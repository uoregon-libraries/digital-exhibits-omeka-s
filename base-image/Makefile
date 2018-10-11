-include env_make

build:
        docker build --rm -f Dockerfile -t $(APP_NAME) .

# Docker tagging
tag: tag-latest tag-version ## Generate container tags for the `{version}` ans `latest` tags

tag-latest: ## Generate container `{version}` tag
        @echo 'create tag latest'
        docker tag $(APP_NAME) $(APP_NAME):latest

tag-version: ## Generate container `latest` tag
        @echo 'create tag $(APP_VERSION)-$(IMAGE_VERSION)'
        docker tag $(APP_NAME) $(APP_NAME):$(APP_VERSION)-$(IMAGE_VERSION)
