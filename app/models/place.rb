class Place < ActiveRecord::Base
   has_many :engineorders
   belongs_to :company      # ���t��ɂ��ẮA���_���Ƃ̓o�^�Ƃ��� S-010
end
