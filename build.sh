#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                      BUILD LOCAL                   ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"

for project in Bienvenute Pokerface; do
    echo -e "\n${YELLOW}📦 Procesando $project...${NC}"
    echo -e "${BLUE}🧹 Limpiando...${NC}"
    dotnet clean ./$project/$project.csproj -c Release
    echo -e "${BLUE}📦 Publicando para linux-x64...${NC}"
    dotnet publish ./$project/$project.csproj -c Release -r linux-x64 --self-contained false -o ./$project/bin/Release/net10.0/linux-x64/publish
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error al publicar $project${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ $project publicado correctamente${NC}"
done

echo -e "\n${YELLOW}🐳 Construyendo imágenes Docker...${NC}"
docker-compose build
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al construir las imágenes${NC}"
    exit 1
fi

echo -e "\n${YELLOW}🚀 Levantando contenedores...${NC}"
docker-compose up -d
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al levantar los contenedores${NC}"
    exit 1
fi

echo -e "\n${GREEN}✅ ¡Contenedores levantados exitosamente!${NC}"
echo -e "${GREEN}🌐 Bienvenute: http://localhost:5601/swagger${NC}"
echo -e "${GREEN}🌐 Pokerface: http://localhost:5602/swagger${NC}"