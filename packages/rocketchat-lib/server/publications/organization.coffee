Meteor.publish 'organization', ->
	unless @userId
		return @ready()

	if RocketChat.authz.hasRole(@userId, 'admin')
		RocketChat.models.Organizations.find({'adminId':@userId})
	else
		RocketChat.models.Organizations.find({userIds:@userId})