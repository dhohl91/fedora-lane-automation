# Fedora Lane automation

Ansible automation for creating Fedora Lane developer staging environments,
maintaining demo servers, and demonstrating the developer onboarding process.

The repository is organized for use with Ansible Automation Platform (AAP), but
the playbooks can also be run with `ansible-playbook` where noted below.

## Staging environment

[`staging.yml`](staging.yml) configures RHEL hosts for a developer:

- installs the packages listed in [`vars/staging.yml`](vars/staging.yml)
- creates the `staging-devs` group
- creates or updates `staging_user` and adds that user to the group
- creates `/opt/staging` with owner and group permissions
- replaces `/etc/motd` with an ownership and management notice

The default target is `all`. Override it from AAP or the command line with
`staging_target`, and use `vars/staging.yml` to set the developer name and
package list:

```yaml
staging_user: dev-anna
staging_packages:
  - git
  - vim
  - tree
  - zip
  - wget
  - unzip
```

Run the playbook locally with an inventory:

```bash
ansible-playbook -i inventory staging.yml \
  -e staging_target=staging
```

The play requires privilege escalation and RHEL package support through DNF.
Running it repeatedly is idempotent: only missing packages, users, directories,
or configuration content are changed.

## Other playbooks

### Maintenance

The [`maintenance/`](maintenance/) directory contains AWS demo-server utilities.
They run on `localhost` and use the `us-east-2` region.

| Playbook | Purpose |
| --- | --- |
| [`maintenance/reboot_servers.yml`](maintenance/reboot_servers.yml) | Reboots the EC2 instances named `aws-rhel9` and `aws-rhel10`, then waits for SSH on their public IP addresses. |
| [`maintenance/check_network.yml`](maintenance/check_network.yml) | Tests outbound SSH to GitHub and the demo server, and inspects the `aws-test-sg` security group for a port 22 rule. |
| [`maintenance/allow_ssh.yml`](maintenance/allow_ssh.yml) | Opens TCP/22 to `0.0.0.0/0` on `aws-test-sg`. This is intended only for a disposable demo sandbox. |

The maintenance playbooks require the `amazon.aws` Ansible collection and AWS
credentials available to Ansible or the execution environment.

```bash
ansible-playbook maintenance/reboot_servers.yml
ansible-playbook maintenance/check_network.yml
ansible-playbook maintenance/allow_ssh.yml
```

### Onboarding

The [`onboarding/`](onboarding/) playbooks demonstrate an onboarding workflow
using `debug` tasks. They do not currently call GitLab or a database API.

- [`onboarding/create_gitlab_project.yml`](onboarding/create_gitlab_project.yml)
  prints the project and member names that would be created.
- [`onboarding/grant_db_access.yml`](onboarding/grant_db_access.yml) prints the
  database access action that would be granted.
- [`onboarding/notify_developer.yml`](onboarding/notify_developer.yml) prints the
  readiness notification.

These playbooks require `developer_team` and `developer_name` as extra variables:

```bash
ansible-playbook onboarding/create_gitlab_project.yml \
  -e developer_team=platform \
  -e developer_name=dev-anna
```

## Requirements

- Ansible with privilege escalation support
- RHEL-compatible hosts for `staging.yml`
- A valid Ansible inventory for remote hosts
- The `amazon.aws` collection and AWS credentials for maintenance playbooks
- Ansible Automation Platform credentials and inventory configured for the target
  environment

## AAP job templates

Suggested names for separate job templates:

- **Staging environment**: run `staging.yml`
- **Reboot demo servers**: run `maintenance/reboot_servers.yml`
- **Check network**: run `maintenance/check_network.yml`
- **Allow SSH**: run `maintenance/allow_ssh.yml`
- **Create GitLab project**: run `onboarding/create_gitlab_project.yml`
- **Grant database access**: run `onboarding/grant_db_access.yml`
- **Notify developer**: run `onboarding/notify_developer.yml`

Supply `developer_team` and `developer_name` to onboarding job templates. If a
template for `staging.yml` targets hosts through an inventory rather than the
default `all`, set `staging_target` to the inventory group name.

## Legacy script

[`legacy/create_staging_env.sh`](legacy/create_staging_env.sh) is retained as a
historical reference only. It is not idempotent and is not the supported method
for provisioning staging environments. Use `staging.yml` instead.