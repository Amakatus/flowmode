# Description du projet

PARTIE 1 – Script d’activation du mode concentration

👤 Responsable A : Gestion de l’activation (mise en place du mode)
🔧 Responsabilités :

    Pause des notifications

        Utiliser dunstctl ou autre selon l’environnement.

    Blocage de sites

        Lecture d’un fichier sites.txt

        Ajout des redirections dans /etc/hosts

        Ajout de balises personnalisées (# focus-mode) pour faciliter le retrait plus tard.

    Fermeture d’apps

        Lecture de la liste dans apps.txt

        Fermeture avec pkill, killall, confirmation optionnelle

    Lecture de musique

        Lancer une musique calme (fichier local ou streaming) avec mpv, cvlc...

        Démarrage en arrière-plan

🧪 Tests à prévoir :

    Vérifier que /etc/hosts est modifié proprement

    Vérifier que la musique continue en fond

    Assurer que le script est bien idempotent (réutilisable sans bug)

🔸PARTIE 2 – Script de désactivation / retour à la normale

👤 Responsable B : Gestion de la sortie du mode concentration
🔧 Responsabilités :

    Reprise des notifications

        dunstctl set-paused false

    Déblocage des sites

        Suppression uniquement des lignes avec # focus-mode dans /etc/hosts

    Redémarrage d’apps (optionnel)

        Lecture de la liste dans apps.txt

        Lancement avec command & (optionnel, ou laisser à l’utilisateur)

    Arrêt de la musique

        pkill mpv ou autre commande adaptée

🧪 Tests à prévoir :

    Vérifier que le fichier hosts est restauré sans erreur

    Vérifier que les processus musicaux sont bien arrêtés

    Messages de confirmation dans le terminal
focus-mode/
├── focus-on.sh         # Partie 1
├── focus-off.sh        # Partie 2
├── config/
│   ├── sites.txt       # Liste de sites à bloquer
│   └── apps.txt        # Liste d'apps à fermer
└── music/
    └── chill.mp3       # Fichier musical optionnel

🧠 Coordination à prévoir

    Se mettre d’accord sur le format des fichiers config/*.txt (noms d'apps, URL)

    Utiliser un tag commun dans /etc/hosts comme # focus-mode pour retrouver les lignes à supprimer

    Test final ensemble pour vérifier le passage fluide entre activation et désactivation