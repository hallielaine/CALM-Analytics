#!/bin/bash

if [ ! -f token ]; then
    ./getToken.sh
fi

TOKEN=`cat token`

curl https://na11.salesforce.com/services/apexrest/ClearDatabase/ -H "Authorization: Bearer ${TOKEN}" -H "X-PrettyPrint:1" -H "Content-Type: application/json" --data-binary @actionOne.json
