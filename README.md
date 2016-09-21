# About Nuxeo Benchmark 10b

Helper script to deploy tuned Nuxeo/MongoDB on AWS.

# Goal

  Deploy minimum and tuned nodes for each benchmark step.

  The steps are:
  1. Mass import: ES Indexing and audit is disabled. Only Nuxeo and Mongo nodes are running.
  2. Elasticsearch indexing: Add an ES cluster, add a Redis server for the workmanager, reconfigure Nuxeo to use it 
  3. Gatling simulation: Add a Gatling node to deploy and run Gatling simulation over the imported content.

# Choices

## AWS instance

  Use AWS ec2 instance with ephemeral storage instance because SSD is faster than EBS.

  We also expect to have 2 ssd disk so instances must be of type:

  - c3.*
  - m3.*
  - i2.*

## No attached file (binaries) for mass import

  Importing with attached file is a bottleneck per se. It requires lots of network and storage resources.

  In real life for large import this should be done separately as the Nuxeo document import,
  by using an existing S3 bucket and/or creating an ad hoc binarystore so data don't have to be moved.
  This way Nuxeo has just to import a reference to a binary.

  For this bench the attached file per document is a null file so we don't even need to define a binary storage.


## Document identifier is a big int sequence

   Why ?
   - 1b of UUID is 36g of data
   - Generating random uid is an expensive operation and a bottleneck when done concurrently
   - Index work much better on int than string


# Tuning

## MongoDB

  We follow the [Performance Best Practices forMongoDB - MongoDB 3.2 March 2016](https://www.mongodb.com/collateral/mongodb-performance-best-practices):

  - Use `XFS` filesystem, `atime` and `diratime` disabled
  - Use different disk for data and index
  - `readahead` block size to 32 (16kb)
  - Use a `NOOP` scheduler
  - Huge pages disabled
  - Open file limits increased


  Also because the shard key is an hash of the document id which is a sequence, we rely
  on the hash to distribute the data on the cluster and therefor we can **deactivate the
  chunk balancing**.

## Elasticsearch

  We follow the Elasticsearch best practices:

  - Use `ext4` filestystem, atime and diratime disabled
  - use multiple drives to stripe data across them via multiple path.data directories
  - Disable merge throttling entirely
  - Set `index.refresh_interval` to 10s
  - Disable replicas
  - Use 3 shards per nodes, and no replication
  - Use a static and optimized mapping (fulltext analyzer tuned)


## Nuxeo

  Import:

  - No fulltext extraction
  - No audit
  - Elasticsearch disabled
  - Use Nuxeo patches to make sure that Nuxeo limits the number of MongoDB `find` operations that
    requires lots of `mongos` resource and prevent write scaling. 
    
    The patch are part of the branch: [`test-NXBT-1103-import-tuning-1b`](https://github.com/nuxeo/nuxeo/compare/test-NXBT-1103-import-tuning-1b?expand=1), 
    the following jars must be present on `./custom/bundles`

    - nuxeo-core-8.4-SNAPSHOT.jar
    - nuxeo-core-storage-dbs-8.4-SNAPSHOT.jar
    - nuxeo-core-storage-mongodb-8.4-SNAPSHOT.jar
    - nuxeo-importer-core-8.4-SNAPSHOT.jar


Elasticsearch indexing:

  - Use pristine jars (no more patch)
  - The Elasticsearch mapping is static and fulltext does not escape html.
  - TODO: describe tuning of bulk mode


# Running

## Configure access and nodes

1. Edit your `~/.ssh/config` to use your keypair when accessing AWS, for `eu-west-1`

        Host 52.*
            User ubuntu
            IdentityFile "/home/XXX/.ssh/your-key-pair.pem"


2. Edit `ansible/group_vars/all.yml` to set your keypair and the ec2 type target for 1b can be:

        types:
          mongodb: m3.2xlarge
          nuxeo: c3.4xlarge
          elastic: i2.2xlarge
          gatling: c3.2xlarge
          monitor: c3.xlarge
        counts:
          mongodb: 4
          nuxeo: 2
          elastic: 3
          gatling: 1
          monitor: 1

## Step 1 - Import

1. Create MongoDB cluster and setup Nuxeo using latest 8.4 snapshot:

        ./start_infra.sh -c /opt/build/hudson/instance.clid


2. Start Nuxeo and run the importer on each Nuxeo nodes:

        ./run_import.sh


## Step 2 - Indexing

1. Create an Elasticsearch cluster and reconfigure Nuxeo to use it:

        ./start_elastic.sh


2. Run a reindexing process:

        ./run_indexing.sh


## Step 3 - Gatling benchmark

1. Create a Gatling server with a pound load balancer:

         ./start_gatling.sh

2. Log into the `gatling` host and run the bench

         ./run_bench.sh


## Capture monitoring and results

Save all metrics in an s3 bucket:

        ./save_results.sh

## Shutdown all resources

       ./terminate_infra.sh

# About Nuxeo

Nuxeo provides a modular, extensible, open source
[platform for enterprise content management](http://www.nuxeo.com/products/content-management-platform) used by organizations worldwide to power business processes and content repositories in the area of
[document management](http://www.nuxeo.com/solutions/document-management),
[digital asset management](http://www.nuxeo.com/solutions/digital-asset-management),
[case management](http://www.nuxeo.com/case-management) and [knowledge management](http://www.nuxeo.com/solutions/advanced-knowledge-base/). Designed
by developers for developers, the Nuxeo platform offers a modern
architecture, a powerful plug-in model and top notch performance.

More information on: <http://www.nuxeo.com/>
