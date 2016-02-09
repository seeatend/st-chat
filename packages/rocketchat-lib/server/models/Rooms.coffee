RocketChat.models.Rooms = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'room'

		@tryEnsureIndex { 'name': 1 }, { sparse: 1 }
		@tryEnsureIndex { 'default': 1 }
		@tryEnsureIndex { 'usernames': 1 }
		@tryEnsureIndex { 't': 1 }
		@tryEnsureIndex { 'u._id': 1 }


	# FIND ONE
	findOneById: (_id, options) ->
		query =
			_id: _id

		return @findOne query, options

	findOneByName: (name, options) ->
		query =
			name: name

		return @findOne query, options

	findOneByNameAndOrg: (name, orgId, options) ->
		query =
			name: name
			organizationId: orgId

		return @findOne query, options

	findOneByNameTypeAndOrg: (name, type, orgId, options) ->
		query =
			name: name
			t: type
			organizationId: orgId

		return @findOne query, options

	findOneByNameAndType: (name, type, options) ->
		query =
			name: name
			t: type

		return @findOne query, options

	findOneDirectByUsernamesAndOrg: (type, myUsername, receiverUsername, orgId, options) ->
		query =
			t: 'd'
			$and: [
				usernames: myUsername
				usernames: receiverUsername
			]
			organizationId: orgId

		return @findOne query, options

	findOneByIdContainigUsername: (_id, username, options) ->
		query =
			_id: _id
			usernames: username

		return @findOne query, options

	findOneByNameAndTypeNotContainigUsername: (name, type, username, options) ->
		query =
			name: name
			t: type
			usernames:
				$ne: username

		return @findOne query, options


	# FIND

	findByOrg: (orgId, options) ->
		query =
			organizationId: orgId

		return @find query, options

	findByType: (type, orgId, options) ->
		query =
			t: type
			organizationId: orgId

		return @find query, options

	findByTypes: (types, orgId, options) ->
		query =
			t:
				$in: types
			organizationId: orgId

		return @find query, options

	findByUserId: (userId, options) ->
		query =
			"u._id": userId

		return @find query, options

	findByOrgId: (orgId, options) ->
		query =
			"organizationId": orgId

		return @find query, options

	findByNameContaining: (name, orgId, options) ->
		nameRegex = new RegExp name, "i"

		query =
			$or: [
				name: nameRegex
			,
				t: 'd'
				usernames: nameRegex
			]
			organizationId: orgId

		return @find query, options

	findByNameContainingAndTypes: (name, types, orgId, options) ->
		nameRegex = new RegExp name, "i"

		query =
			t:
				$in: types
			$or: [
				name: nameRegex
			,
				t: 'd'
				usernames: nameRegex
			]
			organizationId: orgId

		return @find query, options

	findByDefaultAndTypes: (defaultValue, types, orgId, options) ->
		query =
			default: defaultValue
			t:
				$in: types
			organizationId: orgId

		return @find query, options

	findByTypeContainigUsername: (type, username, options) ->
		query =
			t: type
			usernames: username

		return @find query, options

	findByTypeContainigUsernames: (type, username, options) ->
		query =
			t: type
			usernames: { $all: [].concat(username) }

		return @find query, options

	findByTypesAndNotUserIdContainingUsername: (types, userId, username, options) ->
		query =
			t:
				$in: types
			uid:
				$ne: userId
			usernames: username

		return @find query, options

	findByContainigUsername: (username, options) ->
		query =
			usernames: username

		return @find query, options

	findByTypeAndName: (type, name, orgId, options) ->
		query =
			t: type
			name: name
			organizationId: orgId

		return @find query, options

	findByTypeAndNameContainigUsername: (type, name, username, options) ->
		query =
			name: name
			t: type
			usernames: username

		return @find query, options

	findByTypeAndArchivationState: (type, archivationstate, options) ->
		query =
			t: type

		if archivationstate
			query.archived = true
		else
			query.archived = { $ne: true }

		return @find query, options

	findByVisitorToken: (visitorToken, options) ->
		query =
			"v.token": visitorToken

		return @find query, options


	# UPDATE
	archiveById: (_id) ->
		query =
			_id: _id

		update =
			$set:
				archived: true

		return @update query, update

	unarchiveById: (_id) ->
		query =
			_id: _id

		update =
			$set:
				archived: false

		return @update query, update

	addUsernameById: (_id, username) ->
		query =
			_id: _id

		update =
			$addToSet:
				usernames: username

		return @update query, update

	addUsernamesById: (_id, usernames) ->
		query =
			_id: _id

		update =
			$addToSet:
				usernames:
					$each: usernames

		return @update query, update

	addUsernameByName: (name, username) ->
		query =
			name: name

		update =
			$addToSet:
				usernames: username

		return @update query, update

	removeUsernameById: (_id, username) ->
		query =
			_id: _id

		update =
			$pull:
				usernames: username

		return @update query, update

	removeUsernamesById: (_id, usernames) ->
		query =
			_id: _id

		update =
			$pull:
				usernames:
					$in: usernames

		return @update query, update

	removeUsernameFromAll: (username) ->
		query = {}

		update =
			$pull:
				usernames: username

		return @update query, update, { multi: true }

	removeUsernameByName: (name, username) ->
		query =
			name: name

		update =
			$pull:
				usernames: username

		return @update query, update

	setNameById: (_id, name) ->
		query =
			_id: _id

		update =
			$set:
				name: name

		return @update query, update

	incUnreadAndSetLastMessageTimestampById: (_id, inc=1, lastMessageTimestamp) ->
		query =
			_id: _id

		update =
			$set:
				lm: lastMessageTimestamp
			$inc:
				msgs: inc

		return @update query, update

	replaceUsername: (previousUsername, username) ->
		query =
			usernames: previousUsername

		update =
			$set:
				"usernames.$": username

		return @update query, update, { multi: true }

	replaceMutedUsername: (previousUsername, username) ->
		query =
			muted: previousUsername

		update =
			$set:
				"muted.$": username

		return @update query, update, { multi: true }

	replaceUsernameOfUserByUserId: (userId, username) ->
		query =
			"u._id": userId

		update =
			$set:
				"u.username": username

		return @update query, update, { multi: true }

	setUserById: (_id, user) ->
		query =
			_id: _id

		update =
			$set:
				u:
					_id: user._id
					username: user.username

		return @update query, update

	setTypeById: (_id, type) ->
		query =
			_id: _id

		update =
			$set:
				t: type

		return @update query, update

	muteUsernameByRoomId: (_id, username) ->
		query =
			_id: _id

		update =
			$addToSet:
				muted: username

		return @update query, update

	unmuteUsernameByRoomId: (_id, username) ->
		query =
			_id: _id

		update =
			$pull:
				muted: username

		return @update query, update


	# INSERT
	createWithTypeNameUserAndUsernames: (type, name, user, usernames, extraData) ->
		room =
			t: type
			name: name
			usernames: usernames
			msgs: 0
			u:
				_id: user._id
				username: user.username
			organizationId: user.organizationId

		_.extend room, extraData

		room._id = @insert room
		return room

	createWithNameTypeAndOrgId: (name, type, orgId, extraData) ->
		room =
			ts: new Date()
			t: type
			name: name,
			organizationId: orgId,
			usernames: []
			msgs: 0

		_.extend room, extraData

		@insert room
		return room


	# REMOVE
	removeById: (_id) ->
		query =
			_id: _id

		return @remove query

	removeByTypeContainingUsername: (type, username) ->
		query =
			t: type
			username: username

		return @remove query