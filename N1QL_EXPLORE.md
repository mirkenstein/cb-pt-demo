### Create Primary Indices
```sql
CREATE PRIMARY INDEX `#primary` ON `pt_bucket`.`uh`.`provider_references`;
CREATE PRIMARY INDEX `#primary` ON `pt_bucket`.`uh`.`in_network`;
CREATE PRIMARY INDEX `#primary` ON `pt_bucket`.`provider`.`nppes`;
```

We would like to look up items based on a billing code so we will add the following index
```sql
CREATE INDEX adv_billing_code ON `default`:`pt_bucket`.`uh`.`in_network`(`billing_code`)
```

 Example lookup query on a specific billing code. 
```sql
SELECT meta(t).id,t.* FROM  `pt_bucket`.`uh`.`in_network` t    WHERE   t.billing_code='J1700';
```
We would expect for each file that we loaded to return an individual rate "line".

Let's further explore the line in greater details.

```sql
SELECT
    COUNT(*)
FROM  `pt_bucket`.`uh`.`in_network` t
   UNNEST t.`negotiated_rates` p
   UNNEST p.`provider_references` ppr
WHERE
    meta(t).id LIKE 'key::PS1-50_C2%'
    AND  t.billing_code='J1700';

```
The query above returns 4720. That is from a single rate we get thousands of lines.

Provider references
```sql
ELECT COUNT(*)
     FROM `pt_bucket`.`uh`.provider_references t2
     USE INDEX (adv_ALL_provider_groups_npi_provider_group_id USING GSI)
UNNEST t2.provider_groups pg
UNNEST pg.npi npi
    WHERE  meta(t2).id LIKE 'key::PS1-50_C2%'
```
This gives us `1 890 525` lines with NPI numbers.


Lets join the single rate line with the provider references 
```sql
SELECT
COUNT( npi)
FROM  `pt_bucket`.`uh`.`in_network` t
UNNEST t.`negotiated_rates` p
UNNEST p.`provider_references` ppr
INNER JOIN `pt_bucket`.`uh`.provider_references t2
ON t2.provider_group_id=ppr
UNNEST t2.provider_groups pg
UNNEST pg.npi npi
WHERE  t.billing_code = 'J1700'
AND meta(t2).id LIKE 'key::PS1-50_C2%'
```
We get `871 304` providers. If we compute uniq `COUNT(DISTINCT npi)` then the number of providers is slightly lower 642956


### Typical Application Query

We would need to filter on
1. Billing Code
2. Provider Location, i.e. Zip Code
3. Plan ID which is contained in the substring from the filename from where the rates are uploaded from.
```sql
WHERE  t.billing_code = 'J1700'
AND nppes.prov_business_zip= '56751'
AND meta(t2).id LIKE 'key::PS1-50_C2%'
```
This query without the Zip Code Condition executes in under 100ms.
Adding the Zip Code clause the query takes 30 seconds.
The bottleneck seems to be with the nppes zipcode scan. 
![cb_plan_nppes_scan_01.png](img%2Fcb_plan_nppes_scan_01.png)
![cb_plan_nppes_scan_02.png](img%2Fcb_plan_nppes_scan_02.png)
```sql
SELECT
    DISTINCT     t.billing_code, pr.negotiated_rate,npi,SUBSTR(nppes.`Provider Business Practice Location Address Postal Code`,0,5)

FROM  `pt_bucket`.`uh`.`in_network` t

UNNEST t.`negotiated_rates` p
UNNEST p.`provider_references` ppr
UNNEST p.`negotiated_prices` pr
INNER JOIN `pt_bucket`.`uh`.provider_references t2
ON t2.provider_group_id=ppr

UNNEST t2.provider_groups pg
UNNEST pg.npi npi
INNER JOIN  pt_bucket.provider.nppes nppes  ON  TONUMBER(nppes.NPI)=npi

WHERE  t.billing_code = 'J0129'
AND SUBSTR(nppes.`Provider Business Practice Location Address Postal Code`,0,5)='01810'
AND meta(t2).id LIKE 'key::PS1-50_C2%'
LIMIT 10
```

Indices used in the query above
```sql
CREATE INDEX idx_provider_references ON `default`:`pt_bucket`.`uh`.`in_network`(`billing_code`,(distinct (array (distinct (array `y` for `y` in (`x`.`provider_references`) end)) for `x` in `negotiated_rates` end))) PARTITION BY HASH(`billing_code`)
CREATE INDEX idx_provider_group_id ON `default`:`pt_bucket`.`uh`.`provider_references`(`provider_group_id`)
CREATE INDEX adv_to_number_NPI_substr0_ProviderBusinessPracticeLocationAddressPostalCode05 ON `default`:`pt_bucket`.`provider`.`nppes`(to_number(`NPI`),substr0(`Provider Business Practice Location Address Postal Code`, 0, 5))```

Index Advisor. Indices not created.
```sql
CREATE INDEX adv_ALL_provider_groups_npi_meta_id_provider_group_id ON `default`:`pt_bucket`.`uh`.`provider_references`(_ALL ARRAY (ALL ARRAY `npi` FOR npi IN `pg`.`npi` END) FOR pg IN `provider_groups` END,meta().`id`,`provider_group_id`)
CREATE INDEX adv_ALL_negotiated_rates_provider_references_billing_code ON `default`:`pt_bucket`.`uh`.`in_network`(_ALL ARRAY (ALL ARRAY `ppr` FOR ppr IN `p`.`provider_references` END) FOR p IN `negotiated_rates` END,`billing_code`)
```
Note on restoring indexes after snapshot restore.
````sql
BUILD INDEX ON `pt_bucket`.`uh`.provider_references(idx_provider_groups_npi,provider_group_id, idx_billingCode_by_jad) USING GSI;
BUILD INDEX ON `pt_bucket`.`uh`.in_network(idx_provider_references ) USING GSI;
BUILD INDEX ON `pt_bucket`.`provider`.nppes(
adv_EntityTypeCode,
adv_substr0_ProviderBusinessPracticeLocationAddressPostalCode05_to_number_NPI,
adv_to_number_NPI_substr0_ProviderBusinessPracticeLocationAddressPostalCode05
 ) USING GSI;

````

Error Message when trying to create the index above
```json
[
  {
    "code": 3000,
    "msg": "syntax error - line 1, column 124, near 'm`.`in_network`(_ALL', at: ARRAY (reserved word)",
    "query": "CREATE INDEX adv_ALL_negotiated_rates_provider_references_billing_code ON `default`:`pt_bucket`.`anthem`.`in_network`(_ALL ARRAY (ALL ARRAY `ppr` FOR ppr IN `p`.`provider_references` END) FOR p IN `negotiated_rates` END,`billing_code`)"
  }
]
```

#  Application Query 2
### Find rates for a specific provider for a specific procedure

```sql 
SELECT DISTINCT t.billing_code,
       pr.negotiated_rate,
       npi

FROM `pt_bucket`.`uh`.`in_network` t
UNNEST t.`negotiated_rates` p
UNNEST p.`provider_references` ppr
UNNEST p.`negotiated_prices` pr
INNER JOIN `pt_bucket`.`uh`.provider_references t2 ON t2.provider_group_id=ppr
UNNEST t2.provider_groups pg
UNNEST pg.npi npi

WHERE t.billing_code IN ['J1030','J1700','J0129']
    AND npi=1265066245
    AND META(t2).id LIKE 'key::PS1-50_C2%';
``` 

#  Application Query 3
### Get aggregate statistics for a given list of procedures for certain region

```sql
    SELECT AVG(t.billing_code),SELECT  t.billing_code,AVG(t.negotiated_rates),
       COUNT(DISTINCT npi)

FROM `pt_bucket`.`uh`.`in_network` t
UNNEST t.`negotiated_rates` p
UNNEST p.`provider_references` ppr
UNNEST p.`negotiated_prices` pr
INNER JOIN `pt_bucket`.`uh`.provider_references t2 ON t2.provider_group_id=ppr
UNNEST t2.provider_groups pg
UNNEST pg.npi npi
INNER JOIN pt_bucket.provider.nppes nppes ON TONUMBER(nppes.NPI)=npi
WHERE t.billing_code  IN ['J1030','J1700','J0129']
   AND SUBSTR(nppes.`Provider Business Practice Location Address Postal Code`,0,5)='56751'
    AND META(t2).id LIKE 'key::PS1-50_C2%'
GROUP BY  t.billing_code
    ;
```