BASE_URL='http://kobhqlt.fr:3000'
PART_SIZE=5242880 # 5MB: 5 * 1024 * 1024
DEFAULT_SPACE=1073741824 # 1GB: 1024 * 1024 * 1024

Storage::path='./storage'
Storage::use_aws = false
AWS_ACCESS = ''
AWS_SECRET = ''

AWS.config(:access_key_id => AWS_ACCESS, :secret_access_key => AWS_SECRET)


