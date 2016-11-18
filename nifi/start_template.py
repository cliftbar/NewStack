import requests
import json
import xml.dom.minidom as minxml
import sys

try:
    # Load template file
    template_name = 'TsvToJson_ToKafka'
    template = {'template': open('nifi/' + template_name + '.xml', 'rb')}

    procs = requests.get('http://0.0.0.0:8073/nifi-api/flow/templates').json()
    curr_templates = list(map((lambda x: x['template']['name']), procs['templates']))

    if template_name not in curr_templates:
        r = requests.post('http://0.0.0.0:8073/nifi-api/process-groups/root/templates/upload', files=template)

        xmldoc = minxml.parseString(r.text)
        template_id = xmldoc.getElementsByTagName('id')[0].firstChild.nodeValue

        # Instanstiate template
        data = {'templateId': template_id, 'originX': 0.0, 'originY': 0.0}
        url = "http://0.0.0.0:8073/nifi-api/process-groups/root/template-instance"

        r2 = requests.post(url, json=data)
        jsr2 = r2.json()

        # Start processors
        psids = list(map((lambda x: x['id']), jsr2['flow']['processors']))

        procs_group = requests.get("http://0.0.0.0:8073/nifi-api/process-groups/root").json()

        for id in psids:
            url = 'http://0.0.0.0:8073/nifi-api/processors/' + id
            component = {"id": id, "state":"RUNNING"}
            revision = {"clientId": procs_group['id'], "version": procs_group['revision']['version']}
            send_json = {'component': component, 'revision': revision}
            ret = requests.put(url, json=send_json)
except:
    print("error")

