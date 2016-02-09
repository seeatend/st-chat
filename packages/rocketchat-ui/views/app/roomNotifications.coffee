Template.roomNotifications.helpers
	notifications: ->
		subscription = ChatSubscription.findOne { 'u._id': Meteor.userId(), rid: this.roomId }
		return subscription.notifications

Template.roomNotifications.events
	'click #roomNotificationsSubmit': (e) ->
		e.preventDefault()

		notifications = {}
		notifications.desktop = $("[name=desktop-notifications]:checked").val()
		notifications.mobile = $("[name=mobile-notifications]:checked").val()
		notifications.muteAll = $('#muteNotifications').prop('checked')

		Meteor.call 'updateSubscriptionNotifications', this.roomId, notifications, (error, result) ->
			if result
				toastr.success 'Notification settings updated'
			if error
				toastr.error error.reason
			Modal.close()
