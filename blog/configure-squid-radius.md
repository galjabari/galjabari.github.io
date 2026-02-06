# Configure Squid proxy with RADIUS authentication

Before configuring Squid proxy to authenticate users against a RADIUS server, you need to complete the following guides:
[Install and configure RADIUS Server on Ubuntu](install-radius-server.md)
[Install and configure Proxy Server on Ubuntu](install-proxy-server.md)

Next, edit the Squid configuration file using the following command:

```
sudo nano /etc/squid/squid.conf
```

Add the following lines to the top of `http_access` section to configure RADIUS authentication:

```
auth_param basic program /usr/lib/squid/basic_radius_auth -h localhost -w testing123
auth_param basic children 5
auth_param basic realm Proxy Authentication Required
auth_param basic credentialsttl 30 minute
acl radius-auth proxy_auth REQUIRED
http_access allow radius-auth
```

Replace `localhost` with the hostname or IP address of your RADIUS server and `testing123` with your shared secret key. Make sure to define Squid proxy as a client in RADIUS server.

Remove the following line by commenting it out to restrict access to authenticated users:

```
#http_access allow localnet
```

After making changes, reload the Squid service to apply the configuration:

```
sudo systemctl reload squid.service
```

You can now connect to proxy server from your client devices using RADIUS for authentication.
