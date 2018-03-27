import csv
from io import StringIO

def monetization_csv_chart(data):
    f = StringIO(data)
    reader = csv.reader(f, delimiter=',')
    rows = list(reader)
    rows[0] = ["Date", "Demand Source", "Impressions", "Estimated Revenue", "eCPM"]
    return "\n".join(rows)
