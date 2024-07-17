---
slug: deploying-additional-vms-with-ansible
id: tqxhvcrervnx
type: challenge
title: Deploying additional VMs with Ansible
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

There are 5 VMs available in this track: 1 for Ansible, 4 for Redpanda. Initially, we will deploy Redpanda on 3 of the 4 nodes.

# Install Ansible

First we need to install Ansible:

```bash,run
apt update && apt install -y ansible
```

Output:

```bash,nocopy
Hit:1 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy InRelease
Get:2 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-updates InRelease [128 kB]
Get:3 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-backports InRelease [127 kB]
Get:4 http://security.ubuntu.com/ubuntu jammy-security InRelease [129 kB]
Get:5 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/universe amd64 Packages [14.1 MB]
Get:6 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/universe Translation-en [5652 kB]
Get:7 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/universe amd64 c-n-f Metadata [286 kB]
Get:8 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/multiverse amd64 Packages [217 kB]
Get:9 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/multiverse Translation-en [112 kB]
Get:10 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/multiverse amd64 c-n-f Metadata [8372 B]
Get:11 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages [1731 kB]
Get:12 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-updates/universe amd64 Packages [1086 kB]
Get:13 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-updates/universe Translation-en [251 kB]
Get:14 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-updates/universe amd64 c-n-f Metadata [22.1 kB]
Get:15 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-updates/multiverse amd64 Packages [43.0 kB]
Get:16 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-updates/multiverse Translation-en [10.7 kB]
Get:17 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-updates/multiverse amd64 c-n-f Metadata [472 B]
Get:18 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-backports/main amd64 Packages [67.1 kB]
Get:19 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-backports/main Translation-en [11.0 kB]
Get:20 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-backports/main amd64 c-n-f Metadata [388 B]
Get:21 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-backports/restricted amd64 c-n-f Metadata [116 B]
Get:22 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-backports/universe amd64 Packages [27.2 kB]
Get:23 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-backports/universe Translation-en [16.3 kB]
Get:24 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-backports/universe amd64 c-n-f Metadata [644 B]
Get:25 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-backports/multiverse amd64 c-n-f Metadata [116 B]
Get:26 http://security.ubuntu.com/ubuntu jammy-security/main amd64 Packages [1517 kB]
Get:27 http://security.ubuntu.com/ubuntu jammy-security/main Translation-en [259 kB]
Get:28 http://security.ubuntu.com/ubuntu jammy-security/restricted amd64 Packages [1933 kB]
Get:29 http://security.ubuntu.com/ubuntu jammy-security/restricted Translation-en [329 kB]
Get:30 http://security.ubuntu.com/ubuntu jammy-security/universe amd64 Packages [858 kB]
Get:31 http://security.ubuntu.com/ubuntu jammy-security/universe Translation-en [166 kB]
Get:32 http://security.ubuntu.com/ubuntu jammy-security/universe amd64 c-n-f Metadata [16.8 kB]
Get:33 http://security.ubuntu.com/ubuntu jammy-security/multiverse amd64 Packages [37.2 kB]
Get:34 http://security.ubuntu.com/ubuntu jammy-security/multiverse Translation-en [7588 B]
Get:35 http://security.ubuntu.com/ubuntu jammy-security/multiverse amd64 c-n-f Metadata [260 B]
Fetched 29.1 MB in 6s (4704 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
All packages are up to date.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  ieee-data python3-argcomplete python3-dnspython python3-jmespath python3-kerberos python3-libcloud python3-lockfile python3-netaddr python3-ntlm-auth python3-packaging python3-pycryptodome
  python3-requests-kerberos python3-requests-ntlm python3-requests-toolbelt python3-selinux python3-simplejson python3-winrm python3-xmltodict
Suggested packages:
  cowsay sshpass python3-sniffio python3-trio python-lockfile-doc ipython3 python-netaddr-docs
The following NEW packages will be installed:
  ansible ieee-data python3-argcomplete python3-dnspython python3-jmespath python3-kerberos python3-libcloud python3-lockfile python3-netaddr python3-ntlm-auth python3-packaging python3-pycryptodome
  python3-requests-kerberos python3-requests-ntlm python3-requests-toolbelt python3-selinux python3-simplejson python3-winrm python3-xmltodict
0 upgraded, 19 newly installed, 0 to remove and 0 not upgraded.
Need to get 22.9 MB of archives.
After this operation, 243 MB of additional disk space will be used.
Get:1 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/main amd64 python3-packaging all 21.3-1 [30.7 kB]
Get:2 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-pycryptodome amd64 3.11.0+dfsg1-3ubuntu0.1 [1029 kB]
Get:3 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/main amd64 python3-dnspython all 2.1.0-1ubuntu1 [123 kB]
Get:4 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/main amd64 ieee-data all 20210605.1 [1887 kB]
Get:5 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/main amd64 python3-netaddr all 0.8.0-2 [309 kB]
Get:6 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/universe amd64 ansible all 2.10.7+merged+base+2.10.8+dfsg-1 [17.5 MB]
Get:7 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/universe amd64 python3-argcomplete all 1.8.1-1.5 [27.2 kB]
Get:8 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/main amd64 python3-jmespath all 0.10.0-1 [21.7 kB]
Get:9 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/universe amd64 python3-kerberos amd64 1.1.14-3.1build5 [23.0 kB]
Get:10 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/main amd64 python3-lockfile all 1:0.12.2-2.2 [14.6 kB]
Get:11 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/main amd64 python3-simplejson amd64 3.17.6-1build1 [54.7 kB]
Get:12 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/universe amd64 python3-libcloud all 3.2.0-2 [1554 kB]
Get:13 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/universe amd64 python3-ntlm-auth all 1.4.0-1 [20.4 kB]
Get:14 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/universe amd64 python3-requests-kerberos all 0.12.0-2 [11.9 kB]
Get:15 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/universe amd64 python3-requests-ntlm all 1.1.0-1.1 [6160 B]
Get:16 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/main amd64 python3-requests-toolbelt all 0.9.1-1 [38.0 kB]
Get:17 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/universe amd64 python3-selinux amd64 3.3-1build2 [159 kB]
Get:18 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/universe amd64 python3-xmltodict all 0.12.0-2 [12.6 kB]
Get:19 http://europe-west1.gce.archive.ubuntu.com/ubuntu jammy/universe amd64 python3-winrm all 0.3.0-2 [21.7 kB]
Fetched 22.9 MB in 1s (40.5 MB/s)
Selecting previously unselected package python3-packaging.
(Reading database ... 66084 files and directories currently installed.)
Preparing to unpack .../00-python3-packaging_21.3-1_all.deb ...
Unpacking python3-packaging (21.3-1) ...
Selecting previously unselected package python3-pycryptodome.
Preparing to unpack .../01-python3-pycryptodome_3.11.0+dfsg1-3ubuntu0.1_amd64.deb ...
Unpacking python3-pycryptodome (3.11.0+dfsg1-3ubuntu0.1) ...
Selecting previously unselected package python3-dnspython.
Preparing to unpack .../02-python3-dnspython_2.1.0-1ubuntu1_all.deb ...
Unpacking python3-dnspython (2.1.0-1ubuntu1) ...
Selecting previously unselected package ieee-data.
Preparing to unpack .../03-ieee-data_20210605.1_all.deb ...
Unpacking ieee-data (20210605.1) ...
Selecting previously unselected package python3-netaddr.
Preparing to unpack .../04-python3-netaddr_0.8.0-2_all.deb ...
Unpacking python3-netaddr (0.8.0-2) ...
Selecting previously unselected package ansible.
Preparing to unpack .../05-ansible_2.10.7+merged+base+2.10.8+dfsg-1_all.deb ...
Unpacking ansible (2.10.7+merged+base+2.10.8+dfsg-1) ...
Selecting previously unselected package python3-argcomplete.
Preparing to unpack .../06-python3-argcomplete_1.8.1-1.5_all.deb ...
Unpacking python3-argcomplete (1.8.1-1.5) ...
Selecting previously unselected package python3-jmespath.
Preparing to unpack .../07-python3-jmespath_0.10.0-1_all.deb ...
Unpacking python3-jmespath (0.10.0-1) ...
Selecting previously unselected package python3-kerberos.
Preparing to unpack .../08-python3-kerberos_1.1.14-3.1build5_amd64.deb ...
Unpacking python3-kerberos (1.1.14-3.1build5) ...
Selecting previously unselected package python3-lockfile.
Preparing to unpack .../09-python3-lockfile_1%3a0.12.2-2.2_all.deb ...
Unpacking python3-lockfile (1:0.12.2-2.2) ...
Selecting previously unselected package python3-simplejson.
Preparing to unpack .../10-python3-simplejson_3.17.6-1build1_amd64.deb ...
Unpacking python3-simplejson (3.17.6-1build1) ...
Selecting previously unselected package python3-libcloud.
Preparing to unpack .../11-python3-libcloud_3.2.0-2_all.deb ...
Unpacking python3-libcloud (3.2.0-2) ...
Selecting previously unselected package python3-ntlm-auth.
Preparing to unpack .../12-python3-ntlm-auth_1.4.0-1_all.deb ...
Unpacking python3-ntlm-auth (1.4.0-1) ...
Selecting previously unselected package python3-requests-kerberos.
Preparing to unpack .../13-python3-requests-kerberos_0.12.0-2_all.deb ...
Unpacking python3-requests-kerberos (0.12.0-2) ...
Selecting previously unselected package python3-requests-ntlm.
Preparing to unpack .../14-python3-requests-ntlm_1.1.0-1.1_all.deb ...
Unpacking python3-requests-ntlm (1.1.0-1.1) ...
Selecting previously unselected package python3-requests-toolbelt.
Preparing to unpack .../15-python3-requests-toolbelt_0.9.1-1_all.deb ...
Unpacking python3-requests-toolbelt (0.9.1-1) ...
Selecting previously unselected package python3-selinux.
Preparing to unpack .../16-python3-selinux_3.3-1build2_amd64.deb ...
Unpacking python3-selinux (3.3-1build2) ...
Selecting previously unselected package python3-xmltodict.
Preparing to unpack .../17-python3-xmltodict_0.12.0-2_all.deb ...
Unpacking python3-xmltodict (0.12.0-2) ...
Selecting previously unselected package python3-winrm.
Preparing to unpack .../18-python3-winrm_0.3.0-2_all.deb ...
Unpacking python3-winrm (0.3.0-2) ...
Setting up python3-lockfile (1:0.12.2-2.2) ...
Setting up python3-requests-toolbelt (0.9.1-1) ...
Setting up python3-ntlm-auth (1.4.0-1) ...
Setting up python3-pycryptodome (3.11.0+dfsg1-3ubuntu0.1) ...
Setting up python3-kerberos (1.1.14-3.1build5) ...
Setting up python3-simplejson (3.17.6-1build1) ...
Setting up python3-xmltodict (0.12.0-2) ...
Setting up python3-packaging (21.3-1) ...
Setting up python3-jmespath (0.10.0-1) ...
Setting up python3-requests-kerberos (0.12.0-2) ...
Setting up ieee-data (20210605.1) ...
Setting up python3-dnspython (2.1.0-1ubuntu1) ...
Setting up python3-selinux (3.3-1build2) ...
Setting up python3-argcomplete (1.8.1-1.5) ...
Setting up python3-requests-ntlm (1.1.0-1.1) ...
Setting up python3-libcloud (3.2.0-2) ...
Setting up python3-netaddr (0.8.0-2) ...
Setting up python3-winrm (0.3.0-2) ...
Setting up ansible (2.10.7+merged+base+2.10.8+dfsg-1) ...
Processing triggers for man-db (2.10.2-1) ...
```

Next, we need to get hold of the deployment automation project:

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
# Kavya change the below output later
```bash,nocopy
[redpanda]
10.192.0.85 ansible_user=root ansible_become=True private_ip=10.192.0.85 id=0
10.192.0.84 ansible_user=root ansible_become=True private_ip=10.192.0.84 id=1
10.192.0.82 ansible_user=root ansible_become=True private_ip=10.192.0.82 id=2
```

# Run the Playbook

```bash,run
ansible-playbook --private-key ~/.ssh/id_rsa -v ansible/provision-cluster-tls.yml -i hosts.ini -e redpanda_version=23.3.13-1 --extra-vars '{
  "redpanda": {
    "node": {
      "empty_seed_starts_cluster": "false",
      "seed_servers": "redpanda-0.testdomain.local:31092,redpanda-1.testdomain.local:31092,redpanda-2.testdomain.local:31092"
    }
  }
}'
```

# Validate

## Install RPK and Configure

```bash,run
cd
curl -LO https://github.com/redpanda-data/redpanda/releases/latest/download/rpk-linux-amd64.zip
apt install -y unzip
unzip rpk-linux-amd64.zip -d /usr/local/bin
rm rpk-linux-amd64.zip
export REDPANDA_BROKERS="node-a:9092,node-b:9092,node-c:9092"
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