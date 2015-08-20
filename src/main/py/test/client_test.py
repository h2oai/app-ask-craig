import sys, glob
sys.path.append('gen-py')
from thrift import Thrift
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TJSONProtocol
from askcraig import AskCraig
from askcraig.ttypes import *
# Initialize
transport = TSocket.TSocket('localhost', 9090)
transport = TTransport.TBufferedTransport(transport)
protocol = TJSONProtocol.TJSONProtocol(transport)
client = AskCraig.Client(protocol)
transport.open()
# Get thrift files
client.getThrift()
# Get model labels
client.getLabels()
# Make a prediction
client.predict("Marketing manager for sparkling water!")
client.predict("Developer for sparkling water needed!")
