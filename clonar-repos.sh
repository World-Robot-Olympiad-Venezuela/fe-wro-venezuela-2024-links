# clonar_repos.sh
#!/bin/bash

# Campo con lista de repositorios
CSV_FILE="csv/fe-wro-venezuela-2024.csv" # Valor por defecto

# Archivo para almacenar la lista de repositorios clonados
CLONED_LIST="cloned_repos.csv"

#  Archivo de Log
LOG_FILE="clonar_repos.log"

# Carpeta raíz para los repositorios
REPOS_DIR="repositorios"

# Función para registrar mensajes en el archivo de log
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - clonar-repo.sh - $1" >> "$LOG_FILE"
}

# Función para verificar la existencia del archivo CSV
check_csv_file() {
  if [[ ! -f "$CSV_FILE" ]]; then
    log "Error: El archivo CSV '$CSV_FILE' no existe."
    exit 1
  fi
}

# Función para verificar si un repositorio ya fue clonado
is_repo_cloned() {
  local dirname="$1"
  grep -q "^$dirname;" "$CLONED_LIST"
}

# Función para clonar un repositorio
clone_repo() {
  local dirname="$1"
  local link="$2"

  local repo_path="$REPOS_DIR/$dirname" # Ruta completa del repositorio

  log "Clonando $link en $repo_path"
  if git clone "$link" "$repo_path"; then
    echo "$dirname;$link" >> "$CLONED_LIST"
    log "Repositorio $dirname clonado exitosamente."
  else
    log "Error: Falló la clonación de $link."
    return 1
  fi
}

# Función principal
# Función principal
main() {
  # Procesar argumentos de línea de comandos
  while getopts "f:" opt; do
    case "$opt" in
      f)
        CSV_FILE="$OPTARG"
        ;;
      \?)
        echo "Uso: $0 [-f archivo_csv]"
        exit 1
        ;;
    esac
  done

  # Verificar la existencia del archivo CSV
  check_csv_file

  # Crear el archivo de lista de repositorios clonados si no existe
  touch "$CLONED_LIST"

  # Crear la carpeta raíz si no existe
  if [[ ! -d "$REPOS_DIR" ]]; then
    mkdir "$REPOS_DIR"
    log "Creada la carpeta raíz '$REPOS_DIR'."
  fi

  # Saltar la línea de encabezado y procesar cada línea no vacía
  tail -n +2 "$CSV_FILE" | while IFS=';' read -r team country link _; do
    # Eliminar espacios en blanco al principio y al final de cada variable
    team=$(echo "$team" | tr -d '[:space:]')
    country=$(echo "$country" | tr -d '[:space:]')
    link=$(echo "$link" | tr -d '[:space:]')

    # Saltar si el enlace está vacío
    if [[ -z "$link" ]]; then
      continue
    fi

    # Transformar el nombre del equipo
    dirname=$(echo "$team" | tr -d '(),-' | tr ' ' '_')

    # Verificar si el repositorio ya fue clonado
    if is_repo_cloned "$dirname"; then
      log "El repositorio $dirname ya fue clonado. Saltando."
      continue
    fi

    # Clonar el repositorio
    if ! clone_repo "$dirname" "$link"; then
      log "Error: La clonación de $link falló."
    fi
  done
}

# Ejecutar la función principal
main