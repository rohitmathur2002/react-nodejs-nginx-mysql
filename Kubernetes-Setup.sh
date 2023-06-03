sudo apt update -y

sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
mkdir -p $HOME/.kube
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml


kubectl proxy --address='0.0.0.0' --port=8001 --disable-filter=true
kind: ConfigMap
apiVersion: v1
metadata:
  name: dashboard-proxy-config
  namespace: kube-system
data:
  proxy-config: |
    {
      "apiVersion": "v1",
      "kind": "Config",
      "clusters": [
        {
          "name": "local",
          "cluster": {
            "server": "http://localhost:8001"
          }
        }
      ],
      "contexts": [
        {
          "name": "local",
          "context": {
            "cluster": "local"
          }
        }
      ],
      "current-context": "local"
    }
kubectl apply -f dashboard-proxy-config.yaml
kubectl -n kubernetes-dashboard describe secret $(kubectl -n k
