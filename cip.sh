#!/bin/bash
# cip.sh
# Auteur : LePtitMetalleux
# Utilité : Calculatrice IPv4 multifonctions
# Usage : ./cip.sh <IPv4>/<Masque en décimal pointé> (<IPv4>/<Masque en décimal pointé>) (...)
# Exemple : ./cip.sh 192.168.14.20/24 123.45.67.89/10
# Version 1.3.0

[ $# -lt 1 ] && echo "Menu d'aide :" && echo $(cat $0 | head -n 5 | tail -1 | cut -d ' ' -f 2-) && echo $(cat $0 | head -n 6 | tail -1 | cut -d ' ' -f 2-) && exit 1

bin2dec() {
    echo "$((2#$1))"
}

dec2bin() {
    bin=$(bc <<< "obase=2;$1")
    taille=${#bin}
    while [ $taille -lt 8 ]
    do
        bin="0${bin}"
        taille=${#bin}
    done
    echo "$bin"
}

dec2hex() {
    bin=$(bc <<< "obase=16;$1")
    taille=${#bin}
    while [ $taille -lt 2 ]
    do
        bin="0${bin}"
        taille=${#bin}
    done
    echo "$bin"
}

for traitement in $@
do
    [ "$traitement" == '-h' -o "$traitement" == '--help' ] && echo "Menu d'aide :" && echo $(cat $0 | head -n 5 | tail -1 | cut -d ' ' -f 2-) && echo $(cat $0 | head -n 6 | tail -1 | cut -d ' ' -f 2-) && exit 1
    # (25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3} <- Regex IPv4
    ip=$(echo $traitement | cut -d \/ -f 1)
    masquecidr=$(echo $traitement | cut -d \/ -f 2)

    IFS=. read octet1ip octet2ip octet3ip octet4ip <<< $ip

    nombre=$masquecidr
    i=32
    masquebin=''
    while [ $i -gt 0 ]
    do
        if [ $nombre -gt 0 ]
        then
            masquebin="${masquebin}1"
            ((nombre--))
        else
            masquebin="${masquebin}0"
        fi
        taille=${#masquebin}
        if [ $taille -eq 8 -o $taille -eq 17 -o $taille -eq 26 ]
        then
            masquebin="${masquebin}."
        fi
        ((i--))
    done

    IFS=. read octetbinaire1masque octetbinaire2masque octetbinaire3masque octetbinaire4masque <<< $masquebin

    octetdecimal1masque=$(bin2dec $octetbinaire1masque)
    octetdecimal2masque=$(bin2dec $octetbinaire2masque)
    octetdecimal3masque=$(bin2dec $octetbinaire3masque)
    octetdecimal4masque=$(bin2dec $octetbinaire4masque)

    masquedp=$(echo "${octetdecimal1masque}.${octetdecimal2masque}.${octetdecimal3masque}.${octetdecimal4masque}")

    octetbinaire1ip=$(dec2bin $octet1ip)
    octetbinaire2ip=$(dec2bin $octet2ip)
    octetbinaire3ip=$(dec2bin $octet3ip)
    octetbinaire4ip=$(dec2bin $octet4ip)

    octethex1ip=$(dec2hex $octet1ip)
    octethex2ip=$(dec2hex $octet2ip)
    octethex3ip=$(dec2hex $octet3ip)
    octethex4ip=$(dec2hex $octet4ip)

    octethex1masque=$(dec2hex $octetdecimal1masque)
    octethex2masque=$(dec2hex  $octetdecimal2masque)
    octethex3masque=$(dec2hex  $octetdecimal3masque)
    octethex4masque=$(dec2hex  $octetdecimal4masque)

    fichier="$(echo $ip | tr '.' '_').txt"
    echo '┌---------------------------------------------┐' | tee -a $fichier
    echo "            Adresse de la machine :" | tee -a $fichier
    echo " Décimal : $ip" | tee -a $fichier
    echo " Binaire : $octetbinaire1ip.$octetbinaire2ip.$octetbinaire3ip.$octetbinaire4ip" | tee -a $fichier
    echo " Hexadécimal : $(dec2hex $octet1ip).$(dec2hex $octet2ip).$(dec2hex $octet3ip).$(dec2hex $octet4ip)" | tee -a $fichier
    echo '|---------------------------------------------|' | tee -a $fichier
    echo "              Masque du réseau :" | tee -a $fichier
    echo " Décimal : $masquedp" | tee -a $fichier
    echo " Binaire : $octetbinaire1masque.$octetbinaire2masque.$octetbinaire3masque.$octetbinaire4masque" | tee -a $fichier
    echo " CIDR : /$masquecidr" | tee -a $fichier
    echo " Hexadécimal : $(dec2hex $octetdecimal1masque).$(dec2hex $octetdecimal2masque).$(dec2hex $octetdecimal3masque).$(dec2hex $octetdecimal4masque)" | tee -a $fichier
    echo '|---------------------------------------------|' | tee -a $fichier
    echo "               Masque inverse :" | tee -a $fichier
    echo " Décimal $((255 - $octetdecimal1masque)).$((255 - $octetdecimal2masque)).$((255 - $octetdecimal3masque)).$((255 - $octetdecimal4masque))" | tee -a $fichier
    echo " Binaire : $(echo $octetbinaire1masque.$octetbinaire2masque.$octetbinaire3masque.$octetbinaire4masque | tr '1' '_' | tr '0' '1' | tr '_' '0')" | tee -a $fichier
    echo " Hexadécimal : $(dec2hex $((255 - $octetdecimal1masque))).$(dec2hex $((255 - $octetdecimal2masque))).$(dec2hex $((255 - $octetdecimal3masque))).$(dec2hex $((255 - $octetdecimal4masque)))"| tee -a $fichier
    echo '|---------------------------------------------|' | tee -a $fichier
    echo "              Adresse du réseau :" | tee -a $fichier
    echo " Décimal : $((octet1ip & octetdecimal1masque)).$((octet2ip & octetdecimal2masque)).$((octet3ip & octetdecimal3masque)).$((octet4ip & octetdecimal4masque))" | tee -a $fichier
    echo " Binaire : $(dec2bin $((octet1ip & octetdecimal1masque))).$(dec2bin $((octet2ip & octetdecimal2masque))).$(dec2bin $((octet3ip & octetdecimal3masque))).$(dec2bin $((octet4ip & octetdecimal4masque)))" | tee -a $fichier
    echo " Hexadécimal : $(dec2hex $((octet1ip & octetdecimal1masque))).$(dec2hex $((octet2ip & octetdecimal2masque))).$(dec2hex $((octet3ip & octetdecimal3masque))).$(dec2hex $((octet4ip & octetdecimal4masque)))" | tee -a $fichier
    echo '|---------------------------------------------|' | tee -a $fichier
    echo "             Adresse de broadcast :" | tee -a $fichier
    echo " Décimal : $((256 + (octet1ip | ~octetdecimal1masque))).$((256 + (octet2ip | ~octetdecimal2masque))).$((256 + (octet3ip | ~octetdecimal3masque))).$((256 + (octet4ip | ~octetdecimal4masque)))" | tee -a $fichier
    echo " Binaire : $(dec2bin $((256 + (octet1ip | ~octetdecimal1masque)))).$(dec2bin $((256 + (octet2ip | ~octetdecimal2masque)))).$(dec2bin $((256 + (octet3ip | ~octetdecimal3masque)))).$(dec2bin $((256 + (octet4ip | ~octetdecimal4masque))))" | tee -a $fichier
    echo " Hexadécimal : $(dec2hex $((256 + (octet1ip | ~octetdecimal1masque)))).$(dec2hex $((256 + (octet2ip | ~octetdecimal2masque)))).$(dec2hex $((256 + (octet3ip | ~octetdecimal3masque)))).$(dec2hex $((256 + (octet4ip | ~octetdecimal4masque))))" | tee -a $fichier
    echo '|---------------------------------------------|' | tee -a $fichier
    echo " Nombre d'hôtes possibles : $((2 ** (32 - $masquecidr) - 2))" | tee -a $fichier
    echo '|---------------------------------------------|' | tee -a $fichier
    echo " Adresse du premier hôte : " | tee -a $fichier
    echo " Décimal : $((octet1ip & octetdecimal1masque)).$((octet2ip & octetdecimal2masque)).$((octet3ip & octetdecimal3masque)).$(((octet4ip & octetdecimal4masque)+1))" | tee -a $fichier
    echo " Binaire : $(dec2bin $((octet1ip & octetdecimal1masque))).$(dec2bin $((octet2ip & octetdecimal2masque))).$(dec2bin $((octet3ip & octetdecimal3masque))).$(dec2bin $(((octet4ip & octetdecimal4masque)+1)))" | tee -a $fichier
    echo " Hexadécimal : $(dec2hex $((octet1ip & octetdecimal1masque))).$(dec2hex $((octet2ip & octetdecimal2masque))).$(dec2hex $((octet3ip & octetdecimal3masque))).$(dec2hex $(((octet4ip & octetdecimal4masque)+1)))" | tee -a $fichier
    echo '|---------------------------------------------|' | tee -a $fichier
    echo " Adresse du dernier hôte : " | tee -a $fichier
    echo " Décimal : $((256 + (octet1ip | ~octetdecimal1masque))).$((256 + (octet2ip | ~octetdecimal2masque))).$((256 + (octet3ip | ~octetdecimal3masque))).$(((256 + (octet4ip | ~octetdecimal4masque))-1))" | tee -a $fichier
    echo " Binaire : $(dec2bin $((256 + (octet1ip | ~octetdecimal1masque)))).$(dec2bin $((256 + (octet2ip | ~octetdecimal2masque)))).$(dec2bin $((256 + (octet3ip | ~octetdecimal3masque)))).$(dec2bin $(((256 + (octet4ip | ~octetdecimal4masque))-1)))" | tee -a $fichier
    echo " Hexadécimal : $(dec2hex $((256 + (octet1ip | ~octetdecimal1masque)))).$(dec2hex $((256 + (octet2ip | ~octetdecimal2masque)))).$(dec2hex $((256 + (octet3ip | ~octetdecimal3masque)))).$(dec2hex $(((256 + (octet4ip | ~octetdecimal4masque))-1)))" | tee -a $fichier
    echo '└---------------------------------------------┘' | tee -a $fichier
    echo '' | tee -a $fichier
    echo '' | tee -a $fichier
done
exit 0