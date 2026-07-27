# install.ps1 — roda na MÁQUINA DO CLIENTE (extraído do IrisInstaller.zip).
# Instala tudo que a Íris precisa sem Node, git ou conta GitHub:
#   1. copia plugin + whatsapp-mcp + node portátil para C:\Iris
#   2. instala o Claude Code (instalador nativo) se não existir
#   3. registra o marketplace local e instala o plugin iris
#   4. registra o MCP do WhatsApp apontando para o node.exe embutido
#   5. oferece o pareamento por QR code
param([string]$InstallDir = 'C:\Iris')
$ErrorActionPreference = 'Stop'

if (-not [Environment]::Is64BitOperatingSystem) { throw 'Este instalador requer Windows 64 bits.' }

# o payload fica ao lado deste script
$payload = $PSScriptRoot
foreach ($p in @('plugin\.claude-plugin\marketplace.json', 'whatsapp-mcp\index.js', 'whatsapp-mcp\node_modules', 'node\node.exe')) {
    if (-not (Test-Path (Join-Path $payload $p))) { throw "Pacote incompleto: falta '$p'. Extraia o zip inteiro antes de rodar." }
}

Write-Host "== [1/5] Copiando arquivos para $InstallDir =="
New-Item -ItemType Directory -Force $InstallDir | Out-Null
robocopy "$payload\plugin"       "$InstallDir\plugin"       /E | Out-Null
if ($LASTEXITCODE -ge 8) { throw "Falha ao copiar o plugin (robocopy $LASTEXITCODE)" }
robocopy "$payload\whatsapp-mcp" "$InstallDir\whatsapp-mcp" /E | Out-Null
if ($LASTEXITCODE -ge 8) { throw "Falha ao copiar o whatsapp-mcp (robocopy $LASTEXITCODE)" }
robocopy "$payload\node"         "$InstallDir\node"         /E | Out-Null
if ($LASTEXITCODE -ge 8) { throw "Falha ao copiar o node (robocopy $LASTEXITCODE)" }

function Find-Claude {
    $c = Get-Command claude -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    $candidates = @(
        (Join-Path $env:USERPROFILE '.local\bin\claude.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\claude\claude.exe')
    )
    foreach ($cand in $candidates) { if (Test-Path $cand) { return $cand } }
    return $null
}

Write-Host '== [2/5] Verificando Claude Code =='
$claude = Find-Claude
if (-not $claude) {
    Write-Host '   Não encontrado — instalando via instalador nativo (sem Node)...'
    Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
    $claude = Find-Claude
    if (-not $claude) { throw 'Instalação do Claude Code falhou. Instale manualmente (https://claude.ai/install.ps1) e rode este script de novo.' }
}
Write-Host "   Claude CLI: $claude"

Write-Host '== [3/5] Instalando o plugin da Íris =='
# se já houver um marketplace "iris" de instalação anterior, remove para reapontar
& $claude plugin marketplace remove iris
& $claude plugin marketplace add "$InstallDir\plugin"
if ($LASTEXITCODE -ne 0) { throw 'Falha ao registrar o marketplace local da Íris.' }
& $claude plugin install iris@iris
if ($LASTEXITCODE -ne 0) { throw 'Falha ao instalar o plugin iris.' }

Write-Host '== [4/5] Registrando o MCP do WhatsApp =='
# remove registro anterior, se houver, e recria apontando pro node embutido
& $claude mcp remove --scope user whatsapp
& $claude mcp add --scope user whatsapp "$InstallDir\node\node.exe" "$InstallDir\whatsapp-mcp\index.js"
if ($LASTEXITCODE -ne 0) { throw 'Falha ao registrar o MCP do WhatsApp.' }

Write-Host ''
Write-Host '== [5/5] Instalação concluída =='
Write-Host 'Falta apenas: login na conta Claude (no app) e autorizar Gmail/Calendar na GUI.'
Write-Host ''
$resp = Read-Host 'Parear o WhatsApp agora? Abre o QR code no navegador [S/n]'
if ($resp -eq '' -or $resp -match '^[sS]') {
    Push-Location "$InstallDir\whatsapp-mcp"
    try { & "$InstallDir\node\node.exe" pair.js }
    finally { Pop-Location }
    Write-Host 'Sessão salva. Reinicie o Claude para as ferramentas do WhatsApp aparecerem.'
} else {
    Write-Host "Para parear depois: cd $InstallDir\whatsapp-mcp ; ..\node\node.exe pair.js"
}
