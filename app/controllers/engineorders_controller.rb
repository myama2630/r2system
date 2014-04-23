class EngineordersController < ApplicationController
  before_action :set_engineorder, only: [:show, :edit, :update, :destroy]

  after_action :anchor!, only: [:index]
  after_action :keep_anchor!, only: [:show, :new, :edit, :create, :update, :inquiry, :ordered, :allocated, :shipped, :returning, :undo_allocation]

  # GET /engineorders
  # GET /engineorders.json
  def index
  	  
  	if current_user.yesOffice?
    @engineorders = Engineorder.all.order(:updated_at).reverse_order.paginate(page: params[:page], per_page: 10)
    adjust_page(@engineorders)
    
    else
    
    @engineorders = Engineorder.where(:branch_id => current_user.company_id).order(:updated_at).reverse_order.paginate(page: params[:page], per_page: 10)
    adjust_page(@engineorders)
    
    end
  end

  # GET /engineorders/1
  # GET /engineorders/1.json
  def show
  end

  # GET /engineorders/new
  def new
    @engineorder = Engineorder.new
  end

  # GET /engineorders/1/edit
  def edit
    #流通ステータスでレンダリング先を変える。
    # switch 文のような if 文の並びは case 文で書くとすっきりします。
    # 受注オブジェクトの状態問い合わせメソッドを lower-camel-case から
    # snake-case に変更しました。
    case
    when @engineorder.inquiry?
      render :template => "engineorders/inquiry"
    when @engineorder.shipped?
      render :template => "engineorders/shipped"
    when @engineorder.shipping_preparation?
      render :template => "engineorders/allocated"
    when @engineorder.ordered?
      render :template => "engineorders/ordered"
    end
  end	

  # POST /engineorders
  # POST /engineorders.json
  def create
    @engineorder = Engineorder.new(engineorder_params)
    # 流通ステータスを「引合」にセットする(受注モデルは、引合時に新規作成される)
    #  受注オブジェクトの状態更新メソッドを、そのまま代入に置き換えました。
    @engineorder.status = Businessstatus.of_inquiry
    # 発行Noを自動採番する
    @engineorder.issue_no = Engineorder.createIssueNo
    # エンジンのステータスを返却予定にする
    setOldEngine

    #old_engine_idのvalidateチェックを実行させるため、
    #old_engine_idがある場合のみ、エンジンステータス変更を実施するように変更する。
    unless @engineorder.old_engine_id.blank?
      @engineorder.old_engine.status = Enginestatus.of_about_to_return
      @engineorder.old_engine.save
    end
    
    respond_to do |format|
      if @engineorder.save
        format.html { redirect_to @engineorder, notice: t('controller_msg.engineorder_created') }
        format.json { render action: 'show', status: :created, location: @engineorder }
      else
        format.html { render action: 'new' }
        format.json { render json: @engineorder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /engineorders/1
  # PATCH/PUT /engineorders/1.json
  def update
    # すでに新エンジンが登録されていて、入力された新エンジンが現在の新エンジン
    # と異なる場合、一旦引当の取消が必要と判断する
    if new_engine = @engineorder.new_engine
      unless new_engine.id == engineorder_params[:new_engine_id]
        @engineorder.undo_allocation
      end
    end

    # 流通ステータスをセットする。(privateメソッド)
    setBusinessstatus

    respond_to do |format|
      if @engineorder.update(engineorder_params)
        # 受注オブジェクトの状況などから、単純な画面項目のセット以外の、各種編集を行う
        self.editByStatus
        format.html { redirect_to @engineorder, notice: t('controller_msg.engineorder_updated')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @engineorder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /engineorders/1
  # DELETE /engineorders/1.json
  def destroy
    @engineorder.destroy
    respond_to do |format|
      format.html { redirect_to anchor_path }
      format.json { head :no_content }
    end
  end

  # GET /engineorders/engineInquiry/:engine_id'
  # 引合の処理
  def inquiry
    # パラメータのengine_idをもとに、エンジンオブジェクトを取り出す。
    unless params[:id].nil?
      set_engineorder
    end
    if @engineorder.nil?
      unless params[:engine_id].nil?
        engine = Engine.find(params[:engine_id])
        @engineorder = engine.current_order_as_old
        if @engineorder.nil?
          @engineorder = Engineorder.new
          @engineorder.old_engine = engine
        end
      else
        @engineorder = Engineorder.new
      end
    end
  end

  # 受注の処理
  def ordered
    set_engineorder
  end

  # 引当の処理
  def allocated
    set_engineorder
  end

  # 出荷の処理
  def shipped
    set_engineorder
  end

  # 返却の処理
  def returning
    set_engineorder
  end

  # 引当の取り消し
  def undo_allocation
    set_engineorder

    # エンジンオーダと新エンジンの状態に不整合が生じないよう、更新をひとつ
    # のトランザクションにまとめる
    ActiveRecord::Base.transaction do
      respond_to do |format|
        if @engineorder.undo_allocation
          # 取り消し成功時は、エンジンオーダの詳細画面にリダイレクト
          format.html { redirect_to @engineorder, notice: t("controller_msg.engineorder_allocation_undone") }
          format.json { head :no_content }
        else
          # 引当の取り消しのための前提条件を満たしていない場合、エンジンオーダ
          # 詳細画面の notice メッセージとして、その旨を通知
          format.html { redirect_to @engineorder, notice: t("controller_msg.engineorder_allocation_not_undoable") }
          format.json { head :no_content }
        end
      end
    end
  rescue
    # 引当の取り消しのための前提条件は満たしていたが、データベースの更新に失敗
    # まずは、標準のエラー画面に遷移
    raise
  end

  def editByStatus
    # 今の状態では、引当を複数実施する（引当のやり直し）は出来ないかもしれない
    # 下記は要確認
    # ★整備オブジェクトの発行日とは?
    # ★整備オブジェクトの会社コードは、何になるべき？
    #

    # ここの if 文の並びも排他的な条件なので、case 文に変更しました。
    case
    when params[:commit] == t('views.buttun_allocated')
      # 引当画面からの更新の場合
      # 新エンジンのステータスを出荷準備中に変更する。
      @engineorder.new_engine.status = Enginestatus.of_before_shipping
      @engineorder.new_engine.save

    when params[:commit] == t('views.buttun_shipped')
      # 出荷画面からの更新の場合
      # 新エンジンのステータスを出荷済みにセットする。
      @engineorder.new_engine.status = Enginestatus.of_after_shipping
      # 新エンジンの会社を設置先に変更し、DBに反映する
      @engineorder.new_engine.company = @engineorder.install_place
      @engineorder.new_engine.save
      # 出荷しようとしている新エンジンに関わる整備オブジェクトを取得する
      if repair = @engineorder.repair_for_new_engine
        repair.shipped_date = @engineorder.shipped_date
        repair.save
      end

    when params[:commit] == t('views.buttun_returning')
      # 返却画面からの更新の場合
      if repair = @engineorder.repair_for_old_engine
        # 整備オブジェクトの内容を再編集し、旧エンジンを紐づける。
        @engineorder.modifyRepair(repair)
      else
        # 整備オブジェクトを作り、旧エンジンを紐づける。
        repair = @engineorder.createRepair
      end
      # 旧エンジンのステータスを受領前にセットする。
      @engineorder.old_engine.status = Enginestatus.of_before_arrive
      # DBに格納する。
      repair.save
      @engineorder.old_engine.save

    when params[:commit] == t('views.buttun_inquiry')
      # 引合画面からの更新の場合
      @engineorder.old_engine.status = Enginestatus.of_about_to_return
      @engineorder.old_engine.save
    
    end
    
  end

  private
  #流通ステータスをセットする。判定はボタンに表示されているラベルで、どの画面で押されたものかを見て
  #決定している。(ボタンのラベルはprams[:commit]でラベルを取得可能)
  # t('xxxxxx')は、congfg/locales/xxx.ja.ymlから名称を取得するメソッド。
  def setBusinessstatus
    # ここの if 文の並びも排他的な条件なので、case 文に変更しました。
    case
    when params[:commit] == t('views.buttun_inquiry')
      # 引合登録の場合
      # 流通ステータスを、「引合」にセットする。
      setOldEngine
      @engineorder.status = Businessstatus.of_inquiry
    when params[:commit] == t('views.buttun_ordered')
      # 受注登録の場合
      # 流通ステータスを、「受注」にセットする。
      @engineorder.status = Businessstatus.of_ordered
    when params[:commit] == t('views.buttun_allocated')
      # 引当登録の場合
      # 流通ステータスを、「出荷準備中」にセットする。
      @engineorder.status = Businessstatus.of_shipping_preparation
      # エンジンに変更があれば、セットする。
      setNewEngine
    when params[:commit] == t('views.buttun_shipped')
      # 出荷登録の場合
      # 流通ステータスを、「出荷済」にセットする。
      @engineorder.status = Businessstatus.of_shipped
      # エンジンに変更があれば、セットする。
      setNewEngine
    when params[:commit] == t('views.buttun_returning')
      # 返却登録の場合
      # 流通ステータスを、「返却済」にセットする。
      @engineorder.status = Businessstatus.of_returned
      # エンジンに変更があれば、セットする。
      setNewEngine
      setOldEngine
    end
    #paramsに値をセットする(UPDATEで、engineorder_paramsとして更新してもらうため)
    params[:engineorder][:businessstatus_id] = @engineorder.businessstatus_id
  end

  # setNewEngine
  # パラメータにエンジンIDがあればセットメソッドで先に設定する
  def setNewEngine
    engine_id = params[:engineorder][:new_engine_id]
    unless engine_id.blank?
      puts '-----*------new engine changed'
      @engineorder.new_engine = Engine.find(engine_id)
    end
  end

  # setOldEngine
  # パラメータにエンジンIDがあればセットメソッドで先に設定する
  def setOldEngine
    engine_id = params[:engineorder][:old_engine_id]
    unless engine_id.blank?
      @engineorder.old_engine = Engine.find(engine_id)
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_engineorder
    @engineorder = Engineorder.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def engineorder_params
    params.require(:engineorder).permit(
      :issue_no, :inquiry_date, :registered_user_id, :updated_user_id,
      :branch_id, :salesman_id, :install_place_id, :orderer, :machine_no,
      :time_of_running, :change_comment, :order_date, :sending_place_id,
      :sending_comment, :desirable_delivery_date, :businessstatus_id,
      :new_engine_id, :old_engine_id, :old_engine, :new_engine,
      :enginestatus_id,:invoice_no_new, :invoice_no_old, :day_of_test,
      :shipped_date, :shipped_comment, :returning_date, :returning_comment, :title,
      :returning_place_id, :allocated_date)
  end
end
