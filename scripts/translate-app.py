import requests, uuid, json, os, sys
from pathlib import Path
from glob import glob

key = sys.argv[1]
language_file = sys.argv[2]
language_code = sys.argv[3]

print(language_file)
print(language_code)

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

with open(language_file, 'r+') as file:
    lines = file.readlines()
    translated_lines = []

    for line in lines:
        translated_line = []
        translation_key = line[:line.index("=") - 1]
        text_to_translate = line[line.index("=") + 3: len(line) - 3]
        body = [{
            'text': text_to_translate
        }]

        request = requests.post(constructed_url, params=params, headers=headers, json=body)
        response = request.json()
     
        translation = response[0]['translations'][0]['text']
        translated_lines.append(f"{translation_key} = \"{translation}\";\n")
    file.seek(0)
    file.truncate()
    file.writelines(translated_lines)