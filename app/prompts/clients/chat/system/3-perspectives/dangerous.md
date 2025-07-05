subject: the way that Mechanic uses static analysis to derive configuration options and their types/attributes from references like `{{ options.hours__array_number_required }}` (which declares "hours" as a required array of numbers), and how we're looking at introducing more nuanced usage like `{{ options.mode__select_o1_test_o2_live }}` (which declares "mode" as an opportunity for the user to select between "test" and "live")

---

> It's too bad double underscores weren't required for every flag from the beginning, that would eliminate collisions between most flags and their auxiliary flags

the double-underscore thing... I think intuitively I was treating the double underscore kind of like a comma between positional arguments

like, these share the same psuedo-psuedocode to me:

- liquid: `options.foo__bar_baz_qux`
- psuedocode function call: `options("foo", BAR | BAZ | QUX)`
- psuedocode function signature: `options(name, flags)`

your note about using double underscores for every flag suggests this kind of thing to me:

- liquid: `options.foo__bar__baz__qux`
- psuedocode function call: `options("foo", BAR, BAZ, QUX)`
- psuedocode function signature: `options(name, *flags_array)`

I don't looooove splat operators following required positional args... feels too magical

this would feel better to me, structurally, although the aesthetics are ridiculous:

- liquid: `options.foo___bar__baz__qux`
- psuedocode function call: `options("foo", [BAR, BAZ, QUX])`
- psuedocode function signature: `options(name, flags_array)`

this would allow us to add a third class of specifier on the end, if we ever needed to:

- liquid: `options.foo___bar__baz__qux___quux`
- psuedocode function call: `options("foo", [BAR, BAZ, QUX], "this is getting quixotic")`
- psuedocode function signature: `options(name, flags_array, something_else)`

that last example is basically what we still have room for now, at the cost of y'all making flag *order* sometimes significant

- liquid: `options.foo__bar_baz_qux__quux`
- psuedocode function call: `options("foo", BAR | BAZ | QUX, "quux")`
- psuedocode function signature: `options(name, flags, something_else)`

I think I'm writing this out to illustrate the kind of forward-looking I'm always doing with schema design. I'm always always always careful to make sure there's an escape hatch slash expansion point at every level. super rare to consciously decide to seal something off from future expansion. that shit's dangerous

and by "dangerous" I mean "may eventually require systematic change at multiple levels, if change is prevented at the level where it's needed"

this is probably a metaphor for late-stage capitalism

> Is this feedback on this change? :)

nope

> or the the idea of having double underscores

it's a response to the idea of having double-underscores as separators between the flags themselves, not just between the option name and its flags

> got it, that's what I understood
> thank you for confirming

and it's not even a judgement on that idea, it's an illumination of the possibility-space that the idea points to

> So I guess the thing is, the options format that exists (`options.foo__bar_baz_qux`) didn't conceive of flags having their own arguments/sub-flags, so there's no space for a different separator that denotes those sub-flags as different from flags. The current implementation using keywords is how we get around that

*nod*

this is what I meant by "at the cost of y'all making flag *order* sometimes significant" – you've got to add the signal in *somehow*

> I was going to comment on that, I'm not sure where order would matter?

`o1_foo` != `foo_o1`

^ that's never been true before

there's nothing wrong with this approach – the history of language itself is the story of finding ways to express increasing nuance in constricted signal-space

---

(see also: horror)
