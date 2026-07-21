#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo -e "${RED}❌ Uso: $0 <nombre-servicio> (bienvenute o pokerface)${NC}"
    exit 1
fi
SERVICE=$(echo "$1" | tr '[:upper:]' '[:lower:]')
if [ "$SERVICE" != "bienvenute" ] && [ "$SERVICE" != "pokerface" ]; then
    echo -e "${RED}❌ Servicio no válido. Use 'bienvenute' o 'pokerface'${NC}"
    exit 1
fi
PROJECT="$(tr '[:lower:]' '[:upper:]' <<< ${SERVICE:0:1})${SERVICE:1}"

echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║        BUILD LOCAL - $PROJECT                     ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"

echo -e "\n${YELLOW}📦 Procesando $PROJECT...${NC}"
echo -e "${BLUE}🧹 Limpiando...${NC}"
dotnet clean ./$PROJECT/$PROJECT.csproj -c Release
echo -e "${BLUE}📦 Publicando para linux-x64...${NC}"
dotnet publish ./$PROJECT/$PROJECT.csproj -c Release -r linux-x64 --self-contained false -o ./$PROJECT/bin/Release/net10.0/linux-x64/publish
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al publicar $PROJECT${NC}"
    exit 1
fi
echo -e "${GREEN}✅ $PROJECT publicado correctamente${NC}"

echo -e "\n${YELLOW}🐳 Construyendo imagen Docker para $SERVICE...${NC}"
docker-compose build $SERVICE
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al construir la imagen${NC}"
    exit 1
fi

echo -e "\n${YELLOW}🚀 Levantando contenedor $SERVICE...${NC}"
docker-compose up -d $SERVICE
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al levantar el contenedor${NC}"
    exit 1
fi

echo -e "\n${GREEN}✅ ¡Contenedor $SERVICE levantado exitosamente!${NC}"
if [ "$SERVICE" == "bienvenute" ]; then
    echo -e "${GREEN}🌐 Bienvenute: http://localhost:5601/swagger${NC}"
else
    echo -e "${GREEN}🌐 Pokerface: http://localhost:5602/swagger${NC}"
fi