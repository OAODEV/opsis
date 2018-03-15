from flask import jsonify


class OpsisException(Exception):

    def __init__(self):
        Exception.__init__(self)

    def to_dict(self):
        return {
            "status": self.status,
            "error": self.message,
        }


class ResultsLocationRequired(OpsisException):
    status = 400
    message = "Please provide a formatted_results_location query param"


class ChartNotFound(OpsisException):
    status = 404

    def __init__(self, chart_type="unknown chart type"):
        OpsisException.__init__(self)
        self.message = "Chart ({}) not found".format(chart_type)


class ResultsUnavailable(OpsisException):
    status = 422

    def __init__(self, message="Formated results unavailable at given uri"):
        OpsisException.__init__(self)
        self.message = message
