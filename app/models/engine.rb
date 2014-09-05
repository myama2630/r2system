# coding: utf-8

class Engine < ActiveRecord::Base
  # config/initializers/constants.rb で一元的に定義した定数モジュールを取り込ん
  # でいます。
  # config/initializers/*.rb は、Rails アプリの起動時に自動で実行されるコードを
  # 置く場所です。
  # もちろん Engine に関する定数はここで定義することも可能ですが、今回はアプリ
  # 全体の定数を一ヶ所で一元管理したい、という要件があると想定してこの仕組みに
  # しました。
  include Constants::Engine

  # Association
  # engine.enginestatus は冗長に感じたので、DB スキーマを変更せずにアプリ内では
  # engine.status で Enginestatus をアクセスできるようにしてみました。
  belongs_to :status, class_name: 'Enginestatus', foreign_key: 'enginestatus_id'
  belongs_to :company

  has_many :repairs
  # 古いハッシュリテラルの書き方「:key => val」ではなく、Ruby 1.9 からの新記法
  # 「key: val」に統一しました。タイプ数も少ないですし。
  has_many :engineorders_as_new, class_name: 'Engineorder', foreign_key: 'new_engine_id'
  has_many :engineorders_as_old, class_name: 'Engineorder', foreign_key: 'old_engine_id'

  # Initialize Object
  after_initialize :initialize_engine

  # Validation
  validates :engine_model_name, presence: true
  validates :serialno, presence: true, uniqueness: { scope: :engine_model_name }

  # ActiveRecord のスコープ機能を使ってみました。
  # スコープは頻繁に使うクエリに名前を付けて便利に使いまわすための仕組みです。
  # 通常の where で作ったクエリにスコープで条件を追加したり、
  #   Engine.where(company: yes).suspended
  # ActiveRecord のアソシエーションに条件を追加したり、
  #   engine.engineorders_as_new.opened
  # といったことができます。
  #
  # スコープの中身にあたる、-> { where ... } は、Ruby 1.9 で追加された lambda
  # の新記法です。lambda { where ... } と同じ意味です。

  # サスペンド状態のエンジンのみを抽出するスコープ
  scope :suspended, -> { where suspended: true }
  # 修理済み状態のエンジンのみを抽出するスコープ
  scope :completed, -> { where status: Enginestatus.of_finished_repair }

  # 初期化
  def initialize_engine
    # ステータスが設定されていない場合は「整備前」にする。	
    status = Enginestatus.of_before_repair if enginestatus_id.nil?
  end
  
  # Get current repair (get unclosed one)
  # 現在作業中の整備オブジェクトを返す
  def current_repair
    # if このエンジンに関連する修理が 1 件以上ある場合
    #   foreach それぞれの修理について
    #     if 修理が仕掛かり中の場合
    #       return この修理を返却
    # else
    #   return nil
    #
    # というコードでしたが、上記は関連する修理について opened スコープによりク
    # エリを追加して先頭のレコードを取得するコードで書き換えられます。
    # コードが減り、かつ、DB からフェッチしたデータをアプリ側で精査することがな
    # くなるので、性能も上がるはずです。

    repairs.opened.first
  end

  # このエンジンに関する直近の完了済み整備を取得
  def last_repair
    repairs.completed.order(finish_date: :desc).limit(1).first
  end

  # Get unclosed order (this engine is old engine for it and it is not unclosed)
  # 旧エンジンとして関わっている受注オブジェクトのうち、現在仕掛中のものを返す
  def current_order_as_old
    # 「現在仕掛中」の条件を含める場合は、下記のコメントアウトされたコードを使
    # うと、Engineorder の opened スコープが効くので「返却日 IS NULL」のレコー
    # ドだけに絞れます。

    #engineorders_as_old.opened.first
    engineorders_as_old.first
  end

  # Get unclosed order (this engine is new engine for it and it is not unclosed)
  # 新エンジンとして関わっている受注オブジェクトのうち、現在仕掛中のものを返す
  def current_order_as_new
    #engineorders_as_new.opened.first
    engineorders_as_new.first
  end

  # エンジン型式とシリアルNoを併せてエンジン名として表示する。
  def engine_name
    "#{engine_model_name} ( #{serialno} )"
  end

  # Engine.completedEngines クラスメソッドは、completed スコープを使って 
  #   Engine.completed
  # で取得できるので、削除しました。

  # サスペンド状態かどうか確認する。
  def suspended?
    return self.suspended
  end

  # サスペンド状態にする
  # 状態を変更するメソッドなので、わかりやすくするために ! で終わるメソッド名と
  # しました。
  # Ruby 界隈では、自分の状態を破壊的に更新するようなメソッドには ! を付ける慣
  # 習があります。
  def suspend!
    self.suspended = true
  end

  # サスペンド状態を解除する
  def release!
    self.suspended = false
  end

  # Engine#displaySuspend_orNot メソッドは、エンジンの状態をビューでどう表現す
  # るかという仕事をしてるようです。
  # モデルにビューの仕事が入り込むのはまずいので外に出しました。
  # 引越し先は、app/helpers/engines_helper.rb です。
  # app/helpers/*.rb は、ビューやコントローラで何度も使う便利メソッドを集める場
  # 所です。

  # Engine.start_year クラスメソッドは、定数 EARLIEST_START_YEAR として定義しま
  # した。

  # エンジンのステータスを設定するメソッドたちは、単純に engine.status = ... で
  # 状態を設定すれば十分と考え、削除しました。
  #
  # たとえば、
  #   engine.setBeforeArrive
  # は、
  #   engine.status = Enginestatus.of_before_arrive
  # といった具合になります。

  # 受領前状態かどうか？
  def before_arrive?
    # エンジン状態マスタの id を直接使うのではなく、エンジン状態オブジェクトで
    # 比較するようにしました。
    status.id == Enginestatus.of_before_arrive.id
  end

  # 整備前状態かどうか？
  def before_repair?
    status.id == Enginestatus.of_before_repair.id
  end

  # 整備中状態かどうか？
  def under_repair?
    self.status.id == Enginestatus.of_under_repair.id

  end

  # 整備完了(完成品)状態かどうか？
  def finished_repair?
    status.id == Enginestatus.of_finished_repair.id
  end

  # 出荷準備中状態かどうか？
  def before_shipping?
    status.id == Enginestatus.of_before_shipping.id
  end

  # 出荷済状態かどうか？
  def after_shipped?
    status.id == Enginestatus.of_after_shipping.id
  end

  # 返却予定状態かどうか？
  def about_to_return?
    status.id == Enginestatus.of_about_to_return.id
  end

  # 廃却状態かどうか？
  def abolished?
    status.id == Enginestatus.of_abolished.id
  end

#エンジンのCSVをインポートする
def self.import(file)
  CSV.foreach(file.path, headers: true) do |row|
    #もし、エンジンモデルクラスの型式に、同じ型式が存在しなかったら、そのデータは登録しない。
    import_row = row.to_hash

    if Enginemodel.where(name: import_row["engine_model_name"]).empty?
      return false
    end
  end
  #全て正しい型式が存在した場合のみ、データを登録する。
  CSV.foreach(file.path, headers: true) do |row|
    Engine.create! row.to_hash
  end
  return true
end


end
