#!/bin/bash
# This script will extract values from the server-redis-client secret
# into 3 files (tls.crt, tls.key, ca.crt) and then use the redis-cli 
# to connect to the redis cluster. Requires the redis-cli to be available
# and setup properly.
# By default the redis-cli will point to localhost port 6379. Alter
# the script if you want to change the location. Also the kubectl 
# command needs to be alter for namespace. May add this to the script!

kubectl get secret server-redis-client  -o json | jq -r '.data | to_entries[] | select(.key == "ca.crt" or .key == "tls.crt" or .key == "tls.key") | "\(.key) \(.value)"' | while read key value; do echo $value | base64 --decode > "$(echo $key | sed 's/\\././g')"; done

redis-cli --tls --cert tls.crt --key tls.key --cacert ca.crt