#!/bin/bash
# cip.sh
# Auteur : LePtitMetalleux
# Utilité : Calculatrice IPv4 multifonctions
# Usage : ./cip.sh <IPv4>/<Masque en décimal pointé> (<IPv4>/<Masque en décimal pointé>) (...)
# Exemple : ./cip.sh 192.168.14.20/24 123.45.67.89/10
# Version 1.3.0
# Licence : MIT License

# Copyright (c) 2021 LePtitMetalleux

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# On retourne le menu d'aide si aucun argument n'est fourni
[ $# -lt 1 ] && echo "Menu d'aide :" && echo $(cat $0 | head -n 5 | tail -1 | cut -d ' ' -f 2-) && echo $(cat $0 | head -n 6 | tail -1 | cut -d ' ' -f 2-) && exit 1

# Fonction de conversion binaire à décimal
bin2dec() {
    echo "$((2#$1))"
}

# Fonction de conversion décimal à binaire
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

# Fonction de conversion décimal vers hexadécimal
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
    # Si l'agument est -h ou --help on affiche le menu d'aide
    [ "$traitement" == '-h' -o "$traitement" == '--help' ] && echo "Menu d'aide :" && echo $(cat $0 | head -n 5 | tail -1 | cut -d ' ' -f 2-) && echo $(cat $0 | head -n 6 | tail -1 | cut -d ' ' -f 2-) && exit 1
    # Validation de l'ip, on passe à l'aguement suivant si l'argument n'est pas une IPv4
    [ $(echo "$traitement" | grep -E '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}' | wc -l) -eq 0 ] && continue
    
    # On découpe l'arguement ou prendre la partie IP
    ip=$(echo $traitement | cut -d \/ -f 1)
    # On découpe l'arguement ou prendre le Masque CIDR
    masquecidr=$(echo $traitement | cut -d \/ -f 2)

    # Création de variables en découpant l'ip aux points
    IFS=. read octet1ip octet2ip octet3ip octet4ip <<< $ip

    # Masque choisi, indique le nombre de 1 dans le masque binaire. Cette valeur sera décrémentée
    nombre=$masquecidr

    # Nombre de bits dans une IP, indique le nombre de bits à traiter. Cette valeur sera décrémentée
    i=32

    # Variable qui contiendra le masque en binaire
    masquebin=''

    # On reste dans la boucle tant que l'on a pas traité les 32 bits 
    while [ $i -gt 0 ]
    do
        # S'il reste des 1 à mettre
        if [ $nombre -gt 0 ]
        then
            # On ajoute 1 dans notre chaine de caractère puis on décrémente le nombre de 1 restants
            masquebin="${masquebin}1"
            ((nombre--))
        # Sinon on ajoute 0 à notre chaine de caractères
        else
            masquebin="${masquebin}0"
        fi
        taille=${#masquebin}
        # Tous les 8 bits, on ajoute un point à notre chaine de caractères
        if [ $taille -eq 8 -o $taille -eq 17 -o $taille -eq 26 ]
        then
            masquebin="${masquebin}."
        fi
        # On décrémente de 1 le nombre de bits à traiter
        ((i--))
    done

    # Création de variables en découpant le masque aux points
    IFS=. read octetbinaire1masque octetbinaire2masque octetbinaire3masque octetbinaire4masque <<< $masquebin

    # Création des variables contenant les octets du masque en décimal
    octetdecimal1masque=$(bin2dec $octetbinaire1masque)
    octetdecimal2masque=$(bin2dec $octetbinaire2masque)
    octetdecimal3masque=$(bin2dec $octetbinaire3masque)
    octetdecimal4masque=$(bin2dec $octetbinaire4masque)

    # Masque en décimal pointé
    masquedp=$(echo "${octetdecimal1masque}.${octetdecimal2masque}.${octetdecimal3masque}.${octetdecimal4masque}")

    # Création des variables contenant les octets de l'ip en binaire
    octetbinaire1ip=$(dec2bin $octet1ip)
    octetbinaire2ip=$(dec2bin $octet2ip)
    octetbinaire3ip=$(dec2bin $octet3ip)
    octetbinaire4ip=$(dec2bin $octet4ip)

    # Création des variables contenant les octets de l'ip en hexadécimal
    octethex1ip=$(dec2hex $octet1ip)
    octethex2ip=$(dec2hex $octet2ip)
    octethex3ip=$(dec2hex $octet3ip)
    octethex4ip=$(dec2hex $octet4ip)

    # Création des variables contenant les octets du masque en hexadécimal
    octethex1masque=$(dec2hex $octetdecimal1masque)
    octethex2masque=$(dec2hex  $octetdecimal2masque)
    octethex3masque=$(dec2hex  $octetdecimal3masque)
    octethex4masque=$(dec2hex  $octetdecimal4masque)

    # Création ou vidage du fichier contenant les informations sur l'ip
    fichier="$(echo $ip | tr '.' '_').txt"
    > $fichier
    # Affichage des informations à l'écran et enregistrement dans le fichier 
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