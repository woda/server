#!/bin/sh

# If you want to test the server, you have to use this instead of regular
# nc, in order to use ssl

openssl s_client -connect $@
