package main

import (
	"bytes"
	"fmt"
	"os/exec"
	"regexp"
	"strings"
)

var tasks []string
var projects string

func main() {
	go getLastTasks()
	go getProjects()
	runningTimer := make(chan string)
	go getActiveTimer(runningTimer)
	if <-runningTimer == "No time entry is running at the moment" {
		startTask()
	} else {
		stopTask()
	}
}
func add(m map[string]bool, list *[]string, s string) {
	if m[s] {
		return // Already in the map
	}
	*list = append(*list, s)
	m[s] = true
}
func prepareTaskList(s string) {
	input := strings.Split(s, "\n")
	if len(input) > 0 {
		input = input[:len(input)-1]
	}
	m := make(map[string]bool)
	var x []string
	for _, v := range input {
		a := regexp.MustCompile("[–@]").Split(v, -1)
		x = append(x, strings.TrimSpace(a[1]))
	}
	for _, a := range x {
		add(m, &tasks, a)
	}
}
func startTask() {

	cmd := exec.Command("rofi", "-dmenu", "-i", "-p", "What do you want to do?")
	cmd.Stdin = bytes.NewBufferString(strings.Join(tasks, "\n"))
	out, _ := cmd.CombinedOutput()
	cmd1 := exec.Command("rofi", "-dmenu", "-i", "-p", "What is the Project?")
	cmd1.Stdin = bytes.NewBufferString(projects)
	out1, _ := cmd1.CombinedOutput()
	fmt.Println(string(out1))
	exec.Command("toggl", "start", "-p", strings.TrimSpace(string(out1)), strings.TrimSpace(string(out))).Run()
}

func stopTask() {
	input := "stopTask\nstartNewTask"
	cmd := exec.Command("rofi", "-dmenu", "-i", "-p", "What do you want to do?")
	cmd.Stdin = bytes.NewBufferString(input)
	out, _ := cmd.CombinedOutput()
	fmt.Println(string(out))
	if strings.TrimSpace(string(out)) == "stopTask" {
		exec.Command("toggl", "stop").Run()
	}
	if strings.TrimSpace(string(out)) == "startNewTask" {
		startTask()
	}
}
func getActiveTimer(c chan string) {
	runningTimer, _ := exec.Command("toggl").Output()
	c <- strings.TrimRight(string(runningTimer), "\n")
}

func getLastTasks() {
	taskList, _ := exec.Command("toggl", "list").Output()
	prepareTaskList(string(taskList))
}

func getProjects() {
	projectList, _ := exec.Command("toggl", "list", "project").Output()
	projects = string(projectList)
}
