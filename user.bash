echo_run() {
    printf '\033[90m'; echo "$@"; printf '\033[0m'; read; "$@"
}

title() {
    echo; echo; printf '\033[1m' ; echo "$@"; printf '\033[0m'
}

# if [ $# == 1 ]
# then
# base=https://woda-server.com:3000
# else
base=https://kobhqlt.fr:3000
# fi

# login=suerpcool

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

title 'Showing self:'
echo_run curl -k -b cookies -c cookies -XGET $base/users


title 'Logging out:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

echo
