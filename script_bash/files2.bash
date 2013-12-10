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
echo_run curl -k -b cookies -c cookies -XPUT $base/sync -d "filename=$filename&content_hash=$sha256&size=$size"

id=
while [ "$id" == '' ]
do
title 'Setting file (input ID):'
read -r id
done


title 'Sending part:'
echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id/0 -d "$filedata"

title 'success upload'
echo_run curl -k -b cookies -c cookies -XGET $base/sync/$id

list

title 'Listing specific files:'
echo_run curl -k -b cookies -c cookies -XGET $base/files/$id

title 'Making file public:'
echo_run curl -k -b cookies -c cookies -XPOST $base/files/public/$id -d 'public=true'

title 'Listing public file:'
echo_run curl -k -b cookies -c cookies -XGET $base/files/public

title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

login=
while [ "$login" == '' ]
do
echo 'Enter login name:'
read -r login
done

title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.co&password=hello"

title 'Logging in:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users/$login/login -d "password=hello"

id=
while [ "$id" == '' ]
do
title 'User ID:'
read -r id
done

title 'Showing user:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/$id

title 'Listing files:'
echo_run curl -k -b cookies -c cookies -XGET $base/usersfiles/$id


echo
