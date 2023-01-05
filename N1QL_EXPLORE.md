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

```sql
SELECT
    DISTINCT     ppr,pr.*,pg.*,npi,nppes.prov_business_zip

FROM  `pt_bucket`.`uh`.`in_network` t

UNNEST t.`negotiated_rates` p
UNNEST p.`provider_references` ppr
UNNEST p.`negotiated_prices` pr
INNER JOIN `pt_bucket`.`uh`.provider_references t2
ON t2.provider_group_id=ppr

UNNEST t2.provider_groups pg
UNNEST pg.npi npi
INNER JOIN  pt_bucket.provider.nppes nppes  ON nppes.npi_int=npi

WHERE  t.billing_code = 'J1700'
AND nppes.prov_business_zip= '46260'
AND meta(t2).id LIKE 'key::PS1-50_C2%'
LIMIT 10
```

Indices used in the query above
```sql
CREATE INDEX adv_provider_group_id           ON `pt_bucket`.`uh`.`provider_references`(`provider_group_id`);
CREATE INDEX `adv_npi_int_prov_business_zip` ON `pt_bucket`.`provider`.`nppes`(`npi_int`,`prov_business_zip`) ;
CREATE INDEX adv_billing_code                ON `pt_bucket`.`uh`.`in_network`(`billing_code`);
CREATE INDEX adv_npi_int                     ON `pt_bucket`.`provider`.`nppes`(`npi_int`);
```

Index Advisor. Indices not created.
```sql
CREATE INDEX adv_ALL_provider_groups_npi_meta_id_provider_group_id ON `default`:`pt_bucket`.`uh`.`provider_references`(_ALL ARRAY (ALL ARRAY `npi` FOR npi IN `pg`.`npi` END) FOR pg IN `provider_groups` END,meta().`id`,`provider_group_id`)
CREATE INDEX adv_ALL_negotiated_rates_provider_references_billing_code ON `default`:`pt_bucket`.`uh`.`in_network`(_ALL ARRAY (ALL ARRAY `ppr` FOR ppr IN `p`.`provider_references` END) FOR p IN `negotiated_rates` END,`billing_code`)
```
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