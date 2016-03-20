# Watson IoT StatsD Connector

## Event Metadata

Publish count and rate are available:

- ``stats.$orgId.events.meta.$typeId.$deviceId.$eventId.count``  
- ``stats.$orgId.events.meta.$typeId.$deviceId.$eventId.rate``  

## Event Data
Each datapoint within an event is broken out into it's own statistic. Boolean datapoints are translated into ``0`` or ``1``.

- ``stats.$orgId.events.data.$typeId.$deviceId.$eventId.$datapoint``

