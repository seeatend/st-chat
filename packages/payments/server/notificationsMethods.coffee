Meteor.methods
	'sendOrgReachFreeLimit': ( userId ) ->
		user = RocketChat.models.Users.findOneById userId
		org = RocketChat.models.Organizations.findOneByadminId userId
		email = user?.emails[0]?.address
		if user?
			Mandrill.messages.sendTemplate
				"template_name": "organization-reach-free-limit",
				"template_content": [{}],
				"message": {
					subject: 'Your organization reach free limit',
					from_email: 'support@teamstitch.com',
					from_name: 'Stitch',
					"global_merge_vars": [
						{
							'name': 'receiverFirstName'
							'content': user.firstName
						}
						{
							'name': 'orgName'
							'content': org.name
						}
						{
							'name': 'loginUrl'
							'content': Meteor.absoluteUrl()
						}
						{
							'name': 'receiverEmail'
							'content': email
						}
					],
					"to": [{"email": email}],
					important: true
				}

	'sendWelcometoPremiumPlan': ( userId ) ->
		user = RocketChat.models.Users.findOneById userId
		org = RocketChat.models.Organizations.findOneByadminId userId
		email = user?.emails[0]?.address

		if user?
			Mandrill.messages.sendTemplate
				"template_name": "payment-organization-welcome-to-premium-plan",
				"template_content": [{}],
				"message": {
					subject: 'Welcome to stitch Premium',
					from_email: 'support@teamstitch.com',
					from_name: 'Stitch',
					"global_merge_vars": [
						{
							'name': 'receiverFirstName'
							'content': user.firstName
						}
						{
							'name': 'orgName'
							'content': org.name
						}
						{
							'name': 'loginUrl'
							'content': Meteor.absoluteUrl()
						}
						{
							'name': 'receiverEmail'
							'content': email
						}
					],
					"to": [{"email": email}],
					important: true
				}
	'sendAddNewUserMessage': ( params ) ->

	'sendDeleteUserMessage': ( params ) ->

	'sendFirstInvoice': ( userId ) -> # XXX do we need this ?
		user = RocketChat.models.Users.findOneById userId
		org = RocketChat.models.Organizations.findOneByadminId userId
		email = user?.emails[0]?.address
		invoice = PaymentHistory.findOne({userId:userId}, {sort: { createdAt: -1}})

		if user?
			Mandrill.messages.sendTemplate
				"template_name": "payment-organization-monthly-invoice",
				"template_content": [{}],
				"message": {
					subject: 'Monthly Invoice',
					from_email: 'support@teamstitch.com',
					from_name: 'Stitch',
					"global_merge_vars": [
						{
							'name': 'receiverFirstName'
							'content': user.firstName
						}
						{
							'name': 'orgName'
							'content': org.name
						}
						{
							'name': 'monthlySubAmount'
							'content': invoice.amount
						}
						{
							'name': 'orgUserCount'
							'content': org.userCount
						}
						{
							'name': 'receiverEmail'
							'content': email
						}
					],
					"to": [{"email": email}],
					important: true
				}
	'sendMonthlyInvoice': ( userId ) ->
		user = RocketChat.models.Users.findOneById userId
		org = RocketChat.models.Organizations.findOneByadminId userId
		email = user?.emails[0]?.address
		invoice = PaymentHistory.findOne({userId:userId}, {sort: { createdAt: -1}})

		if user?
			Mandrill.messages.sendTemplate
				"template_name": "payment-organization-monthly-invoice",
				"template_content": [{}],
				"message": {
					subject: 'Monthly Invoice',
					from_email: 'support@teamstitch.com',
					from_name: 'Stitch',
					"global_merge_vars": [
						{
							'name': 'receiverFirstName'
							'content': user.firstName
						}
						{
							'name': 'orgName'
							'content': org.name
						}
						{
							'name': 'orgUserCount'
							'content': org.userCount
						}
						{
							'name': 'monthlySubAmount'
							'content': invoice.amount
						}
						{
							'name': 'receiverEmail'
							'content': email
						}
					],
					"to": [{"email": email}],
					important: true
				}

	'sendUpgradeInvoice': ( params ) ->

	'sendDowngradeInvoice': ( params ) ->

	'sendPaymentFails': ( params ) ->

	'sendCancelSubscription': ( params ) ->
