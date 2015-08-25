_ = require 'underscore'

module.exports = (db, workflow) ->
  ping = (go) -> go null, 'ACK'

  echo = (message, go) -> go null, message

  predictJobCategory = (jobTitle, go) -> 
    workflow.predict jobTitle, (error, prediction) ->
      if error
        go error
      else
        console.log "title: #{jobTitle}"
        console.log "category: #{prediction.label}"
        go null, prediction.label

  createJob = (job, go) ->
    db.collection('jobs').insert { jobtitle: job.title, category: job.category }, (error, result) ->
      if error
        go error
      else
        go null, result

  listJobs = (skip=0, limit=20, go) ->
    db.collection('jobs').find {}, { skip, limit }, (error, jobs) ->
      list = []
      jobs.each (error, job) ->
        if error
          go error
        else
          if job
            list.push new App.Job title: job.jobtitle, category: job.category
          else
            go null, list

  { ping, echo, createJob, listJobs, predictJobCategory }

