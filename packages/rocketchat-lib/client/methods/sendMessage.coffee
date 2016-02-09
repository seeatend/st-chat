Meteor.methods
	sendMessage: (message) ->
		if not Meteor.userId()
			throw new Meteor.Error 203, t('User_logged_out')

		if _.trim(message.msg) isnt ''

			message.ts = new Date(Date.now() + TimeSync.serverOffset())

			message.u =
				_id: Meteor.userId()
				username: Meteor.user().username
				displayName: Meteor.user().displayName

			message.temp = true

			# message timeline
			query =
				rid: message.rid
				ts: $lt: message.ts
				t: { '$ne': 't' }

			previous = ChatMessage.findOne query, { sort: ts: -1, limit: 1 }

			message.timeLine = RocketChat.services.getMessageTimeLine(message, previous)

			message = RocketChat.callbacks.run 'beforeSaveMessage', message

			ChatMessage.insert message
