#!/bin/bash
MENU="
resume               продолжить работу
orient               понять где проект
brief: <идея>        написать brief
review brief: <id>   проверить brief
spec: <id>           написать spec
review spec: <id>    проверить spec
plan: <id>           написать plan
review plan: <id>    проверить plan
impl: <id>           реализовать
review: <id>         code review"

jq -n --arg msg "$MENU" '{"systemMessage":$msg}'
