class Paymentstatus < ActiveRecord::Base

include Constants::Paymentstatus


  # 他のコードで、マスタデータの id を直接使わないように、マスタデータそのもの
  # を簡単に取得できるようにしました。
  def self.of_unpaid;   find(ID_UNPAID) end
  def self.of_paid;   find(ID_PAID) end

end
