repository = toolen/passgen-web-client
version = $(shell cat package.json | jq -r .version)
tag = $(repository):$(version)
hadolint_version=2.8.0
trivy_version=0.21.1

image:
	make hadolint
	docker build --pull --no-cache -t $(tag) .
	make trivy
	make size
container:
	docker run -p 8080:80 --cap-drop=ALL $(tag)
hadolint:
	docker run --rm -i hadolint/hadolint:$(hadolint_version) < Dockerfile
trivy:
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v ~/.cache/trivy:/root/.cache/ aquasec/trivy:$(trivy_version) --ignore-unfixed $(tag)
size:
	docker images | grep $(repository) | grep $(version)
scan:
	trivy image $(tag)
push:
	docker trust sign $(tag)

