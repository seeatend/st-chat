Meteor.startup ->
	return unless Meteor.isCordova

	# Handle click events for all external URLs
	$(document).on 'deviceready', ->
		platform = device.platform.toLowerCase()
		$(document).on 'click', (e) ->
			$link = $(e.target).closest('a[href]')
			return unless $link.length > 0
			url = $link.attr('href')

			if /^https?:\/\/.+/.test(url) is true
				switch platform
					when 'ios'
						window.open url, '_system'
					when 'android'
						navigator.app.loadUrl url, {openExternal: true}
				e.preventDefault()

		branch.init 'key_live_igjRZqAiTNpvzguR2oliZogossiLvUz4', ( err, data ) ->
			if not err and data.data
				parsed_data = JSON.parse(data.data);
				if parsed_data['+clicked_branch_link']
					FlowRouter.go('home')
        # data are the deep linked params associated with the link that the user clicked -> was re-directed to this app
        # data will be empty if no data found
        # ... insert custom routing logic here ...
			else
      	FlowRouter.go('home')