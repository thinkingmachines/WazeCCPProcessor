exports.downloadData = function(req, res){
    const fetch = require('node-fetch');
    const {Storage} = require('@google-cloud/storage');
    const storage = new Storage();
    const bucket_name = process.env.DATA_BUCKET;
    const bucket = storage.bucket(bucket_name);
    const moment = require('moment');
    const filename = `wazedata_${moment().format('YYYY_MM_DD_HH_mm_ss_SSS')}.json`
    fetch(process.env.WAZEDATAURL).then(
      fetchResponse => fetchResponse.buffer().then(
        buffer => {
          let file = bucket.file(filename);
          const stream = file.createWriteStream({
            resumable: false
          });

          stream.on('error', (err) => {
            next(err);
          });

          stream.on('finish', () => {
            res.send('OK');
          });

          stream.end(buffer);
        }).catch(err => {
          next(err);
        })
      ).catch(err => {
        next(err);
      });
  }