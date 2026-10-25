# Практична робота № 2

## Тема: Базові засоби системи типів TypeScript

---

## Мета роботи
Опанувати синтаксис та базові інструменти типізації мови TypeScript, налаштувати середовище проєкту із суворим режимом компіляції (tsconfig.json).
Навчитися моделювати предметні області за допомогою примітивних типів, кортежів (tuples), псевдонімів типів (type aliases) та інтерфейсів (interfaces).
Засвоїти механізми комбінування типів через об'єднання (unions) та перетин (intersections).
Опанувати техніки звуження типів (type narrowing), роботу з розпізнаваними об'єднаннями (discriminated unions), розробку користувацьких захисників типу (custom type guards) та вичерпну перевірку (exhaustiveness check) через тип never.

---

## Технічне забезпечення
Операційна система: Windows, macOS або Linux.
Середовище розробки: Visual Studio Code (із розширенням TypeScript and JavaScript Language Features).
Платформа виконання: Node.js версії 18+ (LTS) та пакетний менеджер npm.
Інструменти компіляції та виконання: TypeScript (tsc) та швидкий запускач tsx.
Термінал / CLI: bash, zsh або PowerShell.
Система контролю версій: Git.

---

## Короткі теоретичні відомості
1\. Ініціалізація TypeScript-проєкту та суворий режим компіляції
TypeScript — це статично типізована надмножина мови JavaScript, яка транспілюється у чистий JavaScript. Поведінка компілятора регулюється конфігураційним файлом tsconfig.json.
Для сучасних бекенд-застосунків обов'язковим інженерним стандартом є активація прапорця "strict": true, що вмикає перевірку на null/undefined, заборону неявного типу any та жорстку перевірку контексту функцій.
Ключові параметри конфігурації tsconfig.json:
"target": "ES2022" — версія стандарту ECMAScript, у яку компілюється код;
"module": "NodeNext" — сучасна модель модульної системи для середовища Node.js;
"moduleResolution": "NodeNext" — алгоритм резолвінгу імпортованих модулів;
"strict": true — комплексний суворий режим перевірки типів;
"noImplicitAny": true — заборона оголошення змінних без типу, якщо компілятор не може його вивести;
"strictNullChecks": true — розгляд null та undefined як окремих ізольованих типів;
"noUncheckedIndexedAccess": true — безпечний доступ до елементів масивів та об'єктів з динамічними ключами.
Для комфортної та швидкої розробки без постійної ручної компіляції використовується запускач tsx, який виконує TypeScript-файли напряму без генерації проміжних .js файлів:
npm init -y
npm i -D typescript tsx @types/node
npx tsc --init
​
2\. Примітиви, кортежі (tuples), інтерфейси та безпечний тип unknown
На прикладі моделі сутності користувача соціальної мережі розглянемо опис структур даних:
// 1. Кортеж (tuple): фіксована кількість елементів із чіткими типами
type GeoCoordinates = [latitude: number, longitude: number];

// 2. Інтерфейс (interface) профілю користувача
interface UserProfile {
  readonly id: string;            // Поле доступне лише для читання (readonly)
  username: string;
  email: string;
  avatarUrl?: string;             // Опціональне поле (optional property)
  location: GeoCoordinates;
  bio: string | null;             // Може містити рядок або явне значення null
}

// 3. Безпечна робота з зовнішніми даними через unknown замість any
function parseExternalPayload(rawInput: unknown): string {
  // Тип unknown вимагає обов'язкового звуження типу (type narrowing)
  if (typeof rawInput === "string") {
    return rawInput.trim();
  }
  if (typeof rawInput === "object" && rawInput !== null && "data" in rawInput) {
    return String((rawInput as { data: unknown }).data);
  }
  throw new Error("Некоректний формат вхідних даних");
}
​
Тип unknown змушує інженера виконати попередній тайп-чекінг (type checking) перед використанням значення, на відміну від небезпечного типу any, що повністю вимикає систему типізації компілятора.
3\. Комбінування типів: Union (|) та Intersection (&)
Об'єднання типів (Union Types, |): представляють значення, яке може належати до одного з кількох зазначених типів або літералів (string literals).
Перетин типів (Intersection Types, &): об'єднують декілька типів в один, вимагаючи наявності всіх властивостей кожного типу.
// Літеральний тип (string literal union) для статусу повідомлення
type MessageStatus = "sending" | "sent" | "delivered" | "read";

// Базова сутність із метаданими аудиту (timestamp metadata)
interface AuditableEntity {
  createdAt: Date;
  updatedAt: Date;
}

// Дані текстового повідомлення
interface ChatMessageData {
  senderId: string;
  text: string;
  status: MessageStatus;
}

// Перетин типів (intersection): повна сутність містить поля повідомлення ТА аудит-мітки
type PersistedChatMessage = ChatMessageData & AuditableEntity & { id: number };
​
4\. Discriminated Unions, Type Guards та вичерпна перевірка (never)
Розпізнаване об'єднання (Discriminated Union) — патерн, коли кожен варіант типу в юніоні має спільне літеральне поле-дискримінатор (discriminant property), за яким компілятор безпомилково звужує тип.
// Варіанти контенту повідомлення зі спільним дискримінатором "kind"
interface TextContent {
  kind: "text";
  body: string;
}

interface ImageContent {
  kind: "image";
  imageUrl: string;
  fileSizeBytes: number;
}

interface AudioContent {
  kind: "audio";
  audioUrl: string;
  durationSeconds: number;
}

type MessageContent = TextContent | ImageContent | AudioContent;

// Користувацький захисник типу (Custom Type Guard із предикатом is)
function isTextContent(content: MessageContent): content is TextContent {
  return content.kind === "text";
}

// Обробка юніону з вичерпною перевіркою (Exhaustiveness checking)
function renderContent(content: MessageContent): string {
  switch (content.kind) {
    case "text":
      return `Текст: "${content.body}"`;
    case "image":
      return `Зображення: ${content.imageUrl} (${content.fileSizeBytes} байт)`;
    case "audio":
      return `Аудіозапис: ${content.audioUrl} [${content.durationSeconds} сек.]`;
    default: {
      // Якщо з'явиться новий варіант у MessageContent і не буде оброблений у switch,
      // компілятор видасть type error під час збірки завдяки типу never
      const _unhandled: never = content;
      throw new Error(`Невідомий тип повідомлення: ${_unhandled}`);
    }
  }
}
​
---

## Постановка задачі
Для забезпечення стабільності та передбачуваності бізнес-логіки бекенд-додатків на базі NestJS необхідно проєктувати сувору систему типів без використання типу any.
У межах практичної роботи необхідно розробити модуль типізованого ядра системи інтернет-магазину (E-Commerce Core Engine). Рішення повинно моделювати сутності каталогу товарів, кошика покупок, процес оформлення замовлення та різні методи оплати. Специфіка характеристик товарів та додаткові параметри замовлення визначаються індивідуальним варіантом за номером у журналі.
