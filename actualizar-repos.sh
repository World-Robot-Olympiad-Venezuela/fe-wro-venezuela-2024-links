#!/bin/bash

# Archivo que contiene la lista de repositorios clonados
CLONED_LIST="cloned_repos.csv"

if [ ! -f "$CLONED_LIST" ]; then
  echo "Error: No se encontró el archivo $CLONED_LIST"
  exit 1
fi

# Guardar directorio actual
ORIGINAL_DIR=$(pwd)

# Leer el archivo cloned_repos.csv línea por línea
while IFS=';' read -r Equipo Enlace; do 
  if [ -d "$Enlace" ]; then 
    echo "Actualizando $Enlace..."
    cd "$Enlace"
    git pull
    cd "$ORIGINAL_DIR"
  else
    echo "Advertencia: No se encontró el directorio $Enlace"
  fi
done < "$CLONED_LIST"