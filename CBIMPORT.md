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

```
 /opt/couchbase/bin/cbimport  json --username  Administrator  --password passwordString --bucket pt_bucket --dataset file://in_network_uh_tpa-ppo_part_01.json            -f lines -c localhost -g key::%billing_code%  --scope-collection-exp network.rates
 /opt/couchbase/bin/cbimport  json --username  Administrator  --password passwordString --bucket pt_bucket --dataset  file://provider_references_uh_tpa-ppo_part_01.json  -f lines -c localhost -g key::%provider_group_id% --scope-collection-exp provider.references


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
