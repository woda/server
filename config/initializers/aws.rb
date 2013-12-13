BASE_URL='https://kobhqlt.fr:3000'
PART_SIZE=5242880 # 5 * 1024 * 1024

Storage::path='./storage'
Storage::use_aws = false
AWS_ACCESS = 'AKIAIGXEIP24RN5TWCXQ'
AWS_SECRET = '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'

AWS.config(:access_key_id => AWS_ACCESS, :secret_access_key => AWS_SECRET)


