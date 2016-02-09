# Listen to deep links 
# DeepLink.once 'teamstitch', (data, url, scheme, path, querystring) ->
#   alert 'Got some deep linked data...'
#   alert data.cool


# Set up a deep link helper object
# @go2App = new DeepLink('teamstitch',
#   appId: '1057374126'
#   url: 'https://app.teamstitch.com'
#   fallbackUrl: 'https://app.teamstitch.com')

# #go2App.iosBanner('', { method: 'banner?', date: new Date() })


# Template.downloadApp.onRendered ->
# 	Tracker.afterFlush ->
# 		swal
# 			title: "App"
# 			text: "Open the App"
# 			showCancelButton: true
# 			confirmButtonText: "Yes"
# 			cancelButtonText: "No"
# 		, (isConfirm) =>
# 			if isConfirm
# 				link = go2App.link('', { method: 'ejsonbase64', date: new Date() })
# 				go2App.open('', { method: 'open'})
# 			else
# 				console.log 'can\'t help'

# Template.downloadApp.events
# 	'click #login-card': () ->
# 		go2App.open('', { method: 'open'})

Template.downloadApp.helpers
  store: -> 
  	if navigator.userAgent.match(/(iPad|iPhone|iPod)/g)
  		return 'ios'
  	if navigator.userAgent.toLowerCase().indexOf('android') > -1
  		return 'google'