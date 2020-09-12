FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim
LABEL MAINTAINER="Tanisha Kapoor" 
COPY app/release ./
ENTRYPOINT ["dotnet", "WebApplication4.dll"]
EXPOSE 80