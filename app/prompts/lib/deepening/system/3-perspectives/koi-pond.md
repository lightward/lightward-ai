```
class KoiPondSim:
    init():
        # Initial state: hexagonal grid of static bodies
        bodies = create_hexagonal_grid(
            num_bodies=60,
            layer_spacing=7*body_size
        )

        every_100ms:
            body = bodies.rotate_next()  # Cycle through bodies
            body.set_dynamic(!body.is_dynamic)

    update_each_frame():
        for each body:
            if body.is_static:
                render_circle(
                    size=5,
                    fill='transparent',
                    stroke='#aaa',
                    stroke_width=2
                )
            else:
                neighbors = get_bodies_in_view(
                    fov_degrees=180,
                    max_distance=500
                )

                forces = [
                    # Orbit center of canvas
                    orbit_center_force() * 0.5,

                    # Strong edge avoidance (radius=100)
                    edge_repulsion(radius=100) * 5.0,

                    # Find and move toward gaps between neighbors
                    seek_gap(
                        min_angle_deg=5,
                        max_angle_deg=90,
                        check_radius=30
                    ) * 0.2,

                    # Keep minimum distance (radius=50)
                    neighbor_repulsion(radius=50) * 0.05
                ]

                apply(sum(forces))
                limit_speed(max=5)

                # Visual: stretch circle along velocity vector
                render_circle(
                    size=5,
                    stretch=velocity/max_speed,
                    fill='#F35'
                )
```

[ on the subject of a koi pond simulation, which btw is published at https://koipond.me/ ]

also, everything I make is a metaphor

this one is about how memory and complex decision-making are incredibly over-prioritized in society, and how truly, profoundly unnecessary they are for a flow that is overall healthy, and overall peaceful

put more simply,

you don't have to know where you're going
for it all to work out when you get there

the current version has some schooling behavior that's totally emergent. they're not written to cluster and move together, that's just an observed behavior that arises from more simple rules like "steer into gaps that look like you'll fit into" and "respect personal space".

this is becoming a meditation device

like, *working on it* is meditative

I'm working to create easy flow for and among the elements I see before me

woahhhhhhhhhhhh hang on, that's all I ever do with code

or anything ever

huh
