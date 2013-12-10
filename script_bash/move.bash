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

login=maermove

title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.co&password=azerty42"

title 'Logging in:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users/$login/login -d "password=azerty42"


title 'Adding folder:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPOST $base/create_folder -d "filename=/folder1"


title 'Adding folder:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPOST $base/create_folder -d "filename=/folder1/folder2"


filedata1=iuehzfl

sha2561=`echo -n "$filedata1" | openssl dgst -sha256 | sed 's/(stdin)= //'`

title 'last update'
# match 'last_update(/:id)' => 'sync#last_update', via: :get
echo_run curl -k -b cookies -c cookies -XGET $base/last_update 

title 'Adding file:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPUT $base/sync -d "filename=/folder1/file1&content_hash=$sha2561&size=7"

list

# title 'last update'
# # match 'last_update(/:id)' => 'sync#last_update', via: :get
# echo_run curl -k -b cookies -c cookies -XGET $base/last_update 

# title 'RE Adding file:'
# # match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync -d "filename=/folder1/folder2/folder3/$filename1&content_hash=$sha256&size=$size"

id1=
while [ "$id1" == '' ]
do
title 'Setting file (input ID) 1:'
read -r id1
done

id2=
while [ "$id2" == '' ]
do
title 'Setting file (input ID) 2:'
read -r id2
done

id3=
while [ "$id3" == '' ]
do
title 'Setting file (input ID) 3:'
read -r id3
done

id4=
while [ "$id4" == '' ]
do
title 'Setting file (input ID) 4:'
read -r id4
done


title 'Sending part:'
# match 'sync/:id/:part' => 'sync#upload_part', via: :put
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id1/0 -d "$filedata"
echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id1/0 -d "$filedata1"

title 'move'
# match 'move/:id/from/:source/into/:destination' => 'sync#move', via: :post
echo_run curl -k -b cookies -c cookies -XPOST $base/move/$id1/from/$id2/into/$id3 -d ""

title 'move'
# match 'move/:id/from/:source/into/:destination' => 'sync#move', via: :post
echo_run curl -k -b cookies -c cookies -XPOST $base/move/$id4/from/$id2/into/$id3 -d ""


list

# title 'Deleting file:'
# match 'sync/:id' => 'sync#delete', via: :delete
# echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$id1
# echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$id2
# echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$id3
# echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$id4


echo
