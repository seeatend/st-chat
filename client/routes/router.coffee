Blaze.registerHelper 'pathFor', (path, kw) ->
	return FlowRouter.path path, kw.hash

BlazeLayout.setRoot 'body'

FlowRouter.subscriptions = ->
	Tracker.autorun =>
		RoomManager.init()
		@register 'room', Meteor.subscribe('room')
		@register 'userData', Meteor.subscribe('userData')
		@register 'usersData', Meteor.subscribe('usersData')
		@register 'activeUsers', Meteor.subscribe('activeUsers')
		@register 'admin-settings', Meteor.subscribe('admin-settings')
		@register 'organization', Meteor.subscribe('organization')

FlowRouter.route '/',
	name: 'index'
	action: ->
		BlazeLayout.render 'main', {center: 'loading'}
		analytics.page()
		if not Meteor.userId()
			return FlowRouter.go 'home'

		Tracker.autorun (c) ->
			if FlowRouter.subsReady() is true
				Meteor.defer ->
					if Meteor.user().defaultRoom?
						room = Meteor.user().defaultRoom.split('/')
						FlowRouter.go room[0], {name: room[1]}
					else
						FlowRouter.go 'home'
				c.stop()

FlowRouter.route '/login',
	name: 'login'
	action: ->
		FlowRouter.go 'home'
		analytics.page()

FlowRouter.route '/reset/:uuid',
	name: 'resetPassword'
	action: ->
		BlazeLayout.render 'main', {center: 'home'}
		analytics.page()

FlowRouter.route '/register/:orgId?',
	name: 'register'
	action: ->
		BlazeLayout.render 'main', {center: 'home'}
		analytics.page()

FlowRouter.route '/verify/:uuid',
	name: 'verify'
	action: (params) ->
		Meteor.call 'verifyUser', params.uuid, ->
			Accounts.callLoginMethod
				methodArguments: [ { uuid: params.uuid } ]
				userCallback: ->
					Meteor.call 'joinDefaultChannels', ->
						FlowRouter.go '/home'
					return
			return

FlowRouter.route '/home',
	name: 'home'
	action: ->
		RocketChat.TabBar.reset()
		BlazeLayout.render 'main', {center: 'home'}
		KonchatNotification.getDesktopPermission()
		analytics.page()

FlowRouter.route '/preferences',
	name: 'account-preferences'
	action: ->
		BlazeLayout.render 'main', {center: 'accountPreferences'}
		analytics.page()

FlowRouter.route '/history/private',
	name: 'privateHistory'
	subscriptions: (params, queryParams) ->
		@register 'privateHistory', Meteor.subscribe('privateHistory')
	action: ->
		Session.setDefault('historyFilter', '')
		BlazeLayout.render 'main', {center: 'privateHistory'}
		analytics.page()

FlowRouter.route '/terms-of-service',
	name: 'terms-of-service'
	action: ->
		Session.set 'cmsPage', 'Layout_Terms_of_Service'
		BlazeLayout.render 'cmsPage'
		analytics.page()

FlowRouter.route '/privacy-policy',
	name: 'privacy-policy'
	action: ->
		Session.set 'cmsPage', 'Layout_Privacy_Policy'
		BlazeLayout.render 'cmsPage'
		analytics.page()

FlowRouter.route '/room-not-found/:type/:name',
	name: 'room-not-found'
	action: (params) ->
		Session.set 'roomNotFound', {type: params.type, name: params.name}
		BlazeLayout.render 'main', {center: 'roomNotFound'}
		analytics.page()

FlowRouter.route '/fxos',
	name: 'firefox-os-install'
	action: ->
		BlazeLayout.render 'fxOsInstallPrompt'
		analytics.page()

FlowRouter.route '/subscribe',
	name: 'subscribe'
	subscriptions: (params, queryParams) ->
		@register 'paymentSubscriptions', Meteor.subscribe('paymentSubscriptions')
		@register 'paymentHistory', Meteor.subscribe('paymentHistory')
	action: (params) ->
		BlazeLayout.render 'main', {center: 'subscribe'}
		analytics.page()
