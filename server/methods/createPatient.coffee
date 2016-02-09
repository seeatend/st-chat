Meteor.methods
	createPatient: (data, members) ->
		name = data.name
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] createPatient -> Invalid user"

		if not /^[0-9a-z-_]+$/.test name
			throw new Meteor.Error 'name-invalid'

		if RocketChat.authz.hasPermission(Meteor.userId(), 'create-c') isnt true
			throw new Meteor.Error 'not-authorized', '[methods] createPatient -> Not authorized'

		console.log '[methods] createPatient -> '.green, 'userId:', Meteor.userId(), 'arguments:', arguments

		now = new Date()
		user = Meteor.user()

		members.push user.username

		# avoid duplicate names
		if RocketChat.models.Rooms.findOneByNameAndOrg name, user.organizationId
			throw new Meteor.Error 'duplicate-name'

		issetMrn = RocketChat.models.Rooms.findOne mrn: data.mrn
		if issetMrn
			throw new Meteor.Error 'duplicate-mrn'

		RocketChat.callbacks.run 'beforeCreatePatient', user,
			t: 't'
			name: name
			fullName: data.fullName
			mrn: data.mrn
			ts: now
			usernames: members
			u:
				_id: user._id
				username: user.username

		# create new room
		room = RocketChat.models.Rooms.createWithTypeNameUserAndUsernames 't', name, user, members,
			ts: now
			mrn: data.mrn
			fullName: data.fullName

		# set creator as channel moderator.  permission limited to channel by scoping to rid
		RocketChat.authz.addUsersToRoles(Meteor.userId(), 'moderator', room._id)

		for username in members
			member = RocketChat.models.Users.findOneByUsername username
			if not member?
				continue

			extra = {}

			if username is user.username
				extra.ls = now
				extra.open = true
				extra.mrn = data.mrn
				extra.fullName = data.fullName

			RocketChat.models.Subscriptions.createWithRoomAndUser room, member, extra

		Meteor.defer ->
			RocketChat.callbacks.run 'afterCreatePatient', user, room

		return {
		rid: room._id
		}
