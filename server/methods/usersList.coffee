Meteor.methods
	usersList: ->
		orgId = Meteor.user().organizationId;
		return { users: RocketChat.models.Users.find({
				_id: {$ne: this.userId},
				organizationId: orgId
		}).fetch()
    }
