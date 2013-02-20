echo_run() {
    printf '\033[90m'; echo "$@"; printf '\033[0m'; "$@"
}

title() {
    echo; echo; printf '\033[1m' ; echo "$@"; printf '\033[0m'
}

if [ $# == 1 ]
then
base=$1
else
base=https://ec2-54-242-98-168.compute-1.amazonaws.com:3000
fi

echo 'Enter login name:'
read -r login
title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.co&password=hello&first_name=Adrien&last_name=Ecoffet"

title 'Logging out:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

title 'Logging out when unlogged:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

title 'Creating user that already exists:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.co&password=hello&first_name=Adrien&last_name=Ecoffet"

title 'Logging in:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users/$login/login -d "password=hello"

title 'Showing self:'
echo_run curl -k -b cookies -c cookies -XGET $base/users

title 'Changing self:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users -d "email=${login}.2@gmail.com"

title 'Enter file data:'
read -r filedata
sha256=`echo -n "$filedata" | openssl dgst -sha256`

title 'Adding file:'
echo_run curl -k -b cookies -c cookies -XPUT $base/sync/hello/world -d "content_hash=$sha256&size=7"

#echo_run curl https://woda-files.s3.amazonaws.com/ -XPOST -d 'enctype=multipart/form-data&'"`ruby get_request.rb \"$results\"`"'&file='"$filedata"

title 'Getting file:'
echo_run curl -k -b cookies -c cookies -XGET $base/sync/hello/world

title 'Uploading same file:'
echo_run curl -k -b cookies -c cookies -XPUT $base/sync/file_2 -d "content_hash=$sha256&size=7"

title 'Listing files:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/files

title 'Deleting file:'
echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/hello/world
