server = new App.WebClient new Thrift.TJSONProtocol new Thrift.TXHRTransport '/rpc'

app.title 'Ask Craig'

server.ping (result) -> console.log arguments
server.echo 'hello!', (result) -> console.log arguments
server.predictJobCategory 'Marketing manager for sparkling water!', (result) ->  console.log arguments
server.listJobs 0, 10, (res) -> console.log res

aJob = new App.Job title: 'judo instructor needed', category: 'education'

server.createJob aJob, (result) -> console.log arguments


window.server = server
