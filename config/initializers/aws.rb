AWS_ACCESS = 'AKIAIGXEIP24RN5TWCXQ'
AWS_SECRET = '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'

AWS.config(:access_key_id => AWS_ACCESS,
	:secret_access_key => AWS_SECRET)

EMAIL_SETTINGS = YAML::load(File.read("#{Rails.root}/config/mail.yml"))[Rails.env]
raise "Error: no email settings, create file config/mail.yml" unless EMAIL_SETTINGS

ActionController::Base.default_charset = "ISO-8859-1"
