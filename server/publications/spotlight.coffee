Meteor.publish 'spotlight', (selector, options, collName) ->
	unless this.userId
		return this.ready()

	self = this
	subHandleUsers = null
	subHandleRooms = null

	user = RocketChat.models.Users.findOneById this.userId, fields: organizationId: 1
	subHandleUsers = RocketChat.models.Users.findUsersByNameOrUsername(new RegExp(selector.name.$regex, 'i'), user.organizationId, { limit: 10, fields: { name: 1, username: 1, status: 1 } }).observeChanges
		added: (id, fields) ->
			data = { type: 'u', uid: id, name: fields.username + ' - ' + fields.name, status: fields.status }
			self.added("autocompleteRecords", id, data)
		removed: (id) ->
			self.removed("autocompleteRecords", id)

	user = RocketChat.models.Users.findOneById this.userId, fields: organizationId: 1
	subHandleRooms = RocketChat.models.Rooms.findByNameContainingAndTypes(selector.name.$regex, ['c'], user.organizationId, { limit: 10, fields: { t: 1, name: 1 } }).observeChanges
		added: (id, fields) ->
			data = { type: 'r', rid: id, name: fields.name, t: fields.t }
			self.added("autocompleteRecords", id, data)
		removed: (id) ->
			self.removed("autocompleteRecords", id)

	this.ready()

	this.onStop ->
		subHandleUsers?.stop()
		subHandleRooms?.stop()
