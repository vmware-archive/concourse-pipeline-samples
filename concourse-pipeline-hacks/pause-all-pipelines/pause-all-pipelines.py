#!/usr/bin/env python3

import requests
import argparse
import yaml
import urllib3
import multiprocessing
import os
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def concourse_request(api_path, type):
    func = getattr(requests, type)
    return func(url + api_path, verify=insecure, headers={
        "Authorization": "Bearer " + auth_token})


def get_pipelines():
    req = concourse_request("/api/v1/pipelines", "get")
    return req.json()


def process_pipeline(pipeline):
    concourse_request(
        "/api/v1/teams/" + pipeline['team_name'] + "/pipelines/" + pipeline['name'] + ("/unpause" if unpause else "/pause"), "put")


def process(url):
    pipelines = get_pipelines()
    pool = multiprocessing.Pool(20)
    pool.map(process_pipeline, pipelines)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Pause all the pipelines")
    parser.add_argument(
        '-t', help='concourse target', required=True)
    parser.add_argument(
        '-u', help='unpause all pipelines', required=False, action='store_true')
    args = parser.parse_args()
    flyrc = yaml.safe_load(open(os.path.expanduser("~/.flyrc")))
    url = flyrc['targets'][args.t]['api']
    auth_token = flyrc['targets'][args.t]['token']['value']
    unpause = args.u
    insecure = True if flyrc['targets'][args.t]['insecure'] == 'true' else False
    process(args.t)

