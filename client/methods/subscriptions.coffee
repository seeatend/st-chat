Meteor.methods
	updateSubscriptionNotifications: (rid, notifications) ->
		if not Meteor.userId()
			throw new Meteor.Error 203, t('User_logged_out')

		ChatSubscription.update
			rid: rid
			'u._id': Meteor.userId()
		,
			$set:
				notifications: notifications
