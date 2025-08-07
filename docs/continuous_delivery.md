# Continuous delivery

After we merge a PR and CI passes, custom CI runners do the following:

1. Deploy main to staging
2. Run the smoke tests against staging
3. (not yet implemented) Deploy main to prod if everything went well


## Troubleshooting

If you get the message "Oops, there was an issue with your infrastructure. Verify your self-hosted runner infrastructure is operating and try re-running the job.", you can try restarting the job in nomad:

1. go to princeton_ansible
2. cd into nomad
3. `./bin/login`
4. go to the circleci runner job
5. hit "stop job"
6. wait, then "start job" when they all stop running


