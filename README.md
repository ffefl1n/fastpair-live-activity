# FastPair Live Activity for iOS 🎧

Утилита для iOS (iOS 16.2+ / iOS 17 / iOS 18), реализующая механику в стиле **Google Fast Pair** и всплывающих карточек **AirPods** для любых сторонних Bluetooth-наушников (Sony, Samsung Galaxy Buds, Google Pixel Buds, Nothing Ear, Xiaomi, Marshall и др.) через нативный механизм **Live Activities (Эфир активности)** и **Dynamic Island**.

---

## 💡 Как это работает

Поскольку Apple запрещает сторонним приложениям рисовать окна поверх других программ и SpringBoard, данная утилита использует самый близкий к нативному разрешённый интерфейс iOS:

1. **Двойной мониторинг подключения:**
   - **AVAudioSession:** мгновенно отслеживает переключение аудиовыхода на Bluetooth (A2DP / HFP / LE Audio) на системном уровне.
   - **CoreBluetooth:** фоновое сканирование BLE сервиса **Google Fast Pair** (`UUID: FE2C`) и стандартного профиля батареи GATT Battery Service (`UUID: 180F`).
2. **Запуск Live Activity:**
   - При обнаружении подключения наушников автоматически создаётся `Activity<HeadphoneActivityAttributes>`.
   - На экране блокировки и в Dynamic Island появляется стильная карточка с анимацией подключения, названием устройства и раздельным зарядом (левый / правый наушник / кейс).
3. **Авто-скрытие (как у AirPods):**
   - Карточка может автоматически сворачиваться через заданное время (например, 15 секунд, как оригинальная шторка AirPods), либо оставаться активной на всё время прослушивания.
4. **Интеграция с iOS Shortcuts (Быстрые команды):**
   - Поддержка URL-схемы `fastpair://connect?name=...` позволяет настроить автоматизацию в приложении «Команды» по триггеру «При подключении к Bluetooth» для 100% надёжного пробуждения даже после выгрузки приложения из памяти.

---

## 📱 Внешний вид карточки Live Activity

```text
+-------------------------------------------------------------+
|  🎧  Sony WF-1000XM4                      [🟢 Fast Pair]     |
|  ---------------------------------------------------------  |
|       [ L ]                [ ⚡ ]                [ R ]       |
|      Левый                 Кейс                 Правый      |
|       85%                  90%                   80%        |
|     [====-]              [====-]               [===-]       |
+-------------------------------------------------------------+
```

---

## 🛠 Быстрый старт и сборка

### Требования
- Mac с установленным **Xcode 15+**
- iOS устройство с версией **iOS 16.2 или новее** (включая iPhone 11 Pro)
- Бесплатный или платный аккаунт Apple Developer (для подписи)

### Генерация проекта через XcodeGen
В репозитории есть готовый `project.yml`. Для быстрой генерации `.xcodeproj`:

```bash
# Установка XcodeGen (если ещё не установлен)
brew install xcodegen

# Клонирование репозитория
git clone https://github.com/ffefl1n/fastpair-live-activity.git
cd fastpair-live-activity

# Генерация проекта Xcode
xcodegen generate
```

После выполнения команды откройте созданный `FastPairLiveActivity.xcodeproj` в Xcode:
1. Выберите таргеты `FastPairLiveActivity` и `HeadphoneWidgetExtension`.
2. Во вкладке **Signing & Capabilities** выберите свою команду (**Team**).
3. Запустите приложение на вашем iPhone.

---

## ⚡ Настройка автоматизации через Быстрые команды (Рекомендуется)

iOS может приостанавливать фоновые процессы приложений через некоторое время после блокировки. Чтобы запуск Live Activity срабатывал **в 100% случаев моментально**:

1. Откройте приложение **Команды (Shortcuts)** на iPhone.
2. Перейдите во вкладку **Автоматизация** -> нажмите **+** (Создать автоматизацию).
3. Выберите триггер **Bluetooth** -> выберите ваши наушники в списке устройств -> выберите **«Подключено»**.
4. Поставьте переключатель **«Немедленный запуск»** (без подтверждения).
5. В качестве действия добавьте **Открыть URL**:
   ```text
   fastpair://connect?name=Мои%20Наушники&left=85&right=85&case=90
   ```
6. Нажмите **Готово**. Теперь при каждом подключении наушников у вас моментально появляется стильная Live Activity!

---

## 📁 Структура проекта

- `Shared/HeadphoneActivityAttributes.swift` — Модель данных Live Activity (состояние батареи, название, тип наушников).
- `FastPairLiveActivity/Services/AudioRouteMonitor.swift` — Детектор подключения Bluetooth-аудио через `AVAudioSession`.
- `FastPairLiveActivity/Services/FastPairBLEScanner.swift` — BLE-сканер Fast Pair (UUID 0xFE2C) и Battery Service (0x180F).
- `FastPairLiveActivity/Services/LiveActivityManager.swift` — Управление жизненным циклом карточки Live Activity.
- `FastPairLiveActivity/Views/ContentView.swift` — Главный экран настройки, симуляции и мониторинга.
- `HeadphoneWidgetExtension/HeadphoneLiveActivityWidget.swift` — Виджет Live Activity для Lock Screen и Dynamic Island.
- `HeadphoneWidgetExtension/Views/HeadphoneCardView.swift` — SwiftUI дизайн карточки в стиле Fast Pair / AirPods.

---

## 📄 Лицензия

MIT License
