Meteor.startup ->
  if RocketChat.settings.get('API_Segment_KEY')
    analytics.load(RocketChat.settings.get('API_Segment_KEY'))

  Tracker.autorun (c) ->
    if !FlowRouter.subsReady()
      return

    user = Meteor.user()
    if !user
      return

    analytics.identify user._id,
      name: user.displayName
      email: user.emails[0].address

    c.stop()