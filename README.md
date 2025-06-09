## Flow-mode 🚀 - Restez concentré, éliminez les distractions

Flow-mode est un projet développé dans le cadre de la matière Unix - Linux à JUNIA ISEN. Il permet de couper les notifications et de bloquer l'accès à certains sites populaires afin d'améliorer la productivité et la concentration.

## 💻 Installation

Clonez le projet sur votre machine :
```
git clone https://github.com/Amakatus/flowmode
cd flowmode
```

Rendez les scripts exécutable :
```
chmod +x src/*
```

## ⚡ Utilisation
### Activer le mode concentration

Pour activer Flow-mode et bloquer les distractions, lancez le script flow-on.sh :

```bash
cd src/
./flow-on.sh
```
Cela bloquera les sites populaires et désactivera les notifications pour vous permettre de rester concentré.    
Vous pouvez également personaliser les sites à bloquer via l'interface.

### Désactiver le mode concentration

Si vous souhaitez revenir à votre état normal, exécutez le script flow-off.sh :

```bash
./flow-off.sh
```

## 📝 Améliorations prévues

### Rofi
Démarrage des fonctionnalités au travers de la fenêtre d'interaction `Rofi`

### Script d'initialisation
Fournir à l'utilisateur un script d'initialisation afin de préparer son système au Flow-mode (détection et installation des paquets en fonction du système d'exploitation)
