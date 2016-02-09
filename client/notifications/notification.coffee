# Show notifications and play a sound for new messages.
# We trust the server to only send notifications for interesting messages, e.g. direct messages or
# group messages in which the user is mentioned.

Meteor.startup ->
	RocketChat.Notifications.onUser 'notification', (notification) ->

		openedRoomId = undefined
		if FlowRouter.getRouteName() in ['channel', 'group', 'direct', 'patient']
			openedRoomId = Session.get 'openedRoom'

		# This logic is duplicated in /client/startup/unread.coffee.
		hasFocus = readMessage.isEnable()
		messageIsInOpenedRoom = openedRoomId is notification.payload.rid

		if Meteor.user().notificationsEnabled and !(hasFocus and messageIsInOpenedRoom)
			# Play a sound.
			KonchatNotification.newMessage()

			# Show a notification.
			KonchatNotification.showDesktop notification
