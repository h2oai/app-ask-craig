Thrift = require 'thrift'
ML = require './gen-nodejs/AskCraig'

{ ML_SERVER_IP_PORT } = process.env

unless ML_SERVER_IP_PORT then throw new Error 'ML_SERVER_IP_PORT not specified.'

[ ip, port ] = ML_SERVER_IP_PORT.split ':'

console.log "Connecting to ML server #{ML_SERVER_IP_PORT} ..."
connection = Thrift.createConnection ip, port,
  transport : Thrift.TBufferedTransport()
  protocol : Thrift.TBinaryProtocol()

connection.on 'error', (error) ->
  console.error 'Connection failure:'
  console.error error

connection.on 'connect', ->
  console.log 'Connected.'

  console.log 'Creating ML client ...'
  ml = Thrift.createClient ML, connection

  console.log 'Retraining ...'
  ml.buildModel 'data/craigslistJobTitles.csv', (error, result) ->
    if error
      console.error 'Retraining failed:'
      console.error error
    else
      console.log 'Retraining completed.'

    console.log 'Disconnecting ...'
    connection.end()
    console.log 'Disconnected'
