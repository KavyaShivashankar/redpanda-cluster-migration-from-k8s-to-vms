---
slug: deploying-additional-vms-with-ansible
id: tqxhvcrervnx
type: challenge
title: Deploying additional VMs with Ansible.   Ansible is preinstalled
teaser: Add 3 new vms with ansible to the K8s cluster
notes:
- type: text
  contents: Add 3 new VMs with ansible to the K8s cluster
tabs:
- title: Shell
  type: terminal
  hostname: server
difficulty: basic
timelimit: 900
---
# Prerequisites

- Python
- Ansible
- SSH (between the Ansible and cluster hosts)

>**Note:** In a real environment, you'll need password-less SSH access from your Ansible host to your cluster nodes.
> Here in the Instruqt environment, SSH is already configured.

# Infrastructure

There are 4 VMs available in this track: 1 for Ansible, 3 for Redpanda. Initially, we will deploy Redpanda on all 3 nodes.

# Pre-steps

First we will check if Ansible is pre-installed:

```bash,run
ansible --version
```

Output:

```bash,nocopy
ansible 2.10.8
  config file = None
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.10.12 (main, Nov 20 2023, 15:14:05) [GCC 11.4.0]
```

Ansible is already installed as part of setup.  We need to get hold of the deployment automation project:

```bash,run
git clone https://github.com/redpanda-data/deployment-automation.git
cd deployment-automation
```

Output:

```bash,nocopy
cd deployment-automation
Cloning into 'deployment-automation'...
remote: Enumerating objects: 2088, done.
remote: Counting objects: 100% (697/697), done.
remote: Compressing objects: 100% (218/218), done.
remote: Total 2088 (delta 500), reused 593 (delta 462), pack-reused 1391
Receiving objects: 100% (2088/2088), 461.88 KiB | 9.83 MiB/s, done.
Resolving deltas: 100% (1141/1141), done.
```

# Configure Ansible and Install Roles

```bash,run
export DEPLOYMENT_PREFIX=instruqt
export ANSIBLE_COLLECTIONS_PATH=${PWD}/artifacts/collections
export ANSIBLE_ROLES_PATH=${PWD}/artifacts/roles
export ANSIBLE_INVENTORY=${PWD}/artifacts/hosts_gcp_$DEPLOYMENT_PREFIX.ini

ansible-galaxy install -r requirements.yml
```

Output:

```bash,nocopy
Starting galaxy role install process
- downloading role 'mdadm', owned by mrlesmithjr
- downloading role from https://github.com/mrlesmithjr/ansible-mdadm/archive/v0.1.1.tar.gz
- extracting mrlesmithjr.mdadm to /root/deployment-automation/artifacts/roles/mrlesmithjr.mdadm
- mrlesmithjr.mdadm (v0.1.1) was installed successfully
- downloading role 'squid', owned by mrlesmithjr
- downloading role from https://github.com/mrlesmithjr/ansible-squid/archive/v0.1.2.tar.gz
- extracting mrlesmithjr.squid to /root/deployment-automation/artifacts/roles/mrlesmithjr.squid
- mrlesmithjr.squid (v0.1.2) was installed successfully
- downloading role 'node_exporter', owned by geerlingguy
- downloading role from https://github.com/geerlingguy/ansible-role-node_exporter/archive/2.1.0.tar.gz
- extracting geerlingguy.node_exporter to /root/deployment-automation/artifacts/roles/geerlingguy.node_exporter
- geerlingguy.node_exporter (2.1.0) was installed successfully
Starting galaxy collection install process
Process install dependency map
Starting collection install process
'community.general:9.0.1' is already installed, skipping.
'ansible.posix:1.5.4' is already installed, skipping.
'grafana.grafana:5.2.0' is already installed, skipping.
Downloading https://galaxy.ansible.com/api/v3/plugin/ansible/content/published/collections/artifacts/redpanda-cluster-0.4.27.tar.gz to /root/.ansible/tmp/ansible-local-3482mnxyrhvk/tmp_nqw7i2x/redpanda-cluster-0.4.27-s_xya22t
Installing 'redpanda.cluster:0.4.27' to '/root/deployment-automation/artifacts/collections/ansible_collections/redpanda/cluster'
redpanda.cluster:0.4.27 was installed successfully
Downloading https://galaxy.ansible.com/api/v3/plugin/ansible/content/published/collections/artifacts/prometheus-prometheus-0.16.3.tar.gz to /root/.ansible/tmp/ansible-local-3482mnxyrhvk/tmp_nqw7i2x/prometheus-prometheus-0.16.3-p5nhb72j
Installing 'prometheus.prometheus:0.16.3' to '/root/deployment-automation/artifacts/collections/ansible_collections/prometheus/prometheus'
prometheus.prometheus:0.16.3 was installed successfully
```

# Create an Ansible Hosts File

Since we didn't use Terraform to create our nodes, `hosts.ini` isn't created automatically. Therefore, we create one now:

```bash,run
IP_A=$(nslookup node-a | grep Address | tail -1 | cut -f2 -d' ')
IP_B=$(nslookup node-b | grep Address | tail -1 | cut -f2 -d' ')
IP_C=$(nslookup node-c | grep Address | tail -1 | cut -f2 -d' ')

cat << EOF > hosts.ini
[redpanda]
${IP_A} ansible_user=root ansible_become=True private_ip=${IP_A} id=0
${IP_B} ansible_user=root ansible_become=True private_ip=${IP_B} id=1
${IP_C} ansible_user=root ansible_become=True private_ip=${IP_C} id=2
EOF

cat hosts.ini
```

Output:

```bash,nocopy
[redpanda]
10.192.0.85 ansible_user=root ansible_become=True private_ip=10.192.0.85 id=0
10.192.0.84 ansible_user=root ansible_become=True private_ip=10.192.0.84 id=1
10.192.0.82 ansible_user=root ansible_become=True private_ip=10.192.0.82 id=2
```

# Run the Playbook


```bash,run
ansible-playbook --private-key ~/.ssh/id_rsa -vvv ansible/provision-cluster.yml -i hosts.ini -e redpanda_version=23.3.13-1 --extra-vars '{
  "redpanda": {
    "node": {
      "redpanda": {
        "empty_seed_starts_cluster": "false",
        "seed_servers": [
          {
            "host": {
              "address": "redpanda-0.testdomain.local",
              "port": "31092"
            }
          },
          {
            "host": {
              "address": "redpanda-1.testdomain.local",
              "port": "31092"
            }
          },
          {
            "host": {
              "address": "redpanda-2.testdomain.local",
              "port": "31092"
            }
          }
        ]
      }
    }
  }
}' | tee ans_notls_deployment.log

```

# Validate

## Configure RPK and create a profile for ansible VMs

```bash,run
cd ~
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@node-a:/etc/redpanda/redpanda.yaml .
## Not required when no TLS
# scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@node-a:/etc/redpanda/certs/truststore.pem ca_ans.crt
# sed -i 's/\/etc\/redpanda\/certs\/truststore.pem/ca_ans.crt/g' redpanda.yaml
rpk profile create ans --from-redpanda redpanda.yaml
rpk profile use ans

```

Output:

```bash,nocopy
Created and switched to new profile "ans"
Set current profile to "ans"

```

## Check the Cluster

```bash,run
rpk cluster info
```

Output:

```bash,nocopy
CLUSTER
=======
redpanda.9a4eb098-d56f-4af5-9d06-e847a77a760d

BROKERS
=======
ID    HOST    PORT
0*    node-a  9092
1     node-b  9092
2     node-c  9092
```

## Create some topics

```bash,run
rpk topic create log1 -p 3 -r 3
rpk topic create log2 -p 3 -r 3
rpk topic create log3 -p 3 -r 3
rpk topic create log4 -p 3 -r 3
rpk topic create log5 -p 3 -r 3
```

Output:

```bash,nocopy
TOPIC  STATUS
log1   OK
TOPIC  STATUS
log2   OK
TOPIC  STATUS
log3   OK
TOPIC  STATUS
log4   OK
TOPIC  STATUS
log5   OK
```

# Summary

We created a cluster and some topics. Success!