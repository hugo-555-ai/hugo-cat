<?php
$scriptPath = '/var/www.hugo.cat/deploy.sh';
$output = [];
$returnVar = 0;

# Verificar hostname
if (php_uname('n') !== 'boniato') {
    http_response_code(403);
    die('ERROR: Este endpoint solo funciona en el servidor boniato');
}

# Verificar que el script existe
if (!file_exists($scriptPath)) {
    http_response_code(500);
    die("ERROR: Script $scriptPath no encontrado");
}

# Ejecutar el script de despliegue
exec("sudo $scriptPath 2>&1", $output, $returnVar);

header('Content-Type: text/plain; charset=utf-8');
echo "=== Despliegue hugo.cat ===\n\n";
echo implode("\n", $output) . "\n";
echo "\n=== Resultado: " . ($returnVar === 0 ? "ÉXITO" : "FALLÓ (código: $returnVar)") . " ===\n";
?>
