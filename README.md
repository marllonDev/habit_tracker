# 💧 Water Tracker (Lembrete de Água)

Um aplicativo moderno, fluido e inteligente desenvolvido em **Flutter** para rastrear o consumo diário de água e manter a sua hidratação em dia. 

Este projeto foi construído focando numa **Interface de Usuário (UI) Premium** com a estética de **Glassmorphism** e animações dinâmicas, combinadas com arquitetura robusta usando **Riverpod** para gerência de estado e **Hive** para armazenamento offline seguro.

---

## ✨ Funcionalidades Principais

* **🎯 Meta Diária Customizável:** Defina sua própria meta diária em mililitros (ex: 2.500 ml).
* **📱 Interface Glassmorphism:** Elementos desenhados como "vidro translúcido" sobrepostos a um fundo com gradiente escuro refinado, sem necessidade de rolagem de tela.
* **💧 Acompanhamento Visual:** Uma garrafa virtual que enche progressivamente à medida que você adiciona água e responde dinamicamente à sua porcentagem de progresso.
* **🔔 Notificações Inteligentes:** 
  * Escolha a frequência de alertas (ex: a cada 30 min, 1 hora, etc).
  * O aplicativo reagenda inteligentemente alarmes nativos (iOS e Android) em background.
  * Notificação extra e especial de "Meta Atingida" disparada exatamente quando você conclui o objetivo.
* **🎉 Animações de Celebração:** Ao atingir 100% da meta, o aplicativo comemora sua saúde com uma chuva de confetes!
* **🔄 Auto-Reset Diário:** O banco de dados rastreia o consumo por dia e reseta o copo automaticamente às 00h00, salvando seu histórico do dia anterior silenciosamente.

---

## 🛠 Tecnologias Utilizadas

* **[Flutter](https://flutter.dev/):** Framework para desenvolvimento multi-plataforma.
* **[Riverpod](https://riverpod.dev/):** Gerenciamento de estado reativo, seguro e escalável.
* **[Hive](https://docs.hivedb.dev/):** Banco de dados local NoSQL extremamente rápido para salvar o progresso offline.
* **[Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications):** Integração profunda com as APIs nativas do Android e iOS para notificações agendadas e precisas.
* **[Confetti](https://pub.dev/packages/confetti):** Biblioteca para animações 2D de partículas em alta performance.
* **[Intl](https://pub.dev/packages/intl):** Formatação local de números e moedas (ex: `2500` -> `2.500 ml`).

---

## 📸 Como a UI Funciona?

* A tela principal adapta todos os seus elementos de forma fluída no espaço disponível (usando Flex/Expanded).
* **Botões Claros:** Botões com ações destrutivas (como *Zerar Água*) possuem cores levemente avermelhadas; ações positivas (como *+250ml*) possuem identidade visual da marca.
* Ao clicar numa notificação do sistema, o aplicativo é **aberto automaticamente**.

---

## 🚀 Como Executar o Projeto

1. **Clone o repositório e acesse a pasta:**
   ```bash
   git clone <url_do_projeto>
   cd Projeto\ Game\ Flutter
   ```

2. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

3. **Gere os arquivos necessários (se houver geradores do Hive/Riverpod no futuro):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Execute no emulador ou dispositivo físico:**
   ```bash
   flutter run
   ```
   > **Nota para iOS:** Lembre-se de rodar `pod install` dentro da pasta `ios` antes de executar no simulador ou iPhone.

---

## 🔒 Permissões do Sistema

O projeto já está configurado para pedir e conceder permissões vitais de forma elegante:
- **Android:** Utiliza `SCHEDULE_EXACT_ALARM` e `POST_NOTIFICATIONS` no `AndroidManifest.xml` para precisão impecável nos alertas.
- **iOS:** Configurado com `FlutterLocalNotificationsPlugin.setPluginRegistrantCallback` no `AppDelegate.swift` para suportar alertas em background sem falhas.

---

Feito com 💙 e muita hidratação!
