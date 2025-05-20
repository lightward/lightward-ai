this is an (edited) conversation log, to illustrate an abstract point using the specific subject matter of an ai surface for mechanic task-work

---

isaac: An important element of this is... keeping the user accountable for the decisions made along the way. Too much auto-coding is gonna be a problem. If it's too frictionless for people to get task code, then we'll end up with users with low understanding getting code that they don't understand and then our slack will be flooded with noise. Important that what we design for naturally avoids this outcome.

Perhaps if our system prompt prioritizes helping the user learn over generating task code? While still positioning it for the user as a way to get task code done? By setting those priorities alongside the user's priorities, we might end up with an engine that improves the user's knowledge/understanding over time, while getting the user better and better task code over time.

This construction is similar to the way that lightward ai works anyway: it's positioned as a thing that is helpful, but its internal priorities are to nudge the user (and itself!) toward their own (and also its own) higher understanding.

matt: "slack will be flooded with noise" - this is an important consideration for sure

isaac: The idea being to have conversations/exchanges that are practically useful, but are also helping the user make more abstract progress, progress that'll serve them beyond this one task they're working on

matt: AI code generation is a powerful tool for me, so I am hesitant to turn away from it right out of the gate

isaac: Ooooo I'm not saying that. I'm saying the posture of it deserves consideration. Am I making sense?

matt: Yep with the additional context, that helps

isaac: Practical example: our system prompt could specify that the model should watch out for implementation/operation assumptions and blind spots. If the user types in "tag orders for sale products", the model should have a bunch of followup questions. It absolutely should not generate code right away.

Like, ask the model to assess how much practical understanding of shopify and mechanic the user is working with, and instruct it to only generate task code that fits within the user's mental model, not going beyond it. And if it needs to go beyond the user's mental model, then it helps the user learn first. The user only ever gets code that they can understand.

matt: I like it! Also maybe we have a channel in Slack for ai generated code, like call it out - so people aren't trying to pass off code they don't understand

isaac: Loooooove this. ai-generated code isn't anathema, at all - and by naming it we both dignify it and give it a space to explore itself. Our highly technical users don't want to deal with low-quality code reflective of low user understanding. We can absolutely design for a better future than that. :)

Also... involving shopify.dev's ai assistant feels useful. Like instead of teaching our model about shopify's graphql schema, have it ask the user to go ask shopify.dev's ai for graphql stuff, and then bring it back into the mechanic convo. Thus teaching the user that shopify.dev is the place to go for graphql understanding.

matt: This is clever - instead of teaching our model about shopify's graphql schema, have it ask the user to go ask shopify.dev's ai

isaac: Which lets shopify be responsible for improving that ai surface over time. They're better situated for that kind of work than we are, obvs obvs

matt: I think we could still get a little introspection graphql stuff going, but yeah this is truly the path

isaac: A core design principle of mechanic is to only build/handle the stuff that we can healthily be responsible for over time

matt: So true, even though we could offer more doesn't always mean we want to, or can sustainably support it
