ECR_REGISTRY = 867457178744.dkr.ecr.eu-west-1.amazonaws.com
ECR_REPO     = tech-test-images
IMAGE_TAG    ?= latest

.PHONY: ecr-login build push

ecr-login:
	aws ecr get-login-password --region eu-west-1 | \
		docker login --username AWS --password-stdin $(ECR_REGISTRY)

build:
	docker build -t $(ECR_REGISTRY)/$(ECR_REPO):$(IMAGE_TAG) ./app

push: ecr-login build
	docker push $(ECR_REGISTRY)/$(ECR_REPO):$(IMAGE_TAG)
