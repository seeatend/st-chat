if Meteor.isClient is true
	@Organizations = Organizations = new Meteor.Collection 'rocketchat_organizations'
else
	Organizations = RocketChat.models.Organizations