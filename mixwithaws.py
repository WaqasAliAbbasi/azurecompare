#!/usr/bin/env python
import json

from collections import defaultdict

def mixaws(datafile, awsdatafile, mixeddatafile):
    with open(datafile) as data_file:
        instances = json.load(data_file)
    
    with open(awsdatafile) as data_file:
        awsdata = json.load(data_file)

    awsregion = {
        'AP East' : 'N/A',
        'AP Southeast' : 'ap-southeast-1',
        'AU East' : 'ap-southeast-2',
        'AU Southeast' : 'N/A',
        'BR South' : 'sa-east-1',
        'CA Central' : 'ca-central-1',
        'CA East' : 'N/A',
        'EU North' : 'eu-central-1',
        'EU West' : 'eu-west-1',
        'IN Central' : 'ap-south-1',
        'IN South' : 'N/A',
        'IN West' : 'N/A',
        'JA East' : 'N/A',
        'JA West' : 'ap-northeast-1',
        'KR Central' : 'ap-northeast-2',
        'KR South' : 'N/A',
        'UK South' : 'eu-west-2',
        'UK West' : 'N/A',
        'US Central' : 'N/A',
        'US East' : 'us-east-1',
        'US East 2' : 'us-east-2',
        'US Gov AZ' : 'N/A',
        'US Gov TX' : 'N/A',
        'US North Central' : 'N/A',
        'US South Central' : 'N/A',
        'US West' : 'us-west-1',
        'US West 2' : 'us-west-2',
        'US West Central' : 'N/A',
        'USGov' : 'N/A',
        }

    for inst in awsdata:
        nested_dict = lambda: defaultdict(nested_dict)
        instance = nested_dict()
        instance['name'] = "(AWS) " + inst['pretty_name']
        instance['cores'] = inst['vCPU']
        instance['memory'] = '%.2f' % round(inst['memory'], 2)
        if inst['storage'] != None:
            instance['storage'] = inst['storage']['size']
        else:
            instance['storage'] = "EBS Only"
        if inst['GPU'] == 0:
            instance['GPU'] = 'N/A'
        else:
            instance['GPU'] = inst['GPU']
        for region in awsregion.keys():
            instance['pricing'][region.encode('utf-8')]['linux'] = 'N/A'
            instance['pricing'][region.encode('utf-8')]['windows'] = 'N/A'
            instance['pricing'][region.encode('utf-8')]['sql-web'] = 'N/A'
            instance['pricing'][region.encode('utf-8')]['sql-standard'] = 'N/A'
            if awsregion[region.encode('utf-8')] != 'N/A':
                if awsregion[region.encode('utf-8')] in inst['pricing'].keys():
                    if 'linux' in inst['pricing'][awsregion[region.encode('utf-8')]].keys():
                        instance['pricing'][region.encode('utf-8')]['linux'] = inst['pricing'][awsregion[region.encode('utf-8')]]['linux']['ondemand']
                    if 'mswin' in inst['pricing'][awsregion[region.encode('utf-8')]].keys():
                        instance['pricing'][region.encode('utf-8')]['windows'] = inst['pricing'][awsregion[region.encode('utf-8')]]['mswin']['ondemand']
                    if 'mswinSQLWeb' in inst['pricing'][awsregion[region.encode('utf-8')]].keys():
                        instance['pricing'][region.encode('utf-8')]['sql-web'] = inst['pricing'][awsregion[region.encode('utf-8')]]['mswinSQLWeb']['ondemand']
                    if 'mswinSQL' in inst['pricing'][awsregion[region.encode('utf-8')]].keys():
                        instance['pricing'][region.encode('utf-8')]['sql-standard'] = inst['pricing'][awsregion[region.encode('utf-8')]]['mswinSQL']['ondemand']
        instances.append(instance)

    print ("Saving instances...")
    with open(mixeddatafile, 'w') as f:
        json.dump(instances,
                    f,
                    indent=2,
                    sort_keys=True,
                    separators=(',', ': '))

if __name__ == '__main__':
    mixaws('data/azurevirtualmachines.json','data/awsinstances.json', 'data/azureawsmixed.json')