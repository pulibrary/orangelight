# [RabbitMQ](https://www.rabbitmq.com/)

## View the production RabbitMQ UI

Tunnel to a [figgy production VM](https://github.com/pulibrary/princeton_ansible/blob/main/inventory/all_projects/figgy#L5-L8)

`ssh -L 9999:figgy1.princeton.edu:15672 pulsys@figgy1`

visit `http://localhost:9999/`

Find the production rabbit - user and password - credentials in [vault vars](https://github.com/pulibrary/princeton_ansible/blob/main/group_vars/all/vault.yml) and use them to login

## View the staging RabbitMQ UI

Tunnel to a [figgy staging VM](https://github.com/pulibrary/princeton_ansible/blob/dbc180c8e6396c1ee8d5cca0fa24f8ef983202a0/inventory/all_projects/figgy#L2)  

`ssh -L 9999:figgy1.princeton.edu:15672 pulsys@figgy1`

visit `http://localhost:9999/`

Find the staging rabbit - user and password - credentials in [vault vars](https://github.com/pulibrary/princeton_ansible/blob/main/group_vars/all/vault.yml) and use them to login

# [Sneakers](https://github.com/jondot/sneakers)
We use Sneakers to process the messages that are sent to rabbitmq.

## View the sneakers log

We log sneakers in syslog. To view the syslog, ssh as pulsys in any of the catalog boxes (production or staging).

1. `ssh pulsys@catalog1`
2. `sudo less /var/log/syslog`

## Restart sneakers
If you need to restart sneakers (for example there is a datadog alert that 'there are unprocessed messages'):
`sudo service orangelight-sneakers restart`

