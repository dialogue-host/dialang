.DEFAULT_GOAL := re
SHELL:=/bin/bash
PORT:=8000

re : build run

build :
	${SHELL} src/bin/build.sh

run :
	${SHELL} src/bin/run.sh

doc :
	elm-doc-preview .
