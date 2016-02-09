# Schema = if typeof Schema == 'undefined' then {} else Schema

# Schema.PaymentHistory = new SimpleSchema(
#   userId:
#     type: String
#   userId:
#     type: String
#   status:
#     type: String
#     allowedValues: ['Refunded','Complete','Pending','Error','WaitingInfo']
#   chargeId:
#     type: String
#   type:
#     type: String
#     allowedValues: ['Credit','Charge']
#   amount:
#     type: Number
#   fee:
#     type: Number
#   datetime:
#     type: Date
# )

PaymentHistory = new (Mongo.Collection)('PaymentHistory')
#PaymentHistory.attachSchema Schema.PaymentHistory