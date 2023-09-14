#!/bin/bash
checkIfTogglIsRunning ()
{
  response=$(toggl now)
  if [[ $response == "There is no time entry running!" ]]; then
    startNewTask
  else
    dunstify "$response"
    result=$(echo -e "stopTask\nstartNewTask" | rofi -dmenu -i -p "$message ")
    if [[ $result == "stopTask" ]]; then
      dunstify $(toggl stop)
    else
      startNewTask
    fi
  fi
}

getProjectsInformation (){
  echo "$(toggl --no-header projects ls  | awk '{print $1}' | paste -sd '\n' -)"
}

getLastTasks(){
  echo "$(toggl --no-header -s ls  | awk '{print $1}' | paste -sd '\n' -)"
}

createRofiPopUp ()
{
  local popUpText="$1"
  local popUpSelection="$2"
  selected=$(echo "$popUpSelection" | rofi -dmenu -matching fuzzy -i -p "$popUpText")
  echo "$selected"
}
startNewTask()
{
  task="$(createRofiPopUp "What tasks do you want to start?" "$(getLastTasks)")"
  IFS=" " read -ra words <<< "$task"
  camelcase=""
  for word in "${words[@]}"; do
    word="${word^}"
    camelcase="${camelcase}${word}"
  done
  if [[ $camelcase == "" ]]; then
    exit 0
  fi
  project="$(createRofiPopUp "$popUpText" "$(getProjectsInformation)")"
  if [[ $project != "" ]]; then
    dunstify "$(toggl start "$camelcase" -o $project)"
  else
    dunstify "$(toggl start $camelcase)"
  fi
}

checkIfTogglIsRunning 
