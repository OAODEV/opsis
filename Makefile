IMAGE_REPO = us.gcr.io/lexical-cider-93918
COMMIT := $(shell git rev-parse --short HEAD)
SERVICE_NAME = opsis
SYSTEM_NAME = reporting-platform
IMAGE_TAG = $(IMAGE_REPO)/$(SERVICE_NAME):$(COMMIT)
TEST_COMMAND = pytest .
LISTEN_PORT = 5000
CLUSTER = playground


.PHONY: build
build:
	docker build -t $(IMAGE_TAG) .


.PHONY: local-test
local-test: build
	docker run -it $(IMAGE_TAG) $(TEST_COMMAND)


.PHONE: cluster
cluster:
	gcloud container clusters get-credentials $(CLUSTER)

.PHONY: deploy-team
deploy-team: local-test cluster
	gcloud docker -- push $(IMAGE_TAG)
	kubectl run $(SERVICE_NAME) --image=$(IMAGE_TAG) --port=$(LISTEN_PORT)
	kubectl expose deployment $(SERVICE_NAME) --port=80 --target-port=$(LISTEN_PORT)


.PHONY: clean-team
clean-team: cluster
	-docker rmi $(IMAGE_TAG)
	-kubectl delete deployment $(SERVICE_NAME)
	-kubectl delete service $(SERVICE_NAME)
	-rm -rf .venv


.PHONY: install
install: build
	docker run -it -v $(shell pwd):$(shell docker run $(IMAGE_TAG) pwd) $(IMAGE_TAG) pipenv install $(PACKAGE)


.PHONY: uninstall
uninstall: build
	docker run -it -v $(shell pwd):$(shell docker run $(IMAGE_TAG) pwd) $(IMAGE_TAG) pipenv uninstall $(PACKAGE)


.PHONY: lock
lock: build
	docker run -it -v $(shell pwd):$(shell docker run $(IMAGE_TAG) pwd) $(IMAGE_TAG) pipenv lock


.venv: build
	docker run -it -v $(shell pwd):$(shell docker run $(IMAGE_TAG) pwd) $(IMAGE_TAG) pipenv --three
