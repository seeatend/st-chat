if RocketChat.settings.get('Payment_Enabled')
	Stripe = StripeAPI(RocketChat.settings.get('Stripe_SecretKey') or process.env.STRIPE_PRIVATE_KEY)

	@SERVER_TOKEN = Random.secret()