_ = require 'underscore'
argv = require('minimist') process.argv.slice 2
Thrift = require 'thrift'
workflowServer = require './gen-nodejs/AskCraig'
Workflow = require './gen-nodejs/askcraig_types'
appServer = require './gen-nodejs/Web.js'
App = require './gen-nodejs/web_types.js'
mongodb = require 'mongodb'

_.defaults argv,
  'workflow-server': 'localhost:9090'
  'database-server': 'localhost:27017'
  'port': '9091'

# ---
#TODO externalize handler for use by Express server.
#

ping = (go) -> go null, 'ACK'

echo = (message, go) -> go null, message

predictJobCategory = (jobTitle, go) -> 
  _workflow.predict jobTitle, (error, prediction) ->
    if error
      go error
    else
      go null, prediction.label

createJob = (job, go) ->
  _db.collection('jobs').insert { jobtitle: job.title, category: job.category }, (error, result) ->
    if error
      go error
    else
      go null, result

listJobs = (skip=0, limit=20, go) ->
  _db.collection('jobs').find {}, { skip, limit }, (error, jobs) ->
    list = []
    jobs.each (error, job) ->
      if error
        go error
      else
        if job
          list.push new App.Job title: job.jobtitle, category: job.category
        else
          go null, list

handler = { ping, echo, createJob, listJobs, predictJobCategory }

# --- 

_isConnectedToWorkflow = no
connectToWorkflow = (ip, port, go) ->
  connection = Thrift.createConnection ip, port,
    transport : Thrift.TBufferedTransport()
    protocol : Thrift.TBinaryProtocol()

  connection.on 'error', (error) ->
    if not _isConnectedToWorkflow and error?.code is 'ECONNREFUSED'
      process.stdout.write '.'
      #TODO fail after 10m
      setTimeout connectToWorkflow, 1000, ip, port, go
    return

  connection.on 'connect', ->
    _isConnectedToWorkflow = yes
    process.stdout.write ' connected.\n'
    go null, connection

  Thrift.createClient workflowServer, connection

connectToDatabase = (go) ->
  databaseHost = "mongodb://#{argv['database-server']}/app-ask-craig"
  process.stdout.write "Connecting to #{databaseHost} ..."
  mongodb.MongoClient.connect databaseHost, (error, connection) ->
    if error
      go error
    else
      process.stdout.write ' connected.\n'
      go null, connection

startServer = ->
  process.stdout.write 'Starting app server ...'
  server = Thrift.createWebServer
    files: '.'
    services:
      '/rpc':
        transport: Thrift.TBufferedTransport
        protocol: Thrift.TJSONProtocol
        processor: appServer
        handler: handler

  server.listen port = parseInt argv.port, 10

  process.on 'SIGTERM', ->
    console.log 'Shutting down ...'
    if _workflow
      _workflow.end()
    if _db
      _db.close() 

  process.stdout.write " started on port #{port}.\n"

_db = undefined
_workflow = undefined
main = (argv) ->
  [ workflowServerIP, workflowServerPort ] = argv['workflow-server'].split ':'
  process.stdout.write "Connecting to workflow server #{workflowServerIP}:#{workflowServerPort} ..."
  connectToWorkflow workflowServerIP, workflowServerPort, (error, connection) ->
    if error
      throw error
    else
      _workflow = connection
      connectToDatabase (error, connection) ->
        _db = connection
        if error
          throw error
        else
          startServer()

main argv
