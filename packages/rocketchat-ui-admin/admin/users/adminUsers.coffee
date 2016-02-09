Template.adminUsers.helpers
	isReady: ->
		return Template.instance().ready?.get()
	emailEnabled: ->
		console.log 'emailEnabled', RocketChat.settings.get('MAIL_URL') or (RocketChat.settings.get('SMTP_Host') and RocketChat.settings.get('SMTP_Username') and RocketChat.settings.get('SMTP_Password'))
		return RocketChat.settings.get('MAIL_URL') or (RocketChat.settings.get('SMTP_Host') and RocketChat.settings.get('SMTP_Username') and RocketChat.settings.get('SMTP_Password'))
	inviteEmails: ->
		return Template.instance().inviteEmails.get()
	users: ->
		return Template.instance().users()
	flexOpened: ->
		return 'opened' if RocketChat.TabBar.isFlexOpen()
	arrowPosition: ->
		return 'left' unless RocketChat.TabBar.isFlexOpen()
	userData: ->
		return Meteor.users.findOne Session.get 'adminSelectedUser'
	userChannels: ->
		return ChatSubscription.find({ "u._id": Session.get 'adminSelectedUser' }, { fields: { rid: 1, name: 1, t: 1 }, sort: { t: 1, name: 1 } }).fetch()
	isLoading: ->
		return 'btn-loading' unless Template.instance().ready?.get()
	hasMore: ->
		return Template.instance().limit?.get() is Template.instance().users?().length

	flexTemplate: ->
		return RocketChat.TabBar.getTemplate()

	flexData: ->
		return RocketChat.TabBar.getData()

	adminClass: ->
		return 'admin' if RocketChat.authz.hasRole(Meteor.userId(), 'admin')

Template.adminUsers.onCreated ->
	instance = @
	@limit = new ReactiveVar 50
	@filter = new ReactiveVar ''
	@ready = new ReactiveVar true
	@inviteEmails = new ReactiveVar []

	RocketChat.TabBar.addButton({ id: 'invite-user', i18nTitle: t('Invite_Users'), icon: 'icon-plus', template: 'adminInviteUser', order: 1 })

	@clearForm = ->
		$('#inviteEmails').val('')

	@autorun ->
		filter = instance.filter.get()
		limit = instance.limit.get()
		subscription = instance.subscribe 'fullUserData', filter, limit
		instance.ready.set subscription.ready()

	@autorun ->
		if Session.get 'adminSelectedUser'
			channelSubscription = instance.subscribe 'userChannels', Session.get 'adminSelectedUser'
			RocketChat.TabBar.setData Meteor.users.findOne Session.get 'adminSelectedUser'
			RocketChat.TabBar.addButton({ id: 'user-info', i18nTitle: t('User_Info'), icon: 'icon-user', template: 'adminUserInfo', order: 2 })
			# RocketChat.TabBar.addButton({ id: 'user-channel', i18nTitle: t('User_Channels'), icon: 'icon-hash', template: 'adminUserChannels', order: 3 })
		else
			RocketChat.TabBar.reset()
			RocketChat.TabBar.addButton({ id: 'invite-user', i18nTitle: t('Invite_Users'), icon: 'icon-plus', template: 'adminInviteUser', order: 1 })

	@users = ->
		filter = _.trim instance.filter?.get()
		if filter
			filterReg = new RegExp filter, "i"
			query = { organizationId: Meteor.user().organizationId, $or: [ { username: filterReg }, { name: filterReg }, { "emails.address": filterReg } ] }
		else
			query = { organizationId: Meteor.user().organizationId }

		return Meteor.users.find(query, { limit: instance.limit?.get(), sort: { username: 1, name: 1 } }).fetch()

Template.adminUsers.onRendered ->
	Meteor.call 'findOrgById', Meteor.user().organizationId, (err, result) ->
		Session.set('Organization', result);
	Tracker.afterFlush ->
		SideNav.setFlex "adminFlex"
		SideNav.openFlex()

Template.adminUsers.events
	'click .send': (e, instance) ->
		emails = $('#inviteEmails').val().split /[\s,;]/
		rfcMailPattern = /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
		validEmails = _.compact _.map emails, (email) -> return email if rfcMailPattern.test email
		if validEmails.length
			listContainBlockedEmails = false
			listContainPublicEmails = false
			for email in validEmails
				domain = email.split('@')[1]
				if RocketChat.services.isDomainPublic(domain)
					if Session.get('Organization').domains.length > 0
						listContainPublicEmails = true
				else if domain not in Session.get('Organization').domains
					listContainBlockedEmails = true
					break

			if listContainBlockedEmails
				toastr.error 'Looks like you’re trying to invite someone from another organization! Please request a domain merge under the ‘Organization’ section'
				listContainBlockedEmails = false
				return
			if listContainPublicEmails
				listContainPublicEmails = false
				swal {
					title: t('Are_you_sure')
					text: 'This will allow you to invite users with email addresses not associated with your organization. ' +
						'They will have access to patient information shared here.'
					type: 'warning'
					showCancelButton: true
					confirmButtonColor: '#DD6B55'
					confirmButtonText: 'Yes, enable.'
					cancelButtonText: 'No, cancel.'
					closeOnConfirm: false
					html: false
				}, ->
					swal {
						title: 'Password protected.'
						text: 'Please enter your account password to enable this admin ability.'
						html: true
						type: 'input'
						inputType: 'password'
						showCancelButton: true
						closeOnConfirm: false
						confirmButtonText: 'Enable'
						confirmButtonColor: '#ec6c62'
					}, (inputValue) ->
						digest = Package.sha.SHA256(inputValue);
						Meteor.call 'checkPassword', digest, (err, result) ->
							unless result
								swal
									title: 'Wrong password'
									text: ''
									type: 'error'
								return

							Meteor.call 'sendInvitationEmail', validEmails, (error, result) ->
								swal.close();
								if result
									instance.clearForm()
									instance.inviteEmails.set validEmails
								if error
									toastr.error error.reason
			else
				Meteor.call 'sendInvitationEmail', validEmails, (error, result) ->
					swal.close();
					if result
						instance.clearForm()
						instance.inviteEmails.set validEmails
					if error
						toastr.error error.reason
		else
			toastr.error t('Send_invitation_email_error')

	'click .cancel': (e, instance) ->
		instance.clearForm()
		instance.inviteEmails.set []
		RocketChat.TabBar.closeFlex()

	'keydown #users-filter': (e) ->
		if e.which is 13
			e.stopPropagation()
			e.preventDefault()

	'keyup #users-filter': (e, t) ->
		e.stopPropagation()
		e.preventDefault()
		t.filter.set e.currentTarget.value

	'click .flex-tab .more': ->
		if RocketChat.TabBar.isFlexOpen()
			RocketChat.TabBar.closeFlex()
		else
			RocketChat.TabBar.openFlex()

	'click .info-tabs a': (e) ->
		e.preventDefault()
		$('.info-tabs a').removeClass 'active'
		$(e.currentTarget).addClass 'active'

		$('.user-info-content').hide()
		$($(e.currentTarget).attr('href')).show()

	'click .load-more': (e, t) ->
		e.preventDefault()
		e.stopPropagation()
		t.limit.set t.limit.get() + 50

Template.adminUser.helpers
	isAdmin: ->
		return false

	emailAddress: ->
		return _.map(@emails, (e) -> e.address).join(', ')

	username: ->
		return '@' + @username if @username?

	isAdmin: ->
		return RocketChat.authz.hasRole(@_id, 'admin')

	adminToggleDisabled: ->
		if Meteor.userId() is @_id
			return 'disabled'

Template.adminUser.events
	'click input[name=is-admin]': (e) ->
		if $(e.currentTarget).prop('checked')
			Meteor.call 'setAdminStatus', @_id, true, (error, result) ->
				toastr.success 'Saved'
		else
			Meteor.call 'setAdminStatus', @_id, false, (error, result) ->
				toastr.success 'Saved'
