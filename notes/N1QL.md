
### N1QL Code for MRF Exploration

```sql

-- -- --
-- PT data
-- -- --
CREATE PRIMARY INDEX ON `default`:`pt_bucket`
SELECT r.billing_code
from `pt_bucket` r;
-- Transp
SELECT COUNT(*)
FROM pt_bucket

SELECT COUNT(*)
FROM pt_bucket r
-- 464 Original Documents
         UNNEST r.`negotiated_rates` p
-- 93 323 rates unnesting
         UNNEST p.`provider_references` ppr
-- 12 077 103 provider unnesting
-- UNNEST     p.`negotiated_prices` pnr

-- Regular Table Display*
SELECT r.billing_code
     , r.billing_code_type
     , r.negotiation_arrangement
     , r.billing_code_type_version
     , r.description
     , pnr.*
,p.provider_references
FROM pt_bucket r
         UNNEST r.`negotiated_rates` p
--          UNNEST p.`provider_references` ppr
         UNNEST p.`negotiated_prices` pnr
WHERE r.billing_code = '00104'
-- AND ARRAY_CONTAINS(p.provider_references,552)
AND ARRAY_CONTAINS(pnr.service_code,"11")



-- Nested Array Length Calculations
SELECT r.billing_code, ARRAY_LENGTH(r.`negotiated_rates`) AS negotiated_rates_length
FROM pt_bucket r

SELECT r.billing_code
     , ARRAY_LENGTH(p.provider_references) AS prov_ref_length
     , p.*

FROM pt_bucket r
         UNNEST r.`negotiated_rates` p
WHERE r.billing_code = '90791'
-- -- '00104'
-- AND pr=1311
SELECT r.billing_code
     , ARRAY_LENGTH(pnr.service_code) AS service_code_length
     , p.*
FROM pt_bucket r
         UNNEST r.`negotiated_rates` p
         UNNEST p.`negotiated_prices` pnr
WHERE r.billing_code = '90791'

-- WHERE r.billing_code='00104'
SELECT r.billing_code, p.*
FROM pt_bucket r
         UNNEST r.`negotiated_rates` p
WHERE r.billing_code = '0551'



SELECT ARRAY_LENGTH(p.provider_references) AS prov_ref_length, pnr.*, ppr

FROM pt_bucket r
         UNNEST r.`negotiated_rates` p
         UNNEST p.`provider_references` ppr
         UNNEST p.`negotiated_prices` pnr
WHERE r.billing_code = '00104'
-- AND pr=1311


-- 464
-- 93 323
-- 12 077 103



--
-- PT Aggregates
--

SELECT
--     r.billing_code
--      , r.billing_code_type
--      , r.negotiation_arrangement
--      , r.billing_code_type_version
--      , r.description
--      , pnr.*
     ppr,COUNT(r.billing_code)

FROM pt_bucket r
         UNNEST r.`negotiated_rates` p
         UNNEST p.`provider_references` ppr
         UNNEST p.`negotiated_prices` pnr

-- WHERE r.billing_code = '00104'
-- AND ARRAY_CONTAINS(p.provider_references,552)
-- AND ARRAY_CONTAINS(pnr.service_code,"11")
GROUP BY ppr

```
