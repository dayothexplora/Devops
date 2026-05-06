Kubernetes Cluster Setup using kubeadm (v1.36.0)

## 1. Update System Packages [All Nodes].
```bash
sudo apt-get update && sudo apt-get upgrade -y
```

## 2. Install Container Runtime (containerd) [All Nodes].
```bash
sudo apt install -y containerd
```
- Configure Containerd:
```bash
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
```

## 3. Install Required Dependencies[All Nodes].
```bash
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
sudo mkdir -p -m 755 /etc/apt/keyrings
```

## 4. Add Kubernetes Repository (v1.36)[All Nodes].
```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key \
| sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /" \
| sudo tee /etc/apt/sources.list.d/kubernetes.list
```
## 5. Update Packages list[All Nodes].
```bash
sudo apt update
```

## 6. Install Kubernetes Components (v1.36.0)[All Nodes].
```bash
sudo apt install -y kubelet=1.36.0-1.1 kubeadm=1.36.0-1.1 kubectl=1.36.0-1.1
sudo apt-mark hold kubelet kubeadm kubectl
```

## 7. Initialize Control Plane [Master Node].
```bash
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```
-Save the kubeadm join command output, you’ll need it for worker nodes.

## 8. Configure kubectl [Master Node].
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
## 9. Install Network Plugin (Calico)[Master Node].
```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

## 10. Join Worker Nodes [Worker Nodes].
```bash
kubeadm join <MASTER_IP>:6443 --token <TOKEN> \
--discovery-token-ca-cert-hash sha256:<HASH>
```

## 11. Install NGINX Ingress Controller [Master Node].
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

## 12. Verify Cluster[Master Node]
```bash
kubectl get nodes
kubectl get pods -A
```

## 13. Reset Cluster[Master Node].
```bash
sudo kubeadm reset -f
```

## 14. Disable swap permanently:
```bash
sudo sed -i '/ swap / s/^/#/' /etc/fstab
```
