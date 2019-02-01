const waze_data_types = ['alerts', 'irregularities', 'jams']
const BQ_TIME_FORMAT = 'YYYY-MM-DD HH:mm:ss.SSS';
const WAZE_TIME_FORMAT = 'YYYY-MM-DD HH:mm:ss:SSS';
const moment = require('moment');
const { Storage } = require('@google-cloud/storage');
const storage = new Storage();

function convert_time_format(datestring, format) {
  const output_format = format || BQ_TIME_FORMAT;
  const dt = moment(datestring, WAZE_TIME_FORMAT);
  return dt.format(output_format);
}


function write_buffer_to_gcs(filename, bucket_name, buffer) {
  console.log(`writing ${filename} to ${bucket_name}`)
  const bucket = storage.bucket(bucket_name);
  let file = bucket.file(filename);
  const stream = file.createWriteStream({
    resumable: false
  });

  stream.on('error', (err) => {
    next(err);
    console.log(err);
  });

  stream.end(buffer);
}


exports.processData = function (event, callback) {
  const bucket_name = process.env.DATA_BUCKET;
  const file = event.data;

  const bucket = storage.bucket(bucket_name);
  bucket.file(file.name).download().then((data) => {
    let contents = data[0];
    let raw_data = JSON.parse(contents.toString('utf8'));
    let startTimeMillis = raw_data['startTimeMillis'];
    let endTimeMillis = raw_data['endTimeMillis'];
    let startTime = convert_time_format(raw_data['startTime']);
    let endTime = convert_time_format(raw_data['endTime']);
    waze_data_types.forEach(data_type => {
      console.log(`trying data_type:${data_type}`);
      if (!(data_type in raw_data)) {
        return;
      }
      let arr = [];
      let data = raw_data[data_type];
      data.forEach(obj => { //"push in" start and end time to each record
        let newObj = JSON.parse(JSON.stringify(obj)); //copy data to be safe
        newObj['startTimeMillis'] = startTimeMillis;
        newObj['endTimeMillis'] = endTimeMillis;
        newObj['startTime'] = startTime;
        newObj['endTime'] = endTime;
        arr.push(newObj);
      });
      console.log('attempting to write to GCS');
      write_buffer_to_gcs(`${data_type}_${convert_time_format(startTime, 'YYYY_MM_DD_HH_mm_ss_SSS')}.json`,
        process.env.PROCESSED_DATA_BUCKET, Buffer.from(arr.map((x) => JSON.stringify(x)).join('\n')));
    });
    callback();
  }).catch(err => {
    console.log('An error occurred while processing the feed data.')
    throw err;
  });
}
