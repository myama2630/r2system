#encoding:UTF-8
class RepairsController < ApplicationController
  before_action :set_repair, only: [:show, :edit, :update, :destroy, :purchase]

  after_action :anchor!, only: [:index, :index_unbilled, :index_purchase, :index_charge]
  after_action :keep_anchor!, only: [:show, :new, :edit, :create, :update, :engineArrived, :repairStarted, :repairFinished, :repairOrder, :purchase, :undo_purchase]

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
    arel_engine = Engine.arel_table
    arel_engine_old_engine_id = Engine.arel_table

    cond = []

    #拠点：管轄
     if company_id = @searched[:company_id]
      cond.push(arel[:company_id].eq company_id)
    end

  # エンジン型式
    if engine_model_name = @searched[:engine_model_name]
      cond.push(arel[:engine_model_name].matches "%#{engine_model_name}%")
    end

   # エンジンNo
    if serialno = @searched[:serialno]
      cond.push(arel[:serialno].matches "%#{serialno}%")
    end  

    # エンジンステータス
    if enginestatus_id = @searched[:enginestatus_id]
      cond.push(arel[:enginestatus_id].eq enginestatus_id)
    end

    #Yes本社の場合全件表示、それ以外の場合は自社の管轄のエンジンを対象とする。(全件表示のため、一旦コメントアウト)
    #※管轄が変わると表示されなくなるので注意が必要…
    # unless (current_user.yesOffice? || current_user.systemAdmin? )
      #cond.push(arel[:company_id].eq current_user.company_id)
    #end
    
    #対象のエンジン情報を取得して、そのエンジンに紐付く整備情報を取得する
    @repairs = Repair.includes(:engine).where(cond.reduce(&:and)).order(Engine.arel_table[:enginestatus_id],Engine.arel_table[:engine_model_name],Engine.arel_table[:serialno]).paginate(page: params[:page], per_page: 10)
    adjust_page(@repairs)
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
    # エンジンが仕入済みの場合
    if @repair.paid?
      render :template => "repairs/purchase"
    else
      case
        #エンジンが受領前の場合
      when @repair.engine.before_arrive?
        render :templathe => "repairs/returning"
      when @repair.engine.before_repair?
        #エンジンが整備前状態の場合、整備前
        render :template => "repairs/engineArrived"
      when @repair.engine.under_repair?
        #エンジンが整備中の場合
        render :template => "repairs/repairStarted"
      when @repair.engine.finished_repair?
        #エンジンが整備完了(完成品状態)の場合、
        render :template => "repairs/repairFinished"
      end
    end
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

    # 整備完了の場合、会計ステータスに「未払い」を付与
    if params[:commit] == t('views.buttun_repairFinished')
      @repair.status = Paymentstatus.of_unpaid
    end

    # 仕入れ登録の場合、会計ステータスに「支払済」を付与
    if params[:commit] == t('views.buttun_repairpurchase')
      @repair.status = Paymentstatus.of_paid
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
        if params[:commit] == t('views.buttun_repairOrdered')
           #メールを送信するのは、本番環境(production)の場合のみ
           if Rails.env.production?
             R2mailer.sendRepairOrderMail(User.collect_emails_by_company(@repair.engine.company), @repair, current_user).deliver
           end
        end

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
      format.html { redirect_to anchor_path }
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
      # 登録ユーザの会社を整備担当の会社とする
      @repair.company = current_user.company
    end
    # 整備開始→整備中
    if params[:commit] == t('views.buttun_repairStarted')
      @repair.engine.status = Enginestatus.of_under_repair
      @repair.engine.company = current_user.company
      # 登録ユーザの会社を整備担当の会社とする
      @repair.company = current_user.company
    end
    # 整備完了→完成品
    if params[:commit] == t('views.buttun_repairFinished')
      @repair.engine.status = Enginestatus.of_finished_repair
      @repair.engine.company = current_user.company
      # 登録ユーザの会社を整備担当の会社とする
      @repair.company = current_user.company
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

  # 未請求作業一覧を表示する
  def index_unbilled
    case
    when params[:search]
      # 再検索時は、新しく入力された検索条件を使用
      @searched = params[:search].deep_symbolize_keys
    when session[:searched] && (params[:page] || request.format.csv?)
      # ページ繰り時、ファイルエクスポート時は、設定済みの検索条件を使用
      @searched = session[:searched]
    else
      # 初期表示時は、整備会社条件を空白とする
      @searched = {company_id: nil}
    end
    session[:searched] = @searched

    respond_to do |format|
      cutoff_date = ApplicationController.helpers.cutoff_date
      title = "#{cutoff_date.year}年#{cutoff_date.month}月度求償分"

      # ユーザの所属組織により、表示する未検収情報を制限する。
      #   o YES 本社ユーザ : 選択した整備会社が完了した未検収情報を閲覧可能
      #   o 整備会社ユーザ : 自社が完了した未検収情報のみ閲覧可能
      if current_user.yesOffice? || current_user.systemAdmin?
        if @searched[:company_id].blank?
          company_cond = {}  # 整備会社欄が空白の場合は、company_id 条件無し
          title += "（ALL）"
        else
          company_cond = {company_id: @searched[:company_id]}
          title += "（#{Company.find(@searched[:company_id]).name}）"
        end
      else
        company_cond = {company_id: current_user.company_id}
      end

      @repairs = Repair.joins(:engine)
                       .where(company_cond)
                       .where(paymentstatus_id: Paymentstatus.of_unpaid,
                              engines: {enginestatus_id: Enginestatus.of_finished_repair})
                       .where("finish_date <= ?", cutoff_date)
                       .order(:finish_date)

      format.html {
        @repairs = @repairs.paginate(page: params[:page], per_page: 10)
        adjust_page(@repairs)
      }
      format.csv {
        csv_str = CSV.generate { |csv|
          csv << [title]
          csv << []
          csv << [Repair.human_attribute_name(:order_no),
                  Repair.human_attribute_name(:construction_no),
                  Repair.human_attribute_name(:finish_date),
                  Engine.human_attribute_name(:engine_model_name),
                  Engine.human_attribute_name(:serialno),
                  "繰越"]
          @repairs.each do |repair|
            csv << [repair.order_no, repair.construction_no,
                    repair.finish_date, repair.engine.engine_model_name,
                    repair.engine.serialno,
                    ApplicationController.helpers.carry_over_mark(repair)]
          end
        }

        send_data(csv_str.encode(Encoding::SJIS),
                  type: "text/csv; charset=shift_jis", filename: "#{title}.csv")
      }
    end
  end

   # 仕入済の一覧を表示する
  def index_purchase
    case
    when params[:search]
      # 再検索時は、新しく入力された検索条件を使用
      @searched = params[:search].deep_symbolize_keys
    when session[:searched] && (params[:page] || request.format.csv?)
      # ページ繰り時、ファイルエクスポート時は、保存済みの検索条件を使用
      @searched = session[:searched]
    else
      # 初期表示時は、当月を検索条件として設定
      @searched = {:"purchase_month(1i)" => Date.today.year, :"purchase_month(2i)" => Date.today.month}
      session[:searched] = @searched
    end
    session[:searched] = @searched

    year  = @searched[:"purchase_month(1i)"].to_i  # 仕入月度 (年)
    month = @searched[:"purchase_month(2i)"].to_i  # 仕入月度 (月)
    start_date = Date.new(year, month, 1)  # 仕入月度は、1日から
    end_date = start_date.end_of_month  # TODO: 仕入月度締めは当月末

    respond_to do |format|
      @repairs = Repair.joins(:engine).where(
        purachase_date: start_date..end_date,
        paymentstatus_id: Paymentstatus.of_paid,
        engines: {enginestatus_id: Enginestatus.of_finished_repair}
       ).order(:purachase_date)
      @total_price = @repairs.sum(:purachase_price)

      format.html {
        @repairs = @repairs.paginate(page: params[:page], per_page: 10)
        adjust_page(@repairs)
      }
      format.csv {
        col_names = [Repair.human_attribute_name(:order_no),
                     Repair.human_attribute_name(:purachase_date),
                     Engine.human_attribute_name(:engine_model_name),
                     Engine.human_attribute_name(:serialno),
                     Repair.human_attribute_name(:purachase_price)
                     ]
        csv_str = CSV.generate(headers: col_names, write_headers: true) { |csv|
          @repairs.each do |repair|
            csv << [repair.order_no, repair.purachase_date,
                    repair.engine.engine_model_name, repair.engine.serialno,
                    repair.purachase_price]
          end
          csv << ["合計仕入価格", @total_price]
        }
        send_data(csv_str.encode(Encoding::SJIS),
                  type: "text/csv; charset=shift_jis", filename: "purchase_date.csv")
      }
    end
  end

   # 振替の一覧を表示する
  def index_charge
    if params[:page]
      # ページ繰り時は、検索条件を引き継ぐ
      @searched = session[:searched]
    else
      if params[:commit]
        # 再検索時は、以前の検索条件に新しく入力された条件をマージ
        @searched = session[:searched]
        @searched.merge!(params[:search])
      else
        # 初期表示時は、未振替情報を表示
        @searched = {"charge_flg" => "before"}
        session[:searched] = @searched
       #Yes本社の場合全件表示、それ以外の場合は自社の管轄のエンジンを対象とする。
       unless (current_user.yesOffice? || current_user.systemAdmin? )
          @searched["company_id"] == current_user.company_id
        end    
      end
    end


   #エンジンの条件を設定する（エンジンに紐付く整備情報を取得するため）
    arel_engine = Engine.arel_table
    cond_engine = []


    
    if (current_user.yesOffice? || current_user.systemAdmin? )
     # company_idがあれば、条件に追加、
      cond_engine.push(arel_engine[:company_id].eq @searched["company_id"]) if @searched["company_id"].present?
    #拠点の場合は、拠点管轄のエンジンを対象とする。
    else
      cond_engine.push(arel_engine[:company_id].eq current_user.company_id)
    end



   #エンジンの条件を設定する（エンジンに紐付く整備情報を取得するため）
    arel_charge = Charge.arel_table
    cond_charge = []

    if @searched["charge_flg"] == "after"
         cond_charge.push(arel_charge[:charge_flg].eq true)
    else
         cond_charge.push(arel_charge[:charge_flg].eq false)
    end


    respond_to do |format|

      @repairs = Repair.includes(:engine).includes(:charge)
      .where(cond_engine.reduce(&:and)).where(cond_charge.reduce(&:and))
      .order(:purachase_date)

      format.html {
        @repairs = @repairs.paginate(page: params[:page], per_page: 10)
        adjust_page(@repairs)
      }

      format.csv {
puts "*****************************"
puts @repairs.count
puts "*****************************"
        col_names = [Repair.human_attribute_name(:order_no),
                     Repair.human_attribute_name(:purachase_date),
                     Engine.human_attribute_name(:engine_model_name),
                     Engine.human_attribute_name(:serialno),
                     Engineorder.human_attribute_name(:sales_amount),
                     Repair.human_attribute_name(:purachase_price)
                     ]
        csv_str = CSV.generate(headers: col_names, write_headers: true) { |csv|
          @repairs.each do |repair|
            csv << [repair.order_no, repair.purachase_date,
                    repair.engine.engine_model_name, repair.engine.serialno,
                    repair.engine.current_order_as_new.sales_amount,
                    repair.purachase_price]
          end
        }
        send_data(csv_str.encode(Encoding::SJIS),
                  type: "text/csv; charset=shift_jis", filename: "test.csv")
      }

    end

  end


  def purchase
    set_repair
  end

  # 仕入の取り消し
  def undo_purchase
    set_repair
    respond_to do |format|
      if @repair.undo_purchase
        # 取り消し成功時は、整備の詳細画面にリダイレクト
        format.html { redirect_to @repair, notice: t("controller_msg.repair_purchase_undone") }
        format.json { head :no_content }
      else
        # 失敗した場合、整備の詳細画面の notice メッセージとして、その旨を通知
        format.html { redirect_to @repair, notice: t("controller_msg.repair_purchase_not_undoable") }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repair
      @repair = Repair.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def repair_params
      params.require(:repair).permit(:id, :issue_no, :issue_date, :arrive_date, :start_date, :finish_date, :before_comment, :after_comment, :time_of_running, :day_of_test, :returning_comment, :arrival_comment, :order_no, :order_date, :construction_no, :desirable_finish_date, :estimated_finish_date, :engine_id, :enginestatus_id, :shipped_date, :requestpaper, :checkpaper, :paymentstatus_id, :purachase_date, :purachase_comment, :purachase_price, :competitor_code)
    end
end
