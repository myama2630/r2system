class Place < ActiveRecord::Base
   has_many :engineorders
   belongs_to :company      # ���t��ɂ��ẮA���_���Ƃ̓o�^�Ƃ��� S-010

   # Place オブジェクトを生成するアクションによって、必須項目が異なるので
   # 単純にバリデーションを設定できない。
end
