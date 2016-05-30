# About Nuxeo Benchmark 10b

Helper script to deploy tuned Nuxeo/MongoDB on AWS.

# Goal

  Deploy minimum and tuned Nuxeo/MongoDB archi to support best throughput per simulation.
  
  For instance injecting 

# Choices

## AWS instance
  Use AWS ec2 instance with ephemeral storage instance, because SSD is faster than EBS
  
  The instance type must be choose in :
  
  - c3.*
  - i2.*  
  - d2.*

# Simulations

## Import
  Here we use only 2 servers a Nuxeo and a MongoDB server.
  ES Indexing and audit is disabled, the repository use a /dev/null binary store 
  
## ES Indexation
  Add an ES cluster and index repository content.

## Gatling simulations
  Run default gatling simulation on top of the imported content.

# Tuning

## MongoDB 

  We follow the "Performance Best Practices forMongoDB" "MongoDB 3.2/ March 2016" PDF:
  
  - Use XFS filesystem, atime and diratime disabled
  - Use different disk for data and index
  - Readahead block size to 32 (16kb)
  - Use a NOOP scheduler
  - Huge pages disabled
  - Open file limits increased
  
   
## Nuxeo

  Import:
  
  - No fulltext extraction
  - No audit
  - Elasticsearch disabled
  - Fake binary storage, it does not write binary to disk.
 


# About Nuxeo

Nuxeo provides a modular, extensible, open source
[platform for enterprise content management](http://www.nuxeo.com/products/content-management-platform) used by organizations worldwide to power business processes and content repositories in the area of
[document management](http://www.nuxeo.com/solutions/document-management),
[digital asset management](http://www.nuxeo.com/solutions/digital-asset-management),
[case management](http://www.nuxeo.com/case-management) and [knowledge management](http://www.nuxeo.com/solutions/advanced-knowledge-base/). Designed
by developers for developers, the Nuxeo platform offers a modern
architecture, a powerful plug-in model and top notch performance.

More information on: <http://www.nuxeo.com/>
