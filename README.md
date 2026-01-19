# TextListener

Um utilitário nativo para macOS que captura texto selecionado em qualquer aplicativo e o lê em voz alta usando TTS (Text-to-Speech).

## Características

- 🎯 **Menu Bar Only**: Roda exclusivamente na barra de menu (sem ícone no Dock)
- 🎤 **Captura de Texto**: Usa Accessibility API para capturar texto selecionado globalmente
- 🔊 **Síntese de Voz**: Utiliza AVSpeechSynthesizer para leitura em voz alta
- ⚡ **Controles de Velocidade**: Slider para ajustar a velocidade da leitura
- 🎛️ **Janela Flutuante**: Janela de controle sempre no topo com progresso da leitura
- 🎨 **UI Moderna**: Interface seguindo princípios heurísticos de Nielsen com efeitos blur

## Requisitos

- macOS 13.0+ (Ventura ou superior)
- Xcode 14.0+
- Swift 5.7+

## Estrutura do Projeto

```
TextListener/
├── TextListenerApp.swift          # App principal com MenuBarExtra
├── SpeechManager.swift            # Gerenciador de síntese de voz
├── TextCaptureManager.swift       # Captura de texto via Accessibility API
├── MenuBarView.swift              # Interface da barra de menu
├── FloatingControlWindow.swift    # Janela flutuante de controle
├── FloatingWindowModifier.swift   # Modificador para configurar janela flutuante
└── Info.plist                     # Configuração (LSUIElement = true)
```

## Configuração

### 1. Criar Projeto no Xcode

1. Abra o Xcode
2. Crie um novo projeto macOS App
3. Selecione SwiftUI como interface
4. Copie os arquivos deste repositório para o projeto

### 2. Configurar Info.plist

O arquivo `Info.plist` já está configurado com:
- `LSUIElement = true` - Remove o ícone do Dock
- Configurações de alta resolução

### 3. Permissões de Acessibilidade

O app precisa de permissões de acessibilidade para capturar texto selecionado:

1. Vá em **System Settings > Privacy & Security > Accessibility**
2. Adicione o TextListener à lista de apps permitidos
3. Reinicie o app após conceder permissões

## Uso

1. **Iniciar o App**: Execute o app - ele aparecerá apenas na barra de menu
2. **Selecionar Texto**: Selecione texto em qualquer aplicativo
3. **Ler Texto**: Clique no ícone na barra de menu e selecione "Read Selection"
4. **Controles**: Use os botões de pause/resume/stop para controlar a leitura
5. **Velocidade**: Ajuste o slider de velocidade conforme necessário
6. **Janela Flutuante**: Ative a janela flutuante para ver o progresso da leitura

## Funcionalidades Técnicas

### SpeechManager
- Gerencia síntese de voz usando `AVSpeechSynthesizer`
- Suporta play, pause, resume e stop
- Controla velocidade de fala
- Rastreia progresso da leitura (aproximado)

### TextCaptureManager
- Usa `AXUIElement` (Accessibility API) para capturar texto selecionado
- Busca recursivamente por texto selecionado na hierarquia de UI
- Fallback para clipboard se a Accessibility API falhar

### Floating Window
- Janela sempre no topo (`.floating` level)
- Efeito blur estilo expo-blur usando `NSVisualEffectView`
- Mostra progresso da leitura em tempo real
- Controles de playback integrados

## Notas de Implementação

### Accessibility API
A captura de texto usa a Accessibility API do macOS. Alguns aplicativos podem não expor texto selecionado através desta API. Nesses casos, o app usa o clipboard como fallback (requer que o usuário copie o texto manualmente).

### Progresso da Leitura
O `AVSpeechSynthesizer` não fornece progresso exato da leitura. A implementação atual usa uma estimativa baseada em tempo. Para uma implementação mais precisa, seria necessário rastrear posições de palavras/caracteres manualmente.

## Princípios de Design

A interface segue os princípios heurísticos de Nielsen:
1. **Visibilidade do Status**: Progresso e estado sempre visíveis
2. **Correspondência Sistema-Mundo**: Controles familiares (play, pause, stop)
3. **Controle do Usuário**: Controles claros para todas as ações
4. **Consistência**: Padrões de UI do macOS
5. **Prevenção de Erros**: Validação antes de ações
6. **Reconhecimento**: Ícones e labels claros
7. **Flexibilidade**: Múltiplas formas de acesso (menu bar e janela flutuante)
8. **Design Minimalista**: Interface limpa e focada

## Licença

Copyright © 2024. All rights reserved.

