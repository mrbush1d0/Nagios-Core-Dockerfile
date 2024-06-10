# Nagios Docker Image

Este repositorio contiene el Dockerfile para crear una imagen de Docker que instala y configura Nagios Core en un contenedor basado en Debian 12.

## Tabla de Contenidos

1. [Descripción](#descripción)
2. [Requisitos](#requisitos)
3. [Construcción de la Imagen](#construcción-de-la-imagen)
4. [Uso](#uso)
5. [Configuración](#configuración)

## Descripción

Esta imagen de Docker instala y configura Nagios Core junto con todos los complementos necesarios para su funcionamiento. Nagios es una herramienta de monitoreo de sistemas y redes que permite monitorear los servicios y recursos de la red.

## Requisitos

- Docker instalado en tu sistema. Puedes seguir las instrucciones oficiales de [Docker](https://docs.docker.com/get-docker/) para instalarlo.

## Construcción de la Imagen

Para construir la imagen de Docker, clona este repositorio y ejecuta el siguiente comando en el directorio del Dockerfile:

```bash
# Tomar los archivos desde github #
git clone https://github.com/mrbush1d0/Nagios-Core-Dockerfile.git

# Moverse al directorio #
cd Nagios-Core-Dockerfile

# generamos la imagen #
docker build -t nagios:latest .
```
## Uso del contenedor
