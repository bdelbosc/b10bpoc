#!/bin/bash -x
cd ~/bench-scripts/nuxeo-distribution/nuxeo-jsf-ui-gatling-tests
date
curl -XPOST http://monitor1:8080/events/  -d '{"what": "TC_04 Concurrent Upload 600 users Start", "tags":"phases TC_04"}'
time /opt/maven3/bin/mvn -nsu test gatling:execute -Dgatling.simulationClass=org.nuxeo.cap.bench.Sim20CreateDocuments  -DredisDb=0 -Dusers=600 -Dpause_ms=4000 -Dramp=120 -Durl=http://nuxeo1/nuxeo
curl -XPOST http://monitor1:8080/events/  -d '{"what": "TC_04 Concurrent Upload 600 users End", "tags":"phases TC_04"}'
date

