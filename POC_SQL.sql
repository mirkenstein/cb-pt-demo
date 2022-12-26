

"key::850_47B0::0001::RC::ffs"

-- Get Document Size in MegaBytes
CREATE PRIMARY INDEX `#primary` ON `pt_bucket`.`anthem`.`provider_references`;

-- Get Document Size in MegaBytes
SELECT meta(t).id, t.* ,ARRAY_LENGTH(provider_groups),ENCODED_SIZE(provider_groups)/1000000 AS prov_gr_size
FROM pt_bucket.anthem.provider_references t
WHERE ARRAY_LENGTH(provider_groups)>10
-- ORDER BY prov_gr_size DESC
;

SELECT t.* FROM `pt_bucket`.`anthem`.`provider_references` t
-- WHERE provider_group_id=254.0000000004
;
SELECT COUNT(*) FROM `pt_bucket`.`anthem`.`provider_references` t;
-- 14 241 482

SELECT  meta(t2).id,pg.*,npi FROM `pt_bucket`.`anthem`.provider_references t2
UNNEST t2.provider_groups pg
UNNEST pg.npi npi
;
--  Index Provider References
CREATE INDEX adv_ALL_provider_groups_npi
    ON `default`:`pt_bucket`.`anthem`.`provider_references`(ALL ARRAY (ALL ARRAY `npi` FOR npi IN `pg`.`npi` END) FOR pg IN `provider_groups` END)
PARTITION BY hash(`npi`);

--Index Provider References for Size
CREATE INDEX adv_encoded_size_provider_groups_div_1000000
    ON `default`:`pt_bucket`.`anthem`.`provider_references`(encoded_size(`provider_groups`)/1000000 INCLUDE MISSING);


SELECT t.* FROM  `pt_bucket`.`anthem`.`in_network` t;
SELECT COUNT(*) FROM  `pt_bucket`.`anthem`.`in_network` t
UNNEST t.`negotiated_rates` p
-- UNNEST p.`provider_references` ppr
;
--    COUNT 111 722
--    UNNEST t.`negotiated_rates` p  UNNEST p.`provider_references` ppr "$1": 166 082 686
--    UNNEST t.`negotiated_rates` p ->      7 440 327

SELECT SUM(ARRAY_LENGTH(t.negotiated_rates)) FROM   `pt_bucket`.`anthem`.`in_network` t;
-- 7 440 327

SELECT
--     pnr.*
     p.*
--     (pnr.negotiated_rate)
FROM  `pt_bucket`.`anthem`.`in_network` t
UNNEST t.`negotiated_rates` p
-- UNNEST p.`negotiated_prices` pnr
-- ;

SELECT t.* FROM  `pt_bucket`.`anthem`.`in_network` t
LIMIT 100
;
SELECT COUNT(meta(t).id) FROM  `pt_bucket`.`anthem`.`in_network` t
--                 WHERE meta(t).id LIKE 'key::32Q0%'
--                 WHERE meta(t).id LIKE 'key::131_17B0%'
--                 WHERE meta(t).id LIKE 'key::850_47B0%'
                WHERE meta(t).id LIKE 'key::410_60B0%'
--                 WHERE meta(t).id LIKE 'key::302_42B0%'
--                 WHERE meta(t).id LIKE 'key::230_30B0%'
;
-- 32Q0      17 704
-- 131_17B0  18 053
-- 850_47B0  17 155
-- 410_60B0  16 726 17 180
-- 302_42B0  23 932 7 975 992
-- 230_30B0  82 671
-- Find out Duplicate Codes
SELECT t.billing_code,COUNT(*)
FROM  `pt_bucket`.`anthem`.`in_network` t
 WHERE
--                       meta(t).id LIKE 'key::32Q0%'
--                  meta(t).id LIKE 'key::131_17B0%'
--                meta(t).id LIKE 'key::850_47B0%'
--                  meta(t).id LIKE 'key::410_60B0%'
--                  meta(t).id LIKE 'key::302_42B0%'
--                meta(t).id LIKE 'key::230_30B0%'
GROUP BY t.billing_code
HAVING COUNT(*)>2;

SELECT meta(t).id,t.*, ARRAY_LENGTH(p.provider_references) AS AL_PR, ENCODED_SIZE(t.provider_references)/1000000 AS PR_SIZE
FROM  `pt_bucket`.`anthem`.`in_network` t
UNNEST t.`negotiated_rates` p
 WHERE ARRAY_LENGTH(p.provider_references)>1000
;

SELECT t.* FROM pt_bucket.anthem.in_network
WHERE  meta(t).id='key::230_30B0::00002144501::NDC::ffs';
-- Explore Duplicate Codes

SELECT meta(t).id ,t.*  ,ARRAY_LENGTH(negotiated_rates) AS NR_L ,ENCODED_SIZE(negotiated_rates)/1000000 AS NR_SIZE
FROM  `pt_bucket`.`anthem`.`in_network` t
 WHERE
--                  meta(t).id LIKE 'key::32Q0%'
--                  meta(t).id LIKE 'key::131_17B0%'
--                meta(t).id LIKE 'key::850_47B0%'
--                  meta(t).id LIKE 'key::410_60B0%'
--                  meta(t).id LIKE 'key::302_42B0%'
               meta(t).id LIKE 'key::230_30B0%'
;
CREATE PRIMARY INDEX `#primary` ON `pt_bucket`.`anthem`.`in_network`;
SELECT meta(t).id,t.bundled_codes,
       ARRAY_LENGTH(t.bundled_codes) AS BC_L,ENCODED_SIZE(t.bundled_codes)/1000000  AS BC_SIZE ,

       t.negotiated_rates
  ,ARRAY_LENGTH(t.negotiated_rates) AS NR_L ,ENCODED_SIZE(t.negotiated_rates)/1000000 AS NR_SIZE

FROM  `pt_bucket`.`anthem`.`in_network` t
--   WHERE
--   meta(t).id LIKE
--         'key::32Q0%'
--         'key::850_47B0::0001::RC%'
-- ORDER BY NR_L DESC
;

-- 2_32Q0
-- App Query


SELECT meta(t).id,t.* FROM  `pt_bucket`.`anthem`.`in_network` t
WHERE meta(t).id LIKE 'key::410_60B0::B4160%';

SELECT
    ppr,t.*,pg.*,npi
-- COUNT(*)
FROM  `pt_bucket`.`anthem`.`in_network` t
UNNEST t.`negotiated_rates` p
UNNEST p.`provider_references` ppr
INNER JOIN `pt_bucket`.`anthem`.provider_references t2
ON t2.provider_group_id=ppr
UNNEST t2.provider_groups pg

-- APP Query with NPI JOIN
SELECT
    DISTINCT
    ppr,t.*,pg.*,npi,tx.*
-- COUNT(*)
FROM  `pt_bucket`.`anthem`.`in_network` t
UNNEST t.`negotiated_rates` p
UNNEST p.`provider_references` ppr
INNER JOIN `pt_bucket`.`anthem`.provider_references t2
ON t2.provider_group_id=ppr
UNNEST t2.provider_groups pg
UNNEST pg.npi npi
INNER JOIN  pt_bucket.provider.nppes nppes  ON nppes.NPI=npi
INNER JOIN  pt_bucket.provider.taxonomy_crosswalk tx  ON nppes.`Healthcare Provider Taxonomy Code_1` =tx.`PROVIDER_TAXONOMY_CODE`

WHERE meta(t).id LIKE 'key::410_60B0::B4160::ICD%'
AND  t2.provider_group_id<>410.02079
;
SELECT t2.* FROM `pt_bucket`.`anthem`.provider_references t2
 WHERE provider_group_id=410.02079

SELECT
t.*,p.*,t2.*,npi
FROM  `pt_bucket`.`anthem`.`in_network` t
UNNEST t.`negotiated_rates` p
UNNEST p.`provider_references` ppr
INNER JOIN `pt_bucket`.`anthem`.provider_references t2
ON t2.provider_group_id=ppr
UNNEST t2.provider_groups pg
UNNEST pg.npi npi
INNER JOIN  pt_bucket.provider.nppes nppes  ON nppes.NPI=npi
WHERE meta(t).id LIKE 'key::410_60B0::B4160::ICD%'
AND ppr=410.02079
;

SELECT t2.*,pg.*,npi
FROM `pt_bucket`.`anthem`.provider_references t2
UNNEST t2.provider_groups pg
UNNEST pg.npi npi
-- INNER JOIN  pt_bucket.provider.nppes nppes
-- ON nppes.npi=pg.npi


-- Provider Joins
-- Indecies
CREATE PRIMARY INDEX #primary ON `default`:`pt_bucket`.`anthem`.`provider_references`;
CREATE INDEX adv_npi ON `default`:`pt_bucket`.`provider`.`nppes`(`npi`);
-- CREATE INDEX adv_ALL_provider_groups_npi ON `default`:`pt_bucket`.`anthem`.`provider_references`(ALL ARRAY (ALL ARRAY `npi` FOR npi IN `pg`.`npi` END) FOR pg IN `provider_groups` END)


SELECT t2.*,pg.*,npi
FROM `pt_bucket`.`anthem`.provider_references t2
UNNEST t2.provider_groups pg
UNNEST pg.npi npi
INNER JOIN  pt_bucket.provider.nppes nppes
ON nppes.npi=pg.npi
;
SELECT p.*,ARRAY_LENGTH(p.provider_references) AS AL_PR ,ppr FROM  `pt_bucket`.`anthem`.`in_network` t
UNNEST t.`negotiated_rates` p
UNNEST p.`provider_references` ppr
INNER JOIN `pt_bucket`.`anthem`.provider_references t2
ON t2.provider_group_id=ppr
                                                   LIMIT 100;
;
SELECT meta(t).id, p.*,ARRAY_LENGTH(p.provider_references) AS APR_AL,ENCODED_SIZE(t.negotiated_rates)/1000000 AS PR_SIZE ,ppr
FROM  `pt_bucket`.`anthem`.`in_network` t
WHERE ARRAY_LENGTH(p.provider_references)>1;

SELECT meta(t).id, p.*,ARRAY_LENGTH(p.provider_references) AS APR_AL,ENCODED_SIZE(t.negotiated_rates)/1000000 AS PR_SIZE ,ppr
FROM  `pt_bucket`.`anthem`.`in_network` t
UNNEST t.`negotiated_rates` p
UNNEST p.`provider_references` ppr
INNER JOIN `pt_bucket`.`anthem`.provider_references t2
ON t2.provider_group_id=ppr
WHERE ARRAY_LENGTH(p.provider_references)>1;

-- Check Array Size for Provider References
SELECT meta(t).id, p.*,ARRAY_LENGTH(p.provider_references) AS APR_AL,ENCODED_SIZE(t.negotiated_rates)/1000000 AS PR_SIZE
FROM  `pt_bucket`.`anthem`.`in_network` t
UNNEST t.`negotiated_rates` p
-- WHERE ARRAY_LENGTH(p.provider_references)>10;

-- INDEX ADVISOR
CREATE INDEX adv_ALL_negotiated_rates_provider_references
    ON `default`:`pt_bucket`.`anthem`.`in_network`(_ALL ARRAY
                                                       (ALL ARRAY `ppr`
                                                          FOR ppr IN `p`.`provider_references` END
                                                        )
                                                          FOR p IN `negotiated_rates` END
                                                   )

-- Index on in_network and provider_references for JOIN
CREATE INDEX `adv_ALL_negotiated_rates_provider_references` ON `pt_bucket`.`anthem`.`in_network`((all (array (all (array `ppr` for `ppr` in (`p`.`provider_references`) end)) for `p` in `negotiated_rates` end)))
PARTITION BY hash(`ppr`)
WITH {  "nodes":[ "cb-index01.sciviz.co:8091","cb-index02.sciviz.co:8091" ], "num_partition":8, "num_replica":1  }


CREATE INDEX `adv_provider_group_id` ON `pt_bucket`.`anthem`.`provider_references`(`provider_group_id`)
PARTITION BY hash(`provider_group_id`)
WITH {  "nodes":[ "cb-index01.sciviz.co:8091","cb-index02.sciviz.co:8091" ], "num_replica":1 }

CREATE INDEX adv_ALL_provider_groups_provider_group_id ON `default`:`pt_bucket`.`anthem`.`provider_references`(ALL `provider_groups`,`provider_group_id`);

--
-- Anthem Index File
--
CREATE PRIMARY INDEX `#primary` ON `pt_bucket`.`anthem`.`index`;
SELECT t.* ,ARRAY_LENGTH(t.in_network_files) AS CT_INNET,ARRAY_LENGTH(t.reporting_plans) AS CT_PLANS
CREATE INDEX `adv_ALL_in_network_files_location` ON `pt_bucket`.`anthem`.`index`((all (array (`inf`.`location`) for `inf` in `in_network_files` end)))
FROM `pt_bucket`.`anthem`.`index` t;

-- number of locations (files)
SELECT COUNT(DISTINCT inf.location) FROM `pt_bucket`.`anthem`.`index` t
UNNEST t.in_network_files  inf;

SELECT p.*, ARRAY_LENGTH(t.in_network_files) AS CT_INNET
FROM `pt_bucket`.`anthem`.`index` t
UNNEST t.reporting_plans p
WHERE  p.plan_name LIKE 'GOOG%';
-- WHERE  p.plan_name LIKE 'GOOGLE%';

-- Number of plans
SELECT COUNT(DISTINCT p.plan_id)
FROM `pt_bucket`.`anthem`.`index` t;
UNNEST t.reporting_plans p;
-- 138 542
SELECT COUNT(*) FROM `pt_bucket`.`anthem`.`index` t
-- 138 609

SELECT
    inf.*,p.*, ARRAY_LENGTH(t.in_network_files) AS CT_INNET
-- COUNT(*)
-- 542
FROM `pt_bucket`.`anthem`.`index` t
UNNEST t.reporting_plans p
UNNEST t.in_network_files  inf
WHERE  p.plan_name ='VERIZON ASSOCIATES NY NE'
;


-- NPPES
CREATE INDEX adv_NPI ON `default`:`pt_bucket`.`provider`.`nppes`(`NPI`)

SELECT COUNT(*) FROM pt_bucket.provider.nppes t;
-- 7 592 837 sql
-- 7 592 844 wc-l
SELECT meta(t).id,t.* FROM pt_bucket.provider.nppes t
--            WHERE meta(t).id =1609858729
;
SELECT `Provider Last Name (Legal Name)`,COUNT(*) AS CT
FROM pt_bucket.provider.nppes
WHERE `Entity Type Code`=1
GROUP BY `Provider Last Name (Legal Name)`
ORDER BY CT DESC
;
-- Taxonomy Cross Ref
CREATE INDEX adv_PROVIDER_TAXONOMY_CODE ON `default`:`pt_bucket`.`provider`.`taxonomy_crosswalk`(`PROVIDER_TAXONOMY_CODE`);
SELECT t.`PROVIDER TAXONOMY CODE`,COUNT(*) FROM  pt_bucket.provider.taxonomy_crosswalk t
GROUP BY `PROVIDER TAXONOMY CODE`
;
SELECT t.* FROM  pt_bucket.provider.taxonomy_crosswalk t
WHERE `PROVIDER TAXONOMY CODE`='222Z00000X'
;
