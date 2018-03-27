import csv
from io import StringIO

def monetization_csv_chart(data, report_name, display):
    print(data)
    f = StringIO(data)
    reader = csv.reader(f, delimiter=',')
    rows = list(reader)
    print(rows)
    rows[0] = ["Date", "Demand Source", "Impressions", "Estimated Revenue", "eCPM"]
    print(rows)
    return "\n".join([','.join(r) for r in rows])
