Template.messageAttachment.helpers
	fixCordova: (url) ->
		if Meteor.isCordova and url?[0] is '/'
			url = Meteor.absoluteUrl().replace(/\/$/, '') + url
			query = "rc_uid=#{Meteor.userId()}&rc_token=#{Meteor._localStorage.getItem('Meteor.loginToken')}"
			if url.indexOf('?') is -1
				url = url + '?' + query
			else
				url = url + '&' + query

		return url

	showImage: ->
		if Meteor.user()?.settings?.preferences?.autoImageLoad is false and this.downloadImages? is not true
			return false

		if Meteor.Device.isPhone() and Meteor.user()?.settings?.preferences?.saveMobileBandwidth and this.downloadImages? is not true
			return false

		return true

	link_url: ->
		if this.image_url or this.audio_url or this.video_url
			return null
		else if this.title_link
			return this.title_link
		else
			return null

	getImageHeight: (height) ->
		return height or 200
