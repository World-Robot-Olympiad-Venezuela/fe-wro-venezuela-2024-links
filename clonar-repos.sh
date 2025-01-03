#!/bin/bash

# Archivo para almacenar la lista de repositorios clonados
CLONED_LIST="cloned_repos.csv"
touch "$CLONED_LIST"

# Saltar la línea de encabezado y procesar cada línea no vacía
tail -n +2 fe-wro-venezuela-2024.csv | while IFS=';' read -r Equipo Enlace _; do
    # Saltar si el enlace está vacío
    if [ ! -z "$Enlace" ]; then
        # Transformar el nombre del equipo: eliminar caracteres especiales y reemplazar espacios con guiones bajos
        dirname=$(echo "$Equipo" | tr ' ' '_')

        # Verificar si este repositorio ya fue clonado
        if ! grep -q "^$dirname;" "$CLONED_LIST"; then
            echo "Clonando $Enlace en $dirname"
            if git clone "$Enlace" "$dirname"; then
                # Agregar a la lista de clonados solo si git clone fue exitoso
                echo "$dirname;$Enlace" >> "$CLONED_LIST"
            else
                echo "Error al clonar $Enlace"
            fi
        else
            echo "El repositorio $dirname ya fue clonado. Saltando."
        fi
    fi
done