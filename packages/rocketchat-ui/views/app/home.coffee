Template.home.helpers
	title: ->
		return '' #RocketChat.settings.get 'Layout_Home_Title'
	body: ->
		return '' #RocketChat.settings.get 'Layout_Home_Body'

Template.home.onRendered ->
	setTimeout ->
		redirectToRoom = Session.get('RedirectToRoom')
		if redirectToRoom?
			Session.set('RedirectToRoom', undefined)
			FlowRouter.goToRoomById redirectToRoom
		else if Meteor.user().lastRoomId?
			FlowRouter.goToRoomById Meteor.user().lastRoomId
		else
			FlowRouter.go '/channel/general'
	, 100
