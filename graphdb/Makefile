clear-docker:
	rm -rf graphdb-docker

clear-data:
	rm -rf graphdb-data

clear-import:
	rm -rf import

clear: clear-docker clear-data clear-import

build:
	git clone https://github.com/Ontotext-AD/graphdb-docker.git
	cd graphdb-docker ; docker-compose build

import:
	mkdir -p import
	curl -L https://github.com/nleguillarme/soil_food_web_ontology/releases/latest/download/sfwo.owl --output import/sfwo.owl
	# curl -L https://github.com/obophenotype/ncbitaxon/releases/latest/download/ncbitaxon.owl --output import/ncbitaxon.owl

load:
	cd load ; docker compose --env-file ../graphdb.params -f docker-compose.yml up
	
start:
	cp docker-compose.yml ./graphdb-docker
	cd ./graphdb-docker ; docker compose --env-file ../graphdb.params -f docker-compose.yml up

stop:
	cd ./graphdb-docker ; docker compose --env-file ../graphdb.params -f docker-compose.yml down

.PHONY: clear-docker clear-data clear-import clear build import load start stop
