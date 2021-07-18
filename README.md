## liresolr

[![Build Status](https://travis-ci.org/soruly/liresolr.svg?branch=master)](https://travis-ci.org/soruly/liresolr)

This is a fork of [dermotte/liresolr](https://github.com/dermotte/liresolr) customized for [soruly/sola](https://github.com/soruly/sola)

### Changes in this fork
- Removed all default feature class from ParallelSolrIndexer to speed up indexing
- Instead of using last n% of query terms, search query terms one by one

### Additional Features
- Search by file path
- Analyze image by file path
- Search by file upload (HTTP POST)

### Requirements
- openJDK-1.8.0 or Java JDK 8
- [Apache Solr 7](http://lucene.apache.org/solr/)

### Installing
- Download jar files built by travis-CI from [GitHub Releases](https://github.com/soruly/liresolr/releases)
- Copy both `lire.jar` and `liresolr.jar` to `/opt/solr/server/solr-webapp/webapp/WEB-INF/lib/`
- restart solr

These jar files are already included in `soruly/sola`

### Developing
- Linux: `./gradlew distForSolr`
- Windows: `gradlew.bat distForSolr`

In `./dist` folder, you can find the compiled jar files

-  **ph** .. PHOG (pyramid histogram of oriented gradients)
-  **oh** .. OpponentHistogram (simple color his    togram in the opponent color space)
-  **cl** .. ColorLayout (from MPEG-7)
-  **sc** .. ScalableColor (from MPEG-7)
-  **eh** .. EdgeHistogram (from MPEG-7)
-  **ce** .. CEDD (very compact and accurate joint descriptor)
-  **fc** .. FCTH (more accurate, less compact than CEDD)
-  **jc** .. JCD (joined descriptor of CEDD and FCTH)
-  **ac** .. AutoColorCorrelogram (color to color correlation histogram)
-  **pc** .. SPCEDD (pyramid histogram of CEDD)
-  **fo** .. FuzzyOpponentHistogram (fuzzy color histogram)
-  **sf** .. GenericGlobalShortFeature (generic feature used to search for deep features in LireSolr)

For example, with terms A, B, C, D, E, F, G, H in ascending order of popularity:

dermotte/liresolr:
- accuracy 0.125 means search in A
- accuracy 0.250 means search in A+B
- accuracy 0.375 means search in A+B+C

soruly/liresolr:
- accuracy 0 means search in A
- accuracy 1 means search in B
- accuracy 2 means search in C
```
/lireq?&field=cl_ha&ms=false&url=https://url-to/image.jpg&accuracy=0&candidates=100000
```
Given that most corrent search results (>90%) can be found with just one term. The iterative approach search is faster on average as it has reduced search space. Applications can decide when to stop searching. If the first search is not good enough, it can search again in next query term.

#### Search by file path
Just POST files in binary format without any file/url parameters
```
/lireq?&field=cl_ha&ms=false&file=/path/to/image.jpg&accuracy=0&candidates=100000
```

Parameters:

-   **rows** ... indicates how many results should be returned (optional, default=60). Example: lireq?rows=30

Search by ID
------------
Returns images that look like the one with the given ID.

Parameters:

-   **id** .. the ID of the image used as a query as stored in the "id" field in the index.
-   **field** .. gives the feature field to search for (optional, default=cl_ha, values see above)
-   **rows** .. indicates how many results should be returned (optional, default=60).
-   **ms** .. prefer MetricSpaces over BitSampling (optional, default=false).
-   **accuracy** .. double in [0.05, 1] indicates how many accurate the results should be (optional, default=0.33, less is less accurate, but faster).
-   **candidates** .. int in [100, 100000] indicates how many accurate the results should be (optional, default=10000, less is less accurate, but faster).

Search by URL
-------------
Returns images that look like the one found at the given URL.

Parameters:

-   **url** .. the URL of the image used as a query. Note that the image has to be accessible by the web server Java has to be able to read it.
-   **field** .. gives the feature field to search for (optional, default=cl_ha, values see above)
-   **rows** .. indicates how many results should be returned (optional, default=60).
-   **ms** .. prefer MetricSpaces over BitSampling (optional, default=false).
-   **accuracy** .. double in [0.05, 1] indicates how many accurate the results should be (optional, default=0.33, less is less accurate, but faster).
-   **candidates** .. int in [100, 100000] indicates how many accurate the results should be (optional, default=10000, less is less accurate, but faster).

Search by feature vector
------------------------
Returns an image that looks like the one the given features were extracted. This method is used if the client extracts the features from the image, which makes sense if the image should not be submitted.

Parameters:

-   **hashes** .. Hashes of the image feature as returned by BitSampling#generateHashes(double[]) as a String of white space separated numbers.
-   **feature** .. Base64 encoded feature histogram from LireFeature#getByteArrayRepresentation().
-   **field** .. gives the feature field to search for (optional, default=cl_ha, values see above)
-   **rows** .. indicates how many results should be returned (optional, default=60).
-   **ms** .. prefer MetricSpaces over BitSampling (optional, default=false).
-   **accuracy** .. double in [0.05, 1] indicates how many accurate the results should be (optional, default=0.33, less is less accurate, but faster).
-   **candidates** .. int in [100, 100000] indicates how many accurate the results should be (optional, default=10000, less is less accurate, but faster).

#### Examples: 
    /lireq?feature=FQY5Cw8PDRQQEBEUEg4MDREQEA0OEREgEBAQEBAgEBAQEBA=&hashes=df0%20d5e%20726%205cf%204c6%20d58%2025b%2050b%202%20d%2041f%2022c%20985%208aa%20a42%2014f%20571%20b67%2077d%2025d%20210%205cb...&field=cl

Extracting histograms
---------------------
Extracts the histogram and the hashes of an image for use with the Lire sorting function. It will give you hashes and a truncated query for BitSampling (`bs_list` and `bs_query`) and MetricSpaces (`ms_list` and `ms_query`), but the latter only if it's available. the return values for `bs_list` and `ms_list` are ordered by ascending document frequency (BitSampling) and distance from the image to the respective reference point. 

This can also be used to convert generic feature like the ones used for deep features, into base64 encoded feature strings and to obtain the appropriate queries for hashing based queries. If the field is sf_ha (or just sf), it is assumed that the extract parameter contains a comma separated list of doubles to be converted in a GenericGlobalShortFeatureVector.


Parameters:

-   **extract** .. the URL of the image. Note that the image has to be accessible by the web server Java has to be able to read it.
-   **field** .. gives the feature field to search for (optional, default=cl_ha, values see above, works also without the `_ha` suffix.)
-   **accuracy** .. double in [0.05, 1] indicates how many query terms should be in the queries (optional, default=0.33).

#### Examples: 
Extraction from an image file:

    lireq?extract=http://url.to/image.png&field=eh
   
results in 

    {
      "responseHeader":{
        "status":0,
        "QTime":141,
        "params":{
          "q":"*:*",
          "extract":"http://localhost:8983/solr/test/US76287460.png",
          "field":"eh",
          "_":"1544015258504"}},
      "histogram":"s7PQsraSkuCAkbG0xMPkk7PAgICww6K01YKRkICAosTSxMeFtOGjpQ==",
      "bs_list":["957","a26", "4a2", "276", ... ],
      "bs_query":"957 a26 4a2 276 e19 bf0 8b9 b2 ...",
      "ms_list":["R001902", "R001640", "R000511", ...],
      "ms_query":"R001902^1.00 R001640^0.88 ..."
      }

Extraction from a double histogram:

    lireq?extract=0,0,0,1,1,1,1&field=sf

results in 

    {
      "responseHeader": {
        "status": 0,
        "QTime": 2,
        "params": {
          "q": "*:*",
          "extract": "0,0,0,1,1,1,1",
          "field": "sf",
          "_": "1544015258504"
        }
      },
      "histogram": "AAAAAAAAAf8B\/wH\/Af8=",
      "bs_list": ["cd2", "2a5", "612", "d8", "510", "3e1", "d95", ...
      ],
      "bs_query": "cd2 2a5 612 d8 510 ..."
    }


Function queries with lirefunc
-------------------------------
The function `lirefunc(arg1,arg2)` is available for function queries. Two arguments are necessary and are defined as:

-  Feature to be used for computing the distance between result and reference image. Possible values are {cl, ph, eh, jc}
-  Actual Base64 encoded feature vector of the reference image. It can be obtained by calling `LireFeature.getByteRepresentation()` and by Base64 encoding the resulting byte[] data or by using the extract feature of the `RequestHandler`
-  Optional maximum distance for those data items that cannot be processed, ie. don't feature the respective field.

Note that if you send the parameters using an URL you might take extra care of the URL encoding, ie. white space, the "=" sign, etc.

Examples:

-  `[solrurl]/select?q=*:*&fl=id,lirefunc(cl,"FQY5DhMYDg...AQEBA=")` – adding the distance to the reference image to the results
-  `[solrurl]/select?q=*:*&sort=lirefunc(cl,"FQY5DhMYDg...AQEBA=")+asc` – sorting the results based on the distance to the reference image

If you extract the features yourself, use code like his one:

    // ColorLayout
    ColorLayout cl = new ColorLayout();
    cl.extract(ImageIO.read(new File("...")));
    String arg1 = "cl";
    String arg2 = Base64.getEncoder().encodeToString(cl.getByteArrayRepresentation());

    // PHOG
    PHOG ph = new PHOG();
    ph.extract(ImageIO.read(new File("...")));
    String arg1 = "ph";
    String arg2 = Base64.getEncoder().encodeToString(ph.getByteArrayRepresentation());
    
If you experiencing problems with a query having always the same results after changing the lirefunc parameters, you have to disable the cache of ordered search results by setting the size of the `queryResultCache`to `0`. The downside of this approach is that for paging the query has to be run through Solr over and over again.

    <queryResultCache class="solr.LRUCache"
                      size="0"
                      initialSize="0"
                      autowarmCount="0"/>


Installation
============

We assume you have a Solr server installed and running and you have already added a core. If not, check [src/main/docs/install.md](src/main/docs/install.md) or don't even try but go for the docker image. First run the dist task by `gradlew distForSolr` command in folder where the `build.gradle` file is found to create a plugin jar. Then copy jars: `cp ./dist/*.jar /opt/solr/server/solr-webapp/webapp/WEB-INF/lib/`. Then add the new `RequestHandler` and the `ValueSourceParser` have to be registered in the `solrconfig.xml` file:

    <requestHandler name="/lireq" class="net.semanticmetadata.lire.solr.LireRequestHandler">
        <lst name="defaults">
            <str name="echoParams">explicit</str>
            <str name="wt">json</str>
            <str name="indent">true</str>
        </lst>
    </requestHandler>
     
    <valueSourceParser name="lirefunc" 
        class="net.semanticmetadata.lire.solr.LireValueSourceParser" />

Use of the request handler is detailed above.

You'll also need the respective fields in the `managed-schema` file:

    <!-- file path for ID, should be there already -->
    <field name="id" type="string" indexed="true" stored="true" required="true" multiValued="false" />
    <!-- the title of the image, e.g. the file name, optional -->
    <field name="title" type="text_general" indexed="true" stored="true" multiValued="true"/>
    <!-- the url where the image is to be downloaded, optional  -->
    <field name="imgurl" type="string" indexed="true" stored="true" multiValued="false"/>
    <!-- Dynamic fields for LIRE Solr -->
    <dynamicField name="*_ha" type="text_ws" indexed="true" stored="false"/> <!-- if you are using BitSampling --> 
    <dynamicField name="*_ms" type="text_ws" indexed="true" stored="false"/> <!-- if you are using Metric Spaces Indexing -->
    <dynamicField name="*_hi" type="binaryDV" indexed="false" stored="true"/>

Do not forget to add the custom field at the very same file:

    <fieldtype name="binaryDV" class="net.semanticmetadata.lire.solr.BinaryDocValuesField"/>


Indexing
========

Check `ParallelSolrIndexer.java` for indexing. It creates XML documents (either one per image or one single large file)
to be sent to the Solr Server.

ParallelSolrIndexer
-------------------
This help text is shown if you start the ParallelSolrIndexer with the '-h' option.

    $> ParallelSolrIndexer -i <infile> [-o <outfile>] [-n <threads>] [-f] [-p] [-m <max_side_length>] [-r <full class name>] \\
             [-y <list of feature classes>]

Note: if you don't specify an outfile just ".xml" is appended to the input image for output. So there will be one XML
file per image. Specifying an outfile will collect the information of all images in one single file.

- *-n* ... number of threads should be something your computer can cope with. default is 4.
- *-f* ... forces overwrite of outfile
- *-p* ... enables image processing before indexing (despeckle, trim white space)
- *-a* ... use both BitSampling and MetricSpaces.
- *-l* ... disables BitSampling and uses MetricSpaces instead.
- *-m* ... maximum side length of images when indexed. All bigger files are scaled down. default is 512.
- *-r* ... defines a class implementing net.semanticmetadata.lire.solr.indexing.ImageDataProcessor
       that provides additional fields.
- *-y* ... defines which feature classes are to be extracted. default is "-y ph,cl,eh,jc". "-y ce,ac" would
       add to the other four features.

INFILE
------
The infile gives one image per line with the full path. You can create an infile easily on Windows with running in the
parent directory of the images

    $> dir /s /b *.jpg > infile.txt

On linux just use find, grep and whatever you find appropriate. With find it'd look like this assuming that you run it
from the root directory:

    $> find /[path-to-image-base-dir]/ -name *.jpg

OUTFILE
-------
The `outfile` from `ParallelIndexer` has to be send to the Solr server. Assuming the Solr server is local you may use

    $> curl http://localhost:8983/solr/lire/update -H "Content-Type: text/xml" --data-binary "<delete><query>*:*</query></delete>"
    $> curl http://localhost:8983/solr/lire/update -H "Content-Type: text/xml" --data-binary @outfile.xml
    $> curl http://localhost:8983/solr/lire/update -H "Content-Type: text/xml" --data-binary "<commit/>"

You need to commit you changes! If your outfile exceeds 500MB, curl might complain. Then use split to cut it into pieces and repair the root tags (`<add>` and `</add>`). Here is an example how to do that with bash & linux (use *Git Bash* on Windows) under the assumption that the split leads to files *{0, 1, 2, ..., n}*

```
/lireq?&field=cl_ha&ms=false&accuracy=0&candidates=100000
```

For small output files you may use the file upload option in the Solr admin interface. 

LireEntityProcessor
-------------------

Another way is to use the LireEntityProcessor. Then you have to reference the *solr-data-config.xml* file in the
*solrconfig.xml*, and then give the configuration for the EntityProcessor like this:

    <dataConfig>
        <dataSource name ="bin" type="BinFileDataSource" />
        <document>
            <entity name="f"
                    processor="FileListEntityProcessor"
                    transformer="TemplateTransformer"
                    baseDir="D:\Java\Projects\Lire\testdata\wang-1000\"
                    fileName=".*jpg"
                    recursive="true"
                    rootEntity="false" dataSource="null" onError="skip">
                <entity name="lire-test" processor="net.semanticmetadata.lire.solr.LireEntityProcessor" url="${f.fileAbsolutePath}" dataSource="bin"  onError="skip">
                    <field column="id"/>
                    <field column="cl_ha"/>
                    <field column="cl_hi"/>
                    <field column="ph_ha"/>
                    <field column="ph_hi"/>
                    <field column="oh_ha"/>
                    <field column="oh_hi"/>
                    <field column="jc_ha"/>
                    <field column="jc_hi"/>
                    <field column="eh_ha"/>
                    <field column="eh_hi"/>
                </entity>
            </entity>
        </document>
    </dataConfig>

*Mathias Lux, 2018-12-01*
