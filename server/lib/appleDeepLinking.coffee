# Picker.route '/apple-app-site-association', ( params, req, res, next ) ->
#   Fiber = Npm.require('fibers')
  
#   Fiber(->
#     applinks = Assets.getText('apple-app-site-association')
#     console.log '-------------- Apple universal link request ----------------'
#     res.writeHead(200 ,
#       'Content-Type': 'application/pkcs7-mime'
#     )
#     res.end(applinks)
#   ).run()
#   