(function () {
	if(window.location.href.indexOf('DynamicPage?') > 0 || window.IsEDQDynamicPage === true) { return; }
	
	var edqDomain = getEDQDomain();
	if(edqDomain == null) { return; }
	
	var context = {
		cssUrl : edqDomain + '/SalesforceV5RapidSearch/Scripts/v1/edqPopup.css', 
		allEDQForSalesforceUrl : edqDomain + '/SalesforceV5RapidSearch/Scripts/v1/allEDQForSalesforce.js', 
		originDomain: edqDomain,
		onComplete: function () { if(window.edqAddressClient != null && window.edqAddressClient != undefined) { window.edqAddressClient.attachFixValidationStatusOnBeforeSave();}}
	};
		
	function initialize() {
		initialize = function () {};	
	
		var sys = EDQ.system;
	
		try {
			eval(decodeURIComponent(EDQ.jQuery('a').filter(function(index) { return EDQ.jQuery(this).text() === "Global Data Quality"; }).attr('href').replace('javascript:', '')));
		} catch(err) {
			sys.logError(err);
			return;
		}
		
		var ts = "2015052011000";
		try { ts = new Date().toISOString().replace(/[\s-:\.TZ]/gi, '').substring(0, 10) + "000"; } catch(err) { sys.logError(err); }
		
		var loadScriptOrCallInit = function() {
			
			var sfdc = EDQ.DataQuality.Salesforce;

			try {
				var loadScriptUrl = null;
				if(sys.isNullOrEmpty(window.edqSessionToken) && !sys.isNullOrEmpty(window.EDQSessionTokenUrl)) {
					loadScriptUrl = window.EDQSessionTokenUrl;
				} else if(sys.isNullOrEmpty(window.edqSObjectConfigurations) && !sys.isNullOrEmpty(window.EDQConfigurationsUrl)) {
					loadScriptUrl = window.EDQConfigurationsUrl;
				} else if(sys.isNullOrEmpty(window.edqGlobalSettings) && !sys.isNullOrEmpty(window.EDQGlobalSettingsUrl)) {
					loadScriptUrl = window.EDQGlobalSettingsUrl;
				}		
				
				if(!sys.isNullOrEmpty(loadScriptUrl)) {
					if(loadScriptUrl.indexOf('resource/EDQ') > 0) {
						var newLoadScriptUrl = loadScriptUrl.substring(0, loadScriptUrl.indexOf('resource/') + 'resource/'.length);
						newLoadScriptUrl += ts + "/";
						newLoadScriptUrl += loadScriptUrl.substring(loadScriptUrl.indexOf('resource/') + 'resource/'.length);
						loadScriptUrl = newLoadScriptUrl;
					}	
					loadScriptUrl += "?ensureNoCache=" + sys.generateGuid();
					sys.loadScript(document, loadScriptUrl, function() {
						loadScriptOrCallInit();
					});
				} else {
					context.salesforceDomain = sys.getServerDomain();
					sfdc.initialize(context);
				}
			} catch (err) {
				sys.logError(err);
			}
		};
		
		loadScriptOrCallInit();
	}

	var newScript =  document.createElement("script");
	newScript.src = context.allEDQForSalesforceUrl;
	newScript.onreadystatechange = function () { 
		if (newScript.readyState == 'complete' || newScript.readyState == 'loaded') {
			newScript.onreadystatechange = null;
			initialize();
		};
	};
	newScript.onload = function() {	initialize(); };

	var script = document.getElementsByTagName('script')[0];
	if(script == null || script == undefined || script.parentNode == null || script.parentNode == undefined) {
		var scripts = document.getElementsByTagName('script');
		for (var i = 0, len = scripts.len; i < len; i++) {
			script = scripts[i];
			if (script != null && script != undefined && script.parentNode != null && script.parentNode != undefined) {
				break;
			};
		};
	};
	if (script != null && script != undefined && script.parentNode != null && script.parentNode != undefined) {
		script.parentNode.insertBefore(newScript, script);
	};
	
	function getEDQDomain() {
		if(window.EDQDomainUrl != undefined && window.EDQDomainUrl != null) {
			return window.EDQDomainUrl;
		}
		return 'https://sfv5.online.qas.com';
	};
})();