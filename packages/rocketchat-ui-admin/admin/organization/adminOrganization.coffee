Template.adminOrganization.helpers
	isReady: ->
		return Template.instance().ready?.get()
	domains: ->
		if Session.get('Organization') and Session.get('Organization').domains?.length > 0
			return Session.get('Organization').domains
		else
			return null
	orgName: ->
		if Session.get('Organization')
			return Session.get('Organization').name
		else
			return null
	flexOpened: ->
		return 'opened' if RocketChat.TabBar.isFlexOpen()
	flexTemplate: ->
		return RocketChat.TabBar.getTemplate()

	flexData: ->
		return RocketChat.TabBar.getData()

	adminClass: ->
		return 'admin' if RocketChat.authz.hasRole(Meteor.userId(), 'admin')

Template.adminOrganization.onCreated ->
	Meteor.call 'findOrgById', Meteor.user().organizationId, (err, result) ->
		Session.set('Organization', result);

Template.adminOrganization.onRendered ->
	Tracker.afterFlush ->
		SideNav.setFlex "adminFlex"
		SideNav.openFlex()

Template.adminOrganization.events
	'click .edit-org-name': ->
		Meteor.call 'editOrgName', Meteor.user().organizationId, $('#org-name').val(), (err, result) ->
			if err
				toastr.error err.error
				return

			Session.set('Organization', result);
			toastr.success 'Saved'

	'click .add-domain': ->
		domain = $('#new-domain').val()
		if (!/(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:com|org|edu|sg|net|gov|mil|biz|info|io|mobi|name|aero|jobs|museum)\b/i.test(domain))
			toastr.error 'Invalid domain format'
			return
		Meteor.call 'addDomainToOrg', Meteor.user().organizationId, domain, (err, result) ->
			if err
				toastr.error err.error
				return

			Session.set('Organization', result);
			$('#new-domain').val('')

	'click .request-domain': ->
		data = {};
		data.requesterSiteUrl = $('#requester-site-url').val()
		data.requesterSiteName = $('#requester-site-name').val()
		data.requesterDomain = $('#requester-domain').val()
		Meteor.call 'requestDomain', data, (err, result) ->
			if err
				toastr.error err.error
				return
			$('#requester-site-url').val('')
			$('#requester-site-name').val('')
			$('#requester-domain').val('')
			toastr.success 'Request sent successfully'

Template.domain.events
	'click .remove-domain': ->
		if Session.get('Organization')?.domains.length is 1
			toastr.error 'Organization must have at least one domain'
		else
			Meteor.call 'removeDomainFromOrg', Meteor.user().organizationId, this.toString(), (err, result) ->
				Session.set('Organization', result);
