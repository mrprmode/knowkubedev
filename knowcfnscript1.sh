#!/bin/bash
echo " Setting up KnowEnG-Platform K8S Cluster  | Roughly 25 mins "
sleep 2

echo " Installing kubectl "
sleep 2
sudo apt-get update && sudo apt-get install -y apt-transport-https && \
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list && \
  sudo apt-get update && \
  sudo apt-get install -y kubectl
echo "Done"

echo
echo " Authorizing kubectl "
sleep 2
echo 'KUBECONFIG=/home/ubuntu/kubeconfig' | sudo tee -a /etc/profile.d/kubeconfig.sh >> /dev/null
scp master:/home/ubuntu/kubeconfig .
export KUBECONFIG=/home/ubuntu/kubeconfig
echo "Done"

echo
echo " EFS Provisioner "
sleep 2
kubectl apply -f efs-provisioner.yaml
echo "Done"

echo
echo " EFS RBAC "
sleep 2
kubectl apply -f https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/aws/efs/deploy/rbac.yaml
echo "Done"

echo
echo " PVCs - networks "
sleep 2
kubectl apply -f https://raw.githubusercontent.com/prkriz/knowkubedev/master/pvcs/networks.pvc.yaml
echo "Done"

echo
echo " PVCs - postgres "
sleep 2
kubectl apply -f https://raw.githubusercontent.com/prkriz/knowkubedev/master/pvcs/postgres.pvc.yaml
echo "Done"

echo
echo " PVCs - redis"
sleep 2
kubectl apply -f https://raw.githubusercontent.com/prkriz/knowkubedev/master/pvcs/redis.pvc.yaml
echo "Done"

echo
echo " PVCs - userfiles "
sleep 2
kubectl apply -f https://raw.githubusercontent.com/prkriz/knowkubedev/master/pvcs/userfiles.pvc.yaml
echo "Done"


echo
echo " Seeding Knowledge Network | Takes about 5-10 minutes "
sleep 2
ssh -t master "sudo mkdir efs"
sleep 3
ssh -t master "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $EFS_DNS:/ efs"
sleep 5
KNOW_NET_DIR=$(ssh -t master "sudo find efs/ -type d -name \"efs-networks*\"")
sleep 2
ssh -t master "sudo aws s3 cp --recursive s3://KnowNets/KN-20rep-1706/userKN-20rep-1706/ $KNOW_NET_DIR/"
echo "Done"

echo
echo " Pods RBAC "
sleep 2
kubectl apply -f https://raw.githubusercontent.com/prkriz/knowkubedev/master/nest.rbac.yaml
echo "Done"

echo
echo " Deploying KnowEnG pods "
sleep 2
kubectl apply -f https://raw.githubusercontent.com/prkriz/knowkubedev/master/nest.prod.yaml
echo "Done"

echo
echo " Getting things ready, takes 20 minutes "
i=20; while [ $i -gt 0 ]; do echo $i minute\(s\) remaining; i=`expr $i - 1`; sleep 60;  done
kubectl expose --namespace=default deployment nest --type=LoadBalancer --port=80 --target-port=80 --name=nest-public-lb
echo "Done"

echo
echo "Load Balancer URL"
kubectl --namespace=default describe service nest-public-lb | grep "LoadBalancer Ingress"
echo " Congratulations-- KnowEnG Platform IS READY TO ROLL. Thank You for your patience. "
