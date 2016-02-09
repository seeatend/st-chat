Template.listChannelsModal.helpers
	joinedChannels: ->
		query =
			t: 'c'
			usernames: Meteor.user().username
		return ChatRoom.find(query, { sort: { name:-1 } }).fetch()

	canJoinChannels: ->
		query =
			t: 'c'
			usernames:
				$ne: Meteor.user().username
		return ChatRoom.find(query, { sort: { name:-1 } }).fetch()

Template.listChannelsModal.events
	'click .close-modal': (e) ->
		e.preventDefault()
		Modal.close()

	'click .channel-link': ->
		Modal.close()

	'click footer .create': ->
		if RocketChat.authz.hasAtLeastOnePermission( 'create-c')
			Modal.close()
			Modal.init($('#createChannelModal'))
			Modal.open()

	'mouseenter header': ->
		SideNav.overArrow()

	'mouseleave header': ->
		SideNav.leaveArrow()

Template.listChannelsModal.onCreated ->
	instance = this
	instance.channelsList = new ReactiveVar []

	@autorun ->
		instance.subscribe 'adminGroups'
