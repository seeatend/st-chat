Stripe = StripeAPI(RocketChat.settings.get('Stripe_SecretKey') or process.env.STRIPE_PRIVATE_KEY)
Future = Npm.require('fibers/future')
Fiber = Npm.require('fibers')

# paymentsCreateCustomer = Meteor.wrapAsync(Stripe.customers.create, Stripe.customers)
createSubscription = Meteor.wrapAsync(Stripe.customers.createSubscription, Stripe.customers)


Meteor.methods
  'paymentsCreateCustomer': ( token ) ->
    check token, String

    user = Meteor.user()
    lookupCustomer = user?.customerId
    if !lookupCustomer
      Stripe.customers.create {
        source: token
        email: user.emails[0].address
      }, Meteor.bindEnvironment(( err, account ) ->
        if err
          console.error err
          ServerSession.set('paymentsCreateCustomerError', err.message)
          throw new Meteor.Error 'createCustomerNew', '[methods] createCustomerNew -> err'
        else
          ServerSession.set('paymentsCreateCustomerError', null)
          return account
      )
    else
      throw new Meteor.Error( 404, '[methods] paymentsCreateCustomer -> customer already exists' )

  'paymentsCreateSubscription': ( customerId, plan, quantity, customerCard ) ->
    check customerId, String
    check plan, String
    check quantity, Number
    check customerCard, Object

    try
      results = createSubscription(customerId,
        { plan: 'monthly_'+plan+'_plan'
        quantity: quantity })

      if results and results.id
        subscription =
          customerId: customerId
          subscriptionId: results.id
          subscription:
            plan:
              id: 'monthly_'+plan+'_plan'
              name:results.plan.name
              quantity: results.quantity
              amount: results.plan.amount
            payment:
              card:
                type: customerCard.brand
                lastFour: customerCard.last4
              nextPaymentDue: results.current_period_end
            status: results.status
            start: results.current_period_start
            ends: results.current_period_end

      Meteor.users.update Meteor.userId(), { $set: subscription }, ( error, res ) ->
        if error
          console.log error
          Meteor.call 'updateOrgHasActiveSubscriptionById', Meteor.user()?.organizationId, false, 'free'
        else
          Meteor.call 'updateOrgHasActiveSubscriptionById', Meteor.user()?.organizationId, true ,plan
      
      ServerSession.set('paymentsCreateSubscriptionError', null)
      return results

    catch err
      console.log err
      ServerSession.set('paymentsCreateSubscriptionError', err.message)
      throw new Meteor.Error( 404, err.message )

  'getUserSubscription': ->
    if not this.userId 
      throw new Meteor.Error 'invalid-user', "[methods] getUserSubscription -> Invalid user"

    user = Meteor.user()

    if not user.customerId
      return null

    subscription =
      customerId: user.customerId
      subscriptionId: user.subscriptionId
      plan: user.subscription.plan.name
      quantity: user.subscription.plan.quantity
      nextPaymentDue: moment.unix(user.subscription.payment.nextPaymentDue).format('ddd, D MMMM YYYY ')
      status: user.subscription.status
      start: moment.unix(user.subscription.start).format('ddd, D MMMM YYYY ')
      ends: moment.unix(user.subscription.ends).format('ddd, D MMMM YYYY ')

    return subscription

  'paymentsAddNewUsersToSubscription': ( updates ) ->
    check update,
      token: String
      newQuantity: String
      customerId: String
      subscriptionId: String
      plan: String
    
    if update.token == SERVER_TOKEN
    
      cusId = updates.user.customerId
      subId = updates.user.subscriptionId
      plan = updates.user.plan
      updateSubscription = new Future

      Stripe.customers.updateSubscription cusId, subId,
        { plan: plan
        quantity:'newQuantity'}, ( error, customer ) ->
        if error
          console.log error
          updateSubscription.return error
        else
          # Call sendAddNewUserMessage or sendDeleteUserMessage
          updateSubscription.return customer

      updateSubscription.wait()

    else
      throw new Meteor.Error('invalid-auth-token', 'Sorry, your server authentication token is invalid.')

  'paymentsUpdateSubscription': ( plan ) ->
    check plan, String

    stripeUpdateSubscription = new Future
  
    user = Meteor.userId()
    getUser = Meteor.users.findOne({ '_id': user }, fields: 'customerId': 1)
  
    Stripe.customers.updateSubscription getUser.customerId, { plan: plan }, ( error, subscription ) ->
      if error
        stripeUpdateSubscription.return error
      else
        Fiber(->
          update = 
            token: SERVER_TOKEN
            user: user
            plan: plan
            status: subscription.status
            date: subscription.current_period_end

          Meteor.call 'updateUserPlan', update, ( error, response ) ->
            if error
              stripeUpdateSubscription.return error
            else
              stripeUpdateSubscription.return response
        ).run()
      
    stripeUpdateSubscription.wait()

  'paymentsUpdateSubscriptionUsingWebHook': ( update ) ->
    check update,
      token: String
      user: String
      subscription:
        status: String
        ends: String
        quantity: String

    if update.token == SERVER_TOKEN
      updateUserSubscription = new Future
      
      Meteor.users.update update.user, { $set:
        'subscription.status': update.subscription.status
        'subscription.ends': update.subscription.ends
        'subscription.payment.nextPaymentDue': update.subscription.ends
        'subscription.plan.quantity': update.subscription.quantity }, ( error, response ) ->
          if error
            updateUserSubscription.return error
          else
            updateUserSubscription.return response

      updateUserSubscription.wait()

    else
      throw new Meteor.Error('invalid-auth-token', 'Sorry, your server authentication token is invalid.')

  'paymentsRetrieveSubscription': ( cusId, subId ) ->
    check cusId, String
    check subId, String

    if not Meteor.userId()
      throw new Meteor.Error 'invalid-user', "[methods] paymentsRetrieveSubscription -> Invalid user"

    retriveSub = new Future

    Stripe.customers.retrieveSubscription cusId, subId, ( error, customer ) ->
      if error
        console.log error
        retriveSub.return error
      else
        retriveSub.return customer

    retriveSub.wait()

  'paymentsCancelSubscription': ( cusId, subId ) ->
    check cusId, String
    check subId, String

    cancelSubscription = new Future

    Stripe.customers.cancelSubscription cusId, subId, ( error, confirmation ) ->
      if error
        console.log error
        cancelSubscription.return error
      else
        # Call sendCancelSubscription
        cancelSubscription.return confirmation

    cancelSubscription.wait()    

  'updateUserCard': ( update ) ->
    check update,
    token: String
    user: String
    card:
      lastFour: String
      type: String

    if not Meteor.userId()
      throw new Meteor.Error 'invalid-user', "[methods] updateUserCard -> Invalid user"
    
    Meteor.users.update Meteor.userId(), 
      $set: 
        "subscription.payment.card": update.card

  'paymentsUpdateCustomer': () ->
    #stripe.customers.update
  
  'paymentsRetrieveCustomer': () ->
    #stripe.customers.retrieve
  
  'paymentsUpdateCustomerCard': () ->
    #stripe.customers.updateCard
