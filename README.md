# Volchay con Pro

Универсальный конвертер файлов с современным Acrylic-интерфейсом. Дизайн вдохновлён классическим Luna, но переосмыслен в духе Acri — frosted-glass панели, янтарный акцент, чистая типографика.

## Возможности

- **Кодировки** — UTF-8 ↔ UTF-16 (LE/BE) ↔ UTF-32 ↔ Windows-1251 ↔ KOI8-R/U ↔ ISO-8859-1/5 ↔ CP866 ↔ Mac Cyrillic
- **Изображения** — PNG ↔ JPG ↔ BMP ↔ WEBP ↔ TIFF ↔ ICO ↔ PPM ↔ XBM (со слайдером качества для JPG / WEBP)
- **Данные** — CSV ↔ JSON и Markdown → HTML
- **Кодирование** — Base64 / Hex (encode и decode)

Все режимы поддерживают drag-and-drop, авто-определение кодировки по BOM, авто-генерацию имени выходного файла и сохранение в выбранную пользователем папку.

## Дизайн

- **Подложка:** глубокий нейтральный градиент с размытыми янтарными «лампами» (FastBlur из Qt5Compat) → ощущение acrylic / frosted glass
- **Панели:** полупрозрачные карточки 14 px радиуса с 1 px тонкой границей и внутренней верхней подсветкой
- **Акцент:** янтарно-оранжевый `#F59E0B` (только он, никаких холодных оттенков)
- **Типографика:** Inter / Segoe UI, веса 400 / 600 / 700
- **Layout:** Luna-вдохновлённый — кастомный заголовок окна, сайдбар с активным янтарным маркером, главная зона со страницами

## Скачать .exe для Windows

Каждый push в `main` собирает Windows-сборку через GitHub Actions:

1. Открой страницу [Actions](../../actions) этого репозитория
2. Зайди в последний успешный run workflow `Build`
3. Скачай артефакт `Volchay-con-pro-windows-x64`
4. Распакуй и запусти `Volchay-con-pro.exe` (рядом лежат все нужные Qt-библиотеки)

При создании git-тэга `v*` (например `v0.1.0`) автоматически создаётся GitHub Release с этим архивом во вложениях.

## Сборка из исходников

### Windows (рекомендуется через Qt Online Installer)

```powershell
# 1. Установи Qt 6.6+ (Desktop MSVC 2022 64-bit) и CMake 3.21+
# 2. Из x64 Native Tools Command Prompt for VS 2022:
cmake -S . -B build -G "Ninja" -DCMAKE_PREFIX_PATH="C:/Qt/6.6.0/msvc2022_64"
cmake --build build --config Release
# 3. Упаковка зависимостей:
"C:/Qt/6.6.0/msvc2022_64/bin/windeployqt.exe" --qmldir qml build/Volchay-con-pro.exe
```

### Linux (Ubuntu 22.04+)

```bash
sudo apt-get install -y qt6-base-dev qt6-declarative-dev libqt6core5compat6-dev \
    qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-dialogs \
    qml6-module-qtquick-layouts qml6-module-qtquick-window qml6-module-qtquick-templates \
    qml6-module-qt5compat-graphicaleffects qml6-module-qt-labs-platform \
    qml6-module-qtqml-workerscript cmake ninja-build g++

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
./build/Volchay-con-pro
```

### macOS

```bash
brew install qt cmake ninja
cmake -S . -B build -G Ninja -DCMAKE_PREFIX_PATH="$(brew --prefix qt)"
cmake --build build
open build/Volchay-con-pro.app
```

## Структура

```
src/                  C++ — логика конверсий
├── main.cpp
├── ConverterController.{h,cpp}     # экспортирует API в QML
└── converters/
    ├── EncodingConverter.{h,cpp}
    ├── ImageConverter.{h,cpp}
    ├── DataConverter.{h,cpp}       # CSV ↔ JSON, Markdown → HTML
    └── EncodeConverter.{h,cpp}     # Base64, Hex
qml/                  QML — UI
├── Main.qml          # окно, фон, сайдбар, стек страниц
├── Theme.qml         # токены палитры
├── components/       # AcrylicCard, DropZone, AmberButton, …
└── pages/            # HomePage, EncodingsPage, ImagesPage, DataPage, EncodePage
resources/qml.qrc     # упаковка QML в Qt-ресурс
.github/workflows/    # CI: Linux smoke build + Windows build + Release
```

## Лицензия

[MIT](LICENSE)
