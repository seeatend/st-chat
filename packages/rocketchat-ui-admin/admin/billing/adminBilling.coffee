Template.adminBilling.onRendered ->
	Tracker.afterFlush ->
		SideNav.setFlex "adminFlex"
		SideNav.openFlex()

Template.adminBilling.helpers
	needUpgrade: ->
		if RocketChat.settings.get('Payment_Enabled')
			org = Organizations.findOne()
			if org.hasActiveSubscription
				return true
	org: ->
		if RocketChat.settings.get('Payment_Enabled')
			return Organizations.findOne()

Template.adminBilling.events
	'click': () ->
		# ...