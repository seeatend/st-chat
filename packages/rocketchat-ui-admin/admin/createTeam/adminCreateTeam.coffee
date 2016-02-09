Template.adminCreateTeam.helpers
	isReady: ->
		return Template.instance().ready?.get()
	flexOpened: ->
		return 'opened' if RocketChat.TabBar.isFlexOpen()
	flexTemplate: ->
		return RocketChat.TabBar.getTemplate()

	flexData: ->
		return RocketChat.TabBar.getData()

	adminClass: ->
		return 'admin' if RocketChat.authz.hasRole(Meteor.userId(), 'admin')

Template.adminCreateTeam.onRendered ->
	Tracker.afterFlush ->
		SideNav.setFlex "adminFlex"
		SideNav.openFlex()

Template.adminCreateTeam.events
	'click .create-team': ->

		data = {};
		data.orgName = $('#org-name').val()
		data.adminEmail = $('#admin-email').val()
		Meteor.call 'createTeam', data, (err, result) ->
			if err
				toastr.error err.error
				return
			$('#org-name').val('')
			$('#admin-email').val('')
			toastr.success 'Team created and invitation sent successfully'
