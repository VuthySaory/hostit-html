# Variable 
CONTAINER_NAME=$1

docker ps -q --filter "name=$CONTAINER_NAME" | grep -q . && docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME || echo "No running container to remove"