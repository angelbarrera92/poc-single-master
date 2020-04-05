# POC environment



# Demo APP: Guestbook

```bash
$ kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-deployment.yaml
$ kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-service.yaml
$ kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-deployment.yaml
$ kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-service.yaml
$ kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-deployment.yaml
$ kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-service.yaml
$ kubectl scale deployment frontend --replicas=5
```

## Backup-Restore external-db Cluster

### Step By Step

```bash
# Get the instance certificate:
$ terraform output external_tls_private_key > cluster.key && chmod 600 cluster.key
# Enter the instance
$ ssh -i cluster.key external@$(terraform output external_master_public_ip)
# Wait for Kubectl to be running. Check number of nodes. Then run a sample nginx
master$ kubectl run nginx --image nginx:latest --port 80 --expose --replicas=3
master$ kubectl expose deployment nginx --type NodePort --target-port 80 --name nginx-external
# Backup PKI
master$ sudo tar -zcvf /tmp/pki.tar.gz /etc/kubernetes/pki
# Download Backup
$ scp -i cluster.key external@$(terraform output external_master_public_ip):/tmp/pki.tar.gz pki.tar.gz
pki.tar.gz
```

Destroy master via AWS Console

```bash
$ terraform plan
$ terraform apply --auto-approve
$ scp -i cluster.key pki.tar.gz external@$(terraform output external_master_public_ip):/tmp/pki.tar.gz
$ ssh -i cluster.key external@$(terraform output external_master_public_ip)
master$ tar -zxvf /tmp/pki.tar.gz
master$ sudo kubeadm reset -f
restore pki
master$ sudo mv etc/kubernetes/pki/ /etc/kubernetes/
master$ sudo kubeadm init --config /etc/kubernetes/kubeadm.config.yaml --ignore-preflight-errors=ExternalEtcdVersion --node-name=$(hostname -f)
```

Enjoy



## Backup-Restore external-db embeded

Backup using cloud snapshot mechanism
Restore using the `#master_backup_ami` attribute:

No cloud-init
Same public/private ip

q