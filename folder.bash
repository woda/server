echo_run() {
    printf '\033[90m'; echo "$@"; printf '\033[0m'; read; "$@"
}

title() {
    echo; echo; printf '\033[1m' ; echo "$@"; printf '\033[0m'
}

list() {
	title 'Listing files:'
	echo_run curl -k -b cookies -c cookies -XGET $base/folders
}

base=https://localhost:3000
login=pltrflol

title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout


# title 'Creating user:'
# echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.co&password=hello"

title 'Logging in:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users/$login/login -d "password=hello"

list 

foldername=folder1

title 'Creating folder'
echo_run curl -k -b cookies -c cookies -XPUT $base/folders/$foldername -d ""

title 'Listing created folder'
echo_run curl -k -b cookies -c cookies -XGET $base/folders -d "folder=folder1"

title 'set_favorite folder'
echo_run curl -k -b cookies -c cookies -XPOST $base/folders/favorite -d 'path=folder1&favorite=true'

title 'set_public folder'
echo_run curl -k -b cookies -c cookies -XPOST $base/folders/public -d 'path=folder1&public=true'

list 

title 'delete folder'
echo_run curl -k -b cookies -c cookies -XDELETE $base/folders/$foldername

list

echo
