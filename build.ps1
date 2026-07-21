$projects = @("Bienvenute", "Pokerface")

Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        BUILD LOCAL - AMBOS CONTENEDORES          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan

foreach ($project in $projects) {
    Write-Host "`n📦 Procesando $project..." -ForegroundColor Yellow
    Write-Host "🧹 Limpiando..." -ForegroundColor Blue
    dotnet clean ".\$project\$project.csproj" -c Release
    Write-Host "📦 Publicando para linux-x64..." -ForegroundColor Blue
    dotnet publish ".\$project\$project.csproj" -c Release -r linux-x64 --self-contained false -o ".\$project\bin\Release\net10.0\linux-x64\publish"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error al publicar $project" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ $project publicado correctamente" -ForegroundColor Green
}

Write-Host "`n🐳 Construyendo imágenes Docker..." -ForegroundColor Yellow
docker-compose build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al construir las imágenes" -ForegroundColor Red
    exit 1
}

Write-Host "`n🚀 Levantando contenedores..." -ForegroundColor Yellow
docker-compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al levantar los contenedores" -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ ¡Contenedores levantados exitosamente!" -ForegroundColor Green
Write-Host "🌐 Bienvenute: http://localhost:5601/swagger" -ForegroundColor Green
Write-Host "🌐 Pokerface: http://localhost:5602/swagger" -ForegroundColor Green