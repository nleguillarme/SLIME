# SLIME: a semantic soil-life metaweb

SLIME (Soil LIfe MEtaweb) is a knowledge graph on the trophic ecology of soil organisms that integrates several open databases covering major taxonomic groups across multiple trophic levels. SLIME allows users to find relevant information across integrated datasets and facilitates the reconstruction of local food webs based on local co-occurrence or co-abundance data.

## What does this repository contain?
(For more details on the content of these files, see https://nleguillarme.github.io/inteGraph/manual.html#create-a-new-project)
- *graph.cfg*: a INI file used to configure the URI of the knowledge graph, the path to the directory containing the data source configuration files, the triplestore connection and the ontologies that will be used to annotate the integrated data.
- *connections.json*: a JSON configuration file used for storing credentials and other information necessary for connecting to external services (e.g. the GloBi API).
- *config-morph.ini*: a INI file used to configure the [RDF materialization process](https://morph-kgc.readthedocs.io/en/latest/documentation/#configuration).
- *sources*: a directory contaning the configuration and mapping files for the different data sources.
- *graphdb*: a directory containing a Makefile to help you set up an instance of the GraphDB Free triplestore.
- *LICENSE*: a file containing the licence text.
- *README.md*: this file.

## How to build a local copy of SLIME?

### 1. Clone this repository

Clone this repository using the following command:
```bash
$ git clone https://github.com/nleguillarme/SLIME.git
```

### 2. Install inteGraph

[inteGraph](https://nleguillarme.github.io/inteGraph/) is a toolbox that helps you build and execute biodiversity data integration pipelines to create RDF knowledge graphs from multiple data sources. inteGraph pipelines are defined in configuration files. We provide one such configuration file per data source in the `sources` directory of this repository.

To install inteGraph:
1. Clone the project repository
```bash
$ git clone https://github.com/nleguillarme/inteGraph.git
```
2. Run install.sh
```bash
$ cd inteGraph ; sh install.sh
```

### 3. Download missing datasets

Some data sources do not provide an API or URL for downloading datasets programatically. You will need to download these datasets manually.

| Dataset | URL | Copy data file to |
| ------- | --- | ----------------- |
| BETSI        | [Download link](https://portail.betsi.cnrs.fr/request-traits) | SLIME/sources/betsi/data |
| FungalTraits | [Download link](https://docs.google.com/spreadsheets/d/1cxImJWMYVTr6uIQXcTLwK1YNNzQvKJJifzzNpKCM6O0/edit?usp=sharing) | SLIME/sources/fungaltraits/data |
| GlobalAnts   | [Download link](https://globalants.org/AntsDB/Entry) | SLIME/sources/global_ants/data |

After downloading the datasets, ensure that the correct file path is configured for each source (check the `[extract.file]` section in the *source.cfg* file for each source):
```ini
[extract.file]
file_path=<path-to-the-data-file>
```

### 4. Set up your triplestore

We provide a Makefile to help you set up an instance of GraphDB Free in a docker container. You will need docker, docker-compose and make installed on your machine.
1. Move to the *graphdb* directory
```bash
$ cd graphdb
```
2. Run the following command to build a docker image for GraphDB Free
```bash
$ make build
```
3. Run the following command to load the ontology into a new repository called `slime` (N.B. this may take some time)
```bash
$ make load
```
4. Start GraphDB by running the following command
```bash
$ make start
```

The GraphDB Workbench is accessible at http://localhost:7200/.

Configure the connection to the repository in the `[load]` section of *graph.cfg*:

```ini
[load]
id=graphdb
conn_type=http
host=172.17.0.1
port=7200
user=<user-login-if-any>
password=<user-password-if-any>
repository=slime
```

### 5. Run inteGraph

To run inteGraph, execute the following commands:

```bash
$ cd inteGraph
$ export INTEGRAPH__CONFIG__HOST_CONFIG_DIR=<path-to-this-repository> ; make up
```
Make sure you replace `<path-to-this-repository>` in the command with the path to your local copy of this repository.

This will start an instance of Apache Airflow, which can be found at http://localhost:8080/home.

The DAG tab lists all the pipelines generated from the configuration files:

![Airflow DAG list](https://github.com/nleguillarme/SLIME/blob/main/img/dags.png?raw=true)

### 6. Run the pipelines

To execute a pipeline, click on the Pause/Unpause DAG button on the left-hand side. Then click on the pipeline name to monitor its execution.

After triggering the pipeline, it will start running and you will see its current state represented by colors.

![Pipeline running](https://github.com/nleguillarme/SLIME/blob/main/img/running.png?raw=true)

A failed task appears in red in the interface. It’s not uncommon for tasks to fail, which could be for a multitude of reasons (e.g., an external service is down, network connectivity issues). In this situation, you can restart the pipeline from the point of failure by clicking on the failed task and then clicking on the Clear Task button in the top right-hand corner.

If the task keeps failing, you may want to examine the problem in more detail. You can access the task logs by clicking on the failed task and opening the Logs tab.

### 7. Stop inteGraph

Once all the pipelines have been run successfully, you can stop inteGraph with the following command: 
```bash
$ make down
```

## How to retrieve information from SLIME?

You can use SPARQL queries to retrieve information from SLIME. There are three ways to do this:

### 1. Using the GraphDB Workbench. 

Access the GraphDB Workbench at http://localhost:7200/. Choose SPARQL from the navigation bar, enter your query and hit Run, as shown in this example:

![SPARQL Query and Update](https://github.com/nleguillarme/SLIME/blob/main/img/sparql_workbench.png?raw=true)

### 2. Over HTTP in the REST style.

Write your SPARQL query in a file (e.g. *query.rq*) and submit it to the SPARQL endpoint using `curl`:

```bash
$ curl -H "Accept: text/csv" --data-urlencode "query@query.rq" http://0.0.0.0:7200/repositories/slime
dietName
detritivorous
fungivorous
```

### 3. Using the SLIMER package.

## How to cite SLIME?

*Coming soon.*

## How to ask for help?

*Coming soon.*
