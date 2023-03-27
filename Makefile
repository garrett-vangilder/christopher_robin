SHELL := /bin/zsh

.PHONY: start-honey-pot
start-honey-pot:
	. honey_pot/env/bin/activate
	python -m flask --app honey_pot/app.py run
