Template.privateGroups.helpers
	tRoomMembers: ->
		return t('Members_placeholder')

	rooms: ->
	#uncomment to unlock favourites
	#		query = { 'u._id': Meteor.userId(), t: { $in: ['p']}, f: { $ne: true }, open: true }
		query = { 'u._id': Meteor.userId(), t: { $in: ['p']}, open: true }

		return ChatSubscription.find query, { sort: 't': 1, 'name': 1 }

	total: ->
		return ChatSubscription.find({ 'u._id': Meteor.userId(), t: { $in: ['p']}, f: { $ne: true } }).count()

	totalOpen: ->
		return ChatSubscription.find({ 'u._id': Meteor.userId(), t: { $in: ['p']}, f: { $ne: true }, open: true }).count()

	isActive: ->
		return 'active' if ChatSubscription.findOne({ 'u._id': Meteor.userId(), t: { $in: ['p']}, f: { $ne: true }, open: true, rid: Session.get('openedRoom') }, { fields: { _id: 1 } })?

Template.privateGroups.events
	'click .add-room': (e, instance) ->
		if RocketChat.authz.hasAtLeastOnePermission('create-p')
			Modal.init($('#privateGroupsModal'))
			Modal.open()
		else
			e.preventDefault()

	'click .more-groups': ->
		Modal.init($('#listPrivateGroupsModal'))
		Modal.open()
