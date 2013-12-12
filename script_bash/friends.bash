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

# login=suerpcool

password=azertyzef

login=
while [ "$login" == '' ]
do
echo 'Enter login name:'
read -r login
done

login2=
while [ "$login2" == '' ]
do
echo 'Enter login name:'
read -r login2
done


title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

title 'Creating user 1:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.com&password=$password"

id=
while [ "$id" == '' ]
do
echo 'Enter id:'
read -r id
done


title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

title 'Creating user 12:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login2 -d "email=$login2@gmail.com&password=$password"

################################

title 'Create friend'
echo_run curl -k -b cookies -c cookies -XPUT $base/friends/$id -d ""

title 'List friends'
echo_run curl -k -b cookies -c cookies -XGET $base/friends/ -d ""

# title 'Delete friend'
# echo_run curl -k -b cookies -c cookies -XDELETE $base/friends/$id -d ""

#################################

# title 'delete user:'
# echo_run curl -k -b cookies -c cookies -XDELETE $base/users

title 'Logging out:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

title 'Logging in:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users/$login/login -d "password=$password"

# title 'delete user:'
# echo_run curl -k -b cookies -c cookies -XDELETE $base/users

echo