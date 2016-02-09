Meteor.methods
	registerUser: (formData, isCordova) ->
		orgId = null;

		if formData.orgId
			orgId = formData.orgId
		else
			orgName = RocketChat.services.capitalizeFirstLetter formData.orgName
			org = RocketChat.models.Organizations.createWithNameAndDomain orgName, formData.email.split('@')[1], 0
			orgId = org._id
			RocketChat.models.Rooms.createWithNameTypeAndOrgId 'general', 'c', orgId,	default: true

		RocketChat.models.Organizations.updateOrgUserCountById orgId, 1

		loginData =
			email: formData.email
			password: formData.pass

		firstName = RocketChat.services.capitalizeFirstLetter formData.firstName
		lastName = RocketChat.services.capitalizeFirstLetter formData.lastName

		username = null
		userNameInEmailExists = Meteor.users.findOne('username': formData.email.split('@')[0], organizationId: orgId)
		userNameInFormExists = Meteor.users.findOne('username': formData.username, organizationId: orgId)

		if userNameInEmailExists && userNameInFormExists
			throw new (Meteor.Error)(404, 'Username already exists, please enter a different username')
			return
		else if userNameInEmailExists
			username = formData.username
		else
			username = formData.email.split('@')[0]

		random = Math.floor(Math.random()*90000) + 10000
		uuidCode = uuid.new()

		if formData.degree is 'Other'
			formData.otherDegree = RocketChat.services.capitalizeFirstLetter formData.otherDegree

		userId = Accounts.createUser loginData

		userData =
			degree: formData.degree
			otherDegree: RocketChat.services.capitalizeFirstLetter formData.otherDegree
			firstName: firstName
			lastName: lastName
			username: username
			mobilePhone: formData.mobilePhone
			notificationsEnabled: true
			orgId: orgId
			uuid: random + uuidCode.slice(5)
		RocketChat.models.Users.setUserData userId, userData

		# when inserting first user give them admin privileges otherwise make a regular user
		org = RocketChat.models.Organizations.findOneById(orgId)
		users = RocketChat.models.Users.find({organizationId: org._id}).fetch()
		console.log(users.length)
		roleName = if (users && users.length > 1) then 'user' else ['admin', 'billing-admin']

		RocketChat.authz.addUsersToRoles(userId, roleName)

		# add userId to org id's array
		RocketChat.models.Organizations.addUserById(orgId, userId)

		# If first user set org adminId 
		if org.userCount == 1
			RocketChat.models.Organizations.setAdmin(orgId, userId)

		if loginData.email
			if isCordova
				try
					twilio = new Twilio(
						from: '+18482218563'
						sid: 'AC350b94865a001c6495c89395b1e04599'
						token: 'da72e43b7fbd7fad2363c1afda803fbc')
					twilio.sendSMS
						to: userData.mobilePhone
						body: 'Your Stitch verification code is: ' + random
				catch e
			else
				Mandrill.messages.sendTemplate({
					"template_name": "sign-up-1-authenticate",
					"template_content": [{}],
					"message": {
						subject: 'Invitation to Stitch',
						from_email: 'support@teamstitch.com',
						from_name: 'Stitch',
						"global_merge_vars": [
							{
								"name": "confirmAccountUrl",
								"content": Meteor.absoluteUrl('verify/' + userData.uuid)
							}
						],
						"to": [{"email": loginData.email}],
						important: true
					}
				});

		return loginData.email

	emailExists: (email) ->
		user = Meteor.users.findOne('emails.address': email)
		if user
			true
		else
			false

	usernameExistsInOrg: (username, orgId) ->
		user = Meteor.users.findOne('username': username, organizationId: orgId)
		if user
			true
		else
			false

	verifyUser: (uuid, email) ->
		check uuid, String
		# Check user exists
		user = null
		if email #in case of mobile apps
			user = Meteor.users.findOne('emails.address': email)
		else
			user = Meteor.users.findOne(uuid: uuid)

		if !uuid or !user
			throw new (Meteor.Error)(404, 'User does not exist')

		if email
			if uuid != user.uuid.substr(0,5)
				throw new (Meteor.Error)(404, 'Incorrect SMS code')
		else
			try
				twilio = new Twilio(
					from: '+18482218563'
					sid: 'AC350b94865a001c6495c89395b1e04599'
					token: 'da72e43b7fbd7fad2363c1afda803fbc')
				twilio.sendSMS
					to: user.mobilePhone
					body: 'Welcome! You can download the Stitch mobile app here:\nhttp://bit.ly/1J1xvq4'
			catch e

		user.emails[0].verified = true
		Meteor.users.update user._id, user
		return user.uuid

	resetUserPassword: (uuid, newPassword) ->
		check uuid, String
		# Check user exists
		if !uuid or !Meteor.users.findOne(uuid: uuid)
			throw new (Meteor.Error)(404, 'User does not exist')
		user = Meteor.users.findOne(uuid: uuid)
		Accounts.setPassword user._id, newPassword

	checkPassword: (digest) ->
		check digest, String
		if Meteor.userId()?
			user = Meteor.user()
			password =
				digest: digest
				algorithm: 'sha-256'
			result = Accounts._checkPassword(user, password)
			if result.error?
				return false
			else
				return true
		else
			false

	setLastRoomId: (roomType, roomName) ->
		if Meteor.userId()?
			room = null
			if roomType is 'd'
				room = RocketChat.models.Rooms.findOneDirectByUsernamesAndOrg roomType, Meteor.user().username, roomName, Meteor.user().organizationId
			else
				room = RocketChat.models.Rooms.findOneByNameTypeAndOrg roomName, roomType, Meteor.user().organizationId

			RocketChat.models.Users.setLastRoomId Meteor.userId(), room._id
