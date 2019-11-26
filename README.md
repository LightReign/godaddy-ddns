# GoDaddy DDNS
Provides DDNS functionality for GoDaddy managed DNS Domains

## Motivation
If you like running your own webserver from home using a domain from GoDaddy but you have a dynamic IP address then this
program could be the solution to your problem.

This Ruby script detects your external IP address and updates A records in your GoDaddy domain for you. You can set this up in a cron or run it manually from the commandline.

Before using this you will need to get your GoDaddy API-key and secret.

## API Keys
1. Navigate to [GoDaddy Developer Portal](https://developer.godaddy.com/) and click on "Keys".
1. Login with your GoDaddy account.
1. Under "Production" click on the + sign.
1. Note down your API-key and secret.

## Requirements
Ruby (>=1.9)

## Installation and Configration
1. Check out this repository
1. Add the API key and Secret to the godaddy_ddns.yaml file
1. Add what domain you want to update (currently the script only supports updating one domain at a time)

```yaml
domain: yourdomain.com
```

1. Add the A record hostname(s) you want to be dynamically updated each time the script is run.

```yaml
dns-arecords:
    - www
    - mail
```

## Running
This script can be run inside a cron or just manually.

During execution the script writes to a file the users current external IP address. The next time the script is run it checks to see if this address has changed, if it has it will update the records with GoDaddy and update the external address file (remote_ip.addr). If the address has not changed it will simply do nothing.


If there was a problem with connecting to the API an error will be reported to STDERR handy for capturing errors when run inside a cron.

This script returns 0 on success and 1 on failure.

## Warranty
This is free software and I offer no warranty whatsoever.
