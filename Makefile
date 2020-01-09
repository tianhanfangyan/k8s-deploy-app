APP?=k8s-deploy-app
NAMESPACE?=<namespace>
GROUP?=<group>
REGISTRY_PREFIX?=<registry_prefix>
PROJECT?=${REGISTRY_PREFIX}/${GROUP}/${APP}
URLDOMAIN?=<urldomain>
SECRETS?=<secrets>

RELEASE?=$(shell git describe --tags --abbrev=0 --exact-match 2>/dev/null || echo "latest")
COMMIT?=$(shell git rev-parse --short HEAD)
BUILT?=$(shell date +"%Y-%m-%d_%H:%M:%S_%Z")

SERVICE_NAME=$(shell if [[ -z "${STAGE}" ]]; then echo "${APP}"; else echo "${APP}-${STAGE}"; fi)
CONTAINER_IMAGE?=${REGISTRY_PREFIX}/${GROUP}/${APP}:${RELEASE}

image:
	docker build -t ${CONTAINER_IMAGE} .

push: image
	docker push ${CONTAINER_IMAGE}

kube-gen:
	for t in $(shell find ./kubernetes -type f -name "*.yaml"); do \
		cat $$t | \
			sed -E "s/\{\{(\s*)\.RegistryPrefix(\s*)\}\}/${REGISTRY_PREFIX}/g" | \
			sed -E "s/\{\{(\s*)\.NameSpace(\s*)\}\}/${NAMESPACE}/g" | \
			sed -E "s/\{\{(\s*)\.Group(\s*)\}\}/${GROUP}/g" | \
			sed -E "s/\{\{(\s*)\.App(\s*)\}\}/${APP}/g" | \
			sed -E "s/\{\{(\s*)\.Release(\s*)\}\}/${RELEASE}/g" | \
			sed -E "s/\{\{(\s*)\.UrlDomain(\s*)\}\}/${URLDOMAIN}/g" | \
			sed -E "s/\{\{(\s*)\.Secrets(\s*)\}\}/${SECRETS}/g" | \
			sed -E "s/\{\{(\s*)\.ServiceName(\s*)\}\}/${SERVICE_NAME}/g"; \
		echo ---; \
	done > tmp.yaml

kube-deploy: kube-gen
	kubectl --namespace ${NAMESPACE} apply -f tmp.yaml
