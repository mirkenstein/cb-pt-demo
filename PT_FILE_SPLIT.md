### Obtain MRF file from here
[https://transparency-in-coverage.uhc.com/](https://transparency-in-coverage.uhc.com/)

```shell

 jq -c --stream 'fromstream(2|truncate_stream(inputs|select(.[0][0]=="in_network")))' 2022-08-15_OptumBH_2000_OBH_Connecticare_in-network-rates.json  | gsplit -l 100000 --numeric-suffixes=1 - partA_ --additional-suffix=.json


```


### Provider Ref
```
jq -c --stream 'fromstream(2|truncate_stream(inputs|select(.[0][0]=="provider_references")))' 2022-08-15_OptumBH_2000_OBH_Connecticare_in-network-rates.json  | gsplit -l 100000 --numeric-suffixes=1 - partB_ --additional-suffix=.json
```


### Simple jq
jq '.in_network  ' 2022-08-15_OptumBH_2000_OBH_Connecticare_in-network-rates.json >simple_in_network.json
jq '.provider_references  ' 2022-08-15_OptumBH_2000_OBH_Connecticare_in-network-rates.json >simple_prov_ref.json


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


  jq '[.example."sub-example" | .[]] ' example.json 
