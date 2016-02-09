Meteor.startup ->
	Stripe.setPublishableKey(RocketChat.settings.get('Stripe_PublishableKey'))