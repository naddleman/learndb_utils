#!/bin/bash

# Download up to date character prefixes

wget https://raw.githubusercontent.com/crawl/sequell/master/config/crawl-data.yml

cat crawl-data.yml |
	sed '/^species:/,/^species-flavours:/!d' |
	sed '/\*\|#\|species\|^[[:space:]]*$/d'|
	cut -d: -f1 | sed 's/  //' | sed "s/'//g" |
	tr '[:upper:]' '[:lower:]' > species
	
cat crawl-data.yml | sed '/^classes:/,/^column-aliases:/!d' |
	sed '/\*\|classes\|column-aliases\|^[[:space:]]*$/d' |
	cut -d: -f1 | sed 's/  //' |
	tr '[:upper:]' '[:lower:]' > classes
	
# 4 character words
cat /usr/share/dict/words | grep -o -w -E '^[[:alpha:]]{4}' |
	tr '[:upper:]' '[:lower:]' | sort -u > 4words

# regex?
#
echo "/^\("$(cat species | awk 1 ORS='\\|' | sed 's/..$//')"\)""\("$(cat classes | awk 1 ORS='\\|' | sed 's/..$//')"\)/!d" > rgx

cat 4words | sed -f rgx > dcss_words

touch dcss_defs

cat dcss_words | while read line
do
	curl 'https://api.dictionaryapi.dev/api/v2/entries/en/'$line | jq '.' >> dcss_defs

	sleep 1
done

cat dcss_defs | jq '.[0] | .word?' | sed 's/"//g'  > dcss_words_dict

echo "Cleaning up"


echo "Done!"
