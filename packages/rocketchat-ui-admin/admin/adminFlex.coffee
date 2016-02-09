Template.adminFlex.helpers
	isGlobalAdmin: ->
		return Meteor.user().emails[0].address.split('@')[1] is 'teamstitch.com'
	groups: ->
		return Settings.find({type: 'group'}, { sort: { sort: 1, i18nLabel: 1 } }).fetch()
	label: ->
		return TAPi18n.__(@i18nLabel or @_id)
	adminBoxOptions: ->
		return RocketChat.AdminBox.getOptions()
	paymentEnabled: ->
		return RocketChat.settings.get('Payment_Enabled')
		
Template.adminFlex.events
	'mouseenter header': ->
		SideNav.overArrow()

	'mouseleave header': ->
		SideNav.leaveArrow()

	'click header': ->
		SideNav.closeFlex()

	'click .cancel-settings': ->
		SideNav.closeFlex()

	'click .admin-link': ->
		menu.close()
