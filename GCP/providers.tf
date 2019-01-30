provider "google" {
  project     = "YOUR PROJECT NAME HERE"
  region      = "YOUR DEFAULT REGION HERE"
  credentials = "${file("account.json")}"
}
