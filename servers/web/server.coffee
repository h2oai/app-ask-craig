_ = require 'underscore'
argv = require('minimist') process.argv.slice 2
Thrift = require 'thrift'
workflowServer = require './gen-nodejs/AskCraig'
Workflow = require './gen-nodejs/askcraig_types'

_.defaults argv,
  'workflow-server': 'localhost:9099'

[ workflowServerIP, workflowServerPort ] = argv['workflow-server'].split ':'
workflowServerConnection = Thrift.createConnection workflowServerIP, workflowServerPort,
  transport : Thrift.TBufferedTransport()
  protocol : Thrift.TBinaryProtocol()

workflowServerConnection.on 'error', (error) ->
  console.log error

workflow = Thrift.createClient workflowServer, workflowServerConnection

workflow.predict 'Marketing manager for sparkling water!', (error, response) ->
  if error
    console.error error
  else
    console.log response
  workflowServerConnection.end()


