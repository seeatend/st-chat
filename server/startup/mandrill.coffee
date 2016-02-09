# Remove runtime settings (non-persistent)
Meteor.startup ->
	Mandrill.config({
		username: "jonathan@teamstitch.com",
		key: "bAaMyq6HRKH5drmbjLVDgQ"
	});

