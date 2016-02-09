Template.createPatientModal.helpers
	selectedUsers: ->
		return Template.instance().selectedUsers.get()

	name: ->
		return Template.instance().selectedUserNames[this.valueOf()]

	error: ->
		return Template.instance().error.get()

	roomName: ->
		return Template.instance().roomName.get()

	roomMrn: ->
		return Template.instance().roomMrn.get()

	autocompleteSettings: ->
		return {
		limit: 10
# inputDelay: 300
		rules: [
			{
# @TODO maybe change this 'collection' and/or template
				collection: 'UserAndRoom'
				subscription: 'roomSearch'
				field: 'username'
				selector: (match) ->
					return {regexString: match}
				template: Template.userSearch
				noMatchTemplate: Template.userSearchEmpty
				matchAll: true
				filter:
					type: 'u'
					$and: [
						{_id: {$ne: Meteor.userId()}}
						{username: {$nin: Template.instance().selectedUsers.get()}}
						{active: {$eq: true}}
						{organizationId: {$eq: Meteor.user().organizationId}}
					]
				sort: 'username'
			}
		]
		}

Template.createPatientModal.events
	'autocompleteselect #patient-members': (event, instance, doc) ->
		instance.selectedUsers.set instance.selectedUsers.get().concat doc.username

		instance.selectedUserNames[doc.username] = doc.name

		setTimeout ->
			event.currentTarget.value = ''
			event.currentTarget.focus()
		, 10

	'click .remove-room-member': (e, instance) ->
		self = @

		users = _.reject Template.instance().selectedUsers.get(), (_id) ->
			return _id is self.valueOf()

		Template.instance().selectedUsers.set(users)

	'click header': (e, instance) ->
		instance.clearForm()

	'click .close-modal': (e, instance) ->
		e.preventDefault()
		instance.clearForm()
		Modal.close()

	'mouseenter header': ->
		SideNav.overArrow()

	'mouseleave header': ->
		SideNav.leaveArrow()

	'click footer .all': ->
		SideNav.setFlex "listPatientsFlex"

	'keydown input#channel-first-name': (e) ->
		e.target.value = e.target.value.trim();

	'keydown input#channel-last-name': (e) ->
		e.target.value = e.target.value.trim();

	'keydown input#channel-mrn': (e) ->
		e.target.value = e.target.value.trim();

	'keydown input[type="text"]': (e, instance) ->
		Template.instance().error.set([])

	'focus #patient-members': ->
		unless $('#patient-members').val()
			$('#patient-members').val(' ')

	'click .save-patient-channel': (e, instance) ->
		e.preventDefault()
		err = SideNav.validate()
		name = instance.find('#channel-first-name').value.toLowerCase().trim() + instance.find('#channel-last-name').value.toLowerCase().trim()
		fullName = instance.find('#channel-first-name').value.trim() + ' ' + instance.find('#channel-last-name').value.trim()
		mrn = instance.find('#channel-mrn').value.trim()

		instance.roomName.set name
		instance.roomMrn.set mrn
		if not err
			Meteor.call 'createPatient', {
				name: name,
				fullName: fullName,
				mrn: mrn
			}, instance.selectedUsers.get(), (err, result) ->
				if err
					console.log err
					if err.error is 'name-invalid'
						instance.error.set({invalid: true})
						return
					if err.error is 'duplicate-name'
						instance.error.set({duplicate: true})
						return
					if err.error is 'duplicate-mrn'
						instance.error.set({mrn: true})
						return
					else
						return toastr.error err.reason

				instance.clearForm()
				Modal.close()
				FlowRouter.go 'patient', {name: name}
		else
			console.log err
			instance.error.set({fields: err})

Template.createPatientModal.onCreated ->
	instance = this
	instance.selectedUsers = new ReactiveVar []
	instance.selectedUserNames = {}
	instance.error = new ReactiveVar []
	instance.roomName = new ReactiveVar ''
	instance.roomMrn = new ReactiveVar ''

	instance.clearForm = ->
		instance.error.set([])
		instance.roomName.set('')
		instance.roomMrn.set('')
		instance.selectedUsers.set([])
		instance.find('#channel-first-name').value = ''
		instance.find('#channel-last-name').value = ''
		instance.find('#channel-mrn').value = ''
		instance.find('#patient-members').value = ''
