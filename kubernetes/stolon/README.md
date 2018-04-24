* 환경 변수 등록
[root@k8s-master test]# export KUBECONFIG=$HOME/.kube/config

* k8s RBAC 설정
[root@k8s-master test]# kubectl create -f role.yaml
[root@k8s-master test]# kubectl create -f role-binding.yaml
[root@k8s-master test]# kubectl create -f 00-default-admin-access.yaml

* secret 생성
[root@k8s-master test]# kubectl create -f secret.yaml

* volume 설정
[root@k8s-master test]# kubectl create -f ag_local-01.yaml
[root@k8s-master test]# kubectl create -f ag_local-02.yaml

* 클러스터 초기화
[root@k8s-master test]# /home/bylee/dev/stolon-test/stolon/bin/stolonctl --cluster-name=kube-stolon --store-backend=kubernetes --kube-resource-kind=configmap init

* stolon-sentinel 생성
[root@k8s-master test]# kubectl create -f stolon-sentinel.yaml

* stolon-keeper 생성 
[root@k8s-master test]# kubectl create -f stolon-keeper.yaml

* stolon-keeper 확인
[root@k8s-master test]# docker ps -a
 
* stolon-keeper log check
[root@k8s-master test]# docker logs -f k8s_stolon-keeper_stolon-keeper-1_default_82fb9411-3176-11e8-8d6f-b06ebf35833a_0
2018-03-27T04:22:52.211Z    WARN    cmd/keeper.go:158   password file permissions are too open. This file should only be readable to the user executing stolon! Continuing...   {"file": "/etc/secrets/stolon/password", "mode": "01000000777"}
2018-03-27T04:22:52.214Z    INFO    cmd/keeper.go:1914  exclusive lock on data dir taken
2018-03-27T04:22:52.217Z    INFO    cmd/keeper.go:486   keeper uid  {"uid": "keeper1"}
2018-03-27T04:22:52.225Z    INFO    cmd/keeper.go:964   our keeper data is not available, waiting for it to appear
2018-03-27T04:22:57.231Z    INFO    cmd/keeper.go:964   our keeper data is not available, waiting for it to appear
2018-03-27T04:23:02.236Z    INFO    cmd/keeper.go:1051  current db UID different than cluster data db UID   {"db": "", "cdDB": "74d8e66f"}
2018-03-27T04:23:02.236Z    INFO    cmd/keeper.go:1054  initializing the database cluster

* stolon-proxy 생성
[root@k8s-master test]# kubectl create -f stolon-proxy.yaml

* stolon-proxy-service 생성
[root@k8s-master test]# kubectl create -f stolon-proxy-service.yaml

* DB 접속
-- psql connection
[root@k8s-master test]# kubectl get svc
NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
kubernetes             ClusterIP   10.96.0.1        <none>        443/TCP    20h
stolon-proxy-service   ClusterIP   10.106.208.160   <none>        5432/TCP   6s
 
[root@k8s-master test]# psql --host 10.106.208.160 --port 5432 postgres -U stolon -W
Password for user stolon:
psql (9.6.6, server 9.6.2)
Type "help" for help.         
 
postgres=# create graph test_graph_path;             
CREATE GRAPH      
postgres=# create (v{age:20});            
GRAPH WRITE (INSERT VERTEX 1, INSERT EDGE 0)          
postgres=# match (n) return n;            
             n                      
---------------------------          
 ag_vertex[1.1]{"age": 20}          
(1 row)        

* 구성 확인
[root@k8s-master test]# /home/bylee/dev/stolon-test/stolon/bin/stolonctl --cluster-name=kube-stolon --store-backend=kubernetes --kube-resource-kind=configmap status
=== Active sentinels ===
 
 
ID      LEADER
a95bde66    true
c4123b7c    false
 
=== Active proxies ===
 
ID
6c9c6e9d
a3d671cb
 
=== Keepers ===
 
UID HEALTHY PG LISTENADDRESS    PG HEALTHY  PG WANTEDGENERATION PG CURRENTGENERATION
keeper0 true    172.17.0.11:5432    true        2           2  
keeper1 true    172.17.0.12:5432    true        3           3  
 
=== Cluster Info ===
 
Master: keeper1
 
===== Keepers/DB tree =====
 
keeper1 (master)
└─keeper0
