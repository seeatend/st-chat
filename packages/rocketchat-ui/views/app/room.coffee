isSubscribed = (_id) ->
	return ChatSubscription.find({ rid: _id }).count() > 0

favoritesEnabled = ->
	return false #!RocketChat.settings.get 'Disable_Favorite_Rooms'


# @TODO bug com o botão para "rolar até o fim" (novas mensagens) quando há uma mensagem com texto que gere rolagem horizontal
Template.room.helpers
	# showFormattingTips: ->
	# 	return RocketChat.settings.get('Message_ShowFormattingTips') and (RocketChat.Markdown or RocketChat.Highlight)
	# showMarkdown: ->
	# 	return RocketChat.Markdown
	# showHighlight: ->
	# 	return RocketChat.Highlight
	favorite: ->
		sub = ChatSubscription.findOne { 'u._id': Meteor.userId(), rid: this._id }, { fields: { f: 1 } }
		return 'icon-star favorite-room' if sub?.f? and sub.f and favoritesEnabled
		return 'icon-star-empty'

	favoriteLabel: ->
		sub = ChatSubscription.findOne { rid: this._id }, { fields: { f: 1 } }
		return "Unfavorite" if sub?.f? and sub.f and favoritesEnabled
		return "Favorite"

	subscribed: ->
		return isSubscribed(this._id)

	messagesHistory: ->
		return ChatMessage.find { rid: this._id, t: { '$ne': 't' }  }, { sort: { ts: 1 } }

	hasMore: ->
		return RoomHistoryManager.hasMore this._id

	isLoading: ->
		return RoomHistoryManager.isLoading this._id

	windowId: ->
		return "chat-window-#{this._id}"

	uploading: ->
		return Session.get 'uploading'

	roomName: ->
		return RoomManager.getRoomName(this._id)
		# roomData = Session.get('roomData' + this._id)
		# return '' unless roomData

		# if roomData.t is 'd'
		# 	return ChatSubscription.findOne({ 'u._id': Meteor.userId(), rid: this._id }, { fields: { name: 1 } })?.name
		# else
		# 	return roomData.name

	roomIcon: ->
		roomData = Session.get('roomData' + this._id)
		return '' unless roomData?.t

		switch roomData.t
			when 'd' then return 'icon-at'
			when 'c' then return 'icon-hash'
			when 'p' then return 'icon-lock'

	userStatus: ->
		roomData = Session.get('roomData' + this._id)

		return {} unless roomData

		if roomData.t is 'd'
			username = _.without roomData.usernames, Meteor.user().username
			return Session.get('user_' + username + '_status') || 'offline'

		else
			return 'offline'

	isChannel: ->
		roomData = Session.get('roomData' + this._id)
		return '' unless roomData
		return roomData.t is 'c'

	isDirect: ->
		roomData = Session.get('roomData' + this._id)
		return '' unless roomData
		return roomData.t is 'd'

	isCordova: ->
		return Meteor.isCordova

	canEditName: ->
		return false
		# XXX HiddenFeature uncomment to enable renaming channel name
		# roomData = Session.get('roomData' + this._id)
		# return '' unless roomData
		# if roomData.t in ['c', 'p']
		# 	return RocketChat.authz.hasAtLeastOnePermission('edit-room', this._id)
		# else
		# 	return ''

	canDirectMessage: ->
		return Meteor.user()?.username isnt this.username

	roomId: ->
		return this._id

	roomNameEdit: ->
		return Session.get('roomData' + this._id)?.name

	editingTitle: ->
		return 'hidden' if Session.get('editRoomTitle')

	showEditingTitle: ->
		return 'hidden' if not Session.get('editRoomTitle')

	flexOpened: ->
		return 'opened' if RocketChat.TabBar.isFlexOpen()

	arrowPosition: ->
		return 'left' unless RocketChat.TabBar.isFlexOpen()

	phoneNumber: ->
		return '' unless this.phoneNumber
		if this.phoneNumber.length > 10
			return "(#{this.phoneNumber.substr(0,2)}) #{this.phoneNumber.substr(2,5)}-#{this.phoneNumber.substr(7)}"
		else
			return "(#{this.phoneNumber.substr(0,2)}) #{this.phoneNumber.substr(2,4)}-#{this.phoneNumber.substr(6)}"

	userActiveByUsername: (username) ->
		status = Session.get 'user_' + username + '_status'
		if status in ['online', 'away', 'busy']
			return {username: username, status: status}
		return

	seeAll: ->
		if Template.instance().showUsersOffline.get()
			return t('See_only_online')
		else
			return t('See_all')

	getPopupConfig: ->
		template = Template.instance()
		return {
			getInput: ->
				return template.find('.input-message')
		}

	maxMessageLength: ->
		return RocketChat.settings.get('Message_MaxAllowedSize')

	utc: ->
		if @utcOffset?
			return "UTC #{@utcOffset}"

	phoneNumber: ->
		return '' unless @phoneNumber
		if @phoneNumber.length > 10
			return "(#{@phoneNumber.substr(0,2)}) #{@phoneNumber.substr(2,5)}-#{@phoneNumber.substr(7)}"
		else
			return "(#{@phoneNumber.substr(0,2)}) #{@phoneNumber.substr(2,4)}-#{@phoneNumber.substr(6)}"

	lastLogin: ->
		if @lastLogin
			return moment(@lastLogin).format('LLL')

	canJoin: ->
		return !! ChatRoom.findOne { _id: @_id, t: 'c' }

	canRecordAudio: ->
		wavRegex = /audio\/wav|audio\/\*/i
		wavEnabled = RocketChat.settings.get("FileUpload_MediaTypeWhiteList").match(wavRegex)
		return RocketChat.settings.get('Message_AudioRecorderEnabled') and (navigator.getUserMedia? or navigator.webkitGetUserMedia?) and wavEnabled and RocketChat.settings.get('FileUpload_Enabled')

	unreadSince: ->
		room = ChatRoom.findOne(this._id, { reactive: false })
		if room?
			return RoomManager.openedRooms[room.t + room.name]?.unreadSince?.get()

	unreadCount: ->
		return RoomHistoryManager.getRoom(@_id).unreadNotLoaded.get() + Template.instance().unreadCount.get()

	formatUnreadSince: ->
		room = ChatRoom.findOne(this._id, { reactive: false })
		room = RoomManager.openedRooms[room.t + room.name]
		date = room?.unreadSince.get()
		if not date? then return

		return moment(date).calendar(null, {sameDay: 'LT'})

	flexTemplate: ->
		return RocketChat.TabBar.getTemplate()

	flexData: ->
		return _.extend { rid: this._id }, RocketChat.TabBar.getData()

	adminClass: ->
		return 'admin' if RocketChat.authz.hasRole(Meteor.userId(), 'admin')

	showToggleFavorite: ->
		return true if isSubscribed(this._id) and favoritesEnabled()

	compactView: ->
		return 'compact' if Meteor.user()?.settings?.preferences?.compactView

	selectable: ->
		return Template.instance().selectable.get()
	showError: ->
		swal
			title: 'Whoops!'
			text: 'Looks like that file is too big. Max size is 20MB.'
			type: 'error'

	hasActiveSubscription: ->
		if RocketChat.settings.get('Payment_Enabled')
			org = Organizations.findOne()
			return true if org.hasActiveSubscription

Template.room.events
	"click, touchend": (e, t) ->
		Meteor.setTimeout ->
			t.sendToBottomIfNecessaryDebounced()
		, 100

	"touchstart .message": (e, t) ->
		message = this
		doLongTouch = ->
			mobileMessageMenu.show(message, t)

		t.touchtime = Meteor.setTimeout doLongTouch, 500

	"touchend .message": (e, t) ->
		Meteor.clearTimeout t.touchtime

	"touchmove .message": (e, t) ->
		Meteor.clearTimeout t.touchtime

	"touchcancel .message": (e, t) ->
		Meteor.clearTimeout t.touchtime

	"click .upload-progress a": (e) ->
		e.preventDefault()
		Session.set "uploading-cancel-#{this.id}", true

	"click .unread-bar > a": ->
		readMessage.readNow(true)

	# XXX HiddenFeature openflex
	# "click .flex-tab .more": (event, t) ->
	# 	if RocketChat.TabBar.isFlexOpen()
	# 		Session.set('rtcLayoutmode', 0)
	# 		RocketChat.TabBar.closeFlex()
	# 		t.searchResult.set undefined
	# 	else
	# 		RocketChat.TabBar.openFlex()

	'click .room-notifications': (e) ->
		e.preventDefault()
		Modal.init($('#roomNotifications'))
		Modal.open()

	'click .add-user-to-room': (e) ->
		e.preventDefault()
		Modal.init($('#addUserToRoom'))
		Modal.open()

	'click .message-search': (e, t) ->
		e.preventDefault()
		if RocketChat.TabBar.isFlexOpen() and RocketChat.TabBar.getTemplate() is 'messageSearch'
			RocketChat.TabBar.closeFlex()
			$('.flex-tab').css('max-width', '')
		else
			width = $(e.currentTarget).data('width')

			if width?
				$('.flex-tab').css('max-width', "#{width}px")
			else
				$('.flex-tab').css('max-width', '')

			RocketChat.TabBar.setTemplate 'messageSearch', ->
				$('.flex-tab')?.find("input[type='text']:first")?.focus()
				$('.flex-tab .content')?.scrollTop(0)

	"click .flex-tab  .video-remote" : (e) ->
		if RocketChat.TabBar.isFlexOpen()
			if (!Session.get('rtcLayoutmode'))
				Session.set('rtcLayoutmode', 1)
			else
				t = Session.get('rtcLayoutmode')
				t = (t + 1) % 4
				console.log  'setting rtcLayoutmode to ' + t  if window.rocketDebug
				Session.set('rtcLayoutmode', t)

	"click .flex-tab  .video-self" : (e) ->
		if (Session.get('rtcLayoutmode') == 3)
			console.log 'video-self clicked in layout3' if window.rocketDebug
			i = document.getElementById("fullscreendiv")
			if i.requestFullscreen
				i.requestFullscreen()
			else
				if i.webkitRequestFullscreen
					i.webkitRequestFullscreen()
				else
					if i.mozRequestFullScreen
						i.mozRequestFullScreen()
					else
						if i.msRequestFullscreen
							i.msRequestFullscreen()

	'click .toggle-favorite': (event) ->
		event.stopPropagation()
		event.preventDefault()
		Meteor.call 'toogleFavorite', @_id, !$('i', event.currentTarget).hasClass('favorite-room')

	'click .edit-room-title': (event) ->
		event.preventDefault()
		Session.set('editRoomTitle', true)
		$(".fixed-title").addClass "visible"
		Meteor.setTimeout ->
			$('#room-title-field').focus().select()
		, 10

	'keydown #room-title-field': (event) ->
		if event.keyCode is 27 # esc
			Session.set('editRoomTitle', false)
		else if event.keyCode is 13 # enter
			renameRoom @_id, $(event.currentTarget).val()

	'blur #room-title-field': (event) ->
		# TUDO: create a configuration to select the desired behaviour
		# renameRoom this._id, $(event.currentTarget).val()
		Session.set('editRoomTitle', false)
		$(".fixed-title").removeClass "visible"

	# XXX HiddenFeature openflex
	# "click .flex-tab .user-image > a" : (e) ->
	# 	RocketChat.TabBar.openFlex()
	# 	Session.set('showUserInfo', @username)

	# XXX HiddenFeature openflex
	# 'click .user-card-message': (e) ->
	# 	roomData = Session.get('roomData' + this.rid)
	# 	if roomData.t in ['c', 'p']
	# 		# Session.set('flexOpened', true)
	# 		Session.set('showUserInfo', $(e.currentTarget).data('username'))
	# 	# else
	# 		# Session.set('flexOpened', true)
	# 	RocketChat.TabBar.setTemplate 'membersList'

	'scroll .wrapper': _.throttle (e, instance) ->
		if RoomHistoryManager.isLoading(@_id) is false and (RoomHistoryManager.hasMore(@_id) is true or RoomHistoryManager.hasMoreNext(@_id) is true)
			if RoomHistoryManager.hasMore(@_id) is true and e.target.scrollTop is 0
				RoomHistoryManager.getMore(@_id)
			else if RoomHistoryManager.hasMoreNext(@_id) is true and e.target.scrollTop >= e.target.scrollHeight - e.target.clientHeight
				RoomHistoryManager.getMoreNext(@_id)
	, 200

	'click .load-more > a': ->
		RoomHistoryManager.getMore(@_id)

	'click .new-message': (e) ->
		Template.instance().atBottom = true
		Template.instance().find('.input-message').focus()

	'click .see-all': (e, instance) ->
		instance.showUsersOffline.set(!instance.showUsersOffline.get())

	'click .dropzone': (e) ->
		$('.message-dropdown:visible').hide()

	'click .message-cog': (e) ->
		e.stopPropagation()
		message = @
		$('.message-dropdown:visible').hide()

		dropDown = $(".messages-box \##{message._id} .message-dropdown")

		if dropDown.length is 0
			actions = RocketChat.MessageAction.getButtons message

			el = Blaze.toHTMLWithData Template.messageDropdown,
				actions: actions

			$(".messages-box \##{message._id} .message-cog-container").append el

			dropDown = $(".messages-box \##{message._id} .message-dropdown")

		dropDown.show()

	'click .message-dropdown .message-action': (e, t) ->
		el = $(e.currentTarget)

		button = RocketChat.MessageAction.getButtonById el.data('id')
		if button?.action?
			button.action.call @, e, t

	'click .message-dropdown-close': ->
		$('.message-dropdown:visible').hide()

  # XXX HiddenFeature openflex
	# "click .mention-link": (e) ->
	# 	channel = $(e.currentTarget).data('channel')
	# 	if channel?
	# 		FlowRouter.go 'channel', {name: channel}
	# 		return

	# 	RocketChat.TabBar.setTemplate 'membersList'
	# 	Session.set('showUserInfo', $(e.currentTarget).data('username'))
	# 	RocketChat.TabBar.openFlex()

	'click .image-to-download': (event) ->
		ChatMessage.update {_id: this._id, 'urls.url': $(event.currentTarget).data('url')}, {$set: {'urls.$.downloadImages': true}}
		ChatMessage.update {_id: this._id, 'attachments.image_url': $(event.currentTarget).data('url')}, {$set: {'attachments.$.downloadImages': true}}

	'click .pin-message': (event) ->
		message = @
		instance = Template.instance()
		if message.pinned
			chatMessages[Session.get('openedRoom')].unpinMsg(message)
		else
			chatMessages[Session.get('openedRoom')].pinMsg(message)

	'dragenter .dropzone': (e) ->
		e.currentTarget.classList.add 'over'

	'dragleave .dropzone-overlay': (e) ->
		e.currentTarget.parentNode.classList.remove 'over'

	'dragover .dropzone-overlay': (e) ->
		e = e.originalEvent or e
		if e.dataTransfer.effectAllowed in ['move', 'linkMove']
			e.dataTransfer.dropEffect = 'move'
		else
			e.dataTransfer.dropEffect = 'copy'

	'dropped .dropzone-overlay': (event) ->
		event.currentTarget.parentNode.classList.remove 'over'

		e = event.originalEvent or event
		files = e.target.files
		if not files or files.length is 0
			files = e.dataTransfer?.files or []

		filesToUpload = []
		for file in files
			filesToUpload.push
				file: file
				name: file.name

		fileUpload filesToUpload

	'click .deactivate': ->
		username = Session.get('showUserInfo')
		user = Meteor.users.findOne { username: String(username) }
		Meteor.call 'setUserActiveStatus', user?._id, false, (error, result) ->
			if result
				toastr.success t('User_has_been_deactivated')
			if error
				toastr.error error.reason

	'click .activate': ->
		username = Session.get('showUserInfo')
		user = Meteor.users.findOne { username: String(username) }
		Meteor.call 'setUserActiveStatus', user?._id, true, (error, result) ->
			if result
				toastr.success t('User_has_been_activated')
			if error
				toastr.error error.reason

	'load img': (e, template) ->
		template.sendToBottomIfNecessary?()

	'click .jump-recent .jump-link': (e, template) ->
		e.preventDefault()
		template.atBottom = true
		RoomHistoryManager.clear(template?.data?._id)

	'click .message': (e, template) ->
		if template.selectable.get()
			document.selection?.empty() or window.getSelection?().removeAllRanges()
			data = Blaze.getData(e.currentTarget)
			_id = data?._arguments?[1]?._id

			if !template.selectablePointer
				template.selectablePointer = _id

			if !e.shiftKey
				template.selectedMessages = template.getSelectedMessages()
				template.selectedRange = []
				template.selectablePointer = _id

			template.selectMessages _id

			selectedMessages = $('.messages-box .message.selected').map((i, message) -> message.id)
			removeClass = _.difference selectedMessages, template.getSelectedMessages()
			addClass = _.difference template.getSelectedMessages(), selectedMessages
			for message in removeClass
				$(".messages-box ##{message}").removeClass('selected')
			for message in addClass
				$(".messages-box ##{message}").addClass('selected')


Template.room.onCreated ->
	this.data._id = Session.get('openedRoom')
	# this.scrollOnBottom = true
	# this.typing = new msgTyping this.data._id
	this.showUsersOffline = new ReactiveVar false
	this.atBottom = true
	this.unreadCount = new ReactiveVar 0

	this.selectable = new ReactiveVar false
	this.selectedMessages = []
	this.selectedRange = []
	this.selectablePointer = null

	this.resetSelection = (enabled) =>
		this.selectable.set(enabled)
		$('.messages-box .message.selected').removeClass 'selected'
		this.selectedMessages = []
		this.selectedRange = []
		this.selectablePointer = null

	this.selectMessages = (to) =>
		if this.selectablePointer is to and this.selectedRange.length > 0
			this.selectedRange = []
		else
			message1 = ChatMessage.findOne this.selectablePointer
			message2 = ChatMessage.findOne to

			minTs = _.min([message1.ts, message2.ts])
			maxTs = _.max([message1.ts, message2.ts])

			this.selectedRange = _.pluck(ChatMessage.find({ rid: message1.rid, ts: { $gte: minTs, $lte: maxTs } }).fetch(), '_id')

	this.getSelectedMessages = =>
		messages = this.selectedMessages
		addMessages = false
		for message in this.selectedRange
			if messages.indexOf(message) is -1
				addMessages = true
				break

		if addMessages
			previewMessages = _.compact(_.uniq(this.selectedMessages.concat(this.selectedRange)))
		else
			previewMessages = _.compact(_.difference(this.selectedMessages, this.selectedRange))

		return previewMessages

	@autorun =>
		@subscribe 'fullUserData', Session.get('showUserInfo'), 1


Template.room.onDestroyed ->
	RocketChat.TabBar.resetButtons()

	window.removeEventListener 'resize', this.onWindowResize


Template.room.onRendered ->
	analytics.page()
	unless window.chatMessages
		window.chatMessages = {}
	unless window.chatMessages[Session.get('openedRoom')]
		window.chatMessages[Session.get('openedRoom')] = new ChatMessages
	chatMessages[Session.get('openedRoom')].init(this.firstNode)
	# ScrollListener.init()

	wrapper = this.find('.wrapper')
	wrapperUl = this.find('.wrapper > ul')
	newMessage = this.find(".new-message")

	template = this

	containerBars = $('.messages-container > .container-bars')
	containerBarsOffset = containerBars.offset()

	template.isAtBottom = ->
		if wrapper.scrollTop >= wrapper.scrollHeight - wrapper.clientHeight
			newMessage.className = "new-message not"
			return true
		return false

	template.sendToBottom = ->
		wrapper.scrollTop = wrapper.scrollHeight - wrapper.clientHeight
		newMessage.className = "new-message not"

	template.checkIfScrollIsAtBottom = ->
		template.atBottom = template.isAtBottom()
		readMessage.enable()
		readMessage.read()

	template.sendToBottomIfNecessary = ->
		if template.atBottom is true and template.isAtBottom() isnt true
			template.sendToBottom()

	template.sendToBottomIfNecessaryDebounced = _.debounce template.sendToBottomIfNecessary, 10

	template.sendToBottomIfNecessary()

	if not window.MutationObserver?
		wrapperUl.addEventListener 'DOMSubtreeModified', ->
			template.sendToBottomIfNecessaryDebounced()
	else
		observer = new MutationObserver (mutations) ->
			mutations.forEach (mutation) ->
				template.sendToBottomIfNecessaryDebounced()

		observer.observe wrapperUl,
			childList: true
		# observer.disconnect()

	template.onWindowResize = ->
		Meteor.defer ->
			template.sendToBottomIfNecessaryDebounced()

	window.addEventListener 'resize', template.onWindowResize

	wrapper.addEventListener 'mousewheel', ->
		template.atBottom = false
		Meteor.defer ->
			template.checkIfScrollIsAtBottom()

	wrapper.addEventListener 'wheel', ->
		template.atBottom = false
		Meteor.defer ->
			template.checkIfScrollIsAtBottom()

	wrapper.addEventListener 'touchstart', ->
		template.atBottom = false

	wrapper.addEventListener 'touchend', ->
		Meteor.defer ->
			template.checkIfScrollIsAtBottom()
		Meteor.setTimeout ->
			template.checkIfScrollIsAtBottom()
		, 1000
		Meteor.setTimeout ->
			template.checkIfScrollIsAtBottom()
		, 2000

	$('.flex-tab-bar').on 'click', (e, t) ->
		Meteor.setTimeout ->
			template.sendToBottomIfNecessaryDebounced()
		, 100

	updateUnreadCount = _.throttle ->
		firstMessageOnScreen = document.elementFromPoint(containerBarsOffset.left+1, containerBarsOffset.top+containerBars.height()+1)
		if firstMessageOnScreen?.id?
			firstMessage = ChatMessage.findOne firstMessageOnScreen.id
			if firstMessage?
				subscription = ChatSubscription.findOne 'u._id': Meteor.userId(), rid: template.data._id
				template.unreadCount.set ChatMessage.find({rid: template.data._id, ts: {$lt: firstMessage.ts, $gt: subscription?.ls}}).count()
			else
				template.unreadCount.set 0
	, 300

	readMessage.onRead (rid) ->
		if rid is template.data._id
			template.unreadCount.set 0

	wrapper.addEventListener 'scroll', ->
		updateUnreadCount()

	# salva a data da renderização para exibir alertas de novas mensagens
	$.data(this.firstNode, 'renderedAt', new Date)

	webrtc = WebRTC.getInstanceByRoomId template.data._id
	if webrtc?
		Tracker.autorun ->
			if webrtc.remoteItems.get()?.length > 0
				RocketChat.TabBar.setTemplate 'membersList'
				RocketChat.TabBar.openFlex()

			if webrtc.localUrl.get()?
				RocketChat.TabBar.setTemplate 'membersList'
				RocketChat.TabBar.openFlex()


renameRoom = (rid, name) ->
	name = name?.toLowerCase().trim()
	console.log 'room renameRoom' if window.rocketDebug
	room = Session.get('roomData' + rid)
	if room.name is name
		Session.set('editRoomTitle', false)
		return false

	Meteor.call 'saveRoomName', rid, name, (error, result) ->
		if result
			Session.set('editRoomTitle', false)
			# If room was renamed then close current room and send user to the new one
			RoomManager.close room.t + room.name
			switch room.t
				when 'c'
					FlowRouter.go 'channel', name: name
				when 'p'
					FlowRouter.go 'group', name: name

			toastr.success t('Room_name_changed_successfully')
		if error
			if error.error is 'name-invalid'
				toastr.error t('Invalid_room_name', name)
				return
			if error.error is 'duplicate-name'
				if room.t is 'c'
					toastr.error t('Duplicate_channel_name', name)
				else
					toastr.error t('Duplicate_private_group_name', name)
				return
			toastr.error error.reason