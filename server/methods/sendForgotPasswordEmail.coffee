Meteor.methods
	sendForgotPasswordEmail: (email) ->
		user = RocketChat.models.Users.findOneByEmailAddress email

		if user?
			Mandrill.messages.sendTemplate
				'template_name': 'password-reset'
				'template_content': [ {} ]
				'message':
					subject: 'Reset your password'
					from_email: 'support@teamstitch.com'
					from_name: 'Stitch'
					'global_merge_vars': [ {
						'name': 'receiverFirstName'
						'content': user.firstName
					}, {
						'name': 'resetPasswordUrl'
						'content': Meteor.absoluteUrl('reset/' + user.uuid)
					} ]
					'to': [ { 'email': user.emails[0].address } ]
					important: true
			return true
		return false
