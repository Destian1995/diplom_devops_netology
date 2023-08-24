# Развертывание Kubernetes-кластера с подключением мониторинга и развертыванием на нем приложения с Jenkins в YandexCloud.

* Важно! Перед установкой необходимо создать ключик key.json, для авторизации в облаке. 
* Так же необходимо указать свои данные в файле variables.tf и provider.tf(для авторизации в Terraform Cloud)
* Для установки кластера необходимо запустить скрипт main_install.sh. 
* Далее вся установка будет происходить автоматически.

Скрипт main_install.sh Включает в себя:

1. Этап подготовка окружения.
</details>
*<summary> Скачивание репозитория Kubespray, если его нет.<summary>
```
Проверяется, есть ли директория с именем "kubespray".
Если директория не найдена, скрипт клонирует репозиторий Kubespray из GitHub.
```
</details>
* Установка Python 3.9.
```
Проверяется наличие Python 3.9.
Если Python 3.9 не установлен, производится его установка через пакетный менеджер apt.
```
* Установка pip для Python 3.9 и Ansible.
```
Проверяется наличие pip3.9.
Если pip для Python 3.9 отсутствует, производится его установка через apt-get.
Установка Ansible версии 2.14.6 с использованием pip:

Устанавливается конкретная версия Ansible для успешного взаимодействия с kubespray.
```
* Установка дополнительных утилит.
```
Проверяется наличие утилиты jq и устанавливается, если она отсутствует.
Утилиты netaddr, jmespath и kubectl также проверяются на наличие и устанавливаются при необходимости.
```
* Установка Terraform.
```
Проверяется наличие утилиты terraform.
Если она отсутствует, производится установка с использованием snap.
```

2. Этап развертывания инфраструктуры.
   
* Развертывание 4-х серверов в облаке, на каждый workspace(prod, stage): 1 Jenkins, 1 Master, 2 Worker. И подготовка окружения перез развертыванием Kubernetes-кластера.
workspace выбирается исходя из названий установленных в terraform конфигурации: diplom-prod, diplom-stage.
Если указать любое другое название не меняя конфигурацию, то будут ошибки.

```
Переход в директорию terraform, инициализация Terraform и запуск процесса создания инфраструктуры через terraform apply.
Возврат в предыдущую директорию и последовательность команд для подготовки inventory файла Kubespray:

Удаляется старый inventory.
Копируется пример inventory из репозитория Kubespray.
Подготовка переменных для дальнейшего использования:

Извлекается имя текущего workspace из Terraform.
Генерируется файл hosts.ini с помощью generate_inventory.sh.
Извлекаются IP-адреса виртуальных машин из вывода Terraform и сохраняются в файлах inv и inv2.

Ожидание 2 минут (120 секунд) для того, чтобы инфраструктура успела инициализироваться.
```
* Запуск Ansible-плейбука для развертывания Kubernetes-кластера с использованием Kubespray и настроек SSH.

* Запуск Ansible-плейбука k8s_conf.yml для конфигурирования Kubernetes с помощью данных из файла inv.

* Запуск Ansible-плейбука jenkins.yml для развертывания Jenkins с использованием данных из файла inv2.

* Установка Helm-чарта Prometheus и настройка Grafana:
```
Создается namespace "monitoring".
Устанавливается Prometheus с помощью Helm.
Применяется файл конфигурации для сервиса Grafana.
Установка Helm-чарта netology в namespace "myapp".
```

