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

base=https://localhost:3000
login=pltzrgerfjrzf


title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.co&password=hello"

title 'Logging in:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users/$login/login -d "password=hello"

# title 'last update'
# echo_run curl -k -b cookies -c cookies -XGET $base/last_update 


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

title 'Adding folder:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPOST $base/sync_folder -d "filename=SUPERFOLDER"
 
list

title 'Adding file:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPUT $base/sync -d "filename=$filename&content_hash=$sha256&size=$size"

id=
while [ "$id" == '' ]
do
title 'Setting file (input ID):'
read -r id
done

title 'Sending part:'
# match 'sync/:id/:part' => 'sync#upload_part', via: :put
echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id/0 -d "$filedata"

title 'success upload'
# match 'sync_success/:id' => 'sync#upload_success', via: :post
echo_run curl -k -b cookies -c cookies -XPOST $base/sync_success/$id -d ""

list

title 'Getting part:'
# match 'sync/:id/:part' => 'sync#get', via: :get
echo_run curl -k -b cookies -c cookies -XGET $base/sync/$id/0

# filedata=rth
# size=3
# sha256=`echo -n "$filedata" | openssl dgst -sha256 | sed 's/(stdin)= //'`

# title 'last update'
# # match 'last_update(/:id)' => 'sync#last_update', via: :get
# echo_run curl -k -b cookies -c cookies -XGET $base/last_update 

# title 'Change'
# # match 'sync/:id' => 'sync#change', via: :post
# echo_run curl -k -b cookies -c cookies -XPOST $base/sync/$id -d "filename=$filename&content_hash=$sha256&size=$size"

title 'last update'
# match 'last_update(/:id)' => 'sync#last_update', via: :get
echo_run curl -k -b cookies -c cookies -XGET $base/last_update 

list 

title 'Deleting file:'
# match 'sync/:id' => 'sync#delete', via: :delete
echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$id

title 'last update'
# match 'last_update(/:id)' => 'sync#last_update', via: :get
echo_run curl -k -b cookies -c cookies -XGET $base/last_update 

list

echo
