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

password=azertyzef987

login=
while [ "$login" == '' ]
do
echo 'Enter login name:'
read -r login
done

title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.com&password=$password"

user_id=
while [ "$user_id" == '' ]
do
title 'Enter user user_id:'
read -r user_id
done

title 'Showing self:'
echo_run curl -k -b cookies -c cookies -XGET $base/users

title 'Showing other:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/12

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
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPUT $base/sync -d "filename=$filename&content_hash=$sha256&size=$size"

file_id=
while [ "$file_id" == '' ]
do
title 'Enter user file_id:'
read -r file_id
done

title 'RE Adding file:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPUT $base/sync -d "filename=$filename&content_hash=$sha256&size=$size"

title 'Showing self:'
echo_run curl -k -b cookies -c cookies -XGET $base/users

title 'Deleting file:'
echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$file_id

title 'Showing self:'
echo_run curl -k -b cookies -c cookies -XGET $base/users

title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

###############################

title 'Login:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users/admin/login -d "password=azertyzef"

title 'Showing other:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/$user_id

title 'Changing user space'
# match 'admin/users/:id/update_space/:space' => 'admin#update_user_space', via: :post
echo_run curl -k -b cookies -c cookies -XPOST $base/admin/users/$user_id/update_space/3 -d ""

title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

##############################

title 'Login:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users/$login/login -d "password=$password"

title 'Showing self:'
echo_run curl -k -b cookies -c cookies -XGET $base/users

title 'RE Adding file:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPUT $base/sync -d "filename=$filename&content_hash=$sha256&size=$size"

title 'Showing self:'
echo_run curl -k -b cookies -c cookies -XGET $base/users

title 'Deleting file:'
echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$file_id

title 'Showing self:'
echo_run curl -k -b cookies -c cookies -XGET $base/users

title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

echo
