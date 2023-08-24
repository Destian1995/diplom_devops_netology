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

1 этап:
<details>
<summary>Скачивание репозитория Kubespray, если его нет.</summary>
<p>Проверяется, есть ли директория с именем "kubespray". Если директория не найдена, скрипт клонирует репозиторий Kubespray из GitHub.</p>
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
   
Развертывание 4-х серверов в облаке, на каждый workspace (prod, stage): 1 Jenkins, 1 Master, 2 Worker. И подготовка окружения перед развертыванием Kubernetes-кластера.
Workspace выбирается исходя из названий установленных в terraform конфигурации: diplom-prod, diplom-stage.
Если указать любое другое название не меняя конфигурацию, то будут ошибки.


<details>
<summary>Запуск Ansible-плейбука для развертывания Kubernetes-кластера с использованием Kubespray и настроек SSH.</summary>
</details>

<details>
<summary>Запуск Ansible-плейбука k8s_conf.yml для конфигурирования Kubernetes с помощью данных из файла inv.</summary>
</details>

<details>
<summary>Запуск Ansible-плейбука jenkins.yml для развертывания Jenkins с использованием данных из файла inv2.</summary>
</details>

<details>
<summary>Установка Helm-чарта Prometheus и настройка Grafana:</summary>
<p>Создается namespace "monitoring".</p>
<p>Устанавливается Prometheus с помощью Helm.</p>
<p>Применяется файл конфигурации для сервиса Grafana.</p>
<p>Установка Helm-чарта netology в namespace "myapp".</p>
</details>
