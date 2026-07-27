# Íris — sua secretária executiva pessoal

Íris é uma **secretária executiva** que roda dentro do Claude Desktop. Você
**só conversa em português** — sem comandos, sem menus. Ela cuida da agenda, do
e-mail, dos arquivos e do contexto: age no que pode, pede seu **sinal verde** no
que importa e **nunca inventa**.

- **Instalar** → [1. Instalação](#1-instalação)
- **Configurar** → [2. Configuração](#2-configuração)
- **Começar a usar** → [3. Primeiros passos](#3-primeiros-passos)

---

## Antes de começar

| Requisito | Detalhe |
|---|---|
| **Windows 10/11 64 bits** ou **macOS** | há instalador para os dois |
| **Claude Desktop com Cowork** | plano Claude Pro |
| **Conta Google** | Gmail + Calendar, para agenda e e-mail |
| **Celular com WhatsApp** | opcional, só se for usar o canal do zap |

Você **não precisa** instalar Node.js, Git, nem ter conta no GitHub. O
instalador já traz tudo dentro dele.

---

## 1. Instalação

### Caminho recomendado — instalador automático

**No macOS**, abra o **Terminal** e cole:

```bash
curl -fsSL https://github.com/PedroSodrr10/projeto-iris/releases/latest/download/IrisInstaller-mac.zip -o /tmp/iris.zip && unzip -oq /tmp/iris.zip -d /tmp/iris && bash /tmp/iris/IrisInstaller/install.sh
```

O Node é baixado na hora, já na arquitetura certa (Apple Silicon ou Intel).

**No Windows**, abra o **PowerShell** e cole:

```powershell
$z="$env:TEMP\Iris.zip"; iwr https://github.com/PedroSodrr10/projeto-iris/releases/latest/download/IrisInstaller.zip -OutFile $z; Expand-Archive $z "$env:TEMP\Iris" -Force; Get-ChildItem "$env:TEMP\Iris" -Recurse | Unblock-File; powershell -ExecutionPolicy Bypass -File "$env:TEMP\Iris\IrisInstaller\install.ps1"
```

Em ~2 minutos ele:

1. copia os arquivos para `C:\Iris`;
2. instala o **Claude Code** pelo instalador oficial, se ainda não existir;
3. registra o marketplace **a partir da pasta local** e instala o plugin `iris`;
4. registra o **MCP do WhatsApp** apontando para o Node que vem embutido;
5. pergunta se você quer **parear o WhatsApp** por QR code.

> **Por que o `Unblock-File`?** O Windows marca todo arquivo baixado da internet
> e bloquearia o script. Sem isso a instalação para no primeiro passo.

Prefere baixar na mão? Pegue o `IrisInstaller.zip` na
[página de releases](https://github.com/PedroSodrr10/projeto-iris/releases/latest),
extraia e rode:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

### Caminho alternativo — só o plugin, pela interface

Se você **não vai usar o WhatsApp**, dá para instalar só o plugin, sem baixar nada:

1. Claude Desktop → **Cowork**
2. **Customize → Plugins**
3. Em *Personal plugins*, **"+" → Add marketplace → Add from a repository**
4. Cole `https://github.com/PedroSodrr10/projeto-iris` e confirme
5. Instale **Íris** na lista

### Caminho de desenvolvimento

A partir de uma cópia local deste repositório:

```bash
claude plugin marketplace add ./secretaria-plugin
claude plugin install iris@iris
```

---

## 2. Configuração

### 2.1 Autorizar Gmail e Google Calendar (obrigatório)

Esses acessos **não são automatizáveis** — a autorização é sua, na interface,
uma vez só.

No Claude Desktop, vá em **Connectors / Integrações** e autorize **Gmail** e
**Google Calendar** com a sua conta.

Para conferir se funcionou, pergunte à Íris: *"o que tem na minha agenda hoje?"*

Os dois connectors já vêm declarados no `.mcp.json` do plugin:

| Connector | Para quê |
|---|---|
| **Gmail** | ler a caixa, triar, rascunhar respostas |
| **Google Calendar** | ver a agenda, preparar reuniões, propor horários |

> **Google Drive** não vem declarado. A organização de arquivos funciona na
> **pasta local** que você autorizar. Se você usa Drive, ele pode ser ligado
> depois pelo diretório de connectors do Cowork.

### 2.2 Parear o WhatsApp (opcional)

Se você respondeu **S** no final da instalação, o QR já apareceu no navegador.
Para parear depois:

```powershell
cd C:\Iris\whatsapp-mcp
..\node\node.exe pair.js
```

No celular: **WhatsApp → ⋮ → Dispositivos vinculados → Vincular dispositivo** e
aponte a câmera para o QR.

A sessão fica salva em `C:\Iris\whatsapp-mcp\session` — não precisa repetir.
**Reinicie o Claude** para as ferramentas aparecerem.

> **Proteção de conta:** a Íris envia **1:1, uma pessoa por vez, só a pedido**,
> com ritmo humano (≤5 mensagens/min, ~100/dia). Ela **recusa disparo em massa
> mesmo se você pedir** — é o que protege seu número de bloqueio.

### 2.3 Briefing automático (opcional)

Um resumo do dia (e-mail + agenda) que chega sozinho, sem você pedir.

1. No Cowork, painel **Scheduled** → **+ New task**
2. No prompt da tarefa, escreva literalmente:
   **"gerar o briefing agendado da Íris"**
3. Cadência sugerida: dias úteis, de manhã

> A frase exata importa: é o único gatilho que aciona o briefing. Falar
> *"me resume o dia"* na conversa não dispara essa tarefa — nesse caso a Íris
> responde normalmente, lendo agenda e e-mail na hora.
>
> A tarefa roda **quando o computador está ligado e o Claude aberto**. É um
> "te recebe quando você abre o app", não um despertador com horário garantido.

---

## 3. Primeiros passos

### Comece pelo `/start-iris`

Na primeira conversa, digite:

```
/start-iris
```

A Íris se apresenta e faz **3-4 perguntas rápidas** para te conhecer: como te
chamar, o tom que você prefere (formal ou à vontade), o formato das respostas
(curto ou detalhado) e o que é **assunto sensível** para você.

Se você só mandar um "oi" antes de configurar, ela inicia a acolhida sozinha.

Quer mudar algo depois? É só falar: *"prefiro respostas mais curtas"*,
*"me chama de Pedro"*. Ela ajusta e guarda.

### Depois, é só conversar

Sem comandos, sem menu. Experimente:

| Você diz | O que acontece |
|---|---|
| *"Como tá minha agenda hoje?"* | lê o calendário e resume |
| *"Tem algo urgente no e-mail?"* | tria a caixa e destaca o que importa |
| *"Rascunha uma resposta pro João, mais firme"* | escreve o rascunho e mostra |
| *"Acha o contrato da empresa X"* | procura nos seus arquivos |
| *"O que rolou com o cliente Y no zap?"* | lê a conversa e resume |
| *"Lembra que reunião só de manhã"* | guarda na memória |
| *"Em que pé está o projeto Z?"* | recupera o que já foi conversado |

### A regra do sinal verde

Isto é o mais importante para confiar nela:

| A Íris faz sozinha | A Íris pede seu OK antes |
|---|---|
| ler e-mail, agenda, arquivos e conversas | **enviar** e-mail ou mensagem |
| rascunhar respostas | **marcar / remarcar / desmarcar** compromisso |
| resumir, buscar, lembrar | **mover / renomear** arquivo |
| — | **apagar** qualquer coisa (sempre) |

E ela **nunca inventa**: se não sabe, diz que não sabe.

---

## Onde ficam suas coisas

Tudo em `C:\Users\<você>\Claude\iris\`:

| Pasta / arquivo | O que guarda |
|---|---|
| `preferences.md` | **como** ela trabalha com você: nome, tom, formato, red-lines |
| `memory/` | **o que** ela sabe: pessoas, projetos, decisões, combinados |
| `identity/` | **quem** você é — perfil, prioridades, voz (camada premium, opcional) |

Os arquivos do programa ficam em `C:\Iris` (plugin, MCP do WhatsApp e Node).

A cada sessão, um hook `SessionStart` carrega a persona, as preferências e o
índice da memória — por isso ela não te faz repetir as coisas.

---

## Capacidades

| Capacidade | O que cobre |
|---|---|
| **Agenda** | compromissos, disponibilidade, preparo de reunião, conflitos |
| **E-mail** | triagem da caixa, resumo, rascunho e envio sob aprovação |
| **WhatsApp** | leitura de conversas e envio 1:1 controlado |
| **Organização** | achar e arrumar arquivos, padronizar nomes |
| **Memória** | pessoas, projetos, decisões e combinados |
| **Briefing** | resumo diário automático (via tarefa agendada) |

As capacidades **disparam pela conversa** — você não escolhe nenhuma delas.

---

## Se algo der errado

| Sintoma | O que fazer |
|---|---|
| O script nem começa | rode o `Unblock-File` da linha de instalação; use `-ExecutionPolicy Bypass` |
| `claude` não é reconhecido logo após instalar | feche e reabra o PowerShell (o PATH só atualiza em terminal novo) |
| Ferramentas do WhatsApp não aparecem | reinicie o Claude; confirme que `C:\Iris\whatsapp-mcp\session` existe |
| Ela não vê agenda nem e-mail | os connectors não foram autorizados — ver [2.1](#21-autorizar-gmail-e-google-calendar-obrigatório) |
| Instalou versão antiga do plugin | o Cowork só atualiza quando o `version` do `plugin.json` muda |
| O briefing não chega | confirme a frase exata na tarefa e que o Claude estava aberto no horário |

---

## Desinstalar

```powershell
claude plugin uninstall iris@iris
claude plugin marketplace remove iris
claude mcp remove --scope user whatsapp
Remove-Item C:\Iris -Recurse -Force
```

Isso não apaga suas preferências e memória. Para remover também:

```powershell
Remove-Item "$env:USERPROFILE\Claude\iris" -Recurse -Force
```

---

## Para o operador

### Arquitetura em duas camadas

| Camada | O que é | Onde vive | Muda por cliente? |
|---|---|---|---|
| **Plugin** (este repo) | persona + skills + connectors | repo GitHub público | ❌ nunca |
| **Identidade + memória** | perfil, relações, prioridades, voz | pasta local no PC do cliente | ✅ sim |

O plugin é **idêntico para todos**. Toda variação vive na camada local.
**Nenhum segredo de cliente entra neste repositório.**

As ferramentas de build da identidade ficam num plugin **privado e separado** —
assim o cliente só encontra capacidades de conversa, nunca skills de configuração.

### Gerar e publicar o instalador

Ver [`download/LEIA-ME.md`](download/LEIA-ME.md).

### Estrutura do repositório

```
.claude-plugin/
  plugin.json        manifesto do plugin
  marketplace.json   catálogo (este repo é marketplace + plugin)
.mcp.json            connectors declarados (Gmail, Google Calendar)
context/persona.md   persona base sempre-ativa
hooks/hooks.json     SessionStart: persona + identidade + preferências/memória
skills/              capacidades (disparam por conversa)
  agenda/  email/  whatsapp/  organizacao/  memoria/  briefing/  start-iris/
download/            instalador para Windows (scripts; o .zip vai em Releases)
```
