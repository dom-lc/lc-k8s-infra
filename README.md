# lc-k8s-infra

Repository that mocks the lc-k8s-apps-infrastucture. </br></br>
*Note that this repository will be used to demonstrate concepts and does not follow the best security practices.*

## Infra Workflow

This directory contains scripts to setup your clusters and bootstrap them. It also permits deletion. Run these scripts as root user.

* init.sh: Installs kind and sets up our kind single node clusters.
* bootstrap.sh: Adds Argo-Cd's Helm repositories and installs Argo-Cd via Helm to our clusters.
* destroy.sh: Destorys all our kind clusters

A variable has been preset in each script to for the clusters (2 clusters: sandbox and nprod):

```
CLUSTERS=("surveillance-green" "green-prod")
```

If you modify this value, ensure it is reflected in all of your scripts. (init.sh, bootstrap.sh, destroy.sh)</br></br>


## Applicative Workflow

This directory is responsible for our applicative workflow. Using the app-management chart, it creates the applicationsets for our applications. It also has the template responsible to create an argocd application in order to span apps that are in the process of being developed.

## Real World Use

As the original repository does, I see this repo as the one with the Terraform configuration files and GitHub action worflows to create aks clusters, nodepools and resources. It also installs Argo-CD and sets up our base k8s tools applications. (ag. runners, reflector, scaler, ingress controller, ...)