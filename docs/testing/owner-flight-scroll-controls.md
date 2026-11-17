# VOO-001 — voo de desenvolvimento para o proprietário

Botão **Voar** no canto superior direito, disponível no Roblox Studio e ao criador individual do Place de staging. Em voo, o botão muda para **Parar voo**, exibindo **↑ Subir**, **↓ Descer** e velocidade atual.

- **PC:** WASD para deslocamento relativo à câmera, Espaço/E para subir, Ctrl/Q para descer; a rodinha do mouse (scroll) ajusta a velocidade em intervalos de 5 (20–100).
- **Celular:** joystick do Roblox para deslocamento e botões ↑/↓ na tela para altitude. Botão Voar alterna o modo.
- **Controle:** analógico esquerdo para deslocamento, botão A para subir e B para descer, quando compatíveis com o dispositivo.
- **Servidor:** `Hub/OwnerFlight.server.luau` exige autorização pelo `CommandAccess`, cria `LinearVelocity` somente para o personagem autorizado, valida direções e velocidade, zera o movimento quando os pacotes param, limita altitude e limpa no desligamento/morte/desconexão.
- Nenhuma recompensa, item, missão, selo, DataStore ou geografia é alterada; os comandos públicos continuam indisponíveis.
- Em experiências de grupo, a autorização do proprietário via `CreatorType.User` falha de modo seguro fora do Studio.

## Testes que exigem execução Roblox

1. Entrar como criador individual do Place experimental; confirmar botão Voar e alternância ativar/desativar.
2. Testar WASD/câmera, subir/descer, scroll, colisão e distância sobre as cinco ilhas, sem atravessar o cenário.
3. Testar toque/joystick e controle (gamepad), verificando botões e sobreposição com painel de Comandos.
4. Confirmar desligamento ao morrer, renascer, desconectar ou trocar de personagem, sem ficar preso em `PlatformStand`.
5. Tentar acionar o RemoteEvent como segundo jogador sem autorização e confirmar que não voa.
6. Medir desempenho e sincronização num servidor com duas contas.

A CI, Rojo e engine isolado validam estrutura, **não** jogabilidade física nem movimento do jogador.
