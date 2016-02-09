Template.listPatientsModal.helpers
	channel: ->
		return Session.get 'patientsList'

Template.listPatientsModal.events
	'click header': ->
		SideNav.closeFlex()

	'click .close-modal': (e) ->
		e.preventDefault()
		Modal.close()

	'click .channel-link': ->
		Modal.close()

	'click footer .create': ->
		if RocketChat.authz.hasAtLeastOnePermission('create-c')
			SideNav.setFlex "createPatientFlex"

	'mouseenter header': ->
		SideNav.overArrow()

	'mouseleave header': ->
		SideNav.leaveArrow()

Template.listPatientsModal.onCreated ->
	instance = this
	instance.channelsList = new ReactiveVar []

	Meteor.call 'patientsList', (err, result) ->
		if result
			Session.set 'patientsList', result.channels
