param([string]$Service)

if (-not $Service) {
    Write-Host "❌ Uso: .\build-one.ps1 <nombre-servicio> (bienvenute o pokerface)" -ForegroundColor Red
    exit 1
}
$Service = $Service.ToLower()
if ($Service -ne "bienvenute" -and $Service -ne "pokerface") {
    Write-Host "❌ Servicio no válido. Use 'bienvenute' o 'pokerface'" -ForegroundColor Red
    exit 1
}
$Project = (Get-Culture).TextInfo.ToTitleCase($Service)

Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        BUILD LOCAL - $Project                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan

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

Write-Host "`n🐳 Construyendo imagen Docker para $Service..." -ForegroundColor Yellow
docker-compose build $Service
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al construir la imagen" -ForegroundColor Red
    exit 1
}

Write-Host "`n🚀 Levantando contenedor $Service..." -ForegroundColor Yellow
docker-compose up -d $Service
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al levantar el contenedor" -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ ¡Contenedor $Service levantado exitosamente!" -ForegroundColor Green
if ($Service -eq "bienvenute") {
    Write-Host "🌐 Bienvenute: http://localhost:5601/swagger" -ForegroundColor Green
} else {
    Write-Host "🌐 Pokerface: http://localhost:5602/swagger" -ForegroundColor Green
}