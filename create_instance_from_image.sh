#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -n <instance_name> -i <ami_id> -t <instance_type> -v <vpc_id> -s <subnet_id> -g <security_group_id> -k <key_pair_name>"
    exit 1
}

# Parse command line options
while getopts ":n:i:t:v:s:g:k:" opt; do
    case $opt in
        n) instance_name="$OPTARG";;
        i) ami_id="$OPTARG";;
        t) instance_type="$OPTARG";;
        v) vpc_id="$OPTARG";;
        s) subnet_id="$OPTARG";;
        g) security_group_id="$OPTARG";;
        k) key_pair_name="$OPTARG";;
        \?) echo "Invalid option: -$OPTARG" >&2; usage;;
        :) echo "Option -$OPTARG requires an argument." >&2; usage;;
    esac
done

# Check if all required options are provided
if [ -z "$instance_name" ] || [ -z "$ami_id" ] || [ -z "$instance_type" ] || [ -z "$vpc_id" ] || [ -z "$subnet_id" ] || [ -z "$security_group_id" ] || [ -z "$key_pair_name" ]; then
    usage
fi

# Create EC2 instance
echo "Creating EC2 instance..."
instance_id=$(aws ec2 run-instances \
    --image-id "$ami_id" \
    --instance-type "$instance_type" \
    --subnet-id "$subnet_id" \
    --security-group-ids "$security_group_id" \
    --key-name "$key_pair_name" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

if [ -z "$instance_id" ]; then
    echo "Failed to create instance. Please check the provided parameters and try again."
    exit 1
fi

echo "Instance $instance_id created successfully."

# Wait for instance to be in 'running' state
echo "Waiting for instance to be in 'running' state..."
aws ec2 wait instance-running --instance-ids "$instance_id"

echo "Instance $instance_id is now running."


#./create_instance_from_image.sh -n "Instance-from-Docker-image" -i ami-0a3a3a4d168aaecc3 -t t2.micro -v vpc-0acf002493d3f12d9 -s subnet-09a569462bb97b7a3 -g sg-0503c8dfc96f49e6f -k Rashbag-key
