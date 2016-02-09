Meteor.startup ->
	RocketChat.roomTypes.setPublish 'c', (identifier) ->
		options =
			fields:
				name: 1
				t: 1
				cl: 1
				u: 1
				usernames: 1
				muted: 1
				archived: 1

		user = RocketChat.models.Users.findOneById this.userId, fields: organizationId: 1
		return RocketChat.models.Rooms.findByTypeAndName 'c', identifier, user.organizationId,

	RocketChat.roomTypes.setPublish 'p', (identifier) ->
		options =
			fields:
				name: 1
				t: 1
				cl: 1
				u: 1
				usernames: 1
				muted: 1
				archived: 1
		user = RocketChat.models.Users.findOneById this.userId, fields: username: 1
		return RocketChat.models.Rooms.findByTypeAndNameContainigUsername 'p', identifier, user.username, options

	RocketChat.roomTypes.setPublish 'd', (identifier) ->
		options =
			fields:
				name: 1
				t: 1
				cl: 1
				u: 1
				usernames: 1
		user = RocketChat.models.Users.findOneById this.userId, fields: username: 1
		return RocketChat.models.Rooms.findByTypeContainigUsernames 'd', [user.username, identifier], options

	RocketChat.roomTypes.setPublish 't', (identifier) ->
		options =
			fields:
				name: 1
				fullName: 1
				mrn: 1
				t: 1
				cl: 1
				u: 1
				usernames: 1
		user = RocketChat.models.Users.findOneById this.userId, fields: organizationId: 1
		return RocketChat.models.Rooms.findByTypeAndName 't', identifier, user.organizationId, options
