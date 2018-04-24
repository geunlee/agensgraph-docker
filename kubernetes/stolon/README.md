# 환경 변수 등록
[root@k8s-master test]# export KUBECONFIG=$HOME/.kube/config

# k8s RBAC 설정
[root@k8s-master test]# kubectl create -f role.yaml
[root@k8s-master test]# kubectl create -f role-binding.yaml
[root@k8s-master test]# kubectl create -f 00-default-admin-access.yaml

# secret 생성
[root@k8s-master test]# kubectl create -f secret.yaml

# volume 설정
[root@k8s-master test]# kubectl create -f ag_local-01.yaml
[root@k8s-master test]# kubectl create -f ag_local-02.yaml

# 클러스터 초기화
[root@k8s-master test]# /home/bylee/dev/stolon-test/stolon/bin/stolonctl --cluster-name=kube-stolon --store-backend=kubernetes --kube-resource-kind=configmap init

# stolon-sentinel 생성
[root@k8s-master test]# kubectl create -f stolon-sentinel.yaml

# stolon-keeper 생성 
[root@k8s-master test]# kubectl create -f stolon-keeper.yaml

# stolon-keeper 확인
[root@k8s-master test]# docker ps -a
CONTAINER ID        IMAGE                                      COMMAND                  CREATED             STATUS              PORTS               NAMES
09d6b11b31c9        chchch888/stolon                           "/bin/bash -ec '# Ge…"   18 seconds ago      Up 16 seconds                           k8s_stolon-keeper_stolon-keeper-1_default_82fb9411-3176-11e8-8d6f-b06ebf35833a_0
df10ce00f547        gcr.io/google_containers/pause-amd64:3.0   "/pause"                 18 seconds ago      Up 17 seconds                           k8s_POD_stolon-keeper-1_default_82fb9411-3176-11e8-8d6f-b06ebf35833a_0
545cf0f694cf        chchch888/stolon                           "/bin/bash -ec '# Ge…"   20 seconds ago      Up 19 seconds                           k8s_stolon-keeper_stolon-keeper-0_default_81a023cb-3176-11e8-8d6f-b06ebf35833a_0
35419a0b2312        gcr.io/google_containers/pause-amd64:3.0   "/pause"                 20 seconds ago      Up 19 seconds                           k8s_POD_stolon-keeper-0_default_81a023cb-3176-11e8-8d6f-b06ebf35833a_0
e638104f5c14        chchch888/stolon                           "/bin/bash -ec 'exec…"   36 seconds ago      Up 34 seconds                           k8s_stolon-sentinel_stolon-sentinel-7ccf876d58-g76x6_default_784c627f-3176-11e8-8d6f-b06ebf35833a_0
4df73d83c74e        chchch888/stolon                           "/bin/bash -ec 'exec…"   36 seconds ago      Up 35 seconds                           k8s_stolon-sentinel_stolon-sentinel-7ccf876d58-rjgwx_default_784bfcd2-3176-11e8-8d6f-b06ebf35833a_0
e36b8685895e        gcr.io/google_containers/pause-amd64:3.0   "/pause"                 36 seconds ago      Up 35 seconds                           k8s_POD_stolon-sentinel-7ccf876d58-g76x6_default_784c627f-3176-11e8-8d6f-b06ebf35833a_0
6ba99a752758        gcr.io/google_containers/pause-amd64:3.0   "/pause"                 36 seconds ago      Up 35 seconds                           k8s_POD_stolon-sentinel-7ccf876d58-rjgwx_default_784bfcd2-3176-11e8-8d6f-b06ebf35833a_0
acdd6e8a9d42        stolon:master-ag1.3                        "docker-ag-entrypoin…"   2 hours ago         Up 2 hours          5432/tcp            master-ag1.3
fa390bafba5c        stolon:ag1.3-21                            "docker-entrypoint_1…"   19 hours ago        Up 19 hours         5432/tcp            some-postgres-9.6-14
aec68738fb00        fed89e8b4248                               "/sidecar --v=2 --lo…"   20 hours ago        Up 20 hours                             k8s_sidecar_kube-dns-54cccfbdf8-9wtr9_kube-system_171c9ad6-30cc-11e8-8d6f-b06ebf35833a_0
7bc46ed0da3b        gcr.io/k8s-minikube/storage-provisioner    "/storage-provisioner"   20 hours ago        Up 20 hours                             k8s_storage-provisioner_storage-provisioner_kube-system_16d59d02-30cc-11e8-8d6f-b06ebf35833a_0
82c6d7456005        459944ce8cc4                               "/dnsmasq-nanny -v=2…"   20 hours ago        Up 20 hours                             k8s_dnsmasq_kube-dns-54cccfbdf8-9wtr9_kube-system_171c9ad6-30cc-11e8-8d6f-b06ebf35833a_0
16a2dde1d357        512cd7425a73                               "/kube-dns --domain=…"   20 hours ago        Up 20 hours                             k8s_kubedns_kube-dns-54cccfbdf8-9wtr9_kube-system_171c9ad6-30cc-11e8-8d6f-b06ebf35833a_0
969ad7a4dde5        e94d2f21bc0c                               "/dashboard --insecu…"   20 hours ago        Up 20 hours                             k8s_kubernetes-dashboard_kubernetes-dashboard-77d8b98585-tfps7_kube-system_1704a07e-30cc-11e8-8d6f-b06ebf35833a_0
f9d7dc58b04a        gcr.io/google_containers/pause-amd64:3.0   "/pause"                 20 hours ago        Up 20 hours                             k8s_POD_kube-dns-54cccfbdf8-9wtr9_kube-system_171c9ad6-30cc-11e8-8d6f-b06ebf35833a_0
87b00da1894d        gcr.io/google_containers/pause-amd64:3.0   "/pause"                 20 hours ago        Up 20 hours                             k8s_POD_kubernetes-dashboard-77d8b98585-tfps7_kube-system_1704a07e-30cc-11e8-8d6f-b06ebf35833a_0
e8867e749f24        gcr.io/google_containers/pause-amd64:3.0   "/pause"                 20 hours ago        Up 20 hours                             k8s_POD_storage-provisioner_kube-system_16d59d02-30cc-11e8-8d6f-b06ebf35833a_0
76993e27c49b        d166ffa9201a                               "/opt/kube-addons.sh"    20 hours ago        Up 20 hours                             k8s_kube-addon-manager_kube-addon-manager-k8s-master_kube-system_c4c3188325a93a2d7fb1714e1abf1259_0
ff810e8e4f67        gcr.io/google_containers/pause-amd64:3.0   "/pause"                 20 hours ago        Up 20 hours                             k8s_POD_kube-addon-manager-k8s-master_kube-system_c4c3188325a93a2d7fb1714e1abf1259_0
86040cb0d5a8        chchch888/stolon:ag1.3-11-1                "docker-entrypoint.s…"   3 days ago          Up 3 days           5432/tcp            some-postgres-9.6-1
60d15bd43c60        chchch888/stolon:ag1.3-11                  "docker-entrypoint.s…"   3 days ago          Up 3 days           5432/tcp            some-postgres-9.6
4acf1397ddc9        postgres                                   "docker-entrypoint.s…"   3 days ago          Up 3 days           5432/tcp            some-postgres
 
 
--stolon-keeper log check
[root@k8s-master test]# docker logs -f k8s_stolon-keeper_stolon-keeper-1_default_82fb9411-3176-11e8-8d6f-b06ebf35833a_0
2018-03-27T04:22:52.211Z    WARN    cmd/keeper.go:158   password file permissions are too open. This file should only be readable to the user executing stolon! Continuing...   {"file": "/etc/secrets/stolon/password", "mode": "01000000777"}
2018-03-27T04:22:52.214Z    INFO    cmd/keeper.go:1914  exclusive lock on data dir taken
2018-03-27T04:22:52.217Z    INFO    cmd/keeper.go:486   keeper uid  {"uid": "keeper1"}
2018-03-27T04:22:52.225Z    INFO    cmd/keeper.go:964   our keeper data is not available, waiting for it to appear
2018-03-27T04:22:57.231Z    INFO    cmd/keeper.go:964   our keeper data is not available, waiting for it to appear
2018-03-27T04:23:02.236Z    INFO    cmd/keeper.go:1051  current db UID different than cluster data db UID   {"db": "", "cdDB": "74d8e66f"}
2018-03-27T04:23:02.236Z    INFO    cmd/keeper.go:1054  initializing the database cluster


# stolon-proxy 생성
[root@k8s-master test]# kubectl create -f stolon-proxy.yaml


# stolon-proxy-service 생성
[root@k8s-master test]# kubectl create -f stolon-proxy-service.yaml

# DB 접속
--psql connection
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


# 구성 확인
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
