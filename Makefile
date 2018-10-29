default: test

build:
	# Build image
	docker build -t "luzifer/teamspeak3:latest" .

hadolint:
	# Execute hadolint on Dockerfile
	docker run --rm -i \
		-v "$(CURDIR):$(CURDIR)" \
		-w "$(CURDIR)" \
		hadolint/hadolint \
		hadolint --ignore=DL3008 Dockerfile

official-tests: build
	# Execute official docker-image tests
	git clone https://github.com/docker-library/official-images.git /tmp/official-images
	/tmp/official-images/test/run.sh "luzifer/teamspeak3:latest"
	rm -rf /tmp/official-images

test: hadolint official-tests

update: teamspeaki_version_update test

teamspeaki_version_update:
	docker run --rm -i \
		-v "$(CURDIR):$(CURDIR)" \
		-w "$(CURDIR)" \
		python:3-alpine \
		sh -c "pip install -r patcher/requirements.txt && python3 patcher/index.py"
