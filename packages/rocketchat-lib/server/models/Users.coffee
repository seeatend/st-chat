RocketChat.models.Users = new class extends RocketChat.models._Base
	constructor: ->
		@model = Meteor.users


	# FIND ONE
	findOneById: (_id, options) ->
		return @findOne _id, options

	findOneByUsername: (username, options) ->
		query =
			username: username

		return @findOne query, options

	findOneByUsernameAndOrg: (username, orgId, options) ->
		query =
			username: username
			organizationId: orgId

		return @findOne query, options

	findOneByEmailAddress: (emailAddress, options) ->
		query =
			'emails.address': emailAddress

		return @findOne query, options

	findOneByVerifiedEmailAddress: (emailAddress, verified=true, options) ->
		query =
			emails:
				$elemMatch:
					address: emailAddress
					verified: verified

		return @findOne query, options

	findOneVerifiedFromSameDomain: (email, options) ->
		domain = s.strRight(email, '@')
		query =
			emails:
				$elemMatch:
					address:
						$regex: new RegExp "@" + domain + "$", "i"
						$ne: email
					verified: true

		return @findOne query, options

	findOneAdmin: (admin, options) ->
		query =
			admin: admin

		return @findOne query, options

	findOneByIdAndLoginToken: (_id, token, options) ->
		query =
			_id: _id
			'services.resume.loginTokens.hashedToken' : Accounts._hashLoginToken(token)

		return @findOne query, options


	# FIND
	findUsersNotOffline: (orgId, options) ->
		query =
			username:
				$exists: 1
			status:
				$in: ['online', 'away', 'busy']
			organizationId: orgId

		return @find query, options

	findByOrgId: (orgId, options) ->
		query =
			organizationId: orgId

		return @find query, options

	findByUsername: (username, orgId, options) ->
		query =
			username: username
			organizationId: orgId

		return @find query, options

	findByActiveUsersNameOrUsername: (nameOrUsername, orgId, options) ->
		query =
			username:
				$exists: 1
			active: true
			organizationId: orgId
			$or: [
				{name: nameOrUsername}
				{username: nameOrUsername}
			]

		return @find query, options

	findUsersByNameOrUsername: (nameOrUsername, orgId, options) ->
		query =
			username:
				$exists: 1
			organizationId: orgId
			$or: [
				{name: nameOrUsername}
				{username: nameOrUsername}
			]

		return @find query, options

	findByUsernameNameOrEmailAddress: (usernameNameOrEmailAddress, orgId, options) ->
		query =
			$or: [
				{name: usernameNameOrEmailAddress}
				{username: usernameNameOrEmailAddress}
				{'emails.address': usernameNameOrEmailAddress}
			]
			organizationId: orgId

		return @find query, options

	getLastLogin: (options = {}) ->
		query = { lastLogin: { $exists: 1 } }
		options.sort = { lastLogin: -1 }
		options.limit = 1

		return @find(query, options)?.fetch?()?[0]?.lastLogin


	# UPDATE
	updateLastLoginById: (_id) ->
		update =
			$set:
				lastLogin: new Date

		return @update _id, update

	setServiceId: (_id, serviceName, serviceId) ->
		update =
			$set: {}

		serviceIdKey = "services.#{serviceName}.id"
		update.$set[serviceIdKey] = serviceId

		return @update _id, update

	setUsername: (_id, username) ->
		update =
			$set: username: username

		return @update _id, update

	setName: (_id, name) ->
		update =
			$set:
				name: name

		return @update _id, update

	setPhone: (_id, phone) ->
		update =
			$set:
				phone: phone

		return @update _id, update

	setOrganizationId: (_id, orgId) ->
		update =
			$set:
				organizationId: orgId

		return @update _id, update

	setUserData: (_id, userData) ->
		displayDegree = ''
		if userData.degree is 'Other'
			displayDegree = userData.otherDegree
		else
			displayDegree = userData.degree

		update =
			$set:
				degree: userData.degree
				otherDegree: userData.otherDegree
				firstName: userData.firstName
				lastName: userData.lastName
				displayName: userData.firstName + ' ' + userData.lastName + ' (' + displayDegree + ')'
				username: userData.username
				name: userData.firstName + ' ' + userData.lastName
				mobilePhone: userData.mobilePhone
				notificationsEnabled: userData.notificationsEnabled
				lastRoomId: userData.lastRoomId
				organizationId: userData.orgId
				uuid: userData.uuid

		return @update _id, update

	setAvatarOrigin: (_id, origin) ->
		update =
			$set:
				avatarOrigin: origin

		return @update _id, update

	unsetAvatarOrigin: (_id) ->
		update =
			$unset:
				avatarOrigin: 1

		return @update _id, update

	setUserActive: (_id, active=true) ->
		update =
			$set:
				active: active

		return @update _id, update

	setAllUsersActive: (active) ->
		update =
			$set:
				active: active

		return @update {}, update, { multi: true }

	unsetLoginTokens: (_id) ->
		update =
			$set:
				"services.resume.loginTokens" : []

		return @update _id, update

	setLanguage: (_id, language) ->
		update =
			$set:
				language: language

		return @update _id, update

	setProfile: (_id, profile) ->
		update =
			$set:
				firstName: profile.firstName
				lastName: profile.lastName
				name: profile.firstName + ' ' + profile.lastName
				mobilePhone: profile.mobilePhone
				displayName: profile.displayName
				degree: profile.degree
				otherDegree: profile.otherDegree
				notificationsEnabled: profile.notificationsEnabled

		return @update _id, update

	setLastRoomId: (_id, roomId) ->
		update =
			$set:
				lastRoomId: roomId

		return @update _id, update

	setPreferences: (_id, preferences) ->
		update =
			$set:
				"settings.preferences": preferences

		return @update _id, update

	setUtcOffset: (_id, utcOffset) ->
		query =
			_id: _id
			utcOffset:
				$ne: utcOffset

		update =
			$set:
				utcOffset: utcOffset

		return @update query, update


	# INSERT
	create: (data) ->
		user =
			createdAt: new Date
			avatarOrigin: 'none'

		_.extend user, data

		return @insert user


	# REMOVE
	removeById: (_id) ->
		return @remove _id

	removeByUnverifiedEmail: (email) ->
		query =
			emails:
				$elemMatch:
					address: email
					verified: false

		return @remove query
