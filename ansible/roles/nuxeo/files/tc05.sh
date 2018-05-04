#!/bin/bash
jcmd Boot GC.run
curl -XPOST http://monitor1:8080/events/  -d '{"what": "TC_05 - Run 1", "tags":"phases import"}'
./import-100.sh
sleep 300
jcmd Boot GC.run
curl -XPOST http://monitor1:8080/events/  -d '{"what": "TC_05 - Run 2", "tags":"phases import"}'
./import-100.sh
sleep 300
jcmd Boot GC.run
curl -XPOST http://monitor1:8080/events/  -d '{"what": "TC_05 - Run 3", "tags":"phases import"}'
./import-100.sh
sleep 30
jcmd Boot GC.run
curl -XPOST http://monitor1:8080/events/  -d '{"what": "TC_05 - End", "tags":"phases import"}'


