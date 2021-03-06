Meteor.publish 'roomSearch', (selector, options, collName) ->
	unless this.userId
		return this.ready()

	self = this
	searchType = null
	subHandleUsers = null
	subHandleRooms = null

	if selector.type
		searchType = selector.type
		delete selector.type

	if not searchType? or searchType is 'u'
		if selector.regexString
			if selector.regexString isnt ' '
				regexStringArr = selector.regexString.trim().split RegExp(' +', 'g')
				for regexString in regexStringArr
					regex = new RegExp(regexString, 'i')
					selector['$and'].push $or: [{'name': regex}, {'username': regex}]
			delete selector.regexString
		subHandleUsers = RocketChat.models.Users.find(selector, { limit: 5, fields: { name: 1, username: 1, status: 1 } }).observeChanges
			added: (id, fields) ->
				data = { type: 'u', uid: id, name: fields.name, username: fields.username, status: fields.status }
				self.added("autocompleteRecords", id, data)
			changed: (id, fields) ->
				self.changed("autocompleteRecords", id, fields)
			removed: (id) ->
				self.removed("autocompleteRecords", id)

	if not searchType? or searchType is 'r'
		subHandleRooms = RocketChat.models.Rooms.findByTypesAndNotUserIdContainingUsername(['c', 'p'], selector.uid?.$ne, RocketChat.models.Users.findOneById(this.userId).username, { limit: 10, fields: { t: 1, name: 1 } }).observeChanges
			added: (id, fields) ->
				data = { type: 'r', rid: id, name: fields.name, t: fields.t }
				self.added("autocompleteRecords", id, data)
			changed: (id, fields) ->
				self.changed("autocompleteRecords", id, fields)
			removed: (id) ->
				self.removed("autocompleteRecords", id)

	this.ready()

	this.onStop ->
		subHandleUsers?.stop()
		subHandleRooms?.stop()
