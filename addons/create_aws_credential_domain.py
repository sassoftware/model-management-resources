# Copyright (c) 2020, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

import mmAuthorization
import requests
import json, os, pprint
import base64

viya_host = "localhost"
port = ":8080"
host_url="http://" + viya_host + port
credentials_url = host_url + "/credentials"
domains_url = credentials_url + "/domains"

mm_auth = mmAuthorization.mmAuthorization("myAuth")

# admin user id and password
admin_userId = "SAS_USER_ADMIN_ID"
user_passwd = "SAS_USER_PASSWD"

# the user who could use the credential
USER_ID = "SAS_USER_ID"

# AWS secret keys
AWS_KEY_ID = "AWS Key Id"
AWS_SECRET_KEY = "AWS Secret Key"

# the domain which the SAS Credential Service uses
DOMAIN_NAME = "Domain Name"

if AWS_KEY_ID == "AWS Key Id":
    print("Please replace the values in the script with real ones before executing the script!")
    exit(1)

admin_auth_token = mm_auth.get_auth_token(host_url, admin_userId, user_passwd)

domain_put_header = {
    "Content-Type":"application/vnd.sas.credential.domain+json",
    "Accept":"application/vnd.sas.credential.domain+json",
    mmAuthorization.AUTHORIZATION_HEADER: mmAuthorization.AUTHORIZATION_TOKEN + admin_auth_token
}

credential_put_header = {
    "Content-Type":"application/vnd.sas.credential+json",
    "Accept":"application/vnd.sas.credential+json",
    mmAuthorization.AUTHORIZATION_HEADER: mmAuthorization.AUTHORIZATION_TOKEN + admin_auth_token
}


# create a domain with type 'password' 
my_domain_url = domains_url + "/" + DOMAIN_NAME

domain_attrs = {
    "id":DOMAIN_NAME,
    "type":"password",
    "description":"AWS credentials"
}

domain = requests.put(my_domain_url, 
                       data=json.dumps(domain_attrs), headers=domain_put_header)

print(domain)
print("created domain", DOMAIN_NAME)

# create a credential for the specified user
my_credential_url = my_domain_url + "/users/" + USER_ID

key_id = AWS_KEY_ID
secret_access_Key = AWS_SECRET_KEY

encoded_access_key = str(base64.b64encode(secret_access_Key.encode("utf-8")), "utf-8")
#print(encoded_access_key)

credential_attrs = {
    "domainId":DOMAIN_NAME,
    "identityType":"user",
    "identityId":USER_ID,
    "domainType":"password",
    "properties":{"userId":key_id},
    "secrets":{"password":encoded_access_key}
}

domain = requests.put(my_credential_url, 
                       data=json.dumps(credential_attrs), headers=credential_put_header)

print(domain)
#pprint.pprint(domain.json())
print("created credential under domain ", DOMAIN_NAME)



