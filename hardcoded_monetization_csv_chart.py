import csv
from io import StringIO

def monetization_csv_chart(data, report_name, display):
    print(data)
    reader = csv.reader(data.split('\r\n'), delimiter=',')
    rows = list(reader)
    print(rows)
    rows[0] = ["Date", "Demand Source", "Impressions", "Estimated Revenue", "eCPM"]
    print(rows)
    return "\r\n".join([','.join(r) for r in rows])
