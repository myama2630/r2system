json.array!(@paymentstatuses) do |paymentstatus|
  json.extract! paymentstatus, :id, :name
  json.url paymentstatus_url(paymentstatus, format: :json)
end
