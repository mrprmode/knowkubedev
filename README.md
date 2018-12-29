# knowkubedev
Kubernetes Deployment files to setup KnowKubeDev (KnowEng Platform Dev Cluster)

# To launch CFN:

## Create a ssh key-pair in a desired region
# Launch CFN in the desired region. Takes about 5 minutes

# Local- move keypair to bastion from local
`scp -i {path/to/keypair}.pem {path/to/keypair}.pem ubuntu@{BASTION_IP}:/home/ubuntu/.ssh/`

# Bastion- contents of $HOME/.ssh/config
```
Host master
    HostName {MASTER_PRIVATE_IP}
    Port 22
    User ubuntu
    IdentityFile ~/.ssh/{keypair}.pem
```

# AWS Console- Create EFS under master's VPC and cluster security group. Takes about 3 minutes

# Bastion- Export EFS
`export EFS_DNS=fs-1bf82802.efs.us-west-1.amazonaws.com`

# Bastion- Modify efs id, availability zone, and efs server
`wget https://raw.githubusercontent.com/prkriz/knowkubedev/master/efs-provisioner.yaml`

# Bastion- Run the KNOWENG_INIT_FILE
`./knowcfnscript`

# Clean Resources/Stack
## Delete EFS mount targets and optionally, efs.
## Delete the load balancer exposed by kubectl
`kubectl delete svc nest-public-lb`
## Delete the non-nested stack from AWS Cloudformation Console
