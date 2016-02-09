Template.subscribe.onCreated ->
	self = this
	self.orgSub = new ReactiveVar

	Meteor.call 'getUserSubscription', ( error, result ) ->
		if not error
			if result == null
				self.orgSub.set
					empty: true
			else
				self.orgSub.set
					ready: true
					details: result

Template.subscribe.onRendered ->
	Session.set('ccType',null)
	ServerSession.set('paymentsCreateCustomerError',null)
	ServerSession.set('paymentsCreateSubscriptionError',null)

	Tracker.afterFlush ->
		$('#payment-form').hide()
		Stripe.setPublishableKey(RocketChat.settings.get('Stripe_PublishableKey'))

	Tracker.autorun ->
		createCustomerError = ServerSession.get('paymentsCreateCustomerError')
		createSubscriptionError = ServerSession.get('paymentsCreateSubscriptionError')
		if createCustomerError
			swal {
				title: 'Somthing wrong'
				text: ServerSession.get('paymentsCreateCustomerError')
				html: false
				type: 'error'
				closeOnConfirm: false
			}, ->
				ServerSession.set('paymentsCreateCustomerError', null)
				Meteor._reload.reload()
		
		if createSubscriptionError
			swal {
				title: 'Somthing wrong'
				text: ServerSession.get('paymentsCreateSubscriptionError')
				html: false
				type: 'error'
				closeOnConfirm: false
			}, ->
				ServerSession.set('paymentsCreateSubscriptionError', null)
				Meteor._reload.reload()

Template.subscribe.onDestroyed ->
	Template.instance().orgSub.set()
	ServerSession.set('paymentsCreateCustomerError',null)
	ServerSession.set('paymentsCreateSubscriptionError',null)

Template.subscribe.helpers
	orgSub: ->
		return Template.instance().orgSub.get()

	ccType:->
		return Session.get('ccType')

	billingActiveSelection:->
		return Session.get('billingActiveSelection')

Template.subscribe.events
	'submit #payment-form': ( e, t )->
		e.preventDefault()
		button = $(e.target).find('button.make-payment')
		RocketChat.Button.loading(button)
		orgSub = t.orgSub.get()
		orgSub.empty = false
		t.orgSub.set(orgSub)

		$('.make-payment').prop('disabled', true)
		ccNum = $('[data-stripe="number"]').val()
		expMo = $('[data-stripe="exp-month"]').val()
		expYr = $('[data-stripe="exp-year"]').val()
		cvc = $('[data-stripe="cvc"]').val()
		ccType = $.payment.cardType(ccNum)
		ccValidate = $.payment.validateCardNumber(ccNum)
		expValidate = $.payment.validateCardExpiry(expMo,expYr)
		cvcValidate = $.payment.validateCardCVC(cvc,ccType)
		plan = $("[name=plan]:checked").val()

		if not plan
			toastr.error 'please select frequency for your team'
			RocketChat.Button.reset(button)
			$('.make-payment').prop('disabled', false)
			return null

		if not ccValidate
			toastr.error 'please enter a valid CC'
			RocketChat.Button.reset(button)
			$('.make-payment').prop('disabled', false)
			return null
		else if not expValidate
			toastr.error 'please enter a valid expiry date'
			RocketChat.Button.reset(button)
			$('.make-payment').prop('disabled', false)
			return null
		else if not cvcValidate
			toastr.error 'please enter a valid cvc'
			RocketChat.Button.reset(button)
			$('.make-payment').prop('disabled', false)
			return null
		else
			Stripe.card.createToken(
				number: ccNum,
				exp_month: expMo,
				exp_year: expYr,
				cvc: cvc,
				( status, response ) ->
					token = response.id
				  # TODO Important: Need to customize error msgs when payment faild or card decline
					Meteor.call('paymentsCreateCustomer', token, ( err, customer ) ->
						RocketChat.Button.reset(button)
						if err
							RocketChat.Button.reset(button)
							orgSub.empty = true
							console.log(err)
						else
							customerId = customer.id
							org = Organizations.findOne()
							customerCard = customer.sources.data[0]
							ServerSession.set('paymentsCreateCustomerError',null)

							Meteor.call('paymentsCreateSubscription', customerId, plan, org?.userCount, customerCard, ( error, result ) ->
								if error
									RocketChat.Button.reset(button)
									orgSub.empty = true
									return error
								else
									ServerSession.set('paymentsCreateSubscriptionError',null)
									Meteor.call('getUserSubscription', ( error, res ) ->
										if not error
											orgSub.ready = true
											orgSub.details = res
											$('#payment-form').hide('fast')

										RocketChat.Button.reset(button)
										t.orgSub.set(orgSub)
										swal {
											title: 'Thanks You'
											text: 'Your payment have been placed'
											html: false
											type: 'success'
										}
									)
							)
					)
			)

	'keyup input[name="cc-number"]': ( e, t ) ->
		Session.set('ccType',$.payment.cardType(e.target.value.trim()))

	'click .create-sub': ( e, t ) ->
		if $('#payment-form').css('display') == 'none'
      $('#payment-form').show('fast')
    else
      $('#payment-form').hide('fast')

	#'click .billing-type-radio': ( e, t ) ->
		# console.log $(e.target).val()
		# Session.set('billingActiveSelection', this) and 'active'
