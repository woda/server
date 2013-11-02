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
base={BASE_URL}
else
base=https://localhost:3000
fi

login=logitech

title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.co&password=hello"

title 'Logging in:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users/$login/login -d "password=hello"

list 

foldername=folder1

title 'Creating folder'
echo_run curl -k -b cookies -c cookies -XPUT $base/folder -d "path=$foldername"

list 

title 'Listing created folder'
echo_run curl -k -b cookies -c cookies -XGET $base/files -d "path=$foldername"

id=
while [ "$id" == '' ]
do
title 'Setting file (input ID):'
read -r id
done

title 'set_favorite folder'
echo_run curl -k -b cookies -c cookies -XPOST $base/files/favorite/$id -d 'path=$foldername&favorite=true'

title 'set_public folder'
echo_run curl -k -b cookies -c cookies -XPOST $base/files/public/$id -d 'path=$foldername&public=true'

list 

title 'delete folder'
echo_run curl -k -b cookies -c cookies -XDELETE $base/folder -d 'id=$id'

list

echo
