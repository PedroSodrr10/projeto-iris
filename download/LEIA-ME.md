# Instalador da Íris — guia do operador

Esta pasta contém o **empacotador**. Se você quer apenas *instalar e usar* a
Íris, o guia certo é o [README na raiz](../README.md).

O pacote é autossuficiente: a máquina de destino **não precisa de Node, Git nem
conta no GitHub**. Plugin, MCP do WhatsApp (com `node_modules` já resolvido) e
um Node portátil vão todos dentro do `.zip`.

## Arquivos

| Arquivo | Onde roda | O que faz |
|---|---|---|
| `build-pacote.ps1` | máquina do operador | gera o pacote (Windows ou macOS) |
| `install.ps1` | máquina do cliente (Windows) | instala tudo (vai dentro do zip) |
| `install.sh` | máquina do cliente (macOS) | idem, versão Mac |
| `LEIA-ME.md` | — | este guia |

## Windows × macOS

| | Windows | macOS |
|---|---|---|
| Instalador | `install.ps1` | `install.sh` (rode com `bash install.sh`) |
| Node | `node.exe` embutido | baixado na instalação, conforme o chip |
| Tamanho do pacote | ~54 MB | ~13 MB |
| `sharp` | incluído | **removido** |

O `sharp` é o **único** módulo nativo da árvore — todo o resto é JavaScript
puro e roda igual nos dois sistemas. Ele pode sair do pacote Mac porque o
baileys o importa com `catch` e só o usa para miniatura de imagem; este MCP
só manda texto. Verificado: sem `@img`, o MCP carrega com as 6 ferramentas.

No Mac o Node **não** vai embutido: `arm64` (Apple Silicon) e `x64` (Intel) são
binários incompatíveis, e embarcar os dois dobraria o pacote. O `install.sh`
lê `node-version.txt`, detecta o chip com `uname -m` e baixa o certo.

> **O `.zip` não é versionado** (`download/dist/` está no `.gitignore`). São
> ~54 MB, e este repositório é o marketplace clonado por quem instala a Íris —
> commitar o binário faria todo mundo baixar 54 MB a mais, para sempre, sem
> possibilidade de remover sem reescrever o histórico. O lugar dele é como
> **asset de Release**.

## 1. Gerar o pacote

```powershell
# Windows (padrão)
powershell -ExecutionPolicy Bypass -File .\download\build-pacote.ps1

# macOS
powershell -ExecutionPolicy Bypass -File .\download\build-pacote.ps1 -Target mac

# Premium: some -IdentityDir '<staging do cliente>\Claude\iris\identity'
```

Refaça sempre que o plugin ou o `whatsapp-mcp` mudarem.

O script falha cedo se algo estiver faltando (`node_modules` ausente, plugin
inválido). Ele exclui do pacote: `.git`, o clone órfão `projeto-iris/`, o
próprio `dist/` e a pasta `session/` do WhatsApp — **a sessão pareada do
operador nunca vai junto**.

Parâmetros, se precisar:

| Parâmetro | Padrão |
|---|---|
| `-PluginDir` | pasta pai deste script (a raiz do repo) |
| `-McpDir` | `E:\Dev\whatsapp-mcp` |
| `-OutDir` | `download\dist` |

## 2. Publicar como Release

GitHub → **Releases** → *Draft a new release* → tag nova (ex.: `v0.3.3`) →
arraste o `dist/IrisInstaller.zip` para os assets → *Publish*.

A URL de instalação **não muda entre versões**, porque aponta para o release
mais recente:

```
https://github.com/PedroSodrr10/projeto-iris/releases/latest/download/IrisInstaller.zip
```

Publicou uma versão nova? A linha de instalação do README já pega ela sozinha —
não é preciso atualizar a documentação.

## 3. Instalar no cliente

O comando está no [README](../README.md#1-instalação). Dois cenários:

- **Com internet boa:** a linha do README baixa direto do Release. Preferível —
  usa a banda do cliente e não trava a apresentação.
- **Sem internet / AnyDesk:** transfira o zip por **Ctrl+C / Ctrl+V** do AnyDesk
  (ou a sessão de *Transferência de arquivos*), extraia e rode `install.ps1`.
  54 MB pelo relay levam alguns minutos — **faça antes de o cliente estar
  assistindo**.

## Checklist pós-instalação

O `install.ps1` cobre plugin e WhatsApp. O resto é clique seu na interface:

- [ ] Cliente logado na conta Claude
- [ ] Gmail e Google Calendar autorizados
- [ ] WhatsApp pareado (se premium)
- [ ] Identidade publicada em `%USERPROFILE%\Claude\iris\identity\`, se for premium
- [ ] Scheduled Task do briefing criada com a frase exata
- [ ] Primeira mensagem calibrada confirmada
