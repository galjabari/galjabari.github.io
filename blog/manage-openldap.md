---
layout: default
title: "Manage OpenLDAP directory on Ubuntu"
---

# Manage OpenLDAP directory on Ubuntu

You can manage the OpenLDAP directory on Linux using command-line utilities such as `ldapadd`, `ldapmodify`, and `ldapdelete`. For graphical management, tools like phpLDAPadmin and Apache Directory Studio provide user-friendly interfaces.

## Install phpLDAPadmin on Ubuntu

Update package lists and install phpLDAPadmin.

```bash
sudo apt update
sudo apt install phpldapadmin -y
```

During installation, the Apache web server may be automatically installed and configured. To access phpLDAPadmin, open a web browser on the OpenLDAP server and navigate to `http://localhost/phpldapadmin`. If you're accessing it from a different machine, replace `localhost` with the server's hostname or IP address. Log in using your LDAP administrator credentials. Once authenticated, you can browse, search, add, modify, and delete entries within the OpenLDAP directory through the phpLDAPadmin interface.

## Install Apache Directory Studio on Ubuntu

Update package lists and install Java.

```bash
sudo apt update
sudo apt install default-jre -y
```

Visit the [Apache Directory Studio](https://directory.apache.org/studio/) website and download the package suitable for your Ubuntu Linux system. After downloading, extract the archive to a preferred location. Navigate to the extracted directory and launch the `ApacheDirectoryStudio` Java application. To begin, create a new LDAP connection by entering the required details—such as the server's hostname or IP address, port number, and LDAP administrator credentials. Once connected, you can use Apache Directory Studio's graphical interface to browse, search, add, modify, and delete entries in your OpenLDAP directory.
