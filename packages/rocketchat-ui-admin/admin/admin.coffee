@TempSettings = new Meteor.Collection null
@Settings.find().observe
	added: (data) ->
		TempSettings.insert data
	changed: (data) ->
		TempSettings.update data._id, data
	removed: (data) ->
		TempSettings.remove data._id


Template.admin.helpers
	group: ->
		group = FlowRouter.getParam('group')
		group ?= TempSettings.findOne({ type: 'group' })?._id
		return TempSettings.findOne { _id: group, type: 'group' }
	sections: ->
		group = FlowRouter.getParam('group')
		group ?= TempSettings.findOne({ type: 'group' })?._id
		settings = TempSettings.find({ group: group }, {sort: {section: 1, sorter: 1, i18nLabel: 1}}).fetch()

		sections = {}
		for setting in settings
			sections[setting.section or ''] ?= []
			sections[setting.section or ''].push setting

		sectionsArray = []
		for key, value of sections
			sectionsArray.push
				section: key
				settings: value

		return sectionsArray

	isDisabled: ->
		if not @enableQuery?
			return {}

		return if TempSettings.findOne(@enableQuery)? then {} else {disabled: 'disabled'}

	hasChanges: (section) ->
		group = FlowRouter.getParam('group')

		query =
			group: group
			changed: true

		if section?
			if section is ''
				query.$or = [
					{section: ''}
					{section: {$exists: false}}
				]
			else
				query.section = section

		return TempSettings.find(query).count() > 0

	flexOpened: ->
		return 'opened' if RocketChat.TabBar.isFlexOpen()
	arrowPosition: ->
		console.log 'room.helpers arrowPosition' if window.rocketDebug
		return 'left' unless RocketChat.TabBar.isFlexOpen()
	label: ->
		label = @i18nLabel or @_id
		return TAPi18n.__ label if label
	description: ->
		description = TAPi18n.__ @i18nDescription if @i18nDescription
		if description? and description isnt @i18nDescription
			return description
	sectionIsCustomOath: (section) ->
		return /^Custom OAuth:\s.+/.test section
	callbackURL: (section) ->
		id = s.strRight(section, 'Custom OAuth: ').toLowerCase()
		return Meteor.absoluteUrl('_oauth/' + id)
	selectedOption: (_id, val) ->
		return RocketChat.settings.get(_id) is val

	random: ->
		return Random.id()

Template.admin.events
	"change .input-monitor": (e, t) ->
		value = _.trim $(e.target).val()

		switch @type
			when 'int'
				value = parseInt(value)
			when 'boolean'
				value = value is "1"

		TempSettings.update {_id: @_id},
			$set:
				value: value
				changed: Settings.findOne(@_id).value isnt value

	"click .submit .save": (e, t) ->
		group = FlowRouter.getParam('group')

		query =
			group: group
			changed: true

		if @section is ''
			query.$or = [
				{section: ''}
				{section: {$exists: false}}
			]
		else
			query.section = @section

		settings = TempSettings.find(query, {fields: {_id: 1, value: 1}}).fetch()

		if not _.isEmpty settings
			RocketChat.settings.batchSet settings, (err, success) ->
				return toastr.error TAPi18n.__ 'Error_updating_settings' if err
				toastr.success TAPi18n.__ 'Settings_updated'

	"click .submit .add-custom-oauth": (e, t) ->
		config =
			title: TAPi18n.__ 'Add_custom_oauth'
			text: TAPi18n.__ 'Give_a_unique_name_for_the_custom_oauth'
			type: "input",
			showCancelButton: true,
			closeOnConfirm: true,
			inputPlaceholder: TAPi18n.__ 'Custom_oauth_unique_name'

		swal config, (inputValue) ->
			if inputValue is false
				return false

			if inputValue is ""
				swal.showInputError TAPi18n.__ 'Name_cant_be_empty'
				return false

			Meteor.call 'addOAuthService', inputValue

	"click .submit .remove-custom-oauth": (e, t) ->
		name = this.section.replace('Custom OAuth: ', '')
		config =
			title: TAPi18n.__ 'Are_you_sure'
			type: "input",
			type: 'warning'
			showCancelButton: true
			confirmButtonColor: '#DD6B55'
			confirmButtonText: TAPi18n.__ 'Yes_delete_it'
			cancelButtonText: TAPi18n.__ 'Cancel'
			closeOnConfirm: true

		swal config, ->
			Meteor.call 'removeOAuthService', name

	"click .delete-asset": ->
		Meteor.call 'unsetAsset', @asset

	"change input[type=file]": ->
		e = event.originalEvent or event
		files = e.target.files
		if not files or files.length is 0
			files = e.dataTransfer?.files or []

		for blob in files
			toastr.info TAPi18n.__ 'Uploading_file'

			if @fileConstraints.contentType isnt blob.type
				toastr.error TAPi18n.__ 'Invalid_file_type'
				return

			reader = new FileReader()
			reader.readAsBinaryString(blob)
			reader.onloadend = =>
				Meteor.call 'setAsset', reader.result, blob.type, @asset, (err, data) ->
					if err?
						toastr.error TAPi18n.__ err.error
						console.log err.error
						return

					toastr.success TAPi18n.__ 'File_uploaded'

	"click .expand": (e) ->
		$(e.currentTarget).closest('.section').removeClass('section-collapsed')
		$(e.currentTarget).closest('button').removeClass('expand').addClass('collapse').find('span').text(TAPi18n.__ "Collapse")

	"click .collapse": (e) ->
		$(e.currentTarget).closest('.section').addClass('section-collapsed')
		$(e.currentTarget).closest('button').addClass('expand').removeClass('collapse').find('span').text(TAPi18n.__ "Expand")

	"click button.action": (e) ->
		if @type isnt 'action'
			return

		Meteor.call @value, (err, data) ->
			if err?
				toastr.error TAPi18n.__(err.error), TAPi18n.__('Error')
				return

			args = [data.message].concat data.params

			toastr.success TAPi18n.__.apply(TAPi18n, args), TAPi18n.__('Success')


Template.admin.onRendered ->
	Tracker.afterFlush ->
		SideNav.setFlex "adminFlex"
		SideNav.openFlex()

	# HiddenFeature rocketchat-theme package
	# Meteor.setTimeout ->
	# 	$('input.minicolors').minicolors({theme: 'rocketchat'})
	# , 500

	# Tracker.autorun ->
	# 	FlowRouter.watchPathChange()
	# 	Meteor.setTimeout ->
	# 		$('input.minicolors').minicolors({theme: 'rocketchat'})
	# 	, 200
