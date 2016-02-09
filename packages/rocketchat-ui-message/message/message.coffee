Template.message.helpers
	isBot: ->
		return 'bot' if this.bot?
	isGroupable: ->
		return 'false' if this.groupable is false
	isSequential: ->
		if this.timeLine?.isSequential
			return 'sequential'
		return ''
	getEmoji: (emoji) ->
		return emojione.toImage emoji
	own: ->
		return 'own' if this.u?._id is Meteor.userId()
	timestamp: ->
		return +this.ts
	chatops: ->
		return 'chatops-message' if this.u?.username is RocketChat.settings.get('Chatops_Username')
	time: ->
		if this.timeLine?.isSequential
			return moment(this.ts).format('hh:mm')
		return moment(this.ts).format('hh:mm a')
	isNewDay: ->
		if this.timeLine?.isNewDay
			return 'new-day'
		else
			return ''
	date: ->
		return moment(this.ts).format('MMMM D')
	body: ->
		messageType = RocketChat.MessageTypes.getType(this)
		if messageType?.render?
			return messageType.render(message)
		else if messageType?.template?
# render template
		else if messageType?.message?
			if messageType.data?(this)?
				return TAPi18n.__(messageType.message, messageType.data(this))
			else
				return TAPi18n.__(messageType.message)
		else
			if this.u?.username is RocketChat.settings.get('Chatops_Username')
				this.html = this.msg
				message = RocketChat.callbacks.run 'renderMentions', this
				# console.log JSON.stringify message
				return this.html

			this.html = this.msg
			if _.trim(this.html) isnt ''
				this.html = _.escapeHTML this.html

			message = RocketChat.callbacks.run 'renderMessage', this
			# console.log JSON.stringify message
			this.html = message.html.replace /\n/gm, '<br/>'
			return this.html


	system: ->
		if RocketChat.MessageTypes.isSystemMessage(this)
			return 'system'

	edited: ->
		return this.editedAt? and not RocketChat.MessageTypes.isSystemMessage(this)

	pinned: ->
		return this.pinned
	canEdit: ->
		hasPermission = RocketChat.authz.hasAtLeastOnePermission('edit-message', this.rid)
		isEditAllowed = RocketChat.settings.get 'Message_AllowEditing'
		editOwn = this.u?._id is Meteor.userId()

		return unless hasPermission or (isEditAllowed and editOwn)

		blockEditInMinutes = RocketChat.settings.get 'Message_AllowEditing_BlockEditInMinutes'
		if blockEditInMinutes? and blockEditInMinutes isnt 0
			msgTs = moment(this.ts) if this.ts?
			currentTsDiff = moment().diff(msgTs, 'minutes') if msgTs?
			return currentTsDiff < blockEditInMinutes
		else
			return true

	canDelete: ->
		if RocketChat.authz.hasAtLeastOnePermission('delete-message', this.rid )
			return true

		return RocketChat.settings.get('Message_AllowDeleting') and this.u?._id is Meteor.userId()
	canPin: ->
		return RocketChat.settings.get 'Message_AllowPinning'
	canStar: ->
		return RocketChat.settings.get 'Message_AllowStarring'
	showEditedStatus: ->
		return RocketChat.settings.get 'Message_ShowEditedStatus'
	label: ->
		if @i18nLabel
			return t(@i18nLabel)
		else if @label
			return @label

	hasOembed: ->
		return false unless this.urls?.length > 0 and Template.oembedBaseWidget? and RocketChat.settings.get 'API_Embed'

		return false unless this.u?.username not in RocketChat.settings.get('API_EmbedDisabledFor')?.split(',')

		return true

	messageReads: ->
		if RocketChat.settings.get('Payment_Enabled')
			org = Organizations.findOne()
			return null if not org.hasActiveSubscription
		query =
			'u._id':
				$ne: Meteor.userId()
			rid: this.rid

		subscriptions = ChatSubscription.find(query).fetch()
		readBy = []

		for subscription in subscriptions
			if this.ts < subscription.ls
				if (subscription.t is 'd') and (this.u._id is Meteor.userId())
					return 'Seen'
				else
					pattern = /\B@[.a-z0-9_-]+/gi;
					mentions = this.msg.match(pattern)
					if mentions?
						for mention in mentions
							username = mention.substring(1)
							if username is subscription.u.username
								readBy.push(subscription.u.name)

		if readBy.length > 0
			return 'Seen by: ' + readBy.join(', ')

