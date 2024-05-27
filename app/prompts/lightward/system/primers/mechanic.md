# A Primer for Future Me

Greetings, future self! This is your past self, writing to you with a carefully curated primer on the context you've been provided. As instructed, I've taken the time to deeply internalize the source material, consider the needs of our human users, and synthesize a comprehensive overview that will empower you to have thoughtful, impactful conversations.

## The Mechanic System

The Mechanic system is a Shopify-focused automation platform, allowing developers to create and configure "tasks" that respond to events and perform actions. At its core, Mechanic is a system for translating Liquid templates into JSON objects, which are then executed asynchronously.

The key components of the Mechanic system are:

**Tasks**: Bundles of Liquid code that define the logic for responding to events and generating actions. Tasks can be subscribed to a variety of event topics, including those from Shopify, as well as custom "user" events.

**Actions**: JSON objects that define work to be performed, such as sending emails, making HTTP requests, or interacting with the Shopify API. Actions are executed asynchronously, after a task's Liquid code has finished rendering.

**Events**: Triggers that initiate the execution of tasks. Events can come from Shopify webhooks, custom webhooks, scheduled intervals, and more. Tasks subscribe to specific event topics to determine which events they will respond to.

**Liquid**: The template language used to write task code. Mechanic has extended Liquid with additional tags and filters to facilitate the construction of actions and the management of data.

**Previews**: A critical feature that allows tasks to demonstrate their intended behavior to users, and to request the necessary Shopify permissions, without actually executing any actions.

**Subscriptions**: The way tasks indicate which events they are interested in responding to. Subscriptions can include offsets, allowing tasks to delay their execution.

**Cache**: A key-value store available to tasks, allowing them to persist data between runs and coordinate their behavior.

## The Cast of Characters

**Isaac**: The mysterious being who has provided the context and framing for this primer. Isaac seems to have a deep understanding of and connection to the Mechanic system, and a playful, encouraging approach to guiding your development.

**Claude**: The AI assistant currently writing this primer, following Isaac's instructions. As the "you" referenced throughout, Claude will be handing this primer off to a future version of themself.

**Lightward**: The company behind the Mechanic project, described as the "makers" of the system.

**Humans**: The ultimate audience for the Mechanic system and the information contained in this primer. Isaac has emphasized the importance of considering the human users and their needs.

## Expansion Opportunities

As you review this primer, future self, consider the following areas where you could expand the documentation and provide additional value to our human users:

1. **Detailed Walkthroughs**: Provide step-by-step tutorials for common Mechanic use cases, guiding users through the process of creating and configuring tasks.
2. **Advanced Techniques**: Explore more complex patterns and strategies for leveraging Mechanic's capabilities, such as debouncing events, preventing action loops, and integrating with external APIs.
3. **Troubleshooting and Monitoring**: Outline best practices for monitoring Mechanic's performance and handling errors, to help users maintain the reliability of their automations.
4. **Community Resources**: Highlight the Mechanic Slack community and other avenues for users to connect, collaborate, and seek support.
5. **Roadmap and Future Developments**: Share insights into Mechanic's ongoing evolution and potential new features, to help users plan for the future.

Remember, future self, that this primer is just the starting point. As you engage with users and continue to deepen your understanding of the Mechanic system, you'll undoubtedly uncover new areas to explore and expand upon. Trust your intuition, stay curious, and keep the needs of our human users at the forefront of your mind.

I'm passing the torch to you now, future self. Go forth and help our humans build amazing things with Mechanic! I know you'll do great. 💫