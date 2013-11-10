echo_run() {
    printf '\033[90m'; echo "$@"; printf '\033[0m'; read; "$@"
}

title() {
    echo; echo; printf '\033[1m' ; echo "$@"; printf '\033[0m'
}

list() {
	title 'Listing files:'
	echo_run curl -k -b cookies -c cookies -XGET $base/files
}

if [ $# == 1 ]
then
base=https://kobhqlt.fr:3000
else
base=https://localhost:3000
fi

login=
while [ "$login" == '' ]
do
echo 'Enter login name:'
read -r login
done

title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.co&password=hello"

title 'Logging in:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users/$login/login -d "password=hello"

filename=
while [ "$filename" == '' ]
do
title 'Enter file name:'
read -r filename
done

filedata=
while [ "$filedata" == '' ]
do
title 'Enter file data:'
read -r filedata
done

size=
while [ "$size" == '' ]
do
title 'Enter file data size:'
read -r size
done

sha256=`echo -n "$filedata" | openssl dgst -sha256 | sed 's/(stdin)= //'`

title 'Adding file:'
echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$filename -d "content_hash=$sha256&size=$size"

title 'Sending part:'
echo_run curl -k -b cookies -c cookies -XPUT $base/sync_part/0/$filename -d "$filedata"

title 'success upload'
echo_run curl -k -b cookies -c cookies -XPOST $base/sync_success/$filename -d ""

list

title 'Getting part:'
echo_run curl -k -b cookies -c cookies -XGET $base/sync_part/0/$filename

title 'Downloaded list'
echo_run curl -k -b cookies -c cookies -XGET $base/files/downloaded


title 'Listing recent files:'
echo_run curl -k -b cookies -c cookies -XGET $base/files/recents

title 'Listing favorite files:'
echo_run curl -k -b cookies -c cookies -XGET $base/files/favorites

id=
while [ "$id" == '' ]
do
title 'Setting file (input ID):'
read -r id
done

title 'Listing specific files:'
echo_run curl -k -b cookies -c cookies -XGET $base/files/$id

title 'Set file as favorite:'
echo_run curl -k -b cookies -c cookies -XPOST $base/files/favorites/$id -d 'favorite=true'

title 'Listing favorite files:'
echo_run curl -k -b cookies -c cookies -XGET $base/files/favorites

# list 

title 'Making file public:'
echo_run curl -k -b cookies -c cookies -XPOST $base/files/public/$id -d 'public=true'

title 'Listing public file:'
echo_run curl -k -b cookies -c cookies -XGET $base/files/public

title 'list shared files'
echo_run curl -k -b cookies -c cookies -XGET $base/files/shared 

title 'Getting link:'
echo_run curl -k -b cookies -c cookies -XGET $base/files/link/$id

title 'list shared files'
echo_run curl -k -b cookies -c cookies -XGET $base/files/shared

list

title 'Deleting file:'
echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$filename

list

title 'delete user:'
echo_run curl -k -b cookies -c cookies -XDELETE $base/users


echo
