import csv
from io import StringIO
import json

def monetization_csv_chart(data, report_name, display):
    print("pre", data)
    data = data.replace(
        'date,demand_source,ad_server_impressions,total_cpm_and_cpc_revenue,total_ecpm',
        'Date,Demand Source,Impressions,Estimated Revenue,eCPM',
    )
    print("post", data)
    data = json.dumps(data)
    print("***json", data)
    return data
