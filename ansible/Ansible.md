Универсальный сценарий для настройки серверов.

Инструмент автоматизации широкого спектра различных задач, связанных с вычислительными системами:
+ настройка сетевого оборудования,
+ конфигурирование серверов,
+ деплой приложений.
Написан на питоне.

Для Ansible не нужен агент на используемых серверах, только питон.
Настраивать сервер можем сразу, как только получили доступ по SSH.
Использует yaml для описания сценария, инвентаря и переменных.
Идемпотентность.

В философии Ansible сценарий описывает состояние, в которое должна быть приведена система.

Устанавливает Ansible pip3.
Используется так же jinja2 - библиотека по работе с template'ами.

Модули Ansible:
Модули – это дискретные единицы кода, которые можно запускать с помощью командной строки или с помощью плейбука для того, чтобы вносить определенные изменения в целевой узел или собирать с него информацию. Ansible реализует каждый модуль на удалённом целевом узле, а также собирает ответные значения. Модули Ansible также известны как плагины задач или библиотечные плагины.
Ansible connection plugins:
https://docs.ansible.com/ansible/latest/plugins/connection.html
ansible-doc -t connection -l
local, paramiko_ssh, ssh.

________________________________________________________________
Установить на поиграться:
ansible -a /bin/date localhost
// модуль по умолчанию - это command. Передали туда аргумент с помощью флага -а и выполнить его на ъосте localhost.
ansible -m setup localhost
// при первом соединении с сервером, ansible собирает факты об этом сервере, такие как: ip-адреса, используемые ОС, какая дата, жёсткие диски.
ansible -m ping -i red all -u user -k (query password)
// -k - запросить пароль. -i - имя инвентаря. all - группа, указанная в инвентаре.
________________________________________________________________

PLAY RECAP **********************
servers.*   : ok=3 (сколько задач выполнено) changed=4 (сколько модифицировано) unreachable=0 (до какого числа серверов не удалось добраться) failed=0 (сколько провалилось)
servers.*   : ok=3 (сколько задач выполнено) changed=4 (сколько модифицировано) unreachable=0 (до какого числа серверов не удалось добраться) failed=0 (сколько провалилось)
servers.*   : ok=3 (сколько задач выполнено) changed=4 (сколько модифицировано) unreachable=0 (до какого числа серверов не удалось добраться) failed=0 (сколько провалилось)

Flags for ansible-playbook
#ansible-playbook playbook.yml

--diff (какие именно изменения совершил task)
--force-handlers (выполнять handlers независимо от того завершился успешно task или нет)
--inventory (where is an inventory?)
--limit (выполнять task'и не на всех серверах, а только на одном, двух, трёх и т. д.)??????
--step (step by step. Are you sure for continue?)
--syntax-check
--check - запускает Ansible в режиме, когда task выполняется, но изменений не происходит.
--become (повышение привилегий - sudo перед task'ом)
--ask-pass (-k - query for password for ssh)

for debug:
-vvvvv - verbose
ansible.cfg: stdout_callback = debug
Playbook strategy: debug
Также можно указать в таске или плейбуке:
debugger: on_failed
Задать переменную окружения ANSIBLE_ENABLE_TASK_DEBUGGER=True
Указать в ansible.cfg enable_task_debugger = True

По умолчанию Ansible для каждого отдельного task'a создаёт отдельное соединение с сервером.

Изменить ситуацию можно с помощью плагина mitogen:
Указать путь к mitogen в опции strategy_plugins и установить переменную окружения ANSIBLE_STRATEGY=mitogen_linear
Указать путь к mitogen в опции strategy_plugins и указать в плейбуке strategy: mitogen_linear
strategy_plugins = /usr/lib/python(*)/site-packages/ansible_mitogen/plugins/strategy
strategy = mitogen_linear

Ansible - сущности:
____________________________________
Tasks - непосредственно сами tasks. Каждый task - это вызов модуля Ansible.
Variables - директория /vars, раздел vars в тасках, etc.
Templates - написаны на языке jinja2. Язык написания template'в для питона. Позволяют создавать различные файлы на конфигурируемых серверах.
Handlers - в каталоге handlers лежат задачи, которые выполняются, если задача, указывающая на handler, вернула статус changed
Roles - совокупность ролей позволяет гибко настраивать различные серверы. Один из ключевых принципов использования Ansible.
____________________________________
Дополнительно:
В директории files - находятся файлы, которые копируются на удалённый сервер, при копировании не изменяются.
В директории templates лежат динамически изменяющиеся файлы, которые копируются модулем copy. Написаны на языке jinja2, меняются сообразно переменным, указанным в инвентаре, роли и т. д.
В директории handlers - хранятся handlers (неожиданно).
В директории defaults - хранятся переменные роли. Эти переменные могут переопределяться в других местах.
В директории vars - константные переменные, которые нельзя переопределить.

Переменные имеют приоритет.
extra vars - flag -e
playbook vars - переменные из плэйбука (раздел vars)
inventory host_vars/* - переменные, описанные в инвентаре host_vars
inventory file or script host vars - переменные, значения которых установлены в инвентаре.
inventory group_vars/* - здесь лежат переменные, назначенные группе серверов, они перезаписывают значения в ролях.
defaults/role - здесь лежат значения переменных в ролях по умолчанию.

Модули.
yum_repository - устанавливает модули для yum.
yum - устанавливает конкретный пакет из репозитория, скачанного на стадии yum_repository.
template - настраивает конфигурацию сервера:
  src - берёт данные из,
  dest - закидывает куда.
  mode - access mode
service - запускает сервис.
  name - имя модуля.
  state - состояние, например, started.

import_tasks - выполняется в самом начальном запуске сценария, объединяясь в один файл.
include_tasks - исполняются в момент проигрыша сценария, могут быть вставлены логические условия.
  when - может быть условие, когда вставляется task.

file - модуль для удаления файла:
  state: absent
или для создания директории:
  state: directory
with_items: - циклы для file'а.

Пример:
file:
  path: "{{ item }}"
  state: directory
with_items:
  - "{{ var1_from_vars }}"
  - "{{ var2_from_vars }}"
  - "{{ var3_from_vars }}"
берёт переменные из vars и создаёт директории с их именем.

systemd - такой же модуль как service. Позволяет их останавливать, запускать, перезапускать. Отличие - ориентирован на работу с systemd, но есть опция daemon_reload: yes|no на перезапуск конфигурации.

register - позволяет запомнить состояние, выполненное в ходе операций выше.
Впоследствии его можно проверять, к примеру:
  register: mongodb_whitelist

when:
  - something_enable
  - mongodb_whitelist.changed

Перечисление в when в таком стиле обозначает логический оператор and.

Templates jinja2:
{% операторы jinja2 %}
example:
{% if something is defined %}
{% endif %}

{{ variable jinja2 }}
example:
{% for item in something %}
{{ item|ipv4|ternary(item, '# ' - item) }}
{% endfor %}

Inventory.
По умолчанию состоит из двух директорий и одного файла:
/group_vars
/host_vars
hosts

hosts - в квадратных скобках группы, в них - имена и настройки серверов.
/host_vars - здесь могут быть файлы с названиями серверов. Все переменные, которые есть в них, применяются к соответствующим серверам.
/group_vars:
/all - в эту группу входят все сервера, указанные в inventory. Все файлы, лежашие в этой директории будут применены ко всем серверам.
file_name_group - все файлы, лежащие в файле /group_vars/file_name_group - будут применены к группе file_name_group
В них могут быть:
roles:
  - sudo
  - kubernetes
  - etc
variables:
base_etc_hosts_local:
  - { ipaddr: '172.01.0.2', host: 'host1' }
  - { ipaddr: '172.01.0.3', host: 'host2' }
  - { ipaddr: '172.01.0.4', host: 'host3' }
  - { ipaddr: '172.01.0.5', host: 'host4' }
  - { ipaddr: '172.01.0.6', host: 'host5' }
(It was an example of list)

У переменных могут быть следующие расширения:
.yaml, .yml, .json, без расширения.

Дальше - модуль 3 Ansible.
В директории /core находятся роли и плейбуки.
roles - входящие в сценарий.
plays - темплейты плейбуков. Генерирует плейбук из темплейта и запускает его для настройки серверов.

Ansible можно конфигурировать 4-мя способами (по приоритету):
1. Переменные окружения.
2. ansible.cfg в текущей директории.
3. ~/.ansible.cfg в домашней директории.
4. /etc/ansible/ansible.cfg - вариант по умолчанию.


3.4 - passed, exception - ssh flags.

Framefork for testing
https://molecule.readthedocs.io/en/latest

Ansible vault
playbook, roles, inventory, templates, single variables:

command: ansible-vault
ansible-vault encrypt <your_awesome_file-name> --vault-id <your_vault-id>
ansible-vault encrypt_string "Your awesome string" --name encs --vault-id <your_vault-id>

id@<file-name> - Указание файла, где находится пароль, с помощью которого можно расшифровать файл.
id@<prompt> - Указание, что нужно запрашивать пароль с ввода консоли.
При этом id может быть любым. Это - указание ключа к паролю (или файлу).

--vault-id id@<file-name> нужно также указывать, если есть зашифрованный файл при запуске плейбука.
