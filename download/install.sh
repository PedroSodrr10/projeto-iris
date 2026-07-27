#!/usr/bin/env bash
# install.sh — roda na MÁQUINA DO CLIENTE (macOS), extraído do IrisInstaller-mac.zip.
#
# Equivalente ao install.ps1 do Windows. Diferença principal: o Node NÃO vem
# embutido — é baixado aqui conforme o chip do Mac (Apple Silicon × Intel),
# porque binário nativo não é portável entre arquiteturas.
#
# Uso:  bash install.sh [diretorio-de-instalacao]
set -euo pipefail

INSTALL_DIR="${1:-$HOME/Iris}"
PAYLOAD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

msg()  { printf '%s\n' "$*"; }
aviso() { printf '\033[33mAVISO: %s\033[0m\n' "$*" >&2; }
erro() { printf '\033[31mERRO: %s\033[0m\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || erro "Este instalador é para macOS. No Windows use install.ps1."

# --- pré-condições: pacote completo? ---
for p in plugin/.claude-plugin/marketplace.json whatsapp-mcp/index.js whatsapp-mcp/node_modules node-version.txt; do
  [ -e "$PAYLOAD/$p" ] || erro "Pacote incompleto: falta '$p'. Extraia o zip inteiro antes de rodar."
done

msg "== [1/6] Copiando arquivos para $INSTALL_DIR =="
mkdir -p "$INSTALL_DIR"
rm -rf "$INSTALL_DIR/plugin" "$INSTALL_DIR/whatsapp-mcp"
cp -R "$PAYLOAD/plugin" "$INSTALL_DIR/plugin"
cp -R "$PAYLOAD/whatsapp-mcp" "$INSTALL_DIR/whatsapp-mcp"
# Gatekeeper marca tudo que veio da internet; sem isso o Node se recusa a rodar.
xattr -dr com.apple.quarantine "$INSTALL_DIR" 2>/dev/null || true

msg "== [2/6] Preparando o Node =="
NODE_BIN=""
if [ -x "$INSTALL_DIR/node/bin/node" ]; then
  NODE_BIN="$INSTALL_DIR/node/bin/node"
  msg "   Reaproveitando Node de instalação anterior."
else
  NODE_VER="$(tr -d '[:space:]' < "$PAYLOAD/node-version.txt")"
  case "$(uname -m)" in
    arm64)  NARCH=arm64 ;;   # Apple Silicon
    x86_64) NARCH=x64   ;;   # Intel
    *) erro "Arquitetura não suportada: $(uname -m)" ;;
  esac
  TARBALL="node-${NODE_VER}-darwin-${NARCH}.tar.gz"
  msg "   Baixando Node ${NODE_VER} para ${NARCH}..."
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  curl -fsSL "https://nodejs.org/dist/${NODE_VER}/${TARBALL}" -o "$TMP/node.tar.gz" \
    || erro "Falha ao baixar o Node. Verifique a internet e rode de novo."
  mkdir -p "$INSTALL_DIR/node"
  tar -xzf "$TMP/node.tar.gz" -C "$INSTALL_DIR/node" --strip-components=1
  NODE_BIN="$INSTALL_DIR/node/bin/node"
fi
[ -x "$NODE_BIN" ] || erro "Node não ficou executável em $NODE_BIN"
msg "   Node: $("$NODE_BIN" --version)"

msg "== [3/6] Verificando Claude Code =="
achar_claude() {
  command -v claude 2>/dev/null && return 0
  for c in "$HOME/.local/bin/claude" "/usr/local/bin/claude" "/opt/homebrew/bin/claude"; do
    [ -x "$c" ] && { printf '%s\n' "$c"; return 0; }
  done
  return 1
}
CLAUDE="$(achar_claude || true)"
if [ -z "$CLAUDE" ]; then
  msg "   Não encontrado — instalando pelo instalador oficial..."
  curl -fsSL https://claude.ai/install.sh | bash
  export PATH="$HOME/.local/bin:$PATH"
  CLAUDE="$(achar_claude || true)"
  [ -n "$CLAUDE" ] || erro "Instalação do Claude Code falhou. Instale manualmente e rode este script de novo."
fi
msg "   Claude CLI: $CLAUDE"

msg "== [4/6] Instalando o plugin da Íris =="
"$CLAUDE" plugin marketplace remove iris >/dev/null 2>&1 || true
"$CLAUDE" plugin marketplace add "$INSTALL_DIR/plugin" || erro "Falha ao registrar o marketplace local da Íris."
"$CLAUDE" plugin install iris@iris || erro "Falha ao instalar o plugin iris."

msg "== [5/6] Registrando o MCP do WhatsApp =="
"$CLAUDE" mcp remove --scope user whatsapp >/dev/null 2>&1 || true
if ! "$CLAUDE" mcp add --scope user whatsapp "$NODE_BIN" "$INSTALL_DIR/whatsapp-mcp/index.js"; then
  aviso "Falha ao registrar o MCP do WhatsApp pelo CLI."
  aviso "Fallback: registre manualmente apontando $NODE_BIN para $INSTALL_DIR/whatsapp-mcp/index.js"
  aviso "A instalação continua — o WhatsApp fica pendente, o resto funciona."
fi

# --- identidade do cliente (premium) ---
msg "== [6/6] Camada de identidade =="
IDY_SRC="$PAYLOAD/identity"
IDY_DST="$HOME/Claude/iris/identity"
if [ -d "$IDY_SRC" ]; then
  if [ -d "$IDY_DST" ]; then
    BAK="$HOME/Claude/iris/_backups/identity-$(date +%Y-%m-%d-%H%M)"
    mkdir -p "$(dirname "$BAK")"
    mv "$IDY_DST" "$BAK"
    msg "   Identidade anterior movida para: $BAK"
  fi
  mkdir -p "$(dirname "$IDY_DST")"
  cp -R "$IDY_SRC" "$IDY_DST"
  # marcador precisa estar AUSENTE para a saudação calibrada acontecer
  rm -f "$IDY_DST/.apresentado"
  msg "   Identidade publicada em: $IDY_DST"
else
  msg "   Sem identidade no pacote — cliente segue o fluxo free (/start-iris)."
fi

msg ""
msg "== Instalação concluída =="
msg ""
msg "Verifique antes de seguir:"
msg "   $CLAUDE plugin list      (iris deve aparecer como enabled)"
msg "   $CLAUDE mcp list         (whatsapp deve aparecer)"
msg ""
msg "Falta, na interface: login na conta Claude e autorizar Gmail/Calendar."
msg ""

if [ -t 0 ]; then
  read -r -p "Parear o WhatsApp agora? Abre o QR code no navegador [S/n] " resp || resp=""
  case "${resp:-S}" in
    [Ss]|"") ( cd "$INSTALL_DIR/whatsapp-mcp" && "$NODE_BIN" pair.js )
             msg "Sessão salva. Reinicie o Claude para as ferramentas do WhatsApp aparecerem." ;;
    *) msg "Para parear depois: cd $INSTALL_DIR/whatsapp-mcp && $NODE_BIN pair.js" ;;
  esac
else
  msg "Para parear o WhatsApp: cd $INSTALL_DIR/whatsapp-mcp && $NODE_BIN pair.js"
fi
