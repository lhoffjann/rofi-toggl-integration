#!/bin/bash

cwd=$(echo $(dirname $0))


config_file="$HOME/.config/i3/uni-tasks.json"
tasks=$(cat $config_file)
echo $tasks

#Pass tasks to rofi, and get the output as the selected option
selected=$(echo $tasks | jq -j 'map(.name) | join("\n")' | rofi -dmenu -matching fuzzy -i -p "Search tasks")
task=$(echo $tasks | jq ".[] | select(.name == \"$selected\")")

if [[ $task == "" ]]; then
  echo "No task defined as '$selected' within config file."
  exit 1
fi


task_name=$(echo $task | jq ".name")
echo $task_name
