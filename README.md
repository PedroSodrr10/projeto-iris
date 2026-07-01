# Íris — plugin para o Claude Cowork

Íris, sua secretária executiva pessoal, entregue como **plugin do Claude Cowork**. O cliente
**só conversa em português**; a Íris cuida de agenda, e-mail, arquivos e
contexto — age no que pode, pede o sinal verde no que importa e nunca inventa.

> Este README é para o **operador** (quem instala e configura). O cliente final
> não instala nem configura nada: ele apenas conversa com a secretária.

## 🚀 Comece aqui (em 1 minuto)

**O que você precisa:**
- **Claude Desktop** com **Cowork** ativo (plano Claude Pro, ~US$20/mês).
- Uma **conta Google** (Gmail + Calendar) para a Íris ver sua agenda e e-mail.
- Uma **pasta no seu PC** onde ela pode organizar arquivos e guardar contexto.

**Como começar, depois de instalado:**
1. **Autorize os acessos** quando a Íris pedir (Gmail e Google Calendar) — é uma vez só.
2. **Comece pelo `/start-iris`.** Na primeira conversa, digite `/start-iris`: a Íris se
   apresenta e faz 3-4 perguntas rápidas pra te conhecer. (Se você só mandar um
   "oi" antes de configurar, ela também inicia a acolhida sozinha.)
3. **Depois é só falar em português, do seu jeito** — sem comandos, sem menu.
4. **Experimente pedir:**
   - *"Como tá minha agenda hoje?"*
   - *"Tem algo urgente no meu e-mail?"*
   - *"Acha o contrato da empresa X na minha pasta."*

**Bom saber:** a Íris **lê à vontade**, mas pede seu **sinal verde** antes de agir
(enviar, mover, reagendar, apagar). Ela nunca inventa — se não sabe, ela diz.

## O que vem neste plugin
- **Persona base sempre-ativa** — comportamento, tom (PT-BR, sem jargão) e política
  de aprovação ("ler é livre; agir pede sinal verde"). Injetada a cada sessão por um
  hook `SessionStart`, que também carrega preferências e memória salvas.
- **Comando `/start-iris`** — ponto de partida visível: acolhe o cliente e configura
  como a Íris vai trabalhar (nome, tom, formato, red-lines).
- **Skills de capacidade** — agenda, e-mail, organização, WhatsApp (leitura +
  envio controlado) e memória (disparam por conversa, sem comando).
- **Connectors declarados** — Gmail e Google Calendar (autorização é feita uma vez
  pelo operador no momento da instalação).

## Arquitetura em duas camadas
| Camada | O que é | Onde vive | Muda por cliente? |
|---|---|---|---|
| **Plugin** (este repositório) | persona + skills + connectors | repo GitHub público | ❌ nunca |
| **Identidade + memória** | perfil, relações, prioridades, voz, memória | pasta local autorizada no PC do cliente | ✅ sim |

O plugin é **idêntico para todos**. Toda variação por cliente vive na camada de
identidade local. **Nenhum segredo do cliente entra neste repositório.**

> As ferramentas de **build/config** (gerar a identidade do cliente a partir do
> questionário) **não fazem parte deste plugin**: são o plano do operador, mantido
> num plugin **privado, separado**. Assim o cliente só encontra capacidades de
> conversa — nunca skills de configuração.

## Instalação (operador)

### Pela interface do Claude Desktop (recomendado)
1. Abra o **Claude Desktop** → **Cowork**.
2. **Customize → Plugins**.
3. Em *Personal plugins*, clique no **"+"** → **Add marketplace** → **Add from a
   repository**.
4. Cole a URL do repositório **público** deste marketplace e confirme.
5. Instale o plugin **Íris** da lista.

> O marketplace precisa estar num repositório GitHub **público** — a sincronização
> pela interface do Cowork não autentica repositórios privados.

### Por linha de comando (desenvolvimento)
```bash
# A partir de uma cópia local deste repositório:
claude plugin marketplace add ./secretaria-plugin
claude plugin install iris@iris
```

## Connectors
Os connectors são autorizados **uma vez** pelo operador (etapa da instalação "luva").
Declarados em `.mcp.json`:

| Connector | Para quê |
|---|---|
| **Gmail** | ler a caixa, triagem, rascunhar respostas |
| **Google Calendar** | ver a agenda, preparar reuniões, propor horários |

**Organização de arquivos** funciona na **pasta local autorizada** do cliente. O
Google Drive pode ser ligado depois pelo diretório de connectors do Cowork, se o
cliente usar Drive.

## Limites desta fase
- **WhatsApp = leitura + envio controlado.** A secretária lê conversas para extrair
  contexto e envia mensagens **1:1, uma pessoa por vez, só a pedido** — nunca em
  massa, com ritmo humano (≤5 msg/min, ~100/dia, grupos só pequenos). Recusa o
  disparo em massa mesmo se pedido, para proteger a conta do cliente.
- Nenhuma ação que altera o mundo (enviar, mover, apagar, reagendar) acontece sem
  aprovação, salvo o que o cliente delegar na própria política.

## Estrutura
```
.claude-plugin/
  plugin.json        manifesto do plugin
  marketplace.json   catálogo (este repo é marketplace + plugin)
.mcp.json            connectors declarados (Gmail, Google Calendar)
context/persona.md   persona base sempre-ativa
hooks/hooks.json     injeta a persona a cada sessão (SessionStart)
skills/              capacidades (disparam por conversa)
```
