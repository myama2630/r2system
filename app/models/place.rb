class Place < ActiveRecord::Base
   has_many :engineorders
   belongs_to :company      # 送付先については、拠点ごとの登録とする S-010
end
