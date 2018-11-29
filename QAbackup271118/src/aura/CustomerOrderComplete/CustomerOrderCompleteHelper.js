({
	/**
	 * Navigates to a specific URL. This is functionally similar to window.open()
	 *
	 * @param component  the component that initiated the navigation
	 * @param url        the URL to navigate to
	 * @param name       the target attribute or name of the window
	 * @param specs      a comma-separated list of items, no whitespaces
	 * @param replace    specifies whether the URL creates a new entry or replaces the current entry
	 *                   in the history list
	 */
	navigateToURL: function(component, url, name, specs, replace) {

		if ((typeof url === 'undefined') || (url === null)) {
			url = '';
		} else {
			url = String(url);
			url = url.replace(new RegExp('^\\s+|\\s+$', 'g'), '');
		}

		var navigateEvent = $A.get('e.force:navigateToURL');
		if (navigateEvent) {
			navigateEvent.setParams({
				url: url,
				isredirect: replace
			});
			navigateEvent.fire();
		} else {
			if (window.sforce && window.sforce.one) {
				window.sforce.one.navigateToURL(url, replace);
			} else {
				window.open(url, name || '_top', specs, replace);
			}
		}
	},  
})