FROM nodered/node-red

# Cambiar al usuario root para instalar dependencias
USER root

# Copiar package.json que contiene las dependencias
COPY package.json /data/package.json

# Instalar las dependencias en Node-RED
RUN cd /data && npm install

# Copiar el archivo settings.js
COPY settings.js /data/settings.js

# Cambiar de nuevo al usuario Node-RED
USER node-red

