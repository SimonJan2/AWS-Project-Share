#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -i <instance_id> -n <image_name>"
    exit 1
}

# Parse command line options
while getopts ":i:n:" opt; do
    case $opt in
        i) instance_id="$OPTARG";;
        n) image_name="$OPTARG";;
        \?) echo "Invalid option: -$OPTARG" >&2; usage;;
        :) echo "Option -$OPTARG requires an argument." >&2; usage;;
    esac
done

# Check if all required options are provided
if [ -z "$instance_id" ] || [ -z "$image_name" ]; then
    usage
fi

# Stop the instance
echo "Stopping instance $instance_id..."
aws ec2 stop-instances --instance-ids "$instance_id"

# Wait for instance to be in 'stopped' state
echo "Waiting for instance to be in 'stopped' state..."
aws ec2 wait instance-stopped --instance-ids "$instance_id"

# Create image from the stopped instance
echo "Creating image from instance $instance_id..."
image_id=$(aws ec2 create-image --instance-id "$instance_id" --name "$image_name" --output text)

if [ -z "$image_id" ]; then
    echo "Failed to create image. Please check the instance ID and try again."
    exit 1
fi

echo "Image $image_id created successfully."

#run the command
#./create_image.sh -i "i-02ebb743b23c19e3b" -n "Docker-AMI"