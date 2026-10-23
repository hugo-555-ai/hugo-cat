<?php
// Configuracion
$tempDir = '/tmp/hugo-cat-deploy-' . time();
$repoUrl = 'git@github.com:hugo-555-ai/hugo-cat.git';
$output = [];
$returnVar = 0;

# Verificar hostname
if (php_uname('n') !== 'boniato') {
    http_response_code(403);
    die('ERROR: Este endpoint solo funciona en el servidor boniato');
}

# Crear directorio temporal
if (!mkdir($tempDir, 0755, true)) {
    http_response_code(500);
    die("ERROR: No se pudo crear directorio temporal $tempDir");
}

# Clonar repositorio
$output = [];
exec("sudo -u www-data git clone --depth 1 $repoUrl $tempDir/repo 2>&1", $output, $returnVar);
if ($returnVar !== 0) {
    http_response_code(500);
    die("ERROR: Fallo el clone del repositorio\n" . implode("\n", $output));
}

$deployScript = $tempDir . '/repo/deploy.sh';

# Verificar que existe deploy.sh
if (!file_exists($deployScript)) {
    http_response_code(500);
    die("ERROR: Script $deployScript no encontrado");
}

# Dar permisos de ejecucion
exec("sudo chmod +x $deployScript 2>&1", $output, $returnVar);
if ($returnVar !== 0) {
    http_response_code(500);
    die("ERROR: No se pudo dar permisos a $deployScript");
}

# Ejecutar deploy.sh
$output = [];
exec("sudo $deployScript 2>&1", $output, $returnVar);

// Limpiar temporal
exec("sudo rm -rf $tempDir 2>&1");

header('Content-Type: text/plain; charset=utf-8');
echo "=== Despliegue hugo.cat ===\n\n";
echo implode("\n", $output) . "\n";
echo "\n=== Resultado: " . ($returnVar === 0 ? "EXITO" : "FALLO (codigo: $returnVar)") . " ===\n";
?>

