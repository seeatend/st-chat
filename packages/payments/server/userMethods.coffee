Meteor.methods
	'getCustomerId': ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] getCustomerId -> Invalid user"
		results = Meteor.user()?.customerId
		return results

	'getSubscriptionId': ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] getSubscriptionId -> Invalid user"
		results = Meteor.user()?.subscriptionId
		return results

	'getUserCard': ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] getUserCard -> Invalid user"
		results = Meteor.user()?.subscription?.payment?.card
		return results

	'updateUserPlan': ( update ) ->
		check update,
			token: String
			user: String
			plan: String
			status: String
			date: Number

		if update.token == SERVER_TOKEN

			Meteor.users.update update.user, { $set:
				'subscription.plan.name': update.plan
				'subscription.ends': update.date
				'subscription.payment.nextPaymentDue': update.date
				'subscription.status': update.status }, ( error ) ->
				if error
					console.log error
		else
			throw new Meteor.Error('invalid-auth-token', 'Sorry, your server authentication token is invalid.')

	'getUserCard': ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] getUserCard -> Invalid user"
		results = Meteor.user()?.subscription?.payment?.card
		return results