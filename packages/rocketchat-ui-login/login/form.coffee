Template.loginForm.helpers
	userName: ->
		return Meteor.user()?.username

	showMobileVerification: ->
		return 'hidden' unless Template.instance().state.get() is 'mobile-verification'

	showName: ->
		return 'hidden' unless Template.instance().state.get() is 'register2'

	showDegree: ->
		return 'hidden' unless Template.instance().state.get() is 'register2'

	showPhone: ->
		return 'hidden' unless Template.instance().state.get() is 'register2'

	showOrganizationName: ->
		return 'hidden' unless (Template.instance().state.get() is 'register2' && !Session.get('OrganizationId'))

	showUsername: ->
		return 'hidden' unless (Template.instance().state.get() is 'register2' && Session.get('isUsernameDuplicate'))

	showPassword: ->
		return 'hidden' unless Template.instance().state.get() in ['login', 'register2', 'reset-password']

	passwordErrors: ->
		unless (Template.instance().state.get() in ['register2', 'reset-password']) and Template.instance().passwordErrors.get()?.length > 0
			return false
		else
			return Template.instance().passwordErrors.get()

	showConfirmPassword: ->
		return 'hidden' unless Template.instance().state.get() in ['register2', 'reset-password']

	showEmailOrUsername: ->
		return 'hidden' unless Template.instance().state.get() is 'login'

	showEmail: ->
		return 'hidden' unless Template.instance().state.get() in ['register1', 'forgot-password', 'email-verification']

	showNextButton: ->
		return 'hidden' unless Template.instance().state.get() is 'register1'

	showSubmitButton: ->
		return 'hidden' if Template.instance().state.get() is 'register1'

	showRegisterLink: ->
		return 'hidden' unless Template.instance().state.get() is 'login'

	showForgotPasswordLink: ->
		return 'hidden' unless Template.instance().state.get() is 'login'

	showBackToLoginLink: ->
		return 'hidden' unless Template.instance().state.get() in ['register1', 'register2', 'forgot-password', 'email-verification', 'wait-activation']

	btnLoginSave: ->
		switch Template.instance().state.get()
			when 'register2'
				return t('Submit')
			when 'login'
				# if RocketChat.settings.get('LDAP_Enable')
				# 	return t('Login') + ' (LDAP)'
				return t('Login')
			when 'email-verification'
				return t('Send_confirmation_email')
			when 'forgot-password'
				return t('Reset_password')
			when 'reset-password'
				return t('Reset_password')
			when 'mobile-verification'
				return 'Submit'

	waitActivation: ->
		return Template.instance().state.get() is 'wait-activation'

	loginTerms: ->
		return RocketChat.settings.get 'Layout_Login_Terms'

Template.loginForm.events
	'click .next': (event, instance) ->
		email = $('[name="email"]').val();
		domain = email.split('@')[1];

		if (!/[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:com|org|edu|sg|net|gov|mil|biz|info|io|mobi|name|aero|jobs|museum|uk)\b/i.test(email))
			toastr.error 'Please enter a valid email address'
		else if RocketChat.services.isDomainPublic(domain) and !FlowRouter.getParam('orgId')
			toastr.error 'Please use your work email address'
		else
			Meteor.call 'emailExists', email, (err, result) ->
				if result
					toastr.error t 'Email_already_exists'
				else
					getOrganizationId domain, (err, orgId) ->
						Session.set('OrganizationId', orgId);

						if orgId
							Meteor.call 'usernameExistsInOrg', email.split('@')[0], orgId, (err, result) ->
								Session.set('isUsernameDuplicate', result);
								instance.state.set 'register2'
						else
							Session.set('isUsernameDuplicate', false);
							instance.state.set 'register2'

	'submit #login-card': (event, instance) ->
		event.preventDefault()

		button = $(event.target).find('button.login')
		RocketChat.Button.loading(button)

		formData = instance.validate()
		if formData
			if instance.state.get() is 'email-verification'
				Meteor.call 'sendConfirmationEmail', formData.email, (err, result) ->
					RocketChat.Button.reset(button)
					toastr.success t('We_have_sent_registration_email')
					instance.state.set 'login'
				return

			if instance.state.get() is 'forgot-password'
				Meteor.call 'sendForgotPasswordEmail', formData.email, (err, result) ->
					RocketChat.Button.reset(button)
					if result
						toastr.success t('We_have_sent_password_email')
						instance.state.set 'login'
					else
						toastr.error 'Email doesn\'t exist'
				return

			if instance.state.get() is 'reset-password'
				Meteor.call 'resetUserPassword', FlowRouter.getParam('uuid'), $('[name="pass"]').val(), (err, result) ->
					RocketChat.Button.reset(button)
					toastr.success 'Password reset successfully'
					instance.state.set 'login'
					FlowRouter.go '/home'
				return

			if instance.state.get() is 'register2'
				if Session.get('OrganizationId')
					formData.orgId = Session.get('OrganizationId')

				Meteor.call 'registerUser', formData, Meteor.isCordova, (error, result) ->
					RocketChat.Button.reset(button)

					if error?
						console.log error
						toastr.error error.reason
						return

					orgName = Meteor.call 'findOrgNameById', formData.orgId
					if analytics?
						analytics.track('New user created',
							eventName: 'New user added to '+ orgName,
							userCount: Meteor.call 'findOrgUserCountById', formData.orgId
						)

					if Meteor.isCordova
						toastr.success 'Please enter verification code sent to you by SMS'
						Session.set('MobileVerificationEmail', result)
						instance.state.set 'mobile-verification'
					else
						Meteor.loginWithPassword formData.email, formData.pass, (error) ->
							if error?.error is 'no-valid-email'
								toastr.success t('We_have_sent_registration_email')
								instance.state.set 'login'
							else if error?.error is 'inactive-user'
								instance.state.set 'wait-activation'

			if instance.state.get() is 'mobile-verification'

				Meteor.call 'verifyUser', $('[name="mobileVerification"]').val(), Session.get('MobileVerificationEmail'), (error, result) ->
					if error
						return toastr.error error.reason
					Accounts.callLoginMethod
						methodArguments: [ { uuid: result } ]
						userCallback: ->
							Meteor.call 'joinDefaultChannels', ->
								FlowRouter.go '/home'
							return
					return


			if instance.state.get() is 'login'
				loginMethod = 'loginWithPassword'
				# if RocketChat.settings.get('LDAP_Enable')
				# 	loginMethod = 'loginWithLDAP'

				Meteor[loginMethod] formData.emailOrUsername, formData.pass, (error) ->
					RocketChat.Button.reset(button)
					if error?
						if error.error is 'no-valid-email'
							instance.state.set 'email-verification'
						else
							toastr.error t 'User_not_found_or_incorrect_password'
						return

	'click .register': ->
		Template.instance().state.set 'register1'

	'click .back-to-login': ->
		Template.instance().state.set 'login'

	'click .forgot-password': ->
		Template.instance().state.set 'forgot-password'

	'keyup #pass': ->
		updatePasswordErrors(Template.instance().passwordErrors, $('#pass').val())

Template.loginForm.onCreated ->
	instance = @

	@passwordErrors = new ReactiveVar('passwordErrors')
	@passwordErrors.set []

	if(FlowRouter.current().route.name is 'resetPassword')
		@state = new ReactiveVar('reset-password')
	else if(FlowRouter.current().route.name is 'register')
		@state = new ReactiveVar('register1')
	else
		@state = new ReactiveVar('login')

	@validate = ->
		formData = $("#login-card").serializeArray()
		formObj = {}
		validationObj = {}

		for field in formData
			formObj[field.name] = field.value

		unless instance.state.get() in ['login', 'reset-password']
			unless formObj['email'] and /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]+\b/i.test(formObj['email'])
				validationObj['email'] = t('Invalid_email')

		if instance.state.get() isnt 'forgot-password'
			unless formObj['pass']
				validationObj['pass'] = t('Invalid_pass')

		if instance.state.get() is 'login'
			unless formObj['emailOrUsername'] and /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]+\b/i.test(formObj['emailOrUsername'])
				validationObj['emailOrUsername'] = 'Invalid email'

		if instance.state.get() in ['register2', 'reset-password']
			updatePasswordErrors(instance.passwordErrors, formObj['pass'])
			unless /(?=.*[A-Z])(?=.*[~!@#$%^*&;?.+_])(?=.*[0-9])(?=.*[a-z]).{8,}/g.test(formObj['pass'])
				validationObj['pass'] = t('Invalid_pass')
			if formObj['confirm-pass'] isnt formObj['pass']
				validationObj['confirm-pass'] = t('Invalid_confirm_pass')

		if instance.state.get() is 'register2'
			unless formObj['degree']
				toastr.error 'You must select a degree'
				validationObj['degree'] = 'Invalid Degree'
			if formObj['degree'] and formObj['degree'] is 'Other'
				unless formObj['otherDegree']
					validationObj['otherDegree'] = 'Invalid Degree'
			unless formObj['firstName']
				validationObj['firstName'] = 'Invalid first name'
			unless formObj['lastName']
				validationObj['lastName'] = 'Invalid Last name'
			unless formObj['mobilePhone']
				validationObj['mobilePhone'] = 'Invalid mobile phone no.'
			unless Session.get('OrganizationId') || formObj['orgName']
				validationObj['orgName'] = 'Invalid organization name'
			unless !Session.get('isUsernameDuplicate') || /^[a-zA-Z0-9]+$/.test(formObj['username'])
				validationObj['username'] = 'Invalid username'

		$("#login-card input").removeClass "error"
		unless _.isEmpty validationObj
			button = $('#login-card').find('button.login')
			RocketChat.Button.reset(button)
			$("#login-card h2").addClass "error"
			for key of validationObj
				$("#login-card input[name=#{key}]").addClass "error"
			return false

		$("#login-card h2").removeClass "error"
		$("#login-card input.error").removeClass "error"
		return formObj

Template.loginForm.onRendered ->
	Tracker.autorun =>
		switch this.state.get()
			when 'login', 'forgot-password', 'email-verification'
				Meteor.defer ->
					$('input[name=email]').select().focus()

			when 'register'
				Meteor.defer ->
					$('input[name=name]').select().focus()

getOrganizationId = (domain, cb) ->
	if FlowRouter.getParam('orgId')?
		cb null, FlowRouter.getParam('orgId')
	else
		Meteor.call 'findOrgIdByDomain', domain, (err, orgId) ->
			cb err, orgId

updatePasswordErrors = (reactiveVar, password) ->
	passwordErrors = []
	if /.{8,}/g.test(password)
		passwordErrors.push({text: 'At least 8 characters', color: 'green'})
	else
		passwordErrors.push({text: 'At least 8 characters', color: 'red'})

	if /(?=.*[A-Z])/g.test(password)
		passwordErrors.push({text: 'An uppercase letter', color: 'green'})
	else
		passwordErrors.push({text: 'An uppercase letter', color: 'red'})

	if /(?=.*[a-z])/g.test(password)
		passwordErrors.push({text: 'A lowercase letter', color: 'green'})
	else
		passwordErrors.push({text: 'A lowercase letter', color: 'red'})

	if /(?=.*[0-9])/g.test(password)
		passwordErrors.push({text: 'A number', color: 'green'})
	else
		passwordErrors.push({text: 'A number', color: 'red'})

	if /(?=.*[~!@#$%^*&;?.+_])/g.test(password)
		passwordErrors.push({text: 'A special character (e.g. !$#)', color: 'green'})
	else
		passwordErrors.push({text: 'A special character (e.g. !$#)', color: 'red'})

	reactiveVar.set(passwordErrors)
