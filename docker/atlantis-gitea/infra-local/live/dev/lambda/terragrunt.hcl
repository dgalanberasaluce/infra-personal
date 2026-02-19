include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/lambda-dummy//"
}

dependency "app" {
  config_path = "../app"

  # Mock outputs: If the bucket does not exist, plan would fail
  mock_outputs = {
    s3_bucket_name = "bucket-temporal-para-plan"
  }
}

inputs = {
  target_bucket_name = dependency.app.outputs.s3_bucket_name
}