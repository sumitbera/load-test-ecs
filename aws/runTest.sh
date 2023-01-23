NUMBER_OF_INSTANCES=$1

CLUSTER_NAME=userServiceTest
REGION=us-east-1
TASH_NAME=loadTestTask

aws ecs run-task --cluster  $CLUSTER_NAME --task-definition $TASK_NAME \
        --region $REGION --output json --launch-type EC2 \
        --count $NUMBER_OF_INSTANCES 