### [Subscription and browsing logic]
# if org gets more than 5 users flag org & admin with needSubscription = true
# when creating any new organization we should add needSubscription = false
# on main app routes check for needSubscription and redirct the admin user to subscription screen 
# Stop creating users for organization 
# Show upgrade option on orginazation admin screen
###

### [Subscription Screen]
# Pricing & Marketing stuff
# Go to payment form
###

### [Orginazation admin screen]
# Manage users: deactivate/ delete/ add new ?
# Analystic details
# Manage subscription: check details /invoices/ make renew ?/ anuale payments?
# Manage organization: update details name / bio / url ..etc
# Option to cancel subscription and go back to free account?
###

### [Remaining tasks and checks]
# Check subscription.ends and subscription.status ==> Meteor.users.find(userId).observe
# Notifications templates a nd methods
# Redirct admin user to subscription page?
# Monitor hooks
# Check paymentHistory on each payment
# Tests
###

# If we need to do any updates on client when user reach 5 user limit
# checkSub = (record)-> 
#   if RocketChat.authz.hasRole(Meteor.userId(), 'admin')
#     if record.needSubscription 
#       console.log 'need subscription'
#     else
#       console.log 'free subscription'

# # Handle the charge on Organization
# if Meteor.isClient
#   if RocketChat.settings.get('Payment_Enabled')
#     # Observe organizations
#     Organizations.find().observe
#       changed: ( record ) ->
#         checkSub(record)
#         if record.userCount >= 5
#           if not record.hasActiveSubscription
#             Meteor.call 'updateOrgNeedSubscriptionById', record._id, true
#             Meteor.call 'sendOrgReachFreeLimit', record.adminId 
#         else if record.userCount < 5
#           Meteor.call 'updateOrgNeedSubscriptionById', record._id, false


# Observe users on server side to watch the subscription ends date  
# if Meteor.isServer
#   if RocketChat.settings.get('Payment_Enabled')
#     Meteor.users.find({}, { fields: { subscription: 1, customerId: 1, subscriptionId: 1, organizationId:1}}).observe
#       changed: ( record ) ->
#         sub = record?.subscription
#         if sub
#           now = Math.round((new Date()).getTime() / 1000) # XXX Should we give the admin few days to renew the subscription ??
#           end = sub?.ends

#           if now > end
#             console.log 'subscription ends'
#             Meteor.call 'updateOrgHasActiveSubscriptionById', record.organizationId, false
#           else
#             console.log 'subscription still active'
#             Meteor.call 'updateOrgHasActiveSubscriptionById', record.organizationId, true
        
        # if record.hasActiveSubscription = false
        #   Meteor.call 'updateOrgNeedSubscriptionById', record._id, true


# Observe users collection to watch new users added to org
# if Meteor.isServer
#   if RocketChat.settings.get('Payment_Enabled')
#     Meteor.users.find({}, { fields: { subscription: 1, customerId: 1, subscriptionId: 1, organizationId:1}}).observe
#       changed: ( record ) ->
#         sub = record?.subscription
#         org = RocketChat.models.Organizations.findOneById(record.organizationId)
#         if sub
#           currentUserCount = sub.plan.quantity
#           NewUserCount = org?.userCount

#           console.log currentUserCount
#           console.log NewUserCount

#           if currentUserCount == NewUserCount
#           	console.log 'No change on userCount'
#           	return

#           if NewUserCount > currentUserCount
#             diff = NewUserCount - currentUserCount
#             console.log diff
#             Meteor.call 'updateOrgHasActiveSubscriptionById', record.organizationId, false


# Observe users collection to watch any updates to users collection by mistake
if Meteor.isServer
	if RocketChat.settings.get('Payment_Enabled')
		# find new users adds to org and charge the customer 
    RocketChat.models.Organizations.find({},{fields:{ _id: 1, hasActiveSubscription: 1, userCount: 1, adminId: 1, plan: 1 }}).observe
      changed: ( record ) ->
        if record.hasActiveSubscription
          orgUserCounts = Meteor.users.find( organizationId: record._id ).count()
          if orgUserCounts == record.userCount
          	return

          if orgUserCounts > record.userCount
          	console.log 'new users Count '+ orgUserCounts
          	console.log 'old payed userCount '+ Meteor.users.findOne( _id: adminId )?.subscription?.plan?.quantity?
          	# TODO Stripe
          	# user = Meteor.usesr.findOne( _id:adminId )
          	# updates = {
          	# 	token: SERVER_TOKEN
          	# 	plan: user.subscription.plan.id
          	# 	quantity: orgUserCounts - record.userCount
          	# 	customerId: user.customerId
          	# 	subscriptionId: user.subscriptionId
          	# }
          	# Meteor.call 'paymentsAddNewUsersToSubscription', updates, ( err, res )->
          	# 	if not err
          	# 		console.log err

      removed:( record ) ->
      	# TODO Stripe
      	# remove subscription and call paymentsCancelSubscription method

		Meteor.users.find({}).observe
			changed: ( record ) ->
				sub = record?.subscription
				if sub is undefined
					Meteor.call 'updateOrgHasActiveSubscriptionById', record.organizationId, false, 'free'
