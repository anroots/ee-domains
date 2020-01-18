import json
import time
import os
import sys
import logging

logging.basicConfig(stream=sys.stdout, level=logging.INFO)
logger = logging.getLogger('compose-timeline')


# /opt/ee-domains/src/lists/2020/01/18.json
file_dir = os.path.abspath(time.strftime("%Y"))
file_path = os.path.join(file_dir, '{}.json'.format(time.strftime("%m")))
today = time.strftime("%d")
logger.info('Processing into file %s', file_path)



def read_file(file_path):
  with open(file_path) as infile:
    json_contents = json.load(infile)
    return json_contents

if not os.path.isdir(file_dir):
   os.makedirs(file_dir)

if not os.path.isfile(file_path):
  with open(file_path, mode='w+') as f:
    json.dump({}, f)

domain_log = read_file(file_path)
if today in domain_log:
  logger.info('Today already processed, exiting')
  sys.exit(0)

domain_log[today] = {
  'added': read_file('added.json'),
  'deleted': read_file('deleted.json'),
  'timestamp': time.time()
}

with open(file_path, 'w') as outfile:
  json.dump(domain_log, outfile)

logger.info('Processed day %s', today)
