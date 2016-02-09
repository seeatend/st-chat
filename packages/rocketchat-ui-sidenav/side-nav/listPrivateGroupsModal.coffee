Template.listPrivateGroupsModal.helpers
	groups: ->
	#uncomment to enable favourites
	#	return ChatSubscription.find { 'u._id': Meteor.userId(), t: { $in: ['p']}, f: { $ne: true } }, { sort: 't': 1, 'name': 1 }
    return ChatSubscription.find { 'u._id': Meteor.userId(), t: { $in: ['p']} }, { sort: 't': 1, 'name': 1 }

Template.listPrivateGroupsModal.events
	'click header': ->
		SideNav.closeFlex()

	'click .channel-link': ->
		Modal.close()

	'click .close-modal': (e) ->
		e.preventDefault()
		Modal.close()

	'click footer .create': ->
		Modal.close()
		Modal.init $('#privateGroupsModal')
		Modal.open()

	'mouseenter header': ->
		SideNav.overArrow()

	'mouseleave header': ->
		SideNav.leaveArrow()
