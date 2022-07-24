import requests, uuid, json, os
from pathlib import Path
from glob import glob


key = os.getenv("TRANSLATOR_API_KEY")
working_directory = os.getenv("GITHUB_WORKSPACE")

metadata_language_folders = list(map(Path, glob(f'{working_directory}/wakawatch/fastlane/metadata/*')))
language_subfolders = {p.name : p for p in metadata_language_folders}

endpoint = "https://api.cognitive.microsofttranslator.com/"
location = "westus2"
path = 'translate'
constructed_url = endpoint + path

params = {
    'api-version': '3.0',
    'from': 'en',
    'to': ['fr', 'es', 'hi', 'de', 'ja', 'pt-pt', 'ru', 'zh-Hant', 'tr', 'uk', 'th', 'it', 'sv', 'pl', 'fi', 'sk', 'ko']
}

headers = {
    'Ocp-Apim-Subscription-Key': key,
    'Ocp-Apim-Subscription-Region': location,
    'Content-Type': 'application/json',
    'X-ClientTraceId': str(uuid.uuid4())
}

with open(f"{working_directory}/wakawatch/fastlane/metadata/en-US/release_notes.txt", 'r') as file:
    release_notes = file.read()
    
    body = [{
        'text': release_notes
    }]

    request = requests.post(constructed_url, params=params, headers=headers, json=body)
    response = request.json()

    translation_responses = response[0]

    for translation in translation_responses["translations"]:
        translated_text = translation["text"]
        to_language = translation["to"]
        languages_to_read = []
        
        # TODO: Replace language code replacement logic
        if to_language == "es":
            languages_to_read.extend(["es-ES", "es-MX"])
        elif to_language == "fr":
            languages_to_read.extend(["fr-FR"])
        elif to_language == "de":
            languages_to_read.extend(["de-DE"])
        elif to_language == "pt-pt":
            languages_to_read.extend(["pt-PT"])
        else:
            languages_to_read.extend([to_language])

        for language in languages_to_read:
            with open(f"{working_directory}/wakawatch/fastlane/metadata/{language}/release_notes.txt", "r+") as translation_release_notes:
                translation_release_notes.write(translated_text)
                