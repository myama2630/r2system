class EnginesController < ApplicationController
  before_action :set_engine, only: [:show, :edit, :update, :destroy]

  after_action :anchor!, only: [:index, :dellist]
  after_action :keep_anchor!, only: [:show, :new, :edit, :create, :update]

  autocomplete :engine, :engine_model_name, :full => true #, :extra_data => [:default_client_id, :default_client_name]
  
  # GET /engines
  # GET /engines.json
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
        # 初期表示時：ログインユーザの部門コードという条件のみセッションへの保存
        # ハッシュのキーのような定型的な「識別子」っぽいものは、シンボルとした
        # 方が性能も可読性もあがると思いました。

        #全件表示に変更のため、一旦コメントアウト
        #YES本社の場合は、初期表示では条件を使用しないため、
        #本社以外の場合に、検索条件をセットする。(システム管理者もYES本社と同じ扱い)
        #unless (current_user.yesOffice? || current_user.systemAdmin?)
          #@searched[:company_id] = current_user.company_id
        #end

      else
        # 検索ボタン押下時：画面入力された条件のセッションへの保存
        # 検索条件を取り込むときに、あらかじめ blank? なものは設定されていない
        # と見なすように変更しました。
        params[:search].each do |key, val|
          @searched[key.intern] = val unless val.blank?
        end
      end
    else
      # ページ繰り時：検索条件のセッションからの取り出し
      @searched = session[:searched]
    end

    # Rails 標準の Arel 機能を使って、WHERE 条件をオブジェクトとして扱うように
    # 変更しました。
    # cond 配列に WHERE 条件を溜め込んでいきます。
    # Arel は SQL を組み立てるための DSL のようなもので、文字列として SQL 文の
    # 断片を埋め込む必要も無くなり、DBMS を取り替えやすくなります。
    arel = Engine.arel_table
    cond = []

    # 会社コード（管轄）
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
    # ステータス
    if enginestatus_id = @searched[:enginestatus_id]
      cond.push(arel[:enginestatus_id].eq enginestatus_id)
    end

    # cond 配列に溜め込んだ WHERE 条件を AND でつないで検索を実行しています。
    # cond.reduce(&:and) は、Ruby 1.9 で追加された、シンボルから Proc オブジェ
    # クトを作り出す構文を使っています。
    # cond.reduce { |result, c| result.and c } と同じ意味となります。
    # order 指定を paginate の引数で指定すると、実行時に will_paginate 内で
    # deprecated 警告が出たので、外に出しました。
#    @engines = Engine.where(cond.reduce(&:and)).order(:id).paginate(page: params[:page], per_page: 10)
    @engines = Engine.where(cond.reduce(&:and)).order(:enginestatus_id,:engine_model_name,:serialno).paginate(page: params[:page], per_page: 10)
    adjust_page(@engines)
  end

  # GET /engines/1
  # GET /engines/1.json
  def show
  end

  # GET /engines/new
  def new
    @engine = Engine.new
  end

  # GET /engines/1/edit
  def edit
  end

  # POST /engines
  # POST /engines.json
  def create
    @engine = Engine.new(engine_params)

    respond_to do |format|
      if @engine.save
        format.html { redirect_to @engine, notice: t('controller_msg.engine_created') }
        format.json { render action: 'show', status: :created, location: @engine }
      else
        format.html { render action: 'new' }
        format.json { render json: @engine.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /engines/1
  # PATCH/PUT /engines/1.json
  def update
    respond_to do |format|
      if @engine.update(engine_params)
        format.html { redirect_to @engine, notice: t('controller_msg.engine_updated') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @engine.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /engines/1
  # DELETE /engines/1.json
  def destroy
    #流通と整備のどちらも紐付くエンジンがない場合だけ、削除
    if Repair.where(engine_id: @engine.id).count +
        Engineorder.where(new_engine_id: @engine.id).count +
         Engineorder.where(old_engine_id: @engine.id).count  == 0
      @engine.destroy
      respond_to do |format|
        format.html { redirect_to anchor_path , notice: t("controller_msg.engine_deleted")}
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to anchor_path , alert: t("controller_msg.engine_not_deleted")}
        format.json { head :no_content }
      end
    end 
  end

  #インポートする
  def import
    result = Engine.import(params[:file])
    respond_to do |format|
      if result
        format.html { redirect_to anchor_path , notice: t("controller_msg.engine_imported")}
        format.json { head :no_content }
      else
        format.html { redirect_to anchor_path , alert: t("controller_msg.engine_importe_error")}
        format.json { head :no_content }
      end
    end
  end

  # エンジン型式に対応するシリアルNo.リストを抽出する
  def list_serialno
    respond_to do |format|
      engines = Engine.completed.where(engine_model_name: params[:engine_model_name])
      format.json { render json: engines.map { |e| e.serialno }.uniq }
    end
  end


#エンジン一覧の削除候補を表示する
  def dellist

    if params[:page].nil?
      # ページ繰り以外
      @searched = Hash.new
      session[:searched] = @searched
      if params[:commit].nil?

        #YES本社の場合は、初期表示では条件を使用しないため、
        #本社以外の場合に、検索条件をセットする。(システム管理者もYES本社と同じ扱い)
        unless (current_user.yesOffice? || current_user.systemAdmin?)
          @searched[:company_id] = current_user.company_id
        end
      else
        # 検索ボタン押下時：画面入力された条件のセッションへの保存
        params[:search].each do |key, val|
          @searched[key.intern] = val unless val.blank?
        end
      end
    else
      # ページ繰り時：検索条件のセッションからの取り出し
      @searched = session[:searched]
    end

    arel = Engine.arel_table
    cond = []

    # 会社コード（管轄）
    if company_id = @searched[:company_id]
      cond.push(arel[:company_id].eq company_id)
    end
    # エンジン型式
    if engine_model_name = @searched[:engine_model_name]
      cond.push(arel[:engine_model_name].matches "%#{engine_model_name}%")
    end
    # 管轄
    if serialno = @searched[:serialno]
      cond.push(arel[:serialno].matches "%#{serialno}%")
    end

    # 削除対象にならないエンジンIDを取得(整備情報のエンジンID、流通情報の新エンジンID、旧エンジンID)
    repairlist = Repair.pluck(:engine_id)
    engineorderlist_new = Engineorder.pluck(:new_engine_id)
    engineorderlist_old = Engineorder.pluck(:old_engine_id)

    # 削除対象にならないエンジンIDを１つのArrayにする。（重複は除く）
     enginelist = repairlist.concat(engineorderlist_new).concat(engineorderlist_old).uniq

    @engines = Engine.where.not(id: enginelist ).where(cond.reduce(&:and)).order(:enginestatus_id,:engine_model_name,:serialno).paginate(page: params[:page], per_page: 10)

   adjust_page(@engines, :dellist)

  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_engine
      @engine = Engine.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def engine_params
      params.require(:engine).permit(:engine_model_name, :serialno, :company_id, :enginestatus_id, :suspended, :page)
    end
end
