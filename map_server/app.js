const express = require('express');
const mongoose = require('mongoose');
const app = express();
const port = 3000;

// MongoDB connection URI for MongoDB Atlas
const uri = "mongodb+srv://jaanprjt:pj4fmDhFSp8LunVX@cluster0.hpnvxpe.mongodb.net/road_data?retryWrites=true&w=majority";

// Connect to MongoDB using Mongoose
mongoose.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true });
const db = mongoose.connection;

// Define a schema for the road conditions data
    const roadConditionSchema = new mongoose.Schema({
        coordinates: {
          type: [Number], // Assuming coordinates are stored as [longitude, latitude]
          required: true
        },
        properties: {
          id: {
            type: String,
            required: true
          },
          type: {
            type: String,
            required: true
          },
          reporter: {
            type: String
          }
        }
      }, { collection: 'pothump' });
       // Specify the collection name here

// Create a geospatial index on the "geometry.coordinates" field
roadConditionSchema.index({ "geometry.coordinates": "2dsphere" });

// Create a Mongoose model based on the schema
const RoadCondition = mongoose.model('RoadCondition', roadConditionSchema);

// Connect to MongoDB
db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', function () {
  console.log('Connected to MongoDB Atlas');
});

// Endpoint to get road conditions near a given coordinate
app.get('/roadConditions', async (req, res) => {
  const { latitude, longitude } = req.query;
  const coordinates = [parseFloat(longitude), parseFloat(latitude)];

  try {
    // Perform MongoDB query to get road conditions near the given coordinates using Mongoose
    const docs = await RoadCondition.find({
      "geometry.coordinates": {
        $near: {
          $geometry: {
            type: "Point",
            coordinates: coordinates
          },
          $maxDistance: 10000 // Adjust the maximum distance as needed
        }
      }
    }).exec();

    res.json(docs);
  } catch (error) {
    console.error('Failed to query MongoDB:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.listen(port, () => console.log(`Server listening on port ${port}`));
