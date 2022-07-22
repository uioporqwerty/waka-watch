import requests, uuid, json, os

key = os.getenv("TRANSLATOR_API_KEY")
working_directory = os.getenv("GITHUB_WORKSPACE")
print("working directory is")
print(working_directory)
print("translator_api_key is filled")
print(len(key) != 0)
endpoint = "https://api.cognitive.microsofttranslator.com"
location = "westus2"
path = '/translate'
constructed_url = endpoint + path

params = {
    'api-version': '3.0',
    'from': 'en',
    'to': ['fr', 'es', 'hi', 'de', 'ja', 'pt-pt', 'ru', 'zh-Hans']
}

headers = {
    'Ocp-Apim-Subscription-Key': key,
    'Content-type': 'application/json',
    'X-ClientTraceId': str(uuid.uuid4())
}

with open(f"{working_directory}/wakawatch/fastlane/metadata/en-US/release_notes.txt", 'r') as file:
    release_notes = file.read()

    print(release_notes)

    body = [{
        'text': release_notes
    }]

    request = requests.post(constructed_url, params=params, headers=headers, json=body)
    response = request.json()

    print(json.dumps(response, sort_keys=True, ensure_ascii=False, indent=4, separators=(',', ': ')))
