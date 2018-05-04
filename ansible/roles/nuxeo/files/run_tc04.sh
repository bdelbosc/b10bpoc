#!/bin/bash -x
cd ~/bench-scripts/nuxeo-distribution/nuxeo-jsf-ui-gatling-tests
date
curl -XPOST http://monitor1:8080/events/  -d '{"what": "TC_04 Concurrent Upload 100 users Start", "tags":"phases TC_04"}'
time /opt/maven3/bin/mvn -nsu test gatling:execute -Dgatling.simulationClass=org.nuxeo.cap.bench.Sim20CreateDocuments  -DredisHost=gatling1 -DredisDb=0 -Dusers=100 -Dpause_ms=4000 -Dramp=60 -Durl=http://nuxeo1/nuxeo
curl -XPOST http://monitor1:8080/events/  -d '{"what": "TC_04 Concurrent Upload 100 users End", "tags":"phases TC_04"}'
date

