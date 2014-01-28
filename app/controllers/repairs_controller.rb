class RepairsController < ApplicationController
  before_action :set_repair, only: [:show, :edit, :update, :destroy]

  # GET /repairs
  # GET /repairs.json
  def index

  
    # 1.初期表示（メニューなどからの遷移時）
    #    ログインユーザの会社コードのみを条件に抽出
    #    ①検索条件のクリア
    #    ②ログインユーザの会社コードという条件のみセッションへの保存
    # 2.検索ボタン押下時
    #    画面入力された条件に対して抽出
    #    ①検索条件のクリア
    #    ②画面入力された条件のセッションへの保存
    # 3.ページ繰り時
    #    直前の検索条件をもとにページ繰り
    #    ①検索条件のセッションからの取り出し
    if params[:page].nil?
      # ページ繰り以外
      @searched = Hash.new
      session[:searched] = @searched


      if params[:commit].nil?
        # 初期表示時：全件表示（条件なし）
      else
        # 検索ボタン押下時：画面入力された条件のセッションへの保存
        # 検索条件を取り込むときに、あらかじめ blank? なものは設定されていないと見なす。(engineの検索と同じ)
        params[:search].each do |key, val|
          @searched[key.intern] = val unless val.blank?
        end
      end
    else
      # ページ繰り時：検索条件のセッションからの取り出し
      @searched = session[:searched]
    end

    #エンジンの条件を設定する（エンジンに紐付く整備情報を取得するため）
    arel = Engine.arel_table
    cond = []

    # エンジンステータス
    if enginestatus_id = @searched[:enginestatus_id]
      cond.push(arel[:enginestatus_id].eq enginestatus_id)
    end

    #Yes本社の場合全件表示、それ以外の場合は自社の管轄のエンジンを対象とする。
    #※管轄が変わると表示されなくなるので注意が必要…
    unless current_user.yesOffice?
      cond.push(arel[:company_id].eq current_user.company_id)
    end
    
    #対象のエンジン情報を取得して、そのエンジンに紐付く整備情報を取得する
    @repairs = Repair.includes(:engine).where(cond.reduce(&:and)).order(Engine.arel_table[:enginestatus_id]).order(:updated_at).reverse_order.paginate(page: params[:page], per_page: 10)

  end

  # GET /repairs/1
  # GET /repairs/1.json
  def show
  end

  # GET /repairs/new
  def new
    @repair = Repair.new
    # パラメータにengine_idがあり、整備にまだエンジンが紐づけられていなければ、エンジンを紐づける
    if !(params[:engine_id].nil?)
      if @repair.engine.nil?
        @repair.engine = Engine.find(params[:engine_id])
      end
    end
  end

  # GET /repairs/1/edit
  # ステータスでレンダリング先を変える。
  def edit
    #エンジンが受領前状態の場合、
    # メソッド名の lower-camel-case -> snake-case 変更です。
    # ここの if 文の並びも排他的な条件なので、case 文に変更すると読みやすくなる
    # と思います。
    if @repair.engine.before_arrive?
      render :templathe => "repairs/returning"
    end
    #エンジンが整備前状態の場合、整備前
    if @repair.engine.before_repair?
      render :template => "repairs/engineArrived"
    end
    #エンジンが整備中の場合
    if @repair.engine.under_repair?
      render :template => "repairs/repairStarted"
    end
    #エンジンが整備完了(完成品状態)の場合、
    if @repair.engine.finished_repair?
      render :template => "repairs/repairFinished"
    end
  
    #if @repair.engine.beforeShipping?
    #  render :template => "engineorders/?"
    #end
    #if @repair.engine.afterShipped?
    #  render :template => "engineorders/?"
    #end
  
  end

  # POST /repairs
  # POST /repairs.json
  def create
    # パラメータにエンジンIDがある場合、まずエンジンに、作業中の整備オブジェクトの取得を試みる
    engine = Engine.find(params[:repair][:engine_id])
    @reapir = engine.current_repair

    # 作業中の整備オブジェクトが存在しない場合、整備オブジェクトを作って、当該のエンジンに紐づける
    if @reapir.nil?
      @repair = Repair.new(repair_params)  
      @repair.issue_no = Repair.createIssueNo
      @repair.issue_date = Date.today
      @repair.engine = engine
    end

    # エンジンのステータスをセットする。
    setEngineStatus
    @repair.engine.save
    
    respond_to do |format|
      if @repair.save
        format.html { redirect_to @repair, notice: t("controller_msg.repair_created") }
        format.json { render action: 'show', status: :created, location: @repair }
      else
        format.html { render action: 'new' }
        format.json { render json: @repair.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /repairs/1
  # PATCH/PUT /repairs/1.json
  def update
    #整備依頼の場合、新規に依頼Noと整備依頼日を取得する
      if params[:commit] == t('views.buttun_repairOrdered')
        @repair.order_no = Repair.createOrderNo
        @repair.order_date = Date.today
      end

    respond_to do |format|
      if @repair.update(repair_params)
        # パラメータにenginestatus_idがあれば、エンジンのステータスを設定し、所轄をログインユーザの会社に変更する
        self.setEngineStatus

		    #if !(params[:enginestatus_id].nil?)
		    #  @repair.engine.enginestatus = Enginestatus.find(params[:enginestatus_id].to_i)
		    #  if params[:enginestatus_id].to_i == 1
        #    @repair.engine.company = current_user.company
		    #  end
		    #end
		    
		    # もし整備依頼の場合は、その整備会社のユーザに整備依頼メールを送信する。

#		    if params[:commit] == t('views.buttun_repairOrdered')
#           R2mailer.sendRepairOrderMail(User.collect_emails_by_company(@repair.engine.company)  , @repair).deliver
#        end

		    @repair.engine.save
		    
        format.html { redirect_to @repair, notice: t("controller_msg.repair_updated") }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @repair.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repairs/1
  # DELETE /repairs/1.json
  def destroy
    @repair.destroy
    respond_to do |format|
      format.html { redirect_to repairs_url }
      format.json { head :no_content }
    end
  end

  # GET /repairs/engineArrived/1
  def engineArrived
    # パラメータにエンジンIDがある場合、まずエンジンに、作業中の整備オブジェクトの取得を試みる
    engine = Engine.find(params[:engine_id])
    @repair = engine.current_repair
    # 作業中の整備オブジェクトが存在しない場合、整備オブジェクトを作って、当該のエンジンに紐づける
    if @repair.nil?
      @repair = Repair.new()  
	    if !(params[:engine_id].nil?)
        @repair.engine = engine
	    end   
    end
  end

  # GET /repairs/repairStarted/1
  def repairStarted
    set_repair
  end

  # GET /repairs/repairFinished/1
  def repairFinished
    set_repair
  end
  
  # GET /repairs/repairOrder/1  
  def repairOrder
    set_repair
  end

  # 必要に応じて、エンジンのステータスと所轄を設定する
  def  setEngineStatus
  
    # 受領登録時→整備前
    if params[:commit] == t('views.buttun_arrived')
      # エンジンオブジェクトの状態更新を、そのまま代入文に置き換えました。
      @repair.engine.status = Enginestatus.of_before_repair
      @repair.engine.company = current_user.company	
    end
    # 整備開始→整備中
    if params[:commit] == t('views.buttun_repairStarted')
      @repair.engine.status = Enginestatus.of_under_repair
      @repair.engine.company = current_user.company
    end
    # 整備完了→完成品
    if params[:commit] == t('views.buttun_repairFinished')
      @repair.engine.status = Enginestatus.of_finished_repair
      @repair.engine.company = current_user.company
    end

  end

  #整備依頼書のダウンロードを行う
  def download_requestpaper
    filename = URI.decode(Repair.find(params[:id]).requestpaper_url.to_s)
    send_file("public/#{filename}")
  end

  #組立チェックシートのダウンロードを行う
  def download_checkpaper
    filename = URI.decode(Repair.find(params[:id]).checkpaper_url.to_s)
    send_file("public/#{filename}")
  end
  
  #未請求のリストを表示する
  def notbilling
    @repairs = Repair.all.paginate(page: params[:page], per_page: 10)
  end

  #未支払いのリストを表示する
  def notpayment
    @repairs = Repair.all.paginate(page: params[:page], per_page: 10)
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repair
      @repair = Repair.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def repair_params
      params.require(:repair).permit(:id, :issue_no, :issue_date, :arrive_date, :start_date, :finish_date, :before_comment, :after_comment, :time_of_running, :day_of_test, :returning_comment, :arrival_comment, :order_no, :order_date, :construction_no, :desirable_finish_date, :estimated_finish_date, :engine_id, :enginestatus_id, :shipped_date, :requestpaper, :checkpaper)
    end
end
