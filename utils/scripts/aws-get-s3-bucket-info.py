import boto3
import pandas as pd

# Set up Boto3 clients
#s3_resource = boto3.resource('s3',region_name="us-east-1")

# Retrieve list of AWS regions
regions = [region['RegionName'] for region in ec2.describe_regions()['Regions']]
buckets = []

for region in regions:
  s3_client = boto3.client('s3',region_name=region)
  s3_resource = boto3.resource('s3',region_name=region)

  buckets_region = s3_client.list_buckets()['Buckets']

  for bucket in buckets_region:
    bucket_name = bucket["Name"]

    bucket_encryption = s3_client.get_bucket_encryption(Bucket=bucket_name)
    bucket_policy_status = s3_client.get_bucket_policy_status(Bucket=bucket_name)['PolicyStatus']

    buckets.append({
      "name": bucket_name,
      "region": region,
      "encryption": bucket_encryption['ServerSideEncryptionConfiguration'],
      "isPublic": bucket_policy_status['IsPublic']
    })


# Versioning active
# It is public/Private
# ACL
# Size




  bucket_resource = s3_resource.Bucket(bucket_name)
  for obj in bucket_resource.objects.all():
    key = s3_resource.Object(bucket_name, obj.key)
    if key.server_side_encryption != 'AES256':
      print(f"{bucket_name}/{obj.key}")
  #for obj in bucket.objects.all():
  #  key = s3.Object(bucket.name, obj.key)
  #  print(key.server_side_encryption)
