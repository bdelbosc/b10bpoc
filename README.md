# About Nuxeo Benchmark 10b

Helper script to deploy tuned Nuxeo/MongoDB on AWS.

# Goal

  Deploy minimum and tuned nodes for each benchmark step.
  
  The steps are:
  - mass import
  - elasticsearch indexing
  - gatling simulation

# Choices

## AWS instance

  Use AWS ec2 instance with ephemeral storage instance, because SSD is faster than EBS

  The instance type must be choose in :

  - c3.*
  - m3.*
  
## Binaries

  The attached file per document is a null file so we don't need binary storage.

# Steps

## Import

  ES Indexing and audit is disabled. Only Nuxeo and Mongo nodes are running.

## ES Indexation

  Add an ES cluster, add a Redis server for the workmanager, reconfigure Nuxeo to use it

## Gatling simulations

  Add a Gatling node to deploy and run Gatling simulation over the imported content.

# Tuning

## MongoDB

  We follow the "Performance Best Practices forMongoDB" "MongoDB 3.2/ March 2016" PDF:

  - Use XFS filesystem, atime and diratime disabled
  - Use different disk for data and index
  - Readahead block size to 32 (16kb)
  - Use a NOOP scheduler
  - Huge pages disabled
  - Open file limits increased

## Elasticsearch

  We follow the Elasticsearch best practices:
   
  - Use ext4 filestystem, atime and diratime disabled
  - use multiple drives to stripe data across them via multiple path.data directories
  - Disable merge throttling entirely
  - Set index.refresh_interval to 10s
  - Disable replicas
  
  - Set bulk size of 500 documents, may be too small (500KB instead of 5-15MB) but gives better results
    with 24 threads concurrency
  ...
  
## Nuxeo

  Import:

  - No fulltext extraction
  - No audit
  - Elasticsearch disabled
  - Use jar from branch: test-NXBT-1103-import-tuning-1b, they must be present on ./custom/bundles
   
    - nuxeo-core-8.4-SNAPSHOT.jar
    - nuxeo-core-storage-dbs-8.4-SNAPSHOT.jar
    - nuxeo-core-storage-mongodb-8.4-SNAPSHOT.jar
    - nuxeo-importer-core-8.4-SNAPSHOT.jar
    
    
  Elasticsearch indexing:
  
  - restore pristine jars  
  

# Run

## Configure access and nodes

1. Edit your `~/.ssh/config` to use your keypair when accessing AWS, for `eu-west-1` 

        Host 52.*
            User ubuntu
            IdentityFile "/home/XXX/.ssh/your-key-pair.pem"


2. Edit `ansible/group_vars/all.yml` to set your keypair and the ec2 type target for 1b can be:
   
        types:
            mongodb: m3.2xlarge
            nuxeo: c3.4xlarge
            elastic: m3.2xlarge
        counts:
            mongodb: 4
            nuxeo: 2
            elastic: 8

## Step 1 - Import

1. Create Mongo cluster and setup Nuxeo using latest 8.4 snapshot

        ./start_infra.sh -c /opt/build/hudson/instance.clid
      
      
2. Start Nuxeo and run the importer on each Nuxeo nodes:

        ./run_import.sh
       
       
## Step 2 - Indexing

1. Create an Elasticsearch cluster and reconfigure Nuxeo to use it

        ./start_elastic.sh


2. Run a reindexing process from a Nuxeo instance

        ./run_indexing.sh


## Step 3 - Gatling benchmark

1. Create a Gatling server with a pound load balancer

         ./start_gatling.sh
         
2. Log into the gatling host and run the bench, note that Nuxeo is expected to be up and running

         ./run_bench.sh
         

## Capture monitoring and restuls


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
