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

predictJobCategory = (jobTitle, go) -> 
  workflow().predict jobTitle, (error, prediction) ->
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
          list.push new Web.Job title: job.jobtitle, category: job.category
        else
          go null, list

handler = { ping, echo, createJob, listJobs, predictJobCategory }

# --- 

_db = undefined
connectToDb = (go) ->
  databaseHost = "mongodb://#{argv['database-server']}/app-ask-craig"
  console.log "Connecting to #{databaseHost} ..."
  mongodb.MongoClient.connect databaseHost, (error, database) ->
    if error
      console.error 'Failed connecting to database.'
      go error
    else
      _db = database
      console.log 'Connected to database.'
      go null

startServer = ->
  console.log 'Starting server...'
  server = Thrift.createWebServer
    files: '.'
    services:
      '/rpc':
        transport: Thrift.TBufferedTransport
        protocol: Thrift.TJSONProtocol
        processor: processor
        handler: handler

  server.listen port = parseInt argv.port, 10
  process.on 'SIGTERM', ->
    _workflowServerConnection.end() if _workflowServerConnection
    _db.close() if _db
    console.log 'AskCraig web server shut down gracefully.'

  console.log "AskCraig web server running on port #{port}."

connectToDb (error) ->
  if error
    throw error
  else
    startServer()
