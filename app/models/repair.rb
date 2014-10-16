class Repair < ActiveRecord::Base

  # validation

 # 整備依頼時の必須項目
  validates_presence_of :construction_no,
                                   if: ->(repair) { repair.repair_order? }
  
  validates_uniqueness_of :construction_no,
                                   if: ->(repair) { repair.repair_order? }

  # Association
  belongs_to :engine
  belongs_to :company
  belongs_to :status, class_name: 'Paymentstatus', foreign_key: 'paymentstatus_id'
  has_one :charge

  # Upload
   mount_uploader :requestpaper, RequestpaperUploader
   mount_uploader :checkpaper, CheckpaperUploader

  # 作業中の整備のみを抽出するスコープ (出荷日が設定済みなら作業完了)
  # ActiveRecord のスコープ機能を使って、よく使う「作業中？」条件に名前を付けて
  # います。
  scope :opened, -> { where shipped_date: nil }

  # 完了した整備のみを抽出するスコープ (完了日が設定済みなら整備完了)
  scope :completed, -> { where.not finish_date: nil }

  # エンジンをセットする
  def setEngine(engine)
    if self.engine.nil?
      self.engine = engine
    else
      unless self.engine == engine
        prev_engine = self.engine
        prev_engine.suspend!
        prev_engine.save
        self.engine = engine
      end
    end
  end

  # getter and setter for virtual attribute
  # 返却日
  def returning_date
    unless self.engine.current_order_as_old.nil?
      return self.engine.current_order_as_old.returning_date
    end
    return nil
  end
  def returning_date=(returning_date_value)
    #新規作成時はself.engineがnilなので、いったん確認する。
    #(nilに対してcurrent_order_oldは確認できない…)
    unless self.engine.nil?
      unless self.engine.current_order_as_old.nil? 
        self.engine.current_order_as_old.returning_date = returning_date_value
      end
    end
  end

  # getter and setter for virtual attribute
  # 返却コメント
  def returning_comment
    unless self.engine.current_order_as_old.nil?
      return self.engine.current_order_as_old.returning_comment
    end
    return nil
  end
  def returning_comment=(returning_comment_value)
    #新規作成時はself.engineがnilなので、いったん確認する。
    #(nilに対してcurrent_order_oldは確認できない…)
    unless self.engine.nil?
      unless self.engine.current_order_as_old.nil? 
        self.engine.current_order_as_old.returning_comment = returning_comment_value
      end
    end
  end

  #コメント（交換理由）
  def change_comment
    unless self.engine.current_order_as_old.nil?
      return self.engine.current_order_as_old.change_comment
    end
    return nil
  end
  def change_comment=(change_comment_value)
    #新規作成時はself.engineがnilなので、いったん確認する。
    unless self.engine.nil?
      unless self.engine.current_order_as_old.nil? 
        self.engine.current_order_as_old.change_comment = change_comment_value
      end
    end
  end



  # opened? 問い合わせメソッドを削除しました。
  # DB からフェッチしたデータをアプリ内でふるいにかけることになるので、opened
  # スコープを使って DB 検索時に予め作業中のレコードのみに絞るように変更しまし
  # た。

  # 現時点での発行Noの生成(年月-枝番3桁)
  def self.createIssueNo
    issuedate = Date.today.strftime("%Y%m") 
    maxseq = self.where("issue_no like ?", issuedate + "%").max()
    issueseq = '001'

   unless maxseq.nil?
    issueseq = sprintf("%03d", maxseq.issue_no.split('-')[1].to_i + 1)
   end

    return issuedate + "-" + issueseq
  end


  #現時点での依頼Noの生成 (年月-枝番3桁)
  def self.createOrderNo
    orderdate = Date.today.strftime("%Y%m") 
    maxseq = self.where("order_no like ?", orderdate + "%").max()
    orderseq = '001'
    unless maxseq.nil?
      orderseq = sprintf("%03d", maxseq.order_no.split('-')[1].to_i + 1)
    end
    return orderdate + "-" + orderseq
  end
  
  
  #試運転日から運転年数を求める。(運転年数は、切り上げ)
  def calcRunningYear
    return  ((Date.today - self.day_of_test)/365).ceil unless self.day_of_test.nil? 
  end

  #purachase_priceを'カンマ'をとった状態でオーバーライトする
  def purachase_price=(value)
    if value
      self[:purachase_price] = value.gsub(/,/, '')
    else
      self[:purachase_price] = nil
    end
  end

  # この整備の支払状態が「支払済」であるかを確認する
  def paid?
    self.status == Paymentstatus.of_paid
  end

  # この整備の支払状態が「未払い」であるかを確認する
  def unpaid?
    self.status == Paymentstatus.of_unpaid
  end

  # 当月中に仕入されたかを確認する
  def paid_in_this_month?
    # TODO: models から helpers に依存すべきではない気がする
    self.purachase_date > ApplicationController.helpers.previous_cutoff_date &&
      self.purachase_date <= ApplicationController.helpers.cutoff_date
  end

  # 仕入を取り消す
  def undo_purchase
    # 仕入の取り消しは、
    #   1. 整備の支払状態 == 支払済
    #   2. 仕入日が当月中
    # が前提条件
    cutoff_date = ApplicationController.helpers.cutoff_date
    prev_cutoff_date = ApplicationController.helpers.previous_cutoff_date
    if self.paid? && self.paid_in_this_month?
      # 仕入登録時に更新する項目とそれらの戻し方は下記の通り。
      #   * Repair#status (paymentstatus_id) を ID_PAID に更新
      #     => ID_UNPAID に戻す
      #   * Repair#purachase_date を新規設定
      #     => nil に戻す
      #   * Repair#purachase_comment を新規設定
      #     => nil に戻す
      #   * Repair#purachase_price を新規設定
      #     => nil に戻す
      #   * Repair#competitor_code を新規設定
      #     => nil に戻す
      self.status = Paymentstatus.of_unpaid
      self.purachase_date = nil
      self.purachase_comment = nil
      self.purachase_price = nil
      self.competitor_code = nil
      self.save!
      true
    else
      false
    end
  end

  #整備依頼されている状態以降かどうかをチェックｓるう
  def repair_order? 
    self.order_date.present?    
  end
end
