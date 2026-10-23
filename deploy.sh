#!/bin/bash
# Script de despliegue para hugo.cat
# Solo funciona en el servidor "boniato"

set -e  # Salir en caso de error

# ========== CONFIGURACIÓN ==========
BASE_DIR="/var/www.hugo.cat"
TARGET_HTML="$BASE_DIR/html"
TARGET_UPDATE="$BASE_DIR/update"
REPO_URL="git@github.com:hugo-555-ai/hugo-cat.git"
REPO_TEMP="/tmp/hugo-cat-deploy-$$"

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
echo "Clonando repositorio en $REPO_TEMP..."
mkdir -p "$REPO_TEMP"
cd "$REPO_TEMP"
git clone --depth 1 "$REPO_URL" repo 2>&1
cd repo

# Validar estructura del repo
if [ ! -d "html" ] || [ ! -d "admin" ]; then
    echo "ERROR: Estructura del repositorio inesperada (falta html/ o admin/)"
    cd / && rm -rf "$REPO_TEMP"
    exit 1
fi

echo "Copiando archivos..."
sudo cp -r html/* "$TARGET_HTML/"
sudo cp -r admin/* "$TARGET_UPDATE/"

# ========== PERMISOS ==========
echo "Configurando permisos..."
sudo chown -R www-data:www-data "$TARGET_HTML" "$TARGET_UPDATE"
sudo chmod -R 755 "$TARGET_HTML" "$TARGET_UPDATE"
sudo chmod 644 "$TARGET_UPDATE"/pull.php

# ========== LIMPIEZA ==========
echo "Limpieza..."
cd / && rm -rf "$REPO_TEMP"

echo ""
echo "=== ✅ Despliegue completado ==="
echo "Html: $TARGET_HTML"
echo "Update: $TARGET_UPDATE"
