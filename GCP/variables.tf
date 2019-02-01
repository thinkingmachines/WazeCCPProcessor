variable "bucket_location" {
  default = "us-central1"
}

variable "waze_data_url" {
  default = ""
}

variable "waze_raw_bucket_name" {
  default = "YOUR BUCKET NAME FOR RAW FILES" #suggestion: <YOUR ORG NAME>-gcp-wazeccpprocessor-raw
}

variable "waze_processed_bucket_name" {
  default = "YOUR BUCKET NAME FOR PROCESSED FILES" #suggestion: <YOUR ORG NAME>-gcp-wazeccpprocessor-processed
}

variable "service_account_email" {
  default = "THE EMAIL OF THE SERVICE ACCOUNT YOU CREATED"
}

variable "user_email" {
  default = "YOUR BQ OWNER'S EMAIL"
}

variable "dataset_name" {
  default = "waze_feed_dataset"
}

variable "topic_name" {
  default = "waze_ccp_processor"
}
