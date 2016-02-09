Meteor.methods
	# Add organization
	'createTeam': (data) ->
		user = Meteor.users.findOne('emails.address': data.adminEmail)
		domain = data.adminEmail.split('@')[1]
		if !RocketChat.services.isDomainPublic domain
			throw new Meteor.Error 'You must enter an email with a public domain. e.g. gmail.com. To invite a user with ' +
				'a company specific email address, use the invite users form in the "Users" tab.'
		if user
			throw new Meteor.Error 'Email already exists'
		org = RocketChat.models.Organizations.createWithNameAndDomain(data.orgName, null, 0)
		RocketChat.models.Rooms.createWithNameTypeAndOrgId 'general', 'c', org._id,	default: true
		Mandrill.messages.sendTemplate({
			"template_name": "public-domain-email-admin-invite",
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
						"content": Meteor.absoluteUrl('register/' + org._id)
					}
				],
				"to": [{"email": data.adminEmail}],
				important: true
			}
		});
		return org

	'requestDomain': (data) ->
		user = Meteor.user()
		org = RocketChat.models.Organizations.findOneById(user.organizationId)
		Mandrill.messages.sendTemplate({
			"template_name": "domain-merge-request-form",
			"template_content": [{}],
			"message": {
				subject: 'Domain Merge Request',
				from_email: 'support@teamstitch.com',
				from_name: 'Stitch',
				"global_merge_vars": [
					{
						"name": "adminName",
						"content": user.name
					}, {
						"name": "orgName",
						"content": org.name
					}, {
						"name": "orgId",
						"content": org._id
					}, {
						"name": "domain",
						"content": data.requesterDomain
					}, {
						"name": "siteName",
						"content": data.requesterSiteName
					}, {
						"name": "siteUrl",
						"content": data.requesterSiteUrl
					}
				],
				"to": [{"email": 'support@teamstitch.com'}],
				important: true
			}
		});
		return org

	'editOrgName': (orgId, name) ->
		org = RocketChat.models.Organizations.editOrgName(orgId, name)
		return org

	'addDomainToOrg': (orgId, domain) ->
		org = RocketChat.models.Organizations.addDomainToOrg(orgId, domain)
		return org

	'removeDomainFromOrg': (orgId, domain) ->
		org = RocketChat.models.Organizations.removeDomainFromOrg(orgId, domain)
		return org

	'findOrgById': (orgId) ->
		domains = RocketChat.models.Organizations.findOneById(orgId)
		return domains

	'findOrgIdByDomain': (domain) ->
		org = RocketChat.models.Organizations.findOneByDomain domain
		if org
			return org._id
		else
			return null

	'findOrgNameById': (id) ->
		org = RocketChat.models.Organizations.findOneById id
		if org
			return org.name
		else
			return null

	'findOrgUserCountById': (id) ->
		org = RocketChat.models.Organizations.findOneById id
		if org
			return org.userCount
		else
			return null

	'updateOrgUserCountById': (id) ->
		console.log('update Org user count')

		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] toogleFavorite -> Invalid user")

		RocketChat.models.Organizations.updateOrgUserCountById id , 1

	'checkIfRegisterationAllowed': ( orgId ) ->
		org = RocketChat.models.Organizations.findOneById orgId
		
		if not org
			throw new Meteor.Error 'organization-doesnt-exist', "[methods] checkIfRegisterationAllowed -> organization doesn't exist"

		if org.needSubscription
			return false
		else
			return true

	'updateOrgNeedSubscriptionById': ( id, flag ) ->
		org = RocketChat.models.Organizations.findOneById id
		
		if not org
			throw new Meteor.Error 'organization-doesnt-exist', "[methods] updateOrgNeedSubscriptionById -> organization doesn't exist"

		RocketChat.models.Organizations.setNeedSubscription id , flag

	'updateOrgHasActiveSubscriptionById': ( id, flag, plan ) ->
		org = RocketChat.models.Organizations.findOneById id
		
		if not org
			throw new Meteor.Error 'organization-doesnt-exist', "[methods] updateOrgHasActiveSubscriptionById -> organization doesn't exist"

		RocketChat.models.Organizations.setHasActiveSubscription id , flag, plan

	'updateOrgHidePremiumById': ( id ) ->
		org = RocketChat.models.Organizations.findOneById id
		
		if not org
			throw new Meteor.Error 'organization-doesnt-exist', "[methods] updateOrgHidePremiumById -> organization doesn't exist"

		RocketChat.models.Organizations.hidePremium id