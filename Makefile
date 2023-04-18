.PHONY: libstrophe

fetch-dependencies:
	@scripts/fetch-dependencies.sh

libstrophe: fetch-dependencies
	@scripts/build-libstrophe.sh

client: libstrophe
	@scripts/build-core-client.sh