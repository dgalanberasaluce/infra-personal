# Forgejo Runner



**Configure DNS in Docker**

Images are used to be configured with a public DNS. In case we need to resolve some internal domain names, like `ansible` trying to resolve the hosts, we need to update the `daemon.json` used by docker (`dind` in this case)

Create `dind-config/daemon.json` and mount to `dind`.

```jsonc
// dind-config/daemon.json
{
  "insecure-registries": ["forgejo.internal"], // I didn't work
  "tls": false,
  "dns": ["<DNS_IP/Router_IP>"]
}
```

**Resources**
- https://nickcunningh.am/blog/how-to-automate-version-updates-for-your-self-hosted-docker-containers-with-gitea-renovate-and-komodo
- https://nickcunningh.am/blog/how-to-setup-and-configure-forgejo-with-support-for-forgejo-actions-and-more