Meteor.methods
	channelsList: ->
		orgId = Meteor.user().organizationId;

		query =
			t: 'c'
			organizationId: orgId
			name:
				$ne: 'general'
		channels = RocketChat.models.Rooms.find(query, { sort: { msgs:-1 } }).fetch()
		general = RocketChat.models.Rooms.findOne {name: 'general', organizationId: orgId}
		channels.unshift(general)

		return { channels: channels }

	joinedChannels: ->
		orgId = Meteor.user().organizationId;

		query =
			t: 'c'
			organizationId: orgId
			usernames: Meteor.user().username
		channels = RocketChat.models.Rooms.find(query, { sort: { name:-1 } }).fetch()
		return { channels: channels }

	canJoinChannels: ->
		orgId = Meteor.user().organizationId;

		query =
			t: 'c'
			organizationId: orgId
			usernames:
				$ne: Meteor.user().username
		channels = RocketChat.models.Rooms.find(query, { sort: { name:-1 } }).fetch()
		return { channels: channels }
