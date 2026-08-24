# SSL Certificate Expiry Monitoring

## Overview

This project provides an automated solution to monitor SSL/TLS certificate expiration for multiple domains and subdomains. The script checks certificate validity, calculates the remaining days before expiration, and generates alerts for certificates nearing expiry.

The solution is designed for Linux environments and can be scheduled using Cron to perform daily certificate health checks.

---

## Features

* Monitor SSL certificates for 100+ domains.
* Detect certificate expiration dates automatically.
* Generate alerts for certificates expiring within a configurable threshold.
* Produce daily reports.
* Support wildcard certificates and standard SSL certificates.
* Easy integration with email notifications.
* Lightweight and requires only OpenSSL.

---

## Repository Structure

```text
ssl-certificate-monitor/
├── certificates.txt
├── check_ssl_expiry.sh
├── logs/
│   └── ssl_expiry_report.log
└── README.md
```

---

## Prerequisites

### Operating System

* Ubuntu
* RHEL
* CentOS
* Rocky Linux
* Oracle Linux

### Required Packages

```bash
sudo apt install openssl mailutils -y
```

or

```bash
sudo yum install openssl mailx -y
```

---

## Configuration

### Domain List

Add all domains to the `certificates.txt` file.

Example:

```text
wildcard.globalworld.com
wildcard.globalworldnew.com
portal.globalworld.com
api.globalworld.com
```

Each hostname must be reachable on port 443.

---

## Script Functionality

The script performs the following actions:

1. Reads all hostnames from `certificates.txt`
2. Connects to each host using OpenSSL
3. Retrieves SSL certificate expiration date
4. Calculates remaining validity days
5. Generates warnings for certificates approaching expiration
6. Writes results to a report file
7. Optionally sends email notifications

---

## Execution

Make the script executable:

```bash
chmod +x check_ssl_expiry.sh
```

Run manually:

```bash
./check_ssl_expiry.sh
```

---

## Sample Output

```text
SSL Certificate Expiry Report

OK: wildcard.globalworld.com expires in 145 days

WARNING: wildcard.globalworldnew.com expires in 12 days

OK: api.globalworld.com expires in 87 days
```

---

## Scheduling with Cron

Run the script every day at 07:00 AM.

```bash
crontab -e
```

Add:

```cron
0 7 * * * /opt/ssl-monitor/check_ssl_expiry.sh
```

Verify cron configuration:

```bash
crontab -l
```

---

## Email Notifications

Configure the email recipient inside the script:

```bash
MAIL_TO="linux-admin@example.com"
```

When certificates are approaching expiration, an alert email will be generated automatically.

---

## Monitoring Workflow

```text
                +----------------+
                | Cron Scheduler |
                +--------+-------+
                         |
                         v
            +------------------------+
            | SSL Expiry Check Script|
            +-----------+------------+
                        |
                        v
            +------------------------+
            | OpenSSL Certificate    |
            | Validation             |
            +-----------+------------+
                        |
        +---------------+---------------+
        |                               |
        v                               v
+---------------+             +----------------+
| Report Output |             | Email Alerts   |
+---------------+             +----------------+
```

---

## Use Cases

### Enterprise SSL Monitoring

Monitor certificates across:

* Public websites
* APIs
* Load balancers
* Reverse proxies
* Kubernetes ingress endpoints

### Compliance Monitoring

Identify certificates nearing expiration to avoid:

* Service outages
* Security risks
* Compliance violations

### Centralized Operations

Enable infrastructure and operations teams to manage certificate lifecycle from a single monitoring server.

---

## Security Considerations

* Use a dedicated monitoring account.
* Restrict script execution permissions.
* Store reports securely.
* Configure SMTP authentication for email notifications.
* Monitor script execution through system logs.

---

## Troubleshooting

### Unable to Retrieve Certificate

Verify connectivity:

```bash
openssl s_client -connect hostname:443 -servername hostname
```

### DNS Resolution Issues

Verify DNS:

```bash
nslookup hostname
```

### Port 443 Unreachable

Verify network access:

```bash
telnet hostname 443
```

or

```bash
nc -zv hostname 443
```

---

---

## Author

Abdul Rehan

Linux Administrator | Cloud Engineer | DevOps Enthusiast

