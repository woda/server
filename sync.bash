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

title 'last update'
echo_run curl -k -b cookies -c cookies -XGET $base/last_update 


# filename=lolilofjf
# filedata=HJDLIPEOAM
# size=10

# sha256=`echo -n "$filedata" | openssl dgst -sha256 | sed 's/(stdin)= //'`


# title 'Adding file:'
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$filename -d "content_hash=$sha256&size=$size"


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

list

title 'Adding file:'
echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$filename -d "content_hash=$sha256&size=$size"

title 'Sending part:'
echo_run curl -k -b cookies -c cookies -XPUT $base/sync_part/0/$filename -d "$filedata"

title 'success upload'
echo_run curl -k -b cookies -c cookies -XPOST $base/sync_success/$filename -d ""

# title 'Getting link:'
# echo_run curl -k -b cookies -c cookies -XGET $base/sync_link/$filename

# list

title 'Getting part:'
echo_run curl -k -b cookies -c cookies -XGET $base/sync_part/0/$filename

filedata=rth
size=3
sha256=`echo -n "$filedata" | openssl dgst -sha256 | sed 's/(stdin)= //'`

title 'last update'
echo_run curl -k -b cookies -c cookies -XGET $base/last_update 

title 'Change'
echo_run curl -k -b cookies -c cookies -XPOST $base/sync/$filename -d "content_hash=$sha256&size=$size"

title 'last update'
echo_run curl -k -b cookies -c cookies -XGET $base/last_update 


list 

title 'Deleting file:'
echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$filename

list

echo
