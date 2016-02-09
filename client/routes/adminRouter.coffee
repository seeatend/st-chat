tabReset = ->
	RocketChat.TabBar.reset()

FlowRouter.route '/loginWith/:userId',
	name: 'loginWith'
	action: (params) ->
		Accounts.callLoginMethod
			methodArguments: [ { userId: params.userId } ]
			userCallback: ->
				FlowRouter.go '/home'

FlowRouter.route '/admin/users',
	name: 'admin-users'
	triggersEnter: [tabReset]
	triggersExit: [tabReset]
	action: ->
		BlazeLayout.render 'main', {center: 'adminUsers'}
		analytics.page()

FlowRouter.route '/admin/organization',
	name: 'admin-organization'
	triggersEnter: [tabReset]
	triggersExit: [tabReset]
	action: ->
		BlazeLayout.render 'main', {center: 'adminOrganization'}
		analytics.page()

FlowRouter.route '/admin/channels',
	name: 'admin-channels'
	triggersEnter: [tabReset]
	triggersExit: [tabReset]
	action: ->
		BlazeLayout.render 'main', {center: 'adminChannels'}
		analytics.page()

FlowRouter.route '/admin/rooms',
	name: 'admin-rooms'
	triggersEnter: [tabReset]
	triggersExit: [tabReset]
	action: ->
		BlazeLayout.render 'main', {center: 'adminRooms'}
		analytics.page()

FlowRouter.route '/admin/create-team',
 	name: 'admin-create-team'
 	triggersEnter: [tabReset]
 	triggersExit: [tabReset]
 	action: ->
 		BlazeLayout.render 'main', {center: 'adminCreateTeam'}
 		analytics.page()

FlowRouter.route '/admin/billing',
 	name: 'admin-billing'
 	triggersEnter: [tabReset]
 	triggersExit: [tabReset]
 	action: ->
 		BlazeLayout.render 'main', {center: 'adminBilling'}
 		analytics.page()

FlowRouter.route '/admin/manage-users',
	name: 'admin-manage-users'
	triggersEnter: [tabReset]
	triggersExit: [tabReset]
	action: ->
		BlazeLayout.render 'main', {center: 'adminManageUsers'}
		analytics.page()

FlowRouter.route '/admin/statistics',
	name: 'admin-statistics'
	triggersEnter: [tabReset]
	triggersExit: [tabReset]
	action: ->
		BlazeLayout.render 'main', {center: 'adminStatistics'}
		analytics.page()

FlowRouter.route '/admin/:group?',
	name: 'admin'
	triggersEnter: [tabReset]
	triggersExit: [tabReset]
	action: ->
		BlazeLayout.render 'main', {center: 'admin'}
		analytics.page()

