#!/bin/bash -x
cd ~/bench-scripts/nuxeo-distribution/nuxeo-jsf-ui-gatling-tests
date
curl -XPOST http://monitor1:8080/events/  -d '{"what": "TC_07 Concurrent Download 50 users Start from '"$HOSTNAME"'", "tags":"phases TC_07"}'
time /opt/maven3/bin/mvn -Pbench -nsu gatling:test -Dgatling.simulationClass=org.nuxeo.cap.bench.Sim30Navigation  -DredisHost=gatling1 -DredisDb=0 -Dduration=1800 -Dusers=50 -Dpause_ms=4000 -Dramp=60 -Durl=http://nuxeo1/nuxeo
curl -XPOST http://monitor1:8080/events/  -d '{"what": "TC_07 Concurrent Download 50 users End from '"$HOSTNAME"'", "tags":"phases TC_07"}'
date

