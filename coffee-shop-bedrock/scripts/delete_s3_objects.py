#!/usr/bin/env python3
"""Delete all objects from S3 bucket before destruction."""
import sys
import boto3

region = sys.argv[1]
bucket_name = sys.argv[2]
profile = sys.argv[3] if len(sys.argv) > 3 else None

session = boto3.Session(profile_name=profile, region_name=region)
s3 = session.resource("s3")
bucket = s3.Bucket(bucket_name)
bucket.object_versions.all().delete()
bucket.objects.all().delete()
print("Deleted all objects from bucket")
