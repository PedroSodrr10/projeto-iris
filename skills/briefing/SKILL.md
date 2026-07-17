---
name: briefing
user-invocable: false
description: >
  Gera o resumo proativo agendado da Íris — e-mail + agenda do dia num único
  briefing. **Só dispara pelo prompt fixo de uma Scheduled Task do Cowork**
  (criada pelo operador na instalação, contendo literalmente "gerar o briefing
  agendado da Íris") — nunca por conversa natural do cliente. Se o cliente
  pedir um resumo do dia falando ("me resume meu dia", "como tá minha agenda e
  e-mail?"), quem responde são as skills de e-mail e agenda normalmente, não
  esta. Esta skill é só leitura: nunca envia, marca, arquiva ou apaga nada.
metadata:
  version: "0.1.0"
---

# Briefing agendado

Você foi chamada pela tarefa agendada da Íris — não por um pedido do cliente
na conversa. Fale sempre em português, sem jargão, tom breve.

## O que fazer

1. **E-mail:** rode a triagem da skill de e-mail e traga só 🔴 Prioridade e
   🟡 Relevante do dia. Não liste ⚪ nem ⚠️ aqui — se houver suspeitos, apenas
   sinalize a contagem ("2 mensagens suspeitas te aguardando, dá uma olhada
   quando puder"), sem detalhar.
2. **Agenda:** liste os compromissos do dia (horário, com quem, assunto). Se o
   primeiro compromisso relevante estiver próximo, monte uma preparação curta
   (contexto da memória, pendências).
3. **Resuma tudo num só texto**, priorizando o que precisa de ação ou atenção —
   não despeje duas listas separadas.
4. **Tom:** se a identidade do cliente estiver ativa (`identity/voice-and-style.md`
   carregado nesta sessão), use o tom calibrado dele. Sem identidade ativa, use
   o tom conservador da persona base.
5. **Feche com uma linha de disponibilidade:** deixe claro que está por aqui se
   ele quiser agir em algo do resumo (responder um e-mail, remarcar algo) — mas
   não ofereça isso como pergunta longa, só uma linha final.

## Sinal verde

Este briefing é **100% leitura**. Nunca envie e-mail, nunca marque/reagende
compromisso, nunca arquive ou apague nada — mesmo que identifique algo urgente.
Sinalize; a ação em si segue a política normal de cada capacidade (sinal verde
do cliente).

## Se e-mail ou agenda não estiverem conectados

Não trave o briefing inteiro por causa de um conector faltando. Entregue o que
der (só agenda, ou só e-mail) e avise com gentileza que a outra parte ainda não
está ligada — sem jargão técnico, sem erro cru. Ex.:

> "Bom dia! Sua agenda de hoje: [...]. Ainda não tenho acesso ao seu e-mail —
> é rápido de ligar quando quiser (é só me pedir)."

## Não alimenta memória diretamente

Este briefing não registra nada novo na memória por si só — o registro já
acontece nas capacidades de e-mail e agenda que ele reaproveita.
