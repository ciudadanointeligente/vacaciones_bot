#!/bin/bash

logfile="bot.log"

echo "vacaciones_bot launch script starting..."

pid=$(ps x | grep ruby| grep vacaciones | awk '{print $1;}')
echo "pid of process: "
echo $pid
tmp=$(echo $pid | wc -w)
echo $tmp


case "$tmp" in

0)  echo "starting vacaciones_bot"
    ruby ~/vacaciones_bot/vacaciones.rb > ~/vacaciones_bot/bot_output.log &
    ;;
1)  echo "vacaciones_bot running, all OK"
    ;;
*)  echo "error"
    ;;
esac
