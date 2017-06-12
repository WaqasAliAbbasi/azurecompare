import mako.template
import mako.lookup
import mako.exceptions
import json
import datetime

def json_load_byteified(file_handle):
    return _byteify(
        json.load(file_handle, object_hook=_byteify),
        ignore_dicts=True
    )

def json_loads_byteified(json_text):
    return _byteify(
        json.loads(json_text, object_hook=_byteify),
        ignore_dicts=True
    )

def _byteify(data, ignore_dicts = False):
    # if this is a unicode string, return its string representation
    if isinstance(data, unicode):
        return data.encode('utf-8')
    # if this is a list of values, return list of byteified values
    if isinstance(data, list):
        return [ _byteify(item, ignore_dicts=True) for item in data ]
    # if this is a dictionary, return dictionary of byteified keys and values
    # but only if we haven't already byteified it
    if isinstance(data, dict) and not ignore_dicts:
        return {
            _byteify(key, ignore_dicts=True): _byteify(value, ignore_dicts=True)
            for key, value in data.iteritems()
        }
    # if it's anything else, return it in its original form
    return data

def render(data_file, template_file, destination_file):
    """Build the HTML content from scraped data"""
    lookup = mako.lookup.TemplateLookup(directories=['.'])
    template = mako.template.Template(filename=template_file, lookup=lookup)
    print "Loading data from %s..." % data_file
    with open(data_file) as f:
        instances = json_load_byteified(f)
    #for i in instances:
     #   add_render_info(i)
    print "Rendering to %s..." % destination_file
    generated_at = datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')
    with open(destination_file, 'w') as fh:
        try:
            fh.write(template.render(instances=instances, generated_at=generated_at))
        except:
            print mako.exceptions.text_error_template().render()

if __name__ == '__main__':
    render('data/azurevirtualmachines.json', 'in/index.html.mako', 'www/index.html')
