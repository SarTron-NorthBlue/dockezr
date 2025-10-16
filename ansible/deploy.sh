#!/bin/bash
# Script de déploiement Ansible pour DockeZR
# À exécuter depuis WSL ou Linux

# Couleurs pour l'affichage
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Déploiement Ansible - DockeZR      ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

# Vérifier qu'Ansible est installé
if ! command -v ansible &> /dev/null; then
    echo -e "${RED}❌ Ansible n'est pas installé!${NC}"
    echo ""
    echo "Installation sur Ubuntu/Debian:"
    echo "  sudo apt update && sudo apt install ansible -y"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Ansible version: $(ansible --version | head -n1)${NC}"
echo ""

# Test de connexion
echo -e "${YELLOW}🔍 Test de connexion SSH...${NC}"
if ansible all -i inventory.ini -m ping &> /dev/null; then
    echo -e "${GREEN}✅ Connexion SSH réussie!${NC}"
    echo ""
else
    echo -e "${RED}❌ Impossible de se connecter au serveur!${NC}"
    echo ""
    echo "Vérifiez:"
    echo "  1. L'adresse IP dans inventory.ini"
    echo "  2. Les permissions de la clé SSH: chmod 600 ../../sskdockerz/ssh-key-2025-10-16.key"
    echo "  3. La connexion réseau"
    echo ""
    exit 1
fi

# Menu de déploiement
echo -e "${BLUE}Choisissez une option:${NC}"
echo "  1) Déploiement complet (recommandé)"
echo "  2) Test de connexion uniquement"
echo "  3) Arrêter les conteneurs"
echo "  4) Reconstruire et redémarrer"
echo "  5) Mode verbeux (debug)"
echo ""
read -p "Votre choix [1-5]: " choice

case $choice in
    1)
        echo -e "${GREEN}🚀 Lancement du déploiement complet...${NC}"
        ansible-playbook -i inventory.ini deploy.yml
        ;;
    2)
        echo -e "${GREEN}🔍 Test de connexion...${NC}"
        ansible all -i inventory.ini -m ping -v
        ;;
    3)
        echo -e "${YELLOW}🛑 Arrêt des conteneurs...${NC}"
        ansible-playbook -i inventory.ini deploy.yml --tags stop
        ;;
    4)
        echo -e "${GREEN}🔄 Reconstruction et redémarrage...${NC}"
        ansible-playbook -i inventory.ini deploy.yml --tags build,start
        ;;
    5)
        echo -e "${GREEN}🐛 Mode verbeux activé...${NC}"
        ansible-playbook -i inventory.ini deploy.yml -vvv
        ;;
    *)
        echo -e "${RED}Choix invalide!${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ Opération terminée!${NC}"

