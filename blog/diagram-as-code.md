---
layout: default
title: "Diagram as Code in Python"
---

# Diagram as Code in Python

To create a diagram for prototyping a new system architecture, you can use [Diagrams](https://diagrams.mingrammer.com) library in Python.

First, you need to install [Graphviz](https://graphviz.gitlab.io) to render the diagram. To install Graphviz on Ubuntu:

```
sudo apt install graphviz -y
```

After installing Graphviz, create a folder for Python code:

```
mkdir diagrams
```

Inside the folder, create a virtual environment and activate it:

```
cd diagrams
python3 -m venv .venv
source .venv/bin/activate
```

Install the `diagrams` using package installer for Python:

```
pip install diagrams
```

Now, you can generate diagrams with Python. For example, create a new Python file using your preferred editor:

```
nano diagram.py
```

Add the following code to generate a diagram for on-premise web service:

```python
from diagrams import Diagram, Cluster
from diagrams.onprem.compute import Server
from diagrams.onprem.database import MySQL
from diagrams.onprem.network import Nginx, Internet

with Diagram("Web Service", show=False, direction="LR"):
    internet = Internet("Internet")
    lb = Nginx("Load Balancer")
    
    with Cluster("Web Cluster"):
        web_cluster = [Server("Web 1"), Server("Web 2"), Server("Web 3")]
    
    with Cluster("Database HA"):
        db_primary = MySQL("DB primary")
        db_primary - MySQL("DB replica")
    
    internet - lb >> web_cluster >> db_primary
```

After saving and closing the file, run your Python code:

```
python3 diagram.py
```

The diagram will be saved as `web_service.png` on your working directory.

![](../assets/web_service.png)
