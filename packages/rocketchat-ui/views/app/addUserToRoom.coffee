Template.addUserToRoom.helpers
	usersInRoom: ->
		return Template.instance().usersInRoom.get()

	error: ->
		return Template.instance().error.get()

	autocompleteSettings: ->
		usernames = _.pluck(Template.instance().usersInRoom.get(), 'username')
		return {
		limit: 10
# inputDelay: 300
		rules: [
			{
# @TODO maybe change this 'collection' and/or template
				collection: 'UserAndRoom'
				subscription: 'roomSearch'
				field: 'username'
				selector: (match) ->
					return {regexString: match}
				template: Template.userSearch
				noMatchTemplate: Template.userSearchEmpty
				matchAll: true
				filter:
					type: 'u'
					$and: [
						{ _id: { $ne: Meteor.userId() } }
						{ username: { $nin: usernames } }
						{ active: { $eq: true } }
						{ organizationId: { $eq: Meteor.user().organizationId } }
					]
				sort: 'username'
			}
		]
		}

Template.addUserToRoom.events
	'autocompleteselect #room-members': (event, instance, doc) ->
		user = {_id: doc._id, username: doc.username, name: doc.name, isNew: true}
		instance.usersInRoom.set instance.usersInRoom.get().concat user

		setTimeout ->
			event.currentTarget.value = ''
			event.currentTarget.focus()
		, 10

	'click .close-modal': (event, instance) ->
		users = instance.usersInRoom.get()
		users = _.reject instance.usersInRoom.get(), (user) ->
			return user.isNew is true

		instance.usersInRoom.set(users)

	'click #addUserToRoomSubmit': (event, instance) ->
		event.preventDefault()

		users = instance.usersInRoom.get()
		newUsers = _.filter(users, (user) ->
			user.isNew is true
		)

		if newUsers?.length is 0
			return

		Meteor.call 'addUsersToRoom', this.roomId, newUsers, (error, result) ->
			if result
				toastr.success 'User(s) added successfully'
				for user in users
					user.isNew = false
				instance.usersInRoom.set(users)
			if error
				toastr.error error.reason
			Modal.close()

	'click .remove-room-member': (e, instance) ->
		self = @

		users = instance.usersInRoom.get()
		users = _.reject instance.usersInRoom.get(), (user) ->
			return user.username is self.username

		instance.usersInRoom.set(users)

	'mouseenter header': ->
		SideNav.overArrow()

	'mouseleave header': ->
		SideNav.leaveArrow()

	'click footer .all': ->
		SideNav.setFlex "listChannelsFlex"

	'focus #room-members': ->
		unless $('#room-members').val()
			$('#room-members').val(' ')

Template.addUserToRoom.onCreated ->
	room = Session.get('roomData' + this.data.roomId)

	usersOfRoom = Meteor.users.find({
			username: {$in: room.usernames},
			_id: {$ne: Meteor.userId()}},
		{fields: {_id: 1, username: 1, name: 1}})
	.fetch()

	instance = this
	instance.usersInRoom = new ReactiveVar []

	for userOfRoom in usersOfRoom
		user = {_id: userOfRoom._id, username: userOfRoom.username, name: userOfRoom.name, isNew: false}
		instance.usersInRoom.set instance.usersInRoom.get().concat user
