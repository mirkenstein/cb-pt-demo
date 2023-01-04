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
We get `871 304` providers. If we compute uniq `COUNT(DISTINCT npi)` then the numnber of providers is slightly lower 642956