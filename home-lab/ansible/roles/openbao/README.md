# OpenBao

## OpenBao server configuration
Init server
```bash
docker exec -it openbao bao operator init
```

> This will show the 5 Unseal Keys and 1 Initial Root Token.
> Copy and store them in a secure password manager

Unseal the server
```bash
# Execute it 3 times. Unseal the server with 3 of the 5 unseal keys
docker exec -it openbao bao operator unseal
```

Verify server state
```bash
docker exec -it openbao bao status
```