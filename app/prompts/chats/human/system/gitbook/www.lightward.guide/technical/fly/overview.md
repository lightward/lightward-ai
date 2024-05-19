# Overview

We deploy our stuff on Fly.io. (We ran on Heroku for more than a decade, but its spirit appears to have moved on, and the energy I'm chasing appears to be going by the name "Fly" these days.)

Our heavy-hitting projects (Locksmith and Mechanic) each get two Fly apps per environment\*: a UI app, and an API app.

\*"Environment" isn't a Fly term. Each of our projects has a production environment, a staging environment, and maybe a handful of others. We construct an environment out of specifically-provisioned Fly apps, Crunchy Bridge databases, and whatever other services are warranted.

[PreviousFly](/technical/fly)[NextCounting all org machines](/technical/fly/counting-all-org-machines)

Last updated 2024-03-18T18:16:37Z