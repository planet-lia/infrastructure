# Kubernetes
This directory contains everything necessary to spin up a new Kubernetes cluster deployment.

## Quick Overview of Bundled Scripts
- `cluster_create_files.sh`: Creates the deployment project directories & files (in `k8s/deployment`)
- `install.sh`: Installs the Kubernetes cluster using the Kubespray files created earlier using `cluster_create_files.sh`
- `firewall.sh`: Optional script used to disable Kubernetes API Server traffic from the internet, instead you would forward your traffic via SSH to access the Kubernetes API Server
- `local_forward.sh`: Helper script that is best if you copy locally and use to forward your Kubernetes API Server traffic to your K8s master node
- `node_add.sh`: Adds a node to the cluster
- `node_remove.sh`: Removes a node from the cluster

## Kubernetes Cluster
### Installation
Dependencies:
- Python 3 (version 3.7.4 was used when writing this guide)
- Ansible (version 2.7, version 2.8 isn't supported yet, see [#1](https://github.com/planet-lia/infrastructure/issues/1))

Before starting you should have at least two nodes ready.
We assume that the nodes are running Ubuntu 18.04 LTS or similar and you have SSH access.

**Note**: login using SSH at least one time (or regenerate the SSH key fingerprint) to accept the server's SSH fingerprint.
Otherwise the Ansible script will probably fail to connect to the server.  

First do a pull from `k8s/kubespray` since it's a submodule to get the latest changes.
```bash
$ cd ./kubespray
$ git pull
```

Then create a Python3 virtual environment in the `k8s` dir and activate it.
```bash
$ cd ../ # You should now be in `./k8s`
$ virtualenv -p python3 venv
$ source venv/bin/activate
```

Install the kubespray dependencies.
```bash
$ pip install -r kubespray/requirements.txt
```

Create the necessary files for the cluster.
```bash
$ ./cluster_create_files.sh <CLUSTE_NAME>
# Edit deployment/<CLUSTER_NAME>/inventory.ini
# Edit deployment/<CLUSTER_NAME>/overrides.yml
```
Configure the `inventory.ini` and `overrides.yml` files for your cluster.

Install time!
```bash
$ ./install.sh <CLUSTER_NAME> <SSH_PRIVATE_KEY>
# Now wait...
```

SSH into your master node and copy locally the `/etc/kubernetes/admin.conf` file.
This is your Kubernetes config file with which you can connect using `kubectl` on your remote computer (move it to `~/.kube/config`).

### Firewall (Optional)
It's not good security practice to leave the Kubernetes API Server exposed on the internet.

Instead what you can do is disable Internet traffic from reaching the Kubernetes API Server (port 6443 by default) and rather forward your traffic via SSH (SSH needs to be reachable via the Internet for this to work ofc :stuck_out_tongue:).
```bash
$ ./firewall.sh <CLUSTER_MASTER_NODE> <SSH_PRIVATE_KEY> <CLUSTER_SUBNET_CIDR>

# Copy this somewhere convenient, e.g. ~/.kube/local_forward.sh
# Then whenever you need to forward your traffic (when using kubectl) run
$ ./local_forward.sh <CLUSTER_MASTER_NODE>
```

Open your Kubernetes configuration (the one that you copied from the master node `/etc/kubernetes/admin.conf` onto your computer into e.g. `~/.kube/config`).
Change the cluster server endpoint from `https://<CLUSTER_MASTER_NODE>:6443` into `https://127.0.0.1:6443`.

### Kubernetes Dashboard
If you wish to enable the Kubernetes Dashboard (by default it is turned on, unless you overrode it in `overrides.yml`), create a Service Account
```bash
$ kubectl create serviceaccount cluster-admin-dashboard-sa
$ kubectl create clusterrolebinding cluster-admin-dashboard-sa \
  --clusterrole=cluster-admin \
  --serviceaccount=default:cluster-admin-dashboard-sa
$ kubectl get secret | grep cluster-admin-dashboard-sa
# Take a note of the name of the secret
$ kubectl describe secret <NAME_OF_SECRET_FROM_ABOVE_COMMAND>
# Save the token value - this is your password.
```
Now if you visit: `https://127.0.0.1:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=default` you can paste in your token and access the dashboard.
If you wish to upload your kubeconfig file you will need to [paste your token into the config file](https://stackoverflow.com/a/51446875).


### Adding a Node
To add a node to the cluster you can simply add it to your cluster's `inventory.ini` file and run:
```bash
./node_add.sh <CLUSTER_NAME> <SSH_PRIVATE_KEY>
```

Note: same as when creating the cluster, make sure SSH does not inquire about the fingerprint (so login and/or reset the fingerprint of the new node at least once).

### Removing a Node
Similar to adding a node, simply run:
```bash
./node_add.sh <CLUSTER_NAME> <SSH_PRIVATE_KEY> <NODE>  # NODE is the name of the node in the inventory.ini file
```
**BEFORE YOU RUN THE SCRIPT**: There is [a bug in Kubespray](https://github.com/kubernetes-sigs/kubespray/issues/5160) which causes some variables not to be initialized and the removal process is unsuccessful. 
As a temporary fix open `kubespray/remove-node.yml` and change
```yaml
- hosts: "{{ node | default('kube-node') }}"
  gather_facts: no
```
into:
```yaml
- hosts: "{{ node | default('kube-node') }}"
  gather_facts: yes
```

You may now run the `node_add.sh` script.

After the successful removal of the node you may remove the node's entry in the `inventory.ini` file of your cluster.

## Credits
The credit for the structure of the repository and Kubespray technique used to house multiple clusters goes to the :crown: Kubernetes Wizard [dr. Mataž Pančur](https://fri.uni-lj.si/en/employees/matjaz-pancur). 