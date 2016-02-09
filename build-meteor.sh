set -e

if [ $# -lt 1 ]
	then
  echo "USAGE"
  echo "./build-meteor.sh server-url"
  echo ""
  exit 1
fi


# Run only when server parameter is passed
meteor build ../stitch-deploy/.deploy --architecture os.linux.x86_64 --server $1

cd ../stitch-deploy
git add ./.deploy/stitch-app.tar.gz
git commit -m 'AUTOMATED: Commiting bundle for deployment'
git push

# Build and deploy a docker
git push aptible HEAD --force

cd ../stitch-app