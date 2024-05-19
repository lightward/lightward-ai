# Environment variables

GitHub is the source of truth for our environment variables, whether they be sensitive "secrets" or less sensitive "variables".

Fly has its own secret store, which contains protected values to be used as environment variables on deployed Machines. We use Fly's secret store to get our secrets onto deployed Machines, but it is not the source of truth for those values. Instead, we use Fly's secret store as a automatically-maintained mirror of whatever GitHub secrets and variables are effective for a given environment.

A "secret" is an environment variable that shouldn't be read by anything other than production code. Once configured in GitHub or Fly, you won't get that value back anywhere but in a GitHub workflow or on a Fly Machine.

A "variable" is an environment variable that's safe to be read by authorized users. If you have permission, you can view variable values in GitHub. Fly doesn't distinguish between secrets and variables; once in Fly, they're all secrets, and Fly never lets you read them back except on deployed Machines.

## Configuration

In GitHub, secrets and variables can live at any of the following levels. Each subsequent level inherits the preceding level, overriding the preceding level in case of conflict.

1. The organization level
2. The repo level, within the org
3. The environment level, within the repo

## Deploying

Secrets are populated automatically, during a repo-level GitHub workflow. Every deployable repo has its own fly-secrets.yml workflow.

## Rotating tokens

Authorization tokens are strings used to identify and authorize us to some external service.

1. Locate the external service's config area for the token in question. Example: FLY\_API\_TOKEN comes from the "Tokens" config, within a Fly app
2. Locate the secret's canonical location within GitHub. Example: FLY\_API\_TOKEN is configured at the repository environment level.
3. Without revoking the old token, generate a new token for the secret with the vendor.
4. Copy the new token value, and update the corresponding GitHub secret.
5. Deploy to whatever deployment environments receive and use this secret.
6. Verify that the new token is working in its deployed environment(s).
7. Revoke the original token.

[PreviousAutoscaling](/technical/fly/autoscaling)[NextDeploys](/technical/fly/deploys)

Last updated 2023-12-13T17:57:11Z