#!/bin/bash
cd /home/minecraft/
java -Xmx1024M -Xms1024M -jar minecraft_server.jar nogui > /home/minecraft/minecraft.log 2>&1
