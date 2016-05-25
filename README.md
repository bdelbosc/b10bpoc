# About Nuxeo Big Benchmarks

Helper scripts to run Big Benchmark on MongoDB/AWS

## Servers

- MongoDB: the MongoDB database and Redis, using SSD
- Nuxeo: One or more Nuxeo node
- Elasticsearch: one or more Elasticsearch node, using SSD
- Monitor: A graphite server on EBS ?
- Gatling: Run Gatling test on EBS ?

## Benchmark phases

Phases are:

1. Mass import of document (only Nuxeo and MongoDB)
  servers: MongoDB, Nuxeo, Monitor
1. MongoDB indexing
  servers: MongoDB, Monitor
1. Elasticsearch indexing, Monitor
  Servers: MongoDB, Nuxeo, Elasticsearch, Monitor
1. Run Gatling benchmarks
  Servers: MongoDB, Nuxeo x n, Elasticsearch, Gatling, Monitor

## Goal

- Launch only necessary ec2 for each phase
- Support multiple configuration (type of ec2, number of Nuxeo Node)



# About Nuxeo

Nuxeo provides a modular, extensible, open source
[platform for enterprise content management](http://www.nuxeo.com/products/content-management-platform) used by organizations worldwide to power business processes and content repositories in the area of
[document management](http://www.nuxeo.com/solutions/document-management),
[digital asset management](http://www.nuxeo.com/solutions/digital-asset-management),
[case management](http://www.nuxeo.com/case-management) and [knowledge management](http://www.nuxeo.com/solutions/advanced-knowledge-base/). Designed
by developers for developers, the Nuxeo platform offers a modern
architecture, a powerful plug-in model and top notch performance.

More information on: <http://www.nuxeo.com/>
