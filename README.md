# Безопасное подключение Bitrix24

Этот обработчик принимает события сайта и создает лиды в Bitrix24.

Секретный вебхук Bitrix24 хранится на стороне Yandex Cloud Function или другого backend-хостинга, а не в HTML-коде сайта.

## 1. Создайте входящий вебхук Bitrix24

В Bitrix24:

1. Откройте `Разработчикам`.
2. Выберите `Другое`.
3. Создайте `Входящий вебхук`.
4. В правах доступа отметьте `CRM`.
5. Скопируйте URL вида:

```text
https://ваш-портал.bitrix24.ru/rest/1/секретный_код/
```

## 2. Создайте Yandex Cloud Function

Настройки:

- Runtime: Node.js 18 или новее.
- Entry point: `index.handler`.
- Файл `yandex-function.js` загрузите как `index.js`.
- Создайте публичный HTTP-триггер.

Переменные окружения:

```text
BITRIX_WEBHOOK_URL=https://ваш-портал.bitrix24.ru/rest/1/секретный_код/
ALLOWED_ORIGIN=*
```

Для строгого режима вместо `*` можно указать домен сайта, например:

```text
ALLOWED_ORIGIN=https://lkcabinet.tilda.ws
```

## 3. Подключите endpoint в HTML

После создания HTTP-триггера у вас будет публичный URL обработчика.

В каждом HTML-файле найдите строку:

```js
const CRM_ENDPOINT = window.MP_CRM_ENDPOINT || '';
```

И замените на:

```js
const CRM_ENDPOINT = window.MP_CRM_ENDPOINT || 'https://functions.yandexcloud.net/ВАШ_ID_ФУНКЦИИ';
```

## 4. Какие лиды создаются

Обработчик создает лиды для событий:

- `registration` - регистрация клиента, няни или репетитора.
- `request` - заявка клиента специалисту.
- `profile_published` - публикация анкеты специалиста.

Пароли в Bitrix24 не отправляются.
