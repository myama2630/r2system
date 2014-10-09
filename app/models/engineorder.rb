class Engineorder < ActiveRecord::Base
  #Association
  # engine.status と同様に、DB スキーマを変更せずに order.status で
  # Businessstatus を取得できるように変更しました。
  
  belongs_to :status, class_name: 'Businessstatus', foreign_key: 'businessstatus_id'

  belongs_to :old_engine, :class_name => 'Engine' 
  belongs_to :new_engine, :class_name => 'Engine' 

  belongs_to :branch, :class_name => 'Company' 
#  belongs_to :sending_place,   :class_name => 'Company' 

  belongs_to :returning_place, :class_name => 'Company' 

  #場所（設置場所）
  belongs_to :install_place,   :class_name => 'Place' , foreign_key: 'install_place_id'
  accepts_nested_attributes_for :install_place

  #場所（送付先）
  belongs_to :sending_place,   :class_name => 'Place' , foreign_key: 'sending_place_id'
  accepts_nested_attributes_for :sending_place


  belongs_to :registered_user, :class_name => 'User' 
  belongs_to :updated_user, :class_name => 'User' 
  belongs_to :salesman, :class_name => 'User' 
  belongs_to :company
  belongs_to :enginestatus

  # 仕掛中の受注のみを抽出するスコープ (返却日が設定済みなら完了と見なす)
  # ActiveRecord のスコープ機能を使って、よく使う「仕掛かり中？」条件に名前を付
  # けています。
  scope :opened, -> { where returning_date: nil }


  #旧エンジンは必ず流通登録に必要なので、必須項目とする。
  validates :old_engine, presence: true

  # View でも数値以外入力できないように制限しているが、ブラウザ以外のクライアン
  # トなども考慮して、Model でもバリデーションを設定しておく。
  validates_numericality_of :time_of_running

  accepts_nested_attributes_for :old_engine
  accepts_nested_attributes_for :new_engine

  # 新エンジンをセットする
  # 独自の setNewEngine メソッドではなく、そのまま order.new_engine = engine と
  # 書けるように、ActiveRecord が定義する new_engine= メソッドを拡張しました。
  # もともとの new_engine= メソッドを内部で呼び出すので、メソッド定義を上書きす
  # る前に元のメソッドに alias で別名を付けています。
  # あと、冗長な self. 指定も削りました。
  alias :_orig_new_engine= :new_engine=
  def new_engine=(engine)
    if engine
      if self.new_engine && self.new_engine != engine
        # 新エンジンが指定済みの場合は、その新エンジンをサスペンド状態に変更する
        self.new_engine.suspend!
        self.new_engine.save
      end
    else
      # エンジンオーダの新エンジンを nil に更新する (引当を取り消す) ので、
      # エンジンオーダが "出荷準備中" 状態の場合、"受注" 状態に戻す
      if self.new_engine && self.shipping_preparation?
        self.status = Businessstatus.of_ordered
      end
    end
    self._orig_new_engine = engine
  end

  # 旧エンジンを差し替える
  def switch_old_engine(engine)
    if self.old_engine && self.old_engine != engine
      # 旧エンジンが指定済みの場合は、その旧エンジンをサスペンド状態に変更する
      self.old_engine.suspend!
      self.old_engine.save!
    end
    self.old_engine = engine
  end

  # ステータスの確認メソッド集 --------------- #
  # メソッド名を lower-camel-case -> snake-case に変更しています。
  # 新規引合かどうか？
  def new_inquiry?
    self.status.nil?
  end 

  # 引合かどうか？
  def inquiry?
    self.status == Businessstatus.of_inquiry
  end 

  # 受注かどうか？
  def ordered?
    self.status == Businessstatus.of_ordered
  end 

  # 出荷準備中かどうか？
  def shipping_preparation?
    self.status == Businessstatus.of_shipping_preparation
  end 

  # 出荷済かどうか？
  def shipped?
    self.status == Businessstatus.of_shipped
  end 

  # 返却済みかどうか？
  def returned?
    self.status == Businessstatus.of_returned
  end 

  # キャンセルかどうか？
  def canceled?
    self.status == Businessstatus.of_canceled
  end 

  # 旧エンジンに対する整備オブジェクトを取り出す
  def repair_for_old_engine
    return self.old_engine.current_repair
  end

  # 新エンジンに対する整備オブジェクトを取り出す
  def repair_for_new_engine
    return self.new_engine.current_repair
  end

  #現時点での発行Noの生成 (年月-枝番3桁)
  def self.createIssueNo
    issuedate = Date.today.strftime("%Y%m") 
    maxseq = self.where("issue_no like ?", issuedate + "%").max()
    issueseq = '001'

   unless maxseq.nil?
    issueseq = sprintf("%03d", maxseq.issue_no.split('-')[1].to_i + 1)
   end

    return issuedate + "-" + issueseq

  end


  #試運転日から運転年数を求める。(運転年数は、切り上げ)
  def calcRunningYear
    return  ((Date.today - self.day_of_test)/365).ceil unless self.day_of_test.nil? 
  end

  # 整備オブジェクトを受領前の状態で新規作成する
  def createRepair
    repair = Repair.new
    repair.issue_no          = Repair.createIssueNo
    copyToRapair(repair)
    # 整備オブジェクトに旧エンジンを紐づける
    repair.setEngine(self.old_engine)
    
    return repair
  end

  # 整備オブジェクトを再度設定する。
  def modifyRepair(repair)
    copyToRapair(repair)
    # 整備オブジェクトに旧エンジンを紐づける
    repair.setEngine	(self.old_engine)
    
    return repair
  end
  
  # 整備に必要な属性を、自身からコピーする。
  def copyToRapair(repair)
    repair.issue_date        = self.order_date
    repair.time_of_running   = self.time_of_running
    repair.day_of_test       = self.day_of_test
  end
  
  # 引当を取り消す
  def undo_allocation
    # 引当の取り消しは、
    #   1. エンジンオーダの状態 == 出荷準備中
    #   2. エンジンオーダに新エンジンが割り当て済み
    #   3. 新エンジンの状態 == 出荷準備中
    # が前提条件
    if self.shipping_preparation? &&
        new_engine = self.new_engine and new_engine.before_shipping?
      # 新エンジンの状態を "完成品" に戻す
      new_engine.status = Enginestatus.of_finished_repair
      new_engine.save!
      # 引当時に新規入力した項目をクリア
      self.new_engine = nil
      self.allocated_date = nil
      self.save!
      true
    else
      false
    end
  end

  # 受注を取り消す
  def undo_ordered
    # 受注の取り消しは、
    #   1. エンジンオーダの状態 == 受注
    #   2. エンジンオーダに旧エンジンが割り当て済み
    #   3. 旧エンジンの状態 == 返却予定
    # が前提条件。
    # 受注を取り消すと、以下の状態になる。
    #   1. エンジンオーダの状態 = 引合
    #   2. 旧エンジンの状態 = 出荷済

    if self.ordered? &&
        old_engine = self.old_engine and old_engine.about_to_return?
      # 旧エンジンの状態を "出荷済" に戻す
      old_engine.status = Enginestatus.of_after_shipping
      old_engine.save!
      #自分自身のステータスを、引合にする。
      self.status = Businessstatus.of_inquiry
      # 受注時に新規入力した項目をクリア(受注日、送付先、送付コメント)
      self.order_date = nil
      self.sending_place_id = nil
      self.sending_comment = nil
      self.save!
      true
    else
      false
    end
  end

  def undo_shipping
    # 出荷の取り消しは、
    #   1. エンジンオーダの状態 == 出荷済み
    #   2. 新エンジンの状態 == 出荷済み
    #   3. 新エンジンの管轄 == 拠点
    # が前提条件。
    # 出荷を取り消すと、以下の状態になる。
    #   1. エンジンオーダの状態 == 出荷準備中
    #   2. 新エンジンの状態 == 出荷準備中
    #   3. 新エンジンの管轄 == 整備会社 (新エンジンを修理した会社)
    #   4. 新エンジンに関する(直近の)修理の出荷日がブランク
    if self.shipped? and
        new_engine = self.new_engine and new_engine.after_shipped? and
        new_engine_owner = new_engine.company and new_engine_owner.base?
      # 新エンジンの状態を "出荷準備中" に戻す
      new_engine.status = Enginestatus.of_before_shipping
      # 新エンジンの管轄を "整備会社" に戻す
      # 戻し先の整備会社は、新エンジンに関する直近の修理を担当した会社
      if repair = new_engine.last_repair
        new_engine.company = repair.company
      end
      new_engine.save!
      # 新エンジンに関する直近の修理の出荷日をブランクに戻す
      if repair = new_engine.current_repair
        repair.shipped_date = nil
        repair.save!
      end
      # エンジンオーダの状態を "出荷準備中" に戻す
      self.status = Businessstatus.of_shipping_preparation
      # 出荷時に新規入力した項目をクリア(送り状No.、出荷日、出荷コメント)
      self.invoice_no_new = nil
      self.shipped_date = nil
      self.shipped_comment = nil
      self.save!
      true
    else
      false
    end
  end

  #sales_amountの値を'カンマ'をとった状態でオーバーライトする
  def sales_amount=(value)
    self[:sales_amount] = value.gsub(/,/, '')
  end

  def old_engine_attributes=(attrs)
    self.old_engine = Engine.find_or_initialize_by(id: attrs.delete(:id))
    self.old_engine.attributes = attrs
  end

  def new_engine_attributes=(attrs)
    self.new_engine = Engine.find_or_initialize_by(attrs)
  end
end
