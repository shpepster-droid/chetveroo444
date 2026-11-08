ЧЕТВЕРО — готовые иконки PWA

Все файлы лежат в корне архива:
- apple-touch-icon.png — 180×180 для добавления на экран iPhone
- icon-192.png — PWA icon 192×192
- icon-512.png — PWA icon 512×512
- favicon-32.png — favicon браузера
- icon-master-1024.png — исходник 1024×1024
- manifest.json — пример манифеста PWA

Для интеграции в приложение:
1. Положи apple-touch-icon.png в корень сайта.
2. Положи остальные PNG и manifest.json в корень сайта.
3. Добавь в <head> HTML:
   <link rel="apple-touch-icon" href="./apple-touch-icon.png">
   <link rel="icon" type="image/png" sizes="32x32" href="./favicon-32.png">
   <link rel="manifest" href="./manifest.json">

Пути в manifest.json уже соответствуют расположению файлов в корне.
