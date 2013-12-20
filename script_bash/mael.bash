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

login=mael
password=azerty42

title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout

title 'Creating user:'
echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.co&password=$password"

title 'Logging in:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users/$login/login -d "password=$password"


title 'Adding folder:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPOST $base/create_folder -d "filename=/folder1/folder2/folder3"

title 'Adding folder:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPOST $base/create_folder -d "filename=/folder4/folder5/"

title 'Adding folder:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPOST $base/create_folder -d "filename=/folder6/folder7"



filedata1=iuehzfl
filedata2=lkijpom
filedata3=lkifrfm
filedata4=lerkief
sha2561=`echo -n "$filedata1" | openssl dgst -sha256 | sed 's/(stdin)= //'`
sha2562=`echo -n "$filedata2" | openssl dgst -sha256 | sed 's/(stdin)= //'`
sha2563=`echo -n "$filedata3" | openssl dgst -sha256 | sed 's/(stdin)= //'`
sha2564=`echo -n "$filedata4" | openssl dgst -sha256 | sed 's/(stdin)= //'`

list

title 'Listing files with depth = 0'
echo_run curl -k -b cookies -c cookies -XGET $base/files -d "depth=0"


title 'Listing files with depth = 1'
echo_run curl -k -b cookies -c cookies -XGET $base/files -d "depth=1"

title 'Listing files with depth = 2'
echo_run curl -k -b cookies -c cookies -XGET $base/files -d "depth=2"


title 'last update'
# match 'last_update(/:id)' => 'sync#last_update', via: :get
echo_run curl -k -b cookies -c cookies -XGET $base/files/last_update 


title 'Adding file:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPUT $base/sync -d "filename=/folder1/folder2/folder3/file1&content_hash=$sha2561&size=7"

title 'Adding file:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPUT $base/sync -d "filename=/folder4/folder5/file2&content_hash=$sha2562&size=7"

title 'Adding file:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPUT $base/sync -d "filename=/folder6/file3&content_hash=$sha2563&size=7"

title 'Adding file:'
# match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
echo_run curl -k -b cookies -c cookies -XPUT $base/sync -d "filename=/file4&content_hash=$sha2564&size=7"


# title 'last update'
# # match 'last_update(/:id)' => 'sync#last_update', via: :get
# echo_run curl -k -b cookies -c cookies -XGET $base/files/last_update 

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

title 'last update'
# match 'last_update(/:id)' => 'sync#last_update', via: :get
echo_run curl -k -b cookies -c cookies -XGET $base/files/last_update 


title 'Sending part:'
# match 'sync/:id/:part' => 'sync#upload_part', via: :put
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id1/0 -d "$filedata"
echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id1/0 -d "$filedata1"


title 'Sending part:'
# match 'sync/:id/:part' => 'sync#upload_part', via: :put
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id1/0 -d "$filedata"
echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id2/0 -d "$filedata2"


title 'Sending part:'
# match 'sync/:id/:part' => 'sync#upload_part', via: :put
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id1/0 -d "$filedata"
echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id3/0 -d "$filedata3"

title 'Sending part:'
# match 'sync/:id/:part' => 'sync#upload_part', via: :put
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id1/0 -d "$filedata"
echo_run curl -k -b cookies -c cookies -XPUT $base/sync/$id4/0 -d "$filedata4"

# title 'success upload'
# # match 'sync/:id' => 'sync#needed_parts', via: :post
# echo_run curl -k -b cookies -c cookies -XGET $base/sync/$id1 -d ""

# list

title 'Making file public:'
echo_run curl -k -b cookies -c cookies -XPOST $base/files/public/$id1 -d 'public=true'

title 'Making file public:'
echo_run curl -k -b cookies -c cookies -XPOST $base/files/public/$id2 -d 'public=true'

title 'Set file as favorite:'
echo_run curl -k -b cookies -c cookies -XPOST $base/files/favorites/$id2 -d 'favorite=true'

title 'Set file as favorite:'
echo_run curl -k -b cookies -c cookies -XPOST $base/files/favorites/$id3 -d 'favorite=true'

title 'Getting link:'
echo_run curl -k -b cookies -c cookies -XGET $base/files/link/$id4

title 'last update'
# match 'last_update(/:id)' => 'sync#last_update', via: :get
echo_run curl -k -b cookies -c cookies -XGET $base/files/last_update 

list 

title 'Getting link:'
echo_run curl -k -b cookies -c cookies -XGET $base/files/breadcrumb/$id4

# title 'Deleting file:'
# match 'sync/:id' => 'sync#delete', via: :delete
# echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$id1
# echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$id2
# echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$id3
# echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/$id4


echo
