#################################################################
### Functions
#################################################################

# Add required Helm repositories
add_helm_repos() {
  echo "Adding Helm repositories..."
  # Argo-CD Helm Repo
  helm repo add argo https://argoproj.github.io/argo-helm
  helm repo update
}

# Install Argo-CD and required secret
install_argo() {
  local cluster=$1
  kubectl config use-context "kind-$cluster"

  echo "************************************"
  echo "Installing Argo-CD on cluster: $cluster"
  echo "************************************"
  # Install Argo-CD
  helm install argocd argo/argo-cd \
    --version "$ARGO_VERSION" \
    --namespace "$NAMESPACE" \
    --create-namespace \
    --set server.service.type=NodePort
}

# Get Argo-Cd initial admin credentials from the clusters
fetch_argo_credentials() {
  local cluster=$1
  kubectl config use-context "kind-$cluster"
  # Check if the secret exists
  # If it does exist, print the credentials and break the loop
  # If it does not exist, wait for 5 seconds and check again
  for i in {1..60}; do
  SECRET=$(kubectl get secret argocd-initial-admin-secret -n "$NAMESPACE" -o jsonpath='{.data.password}' 2>/dev/null)
  if [[ -n "$SECRET" ]]; then
        echo "************************************"
        echo "**********Cluster $cluster**********"
        echo "************************************"
        echo ""
        echo "Username: admin"
        echo "Password: $(kubectl get secret argocd-initial-admin-secret -n argocd \
          -o jsonpath='{.data.password}' | base64 --decode)" && echo
        echo "************************************"
        echo ""
    break
  fi
  sleep 5
done
}

#################################################################
### Core
#################################################################

# Variables
# Please refer to the init.sh script for the list of cluster names
# or use: kind get clusters
# "surveillance-green" 
CLUSTERS=("surveillance-green" "green-prod")
ARGO_VERSION="6.10.2" # argocd lc version
NAMESPACE="argocd"

# Add all required Helm repositories
add_helm_repos

# Install ArgoCD on each cluster
for CLUSTER in "${CLUSTERS[@]}"; do
  install_argo "$CLUSTER"
done

# Get the ArgoCD admin password
echo "Fetching initial ArgoCD server credentials..."
for CLUSTER in "${CLUSTERS[@]}"; do
  fetch_argo_credentials "$CLUSTER"
done

# Set the ArgoCD server URL to be served on localhost
echo "ArgoCD installation and credential retrieval complete."
echo "You can access ArgoCD by forwarding you port."
echo "First select the cluster you want to access with: kubectl config use-context kind-<cluster_name>"
echo "Then run the following command to forward the port:"
echo "kubectl port-forward svc/argocd-server -n argocd <desired-port>:80"