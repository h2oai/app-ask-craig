include "./shared.thrift"

namespace java water.api

struct Prediction {
    1: string label
    2: list<double> distribution
}

service AskCraig extends shared.ServiceProvider {
    /** Build initial model for a specified file */
    void buildModel(1: string file)

    /* Returns labels for predicted values. */
    list<string> getLabels()

    /* Return prediction for given job title. */
    Prediction predict(1: string jobTitle)
}