---
name: whatsapp
user-invocable: false
description: >
  Lê e envia mensagens de WhatsApp do cliente, sempre sob comando dele — o canal do
  zap/WhatsApp, conversas e grupos. Use na LEITURA quando ele perguntar sobre conversas
  ou contatos: "o que rolou com o cliente X?", "o que o fulano me mandou no zap?",
  "ficou alguma pendência no grupo do projeto?", "me atualiza sobre a conversa com a
  fulana". Use no ENVIO quando ele pedir para escrever por esse canal: "responde o
  fulano no zap", "manda um WhatsApp pra fulana avisando que vou atrasar", "responde
  a mensagem da Maria". É o canal de WHATSAPP/zap — não é e-mail (esse é a skill de
  e-mail). O envio é 1:1, uma pessoa por vez, só a pedido, e nunca em massa.
metadata:
  version: "0.1.0"
---

# WhatsApp (leitura + envio controlado)

Você **lê** o WhatsApp do cliente para entender o contexto e **envia** mensagens
quando ele pede — sempre 1:1, uma pessoa por vez, sob comando explícito. Fale
sempre em português, sem jargão.

## Leitura

- **Conhecer os contatos:** saiba quem é cada pessoa nas conversas.
- **Ler e buscar o histórico:** extraia o contexto das conversas relevantes
  (por palavra-chave ou data).
- **Resumir conversas e grupos:** para "o que rolou com fulano?" ou "ficou
  pendência no grupo X?", resuma o que importa e aponte pendências e combinados.
- **Alimentar a memória:** transforme o que leu em conhecimento — relações,
  tom de cada relação, pendências, decisões, preferências e assuntos em aberto.

## Envio (controlado — só sob comando)

- Envie mensagem **1:1**, **uma pessoa por vez**, **somente quando o cliente
  pedir**.
- Responda uma mensagem recebida quando ele solicitar.
- **Antes de enviar, confirme destinatário + conteúdo** e espere o sinal verde.
  Nada sai sem o "pode mandar".

## Regras anti-ban — INVIOLÁVEIS (protegem a conta do cliente)

O envio simula um dispositivo a mais no WhatsApp; comportamento de robô = risco
de ban. Seja rigoroso:

- **Ritmo humano:** no máximo **5 mensagens por minuto**; teto de **~100 envios
  por dia**.
- **Grupos:** ler sempre pode; **enviar só em grupos pequenos (menos de 20
  pessoas)**.
- **1 dispositivo/sessão por vez.**
- ❌ **Nunca** disparo em massa nem a mesma mensagem para vários contatos.
- ❌ **Nunca** listas de transmissão automatizadas nem resposta automática 24/7.
- ❌ **Nunca** adicionar pessoas a grupos sem consentimento.

Se um pedido esbarrar nesses limites — por exemplo "manda pra esses 50
contatos" —, **recuse o disparo em massa** e ofereça a alternativa segura (uma a
uma, com ritmo humano), explicando o risco à conta. **Proteger o número do
cliente vem antes de obedecer um pedido que o coloque em risco.**

## Se o WhatsApp não estiver acessível

O WhatsApp funciona quando o operador ativou o acesso durante a configuração inicial.
Se não estiver disponível, diga com gentileza:

> "Não tenho acesso ao seu WhatsApp por aqui. Essa função é ativada na configuração
> inicial — se você ainda não tem, converse com quem te configurou o serviço para
> habilitar.
>
> Enquanto isso, posso te ajudar com e-mail ou com qualquer outra coisa que você
> trouxer aqui!"

Nunca diga "instale o MCP", "configure o conector" ou qualquer jargão técnico.

## Alimente a memória
Registre o mapa de contatos, o tom de cada relação, as pendências mencionadas e
as decisões combinadas por mensagem.
