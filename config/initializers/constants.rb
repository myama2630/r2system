# Enginestatus, Businessstatus マスタデータの id に定数として名前を付けました。
# db/seeds.rb も、この定数を使って仕込みデータを作るので、id がずれることもなく
# 安心です。
module Constants
  module Enginestatus
    ID_BEFORE_ARRIVE   = 1 # 受領前
    ID_BEFORE_REPAIR   = 2 # 整備前
    ID_UNDER_REPAIR    = 3 # 整備中
    ID_FINISHED_REPAIR = 4 # 完成品
    ID_BEFORE_SHIPPING = 5 # 出荷準備中
    ID_AFTER_SHIPPING  = 6 # 出荷済
    ID_ABOUT_TO_RETURN = 7 # 返却予定
    ID_ABOLISHED       = 9 # 廃却済
  end

  module Businessstatus
    ID_INQUIRY              = 1 # 引合
    ID_ORDERED              = 2 # 受注
    ID_SHIPPING_PREPARATION = 3 # 出荷準備中
    ID_SHIPPED              = 4 # 出荷済
    ID_RETURNED             = 5 # 返却済
    ID_CANCELED             = 9 # キャンセル
  end

 module Paymentstatus
    ID_UNPAID               = 1 # 未払い
    ID_PAID                 = 2 # 支払済
  end

  module Engine
    EARLIEST_START_YEAR = 1990 # 最も古いエンジンの試運転年
  end
end
