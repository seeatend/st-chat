Package.describe({
  summary: "Stripe payments for Stitch",
  version: "0.0.1",
  name: "payments"
});

Package.onUse(function(api) {
  api.versionsFrom('1.0');
  api.use([
    'templating',
    'coffeescript',
    'benjick:stripe',
    'dburles:collection-helpers@1.0.4',
    'aldeed:simple-schema@1.3.3',
    'aldeed:collection2@2.5.0',
    'matb33:collection-hooks@0.7.15',
    'less@2.5.1',
    'reactive-dict',
    'reactive-var',
    'random',
    'tracker',
    'underscore',
    'underscorestring:underscore.string',
    'momentjs:moment@2.10.6',
    'rocketchat:lib@0.0.1',
    'wylio:mandrill@1.0.0'
  ],['client','server']);

  api.use('kadira:flow-router', 'client');
  api.use(['http', 'webapp'],'server');
  
  // COMMON
  api.addFiles([
    'lib/payment.coffee',
    'lib/payment-history.coffee',
    'lib/subscriptions.coffee',
    'lib/hooks.coffee',
  ], ['client','server']);
  
  // CLIENT
  api.addFiles([
    'client/startup.coffee',
    'client/lib/jquery.payment.coffee',
    'client/views/layout.html',
    'client/views/layout.coffee',
    'client/views/subscribe/subscribe.html',
    'client/views/subscribe/subscribe.coffee',
    'client/views/needSubscription/needSubscription.html',
    'client/views/needSubscription/needSubscription.coffee',
    'client/stylesheets/style.less',
  ], 'client');

  // SERVER
  api.addFiles([
    'server/paymentMethods.coffee',
    'server/userMethods.coffee',
    'server/subMethods.coffee',
    'server/notificationsMethods.coffee',
    'server/publish.coffee',
    'server/router.coffee',
    'server/config.coffee',
  ], 'server');
  
  api.export([
    'Subscriptions',
    'PaymentHistory',
    'Currency'
  ]);

});

Npm.depends({
  "body-parser": "1.14.1"
});
