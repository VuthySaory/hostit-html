#!/bin/bash

# Define the image name
# IMAGE_NAME="knoeurn/html_dev_ops_images"
IMAGE_NAME=$1

# Get all image IDs for the given image
IMAGE_IDS=$(docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | grep "^${IMAGE_NAME}:" | awk '{print $2}')

# Check if any images exist
if [ -z "$IMAGE_IDS" ]; then
    echo "No images found for ${IMAGE_NAME}."
    exit 0
fi

# Loop through each image ID
for IMAGE_ID in $IMAGE_IDS; do
    # Check if the image is in use by any running container
    if docker ps --format "{{.Image}}" | grep -q "$IMAGE_ID"; then
        echo "Skipping running image: $IMAGE_ID"
    else
        echo "Removing unused image: $IMAGE_ID"
        docker rmi -f "$IMAGE_ID"
    fi
done

echo "Cleanup completed!"
