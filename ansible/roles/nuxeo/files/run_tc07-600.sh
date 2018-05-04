#!/bin/bash -x
cd ~/bench-scripts/nuxeo-distribution/nuxeo-jsf-ui-gatling-tests
date
curl -XPOST http://monitor1:8080/events/  -d '{"what": "TC_07 Concurrent Download 600 users Start", "tags":"phases TC_07"}'
time /opt/maven3/bin/mvn -Pbench -nsu gatling:test -Dgatling.simulationClass=org.nuxeo.cap.bench.Sim30Navigation  -DredisDb=0 -Dusers=600 -Dpause_ms=4000 -Dramp=60 -Durl=http://nuxeo1/nuxeo
curl -XPOST http://monitor1:8080/events/  -d '{"what": "TC_07 Concurrent Download 600 users End", "tags":"phases TC_07"}'
date

