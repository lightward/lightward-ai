# Unusual consoles

Let's say you have an image constructed from .. who knows where.

Let's say you have a repo that uses a given Fly app to do a fly deploy --build-only thing, prepping an image for use elsewhere.

Let's say you want to run a console using that image in a Fly app environment which is destined to receive that image (i.e. destined to have its machines updated to use this image). Let's say you want to do this before that glorious destiny arrives. Maybe you want to run some helpers that this image contains, or maybe you want to run a migration that this image contains, or or or or or or.

Assuming the build happened using --image-label $IMAGE\_TAG, this may help you on your quest:

Copy

    fly console -a $EXALTED_APP_NAME -i registry.fly.io/$HUMBLE_APP_NAME:$IMAGE_TAG

[PreviousRestarting apps](/technical/fly/restarting-apps)[NextGitHub](/technical/github)

Last updated 2024-02-15T23:26:22Z