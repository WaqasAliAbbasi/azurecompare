#!/usr/bin/env python
import csv
import json
import os

print ("Importing Azure libraries...")
from azure.mgmt.commerce import UsageManagementClient
from azure.common.credentials import UserPassCredentials
from azure.mgmt.resource.resources import ResourceManagementClient

from collections import defaultdict

def updateprices(specfile, datafile):
    
    #Replace this with your subscription id
    subscription_id = 'fd454c6b-2edf-40e4-bac3-bbf985868950'

    # See above for details on creating different types of AAD credentials
    credentials = UserPassCredentials(
                os.environ['AZURELOGIN'],      # Your user
                os.environ['AZUREPASSWORD'],          # Your password
        )

    print ("Connecting to Azure...")
    commerce_client = UsageManagementClient(
        credentials,
        subscription_id
    )

    resource_client = ResourceManagementClient(
        credentials,
        subscription_id
    )
    resource_client.providers.register('Microsoft.Commerce')

    print ("Getting latest instance data...")
    # OfferDurableID: https://azure.microsoft.com/en-us/support/legal/offer-details/
    rate = commerce_client.rate_card.get(
        "OfferDurableId eq 'MS-AZR-0003P' and Currency eq 'USD' and Locale eq 'en-US' and RegionInfo eq 'US'"
    , raw = True)

    rate = json.loads(rate.response._content)

    print ("Finding virtual machines...")
    virtualmachines = [x for x in rate['Meters'] if x['MeterCategory'] == "Virtual Machines"]

    csvfile = open(specfile)
    instancesSpec = list(csv.reader(csvfile, delimiter=','))
    
    instances = []
    print ("Finding regions...")
    regions = set([])
    addOnsList = {}
    for vm in virtualmachines:
        if vm['MeterRegion'] != '':
            regions.add(vm['MeterRegion'])
        elif 'VM' not in vm['MeterSubCategory']:
            addOnsList[vm['MeterSubCategory']] = vm['MeterRates']['0']   

    print ("Initializing virtual machines from spec...")
    for vm in instancesSpec[1:]:
        nested_dict = lambda: defaultdict(nested_dict)
        instance = nested_dict()
        instance['name'] = vm[0]
        instance['cores'] = vm[1]
        instance['memory'] = vm[2]
        instance['storage'] = vm[3]
        instance['GPU'] = vm[4]
        for region in regions:
            instance['pricing'][region.encode('utf-8')]['linux'] = "N/A"
            instance['pricing'][region.encode('utf-8')]['windows'] = "N/A"
            instance['pricing'][region.encode('utf-8')]['linux-low-priority'] = "N/A"
            instance['pricing'][region.encode('utf-8')]['windows-low-priority'] = "N/A"
            instance['pricing'][region.encode('utf-8')]['msft-r-server-linux'] = "N/A"
            instance['pricing'][region.encode('utf-8')]['sql-web'] = "N/A"
            instance['pricing'][region.encode('utf-8')]['sql-standard'] = "N/A"
            instance['pricing'][region.encode('utf-8')]['sql-enterprise'] = "N/A"
            instance['pricing'][region.encode('utf-8')]['biztalk-standard'] = "N/A"
            instance['pricing'][region.encode('utf-8')]['biztalk-enterprise'] = "N/A"
            instance['pricing'][region.encode('utf-8')]['oracle-java'] = "N/A"
            instance['pricing'][region.encode('utf-8')]['redhat-enterprise-linux'] = "N/A"
        instances.append(instance)

    virtualmachines = [x for x in rate['Meters'] if x['MeterCategory'] == "Virtual Machines" and x['MeterRegion'] != '']
    print ("Updating prices...")
    for vm in virtualmachines:
        found = False
        for specification in instancesSpec[1:]:
                for allowed in specification[5:]:
                    if vm['MeterSubCategory'].encode('utf-8') == allowed:
                        found = True
                        i = int(instancesSpec[1:].index(specification))
                        type = instancesSpec[0][specification.index(allowed)]
                    if found:
                        break
                if found:
                    break
        if found:
            instances[i]['pricing'][vm['MeterRegion'].encode('utf-8')][type] = vm['MeterRates']['0']

    for inst in instances:
            for addon in addOnsList:
                found = False
                for allowed in instancesSpec[1:][instances.index(inst)][9:]:
                    if addon == allowed:
                        found = True
                        type = instancesSpec[0][instancesSpec[1:][instances.index(inst)].index(allowed)]
                    if found:
                        break
                if found:
                    for region in regions:
                        if inst['pricing'][region]['linux'] != "N/A":
                            inst['pricing'][region][type] = round(addOnsList[addon] + inst['pricing'][region]['linux'],5)

    print ("Saving instances...")
    with open(datafile, 'w') as f:
        json.dump(instances,
                    f,
                    indent=2,
                    sort_keys=True,
                    separators=(',', ': '))

if __name__ == '__main__':
    updateprices('data/azurevirtualmachinesSpec.csv','data/azurevirtualmachines.json')