RocketChat.models.Organizations = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'organizations'

	# INSERT
	createWithNameAndDomain: (name, domain, initCount) ->
		domains = null
		if domain?
			domains = [domain]
		else
			domains = []
		record =
			name: name
			domains: domains
			userCount: initCount
			hasActiveSubscription: false
			plan: 'free'

		record._id = @insert record
		return record

	# Find
	findOneByDomain: (domain) ->
		query =
			domains: domain

		return @findOne query

	findOneById: (_id) ->
		query =
			_id: _id

		return @findOne query

	findOneByadminId: (adminId) ->
		query =
			adminId: adminId

		return @findOne query

	# Update
	updateOrgUserCountById: (_id, inc=1) ->
		query =
			_id: _id

		update =
			$inc:
				userCount: inc

		return @update query, update

	setPlan: (_id, plan) ->
		query =
			_id: _id

		update =
			$set:
				plan: plan

		return @update query, update

	setAdmin: (_id, userId) ->
		query =
			_id: _id

		update =
			$set:
				adminId: userId

		return @update query, update

	addUserById: (_id, userId) ->
		query =
			_id: _id

		update =
			$addToSet:
				userIds: userId

		return @update query, update

	setNeedSubscription: (_id, flag) ->
		query =
			_id: _id

		update =
			$set:
				needSubscription: flag

		return @update query, update

	setHasActiveSubscription: (_id, flag , plan) ->
		query =
			_id: _id

		update =
			$set:
				hasActiveSubscription: flag
				plan: plan

		return @update query, update

	hidePremium: (_id) ->
		query =
			_id: _id

		update =
			$set:
				hidePremium: true

		return @update query, update

	editOrgName: (_id, name) ->
		query =
			_id: _id

		update =
			$set:
				'name': name

		@update query, update

		return @findOneById(_id)

	addDomainToOrg: (_id, domain) ->
		org = @findOneByDomain domain
		if org?
			throw new Meteor.Error 'Domain already exists'
		query =
			_id: _id

		update =
			$push:
				'domains': domain

		@update query, update

		return @findOneById(_id)

	removeDomainFromOrg: (_id, domain) ->
		query =
			_id: _id

		update =
			$pull:
				'domains': domain

		@update query, update

		return @findOneById(_id)
