FlowRouter.route '/room/:rid',
	name: 'room'

	action: (params, queryParams) ->
		if not Meteor.userId()
			Session.set('RedirectToRoom', params.rid)
			return FlowRouter.go 'home'

		Tracker.autorun (c) ->
			if FlowRouter.subsReady() is true
				Meteor.defer ->
					FlowRouter.goToRoomById params.rid
				c.stop()

FlowRouter.goToRoomById = (roomId) ->
	subscription = ChatSubscription.findOne({'u._id': Meteor.userId(), rid: roomId})
	if subscription?
		FlowRouter.go RocketChat.roomTypes.getRouteLink subscription.t, subscription
