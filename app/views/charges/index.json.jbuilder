json.array!(@charges) do |charge|
  json.extract! charge, :id, :charge_flg, :charge_price, :charge_comment, :repair_id, :engine_id, :charge_date
  json.url charge_url(charge, format: :json)
end
