#!/bin/bash

mkdir -p ./backup

tar -czf ./backup/$(date "+%Y%m%d-%H.%M.%S").tgz \
  ./data/cluster \
  ./data/ShooterGame/Saved \
  ./data/ShooterGame/Binaries/Linux/PlayersJoinNoCheckList.txt
