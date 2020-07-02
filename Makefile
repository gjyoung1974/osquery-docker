all:  osqueryds

# IMAGE := quay.io/postmates/osqueryds:latest
IMAGE := gjyoung1974/osqueryds:latest

osqueryds:
	docker build --pull --rm --label org.label-schema.vcs-url=https://github.com/postmates/pi-k8s.git  -f "Dockerfile" --tag $(IMAGE) "."

push:
	docker push $(IMAGE)
