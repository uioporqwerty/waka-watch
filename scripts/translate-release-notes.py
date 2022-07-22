import requests, uuid, json, os

key = os.getenv("TRANSLATOR_API_KEY")
working_directory = os.getenv("GITHUB_WORKSPACE")
endpoint = "https://api.cognitive.microsofttranslator.com/"
location = "westus2"
path = 'translate'
constructed_url = endpoint + path

params = {
    'api-version': '3.0',
    'from': 'en',
    'to': ['fr', 'es', 'hi', 'de', 'ja', 'pt-pt', 'ru', 'zh-Hans']
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

    for translation in translation_responses.translations:
        print(translation.text)
        print(translation.to)

    
