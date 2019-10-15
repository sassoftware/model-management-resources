# Copyright (c) 2020, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

import mmAuthorization
import requests
import json, os, pprint

viya_host = "localhost"
port = ":8080"
host_url="http://" + viya_host + port
publishmodel_url = host_url + "/modelPublish/models"

mm_auth = mmAuthorization.mmAuthorization("myAuth")

user_id = "SAS_USER_ID"
user_passwd = "SAS_USER_PASSWD"

dest_name = "MY_DEST_NAME"

if user_id == "SAS_USER_ID":
    print("Please replace the values in the script with real ones before executing the script!")
    exit(1)

auth_token = mm_auth.get_auth_token(host_url, user_id, user_passwd)

model_get_headers = {
    mmAuthorization.AUTHORIZATION_HEADER: mmAuthorization.AUTHORIZATION_TOKEN + auth_token
}

# synchronous
model_publishing_headers = {
    'Content-Type': 'application/vnd.sas.models.publishing.request+json',
    mmAuthorization.AUTHORIZATION_HEADER: mmAuthorization.AUTHORIZATION_TOKEN + auth_token
}
# asynchronous
model_publishing_async_headers = {
    'Content-Type': 'application/vnd.sas.models.publishing.request.asynchronous+json',
    mmAuthorization.AUTHORIZATION_HEADER: mmAuthorization.AUTHORIZATION_TOKEN + auth_token
}

# # Create and publish the BaseImages to specified destination
# #
# # Synchronous create python3 base-image
# # The API call will wait until baseImage is fully created and pushed
# # The 'imageUrl' property will be showed in the returned body
# #

# create python3 base-image (with synchronous request)
# three required fields: 
# - modelName: 'python'
# - modelId: must be 'base'
# - modelVersionid: '3'

python_model = {
    "name":"publish python3 baseimage",
    "modelContents":[
        {
            "modelName": "python",
            "modelId": "base",
            "modelVersionId": "3"
        }
    ],
    "destinationName": dest_name
}

published_model = requests.post(publishmodel_url, 
                             data=json.dumps(python_model), headers=model_publishing_headers)

print(published_model)
json_obj = published_model.json()

pprint.pprint(json_obj)

# inspect property value of 'imageUrl'
if "properties" in json_obj:
    props = json_obj["properties"]
    if "imageUrl" in props:
        print("imageUrl:", props["imageUrl"])

