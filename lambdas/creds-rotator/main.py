#main function
import boto3
import botocore
from datetime import datetime

#Connect to AWS API
client = boto3.client('iam')

def lambda_handler(event, context):

    data = client.list_users()
    list_users = list()

    try:

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

                # Format the age of the key
                age = key_age(key_created_date)

                print(
                    f'KeyID : {access_key_id} - '
                    f'Date de Création : {key_created_date} - '
                    f'AccessKey age : {age}'
                    )


                if age > 90:
                    # Deletion of old accesskey
                    delete_access_key = client.delete_access_key(
                        AccessKeyId=access_key_id,
                        UserName=users['username']
                    )

                    # Creation of the new accesskey
                    create_access_key = client.create_access_key(
                        UserName= users['username']
                    )

                    new_access_key = create_access_key['AccessKey'].get('AccessKeyId')
                    new_secret_key = create_access_key['AccessKey'].get('SecretAccessKey')
                    
                    print(
                        f'New KeyID : {new_access_key} - ' 
                        f'New Secret Key : {new_secret_key}'
                        )

                    # Send email to admin - need to find user email
                    send_desactivation_email('pierre.poree@d2si.io', users['username'], age,access_key_id)
                
                
    
    except botocore.exceptions.ClientError as error:
        print(error)
    except botocore.exceptions.ParamValidationError as error:
        print(error)
    
    finally:
        print('Fin de script')
        



def key_age(key_created_date):
    """
    Format the date and return age of the accesskey
    """
    tz_info = key_created_date.tzinfo

    age = datetime.now(tz_info) - key_created_date

    key_age_str = str(age)
    if 'days' not in key_age_str:
        return 0

    days = int(key_age_str.split(',')[0].split(' ')[0])

    return days


def send_desactivation_email(email_to, username, age, access_key_id):
    """
    Function to send email to admin/user
    """
    client = boto3.client('ses')

    data = f'The Access Key {access_key_id} belonging to User {username} ' \
           f'has been automatically deactivated due to it being {age} days old'

    response = client.send_email(
        Source='pierre.poree@d2si.io',
        Destination={
            'ToAddresses': [email_to]
        },
        Message={
            'Subject': {
                'Data': f'AWS IAM Access Key Rotation - Deactivation of Access Key: {access_key_id}'
            },
            'Body': {
                'Text': {
                    'Data': data
                }
            }
        }
    )


if __name__ == "__main__":
    event = 1
    context = 1
    lambda_handler(event, context)