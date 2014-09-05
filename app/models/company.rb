#encoding:utf-8
class Company < ActiveRecord::Base
  has_many :engineorders

  # カテゴリが "YES本社" であることを確認する
  def headquarter?
    # TODO: 定数値が散らばるので db/seeds.rb と合わせて整理すること
    self.category == "YES本社"
  end

  # カテゴリが "YES拠点" であることを確認する
  def base?
    # TODO: 定数値が散らばるので db/seeds.rb と合わせて整理すること
    self.category == "YES拠点"
  end

  # カテゴリが "整備会社" であることを確認する
  def tender?
    # TODO: 定数値が散らばるので db/seeds.rb と合わせて整理すること
    self.category == "整備会社"
  end

#法人のCSVをインポートする
def self.import(file)
  CSV.foreach(file.path, headers: true) do |row|
    Company.create! row.to_hash
  end
end

end
