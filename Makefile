.PHONY: docker-build build

build: docker-build

docker-build:
	docker build -t binded/python-opencv .
