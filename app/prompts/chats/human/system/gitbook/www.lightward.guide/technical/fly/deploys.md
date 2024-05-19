# Deploys

Human autonomy and responsibility go hand in hand.

Our deploy practices reflect this, by acknowledging that there are some scenarios in which human autonomy is necessary, and ensuring that the human (1) can be nimbly responsive in those scenarios, and (2) is fully responsible for what happens in those scenarios.

If we have a situation where we actively don't want a human to be responsible, we also take away human autonomy. You can't mess around in a place where you're not responsible for the results.

## Automatic deploys

Our regular deploys are all initiated through GitHub Actions.

- To initiate a regular deploy to a production environment, we publish a new repo release. This manual action kicks off an automatic Actions workflow, which invokes flyctl deploy. Our releases are auto-prepped using Release Drafter. This means that publishing a new release is as simple as editing the latest release draft, and hitting the big green "Publish release" button.
- Regular deploys to non-production environments are triggered however's appropriate. Usually, it happens via a push to main, which kicks off an Actions workflow, which invokes flyctl deploy.

## Manual deploys

Each repo has two GHA workflows that can be manually called through the GitHub UI: one called "Manual secrets 🛠️", and one called "Manual deploy 🛠️".

Use these as needed.

## CLI deploys

This should reeeeeeaally only ever be done in an emergency situation. If you're reaching for this in a non-emergency, take a minute first, and have a think on why you're here.

Copy

    flyctl deploy \
        --app $FLY_APP_NAME \
        --strategy immediate \
        --env RELEASE_LABEL=v37 \
        --image registry.fly.io/$FLY_APP_NAME:$REPO_NAME.v37 \
        --update-only

## Recovery

Some of our apps are on the larger end. Mechanic uses upwards of 500 Machines, for example. Lots of things can go wrong. Here's some documentation on that:

Recovering from deploy failures

## Strategies

We use "immediate" in environments where deploys are manually initiated, and "bluegreen" wherever deploys are automatically initiated.

Immediate deploys finish quickly, but the actual Machine updates happen asynchronously, and may take longer. Usually they're fast, but I've seen them take more than 15min on occasion.

"Why not use a strategy (like bluegreen) that guarantees the health of new Machines before putting them into service?"

- This takes so much time. So much time. Deploys are not fast, and they're hard to interrupt, and when interrupted flyctl tries to roll back the change, and when hundreds of Machines are in play this process is kinda brittle.
- This doubles the size of our Machine pool, which doubles the number of Postgres and Redis connections in play. This hasn't actually been a problem, but it's .. you know, it's something to think about.

### Configuration

Our GitHub org has an org-level variable in place: FLY\_DEPLOY\_STRATEGY=bluegreen. This makes it the default value for all repos and their environments.

Each repository's production environment has an env-level variable in place: FLY\_DEPLOY\_STRATEGY=immediate. This makes it the effective value for that environment, and that environment alone.

## Release commands

Fly supports "release commands", which are automatically invoked during deploy, right before updating Machines with new images.

In apps that run Sidekiq, we use this feature it to issue "quiet" commands to all of our Sidekiq processes.

fly.toml excerpt

Copy

    [deploy]
    # deployment is done (and configured) via shared workflow. see:
    # https://github.com/lightward/.github-private/blob/main/.github/workflows/fly-deploy.yml
    # except for this part, where we have an app-specific interest in quieting sidekiq before release
    release_command = "bin/rake sidekiq:quiet"

Once this happens, no jobs will be performed. Jobs will be automatically resumed as Machines come back online after the deploy.

[PreviousEnvironment variables](/technical/fly/environment-variables)[NextRecovering from deploy failures](/technical/fly/deploys/recovering-from-deploy-failures)

Last updated 2024-01-09T18:33:04Z