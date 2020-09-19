#!/bin/bash

for i in 30 70 100;do
echo -n -e "                                                           \r"
  case $i in
    30)
     echo -n -e "Installing - \e[1;32m#####\e[0m################# - $i% "
    ;;
    70)
     echo -n -e "Installing - \e[1;32m#################\e[0m##### - $i% "
    ;;
    100)
     echo -n -e "Installing - \e[1;32m######################\e[0m - $i% "
    ;;
esac
sleep 1

done
echo