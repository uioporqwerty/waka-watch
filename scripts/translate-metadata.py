import requests, uuid, json, os, sys, shutil
from pathlib import Path
from glob import glob

key = sys.argv[1]
language_code = sys.argv[2]
english_dir = f"{os.getcwd()}/wakawatch/fastlane/metadata/en-US/"
metadata_dir = f"{os.getcwd()}/wakawatch/fastlane/metadata/{language_code}/"
os.makedirs(metadata_dir)

for file_name in os.listdir(english_dir):
    source = english_dir + file_name
    destination = metadata_dir + file_name
    shutil.copy(source, destination)

endpoint = "https://api.cognitive.microsofttranslator.com/"
location = "westus2"
path = 'translate'
constructed_url = endpoint + path

params = {
    'api-version': '3.0',
    'from': 'en',
    'to': [language_code]
}

headers = {
    'Ocp-Apim-Subscription-Key': key,
    'Ocp-Apim-Subscription-Region': location,
    'Content-Type': 'application/json',
    'X-ClientTraceId': str(uuid.uuid4())
}

for file_name in os.listdir(metadata_dir):
    if file_name in ['description.txt', 'keywords.txt', 'subtitle.txt', 'release_notes.txt']:
        with open(metadata_dir + file_name, 'r+') as file:
            if file_name == 'release_notes.txt':
                file.seek(0)
                file.truncate()
                file.write('')
                continue

            text_to_translate = file.read()
            body = [{
                'text': text_to_translate
            }]

            request = requests.post(constructed_url, params=params, headers=headers, json=body)
            response = request.json()

            translation = response[0]['translations'][0]['text']
            delete_subtitle_file = file_name == "subtitle.txt" and len(translation) > 30
            file.seek(0)
            file.truncate()
            file.write(translation)

            if delete_subtitle_file:
                os.remove(metadata_dir + file_name)