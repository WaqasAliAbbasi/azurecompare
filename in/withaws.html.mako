<%!
  active_ = "withaws"
  import json
%>
<%inherit file="base.mako" />

    <%block name="header">
    <h1>VMCompare.azurewebsites.net <small>Easy Azure Virtual Machines Comparison</small></h1>
    </%block>

    <div class="row" id="menu">
      <div class="col-sm-12">
        <div class="btn-group" id='region-dropdown'>
          <a class="btn dropdown-toggle btn-primary" data-toggle="dropdown" href="#">
            <i class="icon-globe icon-white"></i>
            Region: <span class="text"></span>
            <span class="caret"></span>
          </a>
          <ul class="dropdown-menu" role="menu">
			<li class="available"><a href="javascript:;" data-region='AP Southeast'>Southeast Asia | Asia-Pacific (Singapore)</a></li>
			<li class="disabled"><a href="javascript:;" data-region='AP East'>East Asia</a></li>
			<li class="available"><a href="javascript:;" data-region='AU East'>Australia East | Asia-Pacific (Sydney)</a></li>
			<li class="disabled"><a href="javascript:;" data-region='AU Southeast'>Australia Southeast</a></li>
			<li class="available"><a href="javascript:;" data-region='BR South'>Brazil South | South America (S&atilde;o Paulo)</a></li>
			<li class="available"><a href="javascript:;" data-region='CA Central'>Canada Central | Canada (Central)</a></li>
			<li class="disabled"><a href="javascript:;" data-region='CA East'>Canada East</a></li>
			<li class="available"><a href="javascript:;" data-region='EU North'>North Europe | EU (Frankfurt)</a></li>
			<li class="available"><a href="javascript:;" data-region='EU West'>West Europe | EU (Ireland)</a></li>
			<li class="disabled"><a href="javascript:;" data-region='IN Central'>Central India</a></li>
			<li class="disabled"><a href="javascript:;" data-region='IN South'>South India</a></li>
			<li class="disabled"><a href="javascript:;" data-region='IN West'>West India</a></li>
			<li class="disabled"><a href="javascript:;" data-region='JA East'>Japan East</a></li>
			<li class="available"><a href="javascript:;" data-region='JA West'>Japan West | Asia-Pacific (Tokyo)</a></li>
			<li class="available"><a href="javascript:;" data-region='KR Central'>Korea Central | Asia-Pacific (Seoul)</a></li>
			<li class="disabled"><a href="javascript:;" data-region='KR South'>Korea South</a></li>
			<li class="available"><a href="javascript:;" data-region='UK South'>UK South | EU (London)</a></li>
			<li class="disabled"><a href="javascript:;" data-region='UK West'>UK West</a></li>
			<li class="disabled"><a href="javascript:;" data-region='US Central'>Central US</a></li>
			<li class="available"><a href="javascript:;" data-region='US East'>East US | US East (N. Virginia)</a></li>
			<li class="available"><a href="javascript:;" data-region='US East 2'>East US 2 | US East (Ohio)</a></li>
			<li class="disabled"><a href="javascript:;" data-region='US North Central'>North Central US</a></li>
			<li class="disabled"><a href="javascript:;" data-region='US South Central'>South Central US</a></li>
			<li class="available"><a href="javascript:;" data-region='US West'>West US | US West (Northern California)</a></li>
			<li class="available"><a href="javascript:;" data-region='US West 2'>West US 2 | US West (Oregon)</a></li>
			<li class="disabled"><a href="javascript:;" data-region='US West Central'>West Central US</a></li>
			<li class="disabled"><a href="javascript:;" data-region='US Gov AZ'>US Gov Arizona</a></li>
			<li class="disabled"><a href="javascript:;" data-region='US Gov TX'>US Gov Texas</a></li>
			<li class="disabled"><a href="javascript:;" data-region='USGov'>US Gov</a></li>
          </ul>
        </div>

        <div class="btn-group" id="cost-dropdown">
          <a class="btn dropdown-toggle btn-primary" data-toggle="dropdown" href="#">
            <i class="icon-shopping-cart icon-white"></i>
            Cost: <span class="text"></span>
            <span class="caret"></span>
          </a>
          <ul class="dropdown-menu" role="menu">
            <li class="available"><a href="javascript:;" duration="hourly">Hourly</a></li>
            <li class="available"><a href="javascript:;" duration="daily">Daily</a></li>
            <li class="available"><a href="javascript:;" duration="weekly">Weekly</a></li>
            <li class="available"><a href="javascript:;" duration="monthly">Monthly</a></li>
            <li class="available"><a href="javascript:;" duration="annually">Annually</a></li>
          </ul>
        </div>

        <div class="btn-group" id="filter-dropdown">
          <a class="btn dropdown-toggle btn-primary" data-toggle="dropdown" href="#">
            <i class="icon-filter icon-white"></i>
            Columns
            <span class="caret"></span>
          </a>
          <ul class="dropdown-menu" role="menu">
            <!-- table header elements inserted by js -->
          </ul>
        </div>

        <button class="btn btn-primary btn-compare"
          data-text-on="End Compare"
          data-text-off="Compare Selected">
          Compare Selected
        </button>

        <button class="btn btn-primary btn-clear">
          Clear Filters
        </button>
      </div>
    </div>

    <div class="form-inline" id="filters">
      <strong> Filter:</strong>
      Min Cores: <input data-action="datafilter" data-type="cores" class="form-control" placeholder="0"/>
	  Min Memory (GiB): <input data-action="datafilter" data-type="memory" class="form-control" placeholder="0"/>
      Min Storage (GB): <input data-action="datafilter" data-type="storage" class="form-control" placeholder="0"/>
    </div>

    <table cellspacing="0" class="table table-bordered table-hover table-condensed" id="data">
	<thead>
		<tr>
			<th class="name">Name</th>
			<th class="quantity">Quantity</th>
			<th class="cores">Cores</th>
			<th class="memory">Memory (GiB)</th>
			<th class="storage"><abbr title="Storage values for disk sizes use a legacy &quot;GB&quot; label. They are actually calculated in gibibytes, and all values should be read as &quot;X GiB&quot;">Storage (GB)</abbr></th>
			<th class="gpus">GPUs</th>
			<th class="cost linux">Linux</th>
			<th class="cost windows">Windows</th>
			<th class="cost sql-web">SQL Server Web</th>
			<th class="cost sql-standard">SQL Server Standard</th>
		</tr>
	</thead>
	<tfoot>
            <tr id="totalazure">
			<th class="name"><span><img src="../favicon.ico" style="height:40%"></span> Total (0 Selected)</th></th>
			<th class="quantity"></th>
			<th class="cores"></th>
			<th class="memory"></th>
			<th class="storage"></th>
			<th class="gpus"></th>
			% for platform in ['linux', 'windows','sql-web','sql-standard']:
			<th class="total-cost ${platform}"><span total="0">$0.000 hourly</span></th>
			% endfor
		</tr>
		<tr id="totalaws" class="aws">
			<th class="name"><span><img src="../aws.ico" style="height:50%"></span> Total (0 Selected)</th>
			<th class="quantity"></th>
			<th class="cores"></th>
			<th class="memory"></th>
			<th class="storage"></th>
			<th class="gpus"></th>
			% for platform in ['linux', 'windows','sql-web','sql-standard']:
			<th class="total-cost ${platform}"><span total="0">$0.000 hourly</span></th>
			% endfor
		</tr>
        </tfoot>
	<tbody>
		% for inst in instances:
		% if '(AWS)' in inst['name']:
			<tr class='instance aws' id="${inst['name'].lower().replace(" ", "_")}">
		% else:
				<tr class='instance azure' id="${inst['name'].lower().replace(" ", "_")}">
		% endif
			% if '(AWS)' in inst['name']:
			<td class="name"><span><img src="../aws.ico" style="height:50%"></span> ${inst['name'].replace("(AWS) ","")}</td>
		% else:
				<td class="name">${inst['name']}</td>
		% endif
			<td class="quantity"><input type="number" class="form-control input-sm" id="quantity" name="quantity" value="1" placeholder="0"></td>
			<td class="cores"><span sort="${inst['cores']}">${inst['cores']}</span></td>
			<td class="memory"><span sort="${inst['memory']}">${inst['memory']}</span></td>
			% if inst['storage'] == "EBS Only":
				<td class="storage"><span sort="999999"><abbr title="Amazon Elastic Block Store (EBS) provides raw block-level storage that can be attached to Amazon EC2 instances.">EBS Only</abbr></span></td>
			% else:
				<td class="storage"><span sort="${inst['storage']}">${inst['storage']}</span></td>
			% endif
			<td class="gpus">${inst['GPU']}</td>
			% for platform in ['linux', 'windows','sql-web','sql-standard']:
			## note that the contents in these cost cells are overwritten by the JS change_cost() func, but the initial
			## data here is used for sorting (and anyone with JS disabled...)
			## for more info, see https://github.com/powdahound/ec2instances.info/issues/140
			<td class="cost ${platform}" data-pricing='${json.dumps({r:p.get(platform, p.get(' os',{})) for r,p in inst['pricing'].iteritems()}) | h}'>
				% if inst['pricing'].get('AP Southeast', {}).get(platform) != "N/A":
				<span sort="${inst['pricing']['AP Southeast'][platform]}">
					$${inst['pricing']['AP Southeast'][platform]} hourly
				</span>
				% else:
				<span sort="99999999">unavailable</span>
				% endif
			</td>
			% endfor
		</tr>
		% endfor
	</tbody>
</table>

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