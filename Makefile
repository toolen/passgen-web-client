repository = toolen/passgen-web-client
version = $(shell npm run version | tail -1)
image_tag = ghcr.io/$(repository):$(version)
hadolint_version=v2.14.0
trivy_version=0.68.2

image:
	make hadolint
	docker build --pull --no-cache -t $(image_tag) .
	make trivy
	make size
container:
	docker run -p 8080:80 --cap-drop=ALL --cap-add CAP_CHOWN --cap-add CAP_NET_BIND_SERVICE --cap-add CAP_SETGID --cap-add CAP_SETUID $(image_tag)
hadolint:
	docker run --rm -i ghcr.io/hadolint/hadolint:$(hadolint_version) < Dockerfile
trivy:
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v ~/.cache/trivy:/root/.cache/ ghcr.io/aquasecurity/trivy:$(trivy_version) image --ignore-unfixed $(image_tag)
size:
	docker images | grep $(repository) | grep $(version)
scan:
	trivy image $(image_tag)
push:
	docker trust sign $(image_tag)
push-to-ghcr:
	docker login ghcr.io -u toolen -p $(CR_PAT)
	docker push $(image_tag)
ci:
	npm install
	npm install -g @lhci/cli
	npm run build
	lhci autorun
