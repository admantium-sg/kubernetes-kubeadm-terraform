# K8S Kubeadm Cluster with Terraform

This repository creates a kubeadm cluster on the Hetzner cloud.

The preconfigured components are `etcd`, `containerd` and `calico`.

## Prerequisites

You need a [Hetzner Cloud](https://accounts.hetzner.com/login) account. Then, get an access token following the [official documentation](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/).

## Usage

Export your Hetzner cloud access token as an environment variable, select the `staging` workspace, and start deploying.

```js
export TF_VAR_hcloud_token=SECRET

terraform init
terraform workspace select staging
terraform apply
```

Then, access your cluster via SSH and grab the `kubeconfig` file:

```bash
ssh root@${$(terraform output controller_ip)//\"/} \
  -o StrictHostKeyChecking=no \
  -i .ssh-${$(terraform workspace show)//\"/}/id_rsa.key \
  -c "cat /root/.kube/config"
```

## Customization

### Kubernetes Version

The default value is `v1.25.2`, change it in `bin/01_install.sh`:

```bash
KUBERNETES_VERSION=1.25.2
```

### Cluster Nodes

The `variables.tf` file contains the configuration which Hetzner server type to use and the number and name for the controller and worker nodes. It also distinguishes into two workspaces with different number of nodes:

`staging`: 1 controller (cx21), 2 worker nodes (cpx21)
`production`: 1 controller (cx31), 3 worker nodes (cpx31)

Edit the [variables.tf](./variables.tf) to change this.

Switch the workspace with `terraform workspace select staging` or `terraform workspace select production`, and use `terraform refresh` to get the current controller IP address.

## Known Limitations

* Currently, only 1 controller node can be provisioned
* The default user on the nodes is `root`
