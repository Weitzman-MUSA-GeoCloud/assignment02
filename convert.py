import requests
import csv

url = 'https://api.census.gov/data/2020/dec/pl?get=NAME,GEO_ID,P1_001N&for=block%20group:*&in=state:42%20county:*'

response = requests.get(url)
data = response.json()

headers = data[0]
rows = data[1:]

with open('population_2020.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['geoid', 'geoname', 'total'])
    for row in rows:
        geo_id = row[headers.index('GEO_ID')]
        name = row[headers.index('NAME')]
        total = row[headers.index('P1_001N')]
        writer.writerow([geo_id, name, total])

print('Done! population_2020.csv created.')
