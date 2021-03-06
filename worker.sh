#!/bin/bash

set -e

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

  if [ "$(docker images --quiet $image 2> /dev/null)" != "" ]; then
    # TODO: we may add this as an option
    echo "***** Removing old docker image $image to build the new one"
    docker rmi "$image"
  fi
  docker build --tag "$image" "$code_path"
}

exec_delete() {
  image=$1

  docker rmi "$image"
}

exec_run() {
  image=$1
  data_path=$2

  docker run --interactive --tty --rm --volume=$data_path:/app/data/ $image
}

exec_all() {
  temp_dir=$(mktemp -d)
  echo -e "***** Working on $temp_dir"

  git_url=$1
  project_name=$(basename $(echo $git_url | sed 's/\.git//' ))
  code_path=$temp_dir/code
  data_path=$temp_dir/data

  echo -e "\n\n***** Cloning repository to $code_path"
  exec_prepare "$git_url" "$code_path"

  git_commit=$(cd $code_path && git rev-parse HEAD)
  image=$USER/$project_name:${git_commit:0:8}
  echo -e "\n\n***** Building image $image"
  exec_build "$image" "$code_path"

  echo -e "\n\n***** Running image $image"
  exec_run "$image" "$data_path"

  echo -e "\n\n***** Done! Access your files in: $data_path"
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
  if [ -z "$2" ]; then
    echo "ERROR - Usage: $0 all <git-url>"
    exit 1
  else
    exec_all "$2"
  fi

else
  echo "$USAGE"
  exit 2
fi
