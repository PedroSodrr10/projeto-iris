# build-pacote.ps1 — roda na MÁQUINA DO OPERADOR (Pedro).
# Monta dist\IrisInstaller.zip com tudo que a máquina do cliente precisa:
# plugin da Íris + whatsapp-mcp (node_modules pronto) + node.exe portátil + install.ps1.
#
# O .zip gerado NÃO é versionado (dist/ está no .gitignore): ele é publicado
# como asset de Release, para não inflar este repositório — que é o marketplace
# clonado por quem instala a Íris.
param(
    [string]$PluginDir = (Split-Path $PSScriptRoot -Parent),
    [string]$McpDir    = 'E:\Dev\whatsapp-mcp',
    [string]$OutDir    = "$PSScriptRoot\dist",
    # Identidade do cliente ja gerada pelo build-identidade (opcional).
    # Aponte para a pasta identity/ publicada no staging daquele cliente.
    # Presente => pacote PREMIUM, personalizado, NAO reutilizavel entre clientes.
    [string]$IdentityDir
)
$ErrorActionPreference = 'Stop'

# --- pré-condições (falhar cedo) ---
foreach ($d in @($PluginDir, $McpDir)) {
    if (-not (Test-Path $d)) { throw "Diretório não encontrado: $d" }
}
if (-not (Test-Path "$PluginDir\.claude-plugin\marketplace.json")) {
    throw "PluginDir não parece ser o plugin da Íris (falta .claude-plugin\marketplace.json): $PluginDir"
}
if (-not (Test-Path "$McpDir\node_modules")) {
    throw "node_modules ausente em $McpDir — rode 'npm install' lá antes de empacotar."
}
if (-not (Test-Path "$McpDir\node_modules\@img\sharp-win32-x64")) {
    throw "sharp-win32-x64 ausente — o node_modules precisa ter sido instalado num Windows x64."
}
foreach ($f in @('install.ps1', 'LEIA-ME.md')) {
    if (-not (Test-Path "$PSScriptRoot\$f")) { throw "Arquivo do instalador ausente: $f" }
}

$stage = Join-Path $OutDir 'IrisInstaller'
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force $stage | Out-Null

# --- 1. plugin da Íris ---
# Exclui: .git, o clone órfão projeto-iris\ e as pastas de artefato.
# Atenção: exclui TANTO o $OutDir atual QUANTO o dist\ padrão — um -OutDir
# apontado para fora do repo não impede que o dist\ padrão exista com um zip
# de 54 MB dentro, que seria engolido pelo pacote.
Write-Host '[1/5] Copiando plugin...'
$distPadrao = Join-Path $PSScriptRoot 'dist'
robocopy $PluginDir "$stage\plugin" /E /XD .git "$PluginDir\projeto-iris" $OutDir $distPadrao | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy do plugin falhou (código $LASTEXITCODE)" }

# --- 2. whatsapp-mcp (sem .git e SEM session/ — o cliente pareia o celular dele) ---
Write-Host '[2/5] Copiando whatsapp-mcp (com node_modules)...'
robocopy $McpDir "$stage\whatsapp-mcp" /E /XD .git session | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy do whatsapp-mcp falhou (código $LASTEXITCODE)" }

# --- 3. Node portátil (só o node.exe da LTS mais recente) ---
Write-Host '[3/5] Baixando Node LTS portátil...'
$index = Invoke-RestMethod 'https://nodejs.org/dist/index.json'
$lts = $index | Where-Object { $_.lts } | Select-Object -First 1
$ver = $lts.version
Write-Host "      Node $ver ($($lts.lts))"
$zip = Join-Path $env:TEMP "node-$ver-win-x64.zip"
Invoke-WebRequest "https://nodejs.org/dist/$ver/node-$ver-win-x64.zip" -OutFile $zip
$extract = Join-Path $env:TEMP 'iris-node-extract'
if (Test-Path $extract) { Remove-Item $extract -Recurse -Force }
Expand-Archive $zip -DestinationPath $extract
New-Item -ItemType Directory -Force "$stage\node" | Out-Null
Copy-Item "$extract\node-$ver-win-x64\node.exe" "$stage\node\node.exe"
Remove-Item $extract -Recurse -Force
Remove-Item $zip -Force

# --- 4. instalador + instruções (+ identidade, se for pacote premium) ---
Write-Host '[4/5] Copiando install.ps1 e LEIA-ME...'
Copy-Item "$PSScriptRoot\install.ps1" $stage
Copy-Item "$PSScriptRoot\LEIA-ME.md" $stage

$premium = $false
if ($IdentityDir) {
    if (-not (Test-Path $IdentityDir)) { throw "IdentityDir nao encontrado: $IdentityDir" }
    # sanidade: o build-identidade publica estes arquivos; sem eles o hook nao calibra
    foreach ($req in @('voice-and-style.md', 'north-star.md', 'delegation.md')) {
        if (-not (Test-Path (Join-Path $IdentityDir $req))) {
            throw "Identidade incompleta: falta '$req' em $IdentityDir. Rode o build-identidade ate a ativacao."
        }
    }
    if (Test-Path (Join-Path $IdentityDir '.apresentado')) {
        throw "A identidade em $IdentityDir tem o marcador .apresentado — ela ja foi usada numa sessao. Apague o marcador antes de empacotar, senao o cliente perde a saudacao calibrada."
    }
    robocopy $IdentityDir "$stage\identity" /E /XD .git | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy da identidade falhou (código $LASTEXITCODE)" }
    $premium = $true
    Write-Host "      Identidade embarcada (pacote PREMIUM, especifico deste cliente)"
}

# --- 5. zip final ---
# Nome diferente quando ha identidade: pacote premium carrega dados do cliente
# e NUNCA pode ser publicado como Release publico.
Write-Host '[5/5] Compactando...'
$nome = if ($premium) { 'IrisInstaller-PRIVADO.zip' } else { 'IrisInstaller.zip' }
$zipOut = Join-Path $OutDir $nome
if (Test-Path $zipOut) { Remove-Item $zipOut -Force }
Compress-Archive -Path $stage -DestinationPath $zipOut
$mb = [math]::Round((Get-Item $zipOut).Length / 1MB, 1)
Write-Host ''
Write-Host "Pacote pronto: $zipOut ($mb MB)"
if ($premium) {
    Write-Warning 'PACOTE PRIVADO — contem a identidade do cliente.'
    Write-Warning 'NAO publique como Release. Entregue por AnyDesk / canal direto.'
} else {
    Write-Host 'Pacote generico. Pode ser publicado como asset de Release (ver LEIA-ME.md).'
}
