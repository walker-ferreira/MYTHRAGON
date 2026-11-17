# Biblioteca de 10 NPCs — preparada, não instalada

Definições individuais em `src/server/NPCs/Definitions.luau` e validação em `Definitions.spec.luau`.

A biblioteca contempla Nara (cartógrafa), Breno (mestre das docas), Orik (ferreiro), Lyria (arquivos), Maia (herbalista), Tarek (ruínas), Isca (vigia do inverno), Félix (astrônomo), Zira (engenheira) e Doran (ferrovia). Cada personagem tem ilha, papel, aparência/paleta, três itens de catálogo futuro, três falas, saudação e despedida.

**Não gerar NPCs no mundo automaticamente.** Não conectar essa biblioteca ao Bootstrap/Start/Hub. Não ativar itens, pagamentos, estoque, recompensas ou comércio fictício.

Quando o proprietário autorizar instalação no mapa:

1. Criar modelos originais individuais e scripts de diálogo de servidor em pasta própria, preservando as definições atuais.
2. Verificar spawn sem duplicação, distância real de interação, acessibilidade por teclado e toque e nenhuma resposta de cliente concedendo objetos/moeda.
3. Definir economia real, inventário e preços no servidor antes de habilitar compras; enquanto isso usar apenas visualização sem transação.
4. Rodar specs, CI e testes Studio, e só depois publicar o candidato experimental pelo pipeline oficial.

Não há PNG, textura importada nem modelos 3D nesta entrega. As descrições visuais são orientações futuras, não arquivos de textura existentes.
