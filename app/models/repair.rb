class Repair < ActiveRecord::Base

  # validation
  
  # Association
  belongs_to :engine
  
  # Upload
   mount_uploader :requestpaper, RequestpaperUploader
   mount_uploader :checkpaper, CheckpaperUploader

  # 作業中の整備のみを抽出するスコープ (出荷日が設定済みなら作業完了)
  # ActiveRecord のスコープ機能を使って、よく使う「作業中？」条件に名前を付けて
  # います。
  scope :opened, -> { where shipped_date: nil }

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

end
