const express = require('express');
const {PubSub} = require('@google-cloud/pubsub');

const client = new PubSub({
  projectId: process.env.GOOGLE_CLOUD_PROJECT
});

const app = express();

//try to publish a message to :topic, use to trigger download function
app.get('/publish/:topic', async (req, res) => {
  const topic = req.params['topic'];

  try {
    await client.topic(topic)
        .publish(Buffer.from('trigger ccp-processor'));

    res.status(200).send('Published to ' + topic).end();
  } catch (e) {
    res.status(500).send('' + e).end();
  }
});

// Index, check if app is running
app.get('/', (req, res) => {
  res.status(200).send('App is up!').end();
});

// Start the server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`App listening on port ${PORT}`);
  console.log('Press Ctrl+C to quit.');
});
