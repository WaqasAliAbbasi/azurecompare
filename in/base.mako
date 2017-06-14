<!DOCTYPE html>

<html lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>Azure - VM Compare</title>
    <link rel="stylesheet" href="/default.css" media="screen">
    <link rel="stylesheet" href="/bootstrap/css/bootstrap.min.css" media="screen">
	<link rel="stylesheet" href="https://cdn.datatables.net/select/1.2.2/css/select.dataTables.min.css" media="screen">
	<link rel="stylesheet" href="https://cdn.datatables.net/fixedheader/3.1.2/css/fixedHeader.dataTables.min.css" media="screen">
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

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js" type="text/javascript" charset="utf-8"></script>
    <script src="/bootstrap/js/bootstrap.min.js" type="text/javascript" charset="utf-8"></script>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.13/js/jquery.dataTables.min.js"></script>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.2.4/js/dataTables.buttons.min.js"></script>
	<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/select/1.2.2/js/dataTables.select.min.js"></script>
	<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/fixedheader/3.1.2/js/dataTables.fixedHeader.min.js"></script>
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
