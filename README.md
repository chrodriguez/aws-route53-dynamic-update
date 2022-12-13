# Updates a dns recordset from AWS Route53

Simply run this command from some machine inside your LAN behind a NAT firewall
you would like to update its public ip address:

```
docker run \
  -e AWS_ACCESS_KEY_ID=XXXX \
  -e AWS_SECRET_ACCESS_KEY=YYYY \
  -e ZONEID=ZZZZZ \
  -e RECORDSET=some-name.example.com \
  --rm -it ghcr.io/chrodriguez/aws-route53-dynamic-update
```

It can also admit the following environment variables:

* **IP**: an IP address different than the one https://ifconfig.me returns.
  Defaults to be dynamically updated.
* **DNS_SERVER**: which DNS server use to get current DNS respose to RECORDSET.
  Defaults to 8.8.8.8
* **TTL**: TTL of recordset. Defaults to 60 seconds
* **TYPE**: which DNS record tu update. Defaults to A record


## Example usage with kubernetes

Credentials using secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: route53-credentials
  namespace: kube-system
stringData:
  secret-access-key: YYYY
  access-key-id: XXXX
  zone-id: ZZZZZ
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  labels:
    application: dns-update
  name: dns-update
spec:
  schedule: "@every 5m"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      backoffLimit: 4
      template:
        metadata:
          labels:
            application: dns-update
        spec:
          restartPolicy: Never #This allow to inspect possible POD errors
          containers:
          - name: dns-update
            image: chrodriguez/aws-route53-dynamic-update
            imagePullPolicy: Always
            env:
            - name: AWS_ACCESS_KEY_ID
              valueFrom:
                secretKeyRef:
                  name: route53-credentials
                  key: access-key-id
            - name: AWS_SECRET_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: route53-credentials
                  key: secret-access-key
            - name: ZONEID
              valueFrom:
                secretKeyRef:
                  name: route53-credentials
                  key: zone-id
            - name: RECORDSET
              value: some-name.example.com
```
