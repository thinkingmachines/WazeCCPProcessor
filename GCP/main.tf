resource "google_storage_bucket" "bucket" {
  name          = "${var.waze_raw_bucket_name}"
  provider      = "google"
  location      = "${var.bucket_location}"
  storage_class = "REGIONAL"
}

resource "google_storage_bucket" "processed_bucket" {
  name          = "${var.waze_processed_bucket_name}"
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

data "archive_file" "process_data" {
  type        = "zip"
  output_path = "${path.module}/code/cloud-functions/waze-data-process.zip"

  source {
    content  = "${file("${path.module}/code/cloud-functions/waze-data-process.js")}"
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

resource "google_storage_bucket_object" "waze-data-process-function" {
  name       = "waze-data-process.zip"
  bucket     = "${google_storage_bucket.processed_bucket.name}"
  source     = "${data.archive_file.process_data.output_path}"
  depends_on = ["data.archive_file.process_data"]
}

resource "google_cloudfunctions_function" "download-function" {
  name                  = "download-function"
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
    PROCESSED_DATA_BUCKET = "${var.waze_processed_bucket_name}"
    WAZEDATAURL           = "${var.waze_data_url}"
  }
}

resource "google_cloudfunctions_function" "process-function" {
  name                  = "process-function"
  description           = "lightly process waze feed data"
  available_memory_mb   = 128
  source_archive_bucket = "${google_storage_bucket.processed_bucket.name}"
  source_archive_object = "${google_storage_bucket_object.waze-data-process-function.name}"
  timeout               = 60
  entry_point           = "processData"
  provider              = "google"

  # see https://github.com/terraform-providers/terraform-provider-google/issues/2409 for notes on the `event_trigger` block
  event_trigger {
    event_type = "providers/cloud.storage/eventTypes/object.change"
    resource   = "${google_storage_bucket.bucket.name}"
  }

  labels {
    my-label = "waze-processor"
  }

  environment_variables {
    DATA_BUCKET           = "${var.waze_raw_bucket_name}"
    PROCESSED_DATA_BUCKET = "${var.waze_processed_bucket_name}"
    WAZEDATAURL           = "${var.waze_data_url}"
  }
}
