Meteor.methods
	patientsList: ->
		orgId = Meteor.user().organizationId;

		query =
			t: 't'
			organizationId: orgId
		channels = RocketChat.models.Rooms.find(query, { sort: { msgs:-1 } }).fetch()

		return { channels: channels }
