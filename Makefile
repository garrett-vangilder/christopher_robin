SHELL := /bin/zsh

.PHONY: start-honey-pot
start-honey-pot:
	. honey_pot/env/bin/activate
	python -m flask --app honey_pot/app.py run

prepare-data-ingest:
	cd data_ingest && pip install -r requirements.txt
	cd .. && zip -r data_ingest.zip data_ingest
