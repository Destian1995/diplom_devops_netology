# Развертывание Kubernetes-кластера с подключением мониторинга и развертыванием на нем приложения с Jenkins в YandexCloud.

```
Важно! Перед установкой необходимо создать ключик key.json, для авторизации в облаке.
Также необходимо указать свои данные в файле variables.tf и provider.tf (для авторизации в Terraform Cloud).
Для установки кластера необходимо запустить скрипт main_install.sh.
Далее вся установка будет происходить автоматически.
```


* Скрипт main_install.sh Включает в себя:
1. Этап подготовки окружения.
2. Этап развертывания инфраструктуры.
-------------------------------------------------

1. Этап:
<details>
<summary>Скачивание репозитория Kubespray, если его нет.</summary>
<pre>
Проверяется, есть ли директория с именем "kubespray". 
Если директория не найдена, скрипт клонирует репозиторий Kubespray из GitHub.
<pre>
</details>

<details>
<summary>Установка Python 3.9.</summary>
<pre>
Проверяется наличие Python 3.9.
Если Python 3.9 не установлен, производится его установка через пакетный менеджер apt.
</pre>
</details>

<details>
<summary>Установка pip для Python 3.9 и Ansible.</summary>
<pre>
Проверяется наличие pip3.9.
Если pip для Python 3.9 отсутствует, производится его установка через apt-get.
Установка Ansible версии 2.14.6 с использованием pip:
Устанавливается конкретная версия Ansible для успешного взаимодействия с kubespray.
</pre>
</details>

<details>
<summary>Установка дополнительных утилит.</summary>
<pre>
Проверяется наличие утилиты jq и устанавливается, если она отсутствует.
Утилиты netaddr, jmespath и kubectl также проверяются на наличие и устанавливаются при необходимости.
</pre>
</details>

<details>
<summary>Установка Terraform.</summary>
<pre>
Проверяется наличие утилиты terraform.
Если она отсутствует, производится установка с использованием snap.
</pre>
</details>

2. Этап:
   
* Развертывание 4-х серверов в облаке, на каждый workspace (prod, stage): 1 Jenkins, 1 Master, 2 Worker. 
* Подготовка окружения перед развертыванием Kubernetes-кластера.
* Развертывание Kubernetes-кластера
* Развертывание Jenkins
* Установка Helm-чарта Prometheus и настройка Grafana

<details>
<summary>Детали подготовки окружения перед развертыванием кластер.</summary>
<pre>
Переход в директорию terraform, инициализация Terraform и запуск процесса создания инфраструктуры через terraform apply.
Возврат в предыдущую директорию и последовательность команд для подготовки inventory файла Kubespray:

Удаляется старый inventory.
Копируется пример inventory из репозитория Kubespray.
Подготовка переменных для дальнейшего использования:

Извлекается имя текущего workspace из Terraform.
Генерируется файл hosts.ini с помощью generate_inventory.sh.
Извлекаются IP-адреса виртуальных машин из вывода Terraform и сохраняются в файлах inv и inv2.

Ожидание 2 минут (120 секунд) для того, чтобы инфраструктура успела инициализироваться.
</pre>
</details>



* Запуск Ansible-плейбука для развертывания Kubernetes-кластера с использованием Kubespray и настроек SSH.
* Запуск Ansible-плейбука k8s_conf.yml для конфигурирования Kubernetes с помощью данных из файла inv.
* Запуск Ansible-плейбука jenkins.yml для развертывания Jenkins с использованием данных из файла inv2.


<details>
<summary>Установка Helm-чарта Prometheus и настройка Grafana:</summary>
<pre>
* Создается namespace "monitoring".
* Устанавливается Prometheus с помощью Helm.
* Применяется файл конфигурации для сервиса Grafana.
* Установка Helm-чарта netology в namespace "myapp".
</pre>
</details>
