#!/bin/bash
set -e
set -x

# 1 blob list
curl -XPOST http://monitor1:8080/events/  -d '{"what": "Step 1 - Ingestion Creating list of files", "tags":"phases import"}'
time curl -X POST 'http://localhost:8080/nuxeo/site/automation/StreamImporter.runFileBlobProducers' -u Administrator:Administrator -H 'content-type: application/json+nxrequest'  \
  -d '{"params":{"nbBlobs": 0, "nbThreads": 1, "logSize": 1, "listFile": "/efs/files/list-tc05.txt", "basePath": "/efs/files", "logName": "nxtc52-blobs"}}'

# 2 import blobs
curl -XPOST http://monitor1:8080/events/  -d '{"what": "Step 2 - Ingestion Importing files", "tags":"phases import"}'
time curl -X POST 'http://localhost:8080/nuxeo/site/automation/StreamImporter.runBlobConsumers' -u Administrator:Administrator -H 'content-type: application/json+nxrequest' \
  -d '{"params":{"blobProviderName": "default", "nbThreads": 1, "logBlobInfo": "nxtc52-blobs-info", "logName": "nxtc52-blobs"}}'

# 3 gen docs
curl -XPOST http://monitor1:8080/events/  -d '{"what": "Step 3 - Ingestion Generating documents", "tags":"phases import"}'
time curl -X POST 'http://localhost:8080/nuxeo/site/automation/StreamImporter.runRandomDocumentProducers' -u Administrator:Administrator -H 'content-type: application/json+nxrequest' \
 -d '{"params":{"nbDocuments": 100, "nbThreads": 1, "logBlobInfo": "nxtc52-blobs-info", "logName": "nxtc52-docs", "logSize": "1", "countFolderAsDocument": false}}'

# 4 import docs
date=$(date +'%Y-%m-%d %H:%M:%S')
name="tc_05-$(date +'%y-%m-%d_%H-%M-%S')"
curl -X POST -H "Content-Type: application/json" -u Administrator:Administrator -d '{ "entity-type": "document", "name":"'"$name"'", "type": "Workspace","properties": { "dc:title": "DAM TC_05 - Bulk Upload Tests to Detect Resource Leaks '"$date"'", "dc:description": "Bulk Upload Tests to Detect Resource Leaks"}}' http://localhost:8080/nuxeo/api/v1/path/default-domain/workspaces/
set +e
curl -XPOST http://monitor1:8080/events/  -d '{"what": "Step 4 - Ingestion Creating Nuxeo documents", "tags":"phases import", "data": "Into '"$name"' workspace"}'
time curl -X POST 'http://localhost:8080/nuxeo/site/automation/StreamImporter.runDocumentConsumers' -u Administrator:Administrator -H 'content-type: application/json+nxrequest' \
 -d '{"params":{"rootFolder": "/default-domain/workspaces/'"$name"'", "logName": "nxtc52-docs", "batchSize": 5 }}'
curl -XPOST http://monitor1:8080/events/  -d '{"what": "Step 5 - Ingestion Completed", "tags":"phases import"}'
#time curl -X POST 'http://localhost:8080/nuxeo/site/automation/Elasticsearch.WaitForIndexing' -u Administrator:Administrator -H 'content-type: application/json+nxrequest' \
# -d '{"params":{"timeoutSecond": "10800"}, "context":{}}'
#curl -XPOST http://monitor1:8080/events/  -d '{"what": "Step 6 - Rendition Completed", "tags":"phases import"}'


