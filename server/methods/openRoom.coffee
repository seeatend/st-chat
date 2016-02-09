Meteor.methods
	openRoom: (rid) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', '[methods] openRoom -> Invalid user'

		room = RocketChat.models.Rooms.findOneById rid
		if not room
			throw new Meteor.Error 'invalid-room', '[methods] openRoom -> Invalid room'

		console.log '[methods] openRoom -> '.green, 'userId:', Meteor.userId(), 'arguments:', arguments

		if room.t is 't'
			RocketChat.models.Subscriptions.update
				rid: rid
				'u._id': Meteor.userId()
			,
				$set:
					open: true
					mrn: room?.mrn
					fullName: room?.fullName
		else
			RocketChat.models.Subscriptions.openByRoomIdAndUserId rid, Meteor.userId()
