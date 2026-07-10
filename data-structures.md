# Структура данных платформы

## Пользователь

```json
{
  "id": 101,
  "role": "tutor | nanny | client",
  "firstName": "Ирина",
  "lastName": "Иванова",
  "email": "tutor@example.ru",
  "password": "123456",
  "phone": "+79001112233",
  "favorites": [201]
}
```

## Анкета специалиста

```json
{
  "id": 201,
  "userId": 101,
  "type": "tutor | nanny",
  "status": "draft | review | published | hidden",
  "views": 128,
  "responses": 17,
  "firstName": "Ирина",
  "lastName": "Иванова",
  "city": "Москва",
  "district": "Хамовники",
  "photo": "base64",
  "rating": 4.9,
  "reviewsCount": 42,
  "experienceYears": 8,
  "experienceLevel": "Опытный",
  "price": 1600,
  "about": "Описание анкеты",
  "keywords": "математика огэ егэ",
  "subjects": ["Математика"],
  "educationLevels": ["Средняя школа"],
  "lessonFormats": ["Индивидуальные", "Онлайн"],
  "tutorSkills": ["Подготовка к ЕГЭ"],
  "teachingLanguages": ["Русский"],
  "childAges": [],
  "employmentTypes": [],
  "nannySkills": [],
  "careMethods": [],
  "extraServices": [],
  "weekdays": ["Пн", "Ср"],
  "timeFrom": "10:00",
  "timeTo": "20:00",
  "homeVisit": true,
  "homeWork": false,
  "workConditions": ["Наличие домашних животных"],
  "territories": ["На территории клиента"]
}
```

## Фильтры

```json
{
  "tutorSubjects": ["Логопед", "Обучение чтению", "Математика"],
  "educationLevels": ["Дошкольное образование", "Начальная школа"],
  "experienceLevels": ["Начинающий", "Средний", "Опытный"],
  "lessonFormats": ["Индивидуальные", "Групповые", "Онлайн", "Очные"],
  "tutorSkills": ["Подготовка к ЕГЭ", "Подготовка к ОГЭ"],
  "teachingLanguages": ["Русский", "Английский", "Другие языки"],
  "childAges": ["Новорожденные", "До 1 года", "От 1 до 3 лет"],
  "employmentTypes": ["Полный день", "Частичная занятость", "Автоняня"],
  "nannySkills": ["Педагогическое образование", "Первая помощь"],
  "careMethods": ["Игровые методики", "Развивающие занятия"],
  "extraServices": ["Приготовление пищи", "Помощь с уроками"],
  "weekdays": ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"],
  "workConditions": ["Работа с несколькими детьми", "Наличие домашних животных"],
  "territories": ["На территории специалиста", "На территории клиента"]
}
```

## Заявка

```json
{
  "id": 301,
  "profileId": 201,
  "specialistUserId": 101,
  "clientId": 103,
  "status": "new | accepted | rejected | completed",
  "text": "Новая заявка из каталога",
  "createdAt": "2026-06-21T00:00:00.000Z"
}
```

## Сообщение

```json
{
  "id": 401,
  "profileId": 201,
  "userId": 103,
  "text": "Здравствуйте! Хочу уточнить детали сотрудничества.",
  "createdAt": "2026-06-21T00:00:00.000Z"
}
```
