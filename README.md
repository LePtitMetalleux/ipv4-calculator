# ipv4-calculator
Calculatrice IPv4 Multifonctions

Très simple d'utilisation, elle vous permet de calculer différents informations à partir d'une IPv4 et d'un masque CIDR :
- Données en binaire et hexadécimal
- Adresse du réseau
- Masque inversé
- Adresse de broadcast
- Nombre d'hôtes possibles
- Première et dernière adresse d'hôte
L'affichage des informations se fait via la console ainsi que dans un fichier texte !

Mode interactif ou non aux choix via un fichier de configuration !

Usage : ./cip.sh IPv4/MasqueCIDR (IPv4/MasqueCIDR) (...)

Exemple : ./cip.sh 192.168.14.20/24 123.45.67.89/10

Sortie :

![image](https://user-images.githubusercontent.com/59097429/116759323-58bf5700-aa12-11eb-8767-4d18d2def9c5.png)

TODO :

Fichier de config :
  - Format de sortie : Console, fichier (fotmat de fichier ? csv, txt) ou les deux
    - Si CSV : Un seul fichier ou en séparés ?

Mise en place de code de sortie

Support IPv6 ?
