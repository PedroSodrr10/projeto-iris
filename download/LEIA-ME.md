# Instalador da Íris

Pacote autossuficiente para instalar a Íris na máquina de um cliente:
**não precisa de Node, git nem conta no GitHub** lá. O plugin, o MCP do
WhatsApp (com `node_modules` já resolvido) e um Node portátil vão todos dentro
do `.zip`.

## Arquivos desta pasta

| Arquivo | Onde roda | O que faz |
|---|---|---|
| `build-pacote.ps1` | máquina do operador | gera `dist/IrisInstaller.zip` |
| `install.ps1` | máquina do cliente | instala tudo (vai dentro do zip) |
| `LEIA-ME.md` | — | este guia |

> O `.zip` **não é versionado** (`dist/` está no `.gitignore`). Ele tem ~54 MB e
> este repositório é o marketplace clonado por quem instala a Íris — commitar o
> binário aqui faria todo mundo baixar 54 MB a mais, para sempre. O lugar certo
> dele é como **asset de Release**.

## 1. Gerar o pacote (na sua máquina)

```powershell
powershell -ExecutionPolicy Bypass -File .\download\build-pacote.ps1
```

Refaça sempre que o plugin ou o `whatsapp-mcp` mudarem.

## 2. Publicar como Release

No GitHub → **Releases** → *Draft a new release* → crie uma tag (ex.: `v0.3.2`)
→ arraste o `dist/IrisInstaller.zip` para os *assets* → *Publish*.

A URL fica estável neste formato:

```
https://github.com/PedroSodrr10/projeto-iris/releases/download/v0.3.2/IrisInstaller.zip
```

## 3. Instalar na máquina do cliente

### Opção A (recomendada) — uma linha no PowerShell

Sem transferir arquivo: usa a internet do cliente e não trava a apresentação.
Troque `<URL>` pela URL do Release.

```powershell
$z="$env:TEMP\Iris.zip"; iwr <URL> -OutFile $z; Expand-Archive $z "$env:TEMP\Iris" -Force; Get-ChildItem "$env:TEMP\Iris" -Recurse | Unblock-File; powershell -ExecutionPolicy Bypass -File "$env:TEMP\Iris\IrisInstaller\install.ps1"
```

O `Unblock-File` não é opcional: o Windows marca arquivos baixados da internet
e o script seria bloqueado na hora de rodar.

### Opção B (offline / fallback) — transferência do AnyDesk

1. **Ctrl+C** no zip na sua máquina, **Ctrl+V** na do cliente (ou a sessão
   dedicada de *Transferência de arquivos*).
2. Extraia (botão direito → Extrair tudo).
3. Na pasta extraída:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

> 54 MB pelo relay do AnyDesk levam alguns minutos. **Faça antes de o cliente
> estar assistindo**, se tiver acesso à máquina mais cedo.

## O que o `install.ps1` faz

1. Copia plugin, `whatsapp-mcp` e Node portátil para `C:\Iris`.
2. Instala o Claude Code pelo instalador nativo, se ainda não existir.
3. Registra o marketplace **a partir da pasta local** e instala `iris@iris`.
4. Registra o MCP do WhatsApp apontando para o `node.exe` embutido.
5. Oferece o pareamento por QR code.

## O que continua manual (por design)

- **Login na conta Claude** — o cliente loga no app.
- **Connectors Gmail / Google Calendar** — autorização OAuth na GUI.
- **QR do WhatsApp** — celular do cliente: WhatsApp → Dispositivos vinculados →
  Vincular dispositivo.

## Desinstalar

```powershell
claude plugin uninstall iris@iris
claude plugin marketplace remove iris
claude mcp remove --scope user whatsapp
Remove-Item C:\Iris -Recurse -Force
```
