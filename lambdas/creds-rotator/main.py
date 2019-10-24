#main function
import boto3
import botocore
from datetime import datetime

#Connect to AWS API
client = boto3.client('iam')

def lambda_handler(event, context):

    # data = client.list_users()
    # list_users = list()

    try:
        data = client.list_users()
        list_users = list()
        for user in data['Users']:
            users = {
                'username': user['UserName'],
                'userid' : user['UserId']
            }
            list_users.append(users)
            print(users['username'])

            access_keys = client.list_access_keys(UserName=users['username'])
            for access_key in access_keys['AccessKeyMetadata']:
                access_key_id = access_key['AccessKeyId']
                key_created_date = access_key['CreateDate']
                age = key_age(key_created_date)
                print(f'KeyID : {access_key_id} - Date de Création : {key_created_date} - AccessKey age : {age}')


                if age > 90:
                    client.delete_access_key(
                        AccessKeyId=access_key_id,
                        UserName=users['username']
                    )
                    # Code pour rendre inactif et supprimer la clé
                    # Code pour créer la nouvelle clé
    
    except botocore.exceptions.ClientError as error:
        print(error)
    except botocore.exceptions.ParamValidationError as error:
        print(error)
        



def key_age(key_created_date):
    tz_info = key_created_date.tzinfo

    age = datetime.now(tz_info) - key_created_date

    key_age_str = str(age)
    if 'days' not in key_age_str:
        return 0

    days = int(key_age_str.split(',')[0].split(' ')[0])

    return days

            


if __name__ == "__main__":
    event = 1
    context = 1
    lambda_handler(event, context)