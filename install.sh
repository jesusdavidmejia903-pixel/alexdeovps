#!/bin/bash

# --- CONFIGURACIÓN POR DEFECTO ---
# Dejamos el usuario fijo, pero el repositorio se pedirá al usuario
GITHUB_USER="jesusdavidmejia903-pixel"
BRANCH="main"
FILE_NAME="netdroid.py"
# ---------------------------------

# Colores
C='\033[96m'
G='\033[92m'
R='\033[91m'
Y='\033[93m'
W='\033[0m'

echo -e "${C}===========================================${W}"
echo -e "${C}   Instalando NETDROID VPS Manager...      ${W}"
echo -e "${C}===========================================${W}"

# --- ENTRADA INTERACTIVA ---
echo -e "\n${Y}Configuración inicial requerida:${W}"
read -p "Ingresa el nombre del repositorio de GitHub (ej. alexdeovps): " GITHUB_REPO

# Validar que el usuario no deje el campo vacío
if [ -z "$GITHUB_REPO" ]; then
    echo -e "${R}[!] El nombre del repositorio no puede estar vacío. Instalación cancelada.${W}"
    exit 1
fi

# 1. Actualizar e instalar dependencias
echo -e "\n${C}[1/3] Instalando dependencias (Python, Curl, Cron)...${W}"
apt-get update -y -qq
apt-get install -y python3 python3-pip curl cron -qq

# Instalar requests omitiendo advertencias de entorno de Ubuntu
pip3 install requests --break-system-packages 2>/dev/null || pip3 install requests 2>/dev/null

# 2. Construir la URL y descargar el script principal
RAW_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/${FILE_NAME}"

echo -e "\n${C}[2/3] Descargando el núcleo del sistema...${W}"
if curl -f -sL "$RAW_URL" -o /usr/local/bin/NETDROID; then
    
    # ¡MAGIA AQUÍ!: Buscamos la variable REPO en el script de Python descargado 
    # y la reemplazamos con los datos exactos que ingresaste en la terminal.
    sed -i "s|^REPO = .*|REPO = '${GITHUB_USER}/${GITHUB_REPO}'|" /usr/local/bin/NETDROID

    chmod +x /usr/local/bin/NETDROID
    echo -e "${G}[✓] Sistema descargado y vinculado al repositorio: ${GITHUB_REPO}.${W}"
else
    echo -e "${R}[!] Error al descargar el archivo. Verifica que el repositorio '${GITHUB_REPO}' exista y sea público.${W}"
    exit 1
fi

# 3. Configurar la tarea automatizada (Cron)
echo -e "\n${C}[3/3] Configurando limpieza automática de vencimientos...${W}"
CRON_JOB="0 0 * * * /usr/bin/python3 /usr/local/bin/NETDROID --cron"
(crontab -l 2>/dev/null | grep -v "NETDROID --cron"; echo "$CRON_JOB") | crontab -

echo -e "\n${G}=================================================${W}"
echo -e "${G}¡Instalación completada con éxito!${W}"
echo -e "${G}=================================================${W}"
echo -e "A partir de ahora, solo debes escribir el comando: ${C}NETDROID${W}"
echo -e "en tu terminal para administrar los clientes VLESS."
