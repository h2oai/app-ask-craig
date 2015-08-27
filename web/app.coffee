server = new App.WebClient new Thrift.TJSONProtocol new Thrift.TXHRTransport '/rpc'

app.title 'Ask Craig'

createJobListing = (jobs) ->
  block jobs.map (job) ->
    card job.title,
      items: [
        body2 job.title
        caption "Category: #{job.category}"
      ]
      menu: menu [
        command 'Edit', -> alert 'not implemented'
      ]
      style: 
        width: 'auto'
        minHeight: 'auto'

refreshJobListings = ->
  server.listJobs 0, 25, (jobs) ->
    if jobs then set jobListingView, createJobListing jobs

createJobView = ->
  jobTitleField = textarea title: 'Job Description'
  jobCategoryField = textfield 'NA', title: 'Category'

  createJob = ->
    job = new App.Job
      title: get jobTitleField
      category: get jobCategoryField
    server.createJob job, ->
      set jobTitleField, '' 
      showJobListingView()

  self = card
    title: 'Add a new job posting'
    items: [
      jobTitleField
      jobCategoryField
    ]
    buttons: [
      button 'Post', color: 'accent', createJob
      button 'Dismiss', showJobListingView
    ]
    style: 
      width: 'auto'

  updateJobCategory = (jobTitle) ->
    server.predictJobCategory jobTitle, (category) ->
      set jobCategoryField, category

  bind jobTitleField, _.throttle updateJobCategory, 500

  self

showJobListingView = ->
  hide jobView
  show jobListingView
  show buttonContainer
  refreshJobListings()

showJobView = ->
  hide jobListingView
  hide buttonContainer
  show jobView

jobListingView = block()
jobView = createJobView()

addJobButton = button 'add', type: 'floating', color: 'primary'
buttonContainer = block addJobButton, 
  style: 
    position: 'absolute'
    right: '10px'
    bottom: '10px'
    zIndex: 100

bind addJobButton, showJobView

set activePage, [ jobListingView, buttonContainer, jobView ]

showJobListingView()
