Meteor.methods
	saveUserProfile: (settings) ->
		# unless RocketChat.settings.get("Accounts_AllowUserProfileChange")
		# 	throw new Meteor.Error(403, "[methods] resetAvatar -> Invalid access")

		if Meteor.userId()
			if settings.language?
				RocketChat.models.Users.setLanguage Meteor.userId(), settings.language

			# if settings.password?
			# 	Accounts.setPassword Meteor.userId(), settings.password, { logout: false }

			firstName = RocketChat.services.capitalizeFirstLetter settings.firstName
			lastName = RocketChat.services.capitalizeFirstLetter settings.lastName

			displayDegree = ''
			if settings.degree is 'Other'
				settings.otherDegree = RocketChat.services.capitalizeFirstLetter settings.otherDegree
				displayDegree = settings.otherDegree
			else
				displayDegree = settings.degree

			displayName = firstName + ' ' + lastName + ' (' + displayDegree + ')'

			profile = {
				firstName: firstName
				lastName: lastName
				displayName: displayName
				degree: settings.degree
				otherDegree: RocketChat.services.capitalizeFirstLetter settings.otherDegree
				mobilePhone: settings.mobilePhone
				notificationsEnabled: settings.notificationsEnabled
			}

			RocketChat.models.Users.setProfile Meteor.userId(), profile
			RocketChat.models.Messages.updateAllDisplayNamesByUserId Meteor.userId(), displayName
			RocketChat.models.Subscriptions.updateAllNamesByUserId Meteor.userId(), settings.firstName + ' ' + settings.lastName
			RocketChat.models.Subscriptions.updateAllReceiverNamesByUsername Meteor.user().username, settings.firstName + ' ' + settings.lastName

			return true
