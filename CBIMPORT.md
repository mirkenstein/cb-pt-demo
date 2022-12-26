### Copy file to docker host
docker ps
docker cp partA_01.json e09da844208c:/tmp/


##### Load Price Data 
```shell 
cbimport json --username  Administrator  --password passwordString --bucket pt_bucket --dataset file:///tmp/partA_01.json -f lines -c localhost -g key::%billing_code%


JSON `file:///tmp/partA_01.json` imported to `localhost` successfully
Documents imported: 464 Documents failed: 0
 root@e09da844208c:/tmp#
```

##### Load Provider Ref data
```shell

cbimport json --username  Administrator  --password passwordString --bucket pt_bucket --dataset file:///tmp/partB_01.json -f lines -c localhost -g key::%provider_group_id% --scope-collection-exp provider.references

JSON `file:///tmp/partA_01.json` imported to `localhost` successfully

Documents imported: 464 Documents failed: 0

--scope-collection-exp

```shell
 /opt/couchbase/bin/cbimport  json --username  Administrator  --password passwordString --bucket pt_bucket --dataset file://in_network_uh_tpa-ppo_part_01.json            -f lines -c localhost -g key::%billing_code%  --scope-collection-exp network.rates
 /opt/couchbase/bin/cbimport  json --username  Administrator  --password passwordString --bucket pt_bucket --dataset  file://provider_references_uh_tpa-ppo_part_01.json  -f lines -c localhost -g key::%provider_group_id% --scope-collection-exp provider.references

# Anthem
/opt/couchbase/bin/cbimport  json --username  Administrator  --password passwordString --bucket pt_bucket --dataset  file://38B0_2of3_prov_ref.json  -f lines -c localhost -g key::%provider_group_id% --scope-collection-exp anthem.provider_references
#Imported 2.56M documents in 17 s with -t=10
#Single thread took 1m40s
2 558 661
# Load Anthem Index File
/opt/couchbase/bin/cbimport  json --username  Administrator  --password passwordString --bucket pt_bucket --dataset  file://anthem_index_lines.json  -f lines -c localhost -g  key::#MONO_INCR# --scope-collection-exp anthem.index -t 10


### Batch Load Data
Load Provider Reference Data 
```shell
for i in `ls *json`;do \
echo  $i; \
/opt/couchbase/bin/cbimport json --username  Administrator  --password passwordString --bucket pt_bucket --dataset  file://$i  -f list -c localhost -g key::%provider_group_id% --scope-collection-exp anthem.provider_references -t 10; \
done 
```

2022-12_131_17B0_in-network-rates_6_of_7_prov_ref.json
JSON `file://2022-12_131_17B0_in-network-rates_6_of_7_prov_ref.json` imported to `localhost` successfully
Documents imported: 6544767 Documents failed: 0

2022-12_230_30B0_in-network-rates_prov_ref.json
JSON `file://2022-12_230_30B0_in-network-rates_prov_ref.json` imported to `localhost` successfully
Documents imported: 7280 Documents failed: 0

2022-12_302_42B0_in-network-rates_1_of_3_prov_ref.json
JSON `file://2022-12_302_42B0_in-network-rates_1_of_3_prov_ref.json` imported to `localhost` successfully
Documents imported: 58 Documents failed: 0

2022-12_410_60B0_in-network-rates_prov_ref.json
JSON `file://2022-12_410_60B0_in-network-rates_prov_ref.json` imported to `localhost` successfully
Documents imported: 7213 Documents failed: 0

2022-12_850_47B0_in-network-rates_prov_ref.json
JSON `file://2022-12_850_47B0_in-network-rates_prov_ref.json` imported to `localhost` successfully
Documents imported: 15365 Documents failed: 0

943MB-> 1.01 GB 6.57M documents
Load Price Data
6.63M Documents with lines file import
```shell
 for i in `ls *json`;do  export j=${i%.json}; export k=${j#2022-12_}; export l=`echo $k|sed -e 's/_in-network-rates//'`; \
 echo  $i; \
/opt/couchbase/bin/cbimport json --username  Administrator  --password passwordString --bucket pt_bucket --dataset  file://$i  -f list -c localhost -g key::$l::%billing_code% --scope-collection-exp anthem.in_network -t 10; \
done 


```
2022-12_131_17B0_in-network-rates_6_of_7.json
JSON `file://2022-12_131_17B0_in-network-rates_6_of_7.json` imported to `localhost` successfully
Documents imported: 26 174 Documents failed: 0

2022-12_230_30B0_in-network-rates.json
JSON `file://2022-12_230_30B0_in-network-rates.json` imported to `localhost` successfully
Documents imported: 247 247 Documents failed: 0

2022-12_302_42B0_in-network-rates_1_of_3.json
JSON `file://2022-12_302_42B0_in-network-rates_1_of_3.json` imported to `localhost` successfully
Documents imported: 7 918 664 Documents failed: 0

2022-12_410_60B0_in-network-rates.json
JSON `file://2022-12_410_60B0_in-network-rates.json` imported to `localhost` successfully
Documents imported: 17 180 Documents failed: 0

2022-12_850_47B0_in-network-rates.json
JSON `file://2022-12_850_47B0_in-network-rates.json` imported to `localhost` successfully
Documents imported: 17 609 Documents failed: 0

13GB files ->2.3 DB File

14GB lines file
 17 704 documents were imported, 4 documents failed to be imported
 wc -l 2022-12_32Q0_in-network-rates.json 
17707 2022-12_32Q0_in-network-rates.json
New Size 7.5GB
### Create index 
```sql 
CREATE PRIMARY INDEX ON `default`:`pt_bucket`
```

CREATE PRIMARY INDEX `#primary_prov` ON `pt_bucket`.`provider`.references

### Sample Document
```json
{
  "negotiation_arrangement": "ffs",
  "name": "ANESTHESIA ELECTROCONVULSIVE THERAPY",
  "billing_code_type": "CPT",
  "billing_code_type_version": "2022",
  "billing_code": "00104",
  "description": "ANESTHESIA ELECTROCONVULSIVE THERAPY",
  "negotiated_rates": [
    {
      "provider_references": [
        216695,
        1311,
        73454
      ],
      "negotiated_prices": [
        {
          "negotiated_type": "percentage",
          "negotiated_rate": 73.5,
          "expiration_date": "9999-12-31",
          "service_code": [
            "11"
          ],
          "billing_class": "professional"
        }
      ]
    },
    {
      "provider_references": [
        552
      ],
      "negotiated_prices": [
        {
          "negotiated_type": "fee schedule",
          "negotiated_rate": 90,
          "expiration_date": "9999-12-31",
          "service_code": [
            "11"
          ],
          "billing_class": "professional"
        }
      ]
    }
  ]
}
```
### NPPES File 

[https://download.cms.gov/nppes/NPI_Files.html](https://download.cms.gov/nppes/NPI_Files.html)
```shell
 /opt/couchbase/bin/cbimport csv --infer-types -c http://localhost:8091 -u Administrator -p passwordString  -d 'file://npidata_pfile_20050523-20221211.csv' -b 'pt_bucket' --scope-collection-exp "provider.nppes" -g %NPI% 


```