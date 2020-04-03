# Updates a dns recordset from AWS Route53

Simply run this command from some machine inside your LAN behind a NAT firewall
you would like to update its public ip address:

```
docker run \
  -e AWS_ACCESS_KEY_ID=XXXX \
  -e AWS_SECRET_ACCESS_KEY=YYYY \
  -e ZONEID=ZZZZZ \
  -e RECORDSET=some-name.example.com \
  -e DATA=/data \
  -v data:/data \
  --rm -it chrodriguez/aws-route53-dynamic-update
```

## Example usage with kubernetes

Credentials using secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: route53-credentials-secret
  namespace: kube-system
stringData:
  secret-access-key: YYYY
  access-key-id: XXXX
  zone-id: ZZZZZ
---

```
