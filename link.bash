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

login=pljkhhah


title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.co&password=hello"

title 'Logging in:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users/$login/login -d "password=hello"

# title 'last update'
# echo_run curl -k -b cookies -c cookies -XGET $base/last_update 

filedata1=iuehzfl
filedata2=lkijpom
sha2561=`echo -n "$filedata1" | openssl dgst -sha256 | sed 's/(stdin)= //'`
sha2562=`echo -n "$filedata2" | openssl dgst -sha256 | sed 's/(stdin)= //'`

list

title 'last update'
# match 'last_update(/:id)' => 'sync#last_update', via: :get
echo_run curl -k -b cookies -c cookies -XGET $base/last_update 


title 'Adding folder:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPOST $base/sync_folder -d "filename=/folder1/folder2/folder3"
 
# list

# title 'last update'
# # match 'last_update(/:id)' => 'sync#last_update', via: :get
# echo_run curl -k -b cookies -c cookies -XGET $base/last_update 

title 'Adding file:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPUT $base/sync -d "filename=/folder1/folder2/folder3/file1&content_hash=$sha2561&size=7"

title 'Adding file:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPUT $base/sync -d "filename=/folder1/folder2/folder3/file2&content_hash=$sha2562&size=7"

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


title 'Sending part:'
# match 'sync/:id/:part' => 'sync#upload_part', via: :put
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id1/0 -d "$filedata"
echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id1/0 -d "$filedata1"


title 'Sending part:'
# match 'sync/:id/:part' => 'sync#upload_part', via: :put
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id1/0 -d "$filedata"
echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id2/0 -d "$filedata2"


# title 'success upload'
# # match 'sync/:id' => 'sync#needed_parts', via: :post
# echo_run curl -k -b cookies -c cookies -XGET $base/sync/$id1 -d ""

# list

title 'Making file public:'
echo_run curl -k -b cookies -c cookies -XPOST $base/files/public/$id1 -d 'public=true'

title 'Making file public:'
echo_run curl -k -b cookies -c cookies -XPOST $base/files/public/$id2 -d 'public=true'


list 

login=peeeeeeee

title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.com&password=hello"

title 'linking file'
echo_run curl -k -b cookies -c cookies -XPOST $base/sync_public/$id1 -d ""

title 'linking file'
echo_run curl -k -b cookies -c cookies -XPOST $base/sync_public/$id2 -d "link=true"


# title 'Deleting file:'
# match 'sync/:id' => 'sync#delete', via: :delete
# echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$id1
# echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$id2
# echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$id3

# title 'last update'
# # match 'last_update(/:id)' => 'sync#last_update', via: :get
# echo_run curl -k -b cookies -c cookies -XGET $base/last_update 

list

echo
