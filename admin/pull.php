<?php
$repoPath = '/var/www.hugo.cat/html';
$output = [];
$returnVar = 0;

chdir($repoPath);
exec('git pull origin master 2>&1', $output, $returnVar);

header('Content-Type: text/plain; charset=utf-8');
echo "=== Git Pull en /var/www.hugo.cat/html ===\n\n";
echo implode("\n", $output) . "\n";
echo "\n=== Resultado: " . ($returnVar === 0 ? "ÉXITO" : "FALLÓ") . " ===\n";
?>
