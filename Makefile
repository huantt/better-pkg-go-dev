build-docker:
	docker build -t huanttok/pkggo:$(v) . && docker push huanttok/pkggo:$(v)