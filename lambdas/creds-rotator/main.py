#main function
import boto3
from key import list_access_keys
from user import list_iam_users

def main():
    for user in list_iam_users():
        for key in list_access_keys(user):
            print(f"{key}")
            


if __name__ == "__main__":
    main()