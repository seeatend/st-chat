RocketChat.Notifications = new class
	constructor: ->
		self = @

		@debug = false

		@streamAll = new Meteor.Stream 'notify-all'
		@streamRoom = new Meteor.Stream 'notify-room'
		@streamUser = new Meteor.Stream 'notify-user'


		@streamAll.permissions.write -> return false
		@streamAll.permissions.read -> return @userId?

		@streamRoom.permissions.write -> return false
		@streamRoom.permissions.read (eventName) ->
			if not @userId? then return false

			roomId = eventName.split('/')[0]

			user = Meteor.users.findOne @userId, {fields: {username: 1}}
			return RocketChat.models.Rooms.findOneByIdContainigUsername(roomId, user.username, {fields: {_id: 1}})?

		@streamUser.permissions.write -> return @userId?
		@streamUser.permissions.read (eventName) ->
			userId = eventName.split('/')[0]
			return @userId? and @userId is userId


	notifyAll: (eventName, args...) ->
		console.log 'notifyAll', arguments if @debug is true

		args.unshift eventName
		@streamAll.emit.apply @streamAll, args

	notifyRoom: (room, eventName, args...) ->
		console.log 'notifyRoom', arguments if @debug is true

		args.unshift "#{room}/#{eventName}"
		@streamRoom.emit.apply @streamRoom, args

	notifyUser: (userId, eventName, args...) ->
		console.log 'notifyUser', arguments if @debug is true

		args.unshift "#{userId}/#{eventName}"
		@streamUser.emit.apply @streamUser, args
		notifyOffline(userId, args[1].payload.sender._id, args[1].payload.rid)


## Permissions for client

# Enable emit for event typing for rooms and add username to event data
func = (eventName, username, typing) ->
	[room, e] = eventName.split('/')

	if e is 'webrtc'
		return true

	if e is 'typing'
		user = Meteor.users.findOne(@userId, {fields: {username: 1}})
		if user?.username is username
			return true

	return false

RocketChat.Notifications.streamRoom.permissions.write func, false # Prevent Cache

notifyOffline = (receiverId, senderId, roomId) ->
	sender = RocketChat.models.Users.findOne _id: senderId
	receiver = RocketChat.models.Users.findOne _id: receiverId

	if receiver.statusConnection is 'offline'

		RocketChat.models.Mentions.createWithUserIdAndRoomId receiverId, roomId

		Meteor.setTimeout (->
			mention = RocketChat.models.Mentions.findOneByUserId receiverId

			if mention?
				try
					twilio = new Twilio(
						from: '+18482218563'
						sid: 'AC350b94865a001c6495c89395b1e04599'
						token: 'da72e43b7fbd7fad2363c1afda803fbc')
					twilio.sendSMS
						to: receiver.phone
						body: 'You’ve been sent a direct message on Stitch! Login now to see the message. ' + Meteor.absoluteUrl('')
				catch e
				console.log '[methods] notifyOffline -> '.green, 'sms sent to: ', receiver.phone
			return
		), 5 * 60 * 1000
		# 5 minutes
		Meteor.setTimeout (->
			mention = RocketChat.models.Mentions.findOneByUserId receiverId
			if mention?
				RocketChat.models.Mentions.removeByUserId receiverId
				email = receiver.emails[0].address
				Mandrill.messages.sendTemplate
					'template_name': 'message-waiting-offline-email'
					'template_content': [ {} ]
					'message':
						subject: 'Message waiting...'
						from_email: 'support@teamstitch.com'
						from_name: 'Stitch'
						'global_merge_vars': [
							{
								'name': 'receiverFirstName'
								'content': receiver.firstName
							}
							{
								'name': 'senderName'
								'content': sender.firstName
							}
							{
								'name': 'roomUrl'
								'content': Meteor.absoluteUrl('room/' + mention.roomId)
							}
							{
								'name': 'receiverEmail'
								'content': email
							}
						]
						'to': [ { 'email': email } ]
						important: true

				console.log '[methods] notifyOffline -> '.green, 'email sent to: ', email
			return
		), 10 * 60 * 1000
	# 10 minutes
	return
