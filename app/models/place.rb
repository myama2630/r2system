class Place < ActiveRecord::Base
   has_many :engineorders
   belongs_to :company      # 送付先については、拠点ごとの登録とする S-010

   # Place 繧ｪ繝悶ず繧ｧ繧ｯ繝医ｒ逕滓�舌☆繧九い繧ｯ繧ｷ繝ｧ繝ｳ縺ｫ繧医▲縺ｦ縲∝ｿ�鬆磯��逶ｮ縺檎焚縺ｪ繧九�ｮ縺ｧ
   # 蜊倡ｴ斐↓繝舌Μ繝�繝ｼ繧ｷ繝ｧ繝ｳ繧定ｨｭ螳壹〒縺阪↑縺�縲�
end
