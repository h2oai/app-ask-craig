_ = require 'underscore'
argv = require('minimist') process.argv.slice 2
Thrift = require 'thrift'
workflowServer = require './gen-nodejs/AskCraig'
Workflow = require './gen-nodejs/askcraig_types'
processor = require './gen-nodejs/Web.js'
Web = require './gen-nodejs/web_types.js'
mongodb = require 'mongodb'

_.defaults argv,
  'workflow-server': 'localhost:9090'
  'database-server': 'localhost:27017'
  'port': '9091'

[ workflowServerIP, workflowServerPort ] = argv['workflow-server'].split ':'

_workflow = undefined
_workflowServerConnection = undefined
workflow = ->
  if _workflow
    _workflow
  else
    _workflowServerConnection = Thrift.createConnection workflowServerIP, workflowServerPort,
      transport : Thrift.TBufferedTransport()
      protocol : Thrift.TBinaryProtocol()

    _workflowServerConnection.on 'error', (error) ->
      console.error JSON.stringify error

    _workflow = Thrift.createClient workflowServer, _workflowServerConnection

# ---
#TODO externalize handler for use by Express server.
#

ping = (go) -> go null, 'ACK'

echo = (message, go) -> go null, message

predict = (jobTitle, go) -> 
  workflow().predict jobTitle, (error, prediction) ->
    if error
      go error
    else
      go null, prediction.label

createJob = (job, go) ->
  #TODO

listJobs = (skip=0, limit=20, go) ->
  _db.collection('jobs').find {}, { skip, limit }, (error, jobs) ->
    list = []
    jobs.each (error, job) ->
      if error
        go error
      else
        if job
          list.push new Web.Job category: job.category, title: job.jobtitle
        else
          go null, list

handler = { ping, echo, predict, createJob, listJobs }

# --- 

_db = undefined
connectToDb = (go) ->
  mongodb.MongoClient.connect "mongodb://#{argv['database-server']}/app-ask-craig", (error, database) ->
    if error
      go error
    else
      _db = database
      go null

startServer = ->
  server = Thrift.createWebServer
    files: '.'
    services:
      '/rpc':
        transport: Thrift.TBufferedTransport
        protocol: Thrift.TJSONProtocol
        processor: processor
        handler: handler

  server.listen port = parseInt argv.port, 10
  console.log "AskCraig web server running on port #{port}."

connectToDb (error) ->
  if error
    throw error
  else

    startServer()

