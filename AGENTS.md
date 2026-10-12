# AGENTS.md — SteemNova (форк 2Moons)

Браузерная космическая стратегия на PHP (движок 2Moons 1.8). Этот файл — выжимка всего,
что нужно знать агенту/разработчику для правок и деплоя. Обновляй при существенных изменениях.

## Окружения

| Что | Где |
|---|---|
| Репо (публичный форк) | https://github.com/TreeLoys/steemnova (remote `fork`, ветка `master`) |
| Апстрим | steemnova/steemnova (не пушим) |
| Локальная разработка | `C:\projects\steemnova` + XAMPP portable в `C:\xampp` |
| Прод | `root@31.56.177.3` (SSH-ключ), Ubuntu 24.04, код в `/var/www/steemnova` |

- Локальный стек: `C:\xampp\start-steemnova.bat` / `stop-steemnova.bat` (Apache+MariaDB консольно, без служб).
  Локальная БД: `steemnova`, root без пароля (XAMPP по умолчанию).
- Линтер PHP локально: `C:\xampp\php\php.exe -l <file>` — гоняй перед каждым коммитом.

## Прод-сервер (НЕ ЛОМАТЬ)

- На сервере живут чужие сервисы: **agentchat** (nginx → 127.0.0.1:5080), **library**, **xray** (VPN, порт 443).
  Их не трогать. Свои правки — только в `/var/www/steemnova` и vhost `steemnova.valeriysirenko.ru`.
- **HTTPS устроен нетривиально**: TLS терминирует **xray** на 443, веб-трафик фолбэка попадает в nginx
  на `127.0.0.1:8080` (см. `/etc/nginx/sites-enabled/steemnova.valeriysirenko.ru`). Один сертификат
  Let's Encrypt на три SAN (agentchat, library, steemnova), выпущен acme.sh и ставится скриптом
  `/usr/local/etc/xray/xray_cert/xray-cert-renew` (сам вызывается cron'ом). Если нужен новый домен в HTTPS —
  добавлять SAN в сертификат и переустанавливать этим же скриптом; конфиг xray не редактировать без нужды.
- Следствие цепочки xray→nginx: **PHP видит клиентом 127.0.0.1**. Реальный IP в логах/проверках не использовать
  (например, в reCAPTCHA siteverify не передавать remoteip).
- Стек: nginx + php8.3-fpm (sock `/run/php/php8.3-fpm.sock`) + MariaDB (урезана под 1 ГБ RAM:
  `/etc/mysql/mariadb.conf.d/60-lowmem.cnf`). Диск маленький (~9 ГБ) — не раздувать.
- Креды прод-БД: юзер `steemnova`, пароль в `/var/www/steemnova/includes/config.php` (не пушить!).
  Админка игры: логин `admin`, пароль знает владелец.
- Cron игры: `/etc/cron.d/steemnova` — каждые 5 минут `cronjob.php` от www-data.

## Деплой

```bash
# локально
git add ... && git commit -m "..." && git push fork master
# на сервере
ssh root@31.56.177.3
cd /var/www/steemnova && git pull origin master
rm -rf cache/templates/*            # Smarty-кэш шаблонов — обязательно после правки .tpl
chown -R www-data:www-data cache includes
```

После деплоя проверить: главная 200, `game.php` 200 под логином, `includes/error.log` пуст.
Ключи/пароли и `includes/config.php`, `includes/error.log`, `cache/` — в `.gitignore`, в репо не попадают.

## Что уже сделано (сводка)

- Установка с нуля (install wizard), автоактивация регистраций (`user_valid=0` в `uni1_config`).
- Часовой пояс по умолчанию `Europe/Moscow`; контакты владельца в `uni1_config.disclamer*` (galaktozawr@gmail.com).
- Почищено мёртвое steem-наследие: Discord в меню, лента busy.org в сайдбаре, steem.min.js,
  кнопка SteemConnect в админке, промо на главной. Facebook-кнопки скрыты конфигом (`fb_on=0`).
- **Вход/регистрация через Google OAuth2**: `includes/classes/extauth/google.class.php` (GoogleAuth),
  кнопки `.google-btn` на главной и в регистрации. Клиент-ID/секрет — колонки `google_*` в `uni1_config`,
  вкл/выкл — `google_on`. Redirect URI в Google Cloud: `https://steemnova.valeriysirenko.ru/index.php?page=externalAuth&method=google`.
  Регистрация через Google: логин = префикс email до `@` (автоподстановка, `nicknameFromEmail`),
  email из Google, пароль генерит сервер (поля скрыты), галка правил предвыставлена, капчи нет.
- **reCAPTCHA v2** только на обычной (не-Google) регистрации: колонки `cap*` в `uni1_config`, `capaktiv=1`.
  Ключи v2 «Флажок», домен без протокола в консоли Google.
- Починена куча PHP 8.x-несовместимостей (см. ниже).

## Грабли, собранные кровью (обязательно к прочтению)

1. **Обработчик ошибок превращает warning в исключение.** В админ-режиме (`MODE=ADMIN`,
   `includes/common.php` ~217: `error_reporting(E_ERROR | E_WARNING | E_PARSE)`) любой
   `Undefined array key` даёт 503. Поэтому все чтения `$_GET[...]`/`$_POST[...]` обязаны быть
   с дефолтом: `($_GET['action'] ?? '')`. В игровом режиме warning-ы подавлены (общий фикс в common.php:33).
2. **Значения конфига из БД — int.** Сравнение `=== '1'` никогда не сработает (баг капчи).
   Только `== 1` или приведение типов.
3. **`$salt` из `includes/config.php` не в глобальной области** — файл инклюдится внутри метода
   Database. Читать так: `$salt = (function() { require 'includes/config.php'; return $salt ?? ''; })();`
4. **Анонимные сессии не переживают shutdown** (`Session::save()` удаляет сессию без userId, а после
   `delete()` нет `return` — чинено, но полагаться на анонимную сессию между запросами нельзя).
   Кросс-запросное анонимное состояние — через HMAC-подписанную куку (образец: кука `extauth`
   в ShowExternalAuthPage/ShowRegisterPage, срок 15 мин).
5. **PHP ломает куки с base64-паддингом `=`** — кодировать в url-safe base64 без `=`
   (`rtrim(strtr(base64_encode(...), '+/', '-_'), '=')`) и раскодировать обратно.
6. **Smarty компилирует шаблоны** в `cache/templates/` — после правки `.tpl` чистить, иначе правок не видно.
7. **Привязка внешних аккаунтов** — таблица `uni1_users_to_extauth` (id, account, mode), создаётся
   при активации из `uni1_users_valid.externalAuthUID/Method`. Спуф через GET-параметр закрыт
   подписанной кукой — не ослаблять.
8. **Пути include**: в `admin.php`/`game.php` разделитель `PATH_SEPARATOR` (не `:`) — иначе Windows-локалка падает.
9. Внешние сетевые ресурсы в шаблонах (fonts.googleapis и пр.) с локальной машины владельца могут
   висеть и блокировать рендер — не добавлять обратно.
10. `install/` заблокирован отсутствием `includes/ENABLE_INSTALL_TOOL` — так и должно быть на проде.

## Конвенции

- Коммиты — короткие, в стиле истории (`Fix ...`, `BOT: ...`).
- Никогда не коммитить: `includes/config.php`, `includes/error.log`, `cache/`, ключи/пароли (репо публичное!).
- Языковые строки добавлять во все 8 файлов `language/<lang>/PUBLIC.php` (ru — перевод, остальные — английский).
- Изменения конфига игры — через БД `uni1_config` (или админку), PHP-код читает колонки автоматически.

## Известные незакрытые вопросы

- **Бэкапы БД не настроены** (владелец не дал трогать серверные cron'ы) — при желании: mysqldump раз в сутки с ротацией.
- **Письма не отправляются** (нет MTA): восстановление пароля молча не работает. Google-аккаунтам пароль
  не нужен; остальным — смена через админку.
- Ротация `includes/error.log` не настроена.
- Если Google-логин падает с ошибкой доступа — проверить, что OAuth consent screen в статусе Published.
