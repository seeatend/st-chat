RocketChat.services.getMessageTimeLine = (message, previous) ->
	timeLine = {}
	if (previous?.u._id isnt message.u._id) or (moment(message.ts).diff(previous.ts) > 120000)
		timeLine.isSequential = false
	else
		timeLine.isSequential = true

	if (not previous) or (moment(message.ts).format('DD MMMM') isnt moment(previous.ts).format('DD MMMM'))
		timeLine.isNewDay = true
	else
		timeLine.isNewDay = false

	return timeLine
