include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/app-base//"
}

inputs = {
  bucket_name = "my-app-dev-bucket-local"
  table_name  = "MyApp-DEV"
}