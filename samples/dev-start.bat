k3d cluster delete k3s-default
k3d cluster create --agents=3 --volume /tmp/out:c:\out@agent[0,1,2]
kubectl config use-context k3d-k3s-default
kubectl cluster-info
kubectl create ns argo
kubectl apply -n argo --wait=true -f quick-start-postgres.yml
kubectl rollout status deployment/argo-server -n argo
docker pull groupsinfra/gocd-agent-centos-8-groups:v21.2.0-groups-0.5.8
k3d image import groupsinfra/gocd-agent-centos-8-groups:v21.2.0-groups-0.5.8
argo submit -n argo --log argo-artifact.yml
