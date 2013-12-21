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

login1=folder1
login2=folder2
login3=folder3
login4=file1
login5=folder4
login6=folder5
login7=file2

# login1=john
# login2=johnny
# login3=marie
# login4=jana
# login5=aajana
# login6=bonjour
# login7=azerty

password=azertyzef

title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login1 -d "email=$login1@gmail.com&password=$password"

title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login2 -d "email=$login2@gmail.com&password=$password"

title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login3 -d "email=$login3@gmail.com&password=$password"

title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login4 -d "email=$login4@gmail.com&password=$password"

title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login5 -d "email=$login5@gmail.com&password=$password"

title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login6 -d "email=$login6@gmail.com&password=$password"

title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login7 -d "email=$login7@gmail.com&password=$password"


echo
