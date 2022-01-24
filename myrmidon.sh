#!/bin/bash
cwd=$(echo $(dirname $0))

# Use ~/.myrmidon-tasks.json as default, otherwise use incoming path
config_file="${1:-"$HOME/.myrmidon-tasks.json"}"
tasks=$(cat $config_file)


# Pass tasks to rofi, and get the output as the selected option
selected=$(echo $tasks | jq -j 'map(.name) | join("\n")' | rofi -dmenu -matching fuzzy -i -p "Search tasks")
task=$(echo $tasks | jq -j ".[] | select(.name == \"$selected\")")

# Exit if no task was found
if [[ $task == "" ]]; then
  echo "No task defined as '$selected' within config file."
  exit 1
fi

command_name=$(echo $task | jq -j ".name")
task_command=$(echo $task | jq -j ".command")
confirm=$(echo $task | jq ".confirm")
task_bool=$(echo $task | jq ".tasks")

if [[ $task_bool == "true" ]]; then
  # Chain the confirm command before executing the selected command

  # get the task you want to execute
  tasks_file="$HOME/.config/i3/uni-tasks.json"
  timer_tasks=$(cat $tasks_file)

  #Pass tasks to rofi, and get the output as the selected option
  selected=$(echo $timer_tasks | jq -j 'map(.name) | join("\n")' | rofi -dmenu -matching fuzzy -i -p "Which tasks")
  timer_task=$(echo $timer_tasks | jq ".[] | select(.name == \"$selected\")")

  if [[ $timer_task == "" ]]; then
    echo "No task defined as '$selected' within config file."
    exit 1
  fi

  task_name=$(echo $timer_task | jq -j ".name")
  echo $task_name
  # get the the project
  project_file="$HOME/.config/i3/uni-projects.json"
  projects=$(cat $project_file)
  selected=$(echo $projects | jq -j 'map(.name) | join("\n")' | rofi -dmenu -matching fuzzy -i -p "which project?")
  project=$(echo $projects | jq ".[] | select(.name == \"$selected\")")

  project_name=$(echo $project | jq -j ".name")
  if [[ $project == "" ]]; then
    eval "$task_command $task_name"
    dunstify "$(toggl now)"

  else
    eval "$task_command $task_name -o $project_name"
    $toggl_now = eval "toggl now"
    dunstify "$(toggl now)"
  fi
fi

echo $command_name
if [[ $command_name == "Stop-Timer" ]]; then
  dunstify "$(toggl stop)"
fi
if [[ $command_name == "Current-Timer" ]]; then
  eval "$task_command"
  dunstify "$(toggl now)"
fi
