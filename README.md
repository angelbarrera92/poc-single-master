# POC environments

Single master Kubernetes clusters (POC).
One with embedded etcd, the other one with external etcd as a PostgreSQL database.

**Note:** Run once at a time. Place a `.deact` suffix to `external.tf` or `embeded.tf` file.

## Demo APP: Guestbook

```bash
$ kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-deployment.yaml
$ kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-service.yaml
$ kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-deployment.yaml
$ kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-service.yaml
$ kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-deployment.yaml
$ kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-service.yaml
$ kubectl scale deployment frontend --replicas=5
```

## Backup & Restore: external DB Cluster

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


## Backup & Restore: embedded DB Cluster

### Step By Step

* Create the cluster: `terraform apply --auto-approve` (remove, if any, the `master_backup_ami` value)
  * Enter the master node: `terraform output embeded_tls_private_key > key && chmod 600 key && ssh -i key embeded@$(terraform output embeded_master_public_ip)`
  * Wait for every node to join the cluster. Run `watch kubectl get nodes` in the master node.
* Scale CoreDNS: `kubectl scale deploy coredns -n kube-system --replicas=5`
* Deploy guestbook application (see commands above)
  * test it (Get the public IP of a worker instance from the AWS Console, get the port number of the frontend service)
    * http://IP:SVC-NODEPORT
    * http://IP:SVC-NODEPORT/guestbook.php?cmd=get&key=messages
* Create an AMI snapshot (Don't forget to mark to don't restart the instance while snapshotting)
  * Wait for the completion
* Deploy a pod *(alter the etcd state somehow)*
* Destroy the master instance
  * ATTENTION: During the destroy, some errors could happen
  * Check everything continues working
    * http://IP:SVC-NODEPORT
    * http://IP:SVC-NODEPORT/guestbook.php?cmd=get&key=messages
* terraform apply (with `the master_backup_ami` value)
* Check everything continues working
  * Wait for everything working
    * http://IP:SVC-NODEPORT
    * http://IP:SVC-NODEPORT/guestbook.php?cmd=get&key=messages
*  Restart worker kubelets
  * `$ ssh -i key embeded@WORKER.PUBLIC.IP sudo systemctl restart kubelet`
  * `kubectl rollout restart ds kube-proxy -n kube-system`
* `kubectl run nginx --image nginx:latest`

Enjoy
