IMAGE_REPO = us.gcr.io/lexical-cider-93918
COMMIT := $(shell git rev-parse --short HEAD)
PRODUCT_NAME = opsis
IMAGE_TAG = $(IMAGE_REPO)/$(PRODUCT_NAME):$(COMMIT)
TEST_COMMAND = pytest .
LISTEN_PORT = 5000


.PHONY: build
build:
	docker build -t $(IMAGE_TAG) .


.PHONY: local-test
local-test: build
	docker run -it $(IMAGE_TAG) $(TEST_COMMAND)


.PHONE: playground
playground:
	gcloud container clusters get-credentials playground

.PHONY: deploy-team
deploy-team: local-test playground
	gcloud docker -- push $(IMAGE_TAG)
	kubectl run $(PRODUCT_NAME) --image=$(IMAGE_TAG) --port=$(LISTEN_PORT)
	kubectl expose deployment $(PRODUCT_NAME) --port=80 --target-port=$(LISTEN_PORT)


.PHONY: clean-team
clean-team: playground
	-docker rmi $(IMAGE_TAG)
	-kubectl delete deployment $(PRODUCT_NAME)
	-kubectl delete service $(PRODUCT_NAME)
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
