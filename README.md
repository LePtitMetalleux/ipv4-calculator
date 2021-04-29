# ipv4-calculator
Calculatrice IPv4 Multifonctions
Très simple d'utilisation, elle vous permet de calculer différents informations à partir d'une IPv4 et d'un masque CIDR : - Données en binaire et hexadécimal
- Adresse du réseau
- Masque inversé
- Adresse de broadcast
- Nombre d'hôtes possibles
- Première et dernière adresse d'hôte
L'affichage des informations se fait via la console ainsi que dans un fichier texte !

Usage : ./cip.sh <IPv4>/<Masque en décimal pointé> (<IPv4>/<Masque en décimal pointé>) (...)

Exemple : ./cip.sh 192.168.14.20/24 123.45.67.89/10

Sortie : 
![image](https://user-images.githubusercontent.com/59097429/116513398-cf9d0880-a8c9-11eb-985c-2ab34f2b9fdc.png)

TODO :
Mode interactif
Fichier de config :
  - Sélection du mode interactif ou non ?
  - Format de sortie : Console, fichier (fotmat de fichier ? csv, txt) ou les deux
Fonction pour faire un joli cadre de présentation
Support IPv6 ?
