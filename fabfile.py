import SimpleHTTPServer
import SocketServer
import os
import traceback

from fabric.api import abort, task
from fabric.contrib.console import confirm

from render import render
from updateprices import updateprices
from scrape import scrape
from mixwithaws import mixaws

abspath = lambda filename: os.path.join(os.path.abspath(os.path.dirname(__file__)),
                                        filename)

@task
def build():
    updateprices('data/azurevirtualmachinesSpec.csv','data/azurevirtualmachines.json')
    scrape_ec2()
    mixaws('data/azurevirtualmachines.json','data/awsinstances.json', 'data/azureawsmixed.json')
    render_html()

@task
def scrape_ec2():
    ec2_file = 'AWSinstances.json'
    try:
        scrape(ec2_file)
    except Exception as e:
        print "ERROR: Unable to scrape data: %s" % e
        print traceback.print_exc()

@task
def serve(ipaddr='127.0.0.1', port=8080):
    """Serve site contents locally for development"""
    port = int(port)
    os.chdir("www/")
    httpd = SocketServer.TCPServer((ipaddr, port), SimpleHTTPServer.SimpleHTTPRequestHandler)
    print "Serving on http://{}:{}".format(httpd.socket.getsockname()[0], httpd.socket.getsockname()[1])
    httpd.serve_forever()


@task
def render_html():
    """Render HTML but do not update data from Amazon"""
    render('data/azurevirtualmachines.json', 'in/index.html.mako', 'www/index.html')
    render('data/azureawsmixed.json', 'in/withaws.html.mako', 'www/withaws/index.html')

@task(default=True)
def update():
    """Build and deploy the site"""
    build()
    serve()
    #deploy()
