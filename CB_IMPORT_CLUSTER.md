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