Package.describe({
	name: 'rocketchat:ui-admin',
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
		'payments@0.0.1',
		'rocketchat:lib@0.0.1'
	]);

	// template files
	api.addFiles('admin/admin.html', 'client');
	api.addFiles('admin/adminFlex.html', 'client');
	api.addFiles('admin/adminStatistics.html', 'client');

	api.addFiles('admin/rooms/adminRoomInfo.html', 'client');
	api.addFiles('admin/rooms/adminRooms.html', 'client');

	api.addFiles('admin/users/adminInviteUser.html', 'client');
	api.addFiles('admin/users/adminUserChannels.html', 'client');
	api.addFiles('admin/users/adminUserEdit.html', 'client');
	api.addFiles('admin/users/adminUserInfo.html', 'client');
	api.addFiles('admin/users/adminUsers.html', 'client');

	api.addFiles('admin/channels/adminChannels.html', 'client');
	api.addFiles('admin/organization/adminOrganization.html', 'client');
	api.addFiles('admin/manageUsers/adminManageUsers.html', 'client');
	api.addFiles('admin/createTeam/adminCreateTeam.html', 'client');

	api.addFiles('admin/billing/adminBilling.html', 'client');

	// coffee files
	api.addFiles('admin/admin.coffee', 'client');
	api.addFiles('admin/adminFlex.coffee', 'client');
	api.addFiles('admin/adminStatistics.coffee', 'client');

	api.addFiles('admin/rooms/adminRoomInfo.coffee', 'client');
	api.addFiles('admin/rooms/adminRooms.coffee', 'client');

	api.addFiles('admin/users/adminInviteUser.coffee', 'client');
	api.addFiles('admin/users/adminUserChannels.coffee', 'client');
	api.addFiles('admin/users/adminUserEdit.coffee', 'client');
	api.addFiles('admin/users/adminUserInfo.coffee', 'client');
	api.addFiles('admin/users/adminUsers.coffee', 'client');

	api.addFiles('admin/channels/adminChannels.coffee', 'client');

	api.addFiles('admin/organization/adminOrganization.coffee', 'client');

	api.addFiles('admin/manageUsers/adminManageUsers.coffee', 'client');
	api.addFiles('admin/createTeam/adminCreateTeam.coffee', 'client');

	api.addFiles('admin/billing/adminBilling.coffee', 'client');


	// api.addAssets('styles/side-nav.less', 'client');
});
