# Kubernetes Hands-On Command Guide

Use the aliases below with the AKS kubeconfig you retrieved via Terraform outputs (`kube_config_raw`). Replace placeholder names (namespace, deployment, etc.) with real values from your cluster.

---

## Cluster Familiarisation
- `kubectl config get-contexts` — list every configured cluster context.
- `kubectl cluster-info` — check API server endpoints.
- `kubectl get componentstatuses` — legacy health check; still useful in interviews.
- `kubectl api-resources | head` — understand what the API server exposes.
- `kubectl get nodes -o wide` — inspect node size, OS image, zones and readiness.
- `kubectl describe node <node-name>` — deep-dive on kubelet configuration and allocatable resources.

## Namespaces & Access
- `kubectl get ns` and `kubectl create ns demo` — manipulate namespaces.
- `kubectl config set-context --current --namespace=demo` — scope commands to one namespace.
- `kubectl auth can-i create pods --as system:serviceaccount:demo:app-sa` — RBAC check.
- `kubectl describe rolebinding <name>` — inspect bindings during troubleshooting.

## Workload CRUD
- `kubectl apply -f manifests/app.yaml` — declarative deployment (practice editing live resources).
- `kubectl create deployment web --image=nginx --replicas=2` — quick imperative deployment.
- `kubectl get deploy,pods -n demo` — watch rollout status.
- `kubectl describe deploy web` — understand strategy, events, conditions.
- `kubectl rollout status deploy/web` / `kubectl rollout undo deploy/web` — upgrade recovery.
- `kubectl scale deploy web --replicas=4` — horizontal scaling.
- `kubectl set image deploy/web nginx=nginx:1.27` — zero-downtime image swap.
- `kubectl delete deploy web --cascade=orphan` — delete while keeping pods for debugging.

## Pods & Debugging
- `kubectl exec -it pod-name -- ls /app` — inspect running containers.
- `kubectl exec -it pod-name -- sh` — interactive debug shell (practice busybox / alpine fallback if image lacks shell).
- `kubectl logs pod-name` / `-f` — streaming logs.
- `kubectl logs pod-name -c sidecar` — multi-container pods.
- `kubectl cp pod-name:/var/log/app.log ./app.log` — retrieve artifacts.
- `kubectl describe pod pod-name` — event timeline for crashloops.
- `kubectl get events --sort-by=.lastTimestamp` — cluster-wide event review.
- `kubectl debug pod-name -it --image=busybox` (Kubernetes ≥1.23) — ephemeral containers for forensics.

## Config & Secrets
- `kubectl create configmap app-config --from-file=config/` — multi-file config.
- `kubectl get configmap app-config -o yaml` — verify mounted configuration.
- `kubectl create secret generic db-credentials --from-literal=username=demo` — secret management.
- `kubectl apply -f manifests/secret-env.yaml` — practise envFrom & projected volumes.
- `kubectl rollout restart deploy web` — reload pods after config change.

## Networking
- `kubectl get svc,ingress -n demo` — service surface.
- `kubectl port-forward svc/web 8080:80` — local debugging.
- `kubectl exec pod-name -- curl -s http://svc-name:port/health` — service-to-service checks.
- `kubectl get endpointslice -n demo` — endpoint distribution across nodes.
- `kubectl describe ingress web` — ingress controller annotations and SSL info.
- `kubectl get networkpolicy -n demo` / apply sample policies to verify enforcement.

## Storage
- `kubectl get sc` — storage classes, understand AKS defaults (`managed-csi`).
- `kubectl apply -f manifests/pvc.yaml` — claim persistent storage.
- `kubectl describe pvc data-pvc` — capacity, access modes, binding status.
- `kubectl get pv` — confirm dynamic provisioning results.
- `kubectl delete pvc data-pvc` — watch PV lifecycle (retained, deleted, recycled).

## Batch & Autoscaling
- `kubectl create job pi --image=perl -- perl -Mbignum=bpi -wle 'print bpi(2000)'`
- `kubectl get jobs -w` — jobs succeed/fail states.
- `kubectl create cronjob cleanup --image=busybox --schedule="*/5 * * * *" -- echo 'hi'`
- `kubectl autoscale deploy web --min=2 --max=6 --cpu-percent=70`
- `kubectl get hpa` — monitor Horizontal Pod Autoscaler.

## Cluster Maintenance
- `kubectl cordon <node>` / `kubectl drain <node> --ignore-daemonsets --delete-emptydir-data` — safe node maintenance sequence.
- `kubectl uncordon <node>` — return node to service.
- `kubectl top nodes` / `kubectl top pods` — resource utilisation (metrics-server required).
- `kubectl taint nodes <node> key=value:NoSchedule` — control scheduling, then remove (`-` suffix).

## Security & Policy
- `kubectl get podsecuritypolicy` (deprecated but still asked historically).
- `kubectl get podsecurityadmissionconfigurations` or check namespace labels for PSP replacements.
- `kubectl create serviceaccount app-sa` and bind roles; practice JWT retrieval from projected volume.
- `kubectl exec pod -- cat /var/run/secrets/kubernetes.io/serviceaccount/token` — verify service account tokens.
- `kubectl get certificate` (if cert-manager installed) — TLS lifecycle.

## Observability & Troubleshooting
- `kubectl get pods --all-namespaces -o wide` — quick cluster health scan.
- `kubectl get nodes -L agentpool,topology.kubernetes.io/zone` — ensure your worker pool (when re-enabled) spreads across zones.
- `kubectl get lease -n kube-system` — look at leader election.
- `kubectl get crd | head` — understand installed operators.
- `kubectl describe daemonset kube-proxy -n kube-system` — inspect core add-ons.
- `kubectl get deployment -n kube-system coredns -o yaml` — check cluster DNS configuration.

## GitOps & Workload Delivery
- `kubectl diff -f manifests/` — dry-run compare before apply (mirrors `terraform plan` for workloads).
- `kubectl apply --server-side` — server-side apply practice for GitOps tools compatibility.
- `kubectl label namespace demo istio-injection=enabled` — service mesh onboarding example.
- `helm repo add bitnami https://charts.bitnami.com/bitnami` & `helm upgrade --install redis bitnami/redis` — helm-based delivery (common interview topic).

## Cleanup & Verification
- `kubectl delete ns demo --wait=false` — asynchronous namespace cleanup.
- `kubectl get namespace demo -o jsonpath='{.status.phase}'` — watch termination.
- `kubectl delete pvc --all -n demo` / `kubectl delete pv --wait=false` — data lifecycle consistency.
- `kubectl get all -A` — final check before destroying infrastructure.

---

### Practice Tips
1. **Script It** – write shell scripts for common tasks (deployment, rollback, smoke tests). Interviewers like seeing automation.
2. **Break & Fix** – intentionally misconfigure resources (bad image, port, env var) and recover using `describe` + `logs`.
3. **Trace RBAC** – create a service account, bind roles, and test allowed/denied operations with `kubectl auth can-i`.
4. **Record Sessions** – capture command output (e.g., `script` command) to build a personal runbook or knowledge base.
5. **Use Namespaces Per Scenario** – keeps practice isolated and highlights multi-tenant operations.

Rehearse these commands until you can explain not just *how* to run them, but *why* they matter for cluster management, day-two operations, and incident recovery—common pillars in technical interviews.
