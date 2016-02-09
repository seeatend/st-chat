# Deny Account.createUser in client
accountsConfig = { forbidClientAccountCreation: true }

if RocketChat.settings.get('Account_AllowedDomainsList')
	domainWhiteList = _.map RocketChat.settings.get('Account_AllowedDomainsList').split(','), (domain) -> domain.trim()
	accountsConfig.restrictCreationByEmailDomain = (email) ->
		ret = false
		for domain in domainWhiteList
			if email.match(domain + '$')
				ret = true
				break;

		return ret

Accounts.config accountsConfig

Accounts.emailTemplates.siteName = RocketChat.settings.get 'Site_Name';
Accounts.emailTemplates.from = "#{RocketChat.settings.get 'Site_Name'} <#{RocketChat.settings.get 'From_Email'}>";

verifyEmailText = Accounts.emailTemplates.verifyEmail.text
Accounts.emailTemplates.verifyEmail.text = (user, url) ->
	url = url.replace Meteor.absoluteUrl(), Meteor.absoluteUrl() + 'login/'
	verifyEmailText user, url

resetPasswordText = Accounts.emailTemplates.resetPassword.text
Accounts.emailTemplates.resetPassword.text = (user, url) ->
	url = url.replace Meteor.absoluteUrl(), Meteor.absoluteUrl() + 'login/'
	resetPasswordText user, url

Accounts.onCreateUser (options, user) ->
	# console.log 'onCreateUser ->',JSON.stringify arguments, null, '  '
	# console.log 'options ->',JSON.stringify options, null, '  '
	# console.log 'user ->',JSON.stringify user, null, '  '

	RocketChat.callbacks.run 'beforeCreateUser', options, user

	user.status = 'offline'
	user.active = not RocketChat.settings.get 'Accounts_ManuallyApproveNewUsers'

	if not user?.name? or user.name is ''
		if options.profile?.name?
			user.name = options.profile?.name

	if user.services?
		for serviceName, service of user.services
			if not user?.name? or user.name is ''
				if service.name?
					user.name = service.name
				else if service.username?
					user.name = service.username

			if not user.emails? and service.email?
				user.emails = [
					address: service.email
					verified: true
				]

	return user

# Wrap insertUserDoc to allow executing code after Accounts.insertUserDoc is run
Accounts.insertUserDoc = _.wrap Accounts.insertUserDoc, (insertUserDoc, options, user) ->
	roles = []
	if Match.test(user.globalRoles, [String]) and user.globalRoles.length > 0
		roles = roles.concat user.globalRoles

	delete user.globalRoles

	_id = insertUserDoc.call(Accounts, options, user)

	if roles.length is 0
		# when inserting first user give them admin privileges otherwise make a regular user
		firstUser = RocketChat.models.Users.findOne({ _id: { $ne: 'rocket.cat' }}, { sort: { createdAt: 1 }})
		if firstUser?._id is _id
			roles.push 'admin'
		else
			roles.push 'user'

	RocketChat.authz.addUsersToRoles(_id, roles)

	RocketChat.callbacks.run 'afterCreateUser', options, user
	return _id

Accounts.validateLoginAttempt (login) ->
	login = RocketChat.callbacks.run 'beforeValidateLogin', login

	if login.allowed isnt true
		return login.allowed

	if login.user?.active isnt true
		throw new Meteor.Error 'inactive-user', TAPi18n.__ 'User_is_not_activated'
		return false

	validEmail = login.user.emails.filter (email) ->
		return email.verified is true

	if validEmail.length is 0
		throw new Meteor.Error 'no-valid-email'
		return false

	RocketChat.models.Users.updateLastLoginById login.user._id
	RocketChat.models.Mentions.removeByUserId login.user._id
	Meteor.defer ->
		RocketChat.callbacks.run 'afterValidateLogin', login
		#nalytics.track('user login')

	return true

# Handle login of user via uuid > confirmation email link
Accounts.registerLoginHandler (options) ->
	userId = null
	if options.userId
		userId = options.userId
	else if options.uuid
		if !Meteor.users.findOne(uuid: options.uuid)
			return undefined
		user = Meteor.users.findOne(uuid: options.uuid)

		org = RocketChat.models.Organizations.findOneById user.organizationId

		# send welcome/invite message
		Mandrill.messages.sendTemplate
			'template_name': 'sign-up-2-confirmation'
			'template_content': [ {} ]
			'message':
				subject: 'Welcome on board!'
				from_email: 'support@teamstitch.com'
				from_name: 'Stitch'
				'global_merge_vars': [ {
					'name': 'organizationName'
					'content': org.name
				} ]
				'to': [ { 'email': user.emails[0].address } ]
				important: true
		userId = user._id

	return { userId: userId }
