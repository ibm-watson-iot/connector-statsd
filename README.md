# Watson IoT StatsD Connector

## Docker

The gateway is packaged into a convenient docker image for ease of use: [wiotp/connector-statsd/](https://hub.docker.com/r/wiotp/connector-statsd/)

```
export GRAPHITE_HOST=xxx
export GRAPHITE_PORT=xxx
export WIOTP_API_KEY=xxx
export WIOTP_API_TOKEN=xxx

docker run wiotp/connector-statsd -e WIOTP_API_KEY -e WIOTP_API_TOKEN -e GRAPHITE_HOST -e GRAPHITE_PORT
```

## Event Metadata

Publish count and rate are available:

- `stats.$orgId.events.meta.$typeId.$deviceId.$eventId.count`  
- `stats.$orgId.events.meta.$typeId.$deviceId.$eventId.rate`

## Event Data
Each datapoint within an event is broken out into it's own statistic. Boolean datapoints are translated into `0` or `1`.

- `stats.$orgId.events.data.$typeId.$deviceId.$eventId.$datapoint`

