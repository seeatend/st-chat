Meteor.methods
	createDirectMessage: (username) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] createDirectMessage -> Invalid user"

		me = Meteor.user()

		if me.username is username
			throw new Meteor.Error('invalid-user', "[methods] createDirectMessage -> Invalid target user")

		to = RocketChat.models.Users.findOneByUsername username

		if not to
			throw new Meteor.Error('invalid-user', "[methods] createDirectMessage -> Invalid target user")

		rid = [me._id, to._id].sort().join('')

		now = new Date()

		# Make sure we have a room
		RocketChat.models.Rooms.upsert
			_id: rid
		,
			$set:
				usernames: [me.username, to.username]
			$setOnInsert:
				organizationId: me.organizationId
				t: 'd'
				msgs: 0
				ts: now

		# Make user I have a subcription to this room
		RocketChat.models.Subscriptions.upsert
			rid: rid
			$and: [{'u._id': me._id}] # work around to solve problems with upsert and dot
		,
			$set:
				ts: now
				ls: now
				open: true
			$setOnInsert:
				name: to.username
				receiverName: to.name
				t: 'd'
				alert: false
				unread: 0
				u:
					_id: me._id
					username: me.username
					name: me.name
				organizationId: me.organizationId

		# Make user the target user has a subcription to this room
		RocketChat.models.Subscriptions.upsert
			rid: rid
			$and: [{'u._id': to._id}] # work around to solve problems with upsert and dot
		,
			$setOnInsert:
				name: me.username
				receiverName: me.name
				t: 'd'
				open: false
				alert: false
				unread: 0
				u:
					_id: to._id
					username: to.username
					name: to.name
				organizationId: to.organizationId

		return {
			rid: rid
		}
