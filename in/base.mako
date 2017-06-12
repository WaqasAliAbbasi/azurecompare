<!DOCTYPE html>

<html lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>Azure - VM Compare</title>
    <link rel="stylesheet" href="/default.css" media="screen">
    <link rel="stylesheet" href="/bootstrap/css/bootstrap.min.css" media="screen">
	<link rel="stylesheet" href="https://cdn.datatables.net/select/1.2.2/css/select.dataTables.min.css" media="screen">
    <link rel="icon" type="image/png" href="/favicon.ico">
  </head>

  <body class="azurevirtualmachines">
    <div class="page-header">

      <span class="pull-right">
	  <a href="mailto:a-waali@microsoft.com" target="_blank" class="btn btn-primary">Feedback</a>
        <!--<a href="https://twitter.com/share" class="twitter-share-button" data-via="WaqasAliAbbasi"></a>-->
        <!--<iframe src="https://ghbtns.com/github-btn.html?user=powdahound&repo=ec2instances.info&type=star&count=true" frameborder="0" scrolling="0" width="100px" height="20px"></iframe>-->
      </span>

      <%block name="header"/>

      <p class="pull-right label label-info">Last Update: ${generated_at}</p>
      <ul class="nav nav-tabs">
        <li role="presentation" class="${'active' if self.attr.active_ == 'azurevms' else ''}"><a href="/">Azure Virtual Machines</a></li>
        <li role="presentation" class="${'active' if self.attr.active_ == 'withaws' else ''}"><a href="/withaws/">Azure/AWS</a></li>
      </ul>
    </div>

    <div class="clear-fix"></div>

    ${self.body()}

    <div class="well">
      <p>
        <strong>Why?</strong>
        Because it's time-consuming to compare virtual machines using Azure's own <a href="https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/" target="_blank">pricing</a>, <a href="https://azure.microsoft.com/en-us/pricing/calculator/" target="_blank">pricing calculator</a>, and other pages.
      </p>
      <p>
        <strong>Who?</strong>
        It was started for AWS by <a href="http://twitter.com/powdahound" target="_blank">@powdahound</a> and contributed to by <a href="https://github.com/powdahound/ec2instances.info/contributors" target="_blank">many</a> at <a href="https://github.com/powdahound/ec2instances.info" target="_blank">GitHub</a>. <a href="https://github.com/WaqasAliAbbasi" target="_blank">WaqasAliAbbasi</a> ported and improved it for Azure under the supervision of Patrick Lam and Brian Law at Microsoft Hong Kong.
      </p>
      <p>
        <strong>How?</strong>
        Azure Virtual Machine specifications are semi-automatically updated while the prices are regularly refreshed through <a href="https://docs.microsoft.com/en-us/azure/billing/billing-usage-rate-card-overview" target="_blank">Azure RateCard API</a>. This was last done at ${generated_at}.
      </p>

      <p class="bg-warning">
        <strong>Warning:</strong> This site is not maintained by or affiliated with Microsoft. The data shown is not guaranteed to be accurate or current. Please <a href="mailto:a-waali@microsoft.com">report issues</a> you see.
      </p>

    </div>

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js" type="text/javascript" charset="utf-8"></script>
    <script src="/bootstrap/js/bootstrap.min.js" type="text/javascript" charset="utf-8"></script>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.13/js/jquery.dataTables.min.js"></script>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.2.4/js/dataTables.buttons.min.js"></script>
	<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/select/1.2.2/js/dataTables.select.min.js"></script>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.2.4/js/buttons.flash.min.js"></script>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.2.4/js/buttons.html5.min.js"></script>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.2.4/js/buttons.print.min.js"></script>
    <script src="/store/store.js" type="text/javascript" charset="utf-8"></script>
    <script src="/default.js" type="text/javascript" charset="utf-8"></script>

	<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-46712607-6', 'auto');
  ga('send', 'pageview');

</script>

    <!--<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>-->
  </body>
</html>
