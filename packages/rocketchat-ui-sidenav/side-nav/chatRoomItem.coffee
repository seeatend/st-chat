Template.chatRoomItem.helpers

	alert: ->
		if FlowRouter.getParam('_id') isnt this.rid or not document.hasFocus()
			return this.alert

	unread: ->
		if (FlowRouter.getParam('_id') isnt this.rid or not document.hasFocus()) and this.unread > 0
			return this.unread

	userStatus: ->
		return 'status-' + (Session.get('user_' + this.name + '_status') or 'offline') if this.t is 'd'
		return ''

	name: ->
		if this.t is 'd'
			this.receiverName
		else if this.t is 't'
			this.fullName
		else
			return this.name

	roomIcon: ->
		return RocketChat.roomTypes.getIcon this.t

	active: ->
		if Session.get('openedRoom') is this.rid
			return 'active'

	canHide: ->
		roomName = RoomManager.getRoomName(this.rid)
		return roomName isnt 'general'

	canLeave: ->
		roomData = Session.get('roomData' + this.rid)

		return false unless roomData

		if (roomData.cl? and not roomData.cl) or roomData.t is 'd' or (roomData.usernames?.indexOf(Meteor.user().username) isnt -1 and roomData.usernames?.length is 1)
			return false
		else
			return true

	route: ->
		return RocketChat.roomTypes.getRouteLink @t, @

Template.chatRoomItem.rendered = ->
	if not (FlowRouter.getParam('_id')? and FlowRouter.getParam('_id') is this.data.rid) and not this.data.ls
		KonchatNotification.newRoom(this.data.rid)

	if navigator.userAgent.toLowerCase().indexOf('android') > -1 or navigator.userAgent.match(/(iPad|iPhone|iPod)/g) or Meteor.Device.isPhone()
		$('.opt').addClass "device_disable"
	else
		$('.opt').removeClass "device_disable"

Template.chatRoomItem.events

	'click .open-room': (e) ->
		menu.close()

	'click .hide-room': (e) ->
		e.stopPropagation()
		e.preventDefault()

		if FlowRouter.getRouteName() in ['channel', 'group', 'direct', 'patient'] and Session.get('openedRoom') is this.rid
			FlowRouter.go '/channel/general'

		Meteor.call 'hideRoom', this.rid

	'click .leave-room': (e) ->
		e.stopPropagation()
		e.preventDefault()

		if FlowRouter.getRouteName() in ['channel', 'group', 'direct', 'patient'] and Session.get('openedRoom') is this.rid
			FlowRouter.go '/channel/general'

		RoomManager.close this.rid

		Meteor.call 'leaveRoom', this.rid
