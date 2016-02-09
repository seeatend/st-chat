Template.starredRooms.helpers
	rooms: ->
		query = { 'u._id': Meteor.userId(), f: true, open: true }

		if Meteor.user()?.settings?.preferences?.unreadRoomsMode
			query.alert =
				$ne: true

		return ChatSubscription.find query, { sort: 't': 1, 'name': 1 }
	total: ->
		return  0 #ChatSubscription.find({ 'u._id': Meteor.userId(), f: true }).count()
	isActive: ->
		return 'active' if ChatSubscription.findOne({ 'u._id': Meteor.userId(), f: true, rid: Session.get('openedRoom') }, { fields: { _id: 1 } })?
