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

  Use AWS ec2 instance with ssd ebs storage.

## Stream importer

  The mass import is done in 4 steps with the [`nuxeo-importer-stream`](https://github.com/nuxeo/nuxeo-platform-importer/tree/master/nuxeo-importer-stream).
  Using Nuxeo Stream with Kafka configuration. 

## Document identifier is a big int sequence

   Why ?
   - 1b of UUID is 36g of data
   - Generating random uid is an expensive operation and a bottleneck when done concurrently
   - Index on UUID are bloated and not as efficient as with bigint.


# Tuning

## MongoDB

  We follow the [Performance Best Practices forMongoDB - MongoDB 3.2 March 2016](https://www.mongodb.com/collateral/mongodb-performance-best-practices):

  - Use a RAID 0 of EBS io1 disk with provisioned IO
  - Use `XFS` filesystem, `atime` and `diratime` disabled
  - `readahead` block size to 32 (16kb)
  - Use a `NOOP` scheduler
  - Huge pages disabled
  - Open file limits increased


  Also because the shard key is an hash of the document id which is a sequence, we rely
  on the hash to distribute the data on the cluster and therefor we can **deactivate the
  chunk balancing**.

## Elasticsearch

  We follow the Elasticsearch best practices:

  - Use a RAID 0 of EBS io1 disk with provisioned IO
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

Elasticsearch indexing:

  - TODO: describe tuning of bulk mode


# Running

There is multiple profile: b10m for 10 millions, b100m for 100 million and b1b for 1 billion.
Use `i` option in shell script like: `-i b100m`.  

## Configure access and nodes

1. Edit your `~/.ssh/config` to use your keypair when accessing AWS, for `eu-west-1`

        Host 52.*
            User ubuntu
            IdentityFile "/home/XXX/.ssh/your-key-pair.pem"


2. Edit `ansible/group_vars/all.yml` to set your keypair and region

## Step 1 - Import

1. Create MongoDB cluster and setup Nuxeo using latest Nuxeo snapshot:

        ./start_infra.sh -i b10m -c /opt/build/hudson/instance.clid


2. Start Nuxeo and run the importer on each Nuxeo nodes:

        ./run_import.sh -i b10m


## Step 2 - Indexing

1. Create an Elasticsearch cluster and reconfigure Nuxeo to use it:

        ./start_elastic.sh -i b10m


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


## Pause and resume

Simple as:

        ./pause.sh
        ./resume.sh


## Shutdown all resources

       ./terminate_infra.sh


## Misc

      cd ansible
      ansible -i inventory.py mongodb -m ping
      

# About Nuxeo

Nuxeo provides a modular, extensible, open source
[platform for enterprise content management](http://www.nuxeo.com/products/content-management-platform) used by organizations worldwide to power business processes and content repositories in the area of
[document management](http://www.nuxeo.com/solutions/document-management),
[digital asset management](http://www.nuxeo.com/solutions/digital-asset-management),
[case management](http://www.nuxeo.com/case-management) and [knowledge management](http://www.nuxeo.com/solutions/advanced-knowledge-base/). Designed
by developers for developers, the Nuxeo platform offers a modern
architecture, a powerful plug-in model and top notch performance.

More information on: <http://www.nuxeo.com/>
