RocketChat.checkUsernameAvailability = (username, orgId) ->
	return not Meteor.users.findOne({ organizationId: orgId, username: { $regex : new RegExp("^" + s.trim(username) + "$", "i") } })
