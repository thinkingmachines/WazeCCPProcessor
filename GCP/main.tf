resource "google_storage_bucket" "bucket" {
  name          = "${var.waze_raw_bucket_name}"
  provider      = "google"
  location      = "${var.bucket_location}"
  storage_class = "REGIONAL"
}

data "archive_file" "http_trigger" {
  type        = "zip"
  output_path = "${path.module}/code/cloud-functions/waze-data-download.zip"

  source {
    content  = "${file("${path.module}/code/cloud-functions/waze-data-download.js")}"
    filename = "index.js"
  }

  source {
    content  = "${file("${path.module}/code/cloud-functions/package.json")}"
    filename = "package.json"
  }
}

resource "google_storage_bucket_object" "waze-data-download-function" {
  name       = "waze-data-download.zip"
  bucket     = "${google_storage_bucket.bucket.name}"
  source     = "${data.archive_file.http_trigger.output_path}"
  depends_on = ["data.archive_file.http_trigger"]
}

resource "google_cloudfunctions_function" "function" {
  name                  = "download-function"
  provider              = "google"
  description           = "waze download function"
  available_memory_mb   = 128
  source_archive_bucket = "${google_storage_bucket.bucket.name}"
  source_archive_object = "${google_storage_bucket_object.waze-data-download-function.name}"
  trigger_http          = true
  timeout               = 60
  entry_point           = "downloadData"
  provider              = "google"

  labels {
    my-label = "waze-processor"
  }

  environment_variables {
    DATA_BUCKET           = "${var.waze_raw_bucket_name}"
    PROCESSED_DATA_BUCKET = "${var.processed_bucket_name}"
    WAZEDATAURL           = "${var.waze_data_url}"
  }
}
