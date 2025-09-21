# Discourse
This project requires a wiki of its own as many of the configuration options need to be done inside of the application.

## Login
Initial login requires using the default admin account with the bootstrap password provided to the application.

## OIDC
Allow Security
* Navigate to Admin -> Security -> Security
* Set the setting for `allowed internal hosts` to your identity providers hostname.  auth.mydomain.tld
* Set the setting for force HTTPS

Configure OIDC
* Navigate to Admin -> Plugins -> Installed
* Enable the `OpenID Connect` and configure.  be sure to set scope to `openid email profile`