ifndef DATA_PATH
$(error DATA_PATH is not set. Example, make push DATA_PATH=eodata_paths/Landsat-5.paths)
endif

ifndef DATA_SAMPLE_SIZE
$(info Using default DATA_SAMPLE_SIZE=1000)
DATA_SAMPLE_SIZE = 1000
endif

DATA_NAME ?= $(shell basename $(DATA_PATH) | cut -d. -f1)
PREFIX = $(shell git config --get remote.origin.url | tr ':.' '/'  | rev | cut -d '/' -f 3 | rev)
REPO_NAME = $(shell git config --get remote.origin.url | tr ':.' '/'  | rev | cut -d '/' -f 2 | rev)

# Linux and macos compatibility
MD5_COMMAND = $(shell type -p md5sum || type -p md5)
DATA_HASH = $(shell md5 -q $(DATA_PATH) 2>/dev/null ||  md5sum $(DATA_PATH) | cut -d' ' -f1)

BUILD_DATE = $(shell date +'%y.%m.%d' | $(MD5_COMMAND) )
NUMBER_OF_FILES=$(shell wc -l $(DATA_PATH) | cut -d' ' -f1)

DATA_LATEST = $(PREFIX)/$(REPO_NAME):$(DATA_NAME)-latest
DATA_TAGED = $(PREFIX)/$(REPO_NAME):$(DATA_NAME)-$(DATA_HASH)
DATA_SAMPLE_LATEST = $(PREFIX)/$(REPO_NAME):$(DATA_NAME)-sample-latest
DATA_SAMPLE_TAGED = $(PREFIX)/$(REPO_NAME):$(DATA_NAME)-sample-$(DATA_HASH)

all: push

push: push-data-sample push-data
images: image-data-sample image-data

data-sample: image-data-sample
data: image-data

image-data-sample:
	echo "*" > .dockerignore
	echo "!paths-sample" >> .dockerignore
	echo $(DATA_HASH)
	head -n $(DATA_SAMPLE_SIZE) $(DATA_PATH) > paths-sample
	docker build --build-arg PATHS_FILE=paths-sample --build-arg NUMBER_OF_FILES=$(DATA_SAMPLE_SIZE) -t $(DATA_SAMPLE_LATEST) . # Build new image and automatically tag it as latest
	docker tag $(DATA_SAMPLE_LATEST) $(DATA_SAMPLE_TAGED)  # Add the version tag to the latest image

image-data:
	docker build --build-arg PATHS_FILE=$(DATA_PATH) --build-arg NUMBER_OF_FILES=$(NUMBER_OF_FILES) -t $(DATA_LATEST) . # Build new image and automatically tag it as latest
	docker tag $(DATA_LATEST) $(DATA_TAGED)  # Add the version tag to the latest image

push-data: image-data
	docker push $(DATA_LATEST) # Push image tagged as latest to repository
	docker push $(DATA_TAGED) # Push version tagged image to repository (since this image is already pushed it will simply create or update version tag)

push-data-sample: image-data-sample
	docker push $(DATA_SAMPLE_LATEST) # Push image tagged as latest to repository
	docker push $(DATA_SAMPLE_TAGED) # Push version tagged image to repository (since this image is already pushed it will simply create or update version tag)

clean:
	rm paths-sample
	rm .dockerignore
