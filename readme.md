# Manage Kubernetes Cluster with Terraform and Argo CD [![Twitter](https://img.shields.io/twitter/follow/piotr_minkowski.svg?style=social&logo=twitter&label=Follow%20Me)](https://twitter.com/piotr_minkowski)

In this project I'm demonstrating you how to use [Terraform](https://www.terraform.io/) together with [Argo CD](https://argo-cd.readthedocs.io/en/stable/) to create and manage the Kubernetes cluster on [Kind](https://kind.sigs.k8s.io/).

## Prerequisites
1. Terraform CLI installed
2. Docker

## Getting Started

You may the detailed explanation of that example repository in the following article: [Manage Kubernetes Cluster with Terraform and Argo CD](https://piotrminkowski.com/2022/06/28/manage-kubernetes-cluster-with-terraform-and-argo-cd/)

First, clone that repo:
```shell
$ git clone https://github.com/piomin/sample-terraform-kubernetes-argocd.git
$ cd sample-terraform-kubernetes-argocd
```

Then initialize Terraform config: 
```shell
terraform init
```

Review the actions plan: 
```shell
terraform plan
```

Run the Terraform actions: 
```shell
terraform apply
```

## Results

After running the previous command you receive:
* 3-nodes Kind cluster running locally
* OLM (Operator Lifecycle Manager) installed on Kind
* Argo CD installed on Kind
* Kafka Strimzi operator ready to use
* 3-node Kafka cluster created on Kind