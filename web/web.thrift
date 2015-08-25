struct Job {
  1: required string category;
  2: required string title;
}
service Web {
  string ping();
  string echo(1: string message);
  string predict(1: string jobTitle);
  void createJob(1: Job job);
  list<Job> listJobs(1: i32 skip, 2: i32 limit);
}

