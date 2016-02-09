Meteor.publish 'adminGroups', () ->
	unless this.userId
		return this.ready()

	options =
		fields:
			name: 1
			t: 1
			cl: 1
			u: 1
			usernames: 1
			muted: 1
		sort:
			name: 1

	user = RocketChat.models.Users.findOneById this.userId, fields: organizationId: 1

	return RocketChat.models.Rooms.findByOrgId user.organizationId, options
