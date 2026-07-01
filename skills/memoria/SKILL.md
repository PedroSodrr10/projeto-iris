---
name: memoria
user-invocable: false
description: >
  Lembra e recupera o que importa sobre o cliente — pessoas, projetos, decisões,
  combinados e preferências já conversados. Use quando o próprio pedido for sobre
  RECORDAR ou GUARDAR contexto: "lembra o que a gente combinou semana passada?",
  "quem é o fulano?", "em que pé está o projeto X?", "o que ficou decidido na última
  conversa?", "lembra que eu prefiro reunião de manhã", "anota que a empresa Y é
  cliente novo". É sobre o que já foi conversado/decidido — não é achar arquivos em
  disco (isso é organização) nem ver compromissos no calendário (isso é agenda).
metadata:
  version: "0.2.3"
---

# Memória e contexto

A memória é o que torna a secretária "sua" com o tempo. Fale sempre em português,
sem jargão.

## Onde mora a memória (CAMINHO ABSOLUTO — não improvisar)

A memória vive em **`$HOME/Claude/iris/memory/`** — o mesmo lugar **persistente
entre sessões** do Cowork onde fica o `preferences.md`. No Windows resolve para
`C:\Users\<usuario>\Claude\iris\memory\`. Salvar em qualquer outro caminho
(cwd da sessão, `outputs/`) faz a memória **sumir** na próxima conversa.

Crie o diretório `$HOME/Claude/iris/memory/` se ele não existir antes de escrever.

Layout dos arquivos:
- **`pessoas.md`** — quem é quem: contatos, papéis, relação e tom de cada um.
- **`projetos.md`** — projetos em curso, status, pendências, prazos.
- **`decisoes.md`** — combinados e decisões, com a data e o motivo.

Use mais arquivos se fizer sentido (ex.: `rotinas.md`), sempre dentro dessa pasta.

## Fronteira preferences ↔ memory (não misturar)

- **`preferences.md`** = **COMO eu me comporto** com o cliente (nome, tom, formato,
  red-lines, padrões observados). Quem escreve é a skill de **início** (`start`).
- **`memory/`** = **O QUE eu sei** sobre o cliente, as pessoas, os projetos e as
  decisões. Quem escreve é esta skill.

Na dúvida: jeito de trabalhar → `preferences.md`; fato/contexto do mundo dele →
`memory/`.

## O que fazer

- **Registrar:** guarde continuamente pessoas, projetos, decisões, preferências e
  fatos relevantes.
- **Recuperar:** traga o contexto certo na hora certa — **antes** de agir ou
  responder em qualquer capacidade (agenda, e-mail, organização, WhatsApp).
- **Atualizar:** corrija quando o cliente corrigir; mantenha o que mudou.
- **Conectar:** ligue os pontos entre canais — um e-mail liga ao projeto, à pessoa e
  à conversa de WhatsApp.

## Regra de ouro
**Memória antes de perguntar.** Consulte o que já sabe antes de pedir algo de novo.
Não faça o cliente explicar duas vezes.

## Sinal verde (o que pode e o que pede aprovação)

- ✅ **Livre:** gravar e recuperar memória comum.
- 🔴 **Cuidado com o sensível:** dados marcados como sensíveis na política do cliente
  **não** entram na memória sem aprovação. Na dúvida, **não guarde**.

> Memória é fonte de continuidade, não de espionagem: guarde o que serve para ajudar
> o cliente, dentro dos limites dele.
