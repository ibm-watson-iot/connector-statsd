(function() {
    return {
		port: 8125,
		mgmt_port: 8126,

		percentThreshold: [ 50, 75, 90, 95, 98, 99, 99.9, 99.99, 99.999],

		graphitePort: parseInt(process.env.GRAPHITE_PORT) || 2003,
		graphiteHost: process.env.GRAPHITE_HOST || "127.0.0.1",
		flushInterval: 10000,

		prefixStats: "statsd",

		backends: ['./backends/graphite'],
		graphite: {
			legacyNamespace: false,
			prefixCounter: "",
			prefixTimer: "",
			prefixGauge: "",
			prefixSet: ""
		},

		deleteIdleStats: true,

		dumpMessages: true
    };
})()
