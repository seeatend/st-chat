Meteor.startup ->
	storeType = 'GridFS'

	if RocketChat.settings.get 'Accounts_AvatarStoreType'
		storeType = RocketChat.settings.get 'Accounts_AvatarStoreType'

	RocketChatStore = RocketChatFile[storeType]

	if not RocketChatStore?
		throw new Error "Invalid RocketChatStore type [#{storeType}]"

	console.log "Using #{storeType} for Avatar storage".green

	transformWrite = (file, readStream, writeStream) ->
		if RocketChatFile.enabled is false or RocketChat.settings.get('Accounts_AvatarResize') isnt true
			return readStream.pipe writeStream

		height = RocketChat.settings.get 'Accounts_AvatarSize'
		width = height

		RocketChatFile.gm(readStream, file.fileName).background('#ffffff').resize(width, height+'^>').gravity('Center').extent(width, height).stream('jpeg').pipe(writeStream)

	path = "~/uploads"

	if RocketChat.settings.get('Accounts_AvatarStorePath')?.trim() isnt ''
		path = RocketChat.settings.get 'Accounts_AvatarStorePath'

	@RocketChatFileAvatarInstance = new RocketChatStore
		name: 'avatars'
		absolutePath: path
		transformWrite: transformWrite

	WebApp.connectHandlers.use '/avatar/', (req, res, next) ->
		params =
			username: decodeURIComponent(req.url.replace(/^\//, '').replace(/\?.*$/, ''))

		if params.username[0] isnt '@'
			file = RocketChatFileAvatarInstance.getFileWithReadStream encodeURIComponent(params.username)
		else
			params.username = params.username.replace '@', ''

		#console.log "[avatar] checking username #{@params.username} (derrived from path #{req.url})"
		res.setHeader 'Content-Disposition', 'inline'

		if not file?
			res.setHeader 'Content-Type', 'image/svg+xml'
			res.setHeader 'Cache-Control', 'public, max-age=0'
			res.setHeader 'Expires', '-1'
			res.setHeader 'Last-Modified', "Thu, 01 Jan 2015 00:00:00 GMT"

			reqModifiedHeader = req.headers["if-modified-since"];
			if reqModifiedHeader?
				if reqModifiedHeader is "Thu, 01 Jan 2015 00:00:00 GMT"
					res.writeHead 304
					res.end()
					return

			colors = ['#003366']

			username = params.username.replace('.jpg', '')
			color = ''
			initials = ''
			if username is "?"
				color = "#000"
				initials = username
			else
				position = username.length % colors.length
				color = colors[position]
				username = username.replace(/[^A-Za-z0-9]/g, '.').replace(/\.+/g, '.').replace(/(^\.)|(\.$)/g, '')
				user = RocketChat.models.Users.findOneByUsername username

				initials = user.firstName.charAt(0) + user.lastName.charAt(0)

			svg = """
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<svg xmlns="http://www.w3.org/2000/svg" pointer-events="none" width="50" height="50" style="width: 50px; height: 50px; background-color: #{color};">
				<text text-anchor="middle" y="50%" x="50%" dy="0.36em" pointer-events="auto" fill="#ffffff" font-family="Helvetica, Arial, Lucida Grande, sans-serif" style="font-weight: 400; font-size: 28px;">
					#{initials}
				</text>
			</svg>
			"""

			res.write svg
			res.end()
			return

		reqModifiedHeader = req.headers["if-modified-since"];
		if reqModifiedHeader?
			if reqModifiedHeader == file.uploadDate?.toUTCString()
				res.setHeader 'Last-Modified', reqModifiedHeader
				res.writeHead 304
				res.end()
				return

		res.setHeader 'Cache-Control', 'public, max-age=0'
		res.setHeader 'Expires', '-1'
		res.setHeader 'Last-Modified', file.uploadDate?.toUTCString() or new Date().toUTCString()
		res.setHeader 'Content-Type', 'image/jpeg'
		res.setHeader 'Content-Length', file.length

		file.readStream.pipe res
		return
