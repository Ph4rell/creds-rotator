#main function
import boto3

#Connect to AWS API
client = boto3.client('iam')

def lambda_handler(event, context):

    data = client.list_users()
    list_users = list()
    
    for user in data['Users']:
        users = {
            'username': user['UserName'],
            'userid' : user['UserId']
        }
        list_users.append(users)

        access_keys = client.list_access_keys(UserName=users['username'])
        for access_key in access_keys['AccessKeyMetadata']:
            print(access_key)



# def key_age(key_created_date):
#     tz_info = key_created_date.tzinfo
#     age = datetime.now(tz_info) - key_created_date

#     print(f'key age : {age}')

#     key_age_str = str(age)
#     if 'days' not in key_age_str:
#         return 0

#     days = int(key_age_str.split(',')[0].split(' ')[0])

#     return days

            


if __name__ == "__main__":
    event = 1
    context = 1
    lambda_handler(event, context)