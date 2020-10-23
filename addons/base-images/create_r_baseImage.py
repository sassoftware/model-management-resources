# Copyright (c) 2020, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

import sys
sys.path.append('..')
import mmAuthorization
import requests
import time
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

# # Asynchronous create r base-image
# # The API call will NOT wait for baseImage being fully created and pushed
# # Instead user has to pull the published model object to check the state every awhile
# # The 'imageUrl' property will be showed in the returned body of the published model object


# R base-image
# two required fields: 
# - name: 'r'
# - modelId: must be 'base'

# !!! using asynchronous header to prevent timeout !!!

r_model = {
    "name":"publish r baseimage",
    "modelContents":[
        {
            "modelName": "r",
            "modelId": "base"
        }
    ],
    "destinationName": dest_name  
}

published_model = requests.post(publishmodel_url, 
                             data=json.dumps(r_model), headers=model_publishing_async_headers)

print(published_model)
json_obj = published_model.json()
pprint.pprint(json_obj)
publish_uuid = json_obj["items"][0]['id']
print("Publishing ID", publish_uuid)

# examine the published model state
url = publishmodel_url + "/" + publish_uuid

done = False

while (not done):
    print("Checking publish status...")
    my_model = requests.get(url, headers=model_get_headers)
    print(my_model)
    json_obj = my_model.json()
    #pprint.pprint(json_obj)

    state = json_obj["state"]
    print("State:", state)
    
    # print("Publishing ID:", json_obj['id'])
    # print("URL:", "/modelPublish/models/"+json_obj['id'])
    
    if state != "running" and state != "pending":
        done = True
        print("Publish completed")
        if "properties" in json_obj:
            props = json_obj["properties"]
            if "imageUrl" in props:
                print("imageUrl:", props["imageUrl"])
    
    else:
        print("Sleep 60s...")
        time.sleep(60)
