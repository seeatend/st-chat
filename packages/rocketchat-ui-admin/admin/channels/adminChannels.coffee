Template.adminChannels.helpers
	isReady: ->
		return Template.instance().ready?.get()
	privateChannels: ->
		ChatRoom.find {t: 'p'}
	publicChannels: ->
		ChatRoom.find {t: 'c'}
	editingChannelName: ->
		return Session.get('editChannelName')
	flexOpened: ->
		return 'opened' if RocketChat.TabBar.isFlexOpen()
	flexTemplate: ->
		return RocketChat.TabBar.getTemplate()
	flexData: ->
		return RocketChat.TabBar.getData()
	adminClass: ->
		return 'admin' if RocketChat.authz.hasRole(Meteor.userId(), 'admin')

Template.adminChannels.onCreated ->
	instance = @
	@autorun ->
		instance.subscribe 'adminGroups'

Template.adminChannels.onRendered ->
	Tracker.afterFlush ->
		SideNav.setFlex "adminFlex"
		SideNav.openFlex()

Template.adminChannel.helpers
	editingChannelName: ->
		return this._id is Session.get('editChannel')

Template.adminChannel.events
	'click .edit-channel-name': ->
		Session.set('editChannel', this._id)
		Meteor.setTimeout ->
			$('#channel-name-field').focus().select()
		, 10

	'click .delete-channel': ->
		channelId = this._id
		channelName = this.name
		channelType = this.t
		swal {
			title: 'Delete ' + channelName + '?'
			text: 'This will delete all of the messages in this group. Are you sure?'
			html: false
			type: 'warning'
			showCancelButton: true
			closeOnConfirm: false
			confirmButtonText: 'Delete ' + channelName
			confirmButtonColor: '#ec6c62'
		}, ->
			RoomManager.close channelType + channelName
			Meteor.call 'deleteRoom', channelId, (error, result) ->
				if error
					swal
						title: 'Yikes! Something went wrong'
						text: error.reason
						type: 'error'
				else
					swal
						title: 'Group deleted!'
						text: 'The <strong>' + channelName + '</strong> ' + 'group is gone forever!'
						type: 'success'
						html: true

	'click .save-channel-name': ->
		Meteor.call 'saveRoomName', this._id, $('#channel-name-field').val(), (error, result) ->
			if result
				toastr.success 'Group name changed successfully'
			if error
				if error.error is 'duplicate-name'
					toastr.error 'Another group with the same name already exists'
				else
					toastr.error 'An error has occured'

			Session.set('editChannel', null)
