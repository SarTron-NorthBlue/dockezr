# Image de base Node.js
FROM node:20-alpine

# Définir le répertoire de travail
WORKDIR /app

# Accepter les build args
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

# Copier les fichiers package
COPY package*.json ./

# Installer les dépendances
RUN npm install

# Installer wget pour les health checks
RUN apk add --no-cache wget

# Copier le reste des fichiers
COPY . .

# Exposer le port
EXPOSE 3000

# Build de l'application pour la production
RUN npm run build

# Commande pour démarrer l'application en mode production
CMD ["npm", "start"]

