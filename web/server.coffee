_ = require 'underscore'
argv = require('minimist') process.argv.slice 2
Thrift = require 'thrift'
workflowServer = require './gen-nodejs/AskCraig'
Workflow = require './gen-nodejs/askcraig_types'
appServer = require './gen-nodejs/Web.js'
App = require './gen-nodejs/web_types.js'
mongodb = require 'mongodb'
Service = require './service.coffee'

_.defaults argv,
  'workflow-server': 'localhost:9090'
  'database-server': 'localhost:27017'
  'port': '9091'

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
    go null, connection: connection, client: client

  client = Thrift.createClient workflowServer, connection

connectToDatabase = (go) ->
  databaseHost = "mongodb://#{argv['database-server']}/app-ask-craig"
  process.stdout.write "Connecting to #{databaseHost} ..."
  mongodb.MongoClient.connect databaseHost, (error, connection) ->
    if error
      go error
    else
      process.stdout.write ' connected.\n'
      go null, connection

startServer = (db, workflow, workflowConnection) ->
  process.stdout.write 'Starting app server ...'
  server = Thrift.createWebServer
    files: '.'
    services:
      '/rpc':
        transport: Thrift.TBufferedTransport
        protocol: Thrift.TJSONProtocol
        processor: appServer
        handler: Service db, workflow

  server.listen port = parseInt argv.port, 10

  process.on 'SIGTERM', ->
    console.log 'Shutting down.'
    if workflowConnection
      workflowConnection.end()
    if db
      db.close() 
    process.exit 0

  process.stdout.write " started on port #{port}.\n"

main = (argv) ->
  [ workflowServerIP, workflowServerPort ] = argv['workflow-server'].split ':'
  process.stdout.write "Connecting to workflow server #{workflowServerIP}:#{workflowServerPort} ..."
  connectToWorkflow workflowServerIP, workflowServerPort, (error, workflow) ->
    if error
      throw error
    else
      workflowClient = workflow.client
      workflowConnection = workflow.connection
      connectToDatabase (error, databaseConnection) ->
        if error
          throw error
        else
          startServer databaseConnection, workflowClient, workflowConnection

main argv
