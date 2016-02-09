Template.patientChannels.helpers
	tRoomMembers: ->
		return t('Members_placeholder')

	isActive: ->
		return 'active' if ChatSubscription.findOne({ 'u._id': Meteor.userId(), t: { $in: ['t']}, f: { $ne: true }, open: true, rid: Session.get('openedRoom') }, { fields: { _id: 1 } })?

	rooms: ->
		query =
			name: { $ne: 'general'},
			t: { $in: ['t']},
			open: true,
			'u._id': Meteor.userId()

		if !RocketChat.settings.get 'Disable_Favorite_Rooms'
			query.f = { $ne: true }

		if Meteor.user()?.settings?.preferences?.unreadRoomsMode
			query.alert =
				$ne: true

		channels = ChatSubscription.find(query, { sort: 't': 1, 'name': 1 }).fetch()
		return channels

Template.patientChannels.events
	'click .add-room': (e, instance) ->
		if RocketChat.authz.hasAtLeastOnePermission('create-c')
			Modal.init($('#createPatientModal'))
			Modal.open()
		else
			e.preventDefault()

	'click .more-patients': ->
		Modal.init($('#listPatientsModal'))
		Modal.open()
