import boto3
from pprint import pprint

client = boto3.client('iam')

def list_iam_users():
    """
    return list of IAM users
    """
    users = client.list_users()
    list_users = list()

    for user in users['Users']:
        list_users.append(user['UserName'])
    return list_users