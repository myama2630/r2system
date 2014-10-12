#encoding:UTF-8
module RepairsHelper

  # エンジン到着登録のためのパスを生成する  
  def engine_arrived_path(engine)
    return '/repairs/engineArrived/' + engine.id.to_s
  end

  # 整備依頼のためのパスを生成する
  def order_repair_path(repair)
    return '/repairs/repairOrder/' +  repair.id.to_s
  end
  
  # 整備開始登録のためのパスを生成する
  def start_repair_path(repair)
    return '/repairs/repairStarted/' +  repair.id.to_s
  end

  # 整備完了登録のためのパスを生成する
  def finish_repair_path(repair)
    return '/repairs/repairFinished/' +  repair.id.to_s
  end

# 仕入れ登録のためのパスを生成する
  def purchase_path(repair)
    return '/repairs/purchase/' +  repair.id.to_s
  end
  
# 整備一覧画面からエンジン到着登録のためのパスを生成する  
  def repair_arrived_path(repair)
    return '/repairs/engineArrived/' + repair.engine_id.to_s
  end

#画面上の編集可否を返す（受領画面）
def getDisabled_EngineArrived
  #整備会社の場合
  if current_user.tender?
      return  {
        :time_of_running=>true,
        :day_of_test=>true,
        :returning_date=>true,
        :returning_comment=>true
      }
  else
    return {
        :time_of_running=>false,
        :day_of_test=>false,
        :returning_date=>false,
        :returning_comment=>false
      }
  end
end



#画面上の編集可否を返す（整備依頼画面）
def getDisabled_RepairOrder
  #整備会社の場合
  if current_user.tender?
      return  {
       :issue_no=>true,
       :issue_date=>true,
       :time_of_running=>true,
       :day_of_test=>true,
       :arrive_date=>true,
       :order_no=>true,
       :order_date=>true,
       :construction_no=>true,
       :desirable_finish_date=>true
      }
  else
    return {
       :issue_no =>  true,
       :issue_date =>  true,
       :time_of_running => false,
       :day_of_test => false,
       :arrive_date=>false,
       :order_no=>false,
       :order_date=>false,
       :construction_no=>false,
       :desirable_finish_date=>false
      }
  end
end

#画面で編集否かどうかを返す（整備開始画面）
def getDisabled_RepairStarted
  #整備会社の場合
  if current_user.tender?
      return  {
        :order_no=>true,
        :order_date=>true,
        :construction_no=>true,
        :desirable_finish_date=>true
      }
  else
    return {
        :order_no=>false,
        :order_date=>false,
        :construction_no=>false,
        :desirable_finish_date=>false
      }
  end
end


#画面で編集否かどうかを返す（整備完了画面）
def getDisabled_RepairFinished
  #整備会社の場合
  if current_user.tender?
      return  {
        :order_no=>true,
        :order_date=>true,
        :construction_no=>true,
        :desirable_finish_date=>true,
        :start_date=>true,
        :estimated_finish_date=>true,
        :before_comment=>true
      }
  else
    return {
        :order_no=>false,
        :order_date=>false,
        :construction_no=>false,
        :desirable_finish_date=>false,
        :start_date=>false,
        :estimated_finish_date=>false,
        :before_comment=>false
    }
  end
end

def cutoff_date
  # TODO: 締め日を常数定義すること
  if Date.today.day > 25
    Date.new(Date.today.next_month.year, Date.today.next_month.month, 25)
  else
    Date.new(Date.today.year, Date.today.month, 25)
  end
end

def previous_cutoff_date
  cutoff_date.advance(months: -1)
end

def carried_over?(repair)
  repair.finish_date <= previous_cutoff_date
end

def carry_over_mark(repair)
  if carried_over?(repair)
    "※"
  else
    ""
  end
end

def repairs_undo_link(repair)
  if repair.paid?
    link_to t("views.link_purchase") + "の取り消し", undo_purchase_path(repair), 
            :style=>"color:red;",
            confirm: t("controller_msg.repair_purchase_undoing?")
  else
    raise "整備に関する逆向きユースケースは、仕入戻しのみ"
  end
end

end
