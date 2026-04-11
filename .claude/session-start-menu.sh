#!/bin/bash
MENU="
resume               	  	продолжить работу
orient               	  	понять и показать текущее состояние
brief: <task>        	  	написать brief
review brief: <id>   	  	проверить brief
spec: <id>           	  	написать spec
review spec: <id>    	  	проверить spec
plan: <id>           	  	написать plan
review plan: <id>    	  	проверить plan
impl: <id>           	  	реализовать
review: <id>         	  	code review
fix review: <id> <stage>    	исправить замечания из review notes"

jq -n --arg msg "$MENU" '{"systemMessage":$msg}'
