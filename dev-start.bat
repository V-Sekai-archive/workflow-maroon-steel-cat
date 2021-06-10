k3d cluster delete k3s-default
;; Make c:\out
k3d cluster create --agents=3 --volume c:\out:/mnt/out@agent[0,1,2]
kubectl config use-context k3d-k3s-default
kubectl cluster-info
kubectl create ns argo
kubectl apply -n argo --wait=true -f quick-start-postgres.yml
kubectl rollout status deployment/argo-server -n argo
argo submit -n argo --watch argo-artifact.yml
