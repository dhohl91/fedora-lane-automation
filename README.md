# Fedora Lane automation

Provides a staging environment on RHEL for Fedora Lane developers.

- `staging.yml`: the playbook. Each task describes one step in plain language.
- `vars/staging.yml`: the values to change, such as the developer and the packages.

Run it from Ansible Automation Platform as the job template "Staging environment".
Running it again only changes what differs from the desired state.