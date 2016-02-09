Template.directMessages.helpers
	rooms: ->
		#uncomment to unlock favourites
		#query = { 'u._id': Meteor.userId(), t: { $in: ['d']}, f: { $ne: true }, open: true }
		query = { 'u._id': Meteor.userId(), t: { $in: ['d']}, open: true }

		if Meteor.user()?.settings?.preferences?.unreadRoomsMode
			query.alert =
				$ne: true

		return ChatSubscription.find query, { sort: 't': 1, 'name': 1 }
	isActive: ->
		return 'active' if ChatSubscription.findOne({ 'u._id': Meteor.userId(), t: { $in: ['d']}, f: { $ne: true }, open: true, rid: Session.get('openedRoom') }, { fields: { _id: 1 } })?

Template.directMessages.events
	'click .add-room': (e, instance) ->
		Modal.init($('#directMessagesModal'))
		Modal.open()
