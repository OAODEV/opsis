IMAGE_REPO = us.gcr.io/lexical-cider-93918
COMMIT := $(shell git rev-parse --short HEAD)
PRODUCT_NAME = opsis
IMAGE_TAG = $(IMAGE_REPO)/$(PRODUCT_NAME):$(COMMIT)
TEST_COMMAND = "pytest ."
LISTEN_PORT = 5000


.PHONY: build
build:
	docker build -t $(IMAGE_TAG) .


.PHONY: local-test
local-test: build
	docker run -it $(IMAGE_TAG) $(TEST_COMMAND)


.PHONY: deploy-team
deploy-team: test
	gcloud container get-credentials playground
	gcloud docker -- push $(IMAGE_TAG)
	kubectl run $(PRODUCT_NAME) --image=$(IMAGE_TAG) --port=$(LISTEN_PORT)
	kubectl expose deployment $(PRODUCT_NAME) --port=80 --target-port=$(LISTEN_PORT)


.PHONY: clean-team
clean-team: three # three replaces the venv with a new python3 venv
	gcloud container get-credentials playground
	-kubectl delete deployment $(PRODUCT_NAME)
	-kubectl delete service $(PRODUCT_NAME)


.PHONY: install
install: build
	docker run -it -v $(shell pwd):$(shell docker run $(IMAGE_TAG) pwd) $(IMAGE_TAG) pipenv install $(PACKAGE)


.PHONY: uninstall
uninstall: buld
	docker run -it -v $(shell pwd):$(shell docker run $(IMAGE_TAG) pwd) $(IMAGE_TAG) pipenv uninstall $(PACKAGE)


.PHONY: lock
lock: buld
	docker run -it -v $(shell pwd):$(shell docker run $(IMAGE_TAG) pwd) $(IMAGE_TAG) pipenv lock


.PHONY: build
three: build
	docker run -it -v $(shell pwd):$(shell docker run $(IMAGE_TAG) pwd) $(IMAGE_TAG) pipenv --three
