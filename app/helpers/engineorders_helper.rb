#encoding: UTF-8
module EngineordersHelper

#画面上の編集可否を返す（受注画面）
def getDisabled_Ordered
  #本社の人は編集可能
  if current_user.yesOffice? || current_user.systemAdmin?
    return {
      :inquiry_date => false,
      :branch => false,
      :salesman_id => false,
      :install_place => false,
      :orderer => false,
      :old_engine_id => false,
      :time_of_running => false,
      :day_of_test => false,
      :change_comment => false
      }
  else
    return  {
      :inquiry_date => true,
      :branch => true,
      :salesman_id => true,
      :install_place => true,
      :orderer => true,
      :old_engine_id => true,
      :time_of_running => true,
      :day_of_test => true,
      :change_comment => true
      }
  end
end

#画面上の編集可否を返す（引当画面）
def getDisabled_Allocated
  if current_user.yesOffice? || current_user.systemAdmin?
    return {
      :inquiry_date => false,
      :order_date => false,
      :branch => false,
      :salesman_id => false,
      :install_place => false,
      :orderer => false,
      :old_engine_id => false,
      :time_of_running => false,
      :day_of_test => false,
      :change_comment => false,
      :sending_place => false,
      :sending_comment => false,
      :desirable_delivery_date => false
      }
  else
    return  {
      :inquiry_date => true,
      :order_date => true,
      :branch => true,
      :salesman_id => true,
      :install_place => true,
      :orderer => true,
      :old_engine_id => true,
      :time_of_running => true,
      :day_of_test => true,
      :change_comment => true,
      :sending_place => true,
      :sending_comment => true,
      :desirable_delivery_date => true
      }
  end
end

	#画面上の編集可否を返す（出荷画面）
def getDisabled_Shipped
  if current_user.yesOffice? || current_user.systemAdmin?
    return {
      :inquiry_date => false,
      :order_date => false,
      :branch => false,
      :salesman_id => false,
      :install_place => false,
      :orderer => false,
      :old_engine_id => false,
      :time_of_running => false,
      :day_of_test => false,
      :change_comment => false,
      :sending_place => false,
      :sending_comment => false,
      :desirable_delivery_date => false,
      :allocated_date => false

      }
  else
      return  {
      :inquiry_date => true,
      :order_date => true,
      :branch => true,
      :salesman_id => true,
      :install_place => true,
      :orderer => true,
      :old_engine_id => true,
      :time_of_running => true,
      :day_of_test => true,
      :change_comment => true,
      :sending_place => true,
      :sending_comment => true,
      :desirable_delivery_date => true,
      :allocated_date => true
      }
  end
end

#画面の項目編集可否を取得する（返却画面）
def getDisabled_Returning
  if current_user.yesOffice?
    return {
      :inquiry_date => false,
      :order_date => false,
      :branch => false,
      :salesman_id => false,
      :install_place => false,
      :orderer => false,
      :old_engine_id => false,
      :time_of_running => false,
      :day_of_test => false,
      :change_comment => false,
      :sending_place => false,
      :sending_comment => false,
      :desirable_delivery_date => false,
      :allocated_date => false,
      :invoice_no_new => false,
      :new_engine_id => false,
      :shipped_date => false,
      :shipped_comment => false,
      :returning_place => false
      }
  else
      return  {
      :inquiry_date => true,
      :order_date => true,
      :branch => true,
      :salesman_id => true,
      :install_place => true,
      :orderer => true,
      :old_engine_id => true,
      :time_of_running => true,
      :day_of_test => true,
      :change_comment => true,
      :sending_place => true,
      :sending_comment => true,
      :desirable_delivery_date => true,
      :allocated_date => true,
      :invoice_no_new => true,
      :new_engine_id => true,
      :shipped_date => true,
      :shipped_comment => true,
      :returning_place => true
      }
  end
end

  def undo_link(engineorder)
    case engineorder.status.id
    when Businessstatus::ID_INQUIRY  # 引合
      # TODO: 未実装
      link_to t("views.link_inquiry") + "の取り消し(未実装)", "#", :style=>"color:red;"
    when Businessstatus::ID_ORDERED  # 受注
      link_to t("views.link_ordered") + "の取り消し", undo_ordered_path(engineorder),
              :style=>"color:red;",
              confirm: t("controller_msg.engineorder_ordered_undoing?")
    when Businessstatus::ID_SHIPPING_PREPARATION  # 出荷準備中
      link_to t("views.link_allocated") + "の取り消し", undo_allocation_path(engineorder),
              :style=>"color:red;",
              confirm: t("controller_msg.engineorder_allocation_undoing?")
    when Businessstatus::ID_SHIPPED  # 出荷済
      link_to t("views.link_shipped") + "の取り消し", undo_shipping_path(engineorder),
              :style=>"color:red;",
              confirm: t("controller_msg.engineorder_shipping_undoing?")
    when Businessstatus::ID_RETURNED  # 返却済
      link_to t("views.link_returning") + "の取り消し", undo_returning_path(engineorder),
              :style=>"color:red;",
              confirm: t("controller_msg.engineorder_returning_undoing?")
    when Businessstatus::ID_CANCELED  # キャンセル
      # TODO: 未実装
      # エンジンオーダをキャンセル状態にするユースケースは無い？
      raise "Not implemented"
    end
  end
end
