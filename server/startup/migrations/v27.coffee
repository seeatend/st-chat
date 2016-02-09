Meteor.startup ->
	Migrations.add
		version: 27
		up: ->
			orgs = RocketChat.models.Organizations.find()
			orgs.forEach (org) ->
				# set hasActiveSubscription: false and plan: free for all orgs
					RocketChat.models.Organizations.update(org._id, $set:
						hasActiveSubscription: false
						plan: 'free'
					)
					orgUsers = RocketChat.models.Users.find({organizationId: org._id}, {fields: {_id: 1, createdAt: 1}}).fetch()
					userIds = _.pluck(orgUsers, '_id')
					admin = RocketChat.models.Users.findOne({organizationId: org._id}, {sort: { createdAt: 1}})

					#Find first admin user and give him the require role for billing 'billing-admin'
					if admin
						if RocketChat.authz.hasRole(admin._id, 'admin')
							RocketChat.authz.addUsersToRoles(admin._id, 'billing-admin')

						#Add all userIds org record as array
						RocketChat.models.Organizations.update(org._id, $set:
						 	adminId : admin._id
						 	userIds : userIds
						 	userCount: userIds.length
						)

			console.log '[End Migrations to ver 27]: Setup payment system'.green