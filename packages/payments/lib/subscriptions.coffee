# Schema = if typeof Schema == 'undefined' then {} else Schema

# Schema.card = new SimpleSchema(
#   lastFourDigit:
#   	type: Number
#   type:
#   	type: String
# )

# Schema.subscription = new SimpleSchema(
#   orgId:
#   	type: String
#   userId:
#   	type: String
#   auth:
#   	type: String
#   planName:
#   	type: String
#   nextPaymentDue:
#   	type: Date
#   status:
#   	type: String
#   	allowedValues:['trialing','active','past_due','canceled','unpaid']
#   ends:
#   	type: Date
#   paymentCard:
#   	type: [ Schema.card ]
# )

Subscriptions = new (Mongo.Collection)('subscription')
#Subscriptions.attachSchema Schema.subscription