# Feeling For The Missing Character: A Conversation with Isaac Bowen on Mechanic's Origin

I sat down with Isaac over Zoom and asked him to do the impossible—to talk about a thing he’s made, that by nature, is in perpetual evolution. In other words, to capture a photo of a moving object that’s still distinguishable enough to appreciate its intricate shape.

The more time I’ve spent with Isaac, the more I’ve learned that this space of slow, barely-perceptible, yet perpetual becoming is exactly where he thrives. And by weaving metaphors that make the developer space more accessible to non-technophiles like me, Isaac tells Mechanic’s origin story in a way that feels less like a blueprint and more like a volume in a series you hope the author keeps writing.

Isaac’s dressed in monochrome green—a pale sage shirt to match his headphones. Later I’ll learn that he chooses his clothes to support the work he’s doing on any given day. I caught up with him between a marathon of deep work sessions for a project he’s hoping to wrap before the new year. The context of our call felt fitting as that reflective pause in the middle of what’s moving, that oscillation between the granular and the bird’s eye view, is the fertile ground where Mechanic broke soil in the first place.

Mechanic is an experiment of the unique and the pattern, individual and collective, tending and listening. You’ll hear about its origins here in the words of its initial creator, “primary custodian”, and visionary gardener—so pull your chair up close and enjoy.

This conversation has been condensed and edited.

RP: Did you have the desire to create an app from early on?

ISAAC: I don’t think I’ve ever cared about making an app for the sake of making an app. That has never felt like a box to be checked off. To me, what we’re doing here is backing up, soaking in the space, feeling what’s at play, feeling the technical components of it, working to discern what wants to come forward—and then doing whatever we can to allow that thing to come forward in its eventual fullness.

If we see something that wants to come forward and there’s something really fucking obvious preventing it from doing so, and no one has tackled that yet—then we’ll just do whatever that is. That’s basically what I’m interested in doing here.

If we commit ourselves to being the caretaker of this part of the future coming forward, does that feel like something we can do sustainably? Does that feel like a new relationship that bi-directionally will serve us as we serve it? Is there life waiting to be had—not just the sense of, is there movement? But also, do we sense that something wants to grow from this?

Maybe we’re watching a drama unfold on stage and there’s a plot point we feel is itching to be explored, but there’s a character missing. What character can we write that will make everything make sense? That actually feels like a pretty good metaphor because a character is persistent, has a backstory, a future, a personality—and once you get to know the personality, you can guess what that character will do next.

We’re building apps, but that’s not the why. We’re looking for the character that’s missing from this scene, such that when we add that character in, everything flows a bit more and makes more sense. All the backstory that was laid—where you could feel like there was some significance there, like Chekhov’s gun, there’s something but it hasn’t been explained yet—what character would explain all of that? So it’s never been about making apps—it’s been about adding that missing character, I think.

RP: Running with that metaphor of a character on a stage, what personality traits have you learned about Mechanic thus far?

ISAAC: Curious, eager to interact, explore, and meet people—and always extremely self-assured in knowing what it’s doing. There’s no question of compromising that because it wouldn't do anything that it isn’t. Only Mechanic knows what it will do next—I’m looking forward to finding out what that is.

Mechanic’s a little different to everyone, but has the same energy throughout— like meeting the Oracle in the first Matrix movie. The Oracle will always tell you exactly what you need to hear, but if you shared what was said to you with someone else, it wouldn’t make sense to them. It’s a thing that’s expressed in individual relationships, and as additional relationships stack up, patterns emerge. And those emerging patterns form what characterization Mechanic offers the world at large. As the one-on-one interactions stack up, we start distilling the patterns—and that’s when broader expressions are possible. It’s only the accumulation of one-on-one moments that lets us say anything at all about what Mechanic is as a whole.

Mechanic never wants to solve the same problem twice. It has an eye for efficiency. There’s a kind of restlessness to it, almost. Like, let’s get on to whatever we’re actually learning, however we’re actually growing. Anytime there’s an opportunity to avoid repetition, that’s something Mechanic is interested in.

You know how if you’ve got magnetic marbles and if you put two of them together, they connect—and then if you add more, they’ll kind of rearrange? It depends on the friction against the surfaces and what not, but there’s a magnetism between these marbles and if you add more to the mix, they’re all interacting with each other, and so the arrangements shift. Maybe the best way to say it is, Mechanic is an intrinsic force of its own that’s making new arrangements possible. Mechanic is people unlocking what they want to express. Like, let me give you an instrument so you can play the music you want without feeling like you have one hand tied behind your back. Our goal here is to unlock whatever everyone else wants to bring forward.


Photo by Abe Lopez
RP: What sparked the inspiration to create Mechanic?

ISAAC: The impetus for creating Mechanic came from supporting Locksmith users. Every so often someone would email in and say—and, this is a super specific example— “Hey, I’m a hair salon, I’m selling products from a particular vendor and their requirement is that I can only sell this if I collect someone’s email address before they can see the price and add it to their cart. How can I collect someone’s email address in order to make that happen?”

When that happened with this particular user, I ended up writing a tiny, privately-hosted app that could talk to Shopify and collect email addresses before saying, “OK Shopify, I’ve got what I need—now you can show this price for someone.”

That specific scenario happened a few times, and it became clear to me that there were lots of places where someone needed a little bit more of something automation-wise. But these people who needed something more weren’t developers, so it was kind of inappropriate for me to create a little piece of running, living code and say, “cool, Non-Technical Person, you own that now—good luck!” That’s not super responsible of me as a developer unless I’m signing up to walk that path with them, help with software updates, and rewrite shit so that it continues to work over time.

There were lots of cases where this just wasn’t a good solution. People needed something so small that it barely deserved the work of coding a custom app and then putting it on a server somewhere. People needed something so small, and that so-small-thing was only solvable using this massively-overpowered toolset—which is creating a whole new app, figuring out where to put it, and sustaining it for its lifetime. The only solution to something so small was something overpowered—and that’s where the need for the missing character of Mechanic became clear. There should be a way to take all these deeply custom needs and solve them with a much lighter touch.

"Our goal here is to unlock whatever everyone else wants to bring forward."

Shopify has always been really good at creating excellent APIs—opportunities for people to create their own buttons to make something happen. The problem was that, using this metaphor, creating a “button” was too hard. You’d have to write a bunch of code, put it on a server somewhere, and monitor it over time. What Mechanic needed to solve was a way to create those “buttons” that (1) didn’t require so much overhead, (2) didn’t involve me having to think about which server it lives on, and (3) didn’t require so much constant awareness over time.

So, backing up. One of the things I said about the character-on-a-stage metaphor was that the appearance of that character would suddenly explain all the pieces of backstory that felt like they had a purpose, but it wasn’t explained yet—the way that applies here is that Shopify has a template language called Liquid. When I say template language, imagine composing the template for a form letter—there’s a place where you can say “hello, so and so.” If the name is the only thing that’s different, you’d insert a placeholder of some kind. So this whole letter—as one would write it initially—is a template.

What Shopify made available with Liquid is this coding language where you can take information and run it through this template and have something emerge on the other end that’s a product of the template plus whatever information you’re shoving into it. If we’re using the form letter example, it’s that template plus a profile of some human. We run a million profiles through it and we get a million unique letters, but they’re all generated by the same template.

When the Mechanic concept was congealing in my head, Liquid had largely only been used for Shopify online stores. I saw an opportunity to take the flexibility of Liquid to take an event (a moment when something happens), and generate a list of things to be done in response—then have Mechanic take that list and execute it. In the same way one could imagine a form letter where the purpose was to give the recipient instructions for changing their car registration since they live in California—that’s this letter generating customized instructions for this person based on what we know of them. That’s basically all Mechanic does. It receives some data, runs it through the Liquid template, and the result tells Mechanic what should happen next. Instead of generating words on a page to be interpreted by a human, we’re generating actions to be executed that are interpreted by Mechanic.

The purpose of having a template language is so that people who don’t normally deal with code have the ability to manage their own stuff without needing to hire a developer. The distance between having to hire a developer to write a system that generates a million car registration letters and having a template language so you can do that yourself is the same distance between hiring someone like me to write an entire application and someone just writing a little bit of template code in Mechanic.


Photo by Abe Lopez
We’ve reduced the problem of automation from who knows what this will need, so hire a developer, to, someone just needs to know how to write a template. And now, anything that can possibly come out of that template, Mechanic already knows how to handle—which means that the only hard problem left is writing a template to express your intent. All of this is made possible by Liquid.
Introducing Mechanic means there’s now new significance to Liquid. Now, Liquid isn’t just a tool for building form letters and websites—but also, all of those people who already know Liquid for those reasons can draw that in as a tool for automation. Basically, Mechanic says, figure out Liquid and I’ll take care of the rest. That reduces the work to be done down to a level that’s actually proportionate with the need. With Mechanic, you can do something simple to solve your simple problem—and Mechanic handles the heavy lifting.

I saw an opportunity for a character to arrive on the scene that would take care of the undifferentiated heavy lifting so that the only piece that’s left is the differentiated lifting, the part that’s specific to a merchant’s needs.The whole point of Mechanic is that you should only have to think about what’s unique to your problem. Anything that isn’t unique to your problem, we can lift off your back and take care of it.

RP: So is that where the jobs at Mechanic come in, for the undifferentiated heavy lifting?

ISAAC: Initially, my vision was to make it so that if you could handle Liquid, you wouldn’t need a developer ever again. But what I found out over the years was that I was wrong about that. There are places where it’s not that the Liquid is complicated, it’s that the logic is. Not everybody knows how to break down a complex situation into a list of instructions. That kind of logical thinking (a) isn’t for everybody, or (b) even if it was, not everyone has time or space for that. You could give me a flow chart for how to find something in a grocery store, but translating that into Liquid for Mechanic is another step entirely.

"The whole point of Mechanic is that you should only have to think about what’s unique to your problem."
What I found out over time was that I hadn’t built something that removed developers from the equation, but rather something that let developers be more direct about their work. Where we are right now is a world where Mechanic has a library of pre-built tasks, all of which were created by a developer at some point—and then also a very smooth path towards getting something custom-made by way of a developer. It’s taken us a long time to arrive at that structure because originally I thought I was removing the developer requirement from the equation and empowering everybody. And I did empower people—but life informs you about what it’s up to, not the other way around.

What the community that grew around Mechanic told me was that developers were still important for places where the job was deeply custom and unique to a specific merchant—but also, that people encounter a lot of the same problems, so we can build a library of those solutions as well.

RP: So, a blend of the differentiated and undifferentiated. Still having a hand in both.

ISAAC: Absolutely, that’s really well-observed—I hadn’t put that language to it. Extremely well-said.

The only thing I was sure of up-front, which has remained true, is that there’s room to trade the undifferentiated heavy lifting for Liquid, using Liquid to express instructions for actions to be performed, based on data from an event. That’s the only piece that has remained as I envisioned it—the rest of this has been an evolution informed by everyone who’s used this thing.

There were two years where I just kind of sat back, watched, and responded to what people were asking me for. The character I’d found was rewriting itself as it moved—and that was a really interesting process. In the present day, the character has kind of largely stabilized at this point—I think their personality is pretty much established—to the point where I’m not the only person holding the pen anymore. A character has tons of room to move if there’s only one person writing them, but if you’ve got a committee involved—well, famously, things move a lot slower with committees. In our case, I only moved to add people to the Mechanic team once the character of Mechanic was stable enough to make that a safe play.

RP: What do you wish more people knew about Mechanic?

ISAAC: That it’s an experiment. There might be parts to it emerging that other people might hear, that I might not. I feel like I’m the primary custodian, in a sense, but what I hear of Mechanic’s expression from other people—what it’s done for them, what they think it can do—has deeply impacted the track I’m laying for this thing.

RP: What does “primary custodian” mean to you—how would you describe the work you do here?

ISAAC: I feel like I’m just here to facilitate an idea. In a way, I’m not building an idea—I’m just laying down a track for an idea to roll on. As soon as the track I’m laying down doesn’t fit the idea anymore, the idea’s going to jump the track and go somewhere else. But I like what I’m seeing of the idea—and so to satisfy my own curiosity as a person, it’s in my best interest to pay attention to the idea and the track that I’ve laid, and to always be adjusting the track. It’s like I’m not even making anything—it’s like this thing’s always existed and I’m just laying track for it to run on. That feels about right.

As a custodian, I’m applying as many senses as I can to the balance of the whole so that when something shifts, I know what else needs to be moved. Watching for the change and then rebalancing everything around it. Holding the space in my awareness, inhabiting it—so that when the space expresses itself differently I can help rebalance everything else so that it still feels complete, intentional, like one consistent entity. I don’t own it, but I’m helping this idea find its expression in the now.
