# Copyright (c) 2020, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

import requests
import json

AUTHORIZATION_TOKEN = "Bearer "
AUTHORIZATION_HEADER = "Authorization"


class mmAuthorization(object):
    
    AUTHORIZATION_TOKEN = "Bearer "
    AUTHORIZATION_HEADER = "Authorization"
    
    uriAuth='/SASLogon/oauth/token'

    def __init__(self, params):
        """
        Constructor
        """

    def get_auth_token(self, url, user, password):
        headers = {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
            self.AUTHORIZATION_HEADER: 'Basic c2FzLmVjOg=='
            }
        payload = 'grant_type=password&username=' + user + '&password=' + password
        auth_return = requests.post(url+self.uriAuth, data=payload, headers=headers)

        my_auth_json = json.loads(auth_return.content.decode('utf-8'))
        my_token = my_auth_json['access_token']
        return my_token

    
