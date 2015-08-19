#!/bin/bash -e
function lcs(){
local i long sub l lshort short
if ((${#1}>${#2})); then
   long=$1 short=$2
else
   long=$2 short=$1
fi

lshort=${#short}
score=0
for ((i=0;i<lshort-score;++i)); do
   for ((l=score+1;l<=lshort-i;++l)); do
      sub=${short:i:l}
      [[ $long != *$sub* ]] && break
      subfound=$sub score=$l
   done
done
}

declare -a lines
readarray -t lines < blacklist.txt # Exclude newline.
len=${#lines[@]}
for (( i=1; i<${len}; i++ )); do
  for (( j=0; j<${i}; j++ )); do
    lcs "${lines[$i]}" "${lines[$j]}"
    leni=${#lines[$i]}
    lenj=${#lines[$j]}
    if [[ $score == $leni || $score == $lenj ]]; then
      echo substring length: $score
      echo substring: $subfound
      echo line $i+1: ${lines[$i]}
      echo line $j+1: ${lines[$j]}
      exit 1
    fi
  done
done
