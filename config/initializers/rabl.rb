Rabl.configure do |config|
  config.include_json_root = false
end

DataMapper::Model.raise_on_save_failure = true
