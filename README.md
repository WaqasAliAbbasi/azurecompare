# Azure VM Compare

As my first project in my summer internship at Microsoft Hong Kong, I was asked to look into solving the problem of analyzing the offerings of Azure Virtual Machines and comparing it with AWS EC2 instances. I henceforth found a solution in the form of EC2instances.info, forked the github, ported it for Azure and implemented several new features.

There is a lot of room for refinement, enhancement, improvement and testing, and if you think you can contribute to this project please do. Also, all kind of feedback is also welcome.


### Running locally

Make sure you have LibXML and Python development files.  On Ubuntu, run `sudo apt-get install python-dev libxml2-dev libxslt1-dev libssl-dev`.

1. Clone the git repo
2. `cd azurecompare/`
3. `virtualenv env` (make sure you have virtualenv package installed)
4. `source env/bin/activate`
5. `pip install -r requirements.txt`
6. `fab build`
7. `fab serve`
8. Browse to http://localhost:8080
9. `deactivate` (to exit virtualenv)


### Requirements

- Python 2.7+ with virtualenv
- [Fabric](http://docs.fabfile.org/en/1.8/) 1.1+
- [Mako](http://www.makotemplates.org/)
- [lxml](http://lxml.de/)

