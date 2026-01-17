# CTF Infrastructure Home Assignment

Infrastructure-as-Code project that deploys:
- Vulnerable EC2 target
- CTFd platform
- Jenkins automation

## Vulnerability Validation

After the vulnerable EC2 instance is provisioned, you can validate the misconfiguration by connecting to the instance and running:

```bash
sudo ./validate_vuln.sh

