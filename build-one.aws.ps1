param([string]$Service)

if (-not $Service) {
    Write-Host "❌ Uso: .\build-one.aws.ps1 <nombre-servicio> (bienvenute o pokerface)" -ForegroundColor Red
    exit 1
}
$Service = $Service.ToLower()
if ($Service -ne "bienvenute" -and $Service -ne "pokerface") {
    Write-Host "❌ Servicio no válido. Use 'bienvenute' o 'pokerface'" -ForegroundColor Red
    exit 1
}
$Project = (Get-Culture).TextInfo.ToTitleCase($Service)

Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        SUBIR IMAGEN A AWS ECR - $Project                ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

try {
    $AWS_ACCOUNT = aws sts get-caller-identity --query Account --output text
    if ($LASTEXITCODE -ne 0) { throw "Error" }
}
catch {
    Write-Host "❌ No se pudo obtener la cuenta de AWS." -ForegroundColor Red
    exit 1
}
$AWS_REGION = aws configure get region
if (-not $AWS_REGION) {
    $AWS_REGION = "us-east-1"
    Write-Host "⚠️ No se encontró región configurada, usando us-east-1 por defecto" -ForegroundColor Yellow
}
$REPO_PREFIX = "${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com"
Write-Host "✅ Cuenta AWS: $AWS_ACCOUNT, Región: $AWS_REGION" -ForegroundColor Green

Write-Host "`n🔑 Iniciando sesión en ECR..." -ForegroundColor Yellow
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REPO_PREFIX
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al hacer login en ECR" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Login exitoso" -ForegroundColor Green

Write-Host "`n📦 Procesando $Project..." -ForegroundColor Yellow
Write-Host "🧹 Limpiando..." -ForegroundColor Blue
dotnet clean ".\$Project\$Project.csproj" -c Release
Write-Host "📦 Publicando para linux-x64..." -ForegroundColor Blue
dotnet publish ".\$Project\$Project.csproj" -c Release -r linux-x64 --self-contained false -o ".\$Project\bin\Release\net10.0\linux-x64\publish"
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al publicar $Project" -ForegroundColor Red
    exit 1
}
Write-Host "✅ $Project publicado correctamente" -ForegroundColor Green

Write-Host "🐳 Construyendo imagen Docker para $Service..." -ForegroundColor Blue
docker build -t $Service -f ".\$Project\Dockerfile" .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al construir imagen" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Imagen $Service construida localmente" -ForegroundColor Green

Write-Host "🏷️ Etiquetando imagen para ECR..." -ForegroundColor Blue
docker tag $Service:latest ${REPO_PREFIX}/$Service:latest
Write-Host "⬆️ Subiendo imagen a ECR..." -ForegroundColor Blue
docker push ${REPO_PREFIX}/$Service:latest
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al subir imagen a ECR" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Imagen $Service subida a ECR" -ForegroundColor Green

Write-Host "`n✅ ¡Imagen $Service subida exitosamente a ECR!" -ForegroundColor Green