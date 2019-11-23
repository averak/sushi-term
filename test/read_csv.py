import csv

with open('./config/text.csv') as f:
    reader = csv.reader(f)
    for row in reader:
        print(row)
