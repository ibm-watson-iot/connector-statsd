import os
import json
import ibmiotf.application

from statsd import StatsClient

from collections import Mapping
from itertools import chain
from operator import add

from numbers import Number

import iso8601
import base64
from bottle import Bottle, template
import urllib
import argparse
import logging
from logging.handlers import RotatingFileHandler

_FLAG_FIRST = object()

# See: http://stackoverflow.com/questions/6027558/flatten-nested-python-dictionaries-compressing-keys
def flattenDict(d, join=add, lift=lambda x:x):
	results = []
	def visit(subdict, results, partialKey):
		for k,v in subdict.items():
			newKey = lift(k) if partialKey==_FLAG_FIRST else join(partialKey,lift(k))
			if isinstance(v,Mapping):
				visit(v, results, newKey)
			else:
				results.append((newKey,v))
	visit(d, results, _FLAG_FIRST)
	return results


class Server():

	def __init__(self, args):
		# Setup logging - Generate a default rotating file log handler and stream handler
		logFileName = 'connector-statsd.log'
		fhFormatter = logging.Formatter('%(asctime)-25s %(levelname)-7s %(message)s')
		sh = logging.StreamHandler()
		sh.setFormatter(fhFormatter)
		
		self.logger = logging.getLogger("server")
		self.logger.addHandler(sh)
		self.logger.setLevel(logging.DEBUG)
		
		
		self.port = int(os.getenv('VCAP_APP_PORT', '9666'))
		self.host = str(os.getenv('VCAP_APP_HOST', 'localhost'))

		if args.bluemix == True:
			self.options = ibmiotf.application.ParseConfigFromBluemixVCAP()
		else:
			if args.token is not None:
				self.options = {'auth-token': args.token, 'auth-key': args.key}
			else:
				self.options = ibmiotf.application.ParseConfigFile(args.config)
		
		# Bottle
		self._app = Bottle()
		self._route()
		
		# Init IOTF client
		self.client = ibmiotf.application.Client(self.options, logHandlers=[sh])
	
		# Init statsd client
		if args.statsd:
			self.statsdHost = args.statsd
		else: 
			self.statsdHost = "localhost"
		
		self.statsd = StatsClient(self.statsdHost, prefix=self.client.orgId)
		
	
	def _route(self):
		self._app.route('/', method="GET", callback=self._status)
	
	
	def myEventCallback(self, evt):
		try:
			flatData = flattenDict(evt.data, join=lambda a,b:a+'.'+b)
			
			self.logger.debug("%-30s%s" % (evt.device, evt.event + ": " + json.dumps(flatData)))
			
			eventNamespace = evt.deviceType +  "." + evt.deviceId + "." + evt.event
			
			self.statsd.incr("events.meta." + eventNamespace)
			for datapoint in flatData:
				eventDataNamespace = "events.data." + eventNamespace + "." + datapoint[0]
				# Pass through numeric data
				# Convert boolean datapoints to numeric 0|1 representation
				# Throw away everything else (e.g. String data)
				if isinstance(datapoint[1], bool):
					if datapoint[1] == True:
						self.statsd.gauge(eventDataNamespace, 1)
					else:
						self.statsd.gauge(eventDataNamespace, 0)
				elif isinstance(datapoint[1], Number):
					self.statsd.gauge(eventDataNamespace, datapoint[1])
		except Exception as e:
			self.logger.critical("%-30s%s" % (evt.device, evt.event + ": Exception processing event - " + str(e)))
			#self.logger.critical(json.dumps(evt.data))

	def start(self):
		self.client.connect()
		self.client.deviceEventCallback = self.myEventCallback
		self.client.subscribeToDeviceEvents()
		self.logger.info("Serving at %s:%s" % (self.host, self.port))
		self._app.run(host=self.host, port=self.port)
	
	def stop(self):
		self.client.disconnect()
		
	def _status(self):
		return template('status', env_options=os.environ)



# Initialize the properties we need
parser = argparse.ArgumentParser()
parser.add_argument('-b', '--bluemix', required=False, action='store_true')
parser.add_argument('-c', '--config', required=False)
parser.add_argument('-k', '--key', required=False)
parser.add_argument('-t', '--token', required=False)
parser.add_argument('-s', '--statsd', required=False)

args, unknown = parser.parse_known_args()

server = Server(args)
server.start()
