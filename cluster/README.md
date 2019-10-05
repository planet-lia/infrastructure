# Kubernetes
This directory contains everything necessary to spin up a new Kubernetes cluster deployment.

## Quick Overview of Bundled Scripts
- `cluster_create_files.sh`: Creates the deployment project directories & files (in `cluster/deployment`)
- `install.sh`: Installs the Kubernetes cluster using the Kubespray files created earlier using `cluster_create_files.sh`
- `firewall.sh`: Optional script used to disable Kubernetes API Server traffic from the internet, instead you would forward your traffic via SSH to access the Kubernetes API Server
- `get_k8s_config.sh`: Get the Kubernetes admin configuration file from the newly created cluster
- `local_forward.sh`: Helper script that is best if you copy locally and use to forward your Kubernetes API Server traffic to your K8s master node
- `node_add.sh`: Adds a node to the cluster
- `node_remove.sh`: Removes a node from the cluster
- `install_overlay.sh`: Installs an overlay to the cluster, see main [README.md](../README.md) for more details 

## Kubernetes Cluster
### Installation
Dependencies:
- Python 3 (version 3.7.4 was used when writing this guide)
- Ansible (version 2.7, version 2.8 isn't supported yet, see [#1](https://github.com/planet-lia/infrastructure/issues/1))

Before starting you should have at least two nodes ready.
We assume that the nodes are running Ubuntu 18.04 LTS or similar and you have SSH access.

**Note**: login using SSH at least one time (or regenerate the SSH key fingerprint) to accept the server's SSH fingerprint.
Otherwise the Ansible script will probably fail to connect to the server.  

First do a pull from `cluster/kubespray` since it's a submodule to get the latest changes.
```bash
$ cd cluster/kubespray
$ git pull
$ cd ../ # You should now be in the `cluster` dir
```

From hereon we assume your working directory is `./cluster`.

Create a Python3 virtual environment in the `cluster` dir and activate it.
```bash
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
$ ./install.sh <CLUSTER_NAME> <SSH_PRIVATE_KEY_PATH>
# Now wait...
```

Time to get our admin Kubernetes configuration file:
```bash
# The last argument is the path of the admin config file, adapt to your liking.
$ ./get_k8s_config.sh ubuntu@master-node.example.com ~/.kube/<CLUSTER_NAME>
```

Do not forget to use the configuration file with kubectl, see [The KUBECONFIG environment variable](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#the-kubeconfig-environment-variable) or for a better experience install and configure [ktx](https://github.com/heptiolabs/ktx).

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
After the successful removal of the node you may remove the node's entry in the `inventory.ini` file of your cluster.

## Credits
The credit for the structure of the repository and Kubespray technique used to house multiple clusters goes to the :crown: Kubernetes Wizard [dr. Mataž Pančur](https://fri.uni-lj.si/en/employees/matjaz-pancur). 