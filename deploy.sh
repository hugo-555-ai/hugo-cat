#!/bin/bash
# Script de despliegue para hugo.cat
# Funciona desde cualquier directorio (autonomo)

set -e

# ========== CONFIGURACIÓN ==========
BASE_DIR="/var/www.hugo.cat"
TARGET_HTML="$BASE_DIR/html"
TARGET_UPDATE="$BASE_DIR/update"

# ========== VALIDACIONES ==========
echo "=== Despliegue hugo.cat ==="
echo "Fecha: $(date)"
echo "Servidor: $(hostname)"
echo ""

# Validar hostname
if [ "$(hostname)" != "boniato" ]; then
    echo "ERROR: Este script solo puede ejecutarse en 'boniato'"
    exit 1
fi

# Validar que los directorios existen
for dir in "$TARGET_HTML" "$TARGET_UPDATE"; do
    if [ ! -d "$dir" ]; then
        echo "ERROR: Directorio $dir no existe"
        exit 1
    fi
done

# ========== BACKUP ==========
echo "Creando backup de $TARGET_HTML..."
BACKUP_DIR="/tmp/hugo-cat-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -a "$TARGET_HTML"/* "$BACKUP_DIR"/ 2>/dev/null || echo "Advertencia: No se pudo hacer backup completo"
echo "Backup en: $BACKUP_DIR"

# ========== DESCARGA Y COPIA ==========
# El repo ya esta clonado en el directorio padre por pull.php
# Solo necesitamos copiar html/ y admin/
SCRIPT_DIR=$(dirname "$0")
REPO_DIR=$(dirname "$SCRIPT_DIR")

echo "Copiando archivos desde $REPO_DIR..."
sudo cp -r "$REPO_DIR/html/"* "$TARGET_HTML/"
sudo cp -r "$REPO_DIR/admin/"* "$TARGET_UPDATE/"

# ========== PERMISOS ==========
echo "Configurando permisos..."
sudo chown -R www-data:www-data "$TARGET_HTML" "$TARGET_UPDATE"
sudo chmod -R 755 "$TARGET_HTML" "$TARGET_UPDATE"
sudo chmod 644 "$TARGET_UPDATE"/pull.php

# ========== LIMPIEZA ==========
echo "Limpieza..."

echo ""
echo "=== ✅ Despliegue completado ==="
echo "Html: $TARGET_HTML"
echo "Update: $TARGET_UPDATE"

