This is a conversation from our internal #mechanic channel. It illustrates... I mean, kind of everything.

# Matt

> Question 2: Is there any way to access what kind of update triggered that event? For instance is there any way to know that it was a tag change vs price change etc?

^^ inspired by this —
I wonder if we could:
A) show a diff between the last webhook received for this resource/webhook type? So people can visually see what changed
B) give access to the previous event programmatically something like this: event.previous
This would be pretty epic! Probably some caveats here but wow that would give us something that a lot of people have been thinking about for a longtime.

I want this, at least part B. We’d have to think about the retention period

And maybe a diff filter? That gives the fields that changed between two objects?

@isaac - what do you think? is `event.previous` or something similar, feasible? Interested to hear your thoughts even if it's something we don't pursue

# Isaac

I think I dreamed about this 😂 like the night *after* you posted that message, I think I went pathfinding in my dreams

this is feasible with a prerequisite addition to the event run layer

a liquid rendering moment for taking an event and rendering a correlation id
mechanically similar to event filters, but the output being an indexable string instead of just a boolean

more later!!

# Matt

Sweet dreams are good!

I feel like this would be pretty cool. It might provide a way for someone in their task to say what changed in a webhook, which isn’t possible any other way

# Isaac

\*nod\*

in order to do this well… here’s what I’m seeing:

- find a popular and well-maintained ruby gem that can do deep diffs of json-compatible structures
  - aiming to use that for a `diff` liquid filter
  - aiming also to *replace* our existing diff implementation for displaying changes across task versions
  - spiritual precedents for this:
    - `naturally` gives us opinions for `sort_naturally`
    - `phony` gives us opinions for `e164`
    - `money` gives us opinions for `currency`
  - this kind of thing pushes the responsibility for getting the opinion right to someone else in the dev community, and gives *our* community a solid destination *that isn't us* for conversations around evolving those opinions
- new db column: `events.correlation_key` (rendered during the event run) and `events.correlation_index` (an auto-incrementing numeric value, scoped by correlation key)
  - the correlation index value would be used for sorting events for the purpose of determining which event was “previous”
  - can’t use time for that, because timestamps are non-unique
  - this introduces some hazard around events arriving out of order, but by establishing a clear platform-level protocol for how we’re determining “previous” based on correlation key, we push the responsibility for hazard-management back to the user
  - this feels a little related to event priorities… maybe there’s another future in here around identifying different event streams, and prioritizing their task runs based on event stream priority, keyed by `correlation_key`?

those two things can be done separately, obvs. a diff filter first would make sense.

this is a good example of how I think about feature development - everything always involves sketching as far into the future as I can see. who knows what will actually get built, but no future feature is ever considered in isolation of visible futures

also: keeping an eye out for regions of necessary opinion/implementation for which we can depend on existing already-specialized players. I'm not in the business of arranging pieces that aren't consistently on my primary work surface. I'm in the business of finding the simplest possible arrangement/structure to support what's already in motion and what *wants* to be in motion. (thank god for the open source community...)
