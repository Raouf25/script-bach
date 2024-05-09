// bulk_update.js
var bulk = db.mycollection.initializeOrderedBulkOp();
bulk.find({ "name": "John Doe" }).updateOne({ $set: { "age": 35 } });
bulk.find({ "name": "Jane Smith" }).updateOne({ $set: { "age": 30 } });
bulk.execute();
