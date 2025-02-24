# actualizar-repos.sh
#!/bin/bash

# Archivo que contiene la lista de repositorios clonados
CLONED_LIST="cloned_repos.csv"

#  Archivo de Log
LOG_FILE="actualizar_repos.log"

# Carpeta raíz para los repositorios
REPOS_DIR="repositorios"

# Funciones

# Función para registrar mensajes en el archivo de log
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - actualizar-repos.sh - $1" >> "$LOG_FILE"
}

# Función para verificar la existencia del archivo de lista de repositorios clonados
check_cloned_list() {
  if [[ ! -f "$CLONED_LIST" ]]; then
    log "Error: No se encontró el archivo $CLONED_LIST"
    exit 1
  fi
}

# Función para actualizar un repositorio
update_repo() {
  local dirname="$1"
  local repo_path="$REPOS_DIR/$dirname" # Ruta completa del repositorio

  if [[ -d "$repo_path" ]]; then
    log "Actualizando $dirname..."
    cd "$repo_path"
    if git pull; then
      log "Repositorio $dirname actualizado exitosamente."
    else
      log "Error: Falló la actualización de $dirname."
      cd "$ORIGINAL_DIR"
      return 1
    fi
    cd "$ORIGINAL_DIR"
  else
    log "Advertencia: No se encontró el directorio $repo_path"
  fi
}

# Función principal
main() {
  # Guardar directorio actual
  ORIGINAL_DIR=$(pwd)

  # Verificar la existencia del archivo de lista de repositorios clonados
  check_cloned_list

  # Leer el archivo cloned_repos.csv línea por línea
  while IFS=';' read -r dirname _; do
    update_repo "$dirname"
  done < "$CLONED_LIST"
}

# Ejecutar la función principal
main