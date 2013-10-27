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

login=pltrflol

title 'Logout:'
echo_run curl -k -b cookies -c cookies -XGET $base/users/logout


# title 'Creating user:'
# echo_run curl -k -b cookies -c cookies -XPUT $base/users/$login -d "email=$login@gmail.co&password=hello"

title 'Logging in:'
echo_run curl -k -b cookies -c cookies -XPOST $base/users/$login/login -d "password=hello"

# filedata=
# while [ "$filedata" == '' ]
# do
# title 'Enter file data:'
# read -r filedata
# done
# filedata = "ertyehjnroferbfhjebfer"
# sha256=`echo -n "$filedata" | openssl dgst -sha256 | sed 's/(stdin)= //'`

list 

title 'Creating folder'
echo_run curl -k -b cookies -c cookies -XPOST $base/folders/create -d 'path=folder1'

title 'set_favorite folder'
echo_run curl -k -b cookies -c cookies -XPOST $base/folders/favorite -d 'path=folder1&favorite=true'

title 'set_public folder'
echo_run curl -k -b cookies -c cookies -XPOST $base/folders/public -d 'path=folder1&public=true'

list 

title 'delete folder'
echo_run curl -k -b cookies -c cookies -XDELETE $base/folders/delete -d 'path=folder1'

list

  # match 'folders/create/:path' => 'folders#create', via: :post
  # match 'folders/favorite/:path' => 'folders#favorite', via: :post
  # match 'folders/public/:path' => 'folders#public', via: :post
  # match 'folders/:path' => 'folders#delete', via: :delete


# title 'Adding file:'
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync/helloworld -d "content_hash=$sha256&size=23"

# title 'Sending part:'
# echo_run curl -k -b cookies -c cookies -XPUT $base/partsync/0/hello/world -d "$filedata"

# title 'Getting part:'
# echo_run curl -k -b cookies -c cookies -XGET $base/partsync/0/hello/world

# title 'Uploading same file:'
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync/file_2 -d "content_hash=$sha256&size=5"

# id=
# while [ "$id" == '' ]
# do
# title 'Setting favorite file (input ID):'
# read -r id
# done
# echo_run curl -k -b cookies -c cookies -XPOST $base/files/favorite/$id -d 'favorite=true'


# title 'Synchronizing public file:'
# echo_run curl -k -b cookies -c cookies -XPUT $base/sync/foreign_public/wo -d "user=$login&foreign_filename=hello/world"

# title 'Deleting file:'
# echo_run curl -k -b cookies -c cookies -XDELETE $base/sync/hello/world

# title 'Listing files:'
# echo_run curl -k -b cookies -c cookies -XGET $base/users/files

echo
