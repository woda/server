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
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.co&password=hello4679"

title 'Logging in:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users/$login/login -d "password=hello4679"

# title 'last update'
# echo_run curl -k -b cookies -c cookies -XGET $base/last_update 


filename1=file1
# while [ "$filename1" == '' ]
# do
# title 'Enter file name 1:'
# read -r filename1
# done

# filename2=file2
# while [ "$filename2" == '' ]
# do
# title 'Enter file name 2:'
# read -r filename2
# done

# filename3=file3
# while [ "$filename3" == '' ]
# do
# title 'Enter file name 3:'
# read -r filename3
# done


filedata=iuehzfl
# while [ "$filedata" == '' ]
# do
# title 'Enter file data:'
# read -r filedata
# done

size=7
# while [ "$size" == '' ]
# do
# title 'Enter file data size:'
# read -r size
# done

sha256=`echo -n "$filedata" | openssl dgst -sha256 | sed 's/(stdin)= //'`

list

title 'last update'
# match 'last_update(/:id)' => 'sync#last_update', via: :get
echo_run curl -k -b cookies -c cookies -XGET $base/last_update 


title 'Adding folder:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPOST $base/create_folder -d "filename=/folder1/folder2/folder3"
 
# list

title 'last update'
# match 'last_update(/:id)' => 'sync#last_update', via: :get
echo_run curl -k -b cookies -c cookies -XGET $base/last_update 


title 'Adding file:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPUT $base/sync -d "filename=/folder1/folder2/folder3/$filename1&content_hash=$sha256&size=$size"

title 'last update'
# match 'last_update(/:id)' => 'sync#last_update', via: :get
echo_run curl -k -b cookies -c cookies -XGET $base/last_update 


title 'RE Adding file:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPUT $base/sync -d "filename=/folder1/folder2/folder3/$filename1&content_hash=$sha256&size=$size"

id1=
while [ "$id1" == '' ]
do
title 'Setting file (input ID) 1:'
read -r id1
done

title 'Sending part:'
# match 'sync/:id/:part' => 'sync#upload_part', via: :put
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id1/0 -d "$filedata"
echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id1/0 -d "iuehzfl"

title 'success upload'
# match 'sync/:id' => 'sync#needed_parts', via: :post
echo_run curl -k -b cookies -c cookies -XGET $base/sync/$id1 -d ""

# title 'Sending part:'
# # match 'sync/:id/:part' => 'sync#upload_part', via: :put
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id1/1 -d "hzf"

# title 'success upload'
# # match 'sync/:id' => 'sync#needed_parts', via: :post
# echo_run curl -k -b cookies -c cookies -XGET $base/sync/$id1 -d ""

# title 'Sending part:'
# # match 'sync/:id/:part' => 'sync#upload_part', via: :put
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id1/2 -d "l"


# title 'Sending part:'
# match 'sync/:id/:part' => 'sync#upload_part', via: :put
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id/0 -d "$filedata"

# title 'success upload'
# # match 'sync/:id' => 'sync#needed_parts', via: :post
# echo_run curl -k -b cookies -c cookies -XGET $base/sync/$id1 -d ""

# list

# title 'RE Adding file:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync -d "filename=$filename3&content_hash=$sha256&size=$size"

title 'Getting part:'
# match 'sync/:id/:part' => 'sync#get', via: :get
echo_run curl -k -b cookies -c cookies -XGET $base/sync/$id1/0

title 'RE Adding file:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPUT $base/sync -d "filename=/folder1/folder2/folder3/$filename1&content_hash=$sha256&size=$size"

# filedata=rth
# size=3
# sha256=`echo -n "$filedata" | openssl dgst -sha256 | sed 's/(stdin)= //'`

title 'last update'
# match 'last_update(/:id)' => 'sync#last_update', via: :get
echo_run curl -k -b cookies -c cookies -XGET $base/last_update 

# title 'Change'
# # match 'sync/:id' => 'sync#change', via: :post
# echo_run curl -k -b cookies -c cookies -XPOST $base/sync/$id -d "filename=$filename&content_hash=$sha256&size=$size"

# title 'last update'
# # match 'last_update(/:id)' => 'sync#last_update', via: :get
# echo_run curl -k -b cookies -c cookies -XGET $base/last_update 

list 

# id2=
# while [ "$id2" == '' ]
# do
# title 'Setting file (input ID) 2:'
# read -r id2
# done

# id3=
# while [ "$id3" == '' ]
# do
# title 'Setting file (input ID) 3:'
# read -r id3
# done


title 'Deleting file:'
# match 'sync/:id' => 'sync#delete', via: :delete
echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$id1
# echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$id2
# echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$id3

title 'last update'
# match 'last_update(/:id)' => 'sync#last_update', via: :get
echo_run curl -k -b cookies -c cookies -XGET $base/last_update 

list

echo
