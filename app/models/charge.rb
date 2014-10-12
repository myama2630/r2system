class Charge < ActiveRecord::Base
  belongs_to :repair
  belongs_to :engine
end
