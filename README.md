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
