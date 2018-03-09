import json
import os

import requests
import frontmatter

from flask import Flask, jsonify, request
from jinja2 import Template

app = Flask(__name__)


def jinja2_chart_factory(chart_script):

    def jinja2_chart(formatted_results, report_name, display):
        template = Template(chart_script)
        data = json.loads(formatted_results)
        return template.render(
            data=data, report_name=report_name, display=display)

    return jinja2_chart


# Chart factories are selected by chart file extension
chart_factories = {
    "jinja2": jinja2_chart_factory,
    "j2": jinja2_chart_factory,
}


def load_charts():
    templates_path = os.environ.get("CHART_TEMPLATES_PATH", "./charts")
    charts = {
        # TODO cludge, consider how builting chart types should work.
        # Maybe environment configuration?
        "noop": lambda x, _y, _z: x,
    }
    formats = {
        # "<chart type>": "<result format>",
    }
    for root, _, files in os.walk(templates_path):
        for f in files:
            chart_type, factory_name = f.split(".")
            factory = chart_factories[factory_name]
            chart_script = frontmatter.load(os.path.join(root, f))
            charts[chart_type] = factory(chart_script.content)
            required_format = chart_script.metadata.get("format", "")
            if required_format:
                formats[chart_type] = required_format
    return charts, formats


@app.route("/v1/<chart_type>/", methods=["GET"], strict_slashes=False)
def chart(chart_type):
    report_name = request.args.get("report_name")
    display = request.args.get("display")
    url = request.args.get("formatted_results_location", None)
    if url is None:
        raise Exception("No formatted_results_location")
    formatted_results = requests.get(url, headers=request.headers).text
    # TODO check response code
    charts, formats = load_charts()
    chart = charts[chart_type]
    return chart(formatted_results, report_name, display)


@app.route("/v1/", methods=["GET"], strict_slashes=False)
def interface():
    """
    return the available chart types and their result set format requirements

    """

    charts, formats = load_charts()
    format_requirements = {
        # "<chartType>": "<resultFormat>",
        # "csv": "CsvResultSet",
    }

    for chart_type in charts.keys():
        format_requirements[chart_type] = formats.get(chart_type, None)

    return jsonify(format_requirements)


@app.route("/health")
def health():
    return jsonify({"status": "200 ok"})
