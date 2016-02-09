Meteor.methods
	sendConfirmationEmail: (email) ->
		user = RocketChat.models.Users.findOneByEmailAddress email

		if user?
			Mandrill.messages.sendTemplate({
				"template_name": "sign-up-1-authenticate",
				"template_content": [{}],
				"message": {
					subject: 'Invitation to Stitch',
					from_email: 'support@teamstitch.com',
					from_name: 'Stitch',
					"global_merge_vars": [
						{
							"name": "confirmAccountUrl",
							"content": Meteor.absoluteUrl('verify/' + user.uuid)
						}
					],
					"to": [{"email": email}],
					important: true
				}
			});
			return true
		return false
