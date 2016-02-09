Meteor.publish 'activeUsers', ->
	unless this.userId
		return this.ready()

	user = RocketChat.models.Users.findOneById this.userId, fields: organizationId: 1
	RocketChat.models.Users.findUsersNotOffline	user.organizationId,
		fields:
			username: 1
			status: 1
			utcOffset: 1
