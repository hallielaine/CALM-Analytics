#!/bin/sh

curl https://login.salesforce.com/services/oauth2/token -d 'grant_type=password' -d 'client_id=3MVG98XJQQAccJQcR1oskEGV9V.GEMHNvCJsTe37wO.3v.Yj14wvz61r8YxuKLM_rhYYeoSKYb7C32udVYA6U' -d 'client_secret=6242913928381552240' -d 'username=calmcoders@calpoly.edu' -d 'password=rtalm20129WQAk0HEmPZLnz47bZaM1w0b' -H "X-PrettyPrint:1" | grep access_token | sed -e 's|^.*: "\(.*\)"$|\1|' > token
