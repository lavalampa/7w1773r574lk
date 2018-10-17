#!/bin/bash
cd "/home/ln/twitter"
dos2unix -q users.txt
limit=$(cat limit.txt)
readarray -t users < users.txt
token=$(cat token.txt)
chat=$(cat chat.txt)

for ii in "${users[@]}";do
	mkdir "$ii" 2>/dev/null
	pics=($(scrape-twitter timeline -m --count=$limit "$ii" | jq --raw-output ".[].images[]"))
	for i in "${pics[@]}";do	
				grep -q "$i" "tweets.txt"
				status=$?
				if [[ $status -ne 0 ]] ; then
					curl --silent -X POST "https://api.telegram.org/$token/sendMessage" --data-binary "chat_id=$chat&text=$i:orig" 2>/dev/null 
					status=$?
					if [[ $status -eq 0 ]]; then
						echo "$ii-$i" >> tweets.txt
						dl=$(echo "$i" | cut -d "/" -f5)
						wget -q "$i:orig" -O "$ii/$dl"
						sleep 1
					fi
				fi
	done
done
