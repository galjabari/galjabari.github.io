# Install Portainer CE with Docker

Portainer is a lightweight management UI which allows you to easily manage your Docker host or Swarm cluster. It is available as a Docker container, making it easy to deploy and manage.

In this guide, we will install Portainer Community Edition (CE) on a Docker host.

First, create a persistent volume for Portainer data:

```
sudo docker volume create portainer_data
```

Next, run the Portainer container with the following command:

```
sudo docker run -d \
  -p 8000:8000 \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```

Once the installation is complete, you can access the Portainer UI in your web browser at: `https://localhost:9443`

If you are accessing Portainer from a different machine, replace `localhost` with the Docker host's IP address.
