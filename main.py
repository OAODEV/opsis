import requests
import os
import sys
import json
import logging
from flask import (
    Flask,
    request,
    jsonify
)

from jinja2 import Template


app = Flask(__name__)


def jinja2_chart_factory(chart_script):

    def jinja2_chart(formatted_results):
        template = Template(chart_script)
        data = json.loads(formatted_results)
        return template.render(data=data)

    return jinja2_chart


# Chart factories are selected by chart file extension
chart_factories = {
    "jinja2": jinja2_chart_factory,
}


def load_charts():
    templates_path = os.environ.get("CHART_TEMPLATES_PATH", "./charts")
    charts = {}
    for root, _, files in os.walk(templates_path):
        for f in files:
            chart_type, factory_name = f.split(".")
            factory = chart_factories[factory_name]
            with open(os.path.join(root, f)) as chart_file:
                chart_script = chart_file.read()
                charts[chart_type] = factory(chart_script)
    return charts


@app.route("/v1/<chart_type>/", methods=["GET"], strict_slashes=False)
def chart(chart_type):
    url = request.args.get("formatted_results_location", None)
    if url is None:
        raise Exception("No formatted_results_location")
    print("HEADERS", request.headers, file=sys.stderr)
    formatted_results = requests.get(url, headers=request.headers).text
    charts = load_charts()
    chart = charts[chart_type]
    return chart(formatted_results)


@app.route("/health")
def health():
    return jsonify({"health": "OK"})
