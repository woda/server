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

# if [ $# == 1 ]
# then
# base=https://woda-server.com:3000
# else
base=https://localhost:3000
# fi

login=pltrflol

# login=
# while [ "$login" == '' ]
# do
# echo 'Enter login name:'
# read -r login
# done

title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout


# title 'Creating user:'
# echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.co&password=hello"

# title 'Logging out:'
# echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

# title 'Logging out when unlogged:'
# echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

# title 'Creating user that already exists:'
# echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.co&password=hello&first_name=Adrien&last_name=Ecoffet"

title 'Logging in:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users/$login/login -d "password=hello"

# title 'Showing self:'
# echo_run curl -k -b cookies -c cookies -XGET $base/users

# title 'Changing self:'
# echo_run curl -k -b cookies -c cookies -XPOST $base/users -d "email=${login}.2@gmail.com"

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

# list

title 'Sending part:'
echo_run curl -k -b cookies -c cookies -XPUT $base/partsync/0/$filename -d "$filedata"

title 'success upload'
echo_run curl -k -b cookies -c cookies -XPOST $base/sync/success/$filename 

# list

title 'Getting part:'
echo_run curl -k -b cookies -c cookies -XGET $base/partsync/0/$filename

list

# title 'Uploading same file:'
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync/file_2 -d "content_hash=$sha256&size=5"

# id=
# while [ "$id" == '' ]
# do
# title 'Setting favorite file (input ID):'
# read -r id
# done
# echo_run curl -k -b cookies -c cookies -XPOST $base/files/favorite/$id -d 'favorite=true'

# title 'Listing files:'
# echo_run curl -k -b cookies -c cookies -XGET $base/files

# title 'set_shared'
# echo_run curl -k -b cookies -c cookies -XPOST $base/files/share/38 -d 'shared=true'

# title 'Shared files'
# echo_run curl -k -b cookies -c cookies -XGET $base/files/shared

# title 'Recent files'
# echo_run curl -k -b cookies -c cookies -XGET $base/files/recents

# title 'set_public'
# echo_run curl -k -b cookies -c cookies -XPOST $base/files/public/38 -d 'public=true'

# title 'public files'
# echo_run curl -k -b cookies -c cookies -XGET $base/files/public

# title 'set_favorite'
# echo_run curl -k -b cookies -c cookies -XPOST $base/files/favorite/38 -d 'favorite=true'

# title 'favorite files:'
# echo_run curl -k -b cookies -c cookies -XGET $base/files/favorites

# title 'Listing files:'
# echo_run curl -k -b cookies -c cookies -XGET $base/files


# title 'Synchronizing public file:'
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync/foreign_public/wo -d "user=$login&foreign_filename=hello/world"

# title 'Listing files:'
# echo_run curl -k -b cookies -c cookies -XGET $base/files

# title 'Deleting file:'
# echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/hello/world

# title 'Listing files:'
# echo_run curl -k -b cookies -c cookies -XGET $base/users/files

echo
