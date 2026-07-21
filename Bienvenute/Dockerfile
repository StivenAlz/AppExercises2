FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 5601

# Copiar la publicacion
COPY ./bin/Release/net10.0/linux-x64/publish/ .
ENTRYPOINT ["dotnet", "Bienvenute.dll"]