# Dependabot

## Secrets

We use environment variables and secrets pretty heavily. Dependabot only gets to use these when responding to a pull\_request\_target event -- it's not a thing during pull\_request. This is relevant, because some of our integration tests need to talk to a deployment environment.

Performing any automation on untrusted code is risky, and that's one way to describe what happens when we run tests on Dependabot pull requests. We use strictly separated environments to keep risk at an acceptable level.

## Automerge

This workflow sets up Dependabot pull requests for auto-merging via squash commit.

Note that it runs on pull\_request\_target. As with secrets, we use this event so that Dependabot qualifies for the necessary permissions.

.github/workflows/dependabot.yml

Copy

    name: Dependabot
    
    on: pull_request_target
    
    permissions:
      contents: write
      pull-requests: write
    
    jobs:
      dependabot:
        name: Auto-merge
        if: github.actor == 'dependabot[bot]'
        runs-on: ubuntu-latest
        steps:
          - name: Dependabot metadata
            id: metadata
            uses: dependabot/fetch-metadata@v1
            with:
              github-token: ${{ secrets.GITHUB_TOKEN }}
          - name: Enable auto-merge
            run: gh pr merge --auto --squash "$PR_URL"
            env:
              PR_URL: ${{ github.event.pull_request.html_url }}
              GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

## Ruby repositories

Note that BUNDLE\_ENTERPRISE\_\_CONTRIBSYS\_\_COM is defined as a Dependabot secret, at the organization level.

Note also that registries doesn't explicitly include rubygems.org. Don't love that, but rubygems.org appears to be included in practice anyway, so here we are.

Posting this largely so that anyone searching for Sidekiq Pro or Enterprise and Dependabot has something to find. :)

.github/dependabot.yml

Copy

    version: 2
    
    registries:
      contribsys:
        type: rubygems-server
        url: https://enterprise.contribsys.com/
        token: ${{ secrets.BUNDLE_ENTERPRISE __CONTRIBSYS__ COM }}
    
    updates:
      - package-ecosystem: bundler
        directory: /
        registries:
          - contribsys
        schedule:
          interval: daily
        # appears to be required for this package manager to work at all
        insecure-external-code-execution: allow
    
      - package-ecosystem: docker
        directory: /
        schedule:
          interval: daily
    
      - package-ecosystem: github-actions
        directory: /
        schedule:
          interval: daily

[PreviousGitHub](/technical/github)[NextMigrations](/technical/migrations)

Last updated 2024-01-08T21:25:57Z