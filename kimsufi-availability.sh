#!/bin/bash

#Copyright (c) 2015 Alexis Kinsella <alexis.kinsella@gmail.com>
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of 
#this software and associated documentation files (the "Software"), to deal in the 
#Software without restriction, including without limitation the rights to use, copy, 
#modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
#and to permit persons to whom the Software is furnished to do so, subject to the 
#following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies 
#or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
#INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
#PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
#FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
#ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

DATA=$(curl https://ws.ovh.com/dedicated/r2/ws.dispatcher/getAvailability2)

echo "Searching for OVH references and zone availabilities ..."
REFERENCES=$(echo $DATA | jq '.answer.availability[].reference' | grep "$1")
for REFERENCE in $REFERENCES; do
    echo "REFERENCE: $REFERENCE"
    ZONES=$(echo $DATA | jq '.answer.availability[] | select(.reference == '$REFERENCE').zones[].zone' | grep "$2")
    for ZONE in $ZONES; do
        echo "  - ZONE: $ZONE"
        AVAILABILITY=$(echo $DATA | jq '.answer.availability[] | select(.reference == '$REFERENCE').zones[] | select(.zone == '$ZONE').availability')
        echo "AVAILABILITY: $AVAILABILITY"
        if [[ "$AVAILABILITY" != "\"unknown\"" ]] && [[ "$AVAILABILITY" != "\"unavailable\"" ]]; then
            RESULTS="$RESULTS  - $REFERENCE $ZONE is available: ${AVAILABILITY}"$'\n'
        fi
    done
done

if [[ $RESULTS == "" ]]; then
    echo "No Reference / zone available."
    exit 1
fi
RESULTS="References / zones available : "$'\n'$RESULTS
RESULTS=$(echo $RESULTS | sed s/\"/\'/g)
echo "$RESULTS"

key="$3"
from_email="$4"
reply_to="$from_email"
from_name="$5"
to_email="$6"
subject="References / zones available"

msg='{ "async": false, "key": "'$key'", "message": { "from_email": "'$from_email'", "from_name": "'$from_name'", "headers": { "Reply-To": "'$reply_to'" }, "return_path_domain": null, "subject": "References / zones available", "text": "'$RESULTS'", "to": [ { "email": "'$to_email'", "type": "to" } ] } }'
sendmail_result=$(curl -A 'Mandrill-Curl/1.0' -d "$msg" 'https://mandrillapp.com/api/1.0/messages/send.json' -s 2>&1);
echo "$sendmail_result" | grep "sent" -q; 
if [ $? -ne 0 ]; then
    echo "An error occured trying to send email: $sendmail_result";
    exit 2;
fi
echo "Email sent to '$to_email' !"

exit 0
