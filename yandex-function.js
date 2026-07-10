const BITRIX_WEBHOOK_URL = process.env.BITRIX_WEBHOOK_URL || '';
const ALLOWED_ORIGIN = process.env.ALLOWED_ORIGIN || '*';

function response(statusCode, body) {
  return {
    statusCode,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Access-Control-Allow-Origin': ALLOWED_ORIGIN,
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type'
    },
    body: JSON.stringify(body)
  };
}

function isOriginAllowed(origin) {
  if (!ALLOWED_ORIGIN || ALLOWED_ORIGIN === '*') return true;
  return origin === ALLOWED_ORIGIN;
}

function text(value) {
  return String(value || '').trim();
}

function roleTitle(role) {
  if (role === 'tutor') return 'Репетитор';
  if (role === 'nanny') return 'Няня';
  if (role === 'client') return 'Клиент';
  return text(role) || 'Не указано';
}

function formatDate(value) {
  if (!value) return '';
  try {
    return new Date(value).toLocaleString('ru-RU', { timeZone: 'Europe/Moscow' });
  } catch (error) {
    return text(value);
  }
}

function crmFieldsForRegistration(payload) {
  const user = payload.user || {};
  const name = text(user.firstName);
  const lastName = text(user.lastName);
  const role = roleTitle(user.role);
  return {
    title: `Регистрация на платформе: ${name} ${lastName}`.trim(),
    name,
    lastName,
    sourceId: 'WEB',
    sourceDescription: 'Регистрация на сайте ПЛАТФОРМА',
    comments: [
      `Тип аккаунта: ${role}`,
      `Email: ${text(user.email)}`,
      `Телефон: ${text(user.phone)}`,
      `Дата регистрации: ${formatDate(user.createdAt)}`
    ].join('\n'),
    fm: contactFields(user.email, user.phone)
  };
}

function crmFieldsForRequest(payload) {
  const request = payload.request || {};
  return {
    title: `Заявка специалисту: ${text(request.specialistName) || 'специалист'}`,
    name: text(request.clientName),
    sourceId: 'WEB',
    sourceDescription: 'Заявка из каталога ПЛАТФОРМА',
    comments: [
      `Клиент: ${text(request.clientName)}`,
      `Email клиента: ${text(request.clientEmail)}`,
      `Телефон клиента: ${text(request.clientPhone)}`,
      `Специалист: ${text(request.specialistName)}`,
      `Тип специалиста: ${text(request.specialistType)}`,
      `Город специалиста: ${text(request.specialistCity)}`,
      `Комментарий: ${text(request.text)}`,
      `Дата заявки: ${formatDate(request.createdAt)}`
    ].join('\n'),
    fm: contactFields(request.clientEmail, request.clientPhone)
  };
}

function crmFieldsForProfile(payload) {
  const profile = payload.profile || {};
  const user = payload.user || {};
  const fullName = `${text(profile.firstName)} ${text(profile.lastName)}`.trim();
  return {
    title: `Опубликована анкета: ${fullName || 'специалист'}`,
    name: text(profile.firstName),
    lastName: text(profile.lastName),
    sourceId: 'WEB',
    sourceDescription: 'Публикация анкеты на сайте ПЛАТФОРМА',
    comments: [
      `Тип специалиста: ${text(profile.typeTitle) || roleTitle(profile.type)}`,
      `Город: ${text(profile.city)}`,
      `Район: ${text(profile.district)}`,
      `Цена: ${text(profile.price)} ₽/час`,
      `Опыт: ${text(profile.experienceYears)} лет, ${text(profile.experienceLevel)}`,
      `Предметы: ${(profile.subjects || []).join(', ')}`,
      `Возраст детей: ${(profile.childAges || []).join(', ')}`,
      `Тип занятости: ${(profile.employmentTypes || []).join(', ')}`,
      `Навыки: ${(profile.skills || []).join(', ')}`,
      `Описание: ${text(profile.about)}`,
      `Email: ${text(user.email)}`,
      `Телефон: ${text(user.phone)}`
    ].join('\n'),
    fm: contactFields(user.email, user.phone)
  };
}

function contactFields(email, phone) {
  const fm = {};
  if (text(email)) {
    fm.EMAIL = [{ VALUE: text(email), VALUE_TYPE: 'WORK' }];
  }
  if (text(phone)) {
    fm.PHONE = [{ VALUE: text(phone), VALUE_TYPE: 'WORK' }];
  }
  return fm;
}

function buildCrmFields(type, payload) {
  if (type === 'registration') return crmFieldsForRegistration(payload);
  if (type === 'request') return crmFieldsForRequest(payload);
  if (type === 'profile_published') return crmFieldsForProfile(payload);
  return {
    title: `Событие сайта: ${type}`,
    sourceId: 'WEB',
    sourceDescription: 'Событие сайта ПЛАТФОРМА',
    comments: JSON.stringify(payload, null, 2)
  };
}

async function createBitrixLead(fields) {
  const url = `${BITRIX_WEBHOOK_URL.replace(/\/$/, '')}/crm.item.add.json`;
  const bitrixResponse = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      entityTypeId: 1,
      fields
    })
  });
  const result = await bitrixResponse.json().catch(() => ({}));
  if (!bitrixResponse.ok || result.error) {
    throw new Error(result.error_description || result.error || `Bitrix HTTP ${bitrixResponse.status}`);
  }
  return result;
}

exports.handler = async function(event) {
  const origin = event.headers?.origin || event.headers?.Origin || '';
  if (origin && !isOriginAllowed(origin)) {
    return response(403, { ok: false, error: 'Origin is not allowed' });
  }

  if (event.httpMethod === 'OPTIONS') {
    return response(200, { ok: true });
  }
  if (event.httpMethod && event.httpMethod !== 'POST') {
    return response(405, { ok: false, error: 'Method not allowed' });
  }
  if (!BITRIX_WEBHOOK_URL) {
    return response(500, { ok: false, error: 'BITRIX_WEBHOOK_URL is not configured' });
  }

  try {
    const body = typeof event.body === 'string' ? JSON.parse(event.body || '{}') : (event.body || {});
    const type = text(body.type);
    const payload = body.payload || {};
    if (!type) return response(400, { ok: false, error: 'Missing event type' });

    const fields = buildCrmFields(type, payload);
    const result = await createBitrixLead(fields);
    return response(200, { ok: true, result });
  } catch (error) {
    return response(500, { ok: false, error: error.message || 'Unknown error' });
  }
};
