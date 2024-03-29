**План**
* Типы серверов: Snowflake vs. Phoenix
* Модели управления инфраструктурой
* Инфраструктурная модель Base-Service-App
* Работа с образами VM: base image, bake vs fry, immutable infrastructure
* Сервисные модели: pets vs cattle
* Работа с Packer

При ручной установке и конфигурации выше шанс совершить ошибки.

**Сервера Snowflake** - ручные изменения, которые мы вносим на сервера приводят к тому, что наша инфраструктура и сервера становятся похожи на снежинки:
уникальны,
сложны для понимания,
хрупки и
неповторимы.

Мы точно не можем понять что именно позволяет им работать так, как они работают сейчас. Поэтому эти сервера очень легко могут поломаться, если в конфигурации что-то случилось. Из-за того, что настройки постоянно меняются очень сложно обновлять данные, wiki по ним и т. д.

**Сервера Phoenix**
Фаулер: "Сервер должен быть как феникс, регулярно восставая из пепла".

**Модели и методы управления инфраструктурой**

**Модели управления инфраструктурой**
**Divergence** - расхождение.
Когда есть желаемое состояние системы (target) и актуальное (actual).
В тот момент, когда мы всё настроили, target and actual is equialent.
Но после того, как люди начинают заходить на сервера, менять настройки, вносить изменения и делать это вручную, то state нашего состояние если нигде не хранится, то мы получаем модель divergence.

**Convergence** - схождение.
Смысл такой же (target and actual) - есть сервер, и есть инструменты, типа ansible or terraform, когда мы постепенно и последовательно, благодаря декларативно описанному инструментарию, мы приводим систему в целевое состояние, описанное в виде кода.
Здесь также может быть расхождение в итоге, поскольку кто-то может ходить по ssh на сервер и вносить ручные изменения.
Расхождение между target and actual называется **конфигурационным дрифтом**.
Чем чаще мы прогоняем сценарии, плэйбуки и т. д., тем ближе target and actual.

**Congruence** - соответствие.
Наше актуальное и целевое состояние идут рядом, практически совпадая (за исключением логов, временных папок и т. д.)
Immutable infrastructure, вроде контейнеров докера.

**Методы управления инфраструктурой**
* Manual
что приводит к серверам snowflake
* Scripts
настройки становятся задокументированы (можем всё вложить в один скрипт, начало процесса автоматизации)
* Infrastructure as a Code (IaC)
инструменты типа ansible, terraform, которые позволяют описывать желаемое состояние системы декларативно
* Immutable Infrastructure
Позволяет создавать неизменяемые образы, которые уже можно доставлять до production. Например, артефакты
* Immutable Delivery
Работа с контейнеризированными приложениями, позволяет создавать среду запуска приложений от разработки до production в неизменяемом виде

Чтобы эффективно управлять инфраструктурой, нужно иметь определённый взгляд на неё
**Base-Service-App модель**
**Application**
Производимые продукты, приносящие прибыль компании либо имеющие внутреннюю ценность для её работы.
Хотя сам код пишут разработчики, ops-инженеры сонастраивают его в соответствии со всеми необходимыми требованиями и зависимостями.
Dev, соответственно, должны понимать какая уже есть инфраструктура, какие есть мощности, производительность, память и т. д.
**Service**
Поддерживающие сервисы, требуемые для работы приложений.
Ops-инженеры.
Web-сервера, бд.
**Base**
Настроенная операционная система, отвечающая предъявленным требованиям и поддерживающая инфраструктура (необходимые приложения, библиотеки и т. д.)
Сюда же относится базовая настройка образа виртуальной машины.
Ops-инженеры.

**Управление базовым слоем (Base)**
----------------------------
|Базовый образ| VM instance|
----------------------------
|Ubuntu 22.04 | settings   |
----------------------------

**Fry**
Подход к созданию базового образ, когда мы:
берём минимальный образ VM и
производим минимальные настройки системы после запуска инстанса vm
называется **fry**.
Образ жарки: сырое мясо + доп. ингредиенты/специи. при которых образ "поджаривается" до готовности.

Недостатки:
* Низкая скорость деплоя
не можем гарантировать, что нужные настройки установились безошибочно до тех пор, пока не донастроим всё самостоятельно
* Возможные проблемы с установкой из сторонних репозиториев.

**Bake**
Базовый образ уже имеет часть настроек (system settings, ruby, MongoDB) и остаётся только установить нужные пакеты и дополнительные зависимости.

**Достоинства**:
* Образ содержит необходимые настройки системы
* Пакеты и сервисы заранее установлены в образ
* Ускоряется деплой
* Повышается надёжность деплоя
**Недостатки**:
* Сложности управления версиями.
Нужно самим создавать образы виртуальных машин и необходимо самому поддерживать информацию о latest версии.

**Подводя итоги**, при создании базового образы мы учитываем:
* Обязательные настройки ОС, ПО, hardening
* Скорость установки пакетов и зависимостей
можно заранее готовить свои образы, чтобы экономить на этом время
* Доступность удалённых репозиториев
* Частоту изменений

Базовый образ ОС может включать:
* Настройки ОС (ядро, сеть, DNS)
* Пакеты, зависимости с низкой частотой изменения
* Агенты мониторинга, логирования, управления конфигурацией
Например, в инстансе устанавливается агент для отправки логов - shipper, который отправляет логи приложения для нужного сервиса мониторинга.

**Immutable infrastructure**
При данном методе, все эти настройки уже включены в базовый образ:
* Образ VM становится артефактом для деплоя
* Не делаем изменений на запущенном инстансе
Достигается **congruence** - полное соответствие между target and actual state.
* Любые изменения сопровождаются билдом нового образа
* Старый инстанс сменяется новым

**Преимущества:**
* Быстрая скорость развёртывания
* Минимальный дрифт конфигурации.

**Недостатки**
* Скорость развёртывания уступает Immutable Delivery
* Not Immutable с точки зрения разработчика
Код запаковывается в образ ОС, так что образ не неизменяем
* Требуется использование IaC инструментов
* Нужна хорошая модель управления версиями образов

**Что почитать:**
Building with Legos - статья Netflix, которая пришла к этой модели
ImmutableServer - статья Фаулера, дающая представление о модели immutable infrastructure.

# Pets vs Cattle
Модель взгляда и отношений к нашим серверам.

**Pets**
Отношение к серерам как к домашним животным и любимцам.
Долгоживущие сервера, которые стараются не трогать.
* Уникальны и неповторимы
* Имеют особые имена
* Не могут заболеть
* Если болеют, то пытаемся лечить

**Cattle** (крупный рогатый скот)
* Все подобны друг другу 
* Не имеют специальных имён, обычно нумеруются
* Если болеют, то убиваем, заменяем другими такими же

Конкретные инструменты:
**Vagrant** - create and configure portable development environment.
Лучший способ протестировать что-то в другой ОС.
**Packer**:
* описание машинных образов в виде кода
* Файлы с описанием называются шаблонами (templates)
* Создание образов для AWS, GCP, Docker, VirtualBox, etc.


**user variables**
* Объявляем переменные и задаём значение по умолчанию:
"variables": {
    "proj_id": "default-project",
    "machint_type": null            # означает, что переменная обязательна для определения
    }
* Используем в шаблоне:
"builders": [
    {
     ...
     "project_id": "{{user `proj_id`}}",        # user - функция, позволяющая получить доступ к пользовательской переменной
     "machine_type": "{{user `machine_type`}}"
    }
]

* Определение переменных из командной строки:
packer build \
    -var 'project_id=steam-strategy-174408'
    ubuntu18.json
* Определение переменных через файл
packer build -var-file=variables.json ubuntu18.json

Секция builders
* Отвечает за запуск виртуальной машины из заданного базового образа и создание нового образа на его основе.

Секция provisioners
* Позволяют производить настройки ОС и установку ПО на созданной билдером машине
"provisioners": [
    {
        "type": "shell", # позволяет выполнять shell-commands на удалённой машине. Есть так же типы ansible, etc.
        "script": "install_mongodb.sh",
        "execute_command": "sudo {{.Path}}"
    }
]

**Основные команды:**
проверка синтаксиса и конфигурации:
packer validate ubuntu16.json
проверка основных секций шаблона
packer inspect ubuntu16.json


