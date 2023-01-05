### Flipflop
Flipflop is a gem that allows you to use different strategies to turn on and off different features.

The dashboard for flipflop is at `/features`, and only administrators for the application can access it. This dashboard shows each feature, and what it is set to using different strategies. Right now, "Active record" (essentially the database) and "Default" are the only strategies, but in the future we could use strategies such as Redis, Cookies, or Sessions, and if we enable these, they will also appear on the dashboard (for configuration of these strategies see `config/features.rb`). Currently, the "Active record" strategy overrides the "Default" strategy.

Unless the feature impacts a controller or initializer (probably better not to use Flipflop for changes in these areas), it is not necessary to restart the server or deploy in order for these changes to take effect.

In order to update the application administrators, update the `ORANGELIGHT_ADMIN_NETIDS` value in princeton_ansible, run the Orangelight playbook and restart the application server.

#### In development
In order to use the dashboard in development, run the rails server with the `ORANGELIGHT_ADMIN_NETIDS` environment variable set, e.g.
```zsh
ORANGELIGHT_ADMIN_NETIDS="mk8066" bundle exec rails s
```

### Ansible-managed
Currently, `read_only_mode` is managed via Ansible. In order to set this value, change the value of `OL_READ_ONLY_MODE` in princeton_ansible and run the Orangelight playbook on the relevant environment. Because this value is set in an initializer, the application server must be restarted before this will take effect (deploying the application will do this as well).