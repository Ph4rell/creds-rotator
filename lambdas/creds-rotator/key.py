#Gestion des accesskeys
import boto3

# Create IAM client
client = boto3.client('iam')

def list_access_keys(user):
    """
    List access keys
    """
    keys = client.list_access_keys(
        UserName=user
    )
    list_keys = list()
    
    for key in keys['AccessKeyMetadata']:
        d = {
            "Username": key['UserName'],
            "AccessKey": key['AccessKeyId'],
            "Status": key['Status'],
            "DateCreation": key['CreateDate']
        }
        list_keys.append(d)
    return list_keys