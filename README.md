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

### 1. Set up your triplestore

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

## How to retrieve information from SLIME?

## How to cite SLIME?

## How to ask for help?
