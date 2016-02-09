Meteor.methods
	createPrivateGroup: (name, members) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] createPrivateGroup -> Invalid user"

		unless RocketChat.authz.hasPermission(Meteor.userId(), 'create-p')
			throw new Meteor.Error 'not-authorized', '[methods] createPrivateGroup -> Not authorized'

		if not /^[0-9a-z-_]+$/.test name
			throw new Meteor.Error 'name-invalid'

		now = new Date()

		me = Meteor.user()

		members.push me.username

		name = s.slugify name

		# avoid duplicate names
		checkRoom = RocketChat.models.Rooms.findOneByNameAndOrg name, me.organizationId
		if checkRoom
			if checkRoom.t is 'c'
				throw new Meteor.Error 'duplicate-name', 'Oops! A public group has already taken this name.'
			else if checkRoom.t is 'p'
				throw new Meteor.Error 'duplicate-name', 'Oops! A private group has already taken this name.'

		# create new room
		room = RocketChat.models.Rooms.createWithTypeNameUserAndUsernames 'p', name, me, members,
			ts: now

		# set creator as group moderator.  permission limited to group by scoping to rid
		RocketChat.authz.addUsersToRoles(Meteor.userId(), 'moderator', room._id)

		for username in members
			member = RocketChat.models.Users.findOneByUsername(username, { fields: { username: 1, name: 1, organizationId: 1 }})
			if not member?
				continue

			extra = {}

			if username is me.username
				extra.ls = now
			else
				extra.alert = true

			RocketChat.models.Subscriptions.createWithRoomAndUser room, member, extra

		return {
			rid: room._id
		}
