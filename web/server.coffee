_ = require 'underscore'
argv = require('minimist') process.argv.slice 2
Thrift = require 'thrift'
workflowServer = require './gen-nodejs/AskCraig'
appServer = require './gen-nodejs/Web.js'
MongoClient = require('mongodb').MongoClient
Service = require './service.coffee'

_.defaults argv,
  'workflow-server': 'localhost:9090'
  'database-server': 'localhost:27017'
  'port': '9091'

_isConnectedToWorkflow = no
connectToWorkflow = (ip, port, go) ->
  process.stdout.write "Connecting to workflow server #{ip}:#{port} ..."

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
  MongoClient.connect databaseHost, (error, db) ->
    if error
      go error
    else
      process.stdout.write ' connected.\n'
      go null, db

startServer = (db, workflow) ->
  process.stdout.write 'Starting app server ...'
  server = Thrift.createWebServer
    files: '.'
    services:
      '/rpc':
        transport: Thrift.TBufferedTransport
        protocol: Thrift.TJSONProtocol
        processor: appServer
        handler: Service db, workflow.client

  server.listen port = parseInt argv.port, 10

  process.on 'SIGTERM', ->
    console.log 'Shutting down.'
    workflow.connection.end()
    db.close() 
    process.exit 0

  process.stdout.write " started on port #{port}.\n"

main = (argv) ->
  [ workflowServerIP, workflowServerPort ] = argv['workflow-server'].split ':'
  connectToWorkflow workflowServerIP, workflowServerPort, (error, workflow) ->
    if error then throw error
    connectToDatabase (error, db) ->
      if error then throw error
      startServer db, workflow

main argv
