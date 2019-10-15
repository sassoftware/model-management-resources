#!/bin/bash -e
 
export CONSUL_HTTP_TOKEN=$(cat /opt/sas/viya/config/etc/SASSecurityCertificateFramework/tokens/consul/default/client.token)
/opt/sas/viya/home/bin/consul kv put config/microanalyticScore/sas.microanalyticservice.system/core/numthreads 1