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
admin_userId = "SAS_USER_ADMIN_ID"
user_passwd = "SAS_USER_PASSWD"

# the domain which the SAS Credential Service stores AWS credentials
DOMAIN_NAME = "Domain Name"

# the kubernetes cluster name
K8S_NAME = "K8s Name"

# destination name
dest_name = "MY_AWS_DEST_NAME"

# AWS region
AWS_REGION = "us-east-1"

# the docker daemon is running on tcp socket
DOCKER_HOST_URL = "tcp://yy.yy.yy.yy:2375"

if K8S_NAME == "K8s Name":
    print("Please replace the values in the script with real ones before executing the script!")
    exit(1)

admin_auth_token = mm_auth.get_auth_token(host_url, admin_userId, user_passwd)

destination_admin_headers = {
    mmAuthorization.AUTHORIZATION_HEADER: mmAuthorization.AUTHORIZATION_TOKEN + admin_auth_token
}

destination_aws_headers = {
    "If-Match":"false",
    "Content-Type":"application/vnd.sas.models.publishing.destination.aws+json",
    mmAuthorization.AUTHORIZATION_HEADER: mmAuthorization.AUTHORIZATION_TOKEN + admin_auth_token
}

# create new destination, expecting 201
print("Creating " + dest_name + " destination...")

props = [{"name": "domainId", "value": DOMAIN_NAME}]
props.append({"name": "region", "value": AWS_REGION})
props.append({"name": "kubernetesCluster", "value": K8S_NAME})

if DOCKER_HOST_URL != "":
    props.append({"name": "dockerHost", "value": DOCKER_HOST_URL})

destination_attrs = {
    "name":dest_name,
    "destinationType":"aws",
    "properties": props
}

#print(destination_attrs)

destination = requests.post(destination_url, 
                       data=json.dumps(destination_attrs), headers=destination_aws_headers)

print(destination)

