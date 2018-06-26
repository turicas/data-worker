#!/bin/bash

exec_prepare() {
	git_url=$1
	code_path=$2

	rm -rf "$code_path"
	git clone "$git_url" "$code_path"
	cp Dockerfile .dockerignore runtime.txt "$code_path"
}

exec_build() {
	image=$1
	code_path=$2

	docker build --tag "$image" "$code_path"
}

exec_delete() {
	image=$1

	docker rmi "$image"
}

exec_run() {
	image=$1
	data_path=$2

	docker run --user=$(id -u) --interactive --tty --rm \
               --volume=$data_path:/app/data/ $image
}

exec_all() {
	git_url=$1
	image=$2
	code_path=$3
	data_path=$4

	exec_prepare "$git_url" "$code_path"
	exec_build "$image" "$code_path"
	exec_run "$image" "$data_path"
}

USAGE="ERROR - Usage: $0 <build|delete|run|all> [parameters]"

if [ -z "$1" ]; then
	echo "$USAGE"
	exit 1

elif [ "$1" = "build" ]; then
	if [ -z "$3" ]; then
		echo "ERROR - Usage: $0 build <image-name> <script-path>"
		exit 1
	else
		exec_build "$2" "$3"
	fi

elif [ "$1" = "delete" ]; then
	if [ -z "$2" ]; then
		echo "ERROR - Usage: $0 delete <image-name>"
		exit 1
	else
		exec_delete "$2"
	fi

elif [ "$1" = "run" ]; then
	if [ -z "$3" ]; then
		echo "ERROR - Usage: $0 run <image-name> <host-data-path>"
		exit 1
	else
		exec_run "$2" "$3"
	fi

elif [ "$1" = "all" ]; then
	if [ -z "$5" ]; then
		echo "ERROR - Usage: $0 all <git-url> <image-name> <host-code-path> <host-data-path>"
		exit 1
	else
		exec_all "$2" "$3" "$4" "$5"
	fi

else
	echo "$USAGE"
	exit 2
fi
