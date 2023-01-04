Load Provider Reference Data 
```shell
for i in `ls *json`;do \
echo  $i; \
/opt/couchbase/bin/cbimport json --username  Administrator  --password passwordString --bucket pt_bucket --dataset  file://$i  -f list \
-c https://cb03.sciviz.co:18091,cb01.sciviz.co:18091,cb02.sciviz.co:18091  --no-ssl-verify  \
-g key::%provider_group_id% --scope-collection-exp anthem.provider_references -t 4; \
done 
```


```shell


for i in `ls *json`;do  export j=${i%.json}; export k=${j#2022-12_}; export l=`echo $k|sed -e 's/_in-network-rates//'`; \
 echo  $i; \
/opt/couchbase/bin/cbimport json --username  Administrator  --password passwordString --bucket pt_bucket --dataset  file://$i  -f list \
-c https://cb03.sciviz.co:18091,cb01.sciviz.co:18091,cb02.sciviz.co:18091   --no-ssl-verify  \
-g key::$l::%billing_code%::%billing_code_type%::%negotiation_arrangement% --scope-collection-exp anthem.in_network -t 4; \
done 
```

### Index File
```shell
/opt/couchbase/bin/cbimport  json --username  Administrator  --password passwordString --bucket pt_bucket --dataset  file://anthem_index_lines.json  -f lines \
-c https://cb03.sciviz.co:18091,cb01.sciviz.co:18091,cb02.sciviz.co:18091  --no-ssl-verify  \
-g  key::#MONO_INCR# --scope-collection-exp anthem.index -t 4
```

### NPPES File
[https://download.cms.gov/nppes/NPI_Files.html](https://download.cms.gov/nppes/NPI_Files.html)
```shell
 /opt/couchbase/bin/cbimport csv --infer-types -c https://cb03.sciviz.co:18091,cb01.sciviz.co:18091,cb02.sciviz.co:18091  --no-ssl-verify  \
 -u Administrator -p passwordString \
  -d 'file://npidata_pfile_20050523-20221211.csv' -b 'pt_bucket' --scope-collection-exp "provider.nppes" -g %NPI% 

```

[https://data.cms.gov/provider-characteristics/medicare-provider-supplier-enrollment/medicare-provider-and-supplier-taxonomy-crosswalk/data](https://data.cms.gov/provider-characteristics/medicare-provider-supplier-enrollment/medicare-provider-and-supplier-taxonomy-crosswalk/data)
 ```shell
/opt/couchbase/bin/cbimport csv --infer-types -c https://cb03.sciviz.co:18091,cb01.sciviz.co:18091,cb02.sciviz.co:18091  --no-ssl-verify  \
 -u Administrator -p passwordString \
  -d 'file://Medicare_Provider_and_Supplier_Taxonomy_Crosswalk_June_2022' -b 'pt_bucket' --scope-collection-exp "provider.taxonomy_crosswalk" -g  key::#MONO_INCR#

```

### UH Individual Files
```shell
export i=2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PS1-50_C2_in-network-rates.json
export l=PS1-50_C2

export i=2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO---NDC_PPO-NDC_in-network-rates.json
export l=TPA-NDC_PPO
time /opt/couchbase/bin/cbimport json --username  Administrator  --password passwordString --bucket pt_bucket --dataset  file://$i  -f lines \
-c https://localhost:18091   --no-ssl-verify  \
-g key::$l::%billing_code%::%billing_code_type%::%negotiation_arrangement% --scope-collection-exp uh.in_network -t 14; \

```
Result:
```shell
Documents imported: 16371 Documents failed: 0

real    0m48.805s
user    2m38.952s
sys     0m13.655s
wc -l $i
16371 2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PS1-50_C2_in-network-rates.json

1.75GB database file 
ls -lh $i ->20G 


Documents imported: 56760 Documents failed: 0


real    0m2.623s
user    0m8.251s
sys     0m1.520s
wc -l $i
56760 2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO---NDC_PPO-NDC_in-network-rates.json
ls -lh $i
-rw-rw-r-- 1 mnm mnm 780M Dec 27 10:22 2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO---NDC_PPO-NDC_in-network-rates.json
1.82G-1.75G=70M 
10X storage compression
```
Document Count confirmed by SQL in addition to the  lines count
```sql
SELECT COUNT(*) FROM  `pt_bucket`.`uh`.`in_network` t WHERE  meta(t).id LIKE 'key::TPA-NDC_PPO%'
```

### UH Files
```shell
 for i in `ls`;do echo $i|grep -oP '(?<=Administrator_).+?(?=_in-net)' ;done
PPO---NDC_PPO-NDC
PPO---NDC_PPO-NDC
PS1-50_C2
PS1-50_C2
PS1-63_A3
PS1-63_A3

```
##### Group of files with common Pattern 
```shell
 for i in `ls`;do export l=$(echo $i|grep -oP '(?<=Administrator_).+?(?=_in-net)' ); \
 echo $i;  \
 /opt/couchbase/bin/cbimport json --username  Administrator  --password passwordString --bucket pt_bucket --dataset  file://$i  -f lines \
-c https://cb03.sciviz.co:18091,cb01.sciviz.co:18091,cb02.sciviz.co:18091   --no-ssl-verify  \
-g key::$l::%billing_code%::%billing_code_type%::%negotiation_arrangement% --scope-collection-exp uh.in_network -t 4; \
 
 done

```
Output
```shell
2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO---NDC_PPO-NDC_in-network-rates.json
JSON `file://2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO---NDC_PPO-NDC_in-network-rates.json` imported to `https://cb03.sciviz.co:18091,cb01.sciviz.co:18091,cb02.sciviz.co:18091` successfully
Documents imported: 56760 Documents failed: 0

2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PS1-50_C2_in-network-rates.json
JSON `file://2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PS1-50_C2_in-network-rates.json` imported to `https://cb03.sciviz.co:18091,cb01.sciviz.co:18091,cb02.sciviz.co:18091` successfully
Documents imported: 16371 Documents failed: 0

2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PS1-63_A3_in-network-rates.json
JSON `file://2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PS1-63_A3_in-network-rates.json` imported to `https://cb03.sciviz.co:18091,cb01.sciviz.co:18091,cb02.sciviz.co:18091` successfully
Documents imported: 16316 Documents failed: 0

 uh]# ls -lh
total 39G
-rw-r--r-- 1 root root 780M Dec 28 01:20 2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO---NDC_PPO-NDC_in-network-rates.json
-rw-r--r-- 1 root root  20G Dec 28 01:20 2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PS1-50_C2_in-network-rates.json
-rw-r--r-- 1 root root  19G Dec 28 01:20 2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PS1-63_A3_in-network-rates.json
drwxr-xr-x 2 root root 4.0K Dec 28 05:00 prov_ref
 uh]# 
wc -l 
   56760 2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO---NDC_PPO-NDC_in-network-rates.json
   16371 2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PS1-50_C2_in-network-rates.json
   16316 2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PS1-63_A3_in-network-rates.json
   89447 total
SQL confirs the total number of lines (items/documents)

```

Provider Ref
```shell
 for i in `ls`;do export l=$(echo $i|grep -oP '(?<=Administrator_).+?(?=_in-net)' ); \
 echo $i;  \
/opt/couchbase/bin/cbimport json --username  Administrator  --password passwordString --bucket pt_bucket --dataset  file://$i  -f lines \
-c https://cb03.sciviz.co:18091,cb01.sciviz.co:18091,cb02.sciviz.co:18091  --no-ssl-verify  \
-g key::$l::%provider_group_id% --scope-collection-exp uh.provider_references -t 4; \
done 
```

```shell


2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO---NDC_PPO-NDC_in-network-rates_prov_ref.json
JSON `file://2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO---NDC_PPO-NDC_in-network-rates_prov_ref.json` imported to `https://cb03.sciviz.co:18091,cb01.sciviz.co:18091,cb02.sciviz.co:18091` successfully
Documents imported: 140 Documents failed: 0
2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PS1-50_C2_in-network-rates_prov_ref.json
JSON `file://2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PS1-50_C2_in-network-rates_prov_ref.json` imported to `https://cb03.sciviz.co:18091,cb01.sciviz.co:18091,cb02.sciviz.co:18091` successfully
Documents imported: 55981 Documents failed: 0
2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PS1-63_A3_in-network-rates_prov_ref.json
JSON `file://2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PS1-63_A3_in-network-rates_prov_ref.json` imported to `https://cb03.sciviz.co:18091,cb01.sciviz.co:18091,cb02.sciviz.co:18091` successfully
Documents imported: 54390 Documents failed: 0
[root@ip-10-0-1-57 prov_ref]# wc -l *
     140 2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO---NDC_PPO-NDC_in-network-rates_prov_ref.json
   55981 2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PS1-50_C2_in-network-rates_prov_ref.json
   54390 2022-12-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PS1-63_A3_in-network-rates_prov_ref.json
  110511 total
```

Localhost Provider Load with de-duplication
```shell

 for i in `ls`;do export l=$(echo $i|grep -oP '(?<=Administrator_).+?(?=_in-net)' ); \
 echo $i;  \
/opt/couchbase/bin/cbimport json --username  Administrator  --password passwordString --bucket pt_bucket --dataset  file://$i  -f lines \
-c https://localhost:18091 --no-ssl-verify  \
-g key::$l::%provider_group_id% --scope-collection-exp uh.provider_references -t 4;
done
```

```shell
 for i in `ls`;do export l=$(echo $i|grep -oP '(?<=Administrator_).+?(?=_in-net)' ); \
 echo $i;  \
/opt/couchbase/bin/cbimport json --username  Administrator  --password passwordString --bucket pt_bucket --dataset  file://$i  -f lines \
-c https://localhost:18091 --no-ssl-verify  \
-g key::$l::%billing_code%::%billing_code_type%::%negotiation_arrangement% --scope-collection-exp uh.in_network -t 4; \
done 
```


### NPPES Data 
We will use the dataset from CMS [https://download.cms.gov/nppes/NPI_Files.html](https://download.cms.gov/nppes/NPI_Files.html)
The file is CSV. We will use the `cbimport-csv` without the `--infer-types` argument.  
[https://docs.couchbase.com/server/current/tools/cbimport-csv.html](https://docs.couchbase.com/server/current/tools/cbimport-csv.html)

```shell
/opt/couchbase/bin/cbimport csv   -c   https://localhost:18091 --no-ssl-verify  \
-u Administrator -p passwordString \
-d 'file://npidata_pfile_20050523-20221211.csv' -b 'pt_bucket' --scope-collection-exp "provider.nppes" -g %NPI% -t 10
```
Add the 5 string zipcode and integer NPI numbers
```sql
UPDATE pt_bucket.provider.nppes t
SET t.prov_business_zip=  SUBSTR(t.`Provider Business Practice Location Address Postal Code`,0,5);

UPDATE pt_bucket.provider.nppes t
SET t.prov_business_zip=  SUBSTR(t.`Provider Business Practice Location Address Postal Code`,0,5);
UPDATE pt_bucket.provider.nppes t
SET npi_int= TONUMBER(t.NPI);
```
ZipCode Coordinates
[https://catalog.data.gov/dataset/tiger-line-shapefile-2019-2010-nation-u-s-2010-census-5-digit-zip-code-tabulation-area-zcta5-na](https://catalog.data.gov/dataset/tiger-line-shapefile-2019-2010-nation-u-s-2010-census-5-digit-zip-code-tabulation-area-zcta5-na)


```shell
/opt/couchbase/bin/cbimport csv  --infer-types -c   https://localhost:18091 --no-ssl-verify  \
-u Administrator -p passwordString \
-d 'file://zip5_coordinates.csv ' -b 'pt_bucket' --scope-collection-exp "provider.zip_coordinates" -g %zip% -t 10
```

