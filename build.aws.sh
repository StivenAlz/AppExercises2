#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                  SUBIR IMÁGENES A AWS ECR                ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"

AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ No se pudo obtener la cuenta de AWS.${NC}"
    exit 1
fi
AWS_REGION=$(aws configure get region)
if [ -z "$AWS_REGION" ]; then
    AWS_REGION="us-east-1"
    echo -e "${YELLOW}⚠️ No se encontró región configurada, usando us-east-1 por defecto${NC}"
fi
REPO_PREFIX="${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com"
echo -e "${GREEN}✅ Cuenta AWS: $AWS_ACCOUNT, Región: $AWS_REGION${NC}"

echo -e "\n${YELLOW}🔑 Iniciando sesión en ECR...${NC}"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REPO_PREFIX
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al hacer login en ECR${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Login exitoso${NC}"

for PROJECT in Bienvenute Pokerface; do
    SERVICE=$(echo "$PROJECT" | tr '[:upper:]' '[:lower:]')
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

    echo -e "${BLUE}🐳 Construyendo imagen Docker para $SERVICE...${NC}"
    docker build -t $SERVICE -f ./$PROJECT/Dockerfile .
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error al construir imagen${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Imagen $SERVICE construida localmente${NC}"

    echo -e "${BLUE}🏷️ Etiquetando imagen para ECR...${NC}"
    docker tag $SERVICE:latest ${REPO_PREFIX}/$SERVICE:latest
    echo -e "${BLUE}⬆️ Subiendo imagen a ECR...${NC}"
    docker push ${REPO_PREFIX}/$SERVICE:latest
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error al subir imagen a ECR${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Imagen $SERVICE subida a ECR${NC}"
done

echo -e "\n${GREEN}✅ ¡Todas las imágenes subidas exitosamente a ECR!${NC}"