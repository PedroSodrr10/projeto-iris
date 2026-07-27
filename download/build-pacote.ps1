# build-pacote.ps1 — roda na MÁQUINA DO OPERADOR (Pedro).
# Monta o pacote de instalação da Íris para Windows OU macOS.
#
# O .zip gerado NÃO é versionado (dist/ está no .gitignore): ele é publicado
# como asset de Release, para não inflar este repositório — que é o marketplace
# clonado por quem instala a Íris.
#
# Diferença entre os alvos:
#   win  — leva node.exe embutido (x64) e install.ps1
#   mac  — NÃO leva Node (baixado na instalação, conforme Apple Silicon × Intel)
#          e exclui @img/sharp-win32-x64, que é binário nativo do Windows.
#          O sharp é dispensável: o baileys o importa com catch e só o usa para
#          miniatura de imagem, coisa que este MCP (só texto) nunca faz.
param(
    [ValidateSet('win', 'mac')]
    [string]$Target = 'win',
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
$instalador = if ($Target -eq 'mac') { 'install.sh' } else { 'install.ps1' }
foreach ($f in @($instalador, 'LEIA-ME.md')) {
    if (-not (Test-Path "$PSScriptRoot\$f")) { throw "Arquivo do instalador ausente: $f" }
}
if ($Target -eq 'win' -and -not (Test-Path "$McpDir\node_modules\@img\sharp-win32-x64")) {
    throw "sharp-win32-x64 ausente — para o alvo 'win' o node_modules precisa vir de um Windows x64."
}

$stage = Join-Path $OutDir 'IrisInstaller'
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force $stage | Out-Null

# --- 1. plugin da Íris ---
# Exclui: .git, o clone órfão projeto-iris\ e as pastas de artefato.
# Atenção: exclui TANTO o $OutDir atual QUANTO o dist\ padrão — um -OutDir
# apontado para fora do repo não impede que o dist\ padrão exista com um zip
# de 54 MB dentro, que seria engolido pelo pacote.
Write-Host "[1/5] Copiando plugin... (alvo: $Target)"
$distPadrao = Join-Path $PSScriptRoot 'dist'
robocopy $PluginDir "$stage\plugin" /E /XD .git "$PluginDir\projeto-iris" $OutDir $distPadrao | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy do plugin falhou (código $LASTEXITCODE)" }

# --- 2. whatsapp-mcp (sem .git e SEM session/ — o cliente pareia o celular dele) ---
Write-Host '[2/5] Copiando whatsapp-mcp (com node_modules)...'
$excluirMcp = @('.git', 'session')
if ($Target -eq 'mac') {
    # binário nativo win32 não roda no Mac; é a única dependência nativa da árvore
    $excluirMcp += (Join-Path $McpDir 'node_modules\@img')
}
robocopy $McpDir "$stage\whatsapp-mcp" /E /XD $excluirMcp | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy do whatsapp-mcp falhou (código $LASTEXITCODE)" }
if ($Target -eq 'mac' -and (Test-Path "$stage\whatsapp-mcp\node_modules\@img")) {
    throw 'Exclusao do @img falhou — o pacote mac nao pode levar binario win32.'
}

# --- 3. Node ---
Write-Host '[3/5] Resolvendo Node LTS...'
$index = Invoke-RestMethod 'https://nodejs.org/dist/index.json'
$lts = $index | Where-Object { $_.lts } | Select-Object -First 1
$ver = $lts.version
Write-Host "      Node $ver ($($lts.lts))"
if ($Target -eq 'mac') {
    # No Mac o binário é baixado na instalação: arm64 e x64 são incompatíveis,
    # e embutir os dois dobraria o pacote sem necessidade.
    Set-Content -Path "$stage\node-version.txt" -Value $ver -NoNewline -Encoding ascii
    Write-Host '      Alvo mac: versao anotada, download acontece na instalacao.'
} else {
    $zip = Join-Path $env:TEMP "node-$ver-win-x64.zip"
    Invoke-WebRequest "https://nodejs.org/dist/$ver/node-$ver-win-x64.zip" -OutFile $zip
    $extract = Join-Path $env:TEMP 'iris-node-extract'
    if (Test-Path $extract) { Remove-Item $extract -Recurse -Force }
    Expand-Archive $zip -DestinationPath $extract
    New-Item -ItemType Directory -Force "$stage\node" | Out-Null
    Copy-Item "$extract\node-$ver-win-x64\node.exe" "$stage\node\node.exe"
    Remove-Item $extract -Recurse -Force
    Remove-Item $zip -Force
}

# --- 4. instalador + instruções (+ identidade, se for pacote premium) ---
Write-Host "[4/5] Copiando $instalador e LEIA-ME..."
Copy-Item "$PSScriptRoot\$instalador" $stage
Copy-Item "$PSScriptRoot\LEIA-ME.md" $stage
if ($Target -eq 'mac') {
    # Garante LF: com CRLF o bash morre em "$'\r': command not found".
    $p = Join-Path $stage 'install.sh'
    $txt = [System.IO.File]::ReadAllText($p) -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText($p, $txt, (New-Object System.Text.UTF8Encoding $false))
}

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
$sufixoOS = if ($Target -eq 'mac') { '-mac' } else { '' }
$sufixoPriv = if ($premium) { '-PRIVADO' } else { '' }
$zipOut = Join-Path $OutDir "IrisInstaller$sufixoOS$sufixoPriv.zip"
if (Test-Path $zipOut) { Remove-Item $zipOut -Force }
# Compress-Archive grava as entradas com "\" (bug conhecido do .NET no Windows),
# o que viola a spec do ZIP (exige "/") e faz o unzip do Mac/Linux emitir
# "appears to use backslashes as path separators" ao extrair. bsdtar, embutido
# no Windows 10/11 em System32, grava "/" corretamente — troca 1:1, mesmo uso.
$tarExe = Join-Path $env:WINDIR 'System32\tar.exe'
& $tarExe -a -c -f $zipOut -C $OutDir 'IrisInstaller'
if ($LASTEXITCODE -ne 0) { throw "tar.exe falhou ao compactar (codigo $LASTEXITCODE)" }
$mb = [math]::Round((Get-Item $zipOut).Length / 1MB, 1)
Write-Host ''
Write-Host "Pacote pronto: $zipOut ($mb MB)"
if ($Target -eq 'mac') {
    Write-Host 'Alvo macOS. O zip nao preserva bit de execucao — instale com: bash install.sh'
}
if ($premium) {
    Write-Warning 'PACOTE PRIVADO — contem a identidade do cliente.'
    Write-Warning 'NAO publique como Release. Entregue por AnyDesk / canal direto.'
} else {
    Write-Host 'Pacote generico. Pode ser publicado como asset de Release (ver LEIA-ME.md).'
}
