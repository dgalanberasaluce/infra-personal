# Find orphaned resources (EBS volumes, snapshots, AMIs)
# https://awstip.com/reducing-costs-in-aws-iii-886da4d25b54
import boto3
import pandas as pd

# Set up Boto3 clients for EC2 and CloudWatch
ec2 = boto3.client('ec2',region_name="us-east-1")
cloudwatch = boto3.client('cloudwatch',region_name="us-east-1")

# Retrieve list of AWS regions
regions = [region['RegionName'] for region in ec2.describe_regions()['Regions']]

# Create empty lists to store the orphaned EBS snapshots, volumes, and unused AMIs
orphaned_snapshots = []
orphaned_volumes = []
unused_amis = []

# Iterate over regions and find orphaned EBS snapshots, volumes, and unused AMIs
for region in regions:
    # Set up Boto3 client for the region
    ec2_region = boto3.client('ec2', region_name=region)
    
    # Find all snapshots that are not associated with a running instance
    snapshots = ec2_region.describe_snapshots(OwnerIds=['self'])['Snapshots']
    for snapshot in snapshots:
        if 'in-use' not in snapshot['State']:
            orphaned_snapshots.append([region, snapshot['SnapshotId'], snapshot['StartTime']])
    
    # Find all volumes that are not attached to a running instance
    volumes = ec2_region.describe_volumes()['Volumes']
    for volume in volumes:
        if volume['State'] == 'available':
            orphaned_volumes.append([region, volume['VolumeId'], volume['CreateTime']])
    
    # Find all AMIs that have not been launched in the last 90 days
    amis = ec2_region.describe_images(Owners=['self'])['Images']
    for ami in amis:
        metrics = cloudwatch.get_metric_statistics(
            Namespace='AWS/EC2',
            MetricName='StatusCheckFailed_Instance',
            Dimensions=[{'Name': 'ImageId', 'Value': ami['ImageId']}],
            StartTime=pd.Timestamp.utcnow() - pd.Timedelta(days=90),
            EndTime=pd.Timestamp.utcnow(),
            Period=86400,
            Statistics=['Sum']
        )['Datapoints']
        if len(metrics) == 0 or metrics[0]['Sum'] == 0:
            unused_amis.append([region, ami['ImageId'], ami['CreationDate']])

# Convert the lists into Pandas DataFrames
orphaned_snapshots_df = pd.DataFrame(orphaned_snapshots, columns=['Region', 'SnapshotId', 'StartTime'])
orphaned_volumes_df = pd.DataFrame(orphaned_volumes, columns=['Region', 'VolumeId', 'CreateTime'])
unused_amis_df = pd.DataFrame(unused_amis, columns=['Region', 'ImageId', 'CreationDate'])

# Remove "Excel does not support datetimes with timezones"
orphaned_snapshots_df['StartTime'] = orphaned_snapshots_df['StartTime'].dt.tz_localize(None)
orphaned_volumes_df['CreateTime'] = orphaned_volumes_df['CreateTime'].dt.tz_localize(None)

# Write the DataFrames to an Excel file
writer = pd.ExcelWriter('aws_orphans.xlsx', engine='xlsxwriter')
orphaned_snapshots_df.to_excel(writer, sheet_name='Orphaned Snapshots', index=False)
orphaned_volumes_df.to_excel(writer, sheet_name='Orphaned Volumes', index=False)
unused_amis_df.to_excel(writer, sheet_name='Unused AMIs', index=False)
writer.close()

# Print a message to indicate that the Excel file has been written
print("Orphaned EBS snapshots, volumes, and unused AMIs written to aws_orphans.xlsx")
