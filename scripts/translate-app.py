import requests, uuid, json, os, sys
from pathlib import Path
from glob import glob

key = sys.argv[1]
language_file = sys.argv[2] if len(sys.argv) > 2 else ''
language_code = sys.argv[3] if len(sys.argv) > 2 else ''

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

if not language_file and not language_code:
    base_dir = os.getcwd()
    base_en_dir = f"{base_dir}/wakawatch/wakawatch WatchKit Extension/en.lproj"
    
    for _, dirs, files in os.walk(f"{base_dir}/wakawatch/wakawatch WatchKit Extension"):
        for dir in dirs:
            if dir.endswith(".lproj") and dir != "en.lproj":
                already_translated_keys = []
                with open(f"{base_dir}/wakawatch/wakawatch WatchKit Extension/{dir}/Localizable.strings", "r") as translation_file:
                    for line in translation_file.readlines():
                        already_translated_keys.append(line[:line.index("=") - 1])
            
                with open(f"{base_en_dir}/Localizable.strings", "r") as base_file:
                    with open(f"{base_dir}/wakawatch/wakawatch WatchKit Extension/{dir}/Localizable.strings", "a") as translation_file:
                        language_code = dir[:dir.index(".")]
                        params['to'] = [language_code]
                        
                        for line in base_file.readlines():
                            translation_key = line[:line.index("=") - 1]
                            text_to_translate = line[line.index("=") + 3: len(line) - 3]
                            if translation_key not in already_translated_keys:
                                body = [{
                                    'text': text_to_translate
                                }]
                                request = requests.post(constructed_url, params=params, headers=headers, json=body)
                                response = request.json()
                                translation = response[0]['translations'][0]['text']
                                translation_file.write(f"{translation_key} = \"{translation}\";\n")
else:
    with open(language_file, 'r+') as file:
        lines = file.readlines()
        translated_lines = []

        for line in lines:
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