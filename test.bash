echo_run() {
    printf '\033[90m'; echo "$@"; printf '\033[0m'; read; "$@"
}

title() {
    echo; echo; printf '\033[1m' ; echo "$@"; printf '\033[0m'
}

if [ $# == 1 ]
then
base=$1
else
base=https://localhost:3000
fi

login=
while [ "$login" == '' ]
do
echo 'Enter login name:'
read -r login
done
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

filedata=
while [ "$filedata" == '' ]
do
title 'Enter file data:'
read -r filedata
done
sha256=`echo -n "$filedata" | openssl dgst -sha256 | sed 's/(stdin)= //'`

title 'Adding file:'
echo_run curl -k -b cookies -c cookies -XPUT $base/sync/hello/world -d "content_hash=$sha256&size=5"

title 'Sending part:'
echo_run curl -k -b cookies -c cookies -XPUT $base/partsync/0/hello/world -d "$filedata"

title 'Getting part:'
echo_run curl -k -b cookies -c cookies -XGET $base/partsync/0/hello/world

title 'Uploading same file:'
echo_run curl -k -b cookies -c cookies -XPUT $base/sync/file_2 -d "content_hash=$sha256&size=5"

title 'Listing recent files:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/recents

title 'Listing favorite files:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/favorites

id=
while [ "$id" == '' ]
do
title 'Setting favorite file (input ID):'
read -r id
done
echo_run curl -k -b cookies -c cookies -XPOST $base/users/favorites/$id -d 'favorite=true'

title 'Listing favorite files:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/favorites

title 'Listing files:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/files

title 'Making file public:'
echo_run curl -k -b cookies -c cookies -XPOST $base/sync/public/hello/world -d 'status=true'

title 'Synchronizing public file:'
echo_run curl -k -b cookies -c cookies -XPUT $base/sync/foreign_public/wo -d "user=$login&foreign_filename=hello/world"

title 'Listing files:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/files

title 'Deleting file:'
echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/hello/world

title 'Listing files:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/files

echo
