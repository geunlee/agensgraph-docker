1. 사전준비

- master, work01, work02 총 3대의 서버 필요
- kubernetes에서 사용될 docker image 위치

  https://hub.docker.com/r/bitnine/stolon
  tag : master-ag1.3.1, latest

1) docker 설치 (centos 기준)

# master, work01, work02에 모두 설치
$ yum install-y yum-utils device-mapper-persistent-data lvm2
$ yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
$ yum install-y docker-ce
$ systemctl enabledocker && systemctl start docker
2) kubernetes 설치

# master, work01, work02에 모두 설치
$ cat<<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
$ setenforce 0
$ yum install-y kubelet kubeadm kubectl
$ systemctl enablekubelet && systemctl start kubelet

$ cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

 --docker driver 수정
$ docker info | grep -i cgroup
$ cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
$ sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
$ systemctl daemon-reload && systemctl restart kubelet
3) stolon 관련 파일 준비

# master node 
git clone https://github.com/bitnineQA/agensgraph-docker.git
-> $PATH/agensgraph-docker/kubernetes/bin , $PATH/agensgraph-docker/kubernetes/stolon 

2. kubernetes 구성

# master node 
$ swapoff -a
$ kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.0.64
... 중략 ...
-> work node에 아래의 token 결과 사용됨
kubeadm join 192.168.0.64:6443 --token zmqf4v.9pa4vi8ph6j9umc8 --discovery-token-ca-cert-hash sha256:29e42e37e0456059ada08b60bb4694b7bd6bdec36fa9f4aa235c963414cc91d4


# 네트워크 플러그인 설치
$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml


# work01, work02 모두 설정
$ swapoff -a
$ kubeadm join 192.168.0.64:6443 --token zmqf4v.9pa4vi8ph6j9umc8 --discovery-token-ca-cert-hash sha256:29e42e37e0456059ada08b60bb4694b7bd6bdec36fa9f4aa235c963414cc91d4


# master node 
$ export KUBECONFIG=/etc/kubernetes/admin.conf
-- 예
$ kubectl get pods --all-namespaces -o wide
$ kubectl get nodes -o wide


# work node 
$ scp root@192.168.0.64:/etc/kubernetes/admin.conf .
--예
$ kubectl --kubeconfig ./admin.conf get pods --all-namespaces -o wide
$ kubectl --kubeconfig ./admin.conf get nodes -o wide


3. stolon 구성

$ cd $PATH/agensgraph-docker/kubernetes/stolon

-- cluster 초기화
$ PATH/bin/stolonctl --cluster-name=kube-stolon --store-backend=kubernetes --kube-resource-kind=configmap init
$ kubectl get pods --all-namespaces -o wide (상태확인)

-- k8s RBAC 설정
$ kubectl create -f role.yaml
$ kubectl create -f role-binding.yaml
$ kubectl create -f 00-default-admin-access.yaml
$ kubectl get pods --all-namespaces -o wide (상태확인)

-- secret 생성
$ kubectl create -f secret.yaml
$ kubectl get pods --all-namespaces -o wide (상태확인)

-- volume 설정
$ kubectl create -f ag_local-01.yaml
$ kubectl create -f ag_local-02.yaml
$ kubectl get pods --all-namespaces -o wide (상태확인)

-- sentinel 생성 (제공되는 docker image 외의 image 를 사용시 yaml 파일내 image 경로를 변경해야한다)
$ kubectl create -f stolon-sentinel.yaml
$ kubectl get pods --all-namespaces -o wide (상태확인)

-- keeper 생성 (제공되는 docker image 외의 image 를 사용시 yaml 파일내 image 경로를 변경해야한다)
$ kubectl create -f stolon-keeper.yaml
$ kubectl get pods --all-namespaces -o wide (상태확인)

-- porxy 생성 (제공되는 docker image 외의 image 를 사용시 yaml 파일내 image 경로를 변경해야한다)
$ kubectl create -f stolon-proxy.yaml
$ kubectl get pods --all-namespaces -o wide (상태확인)

-- proxy-service 생성
$ kubectl create -f stolon-proxy-service.yaml
$ kubectl get pods --all-namespaces -o wide (상태확인)


$PATH/bin/stolonctl  --cluster-name=kube-stolon --store-backend=kubernetes --kube-resource-kind=configmap status


--접속
# kubectl get svc
NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
kubernetes             ClusterIP   10.96.0.1      <none>        443/TCP    22m
stolon-proxy-service   ClusterIP   10.107.37.68   <none>        5432/TCP   27s
 
 
# /root/bylee/agensgraph/bin/agens --host 10.107.37.68  --port 5432 postgres -U stolon -W
Password for user stolon: password1
agens (10.3, server 9.6.2)
Type "help" for help.
 
postgres=# create graph p;
CREATE GRAPH
postgres=# create (p:person {name: 'test'});


4. fail-over 테스트

-- 마스터 죽이기
$ kubectl delete statefulset stolon-keeper --cascade=false
$ kubectl delete pod stolon-keeper-1
 
-- sentinel log에서 새로운 마스터를 선출하는 과정을 확인
$ kubectl logs -f stolon-sentinel-7955cd85f5-fhtk4
no keeper info available db=cb96f42d keeper=keeper1
no keeper info available db=cb96f42d keeper=keeper1
master db is failed db=cb96f42d keeper=keeper1
trying to find a standby to replace failed master
electing db as the new master db=087ce88a keeper=keeper0
 
-- 결과 확인
$ agens --host 10.107.37.68  --port 5432 postgres -U stolon -W
Password for user stolon: password1
agens (10.3, server 9.6.2)
Type "help" for help.
 
postgres=# match (p) return p;
              p               
------------------------------
 person[3.1]{"name": "test"}
(1 row)
