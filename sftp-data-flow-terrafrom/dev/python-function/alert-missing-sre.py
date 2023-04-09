import os
import boto3
from datetime import datetime

# Create AWS clients
transfer = boto3.client('transfer')
s3 = boto3.resource('s3')
sns = boto3.client('sns')


def lambda_handler(event, context):
    topic_arn = os.environ['SNS_TOPIC_ARN']
    bucket_name = os.environ['Landing_Bucket_Name']
    aws_trasfer_server_id = os.environ['Server_Id']
    subfolder = []

    current_date = datetime.utcnow().strftime('%Y-%m-%d')
    response = transfer.list_users(
        ServerId=aws_trasfer_server_id
    )

    for user in response['Users']:
        home_directory = user['HomeDirectory']
        username = user['UserName']
        splitfolder = home_directory.split('/')[2]
        subfolder.append(splitfolder)

        bucket = s3.Bucket(bucket_name)
        if not bucket.objects.filter(Prefix=splitfolder).all():
            print(f"Subfolder '{splitfolder}' does not exist")
        else:
            objs = list(bucket.objects.filter(Prefix=splitfolder))
            if len(objs) == 0:
                print(f"No objects found in subfolder '{splitfolder}'")
                sns.publish(
                    TopicArn=topic_arn,
                    Subject='Not uploaded any files',
                    Message=f'Client not uploaded any files to {splitfolder}'
                )
            else:
                print(f"Objects found in subfolder '{splitfolder}':")
                objects_uploaded_today = False
                for obj in objs:
                    if obj.last_modified.date() == datetime.utcnow().date() and \
                       obj.key.split('.')[-1] in ['csv', 'json', 'xls', 'xlsx']:
                        objects_uploaded_today = True
                        print(f" - {obj.key} (uploaded today)")
                if not objects_uploaded_today:
                    print(f"No CSV, JSON, XLS, or XLSX files uploaded to subfolder '{splitfolder}' today by '{username}'")
                    sns.publish(
                        TopicArn=topic_arn,
                        Subject='No new files uploaded today',
                        Message=f'No new files were uploaded to {splitfolder} on {current_date} by {username}'
                    )
