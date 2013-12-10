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
base=http://kobhqlt.fr:3000
else
base=http://localhost:3000
fi

login=logitzg

title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.co&password=hello"

title 'Logging in:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users/$login/login -d "password=hello"

list 

foldername=folder1/folder2/folder3

title 'Creating folder'
echo_run curl -k -b cookies -c cookies -XPOST $base/sync_folder -d "filename=$foldername"

list 

id=
while [ "$id" == '' ]
do
title 'Setting file (input ID):'
read -r id
done

title 'Listing created folder'
echo_run curl -k -b cookies -c cookies -XGET $base/files/$id


title 'set_favorite folder'
echo_run curl -k -b cookies -c cookies -XPOST $base/files/favorites/$id -d 'path=$foldername&favorite=true'

title 'set_public folder'
echo_run curl -k -b cookies -c cookies -XPOST $base/files/public/$id -d 'path=$foldername&public=true'

list 

title 'Listing recent files:'
echo_run curl -k -b cookies -c cookies -XGET $base/files/recents

title 'delete folder'
echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$id

list

echo
