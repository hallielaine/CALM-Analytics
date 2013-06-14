#!/bin/sh

if [ ! -f token ]; then
    ./getToken.sh
fi

TOKEN=`cat token`


curl https://na11.salesforce.com/services/apexrest/GetEventRecord/ -H "Authorization: Bearer ${TOKEN}" -H "X-PrettyPrint:1" -H "Content-Type: application/json" --data-binary @testGetEventRecord.json


#curl https://na11.salesforce.com/services/apexrest/getEventRecord/ 
#-d 'access_token=00DG0000000BzbT!AQkAQHRvAPalINUP8oE0mhPYj3JcHnQli61LGTVpIhgfmIV5ADsb_mWOBIKdnIux1fHVNKC1pKIYaiOV1rY6FuLA9kJi461v'
#-d 'grant_type=password' 
#-d 'client_id=3MVG98XJQQAccJQcR1oskEGV9V.GEMHNvCJsTe37wO.3v.Yj14wvz61r8YxuKLM_rhYYeoSKYb7C32udVYA6U' 
#-d 'client_secret=6242913928381552240' 
#-d 'username=calmcoders@calpoly.edu' 
#-d 'password=rtalm20129WQAk0HEmPZLnz47bZaM1w0b' 
#-H "X-PrettyPrint:1" | grep access_token | sed -e 's|^.*: "\(.*\)"$|\1|' > token
