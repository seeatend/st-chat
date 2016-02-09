Meteor.publish 'adminRooms', (filter, types, limit) ->
	unless this.userId
		return this.ready()

	if RocketChat.authz.hasPermission(@userId, 'view-room-administration') isnt true
		return this.ready()

	unless _.isArray types
		types = []

	options =
		fields:
			name: 1
			t: 1
			cl: 1
			u: 1
			usernames: 1
			muted: 1
		limit: limit
		sort:
			name: 1

	filter = _.trim filter

	user = RocketChat.models.Users.findOneById this.userId, fields: organizationId: 1

	if filter and types.length
		return RocketChat.models.Rooms.findByNameContainingAndTypes filter, types, user.organizationId, options

	if filter
		return RocketChat.models.Rooms.findByNameContaining filter, user.organizationId, options

	if types.length
		return RocketChat.models.Rooms.findByTypes types, user.organizationId, options
