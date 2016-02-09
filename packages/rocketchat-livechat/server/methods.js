Meteor.methods({
	registerGuest: function(token, name, email) {
		console.log('registerGuest ->'.green, token);
		var pass, qt, user, userData, userExists, userId, inc = 0;
		check(token, String);
		user = Meteor.users.findOne({
			"profile.token": token
		}, {
			fields: {
				_id: 1
			}
		});
		if (user != null) {
			throw new Meteor.Error('token-already-exists', 'Token already exists');
		}
		pass = Meteor.uuid();
		while (true) {
			qt = Meteor.users.find({
				'profile.guest': true
			}).count() + 1;
			user = 'guest-' + (qt + inc++);
			userExists = Meteor.users.findOne({
				'username': user
			}, {
				fields: {
					_id: 1
				}
			});
			console.log('userExists ->',userExists);
			if (!userExists) {
				break;
			}
		}
		userData = {
			username: user,
			password: pass
		};
		userId = Accounts.createUser(userData);

		updateUser = {
			name: name || user,
			"profile.guest": true,
			"profile.token": token
		}

		if (email && email.trim() !== "") {
			updateUser.emails = [{ "address": email }];
		}

		Meteor.users.update(userId, {
			$set: updateUser
		});
		return {
			user: user,
			pass: pass
		};
	},
	sendMessageLivechat: function(message) {
		var guest, operator, room;
		console.log('sendMessageLivechat ->', arguments);
		check(message.rid, String);
		check(message.token, String);
		guest = Meteor.users.findOne(Meteor.userId(), {
			fields: {
				username: 1
			}
		});
		room = RocketChat.models.Rooms.findOneById(message.rid);
		if (room == null) {
			operator = Meteor.users.findOne({
				operator: true,
				status: 'online'
			});
			if (!operator) {
				throw new Meteor.Error('no-operators', 'Sorry, no online operators');
			}
			RocketChat.models.Rooms.insert({
				_id: message.rid,
				name: guest.username,
				msgs: 1,
				lm: new Date(),
				usernames: [operator.username, guest.username],
				t: 'l',
				ts: new Date(),
				v: {
					token: message.token
				}
			});
			RocketChat.models.Subscriptions.insert({
				rid: message.rid,
				name: guest.username,
				alert: true,
				open: true,
				unread: 1,
				answered: false,
				u: {
					_id: operator._id,
					username: operator.username
				},
				t: 'l'
			});
		}
		room = Meteor.call('canAccessRoom', message.rid, guest._id);
		if (!room) {
			throw new Meteor.Error('cannot-acess-room');
		}
		return RocketChat.sendMessage(guest, message, room);
	}
});
