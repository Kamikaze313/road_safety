const MongoClient = require('mongodb').MongoClient;

// Connection URL
const url = 'mongodb+srv://jaanprjt:V4zh4th0pp3@cluster0.hpnvxpe.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';

// Database Name
const dbName = 'road_data';

// Collection Name
const collectionName = 'pothump';

// Create a new MongoClient
const client = new MongoClient(url);

// Connect to the MongoDB server
console.log('Attempting to connect to MongoDB');
client.connect(function(err) {
    if (err) {
        console.error('Failed to connect to MongoDB:', err);
        return;
    }

    console.log('Connected successfully to MongoDB');

    // Get the database
    const db = client.db(dbName);
    console.log('Connected to database:', dbName);

    // Get the collection
    const collection = db.collection(collectionName);
    console.log('Connected to collection:', collectionName);

    // Query for documents with type "speed_breaker"
    collection.find({"properties.type": "speed_breaker"}).toArray(function(err, docs) {
        if (err) {
            console.error('Failed to query documents:', err);
            return;
        }

        console.log('Documents with type "speed_breaker":', docs);
    });

    // Close the connection
    client.close();
});