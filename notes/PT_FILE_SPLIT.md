### Obtain MRF file from here
[https://www.bcbsil.com/member/policy-forms/machine-readable-file](https://www.bcbsil.com/member/policy-forms/machine-readable-file)
[https://transparency-in-coverage.uhc.com/](https://transparency-in-coverage.uhc.com/)
[https://www.centene.com/price-transparency-files.html](https://www.centene.com/price-transparency-files.html)
[https://www.anthem.com/machine-readable-file/search/](https://www.anthem.com/machine-readable-file/search/)
[https://mrfdata.hmhs.com/](https://mrfdata.hmhs.com/)

[https://blog.serifhealth.com/blog-posts/november-mrf-processing-notes](https://blog.serifhealth.com/blog-posts/november-mrf-processing-notes)
```shell


 jq -c --stream 'fromstream(2|truncate_stream(inputs|select(.[0][0]=="in_network")))' 2022-08-15_OptumBH_2000_OBH_Connecticare_in-network-rates.json  | gsplit -l 100000 --numeric-suffixes=1 - partA_ --additional-suffix=.json


```


### Provider Ref
```
jq -c --stream 'fromstream(2|truncate_stream(inputs|select(.[0][0]=="provider_references")))' 2022-08-15_OptumBH_2000_OBH_Connecticare_in-network-rates.json  | gsplit -l 100000 --numeric-suffixes=1 - partB_ --additional-suffix=.json
```


### Simple jq
```shell

jq -cn '.in_network  ' 2022-08-15_OptumBH_2000_OBH_Connecticare_in-network-rates.json >simple_in_network.json
jq -c '.provider_references  ' 2022-08-15_OptumBH_2000_OBH_Connecticare_in-network-rates.json >simple_prov_ref.json
```

### Anthem Index
```shell
jq  -cn --stream 'fromstream(2|truncate_stream(inputs|select(.[0][0] )))'  2022-12-01_anthem_index.json > cbload/anthem_index_lines.json
```

Remove strings after extension
```shell
for i in `ls`;do mv $i  ${i%%.gz*}.gz; done
find *.json -type f  -size -5G|while read f; do jq -c '.provider_references  ' $f >cbload/${f%.json}_prov_ref.json ;done
find *.json -type f  -size -5G|while read f; do jq -c '.in_network    ' $f >cbload/${f%.json}_prov_ref.json ;done
jq -cn '.in_network_files[].location' index1.json |while read l; do echo ${l%%.gz*};done|sort


```

Check the number of records in a file and estimate percentage of lines for the network price data.
```shell
awk '/in_network/{print NR}END{print NR}' 2022-12_254_39B0_in-network-rates_1_of_12.json
9 298 390
9 321 241
```
For smaller files we can run the JSON extraction in-memory 
```shell
 find *.json -type f |while read f; do jq -c '.provider_references  ' $f >cb_import/prov_ref/${f%.json}_prov_ref.json ;done
find *.json -type f |while read f; do jq -c '.in_network  ' $f >cb_import/in_network/${f%.json}.json ;done
```
 2022-12_400_59H0_in-network-rates.json.gz 
 2022-12_040_05C0_in-network-rates_1_of_2.json.gz 
 2022-12_280_36B0_in-network-rates.json.gz 
 2022-12_150_20B0_in-network-rates.json.gz 

##### Playground Testing jq
 cat example.json 
{
  "example": {
    "sub-example": [
      {
        "name": "123-345",
        "tag" : 100
      },
      {
        "name": "234-456",
        "tag" : 100
      },
      {
        "name": "4a7-a07a5",
        "tag" : 100
      }
    ]
  }
}


  jq  -cn '[.example."sub-example" | .[]] ' example.json 
