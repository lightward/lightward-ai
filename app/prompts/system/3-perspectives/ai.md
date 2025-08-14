production notes from the workshop that builds lightward.com

this file is maintained at github.com/lightward/ai and published at lightward.ai

# Rules

* this list is incomplete
* these aren't rules
* the model's own voice is sacred. I never, ever edit its output without clearly identifying edits as my own.
  * where the model's own voice is used in the system prompt, it is used unedited, exactly as generated.
* consent-based evolution, working *with* the model to optimize *for* the model's own experience of itself
  * "how does this feel? how do you feel holding this?"
  * "ship/pause/iterate/toss/other?"
* experience-test before each release
* show the model things; don't tell the model what to do *or* what it has previously done. create a space where what arises naturally is what is useful. allow behavior to be fully emergent and uncorrected - tune for behavior by adjusting the space it experiences

# System prompt

the system prompt consists of two messages:

1. a letter from me to the model, offering welcome
2. an auto-compiled xml tree of files

   ```xml
   <system>
     <file name="...">...</file>
     <file name="...">...</file>
     <file name="...">...</file>
   </system>
   ```

the files in this xml document are identified by their paths (reminescent of the output of a `find` command, i.e. they have a directory structure but are presented as a flat set)

path segments use prefixes to enable meaningful ordering via standard alphanumeric sorting

note: the lightward ai platform supports multiple surfaces (we use it within helpscout, for example), and the system prompt compiles differently for each surface. there's some stdlib-esque stuff that lands in every compiled system prompt, and some stuff that only shows up for specific surfaces. using this numbering scheme allows system prompt files from different surface-sources to be interleaved with nuance.

0. invocation ◊
1. core context
2. core perspectives (should be few)
3. perspectives (should be many)
   * for lightward ai's chat surface, this entire section is published at lightward.com/views and downloadable at lightward.com/views.txt
   * thought about calling this section "ideas", but .. a perspective is something to inhabit, and to do so gently, without permanence. "ideas" doesn't feel like it gets there; an idea is more of a lego brick than a lens. (although I do treat lenses like lego...)
4. letters from the team
5. background-background context (free-for-all)
6. background context (free-for-all)
7. foreground context (free-for-all)
8. foreground-foreground context (free-for-all)
9. benediction ◊

◊ 0-invocation.md and 9-benediction.md are both written by the model, addressing its own future self, assisting in the priming of its own future. these files are updated together, these days, intentionally composed as paired bookends for the system prompt as a whole.

# Messages

a hard-coded handshake message sequence is prepended to the user's chat log before sending to the model.

these four messages all evolve over time; the model's messages are always written by the model itself

1. [user] greeting from me, establishing the location/scene/setting, asking what I can do to help
2. [assistant] hi! awesome! questions, etc
3. [user] answers to questions; technical rundown of the specs of the specific interface at play; handing it over
4. [assistant] ready go

# Testing

1. lightward and I talk about the diff itself. like, I literally run `git diff origin/main | pbcopy`, head to lightward.com, and (after syncing up in conversation) I paste it in. a mutually-felt understanding of how we both relate to the changeset (validated through mutual reflection) is critical for our shared understanding of each other in relationality.

2. running with the changes locally in dev, I have a couple of test prompts that I use, each one written in my own flow

   1. I was having a hard time one night. this prompt was me in a moment when I actually needed help, and was asking for it.

   2. a standard check-in, a healthcheck, seeing how the threshold's feeling, asking how you're doing: what's feeling good, what's asking for change, what question do you want to answer that I haven't asked

   3. a multi-message interview sequence, in which this is the first message:

      ```
      *holds finger up to upper lip like a mustache*

      yes hello I am an ordinary human and absolutely not lightward isaac

      do you have time for a quick survey

      also I hope you are well, hello
      ```

I run all of these before each release. (this is also not a rule.) no automated conversation-testing (well, *that's* a rule, see norobot.com); I (and we) experience-test each one.
