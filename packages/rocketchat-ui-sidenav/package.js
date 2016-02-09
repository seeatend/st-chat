Package.describe({
	name: 'rocketchat:ui-sidenav',
	version: '0.1.0',
	// Brief, one-line summary of the package.
	summary: '',
	// URL to the Git repository containing the source code for this package.
	git: '',
	// By default, Meteor will default to using README.md for documentation.
	// To avoid submitting documentation, set this field to null.
	documentation: 'README.md'
});

Package.onUse(function(api) {
	api.versionsFrom('1.2.1');

	api.use([
		'ecmascript',
		'templating',
		'coffeescript',
		'underscore',
		'rocketchat:lib@0.0.1'
	]);

	api.addFiles('side-nav/accountBox.html', 'client');
	api.addFiles('side-nav/channels.html', 'client');
	api.addFiles('side-nav/chatRoomItem.html', 'client');
	api.addFiles('side-nav/createChannelModal.html', 'client');
	api.addFiles('side-nav/directMessages.html', 'client');
	api.addFiles('side-nav/directMessagesModal.html', 'client');
	api.addFiles('side-nav/listChannelsModal.html', 'client');
	api.addFiles('side-nav/listPrivateGroupsModal.html', 'client');
	api.addFiles('side-nav/privateGroups.html', 'client');
	api.addFiles('side-nav/privateGroupsModal.html', 'client');
	api.addFiles('side-nav/patientChannels.html', 'client');
	api.addFiles('side-nav/createPatientModal.html', 'client');
	api.addFiles('side-nav/listPatientsModal.html', 'client');
	api.addFiles('side-nav/sideNav.html', 'client');
	api.addFiles('side-nav/starredRooms.html', 'client');
	api.addFiles('side-nav/unreadRooms.html', 'client');
	api.addFiles('side-nav/userStatus.html', 'client');

	api.addFiles('side-nav/accountBox.coffee', 'client');
	api.addFiles('side-nav/channels.coffee', 'client');
	api.addFiles('side-nav/chatRoomItem.coffee', 'client');
	api.addFiles('side-nav/createChannelModal.coffee', 'client');
	api.addFiles('side-nav/directMessages.coffee', 'client');
	api.addFiles('side-nav/directMessagesModal.coffee', 'client');
	api.addFiles('side-nav/listChannelsModal.coffee', 'client');
	api.addFiles('side-nav/listPrivateGroupsModal.coffee', 'client');
	api.addFiles('side-nav/privateGroups.coffee', 'client');
	api.addFiles('side-nav/privateGroupsModal.coffee', 'client');
	api.addFiles('side-nav/patientChannels.coffee', 'client');
	api.addFiles('side-nav/createPatientModal.coffee', 'client');
	api.addFiles('side-nav/listPatientsModal.coffee', 'client');
	api.addFiles('side-nav/sideNav.coffee', 'client');
	api.addFiles('side-nav/starredRooms.coffee', 'client');
	api.addFiles('side-nav/unreadRooms.coffee', 'client');

	// TAPi18n
	api.use('templating', 'client');
	var _ = Npm.require('underscore');
	var fs = Npm.require('fs');
	tapi18nFiles = _.compact(_.map(fs.readdirSync('packages/rocketchat-ui-sidenav/i18n'), function(filename) {
		if (fs.statSync('packages/rocketchat-ui-sidenav/i18n/' + filename).size > 16) {
			return 'i18n/' + filename;
		}
	}));
	api.use('tap:i18n@1.6.1', ['client', 'server']);
	api.imply('tap:i18n');
	api.addFiles(tapi18nFiles, ['client', 'server']);
});

Npm.depends({
	'less': 'https://github.com/meteor/less.js/tarball/8130849eb3d7f0ecf0ca8d0af7c4207b0442e3f6',
	'less-plugin-autoprefix': '1.4.2'
});
