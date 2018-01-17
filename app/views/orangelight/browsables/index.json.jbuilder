json.array!(@orangelight_names) do |orangelight_name|
  json.extract! orangelight_name, :id, :label, :count, :sort, :dir
  json.url orangelight_name_url(orangelight_name, format: :json)
end
