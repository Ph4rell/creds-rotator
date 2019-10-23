1. Script Lambda qui permet de remonter tous les utilisateurs IAM avec des accesskeys de plus de x jours

    - Lambda qui tourne dans un seul compte et en option sur une organization
    - Suppression de ou des clés
    - Création des nouvelles
    - Envoi de mail avec les fichiers CSV

2. Mail à l'utilisateur x jours avant pour informé que ses creds vont être périmés ds x jours et qu'ils seront renouvellé
automatiquement ds x jours.

3. DOCS
boto3_iam_access_key_rotation.py
https://gist.github.com/andymotta/cb64ebd71c4703726501fe9a3776ce3d

https://github.com/jicowan/key_rotator/blob/master/key_rotator.py

https://docs.aws.amazon.com/fr_fr/general/latest/gr/aws-access-keys-best-practices.html
https://docs.aws.amazon.com/fr_fr/IAM/latest/UserGuide/id_credentials_access-keys.html
https://aws.amazon.com/fr/blogs/security/how-to-rotate-access-keys-for-iam-users/