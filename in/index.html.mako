<%!
  active_ = "azurevms"
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
			<li class="available"><a href="javascript:;" data-region='AP Southeast'>Southeast Asia</a></li>
			<li class="available"><a href="javascript:;" data-region='AP East'>East Asia</a></li>
			<li class="available"><a href="javascript:;" data-region='AU East'>Australia East</a></li>
			<li class="available"><a href="javascript:;" data-region='AU Southeast'>Australia Southeast</a></li>
			<li class="available"><a href="javascript:;" data-region='BR South'>Brazil South</a></li>
			<li class="available"><a href="javascript:;" data-region='CA Central'>Canada Central</a></li>
			<li class="available"><a href="javascript:;" data-region='CA East'>Canada East</a></li>
			<li class="available"><a href="javascript:;" data-region='EU North'>North Europe</a></li>
			<li class="available"><a href="javascript:;" data-region='EU West'>West Europe</a></li>
			<li class="available"><a href="javascript:;" data-region='IN Central'>Central India</a></li>
			<li class="available"><a href="javascript:;" data-region='IN South'>South India</a></li>
			<li class="available"><a href="javascript:;" data-region='IN West'>West India</a></li>
			<li class="available"><a href="javascript:;" data-region='JA East'>Japan East</a></li>
			<li class="available"><a href="javascript:;" data-region='JA West'>Japan West</a></li>
			<li class="available"><a href="javascript:;" data-region='KR Central'>Korea Central</a></li>
			<li class="available"><a href="javascript:;" data-region='KR South'>Korea South</a></li>
			<li class="available"><a href="javascript:;" data-region='UK South'>UK South</a></li>
			<li class="available"><a href="javascript:;" data-region='UK West'>UK West</a></li>
			<li class="available"><a href="javascript:;" data-region='US Central'>Central US</a></li>
			<li class="available"><a href="javascript:;" data-region='US East'>East US</a></li>
			<li class="available"><a href="javascript:;" data-region='US East 2'>East US 2</a></li>
			<li class="available"><a href="javascript:;" data-region='US North Central'>North Central US</a></li>
			<li class="available"><a href="javascript:;" data-region='US South Central'>South Central US</a></li>
			<li class="available"><a href="javascript:;" data-region='US West'>West US</a></li>
			<li class="available"><a href="javascript:;" data-region='US West 2'>West US 2</a></li>
			<li class="available"><a href="javascript:;" data-region='US West Central'>West Central US</a></li>
			<li class="available"><a href="javascript:;" data-region='US Gov AZ'>US Gov Arizona</a></li>
			<li class="available"><a href="javascript:;" data-region='US Gov TX'>US Gov Texas</a></li>
			<li class="available"><a href="javascript:;" data-region='USGov'>US Gov</a></li>
          </ul>
        </div>

        <div class="btn-group" id="cost-dropdown">
          <a class="btn dropdown-toggle btn-primary" data-toggle="dropdown" href="#">
            <i class="icon-shopping-cart icon-white"></i>
            Cost: <span class="text"></span>
            <span class="caret"></span>
          </a>
          <ul class="dropdown-menu" role="menu">
            <li><a href="javascript:;" duration="hourly">Hourly</a></li>
            <li><a href="javascript:;" duration="daily">Daily</a></li>
            <li><a href="javascript:;" duration="weekly">Weekly</a></li>
            <li><a href="javascript:;" duration="monthly">Monthly</a></li>
            <li><a href="javascript:;" duration="annually">Annually</a></li>
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
			<th class="cost linux">Linux (hourly)</th>
			<!--<th class="cost linux-low-priority">Linux (Low Priority)</th>-->
			<th class="cost windows">Windows (hourly)</th>
			<!--<th class="cost windows-low-priority">Windows (Low Priority)</th>-->
			<th class="cost sql-web">SQL Server Web (hourly)</th>
			<th class="cost sql-standard">SQL Server Standard (hourly)</th>
			<th class="cost sql-enterprise">SQL Server Enterprise (hourly)</th>
			<th class="cost msft-r-server-linux">MSFT R Server for Linux (hourly)</th>
			<th class="cost biztalk-standard">BizTalk Server Standard (hourly)</th>
			<th class="cost biztalk-enterprise">BizTalk Server Enterprise (hourly)</th>
			<th class="cost oracle-java">Java Development Environment (hourly)</th>
			<th class="cost redhat-enterprise-linux">Red Hat Enterprise Linux (hourly)</th>
		</tr>
	</thead>
	<tfoot>
            <tr id="total">
			<th class="name"><span><img src="../favicon.ico" style="height:40%"></span> Total (0 Selected)</th></th>
			<th class="quantity"></th>
			<th class="cores"></th>
			<th class="memory"></th>
			<th class="storage"></th>
			<th class="gpus"></th>
			% for platform in ['linux', 'windows','sql-web','sql-standard','sql-enterprise','msft-r-server-linux','biztalk-standard','biztalk-enterprise','oracle-java','redhat-enterprise-linux']:
			<th class="total-cost ${platform}"><span total="0">$0.000</span></th>
			% endfor
		</tr>
        </tfoot>
	<tbody>
		% for inst in instances:
		<tr class='instance' id="${inst['name'].lower().replace(" ", "_")}">
			<td class="name">${inst['name']}</td>
			<td class="quantity"><input type="number" class="form-control input-sm" id="quantity" name="quantity" value="1" placeholder="0"></td>
			<td class="cores"><span sort="${inst['cores']}">${inst['cores']}</span></td>
			<td class="memory"><span sort="${inst['memory']}">${inst['memory']}</span></td>
			<td class="storage"><span sort="${inst['storage']}">${inst['storage']}</span></td>
			<td class="gpus">${inst['GPU']}</td>
			% for platform in ['linux', 'windows','sql-web','sql-standard','sql-enterprise','msft-r-server-linux','biztalk-standard','biztalk-enterprise','oracle-java','redhat-enterprise-linux']:
			## note that the contents in these cost cells are overwritten by the JS change_cost() func, but the initial
			## data here is used for sorting (and anyone with JS disabled...)
			## for more info, see https://github.com/powdahound/ec2instances.info/issues/140
			<td class="cost ${platform}" data-pricing='${json.dumps({r:p.get(platform, p.get(' os',{})) for r,p in inst['pricing'].iteritems()}) | h}'>
				% if inst['pricing'].get('AP Southeast', {}).get(platform) != "N/A":
				<span sort="${inst['pricing']['AP Southeast'][platform]}">
					$${inst['pricing']['AP Southeast'][platform]}
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
