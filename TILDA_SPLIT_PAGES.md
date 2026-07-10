# Разделенные страницы для Тильды

Файлы:

- `auth.html` - вход и регистрация.
- `client-cabinet.html` - личный кабинет клиента.
- `specialist-cabinet.html` - личный кабинет няни/репетитора.
- `catalog.html` - каталог с фильтрами и карточками.
- `specialist-card.html` - публичная карточка специалиста.
- `marketplace.html` - полная версия в одном файле, оставлена как резерв.

Все файлы используют одни и те же ключи `localStorage`, поэтому пользователи, анкеты, избранное, сообщения, отзывы и заявки остаются общими.

## Страницы в Тильде

Создайте 5 страниц:

1. `/login` - вход и регистрация.
2. `/client-cabinet` - кабинет клиента.
3. `/specialist-cabinet` - кабинет специалиста.
4. `/catalog` - каталог специалистов.
5. `/specialist-card` - карточка специалиста.

## Код iframe

Замените `https://kristina-design-svg.github.io/lk-cabinet/` на ваш реальный GitHub Pages URL, если он отличается.

### Вход и регистрация

```html
<iframe src="https://kristina-design-svg.github.io/lk-cabinet/auth.html" style="width:100%;border:0;display:block;min-height:800px;" id="platformFrame"></iframe>
```

### Кабинет клиента

```html
<iframe src="https://kristina-design-svg.github.io/lk-cabinet/client-cabinet.html" style="width:100%;border:0;display:block;min-height:900px;" id="platformFrame"></iframe>
```

### Кабинет специалиста

```html
<iframe src="https://kristina-design-svg.github.io/lk-cabinet/specialist-cabinet.html" style="width:100%;border:0;display:block;min-height:900px;" id="platformFrame"></iframe>
```

### Каталог

```html
<iframe src="https://kristina-design-svg.github.io/lk-cabinet/catalog.html" style="width:100%;border:0;display:block;min-height:900px;" id="platformFrame"></iframe>
```

### Карточка специалиста

```html
<iframe src="https://kristina-design-svg.github.io/lk-cabinet/specialist-card.html" style="width:100%;border:0;display:block;min-height:900px;" id="platformFrame"></iframe>
```

## Скрипт для авто-высоты iframe

Добавьте на каждую страницу Тильды под iframe:

```html
<script>
window.addEventListener('message', function(event) {
  var frame = document.getElementById('platformFrame');
  if (!frame || !event.data) return;

  if (event.data.action === 'resize' && event.data.height) {
    frame.style.height = Math.max(700, Number(event.data.height)) + 'px';
  }

  if (event.data.action === 'goHome') {
    window.location.href = 'https://lkcabinet.tilda.ws/';
  }
});
</script>
```

Переходы между `auth.html`, `client-cabinet.html`, `specialist-cabinet.html`, `catalog.html` и `specialist-card.html` происходят внутри iframe автоматически.

## Bitrix24 через безопасный обработчик

В папке `bitrix-secure-handler` лежит готовый обработчик:

- `yandex-function.js` - код функции.
- `README.md` - инструкция по подключению.

Схема:

```text
HTML на GitHub Pages / Тильде
→ Yandex Cloud Function
→ Bitrix24 CRM
```

В HTML не хранится секретный вебхук Bitrix24. После создания функции нужно взять ее публичный URL и вставить в строку:

```js
const CRM_ENDPOINT = window.MP_CRM_ENDPOINT || '';
```

Например:

```js
const CRM_ENDPOINT = window.MP_CRM_ENDPOINT || 'https://functions.yandexcloud.net/ВАШ_ID_ФУНКЦИИ';
```

После этого в Bitrix24 будут уходить:

- регистрации;
- заявки специалистам;
- публикации анкет специалистов.
