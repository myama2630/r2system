json.array!(@contactinfos) do |contactinfo|
  json.extract! contactinfo, :id, :mailaddr, :title, :content
  json.url contactinfo_url(contactinfo, format: :json)
end
