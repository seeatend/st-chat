Meteor.methods
	leaveRoom: (rid) ->
		fromId = Meteor.userId()

		unless Meteor.userId()?
			throw new Meteor.Error 300, 'Usuário não logado'

		room = RocketChat.models.Rooms.findOneById rid
		user = Meteor.user()

		RocketChat.callbacks.run 'beforeLeaveRoom', user, room

		RocketChat.models.Rooms.removeUsernameById rid, user.username

		if room.t isnt 'c' and room.usernames.indexOf(user.username) isnt -1
			removedUser = user

			RocketChat.models.Messages.createUserLeaveWithRoomIdAndUser rid, removedUser

		if room.t is 'l'
			RocketChat.models.Messages.createCommandWithRoomIdAndUser 'survey', rid, user


		if room.u?._id is Meteor.userId()
			newOwner = _.without(room.usernames, user.username)[0]
			if newOwner?
				newOwner = RocketChat.models.Users.findOneByUsername newOwner

				if newOwner?
					RocketChat.models.Rooms.setUserById rid, newOwner

		RocketChat.models.Subscriptions.removeByRoomIdAndUserId rid, Meteor.userId()

		Meteor.defer ->

			RocketChat.callbacks.run 'afterLeaveRoom', user, room

	deleteRoom: (rid) ->
		RocketChat.models.Messages.removeByRoomId(rid)
		RocketChat.models.Subscriptions.removeByRoomId(rid)
		RocketChat.models.Rooms.removeById(rid)

		orgId = Meteor.user().organizationId;

		query =
			t: 'c'
			organizationId: orgId
			name:
				$ne: 'general'
		channels = RocketChat.models.Rooms.find(query, { sort: { msgs:-1 } }).fetch()
		general = RocketChat.models.Rooms.findOne {name: 'general', organizationId: orgId}
		channels.unshift(general)

		return { channels: channels }
