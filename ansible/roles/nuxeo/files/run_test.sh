#!/bin/bash -x
cd ~/bench-scripts/nuxeo-distribution/nuxeo-jsf-ui-gatling-tests
date
curl -XPOST http://monitor1:8080/events/  -d '{"what": "TC_11 Day in life 100 users", "tags":"phases TC_11"}'
time /opt/maven3/bin/mvn -Pbench -nsu gatling:test -Dgatling.simulationClass=org.nuxeo.cap.bench.Sim50Bench2  -DredisHost=gatling1 -DredisDb=0 -Dduration=600 -Dpause_ms=4000 -Dramp=60 -Durl=http://nuxeo1/nuxeo
curl -XPOST http://monitor1:8080/events/  -d '{"what": "TC_11 Day in life End", "tags":"phases TC_11"}'
date

