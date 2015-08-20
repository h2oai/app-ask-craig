namespace java water.service.api

service ServiceProvider {
  /* Self-aware call providing its definition. */
  list<string> getThrift()

  /** Shutdown provided service server */
  void shutdown()
}