## AgensGraph Docker    

# Tag Info   
* **v1.3.0** : AgensGraph v1.3.0 / debian

# Usage (docker)    
* Image download       
$ docker pull agensgraph/agensgraph:v1.3.0       

* Container starting           
    - agens 
      $ docker run -it agensgraph/agensgraph:v1.3.0 agens
    - bash 
      $ docker run -it agensgraph/agensgraph:v1.3.0 /bin/bash

# Usage (AgensGraph)     
The image already has a graph("agens_graph"), and you can see the list of graphs created with the `\dG` command.
* list graph
agens=# \dG
* set graph
agens=#  set graph_path=[graph_name];
* show graph
agens=#  show graph_path;

# Reference
* AgensGraph Quick Guide: http://bitnine.net/wp-content/uploads/2017/06/html5/1.3-quick-guide.html
