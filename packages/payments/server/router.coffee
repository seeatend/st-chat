WebApp.connectHandlers.use '/stripe/hook/', (req, res, next) ->

  console.log '-------------- Stripe Webhook Request ----------------'
  console.log req.body.type
  request = req.body
  switch request.type
    when 'customer.subscription.updated'
      updateSubscription request.data.object
    when 'invoice.payment_succeeded'
      createInvoice request.data.object
    # when 'customer.subscription.deleted'
    #   deleteSubscription request.data.object

  res.writeHead(200)
  res.end('success')

updateSubscription = ( request ) ->
	console.log('run update subscription hook')

	getUser = Meteor.users.findOne({ 'customerId': request.customer }, fields: '_id': 1)

	if getUser
    update =
      token : SERVER_TOKEN
      user: getUser._id
      subscription:
        status: if request.cancel_at_period_end then 'canceled' else request.status
        ends: request.current_period_end
        quantity: request.quantity

    Meteor.call 'paymentsUpdateSubscriptionUsingWebHook', update, (error, response) ->
      if error
        console.log error

createInvoice = ( request ) ->
  console.log('run create invoice hook')
  getUser = Meteor.users.findOne({ 'customerId': request.customer }, fields:
    '_id': 1
    'emails.address': 1)

  if getUser
    invoiceItem = request.lines.data[0]
    totalAmount = request.total / 100

    if totalAmount > 0
      invoice = 
        userId: getUser._id
        email: getUser.emails[0].address
        date: request.date
        planId: invoiceItem.plan.id
        ends: invoiceItem.period.end
        quantity:invoiceItem.quantity
        amount: totalAmount
        transactionId: Random.hexString(10)
        createdAt: new Date

      PaymentHistory.insert invoice, (error, response) ->
        if error
          console.log error
        else
        	Meteor.call('sendMonthlyInvoice', getUser._id)

deleteSubscription = ( request ) ->
	console.log('run delete/cancel subscription hook')
	