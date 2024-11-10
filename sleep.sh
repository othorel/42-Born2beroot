#!bin/bash

# Recueration des minutes de boot et sec
boot_min=$(uptime -s | cut -c 15-16)
boot_sec=$(uptime -s | cut -c 18-19)

# On calcul le nombre de minutes qui nous separt de la 10ene la plus proche
# Pour 18:42:23
# 42%10 = 2 donc 2 minutes de l'ecart avec la 10ene la plus proche qui est 40
# 2*60 = 120 pour convertir en seconde
# 120+23 = 143 seconde entre la 10ene la plus proche
delay=$(bc <<< $boot_min%10*60+$boot_sec)

#on passe les seconde au sleep pour avoir notre delay
sleep $delay
