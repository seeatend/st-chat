Meteor.methods
	sendInvitationEmail: (emails) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] sendInvitationEmail -> Invalid user"

		org = RocketChat.models.Organizations.findOneById Meteor.user().organizationId

		for email in emails
			user = Meteor.users.findOne('emails.address': email)
			if user
				throw new Meteor.Error '[methods] sendInvitationEmail -> user exists', 'A user having the email: ' + email + ' already exists'

		for email in emails

			invitationUrl = Meteor.absoluteUrl('register')

			if RocketChat.services.isDomainPublic(email.split('@')[1])
				invitationUrl = invitationUrl + '/' + org._id

			Mandrill.messages.sendTemplate({
				"template_name": "introduction-to-stitch",
				"template_content": [{}],
				"message": {
					subject: 'Invitation to Stitch',
					from_email: 'support@teamstitch.com',
					from_name: 'Stitch',
					"global_merge_vars": [
						{
							"name": "orgName",
							"content": org.name
						},
						{
							"name": "invitationUrl",
							"content": invitationUrl
						}
					],
					"to": [{"email": email}],
					important: true
				}
			});


		return emails
