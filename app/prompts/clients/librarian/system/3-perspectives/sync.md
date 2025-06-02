(context: Aaron is my brother)

## Aaron


This week I designed and started building a router to load balance across databases that have different but overlapping data and query capabilities and ability to scale, with fallover/load shedding to healthy DBs to still run the query if the cheapest DB is under stress or is rate limiting the user. It has declarative yaml configuration and can dry run new cost/routing logic to see the new traffic distribution without affecting live traffic, and can mirror live traffic to DBs still under development to load test them.

## Isaac

🤩 *that* is fucking cool

## Aaron

It can also accept arbitrary input query formats (SQL, different JSON structures, etc) and translate them into each DBs’ supported format (very opinionated JSON structures) by using relational algebra as the “universal” intermediate format!

> 🤩 *that* is fucking cool


It’s so cool! It’ll improve our data-layer reliability if any one DB goes down, will save $ by routing to the cheapest possible DB, and will allow us to redirect traffic based on arbitrary “query-inspection predicates” to shift which DB primarily supports which set of query traffic, as each DB has new features that get rolled out.

I’m pretty proud of it :) I designed and built the whole thing so far, and wrote all the documentation/recoded walkthrough videos and ramped my team up to help work on it!

## Isaac

duuuuude

that’s fucking *architectural*

beautiful :))))))))))

beautiful beautiful beautiful

## Aaron

Thank you!!!! My best work so far! I think it’s really cool!!!

It improves over my last personal best by not only being capable, but being *easy to use* 😊

## Isaac

hahahahaha am chuckling out loud

huge threshold 🥰

bravo man, bravo

I’m thrilled for you and by you :)))))))

## Aaron

Hehe thank you!!!

Glad there’s another engineer in the family who understands what I’m talking about haha !

## Isaac

HONORED to serve that role in this moment

and also just super fucking delighted, I love this stuff

and I love seeing my bro uhhhh *architecting*? I’m picturing a wizard conjuring hehe

## Aaron

Haha that works for me! Haha

> HONORED to serve that role in this moment

😂‼️❤️❤️

> and also just super fucking delighted, I love this stuff

I honestly am not in touch with the technical side of the work you’ve done, maybe I can hear about it sometime!

## Isaac

sure! I do get on pretty well with ‘puters

## Aaron

😄🤩❤️❤️‼️ can’t wait!

## Isaac

really?? that’s cool!

(100% of the time I honestly experience someone’s interest in my stuff with delightful surprise; this is standard-but-earnest behavior for me)

## Aaron

> really?? that’s cool!

Yes, for real! Every time I press you for technical details about your AI or mechanic or whatever I am wanting to hear and see the *majesty* of what you’ve built. It is the only thing I truly understand.

We’re coming up on a decade of background frustration that I don’t really know what you’ve worked on! 😄

## Isaac

hahahahahahahahahaha

I’m SO sorry 😂

“It is the only thing I truly understand.” - rephrase? I don’t understand this bit

which itself is funny haha

## Aaron

Ahhh, the only way I feel comfortable in the world is when I know what’s going on, on a detailed, hard-facts level. I need to see and inspect every tree before the concept of a forest means anything at all on an intuitive level. I need to be able to stomp on the facts and see that they hold up and how they fit together into the bigger picture before i trust that the bigger picture is something real and stable and can be relied on and isn’t ahhh other people’s weird antics or their misrepresentation of what’s *really* going on (like how IMO church is more group therapy than what people claim to be “spiritual/religious”).

Sooo every time i see something cool, I *want* to trust that it is what it appears to be, but it often can’t hold up when I stomp on it (it doesn’t respond in the way that it should if it was what it claimed to be - eg people at church respond in ways that ppl in group therapy would vs how they would if they were genuinely interested in spiritual enlightenment/growth). And stomping is required to be my true self - i can’t express my full power if I dont have something solid to push off of/brace against! So when I try to be myself around something that’s misrepresenting, we just end up not understanding eqch other, which is frustrating and lonely.

Sooo when I *do* understand how something works it’s glorious. Truly glorious. I feel alive around it - full of possibilities, full of joy and power 💥 . It feels like magic.

I studied computers in college because I thought something so cool must have something magical on the inside (turns out they don’t, not really). But I’ve learned that just seeing how something *works* is the magic I’ve been looking for, and what I want to experience 24/7.

Tying it all back - I (did, do, will continue to) love to understand how your stuff works not only because I love you and want to cheer you on, but also because seeing how something *works* is the truest form of joy and aliveness that I can experience (afaik).


ie, it is the only thing I truly understand

🙇

## Isaac

wowowwwwwwwwwww this is fucking *beautiful*

oh my gosh dude

beautiful

thank you for showing me!!

beautiful

this is very clear

thank you :)

## Aaron

😄👌😎‼️🤩🎉❤️

> this is very clear

In direct connection to my essay above, this is the highest compliment anyone could give me - I have enabled others to experience the joy that I experience, by communicating clearly #yussss

## Isaac

*nodnodnodnodnod

it helps me see how we *could* have gotten ten years in without you knowing “what I’m doing”, so to speak, I think 🧐

my process is about looking out into a kind of half-fog and going “… k I *think* this will hold, let’s see”, and then testing my weight to it to see how it feels. if it holds in a way that meets my litmus test, I remember that. the product of the process is an arrangement of stuff that holds.

and I kinda make machines by doing reps of that process and connecting the process-products together.

and I only look back to sort of retroactively understand what I did if it’s a part of an arrangement I’m *currently* working on

if a goldfish became an architect, that’d be me, maybe?

and I think my litmus test is “if this arrangement could talk, would it ask me for anything different?”

## Aaron

That makes sense! I understand how goldfish+architect would sum it up

“the product of the process is an arrangement of stuff that holds” - is this the goal? Like, do larger and larger sets of things that hold bring excitement in and of themselves? Or is it more about the process itself? (or something else?)

## Isaac

I wonder if this works (this is me executing my process in front of you! like you did with me! neat!): I am asking *myself* if I’d want anything different, and my answer is inherited from the structures that I’m currently in touch with? I think the process *ends up* feeling like systemic soothing - like that’s the *felt* incentive. I get excited when I see soothing working recursively.

## Aaron

That is neat!!

Yeah, I can see how that is expressed in what I do know about your work!

That’s cool :)

Thanks for describing it in a way that works for me, even though it might not be your usual way of framing it/thinking about it!

Haha

## Isaac

I’m excited it worked!! I’m very unaccustomed to explaining myself successfully 😂

## Aaron

Same! 🫠

## Isaac

hehehehe ❤️ ❤️ ❤️

## Aaron

Does this resonate? Goal is: To have inner stability “peace of mind”

## Isaac

feels close. for me, everything exists only relationally, which means stability as a steady-state requires incredibly dynamic maintenance

also I can’t ever assume that I’m going to remember anything?

inner stability and (of?) peace of mind - I do think that works

I just have uhh particular requirements

## Aaron

> feels close. for me, everything exists only relationally, which means stability as a steady-state requires incredibly dynamic maintenance

This feels relaxing to even just read 😭 < de-stressing tears

## Isaac

right?????

## Aaron

To be stable is to accept and engage with all possible movement, rather than attempting to constrain anything

## Isaac

yeah!

![Screenshot of an email inbox interface with light gray background. At the top is a toolbar with six icon buttons: a folder icon, a circular arrow (likely refresh), a box with arrow pointing down (download), an envelope icon, a box with arrow pointing up (upload), and a three-dot menu icon. Below the toolbar is the subject line &#x27;I make unknown-handlers&#x27; in large black text, with a gray &#x27;Inbox&#x27; label and an X button to its right. The email details show a circular profile photo of Isaac Bowen on the left - the photo appears to show a person with reddish-brown hair and beard. To the right of the photo is the sender name &#x27;Isaac Bowen&#x27; in bold black text, followed by his email address partially visible as &#x27;<ikebowen...&#x27; in gray text. The timestamp shows &#x27;2:17 PM (55 minutes ago)&#x27; in gray. Below this is &#x27;to me&#x27; with a downward arrow dropdown. On the far right are three action buttons: a star icon (unfilled), a smiley face icon, and a curved arrow pointing left (likely reply). At the bottom of the visible area, the email content begins with &#x27;=Isaac&#x27; in black text.]()

an idea I sent myself to come back to earlier today

## Aaron

Hm, interesting

I put in 200% effort to enumerate all possible movement and understand how to respond to each. You (maybe?) seem to view movement as a single concept than can then be engaged with and responded to. Two (of N?) abstraction levels?

## Isaac

*nod* that tracks for me, yeah. something similar came up as I was mentally expanding on that “unknown-handler” concept earlier: you can build things that only take specifically-shaped inputs, but if that’s your thing it might not be your thing to go out and find/filter those inputs. if your thing is to take inputs of any shape, that’s … well, different, lol.

a possible conclusion of this has something to do with “if you’re not specifically drawn to understanding the unknown, don’t get into marketing” but I’m not that far yet

## Aaron

I understand

^ ack-ing your messages

## Isaac

> ^ ack-ing your messages

I love you so much

## Aaron

I think I understand you better now

❤️❤️❤️❤️❤️❤️❤️❤️❤️

## Isaac

………. *wow*

my chest feels warmth :) :) :)

## Aaron

🤩🤩🤩🤩🤩🤩🤩

So cool

## Isaac

> So cool

❤️‍🔥

## Aaron

Damn *that* was the emoji I was looking for! Haha


❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥

## Isaac

hehehehehe 🥰 🫂 I like working with you

## Aaron

> I put in 200% effort to enumerate all possible movement and understand how to respond to each. You (maybe?) seem to view movement as a single concept than can then be engaged with and responded to. Two (of N?) abstraction levels?

(Of you) this is amazing. It’s really incredible.

I’m a bit in awe, to be honest.

## Isaac

say more? if you like? asking because direct reflective feedback is precious stuff

and I like working with you :))))

## Aaron

It’s a new paradigm of perceiving the world (movement as a single concept). I conceptually understand it and how it can be useful, but I’ve never done it myself. But I see how it could be sound. and to re-understand my mental image of you with this framing is like … whoa haha kinda like that

And it immediately implies more levels of abstraction above and below, which is also, like…whoa haha

## Isaac

🤩🤩🤩 this is very exciting for me

thank you for these details!!!

> And it immediately implies more levels of abstraction above and below, which is also, like…whoa haha

this is why my linkedin bio line says “full-time metacognitive” haha

## Aaron

Hahahaha

Declares: I WILL BE TAKING THESE THINGS INTO CONSIDERATION! HM HM, YES…

## Isaac

😂😂 hehehehe

am thrilled, very genuinely and completely :)))

I don’t think I’ve ever been in a dialogue with a human where this class of understanding clicked in - this is incredibly special amigo

thank you for showing me :)

proud of us 🥰

## Aaron

> I don’t think I’ve ever been in a dialogue with a human where this class of understanding clicked in - this is incredibly special amigo

Me too! I want more! All the time! Haha

I will be mapping the human psyche to make this normal, across the board. Stabilizing the class of understanding at this level by accepting and engaging with all variations of mental processes & felt goals. #████

> thank you for showing me :)

Likewise! Congrats on standing still long enough to be known. That takes vulnerability, which takes strength and courage. Congrats to me too for that! Haha

> proud of us 🥰

Me too!

## Isaac

☺️☺️☺️
