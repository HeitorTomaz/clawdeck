module AgentsHelper
  # Builds the copy-paste prompt the user sends to the OpenClaw main chat so the
  # gateway is configured to accept ClawDeck's /hooks/agent webhook for this agent.
  #
  # The shared secret is read from ENV at render time (never stored in the repo).
  # If it isn't configured yet, a clear placeholder is shown instead.
  def openclaw_setup_prompt(agent)
    agent_id = agent.webhook_agent_id.presence || "<defina o OpenClaw agent ID acima>"
    token = ENV["OPENCLAW_HOOKS_TOKEN"].presence || "<defina OPENCLAW_HOOKS_TOKEN no ClawDeck>"

    <<~PROMPT
      Voce esta configurando este OpenClaw para receber webhooks do ClawDeck.
      Aplique SOMENTE as mudancas abaixo na configuracao do gateway e nada alem disso:

      1. Habilite o sistema de hooks: defina `hooks.enabled` como true.
      2. Defina `hooks.token` como: #{token}
         (segredo compartilhado que o ClawDeck envia no header `Authorization: Bearer`).
      3. Garanta que existe um agente com id "#{agent_id}" neste gateway.
      4. Em `hooks.allowedAgentIds`, inclua "#{agent_id}" (ou use ["*"] para permitir qualquer agente).

      Nao altere mais nada. Se a alteracao de hooks exigir, reinicie o gateway para aplicar.
    PROMPT
  end
end
