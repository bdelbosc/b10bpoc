

for(var i=0; i<100000; i++) {
  doc = {"ecm:racl" : [ "Administrator", "members" ],
    "dc:creator" : "system",
    "ecm:parentId" : "7dad8d61-ad33-4327-96f3-1ed3956793d3",
    "ecm:ancestorIds" : [ "00000000-0000-0000-0000-000000000000", "ceb09464-b9eb-4d0a-b6e5-bb3afc754e6a", "94f540b6-8157-420b-a48f-15183e181471", "953964ce-8940-4f7b-843a-ef82e2fa8840", "7dad8d61-ad33-4327-96f3-1ed3956793d3" ],
    "dc:modified" : new Date(),
    "ecm:minorVersion" : NumberLong(0),
    "dc:lastContributor" : "system",
     "content" : { "name" : "file-1-9.txt",
                   "mime-type" : "text/partial",
                   "length" : NumberLong(4612) },
    "ecm:name" : "file-1-9",
    "ecm:majorVersion" : NumberLong(0),
    "filename" : "file-1-9",
    "ecm:lifeCyclePolicy" : "default",
    "dc:created" : ISODate("2016-05-31T21:14:38.654Z"),
    "dc:title" : "file-1-9",
    "ecm:primaryType" : "File",
    "ecm:id" : "17644fe8-1a99-4cf1-a7c3-4048a9e85698",
    "ecm:lifeCycleState" : "project",
    "dc:contributors" : [ "system" ]
  }
  db.test_collection.save(doc);
}

