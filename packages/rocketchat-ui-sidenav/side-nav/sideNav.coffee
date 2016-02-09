Template.sideNav.helpers
	flexTemplate: ->
		return SideNav.getFlex().template

	flexData: ->
		return SideNav.getFlex().data

	# footer: ->
	#	return ''; #RocketChat.settings.get 'Layout_Sidenav_Footer'

	showStarredRooms: ->
		favoritesEnabled = !RocketChat.settings.get 'Disable_Favorite_Rooms'
		hasFavoriteRoomOpened = ChatSubscription.findOne({ 'u._id': Meteor.userId(), f: true, open: true })

		return true if favoritesEnabled and hasFavoriteRoomOpened

Template.sideNav.events
	'click .close-flex': ->
		SideNav.closeFlex()

	'click .arrow': ->
		SideNav.toggleCurrent()

	'mouseenter .header': ->
		SideNav.overArrow()

	'mouseleave .header': ->
		SideNav.leaveArrow()

	'scroll .rooms-list': ->
		menu.updateUnreadBars()

Template.sideNav.onRendered ->
	SideNav.init()
	menu.init()

	Meteor.defer ->
		menu.updateUnreadBars()

	wrapper = $('.rooms-list .wrapper').get(0)
	lastLink = $('.rooms-list h3.history-div').get(0)
	Meteor.defer ->
		org = Organizations.findOne()
		leftSideRoomTypes = RocketChat.roomTypes.getTypes()
		if true # org?.hasActiveSubscription and org?.plan is 'power'
			leftSideRoomTypes = RocketChat.roomTypes.getTypes()
		else
			leftSideRoomTypes = RocketChat.roomTypes.getTypes().filter((obj) -> obj.template != 'patientChannels')

		leftSideRoomTypes.forEach (roomType) ->
			if Template[roomType.template]?
				Blaze.render Template[roomType.template], wrapper, lastLink

