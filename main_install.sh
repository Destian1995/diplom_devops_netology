#!/bin/bash

set -e

# Проверяем наличие Terraform и устанавливаем его при необходимости
if ! command -v terraform &> /dev/null; then
    echo "Terraform не установлен. Установка..."
    sudo snap install terraform --classic
fi

cd terraform
terraform init
terraform apply -auto-approve

cd ../
rm -rf kubespray/inventory/mycluster
cp -rfp kubespray/inventory/sample kubespray/inventory/mycluster

cd terraform
export WORKSPACE=$(terraform workspace show)
bash ./generate_inventory.sh > ../kubespray/inventory/mycluster/hosts.ini
terraform output -json external_ip_address_vm_instance_master | jq -r '.[]' > ../inv
terraform output -json external_ip_address_vm_instance_jenkins | jq -r '.[]' > ../inv2
export IP_MASTER=$(terraform output -json external_ip_address_vm_instance_master | jq -r '.[]')

# Установка nerdctl на мастер-ноду
ssh ubuntu@$IP_MASTER "sudo sh -c 'curl -L https://github.com/containerd/nerdctl/releases/latest/download/nerdctl-$(uname -s)-$(uname -m) > /usr/local/bin/nerdctl'"
ssh ubuntu@$IP_MASTER "sudo chmod +x /usr/local/bin/nerdctl"

# Установка nerdctl на рабочие ноды
for worker_ip in $(terraform output -json external_ip_address_vm_instance_worker | jq -r '.[]'); do
    ssh ubuntu@$worker_ip "sudo sh -c 'curl -L https://github.com/containerd/nerdctl/releases/latest/download/nerdctl-$(uname -s)-$(uname -m) > /usr/local/bin/nerdctl'"
    ssh ubuntu@$worker_ip "sudo chmod +x /usr/local/bin/nerdctl"
done

sleep 120

cd ../kubespray
ansible-playbook -i ../kubespray/inventory/mycluster/hosts.ini ../kubespray/cluster.yml --become --ssh-common-args='-o StrictHostKeyChecking=no'

cd ..

set +e
ansible-playbook -i inv k8s_conf.yml --user ubuntu --ssh-common-args='-o StrictHostKeyChecking=no'
error_code=$?
rm -rf inv

if [ $error_code -ne 0 ]; then
    echo "Произошла ошибка во время выполнения плейбука k8s_conf.yml."
    exit $error_code
fi

ansible-playbook -i inv2 jenkins.yml --user ubuntu --ssh-common-args='-o StrictHostKeyChecking=no'
error_code=$?
rm -rf inv2

if [ $error_code -ne 0 ]; then
    echo "Произошла ошибка во время выполнения плейбука jenkins.yml."
    exit $error_code
fi
set -e

export KUBECONFIG=~/.kube/$WORKSPACE/config
kubectl create namespace monitoring
kubectl create namespace myapp
helm install prometheus --namespace monitoring prometheus-community/kube-prometheus-stack
kubectl apply -f ./manifests/grafana-service-nodeport.yaml
helm install netology ./helm/myapp -n myapp

