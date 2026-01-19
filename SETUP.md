# Guia de Configuração do Projeto TextListener

## Passo a Passo para Criar o Projeto no Xcode

### 1. Criar Novo Projeto

1. Abra o **Xcode**
2. Selecione **File > New > Project...**
3. Escolha **macOS** como plataforma
4. Selecione **App** como template
5. Clique em **Next**

### 2. Configurar Informações do Projeto

- **Product Name**: `TextListener`
- **Team**: Selecione seu time (ou deixe None)
- **Organization Identifier**: `com.seuapp` (substitua pelo seu)
- **Bundle Identifier**: Será gerado automaticamente
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Storage**: **None** (não precisamos de Core Data)
- **Include Tests**: Opcional

Clique em **Next** e escolha onde salvar o projeto.

### 3. Adicionar Arquivos ao Projeto

No Xcode, adicione todos os arquivos da pasta `TextListener/`:

1. **Arraste os arquivos** da pasta `TextListener/` para o projeto no Xcode
2. Certifique-se de que **"Copy items if needed"** está marcado
3. Selecione **"Create groups"** (não "Create folder references")
4. Adicione ao target **TextListener**

Arquivos a adicionar:
- `TextListenerApp.swift`
- `SpeechManager.swift`
- `TextCaptureManager.swift`
- `MenuBarView.swift`
- `FloatingControlWindow.swift`
- `FloatingWindowModifier.swift`
- `Info.plist` (substitua o existente)

### 4. Configurar Info.plist

1. Selecione o arquivo `Info.plist` no projeto
2. Certifique-se de que contém a chave `LSUIElement` com valor `true`
3. Se não existir, adicione:
   - Clique no `+` ao lado de qualquer chave
   - Digite `LSUIElement`
   - Tipo: `Boolean`
   - Valor: `YES`

### 5. Configurar Build Settings

1. Selecione o projeto no navegador
2. Selecione o target **TextListener**
3. Vá para a aba **Build Settings**
4. Procure por **"Minimum Deployment"**
5. Configure **macOS Deployment Target** para **13.0** ou superior

### 6. Configurar Capabilities (Opcional mas Recomendado)

Para melhor funcionamento da Accessibility API:

1. Selecione o target **TextListener**
2. Vá para a aba **Signing & Capabilities**
3. Adicione **App Sandbox** se necessário
4. Dentro de App Sandbox, habilite:
   - **User Selected File** (Read/Write) - se necessário
   - **Network** - se necessário para futuras funcionalidades

### 7. Configurar Permissões de Acessibilidade

**IMPORTANTE**: O app precisa de permissões de acessibilidade:

1. Compile e execute o app pela primeira vez
2. Vá em **System Settings > Privacy & Security > Accessibility**
3. Adicione o **TextListener** à lista de apps permitidos
4. Reinicie o app

### 8. Testar o Projeto

1. Compile o projeto (⌘B)
2. Execute o app (⌘R)
3. Verifique se o ícone aparece na barra de menu (não deve aparecer no Dock)
4. Selecione texto em qualquer app
5. Clique no ícone na barra de menu
6. Clique em "Read Selection"

## Estrutura Final do Projeto no Xcode

```
TextListener/
├── TextListenerApp.swift
├── SpeechManager.swift
├── TextCaptureManager.swift
├── MenuBarView.swift
├── FloatingControlWindow.swift
├── FloatingWindowModifier.swift
├── Info.plist
├── Assets.xcassets/
└── Preview Content/
```

## Troubleshooting

### O app não aparece na barra de menu
- Verifique se `LSUIElement` está configurado como `true` no Info.plist
- Limpe o build folder (⌘⇧K) e recompile

### Não consegue capturar texto selecionado
- Verifique se as permissões de acessibilidade foram concedidas
- Alguns apps podem não expor texto via Accessibility API
- Use o fallback: copie o texto (⌘C) e tente novamente

### A janela flutuante não aparece
- Verifique se o WindowGroup está configurado corretamente
- Tente clicar em "Show Control Window" novamente
- Verifique os logs do Xcode para erros

### Erros de compilação
- Certifique-se de que todos os arquivos estão adicionados ao target
- Verifique se o macOS Deployment Target está em 13.0+
- Limpe o build folder e recompile

## Próximos Passos

Após configurar o projeto:

1. Teste todas as funcionalidades
2. Ajuste a velocidade padrão se necessário
3. Personalize os ícones e cores conforme desejado
4. Adicione atalhos de teclado (opcional)
5. Configure notificações (opcional)

## Notas Adicionais

- O app usa `MenuBarExtra` que requer macOS 13.0+
- A Accessibility API pode não funcionar com todos os aplicativos
- O progresso da leitura é uma estimativa (AVSpeechSynthesizer não fornece progresso exato)
- A janela flutuante usa efeitos blur nativos do macOS

