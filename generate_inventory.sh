#!/bin/bash

set -e

# Функция для генерации секции хостов
generate_host_section() {
    local prefix="$1"                   # Префикс имени хоста (например, "master" или "worker")
    local external_ips="$2"             # Внешние IP-адреса хостов
    local internal_ips="$3"             # Внутренние IP-адреса хостов
    local count="$4"                    # Количество хостов данного типа

    for ((num = 1; num <= count; num++)); do
        printf "%s-%d   ansible_host=%s   ip=%s\n" "$prefix" "$num" \
            "$(echo "$external_ips" | jq -j ".[$num-1]")" \
            "$(echo "$internal_ips" | jq -j ".[$num-1]")"
    done
}

printf "[all]\n"

# Генерация секции хостов для мастер-узлов
generate_host_section "master" \
    "$(terraform output -json external_ip_address_vm_instance_master)" \
    "$(terraform output -json internal_ip_address_vm_instance_master)" \
    1

# Генерация секции хостов для рабочих узлов
generate_host_section "worker" \
    "$(terraform output -json external_ip_address_vm_instance_worker)" \
    "$(terraform output -json internal_ip_address_vm_instance_worker)" \
    2



printf "\n[all:vars]\n"
printf "ansible_user=cloud-user\n"
printf "supplementary_addresses_in_ssl_keys='"
terraform output -json external_ip_address_vm_instance_master | jq -cj
printf "'\n\n"




cat << EOF
[kube_control_plane]
master-1

[etcd]
master-1

[kube-node]
worker-1
worker-2

[calico-rr]

[k8s-cluster:children]
kube_control_plane
kube-node
calico-rr
EOF
