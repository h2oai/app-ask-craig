service Web {
    string ping()
    string echo(1: string message)
    string predict(1: string jobTitle)
}

