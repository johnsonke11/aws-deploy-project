import urllib.request
import json
import os

TICKERS = ["AAPL","MSFT","NVDA","GOOGL","AMZN"]

def lambda_handler(event,context):
    results = []
    for ticker in TICKERS:
        url = f"{os.environ['API_URL']}/quote?ticker={ticker}"
        try:
            req = urllib.request.urlopen(url)
            data = json.loads(req.read())
            results.append(data)
            print(f"Fetched {ticker}: {data}")
        except Exception as e:
            print(f"Failed to fetch {ticker}: {e}")
    return results