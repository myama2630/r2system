json.array!(@places) do |place|
  json.extract! place, :id, :name, :category, :postcode, :address, :phone_no, :destination_name
  json.url place_url(place, format: :json)
end
