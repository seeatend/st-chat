Template.privateGroupsModal.helpers
	selectedUsers: ->
		return Template.instance().selectedUsers.get()

	name: ->
		return Template.instance().selectedUserNames[this.valueOf()]

	groupName: ->
		return Template.instance().groupName.get()

	error: ->
		return Template.instance().error.get()

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
							{ _id: { $ne: Meteor.userId() } }
							{ username: { $nin: Template.instance().selectedUsers.get() } }
							{ active: { $eq: true } }
							{ organizationId: { $eq: Meteor.user().organizationId } }
						]
					sort: 'username'
				}
			]
		}

Template.privateGroupsModal.events
	'autocompleteselect #pvt-group-members': (event, instance, doc) ->
		instance.selectedUsers.set instance.selectedUsers.get().concat doc.username

		instance.selectedUserNames[doc.username] = doc.name

		setTimeout ->
			event.currentTarget.value = ''
			event.currentTarget.focus()
		, 10

	'click .remove-room-member': (e, instance) ->
		self = @
		users = Template.instance().selectedUsers.get()
		users = _.reject Template.instance().selectedUsers.get(), (_id) ->
			return _id is self.valueOf()

		Template.instance().selectedUsers.set(users)

	'click .close-modal': (e, instance) ->
		e.preventDefault()
		instance.clearForm()
		Modal.close()

	'click header': (e, instance) ->
		SideNav.closeFlex ->
			instance.clearForm()

	'mouseenter header': ->
		SideNav.overArrow()

	'mouseleave header': ->
		SideNav.leaveArrow()

	'keydown input#pvt-group-name' : (e) ->
		e.target.value = e.target.value.trim();

	'keydown input[type="text"]': (e, instance) ->
		Template.instance().error.set([])

	'focus #pvt-group-members': ->
		unless $('#pvt-group-members').val()
			$('#pvt-group-members').val(' ')

	'click .save-pvt-group': (e, instance) ->
		e.preventDefault()
		err = SideNav.validate()
		name = instance.find('#pvt-group-name').value.toLowerCase().trim()
		instance.groupName.set name
		if not err
			Meteor.call 'createPrivateGroup', name, instance.selectedUsers.get(), (err, result) ->
				if err
					if err.error is 'name-invalid'
						instance.error.set({ invalid: true })
						return
					if err.error is 'duplicate-name'
						instance.error.set({ duplicate: true, message: err.reason })
						return
					if err.error is 'archived-duplicate-name'
						instance.error.set({ archivedduplicate: true })
						return
					return toastr.error err.reason
				instance.clearForm()
				Modal.close()
				FlowRouter.go 'group', { name: name }
		else
			Template.instance().error.set({fields: err})

Template.privateGroupsModal.onCreated ->
	instance = this
	instance.selectedUsers = new ReactiveVar []
	instance.selectedUserNames = {}
	instance.error = new ReactiveVar []
	instance.groupName = new ReactiveVar ''

	instance.clearForm = ->
		instance.error.set([])
		instance.groupName.set('')
		instance.selectedUsers.set([])
		instance.find('#pvt-group-name').value = ''
		instance.find('#pvt-group-members').value = ''
