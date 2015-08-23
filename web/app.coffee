web = new WebClient new Thrift.TJSONProtocol new Thrift.TXHRTransport '/rpc'

web.ping (result) -> console.log arguments
web.echo 'hello!', (result) -> console.log arguments
web.predict 'Marketing manager for sparkling water!', (result) ->  console.log arguments

window.web = web
