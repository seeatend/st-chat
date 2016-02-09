Template.registerHelper 'isIOS', ->
  if navigator.userAgent.match(/(iPad|iPhone|iPod)/g) then true else false

Template.registerHelper 'isAndroid', ->
  if navigator.userAgent.toLowerCase().indexOf('android') > -1 then true else false

Template.body.onRendered ->
	new Clipboard('.clipboard')

	$(document.body).on 'mouseup', (e) ->
		container = $('.modal')
		if !container.is(e.target) and container.has(e.target).length is 0
			Modal.close()

	$(document.body).on 'keydown', (e) ->
		if e.keyCode is 80 and (e.ctrlKey is true or e.metaKey is true)
			e.preventDefault()
			e.stopPropagation()
			spotlight.show()

		if e.keyCode is 27
			spotlight.hide()

		unread = Session.get('unread')
		if e.keyCode is 27 and e.shiftKey is true and unread? and unread isnt ''
			e.stopPropagation()
			swal
				title: t('Clear_all_unreads_question')
				type: 'warning'
				confirmButtonText: t('Yes_clear_all')
				showCancelButton: true
				cancelButtonText: t('Cancel')
				confirmButtonColor: '#DD6B55'
			, ->
				subscriptions = ChatSubscription.find({'u._id': Meteor.userId(), open: true}, { fields: { unread: 1, alert: 1, rid: 1, t: 1, name: 1, ls: 1 } })
				for subscription in subscriptions.fetch()
					if subscription.alert or subscription.unread > 0
						Meteor.call 'readMessages', subscription.rid


	Tracker.autorun (c) ->
		w = window
		d = document
		s = 'script'
		l = 'dataLayer'
		i = RocketChat.settings.get 'API_Analytics'
		if Match.test(i, String) and i.trim() isnt ''
			c.stop()
			do (w,d,s,l,i) ->
				w[l] = w[l] || []
				w[l].push {'gtm.start': new Date().getTime(), event:'gtm.js'}
				f = d.getElementsByTagName(s)[0]
				j = d.createElement(s)
				dl = if l isnt 'dataLayer' then '&l=' + l else ''
				j.async = true
				j.src = '//www.googletagmanager.com/gtm.js?id=' + i + dl
				f.parentNode.insertBefore j, f

	Tracker.autorun (c) ->
		if RocketChat.settings.get 'Meta_language'
			c.stop()

			Meta.set
				name: 'http-equiv'
				property: 'content-language'
				content: RocketChat.settings.get 'Meta_language'
			Meta.set
				name: 'name'
				property: 'language'
				content: RocketChat.settings.get 'Meta_language'

	Tracker.autorun (c) ->
		if RocketChat.settings.get 'Meta_fb_app_id'
			c.stop()

			Meta.set
				name: 'property'
				property: 'fb:app_id'
				content: RocketChat.settings.get 'Meta_fb_app_id'

	Tracker.autorun (c) ->
		if RocketChat.settings.get 'Meta_robots'
			c.stop()

			Meta.set
				name: 'name'
				property: 'robots'
				content: RocketChat.settings.get 'Meta_robots'

	Tracker.autorun (c) ->
		if RocketChat.settings.get 'Meta_google-site-verification'
			c.stop()

			Meta.set
				name: 'name'
				property: 'google-site-verification'
				content: RocketChat.settings.get 'Meta_google-site-verification'

	Tracker.autorun (c) ->
		if RocketChat.settings.get 'Meta_msvalidate01'
			c.stop()

			Meta.set
				name: 'name'
				property: 'msvalidate.01'
				content: RocketChat.settings.get 'Meta_msvalidate01'

	Tracker.autorun (c) ->
		c.stop()

		Meta.set
			name: 'name'
			property: 'application-name'
			content: RocketChat.settings.get 'Site_Name'

		Meta.set
			name: 'name'
			property: 'apple-mobile-web-app-title'
			content: RocketChat.settings.get 'Site_Name'

	if Meteor.isCordova
		$(document.body).addClass 'is-cordova'


Template.main.helpers

	siteName: ->
		return RocketChat.settings.get 'Site_Name'
	subscribePage: ->
		if FlowRouter.current().route.name is 'subscribe'
			return true
	logged: ->
		if FlowRouter.current().route.name is 'resetPassword' and Meteor.userId()?
			user = Meteor.user()
			Meteor.logout ->
				Meteor.call('logoutCleanUp', user)

		if Meteor.userId()?
			$('html').addClass("noscroll").removeClass("scroll")
			return true
		else
			$('html').addClass("scroll").removeClass("noscroll")
			return false

	subsReady: ->
		return not Meteor.userId()? or (FlowRouter.subsReady('userData', 'activeUsers'))

	hasUsername: ->
		return Meteor.userId()? and Meteor.user().username?

	flexOpened: ->
		console.log 'layout.helpers flexOpened' if window.rocketDebug
		return 'flex-opened' if RocketChat.TabBar.isFlexOpen()

	flexOpenedRTC1: ->
		console.log 'layout.helpers flexOpenedRTC1' if window.rocketDebug
		return 'layout1' if Session.equals('rtcLayoutmode', 1)

	flexOpenedRTC2: ->
		console.log 'layout.helpers flexOpenedRTC2' if window.rocketDebug
		return 'layout2' if (Session.get('rtcLayoutmode') > 1)

	isMobileBrowser: ->
		if Meteor.isCordova
			return false
		if navigator.userAgent.match(/(iPad|iPhone|iPod)/g) or navigator.userAgent.toLowerCase().indexOf('android') > -1
			return true
		else
			return false

Template.main.events

	"click .main-content": (e) ->
		if menu.isOpen()
			e.preventDefault()
			menu.close()

	"click .burger": (e) ->
		e.stopPropagation()
		console.log 'room click .burger' if window.rocketDebug
		menu.toggle()

	'touchstart': (e, t) ->
		if document.body.clientWidth > 780
			return

		t.touchstartX = undefined
		t.touchstartY = undefined
		t.movestarted = false
		t.blockmove = false
		if $(e.currentTarget).closest('.main-content').length > 0
			t.touchstartX = e.originalEvent.touches[0].clientX
			t.touchstartY = e.originalEvent.touches[0].clientY
			t.mainContent = $('.main-content')
			t.wrapper = $('.messages-box > .wrapper')

	'touchmove': (e, t) ->
		if t.touchstartX?
			touch = e.originalEvent.touches[0]
			diffX = t.touchstartX - touch.clientX
			diffY = t.touchstartY - touch.clientY
			absX = Math.abs(diffX)
			absY = Math.abs(diffY)

			if t.movestarted isnt true and t.blockmove isnt true and absY > 5
				t.blockmove = true

			if t.blockmove isnt true and (t.movestarted is true or absX > 5)
				t.movestarted = true

				if menu.isOpen()
					t.left = 200 - diffX
				else
					t.left = -diffX

				if t.left > 200
					t.left = 200
				if t.left < 0
					t.left = 0

	'touchend': (e, t) ->
		if t.movestarted is true

			if menu.isOpen()
				if t.left >= 200
					menu.open()
				else
					menu.close()
			else
				if t.left >= 60
					menu.open()
				else
					menu.close()


Template.main.onRendered ->

	# RTL Support - Need config option on the UI
	if isRtl localStorage.getItem "userLanguage"
		$('html').addClass "rtl"
