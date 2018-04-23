#!/bin/bash
BASE_FILE=/efs/files
FILE_LIST=$BASE_FILE/list-tc09.txt
PREFIX=nx-

set -e
set -x

function getBlobList() {
  curl -XPOST http://monitor1:8080/events/  -d '{"what": "Step 1 - Ingestion Creating list of files", "tags":"phases import"}'
  time curl -X POST 'http://localhost:8080/nuxeo/site/automation/StreamImporter.runFileBlobProducers' -u Administrator:Administrator -H 'content-type: application/json+nxrequest'  \
    -d '{"params":{"nbBlobs": 0, "nbThreads": 1, "logSize": 8, "listFile": "'"$FILE_LIST"'", "basePath": "'"$BASE_FILE"'", "logName": "'"$PREFIX"'blobs"}}'
}

function importBlobs() {
  curl -XPOST http://monitor1:8080/events/  -d '{"what": "Step 2 - Ingestion Importing files", "tags":"phases import"}'
  time curl -X POST 'http://localhost:8080/nuxeo/site/automation/StreamImporter.runBlobConsumers' -u Administrator:Administrator -H 'content-type: application/json+nxrequest' \
    -d '{"params":{"blobProviderName": "default", "nbThreads": 4, "logBlobInfo": "'"$PREFIX"'blobs-info", "logName": "'"$PREFIX"'blobs"}}'

}

function genDocuments() {
  curl -XPOST http://monitor1:8080/events/  -d '{"what": "Step 3 - Ingestion Generating documents", "tags":"phases import"}'
  time curl -X POST 'http://localhost:8080/nuxeo/site/automation/StreamImporter.runRandomDocumentProducers' -u Administrator:Administrator -H 'content-type: application/json+nxrequest' \
   -d '{"params":{"nbDocuments": 7656250, "nbThreads": 32, "logSize": "32", "logBlobInfo": "'"$PREFIX"'blobs-info", "logName": "'"$PREFIX"'docs", "countFolderAsDocument": false}}'
}

function importDocuments() {
  date=$(date +'%Y-%m-%d %H:%M:%S')
  name="tc10"
#  curl -X POST -H "Content-Type: application/json" -u Administrator:Administrator -d '{ "entity-type": "document", "name":"'"$name"'", "type": "Workspace","properties": { "dc:title": "DAM TC_09 - Search Assets - '"$date"'", "dc:description": "Querying assets when DB volume is 500 million"}}' http://localhost:8080/nuxeo/api/v1/path/default-domain/workspaces/
  set +e
  curl -XPOST http://monitor1:8080/events/  -d '{"what": "Step 4 - Ingestion Creating Nuxeo documents", "tags":"phases import", "data": "Into '"$name"' workspace"}'
  time curl -X POST 'http://localhost:8080/nuxeo/site/automation/StreamImporter.runDocumentConsumers' -u Administrator:Administrator -H 'content-type: application/json+nxrequest' \
   -d '{"params":{"rootFolder": "/default-domain/workspaces/'"$name"'", "logName": "nx-docs", "nbThreads": 16, "batchSize": 20, "useBulkMode": true, "blockIndexing": true, "blockAsyncListeners": true, "blockPostCommitListeners": true, "blockDefaultSyncListeners": true }}'
  curl -XPOST http://monitor1:8080/events/  -d '{"what": "Step 5 - Ingestion Completed", "tags":"phases import"}'
}

function waitForAsync() {
  time curl -X POST 'http://localhost:8080/nuxeo/site/automation/Elasticsearch.WaitForIndexing' -u Administrator:Administrator -H 'content-type: application/json+nxrequest' \
   -d '{"params":{"timeoutSecond": "10800"}, "context":{}}'
  curl -XPOST http://monitor1:8080/events/  -d '{"what": "Step 6 - Rendition Completed", "tags":"phases import"}'
}

# ---------------------
# main
#getBlobList
#importBlobs
#genDocuments
importDocuments

