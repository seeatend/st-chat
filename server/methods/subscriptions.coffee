Meteor.methods
	updateSubscriptionNotifications: (rid, notifications) ->
		if not Meteor.userId()
			throw new Meteor.Error 203, t('User_logged_out')

		RocketChat.models.Subscriptions.updateNotifications rid, Meteor.userId(), notifications
