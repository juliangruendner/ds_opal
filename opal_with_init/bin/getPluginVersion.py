import requests

obibaPlugins = requests.get('https://plugins.obiba.org/plugins.json').json()

for plugin in obibaPlugins['plugins']:

    if(plugin['title'] == 'SPSS'):
        print plugin['version']
