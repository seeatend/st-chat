Template.directMessagesModal.helpers
	error: ->
		return Template.instance().error.get()

	userStatus: ->
		return 'status-' + (Session.get('user_' + this.username + '_status') or 'offline')

	users: ->
		return Template.instance().usersList?.get()

Template.directMessagesModal.events
	'autocompleteselect #who': (event, instance, doc) ->
		instance.selectedUser.set doc.username
		event.currentTarget.focus()

	'click .close-modal': (e, instance) ->
		e.preventDefault()
		instance.clearForm()
		Modal.close()

	'click header': (e, instance) ->
		SideNav.closeFlex()
		instance.clearForm()

	'mouseenter header': ->
		SideNav.overArrow()

	'mouseleave header': ->
		SideNav.leaveArrow()

	'keydown input[type="text"]': (e, instance) ->
		Template.instance().error.set([])

	'click a.channel-link': (e, instance) ->
		if $(e.target).hasClass('channel-link')
			username = $(e.target).data('username')
		else
			username = $(e.target).closest('.channel-link').data('username')
		instance.createDirectChannel(username)

Template.directMessagesModal.onCreated ->
	instance = this
	instance.error = new ReactiveVar []
	instance.usersList = new ReactiveVar []

	Meteor.call 'usersList', (err, result) ->
		if result
			instance.usersList.set result.users

	instance.clearForm = ->
		instance.error.set([])

	instance.createDirectChannel = (username) ->
		err = SideNav.validate()
		if not err
			Meteor.call 'createDirectMessage', username, (err, result) ->
				if err
					return toastr.error err.reason
				instance.clearForm()
				Modal.close()
				FlowRouter.go 'direct', { username: username }
		else
			Template.instance().error.set(err)
