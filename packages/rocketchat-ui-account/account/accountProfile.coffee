Template.accountProfile.helpers
	languages: ->
		languages = TAPi18n.getLanguages()
		result = []
		for key, language of languages
			result.push _.extend(language, { key: key })
		return _.sortBy(result, 'key')

	userLanguage: (key) ->
		return (localStorage.getItem('userLanguage') or defaultUserLanguage())?.split('-').shift().toLowerCase() is key

	firstName: ->
		return Meteor.user().firstName

	lastName: ->
		return Meteor.user().lastName

	degree: ->
		return Meteor.user().degree

	otherDegree: ->
		return Meteor.user().otherDegree

	mobilePhone: ->
		return Meteor.user().mobilePhone

	username: ->
		return Meteor.user().username

	allowUsernameChange: ->
		return RocketChat.settings.get("Accounts_AllowUsernameChange")

	usernameChangeDisabled: ->
		return t('Username_Change_Disabled')

	allowPasswordChange: ->
		return RocketChat.settings.get("Accounts_AllowPasswordChange")

	passwordChangeDisabled: ->
		return t('Password_Change_Disabled')

Template.accountProfile.onCreated ->
	settingsTemplate = this.parentTemplate(3)
	settingsTemplate.child ?= []
	settingsTemplate.child.push this

	@clearForm = ->
		@find('#language').value = localStorage.getItem('userLanguage')
		@find('#oldPassword').value = ''
		@find('#password').value = ''
		@find('#username').value = ''

	@changePassword = (oldPassword, newPassword, callback) ->
		instance = @
		if not oldPassword and not newPassword
			return callback()

		else if !!oldPassword ^ !!newPassword
			toastr.warning t('Old_and_new_password_required')

		else if newPassword and oldPassword
			if !RocketChat.settings.get("Accounts_AllowPasswordChange")
				toastr.error t('Password_Change_Disabled')
				instance.clearForm()
				return
			Accounts.changePassword oldPassword, newPassword, (error) ->
				if error
					toastr.error t('Incorrect_Password')
				else
					return callback()

	@save = ->
		instance = @

		oldPassword = _.trim($('#oldPassword').val())
		newPassword = _.trim($('#password').val())

		instance.changePassword oldPassword, newPassword, ->
			data = {}
			reload = false
			selectedLanguage = $('#language').val()

			if localStorage.getItem('userLanguage') isnt selectedLanguage
				localStorage.setItem 'userLanguage', selectedLanguage
				data.language = selectedLanguage
				reload = true

			if _.trim $('#firstName').val()
				data.firstName = _.trim $('#firstName').val()
			else
				toastr.error 'Please enter a value for first name'
				return

			if _.trim $('#lastName').val()
				data.lastName = _.trim $('#lastName').val()
			else
				toastr.error 'Please enter a value for first name'
				return

			if _.trim $('#degree').val()
				data.degree = $('#degree').val()

				if data.degree is 'Other'
					if _.trim $('#otherDegree').val()
						data.otherDegree = _.trim $('#otherDegree').val()
					else
						toastr.error 'Please enter a value for degree'
						return
			else
				toastr.error 'Please select a value for degree'
				return

			if _.trim $('#mobilePhone').val()
				data.mobilePhone = _.trim $('#mobilePhone').val()
			else
				toastr.error 'Please enter a value for mobile phone no.'
				return

			if _.trim $('#username').val()
				if !RocketChat.settings.get("Accounts_AllowUsernameChange")
					toastr.error t('Username_Change_Disabled')
					instance.clearForm()
					return
				else
					data.username = _.trim $('#username').val()

			Meteor.call 'saveUserProfile', data, (error, results) ->
				if results
					toastr.success t('Profile_saved_successfully')
					instance.clearForm()
					if reload
						setTimeout ->
							Meteor._reload.reload()
						, 1000

				if error
					toastr.error error.reason

Template.accountProfile.onRendered ->
	Tracker.afterFlush ->
		# this should throw an error-template
		FlowRouter.go("home") if !RocketChat.settings.get("Accounts_AllowUserProfileChange")
		SideNav.setFlex "accountFlex"
		SideNav.openFlex()

Template.accountProfile.events
	'click .submit button': (e, t) ->
		t.save()
