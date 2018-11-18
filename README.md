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
- Download jar files built by travis-CI from [releases](releases)
- Copy both `lire.jar` and `liresolr.jar` to `/opt/solr/server/solr-webapp/webapp/WEB-INF/lib/`
- restart solr

These jar files are already included in `soruly/sola`

### Developing
- Linux: `./gradlew distForSolr`
- Windows: `gradlew.bat distForSolr`

In `./dist` folder, you can find the compiled jar files

### Usage
#### Iterative search
The default behavior from dermotte/liresolr uses last n% of query terms as accuracy

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

#### Search by file upload
Just POST files in binary format without any file/url parameters
```
/lireq?&field=cl_ha&ms=false&accuracy=0&candidates=100000
```
