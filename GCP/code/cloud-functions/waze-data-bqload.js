const { Storage } = require('@google-cloud/storage');
const { BigQuery } = require('@google-cloud/bigquery');
const waze_data_types = ['alerts', 'irregularities', 'jams']

function getTableName(filename) {
  let data_type = filename.split('_')[0];
  if (waze_data_types.indexOf(data_type) === -1) {
    throw new Error('invalid waze data type!');
  }
  return data_type;
}

exports.bqLoad = function (event, callback) {
  const bigquery = new BigQuery();
  const storage = new Storage();
  const bucket = storage.bucket(process.env.PROCESSED_DATA_BUCKET);
  const file = event.data;
  const filename = file.name;
  const dataset = bigquery.dataset(process.env.DATASET);
  const table = dataset.table(getTableName(filename));

  const metadata = {
    sourceFormat: 'NEWLINE_DELIMITED_JSON',
    ignoreUnknownValues: true
  };

  table.createLoadJob(
    bucket.file(filename),
    metadata,
    (err, job, apiResponse) => {
      if (err) {
        console.error(err);
        console.log('apiResponse');
        console.log(apiResponse);
      }
      console.log('job');
      console.log(job);
    });
}
