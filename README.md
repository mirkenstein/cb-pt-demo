### Obtain MRF file from here
Here are the direct urls for the Price Transparency data for some of the healthcare payers.  

[https://www.bcbsil.com/member/policy-forms/machine-readable-file](https://www.bcbsil.com/member/policy-forms/machine-readable-file)
[https://transparency-in-coverage.uhc.com/](https://transparency-in-coverage.uhc.com/)
[https://www.centene.com/price-transparency-files.html](https://www.centene.com/price-transparency-files.html)
[https://www.anthem.com/machine-readable-file/search/](https://www.anthem.com/machine-readable-file/search/)
[https://mrfdata.hmhs.com/](https://mrfdata.hmhs.com/)

[https://blog.serifhealth.com/blog-posts/november-mrf-processing-notes](https://blog.serifhealth.com/blog-posts/november-mrf-processing-notes)

First we would download the index file which contains the links to all the actual MRF files.
One way extract the urls is via the `jq`

```shell
jq '.reporting_structure[].in_network_files[]?.location' index_file.json
```
or if the file is exceedingly large we can use the `jq` stream option  
```shell
jq  -cn --stream 'fromstream(2|truncate_stream(inputs|select(.[0][0] )))'   large_index.json > large_index_lines.json
```
The command above splits the index file into individual items lines that are convenient to load into couchbase.


