# Copyright (c) 2020, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

import mmAuthorization
import requests
import json

viya_host = "localhost"
port = ":8080"
host_url="http://" + viya_host + port
destination_url = host_url + "/modelPublish/destinations/"

mm_auth = mmAuthorization.mmAuthorization("myAuth")

# admin user id and password
admin_userId = "<SAS_user_admin_ID>"
user_passwd = "<SAS_user_password>"

# destination name
dest_name = "<my_CAS_destination_name>"

if admin_userId == "<SAS_user_admin_ID>":
    print("You must replace the example values in this script with valid values before executing the script.")
    exit(1)

admin_auth_token = mm_auth.get_auth_token(host_url, admin_userId, user_passwd)

destination_cas_headers = {
    "If-Match":"false",
    "Content-Type":"application/vnd.sas.models.publishing.destination.cas+json",
    mmAuthorization.AUTHORIZATION_HEADER: mmAuthorization.AUTHORIZATION_TOKEN + admin_auth_token
}

# create new destination, expecting 201
print("Creating the " + dest_name + " destination...")

destination_attrs = {
    "name":dest_name,
    "destinationType":"cas",
    "casServerName":"cas-shared-default",
    "casLibrary" : "public",
    "destinationTable" : "SAS_MODEL_TABLE"
}

destination = requests.post(destination_url, 
                       data=json.dumps(destination_attrs), headers=destination_cas_headers)

print(destination)


