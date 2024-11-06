#!/bin/bash

# Archivo de salida
output_file="monitoreo_recursos.txt"

# Encabezado del archivo
echo -e "Tiempo\t% Total de CPU Libre\t% Memoria Libre\t% Disco Libre" > $output_file
echo -e "Tiempo\t% Total de CPU Libre\t% Memoria Libre\t% Disco Libre"  # Mostrar en la terminal

# Monitoreo cada 60 segundos durante 5 minutos (5 iteraciones)
for i in {1..5}; do   # Inicia el ciclo
    # Tiempo en segundos
    tiempo=$((i * 60))

    # Uso de CPU usando top (calculamos CPU libre como 100 - uso de CPU)
    cpu_ocupado=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | tr -d '[:space:]')
    if [[ -z "$cpu_ocupado" || "$cpu_ocupado" == *[^0-9.]* ]]; then
        cpu_ocupado=0
    fi
    cpu_libre=$(echo "scale=2; 100 - $cpu_ocupado" | bc)

    # Uso de memoria
    # Obtenemos la memoria total y la memoria libre de 'free' y calculamos el porcentaje
    memoria_total=$(free | grep "Mem:" | awk '{print $2}')
    memoria_libre=$(free | grep "Mem:" | awk '{print $4}')
    if [[ -z "$memoria_total" || -z "$memoria_libre" ]]; then
        memoria_libre=0
    else
        memoria_libre_percent=$(echo "scale=2; ($memoria_libre / $memoria_total) * 100" | bc)
    fi

    # Uso de disco
    disco_libre=$(df / | grep "/" | awk '{print 100 - $5}' | tr -d '[:space:]')
    if [[ -z "$disco_libre" || "$disco_libre" == *[^0-9.]* ]]; then
        disco_libre=0
    fi

    # Mostrar en la terminal para verificar
    echo "CPU Libre: $cpu_libre%"
    echo "Memoria Libre: $memoria_libre_percent%"
    echo "Disco Libre: $disco_libre%"

    # Guardar los datos en el archivo
    echo -e "${tiempo}s\t$cpu_libre\t$memoria_libre_percent\t$disco_libre" >> $output_file

    # Esperar 60 segundos antes de la siguiente medición
    sleep 60
done  # Cierra el ciclo for

echo "Monitoreo completo. Datos guardados en $output_file."

