Template.needSubscription.onCreated ->
	self = this
	self.orgDetails = new ReactiveVar

	Meteor.call 'findOrgNameAndAdminEmailByDomain', FlowRouter.getParam('domain'), (error, result) ->
		self.orgDetails.set
			ready: true
			name: result.name
			email: result.email

Template.needSubscription.onDestroyed ->
  Template.instance().orgDetails.set()

Template.needSubscription.helpers
	orgDetails: () ->
    return Template.instance().orgDetails.get()