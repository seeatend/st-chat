Template.degreeSelect.helpers
	selected: (value) ->
		if value == this.degree then 'selected' else ''
	showOther: ->
		return Session.get 'showOtherDegree'

Template.degreeSelect.events
	'change #degree': ->
		if $('#degree').val() is 'Other'
			Session.set 'showOtherDegree', ''
		else
			Session.set 'showOtherDegree', 'hidden'

Template.degreeSelect.onRendered ->
	if this.data.degree is 'Other'
		Session.set 'showOtherDegree', ''
		$('#otherDegree').val(this.data.otherDegree)
	else
		Session.set 'showOtherDegree', 'hidden'
