# Autoscaling

Fly has some of its own autoscaling features, but we don't use them. (Their autoscaling only applies to process groups that serve HTTP connections, and it doesn't appear to work when websockets are mixed in.)

## Strategies

Our homegrown autoscaler pays attention to individual process groups. Each process group can be configured for up to three strategies:

- Utilization Aiming for 80% utilization, allowing 10% on either side of that before scaling up or down
- Latency Latency in excess of x results in scaling up
- History Our load patterns are very regular, and because Mechanic in particular is highly latency-sensitive, we use this strategy to scale up in anticipation of higher load based on the historical record

## Sidekiq

Scaling down is implemented as sending the "quiet" instruction to a Sidekiq process. In general, we run one Sidekiq process per Machine. When a quieted Sidekiq process that has finished its work, it's safe to stop the corresponding Machine.

Our Sidekiq leader is configured to monitor for quiet Sidekiq processes that are performing no work. Whenever such a process is detected, the leader uses flyctl to stop the corresponding Machine.

## Web

We don't have this implemented for web stuffs yet. We're just very over-provisioned, instead. :)

Last updated 2023-12-13T18:22:09Z