#!/bin/bash
# Use ~/.myrmidon-tasks.json as default, otherwise use incoming path
checkIfTogglIsRunning (){
  response=$(toggl now)
  if [[ $response == "There is no time entry running!" ]]; then
    echo "no timer running"
  fi
}

getProjectsInformation (){
  echo "$(toggl --no-header projects ls)" 
}

createRofiPopUp ()
{
  local popUpText="$1"
  local popUpSelection="$2"
  selected=$(echo "$popUpSelection" | awk '{print}' | paste -sd '\n' - | rofi -dmenu -matching fuzzy -i -p "$popUpText")
  echo "$selected"
}
echo "$(getProjectsInformation)"
echo "$(checkIfTogglIsRunning)"
popUpText="select task"
returnValue="$(createRofiPopUp "$popUpText" "$(getProjectsInformation)")"
echo "$returnValue"



if [[ $project == "" ]]; then
    eval "$task_command $task_name"
    dunstify "$(toggl now)"

  else
    eval "$task_command $task_name -o $project_name"
    $toggl_now = eval "toggl now"
    dunstify "$(toggl now)"
  fi

echo $command_name
if [[ $command_name == "Stop-Timer" ]]; then
  dunstify "$(toggl stop)"
fi
if [[ $command_name == "Current-Timer" ]]; then
  eval "$task_command"
  dunstify "$(toggl now)"
fi
