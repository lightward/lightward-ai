# Counting all org machines

Copy

    fly apps list --json | jq -r '.[].ID' | xargs -n 1 fly m list -q -a | awk NF | wc -l

Last updated 2024-03-18T18:16:37Z