server = new App.WebClient new Thrift.TJSONProtocol new Thrift.TXHRTransport '/rpc'

app.title 'Ask Craig'

# server.ping (result) -> console.log arguments
# server.echo 'hello!', (result) -> console.log arguments
# server.predictJobCategory 'Marketing manager for sparkling water!', (result) ->  console.log arguments
# server.listJobs 0, 10, (res) -> console.log res
# aJob = new App.Job title: 'judo instructor needed', category: 'education'
# server.createJob aJob, (result) -> console.log arguments

add activePage, jobTitleField = textfield title: 'Enter a job posting'
add activePage, addButton = button 'Add', type: 'raised', color: 'primary'

createJobTable = (jobs) ->
  header = tr [
    th 'Category'
    th 'Title'
  ]
  rows = for job in jobs
    tr [
      td job.category
      td job.title
    ]
  table [ header ].concat rows

_jobTable = null
server.listJobs 0, 25, (jobs) ->
  if jobs 
    add activePage, _jobTable = createJobTable jobs

bind addButton, ->
  if jobTitle = get jobTitleField
    server.predictJobCategory jobTitle, (result) -> print result
    set jobTitleField, ''

    server.listJobs 0, 25, (jobs) ->
      if jobs
        remove activePage, _jobTable
        add activePage, _jobTable = createJobTable jobs




