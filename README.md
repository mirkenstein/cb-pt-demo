# CMS Transparency in Coverage
[https://www.cms.gov/healthplan-price-transparency](https://www.cms.gov/healthplan-price-transparency)

Most group health plans are required to disclose pricing information. The pricing information is published via a machine-readable files aka MRF
which contains costs for services with the references to the providers that are rendering these services.

The official CMS developer documentation can be found on the follwoing github page
[https://github.com/CMSgov/price-transparency-guide](https://github.com/CMSgov/price-transparency-guide)

### Obtaining the MRF files
Here are the direct urls for the Price Transparency data for selected payers.  

[https://www.bcbsil.com/member/policy-forms/machine-readable-file](https://www.bcbsil.com/member/policy-forms/machine-readable-file)
[https://transparency-in-coverage.uhc.com/](https://transparency-in-coverage.uhc.com/)
[https://www.centene.com/price-transparency-files.html](https://www.centene.com/price-transparency-files.html)
[https://www.anthem.com/machine-readable-file/search/](https://www.anthem.com/machine-readable-file/search/)
[https://mrfdata.hmhs.com/](https://mrfdata.hmhs.com/)


First we would download the index file which contains the links to all the actual MRF files.
One way extract the urls is via the `jq`

```shell
jq '.reporting_structure[].in_network_files[]?.location' index_file.json
```
or if the file is exceedingly large we can use the `jq` with stream option as described in the man page
[https://stedolan.github.io/jq/manual/#Streaming](https://stedolan.github.io/jq/manual/#Streaming)
```shell
jq  -cn --stream 'fromstream(2|truncate_stream(inputs|select(.[0][0] )))'   large_index.json > large_index_lines.json
```
The command above splits the index file into individual items lines that are convenient to load into couchbase.

# MRF File Schema
They are large files that are commonly reach tens of gigabytes each. 
Here are the CMS guidelines for the schem [https://github.com/CMSgov/price-transparency-guide/tree/master/schemas/in-network-rates](https://github.com/CMSgov/price-transparency-guide/tree/master/schemas/in-network-rates)
The files structure looks like this...

### Top Level File Structure
```json
{"reporting_entity_name":"Empire BlueCross BlueShield",
"reporting_entity_type":"Health Insurance Network",
"last_updated_on":"2022-12-01",
"version":"1.2.3",
"provider_references":[ ... ],
"in_network": [... ]
}
```
### Rates Information
`in_network` list contains the rate information for a list of medical codes. This `in_network` list is typically contains tens of thousands of items. Each items is specific to a given medical code.

Example item would look like this.

```json
{
  "negotiation_arrangement": "ffs",
  "name": "AMB SERVICE OUTSIDE STATE PER MILE TRANSPORT",
  "billing_code_type": "HCPCS",
  "billing_code_type_version": "2022",
  "billing_code": "A0021",
  "description": "Ambulance service, outside state per mile, transport (Medicaid only)",
  "negotiated_rates": [
    {
      "provider_references": [41354,9436,35161],
      "negotiated_prices": [
        {
          "negotiated_rate": 10.29,
          "service_code": [  "20","23","41","42" ],
          "negotiated_type": "negotiated",
          "expiration_date": "9999-12-31",
          "billing_class": "professional",
          "billing_code_modifier": ["GM","JY"],
          "additional_information": ""
        }
      ]
    },
    {
      "provider_references": [...],
      "negotiated_prices": [
        {
        ...
        }
      ]
    },
  
    ....
}

```
The `negotiated_rates` list  can contain more than one items. It can be as much as tens of thousands and in some instances it can reach hundreds of thousands of items.

### Provider References
`provider_references` list contains the lookup information for the providers. It is sort of the `JOIN` on the 
```json
{
  "provider_groups": [
    {
      "npi": [  1881780344, 1609829100, 1225090087  ],
      "tin": {
        "type": "ein",
        "value": "123456789"
      }
    }
  ],
  "provider_group_id": 104
}
```

# Preparing the files

From the index file we would download some rate files and will separate the `in_network` and `provider_references` lists into a their own files that we will use for loading into the respective collections.
Here again we find the `jq` command line utility

For the rates we run:
```shell
 jq -c --stream 'fromstream(2|truncate_stream(inputs|select(.[0][0]=="in_network")))' PT_FILE_NAME.json>PT_FILE_NAME_IN_NETWORK.json 
```

Similarly for the provider references:
```shell
jq -c --stream 'fromstream(2|truncate_stream(inputs|select(.[0][0]=="provider_references")))'  PT_FILE_NAME.json>PT_FILE_NAME_PROV_REF.json
``` 
The two `jq` commands will extract the list items into a compact json lines. Each line containing a single item from the respective collection.

# Loading the data
Per the plan naming conventions [https://github.com/CMSgov/price-transparency-guide#file-naming-convention](https://github.com/CMSgov/price-transparency-guide#file-naming-convention)
The payers use the following name structure    
`2022-12-01_<Payer Name String>_<Arrangament>_<Pan ID>_in-network-rates.json` for example

`2022-12-01_Some-Payer-Name-Inc-_Third-Party-Administrator_AB1-10_C3_in-network-rates.json`
We will use the `<Unique Identifier String>` AB1-10_C3 as part of the key for our items. 

### Rates Data
```shell
 for i in `ls`;do export l=$(echo $i|grep -oP '(?<=Administrator_).+?(?=_in-net)' ); \
echo "Loading Rates from file $i";  \
/opt/couchbase/bin/cbimport json --username  $cb_user  --password $cb_password --bucket pt_bucket \
--dataset  file://$i  -f lines \
-c $cb_connection_string --no-ssl-verify  \
-g key::$l::%billing_code%::%billing_code_type%::%negotiation_arrangement% \
--scope-collection-exp uh.in_network -t 4; \
done 
```
Where we set out variables 
```shell
export cb_connection_string="https://cb03.sciviz.co:18091,cb01.sciviz.co:18091,cb02.sciviz.co:18091"
export cb_user=Administrator
export cb_password=passwordString
export bucket=pt_bucket
```

The provider references files are extracted into a separate directory.
`cd prov_ref/`
From inside that directory we will load the provider references.

```shell
 for i in `ls`;do export l=$(echo $i|grep -oP '(?<=Administrator_).+?(?=_in-net)' ); \
 echo "Loading Prov Ref from file $i"; ;  \
/opt/couchbase/bin/cbimport json --username  $cb_user  --password $cb_password --bucket pt_bucket \
--dataset  file://$i  -f lines \
-c $cb_connection_string  --no-ssl-verify  \
-g key::$l::%provider_group_id% --scope-collection-exp uh.provider_references -t 4; \
done 
```




 
### NPPES Data 

The `npi` list from the `provider_references`
We will use the dataset from CMS [https://download.cms.gov/nppes/NPI_Files.html](https://download.cms.gov/nppes/NPI_Files.html)
Download the latest `Full Replacement Monthly NPI File` and extract the zip archive. The extracted file will be over 8GB size and will contains millions of entries.
The file is CSV. We will use the `cbimport-csv` without the `--infer-types` argument.  
[https://docs.couchbase.com/server/current/tools/cbimport-csv.html](https://docs.couchbase.com/server/current/tools/cbimport-csv.html)

```shell
/opt/couchbase/bin/cbimport csv   -c  $cb_connection_string  --no-ssl-verify   \
-u $cb_user -p  $cb_password  \
-d 'file://npidata_pfile_20050523-20221211.csv' -b 'pt_bucket' \
--scope-collection-exp "provider.nppes" -g %NPI% -t 4
```
Next we will add the 5 character zipcode and create NPI integer field that we will use for the `N1QL JOIN`. 
```sql
UPDATE pt_bucket.provider.nppes t
SET t.prov_business_zip=  SUBSTR(t.`Provider Business Practice Location Address Postal Code`,0,5);

UPDATE pt_bucket.provider.nppes t
SET t.prov_business_zip=  SUBSTR(t.`Provider Business Practice Location Address Postal Code`,0,5);
UPDATE pt_bucket.provider.nppes t
SET npi_int= TONUMBER(t.NPI);
```

# N1QL 
See the [N1QL_EXPLORE.md](N1QL_EXPLORE.md)