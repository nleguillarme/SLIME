# SLIME: a semantic soil-life metaweb

SLIME (Soil LIfe MEtaweb) is a knowledge graph on the trophic ecology of soil organisms that integrates several open databases covering major taxonomic groups across multiple trophic levels. SLIME allows users to find relevant information across integrated datasets and facilitates the reconstruction of local food webs based on local co-occurrence or co-abundance data.

## What does this repository contain?
(For more details on the content of these files, see https://nleguillarme.github.io/inteGraph/manual.html#create-a-new-project)
- *graph.cfg*: a INI file used to configure the URI of the knowledge graph, the path to the directory containing the data source configuration files, the triplestore connection and the ontologies that will be used to annotate the integrated data.
- *connections.json*: a JSON configuration file used for storing credentials and other information necessary for connecting to external services (e.g. the GloBi API).
- *config-morph.ini*: a INI file used to configure the [RDF materialization process](https://morph-kgc.readthedocs.io/en/latest/documentation/#configuration).
- *sources*: a directory contaning the configuration and mapping files for the different data sources.
- *LICENSE*: a file containing the licence text.
- *README.md*: this file.

## How to build a local copy of SLIME?

### 1. Download the datasets

Some data sources do not provide an API or URL for downloading datasets programatically. You will need to download these datasets manually.

| Dataset | URL | Copy data file to |
| ------- | --- | ----------------- |
| BETSI        | [Download link](https://portail.betsi.cnrs.fr/request-traits) | sources/betsi/data |
| FungalTraits | [Download link](https://docs.google.com/spreadsheets/d/1cxImJWMYVTr6uIQXcTLwK1YNNzQvKJJifzzNpKCM6O0/edit?usp=sharing) | sources/fungaltraits/data |
| GlobalAnts   | [Download link](https://globalants.org/AntsDB/Entry) | sources/global_ants/data |

After downloading the datasets, ensure that the correct file path is configured in each source configuration file (*source.cfg* file in the source directory):
```ini
[extract.file]
file_path=<path-to-the-data-file>
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

### 3. Set up your triplestore

We recommend that you use [GraphDB Free](https://graphdb.ontotext.com/). 
See the documentation on [how to install GraphDB](https://graphdb.ontotext.com/documentation/10.7/how-to-install-graphdb.html) as a desktop or a server application. 

Once GraphDB is installed and running, [create a new repository](https://graphdb.ontotext.com/documentation/10.7/creating-a-repository.html). Choose a name for your repository (e.g. `slime`).
Make sure you select `owl2-rl` or `owl2-rl-optimized` as the ruleset.

Configure the connection to your GraphDB instance in the `[load]` section of *graph.cfg*:

```ini
[load]
id=graphdb
conn_type=http
host=<ip-of-your-graphdb-instance>
port=7200
user=<user-login-if-any>
password=<user-password-if-any>
repository=slime
```

### 4. Run inteGraph

To run inteGraph, execute the following command:

```bash
$ make up
```
This will start an instance of Apache Airflow, which can be found at http://localhost:8080/home.

The DAG tab lists all the pipelines generated from the configuration files:

### 5. Run the pipelines

To execute a pipeline, click on the Trigger DAG button in the Actions column. Then click on the pipeline name to monitor its execution.

After triggering the pipeline, it will start running and you will see its current state represented by colors.

A failed task appears in red in the interface. It’s not uncommon for tasks to fail, which could be for a multitude of reasons (e.g., an external service is down, network connectivity issues). In this situation, you can restart the pipeline from the point of failure by clicking on the failed task and then clicking on the Clear Task button in the top right-hand corner.

If the task keeps failing, you may want to examine the problem in more detail. You can access the task logs by clicking on the failed task and opening the Logs tab.

### 6. Stop inteGraph

Once all the pipelines have been run successfully, you can stop inteGraph with the following command: 
```bash
$ make down
```

## How to retrieve information from SLIME?

## How to cite SLIME?

*Coming soon.*

## How to ask for help?

*Coming soon.*
