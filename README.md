# K8S Kubeadm Cluster with Terraform

This repository creates a kubeadm cluster with the Hetzner cloud.

The preconfigured components are `etcd`, `containerd` and `calico`.

## Prerequisites

- [Hetzner Cloud account](https://accounts.hetzner.com/login)
- [Hetzner Cloud access token](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/).
- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads)

## Usage

Export your Hetzner cloud access token as an environment variable, select the `staging` workspace, and start deploying.

```bash
export TF_VAR_hcloud_token=SECRET

terraform init
terraform workspace new staging
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

The default value is `v1.26.4`, change it in `bin/01_install.sh`:

```bash
KUBERNETES_VERSION=1.26.4
```

### Cluster Nodes

The `variables.tf` file contains the configuration which Hetzner server type to use and the number and name for the controller and worker nodes. It also distinguishes into two workspaces with different number of nodes:

- `staging`: 1 controller (cx21), 2 worker nodes (cpx21)
- `production`: 1 controller (cx31), 4 worker nodes (cpx31)

Edit the [variables.tf](./variables.tf) to change this.

Switch the workspace with `terraform workspace select staging` or `terraform workspace select production`, and use `terraform refresh` to get the current controller IP address.

## Known Limitations

- Currently, only 1 controller node can be provisioned
- The default user on the node is `root`
