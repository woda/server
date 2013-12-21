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

login=admin
password=azertyzef

title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

title 'Login:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users/$login/login -d "password=$password"

title 'Showing self:'
echo_run curl -k -b cookies -c cookies -XGET $base/users

######################################

title 'list users'
echo_run curl -k -b cookies -c cookies -XGET $base/admin/users

id=
while [ "$id" == '' ]
do
title 'Setting user (input ID):'
read -r id
done

title 'Showing other:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/$id

title 'delete user:'
echo_run curl -k -b cookies -c cookies -XDELETE $base/admin/users/$id

title 'list users'
echo_run curl -k -b cookies -c cookies -XGET $base/admin/users

#####################################

title 'list files'
echo_run curl -k -b cookies -c cookies -XGET $base/admin/files

id=
while [ "$id" == '' ]
do
title 'Setting file (input ID):'
read -r id
done

title 'Showing file:'
echo_run curl -k -b cookies -c cookies -XGET $base/admin/files/$id

title 'delete file:'
echo_run curl -k -b cookies -c cookies -XDELETE $base/admin/files/$id

echo
