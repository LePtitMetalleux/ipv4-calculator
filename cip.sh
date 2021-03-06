#!/bin/bash
# cip.sh
# Auteur : LePtitMetalleux
# Utilité : Calculatrice IPv4 multifonctions
# Usage : ./cip.sh IPv4/MasqueCIDR (IPv4/MasqueCIDR) (...)
# Exemple : ./cip.sh 192.168.14.20/24 123.45.67.89/10
# Version 2.0.1
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

[ ! -e '/usr/bin/bc' ] || [ ! -e '/bin/bc' ] && echo "La commande bc est introuvable, veuillez l'installer avant toute exécution du script" && echo "apt install bc" && exit 1

[ ! -e "config.cfg" ] && echo "Fichier de configuration introuvable. Veuillez vérifier l'emplacement du fichier config.cfg" && exit 1

. ./config.cfg

# Fonction de conversion binaire à décimal
bin2dec() {
    echo "$((2#$1))"
}

# Fonction de conversion décimal à binaire
dec2bin() {
    bin=$(bc <<< "obase=2;$1")
    # Le # nous retourne la taille de la chaîne de caractères
    taille=${#bin}
    while [ $taille -lt 8 ]
    do
        bin="0${bin}"
        # Le # nous retourne la taille de la chaîne de caractères
        taille=${#bin}
    done
    echo "$bin"
}

# Fonction de conversion décimal vers hexadécimal
dec2hex() {
    bin=$(bc <<< "obase=16;$1")
    # Le # nous retourne la taille de la chaîne de caractères
    taille=${#bin}
    while [ $taille -lt 2 ]
    do
        bin="0${bin}"
        # Le # nous retourne la taille de la chaîne de caractères
        taille=${#bin}
    done
    echo "$bin"
}

format() {
    # Nombre de caractères dans une ligne sous un format correct - 1 pour le pipe de fin de ligne
    formatedlength=46
    # Ligne à traiter
    toformat=$1
    # Le # nous retourne la taille de la chaîne de caractères
    taille=${#toformat}
    while [ $taille -lt $formatedlength ]
    do
        toformat="$toformat "
        # Le # nous retourne la taille de la chaîne de caractères
        taille=${#toformat}
    done
    toformat="$toformat|"
    echo "$toformat"
}

calcul() {
    for traitement in $@
    do
        # Si l'agument est -h ou --help on affiche le menu d'aide
        [ "$traitement" == '-h' -o "$traitement" == '--help' ] && echo "Menu d'aide :" && echo $(cat $0 | head -n 5 | tail -1 | cut -d ' ' -f 2-) && echo $(cat $0 | head -n 6 | tail -1 | cut -d ' ' -f 2-) && exit 1
        # Validation de l'ip, on passe à l'aguement suivant si l'argument n'est pas une IPv4
        [ $(echo "$traitement" | grep -E '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}' | wc -l) -eq 0 ] && echo "L'adresse IP $traitement n'est pas valide." && continue
    
        # On découpe l'arguement ou prendre la partie IP
        ip=$(echo $traitement | cut -d \/ -f 1)
        # On découpe l'arguement ou prendre le Masque CIDR
        masquecidr=$(echo $traitement | cut -d \/ -f 2)

        [ "$masquecidr" == '' -o "$masquecidr" == "$ip" ] && echo "Je n'ai pas trouvé le masque CIDR dans l'entrée suivante : $traitement. Veuillez vérifier la syntaxe de votre commande." && echo $(cat $0 | head -n 5 | tail -1 | cut -d ' ' -f 2-) && echo $(cat $0 | head -n 6 | tail -1 | cut -d ' ' -f 2-) && exit 1

        [ $masquecidr -gt 32 -o $masquecidr -lt 0 ] && echo "Le masque indiqué (/$masquecidr) pour l'adresse IP $ip est invalide. Le masque doit être compris entre 0 et 32." && continue

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
            # Le # nous retourne la taille de la chaîne de caractères
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
        fichier="$(echo $ip | tr '.' '_')_$masquecidr.txt"
        > $fichier

        # Exception pour les IPs en /32
        if [ $masquecidr -eq 32 ]
        then
            echo '┌---------------------------------------------┐' | tee -a $fichier # La commande Tee Linux lit l’entrée standard et l’écrit à la fois dans le résultat standard et dans un ou plusieurs fichiers.
            echo '|           Adresse de la machine :           |' | tee -a $fichier
            echo "$(format "|Décimal : $ip")" | tee -a $fichier
            echo "$(format "|Binaire : $octetbinaire1ip.$octetbinaire2ip.$octetbinaire3ip.$octetbinaire4ip")" | tee -a $fichier
            echo "$(format "|Hexadécimal : $(dec2hex $octet1ip).$(dec2hex $octet2ip).$(dec2hex $octet3ip).$(dec2hex $octet4ip)")" | tee -a $fichier
            echo '|---------------------------------------------|' | tee -a $fichier
            echo '|             Masque du réseau :              |' | tee -a $fichier
            echo '|Décimal : 255.255.255.255                    |' | tee -a $fichier
            echo '|Binaire : 11111111.11111111.11111111.11111111|' | tee -a $fichier
            echo '|CIDR : /32                                   |' | tee -a $fichier
            echo '|Hexadécimal : FF.FF.FF.FF                    |' | tee -a $fichier
            echo '|---------------------------------------------|' | tee -a $fichier
            echo '|              Masque inverse :               |' | tee -a $fichier
            echo '|Décimal 0.0.0.0                              |' | tee -a $fichier
            echo '|Binaire : 00000000.00000000.00000000.00000000|' | tee -a $fichier
            echo '|Hexadécimal : 00.00.00.00                    |' | tee -a $fichier
            echo '|---------------------------------------------|' | tee -a $fichier
            echo '|            Seul hôte possible :             |' | tee -a $fichier
            echo "$(format "|Décimal : $ip")" | tee -a $fichier
            echo "$(format "|Binaire : $octetbinaire1ip.$octetbinaire2ip.$octetbinaire3ip.$octetbinaire4ip")" | tee -a $fichier
            echo "$(format "|Hexadécimal : $(dec2hex $octet1ip).$(dec2hex $octet2ip).$(dec2hex $octet3ip).$(dec2hex $octet4ip)")" | tee -a $fichier
            echo '└---------------------------------------------┘' | tee -a $fichier
            continue
        fi

        # Affichage des informations à l'écran et enregistrement dans le fichier 
        echo '┌---------------------------------------------┐' | tee -a $fichier # La commande Tee Linux lit l’entrée standard et l’écrit à la fois dans le résultat standard et dans un ou plusieurs fichiers.
        echo '|           Adresse de la machine :           |' | tee -a $fichier
        echo "$(format "|Décimal : $ip")" | tee -a $fichier
        echo "$(format "|Binaire : $octetbinaire1ip.$octetbinaire2ip.$octetbinaire3ip.$octetbinaire4ip")" | tee -a $fichier
        echo "$(format "|Hexadécimal : $(dec2hex $octet1ip).$(dec2hex $octet2ip).$(dec2hex $octet3ip).$(dec2hex $octet4ip)")" | tee -a $fichier
        echo '|---------------------------------------------|' | tee -a $fichier
        echo '|             Masque du réseau :              |' | tee -a $fichier
        echo "$(format "|Décimal : ${octetdecimal1masque}.${octetdecimal2masque}.${octetdecimal3masque}.${octetdecimal4masque}")" | tee -a $fichier
        echo "$(format "|Binaire : $octetbinaire1masque.$octetbinaire2masque.$octetbinaire3masque.$octetbinaire4masque")" | tee -a $fichier
        echo "$(format "|CIDR : /$masquecidr")" | tee -a $fichier
        echo "$(format "|Hexadécimal : $(dec2hex $octetdecimal1masque).$(dec2hex $octetdecimal2masque).$(dec2hex $octetdecimal3masque).$(dec2hex $octetdecimal4masque)")" | tee -a $fichier
        echo '|---------------------------------------------|' | tee -a $fichier
        echo '|              Masque inverse :               |' | tee -a $fichier
        echo "$(format "|Décimal $((255 - $octetdecimal1masque)).$((255 - $octetdecimal2masque)).$((255 - $octetdecimal3masque)).$((255 - $octetdecimal4masque))")" | tee -a $fichier
        echo "$(format "|Binaire : $(echo $octetbinaire1masque.$octetbinaire2masque.$octetbinaire3masque.$octetbinaire4masque | tr '1' '_' | tr '0' '1' | tr '_' '0')")" | tee -a $fichier
        echo "$(format "|Hexadécimal : $(dec2hex $((255 - $octetdecimal1masque))).$(dec2hex $((255 - $octetdecimal2masque))).$(dec2hex $((255 - $octetdecimal3masque))).$(dec2hex $((255 - $octetdecimal4masque)))")" | tee -a $fichier
        echo '|---------------------------------------------|' | tee -a $fichier
        echo '|             Adresse du réseau :             |' | tee -a $fichier
        echo "$(format "|Décimal : $((octet1ip & octetdecimal1masque)).$((octet2ip & octetdecimal2masque)).$((octet3ip & octetdecimal3masque)).$((octet4ip & octetdecimal4masque))")" | tee -a $fichier
        echo "$(format "|Binaire : $(dec2bin $((octet1ip & octetdecimal1masque))).$(dec2bin $((octet2ip & octetdecimal2masque))).$(dec2bin $((octet3ip & octetdecimal3masque))).$(dec2bin $((octet4ip & octetdecimal4masque)))")" | tee -a $fichier
        echo "$(format "|Hexadécimal : $(dec2hex $((octet1ip & octetdecimal1masque))).$(dec2hex $((octet2ip & octetdecimal2masque))).$(dec2hex $((octet3ip & octetdecimal3masque))).$(dec2hex $((octet4ip & octetdecimal4masque)))")" | tee -a $fichier
        echo '|---------------------------------------------|' | tee -a $fichier
        echo '|            Adresse de broadcast :           |' | tee -a $fichier
        echo "$(format "|Décimal : $((256 + (octet1ip | ~octetdecimal1masque))).$((256 + (octet2ip | ~octetdecimal2masque))).$((256 + (octet3ip | ~octetdecimal3masque))).$((256 + (octet4ip | ~octetdecimal4masque)))")" | tee -a $fichier
        echo "$(format "|Binaire : $(dec2bin $((256 + (octet1ip | ~octetdecimal1masque)))).$(dec2bin $((256 + (octet2ip | ~octetdecimal2masque)))).$(dec2bin $((256 + (octet3ip | ~octetdecimal3masque)))).$(dec2bin $((256 + (octet4ip | ~octetdecimal4masque))))")" | tee -a $fichier
        echo "$(format "|Hexadécimal : $(dec2hex $((256 + (octet1ip | ~octetdecimal1masque)))).$(dec2hex $((256 + (octet2ip | ~octetdecimal2masque)))).$(dec2hex $((256 + (octet3ip | ~octetdecimal3masque)))).$(dec2hex $((256 + (octet4ip | ~octetdecimal4masque))))")" | tee -a $fichier
        echo '|---------------------------------------------|' | tee -a $fichier
        echo "$(format "|Nombre d'hôtes possibles : $((2 ** (32 - $masquecidr) - 2))")" | tee -a $fichier
        echo '|---------------------------------------------|' | tee -a $fichier
        echo '|          Adresse du premier hôte :          |' | tee -a $fichier
        echo "$(format "|Décimal : $((octet1ip & octetdecimal1masque)).$((octet2ip & octetdecimal2masque)).$((octet3ip & octetdecimal3masque)).$(((octet4ip & octetdecimal4masque)+1))")" | tee -a $fichier
        echo "$(format "|Binaire : $(dec2bin $((octet1ip & octetdecimal1masque))).$(dec2bin $((octet2ip & octetdecimal2masque))).$(dec2bin $((octet3ip & octetdecimal3masque))).$(dec2bin $(((octet4ip & octetdecimal4masque)+1)))")" | tee -a $fichier
        echo "$(format "|Hexadécimal : $(dec2hex $((octet1ip & octetdecimal1masque))).$(dec2hex $((octet2ip & octetdecimal2masque))).$(dec2hex $((octet3ip & octetdecimal3masque))).$(dec2hex $(((octet4ip & octetdecimal4masque)+1)))")" | tee -a $fichier
        echo '|---------------------------------------------|' | tee -a $fichier
        echo '|          Adresse du dernier hôte :          |' | tee -a $fichier
        echo "$(format "|Décimal : $((256 + (octet1ip | ~octetdecimal1masque))).$((256 + (octet2ip | ~octetdecimal2masque))).$((256 + (octet3ip | ~octetdecimal3masque))).$(((256 + (octet4ip | ~octetdecimal4masque))-1))")" | tee -a $fichier
        echo "$(format "|Binaire : $(dec2bin $((256 + (octet1ip | ~octetdecimal1masque)))).$(dec2bin $((256 + (octet2ip | ~octetdecimal2masque)))).$(dec2bin $((256 + (octet3ip | ~octetdecimal3masque)))).$(dec2bin $(((256 + (octet4ip | ~octetdecimal4masque))-1)))")" | tee -a $fichier
        echo "$(format "|Hexadécimal : $(dec2hex $((256 + (octet1ip | ~octetdecimal1masque)))).$(dec2hex $((256 + (octet2ip | ~octetdecimal2masque)))).$(dec2hex $((256 + (octet3ip | ~octetdecimal3masque)))).$(dec2hex $(((256 + (octet4ip | ~octetdecimal4masque))-1)))")" | tee -a $fichier
        echo '└---------------------------------------------┘' | tee -a $fichier
        echo '' | tee -a $fichier
        echo '' | tee -a $fichier
    done
}

if [ "$GRAPHIC" == 'true' ]
then
    ip=$(whiptail --inputbox "Veuillez indiquer l'adresse IPv4 à traiter avec le masque CIDR sous le format suivant : IPv4/MasqueCIDR" 8 78 192.168.1.14/24 --title "Calculatrice IPv4" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]
    then
        calcul $ip
        whiptail --textbox $fichier 45 53 --title $ip
    fi
elif [ "$INTERACTIF" == 'true' ]
then
    # Mode interactif
    echo 'Bienvenue sur le mode interactif de la calculatrice IPv4'
    echo "Veuillez indiquer l'adresse IPv4 à traiter avec le masque CIDR sous le format suivant : IPv4/MasqueCIDR"
    echo 'Pour annuler répondez par "stop"'
    read -p "IPv4 à traiter : " reponse
    [ "$reponse" == 'stop' ] && echo "Merci d'avoir utilisé la calculatrice IPv4 !" && exit 0
    while :
    do
        calcul $reponse
        read -p "Voulez-vous traiter une nouvelle adresse IPv4 ? [y/n] " reponse
        [ "$reponse" == 'n' -o "$reponse" == 'N' ] && break
        read -p "IPv4 à traiter : " reponse
    done
    echo "Merci d'avoir utilisé la calculatrice IPv4 !" && exit 0
else
    # Mode non-interactif
    # On retourne le menu d'aide si aucun argument n'est fourni
    [ $# -lt 1 ] && echo "Menu d'aide :" && echo $(cat $0 | head -n 5 | tail -1 | cut -d ' ' -f 2-) && echo $(cat $0 | head -n 6 | tail -1 | cut -d ' ' -f 2-) && exit 1

    calcul $@
fi
exit 0
