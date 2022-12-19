### Fedora Install

```shell
dnf install ncurses-compat-libs.x86_64

wget https://packages.couchbase.com/releases/7.1.3/couchbase-server-enterprise-7.1.3-rhel8.x86_64.rpm

```

https://devblog.songkick.com/parsing-ginormous-json-files-via-streaming-be6561ea8671
<!--  -->
sed 's/{"provider_references": \[//' | sed 's/},/}/' | sed ':begin;$!N;s/}\]\n}/}/;tbegin;P;D'

http://kmkeen.com/jshon/


$ time  jq -c --stream 'fromstream(2|truncate_stream(inputs|select(.[0][0]=="in_network")))'  2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO-00_P3_in-network-rates.json  | split -l 100000 --numeric-suffixes=1 - in_network_uh_tpa-ppo_part_ --additional-suffix=.json

real    455m51.026s
user    454m18.291s
sys     1m56.609s


$ wc -l in_network_uh_tpa-ppo_part_01.json
16080 in_network_uh_tpa-ppo_part_01.json



$ time  /opt/couchbase/bin/cbimport  json --username  Administrator  --password passwordString --bucket pt_bucket --dataset file://in_network_uh_tpa-ppo_part_01.json            -f lines -c localhost -g key::%billing_code%  --scope-collection-exp network.rates
2022-12-18T00:54:54.071-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve CCCP config. ambiguous timeout
2022-12-18T00:54:54.071-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve config from any node.
2022-12-18T00:54:59.572-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve CCCP config. ambiguous timeout
2022-12-18T00:54:59.572-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve config from any node.
2022-12-18T00:55:05.073-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve CCCP config. ambiguous timeout
2022-12-18T00:55:05.073-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve config from any node.
2022-12-18T00:55:10.575-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve CCCP config. ambiguous timeout
2022-12-18T00:55:10.575-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve config from any node.
2022-12-18T00:55:16.076-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve CCCP config. ambiguous timeout
2022-12-18T00:55:16.076-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve config from any node.
2022-12-18T00:55:21.577-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve CCCP config. ambiguous timeout
2022-12-18T00:55:21.577-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve config from any node.
2022-12-18T00:55:27.079-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve CCCP config. ambiguous timeout
2022-12-18T00:55:27.079-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve config from any node.
2022-12-18T00:55:32.580-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve CCCP config. ambiguous timeout
2022-12-18T00:55:32.580-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve config from any node.
2022-12-18T00:55:38.081-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve CCCP config. ambiguous timeout
2022-12-18T00:55:38.081-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve config from any node.
2022-12-18T00:55:43.582-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve CCCP config. ambiguous timeout
2022-12-18T00:55:43.582-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve config from any node.
2022-12-18T00:55:49.084-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve CCCP config. ambiguous timeout
2022-12-18T00:55:49.084-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve config from any node.
2022-12-18T00:55:54.586-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve CCCP config. ambiguous timeout
2022-12-18T00:55:54.586-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve config from any node.
2022-12-18T00:56:00.087-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve CCCP config. ambiguous timeout
2022-12-18T00:56:00.087-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve config from any node.
2022-12-18T00:56:05.588-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve CCCP config. ambiguous timeout
2022-12-18T00:56:05.588-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve config from any node.
2022-12-18T00:56:11.089-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve CCCP config. ambiguous timeout
2022-12-18T00:56:11.089-06:00 (Gocbcore) CCCPPOLL: Failed to retrieve config from any node.
JSON `file://in_network_uh_tpa-ppo_part_01.json` imported to `localhost` successfully
Documents imported: 16080 Documents failed: 0

real    1m30.801s
user    1m33.295s
sys     0m16.756s

### Parsing Index Files

Extract all urls for in-network files 
```shell
jq '.reporting_structure[].in_network_files[].location' 2022-12-01_Zurich-American-Insurance-Companies_index.json 

jq '.reporting_structure[].in_network_files[]?.location' 2022-12-01_cigna-health-life-insurance-company_index.json  |xargs wget 

```

### Extract Sublist via sed
[https://stackoverflow.com/questions/38972736/how-to-print-lines-between-two-patterns-inclusive-or-exclusive-in-sed-awk-or/38978201#38978201](https://stackoverflow.com/questions/38972736/how-to-print-lines-between-two-patterns-inclusive-or-exclusive-in-sed-awk-or/38978201#38978201)
```shell
sed -n -e '/"provider_references": \[/,/\"in_network": \[/p'  2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO-00_P3_in-network-rates.json >sed_prov_ref.json 
```

```shell
sed -n '/"provider_references": \[/,/\"in_network": \[/{/"in_network": \[/!p}'  2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO-00_P3_in-network-rates.json >ased_prov_ref.json 

# Exclude the new list key "in_network"
sed -n '/"provider_references": \[/,/\"in_network": \[/{/"in_network": \[/!p}'  2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO-00_P3_in-network-rates.json >ased_prov_ref.json 


# Exclude the both keys "provider_references" and "in_network"
sed -n '/"provider_references": \[/,/\"in_network": \[/{/"in_network"/!p}'  2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO-00_P3_in-network-rates.json >ased_prov_ref.json 

sed -n '/"provider_references": \[/,/\"in_network": \[/{/"provider_references"/!{/"in_network"/!p}}'  2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO-00_P3_in-network-rates.json >ased_prov_ref.json

{/PAT1/!{/PAT2/!p}}

sed -n -e '/"provider_references": \[/,/\"in_network": \[/{/"provider_references"/!{/"in_network"/!p}}'  2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO-00_P3_in-network-rates.json >sed_prov_ref.json 

sed -n -e '/"provider_references": \[/,/\"in_network": \[/!d;//d'  2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO-00_P3_in-network-rates.json >sed_prov_ref.json 

```
### Extract Network Rates
sed -n -e '/\"in_network": \[/,$p'  2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO-00_P3_in-network-rates.json >sed_network
_rates.json 
sed -n -e '/\"in_network":/,${/in_network/!p}'  2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO-00_P3_in-network-rates.json >sed_network_rates.json 

```shell
sed -n    '/in_network":/,$p'  2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO-00_P3_in-network-rates.json >sed_network_rates.json 
sed -i '0,/"in_network": / s///' sed_network_rates.json |less

sed -i "1s#^//-----------#& %TAG#" file.txt
```


 {"negotiation_arrangement":"ffs","name":"IMM ADMN SARSCOV2 30MCG/0.3ML DIL RECON 1ST DOSE","billing_code_type":"CPT","
