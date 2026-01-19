# 🚀 Quick Start - TextListener

## ✅ Tudo Pronto!

O projeto Xcode foi criado e compilado com sucesso! 

## 🎯 Próximos Passos

### 1. Abrir o Projeto
O projeto já está aberto no Xcode. Se não estiver, execute:
```bash
open TextListener.xcodeproj
```

### 2. Executar o App
- Pressione **⌘R** (Command + R) no Xcode
- Ou clique no botão **▶️ Run**

### 3. Conceder Permissões de Acessibilidade
**IMPORTANTE**: Na primeira execução, você precisará conceder permissões:

1. O macOS mostrará um alerta pedindo permissões de acessibilidade
2. Vá em **System Settings > Privacy & Security > Accessibility**
3. Adicione o **TextListener** à lista de apps permitidos
4. Reinicie o app

### 4. Usar o App

1. **O app aparecerá apenas na barra de menu** (sem ícone no Dock)
2. **Selecione texto** em qualquer aplicativo
3. **Clique no ícone** na barra de menu
4. **Clique em "Read Selection"** para ler o texto
5. Use os controles para **pause/resume/stop**
6. Ajuste a **velocidade** com o slider
7. Abra a **janela flutuante** para ver o progresso

## 🛠️ Comandos Úteis

### Build do Terminal
```bash
cd /Users/terryrodriguesmota/Dropbox/Cursor-ai-agent/text-listener-app
xcodebuild -project TextListener.xcodeproj -scheme TextListener -configuration Debug build
```

### Limpar Build
```bash
xcodebuild -project TextListener.xcodeproj -scheme TextListener clean
```

### Executar sem Xcode
```bash
xcodebuild -project TextListener.xcodeproj -scheme TextListener -configuration Debug build
open /Users/terryrodriguesmota/Library/Developer/Xcode/DerivedData/TextListener-*/Build/Products/Debug/TextListener.app
```

## 📝 Notas

- O app roda **exclusivamente na barra de menu** (LSUIElement = true)
- Requer **macOS 13.0+** (Ventura ou superior)
- A captura de texto usa **Accessibility API** com fallback para clipboard
- Alguns apps podem não expor texto via Accessibility API

## 🐛 Troubleshooting

### App não aparece na barra de menu
- Verifique se `LSUIElement` está como `true` no Info.plist ✅ (já configurado)

### Não consegue capturar texto
- Verifique permissões de acessibilidade em System Settings
- Alguns apps não expõem texto selecionado
- Use o fallback: copie o texto (⌘C) primeiro

### Erros de compilação
- Limpe o build: **⌘⇧K** (Product > Clean Build Folder)
- Recompile: **⌘B**

## ✨ Pronto para Usar!

O projeto está completo e funcionando. Apenas execute e conceda as permissões necessárias!

