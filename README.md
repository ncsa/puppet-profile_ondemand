# profile_ondemand

This module is a Puppet profile for deploying [OSC Open OnDemand](https://github.com/OSC/ondemand) at NCSA.

The following parts of the setup will be performed:
* Installing correct versions of OOD's prerequisite packages
* Installing required Apache modules
* Obtaining an SSL certificate from Let's Encrypt
* Some additional customization for NCSA's reporting and UX requirements
  * Cron jobs (e.g. for updating user mappings)
  * Custom menu items (`profile_ondemand::navbar`)
  * ACCESS reporting (`profile_ondemand::xdmod_export`)

## Setup

### Prerequisites

This module requires the following modules:
* [osc/openondemand](https://github.com/OSC/puppet-module-openondemand)
* puppet/letsencrypt
* puppetlabs/apache
* puppetlabs/stdlib

### Required configuration for other modules

These Hiera parameters are required for this module (substitute values as applicable):

#### `apache`
```yaml
apache::default_ssl_cert: "/etc/letsencrypt/live/%{facts.fqdn}/cert.pem"
apache::default_ssl_chain: "/etc/letsencrypt/live/%{facts.fqdn}/chain.pem"
apache::default_ssl_key: "/etc/letsencrypt/live/%{facts.fqdn}/privkey.pem"
apache::vhost: {}
```

#### `letsencrypt`
```yaml
letsencrypt::email: "web@ncsa.illinois.edu"
```

#### `openondemand`
Refer to https://github.com/OSC/puppet-module-openondemand?tab=readme-ov-file#usage

## Usage

```puppet
include ::profile_ondemand
```

Minimal Hiera setup
```yaml
profile_ondemand::nodejs_version: '18'
profile_ondemand::ruby_version: '3.1'
profile_ondemand::crons: {}
```

## Limitations

* Because OOD uses a custom script to generate its own Apache vhost config, this module is not compatible with [ncsa/profile_website](https://github.com/ncsa/puppet-profile_website).

* The server must be accessible from the public Internet when Let's Encrypt is attempting to obtain a certificate.
