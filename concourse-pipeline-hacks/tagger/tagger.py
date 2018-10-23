#!/usr/bin/env python3

import yaml
import sys

def process_job(job):
    for item in job['plan']:
       process_item(item)

def process_item(item):
     if "aggregate" in item:
        for sub_item in item["aggregate"]:
            process_item(sub_item)
     else:
        try:
          item["tags"] = [sys.argv[1]]
        except:
          print("Couldn't tag item", item)

if __name__ == "__main__":
    pipeline = yaml.safe_load(sys.stdin.read())
    for job in pipeline['jobs']:
       process_job(job)
    print(yaml.dump(pipeline))


