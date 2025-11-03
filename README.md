# Rally MLOps on AKS

I’m building an end-to-end rally analytics platform on Azure Kubernetes Service (AKS). Terraform drives all infra, and everything else lives as code in this repo.

## What’s live right now
- Terraform Cloud + modules for AKS, ACR, storage, and Key Vault (`infra/aks`, `infra/modules/*`).
- AKS cluster is up with the system node pool; worker pool is paused while I sort out spot/VCU quota.
- ACR, blob containers, and Key Vault provision cleanly and tag consistently.
- Docs for day‑one cluster ops (`docs/guides/TROUBLESHOOTING.md`, `docs/guides/KUBERNETES_PRACTICE.md`).

## Lessons & Decisions
- Azure capacity is fickle: keep a list of fallback VM SKUs and plan for quota bumps.
- Spot pools can’t use upgrade surge; need explicit overrides when they come back.
- Managed identities everywhere; no static creds. Purge protection is on for Key Vault.
- Git-first workflow but not full GitOps yet (manual `terraform apply` until CI is wired).

## What’s next
1. Re-enable worker pool once quota is approved or migrate to a friendlier region.
2. Layer in Airflow + ML pipeline (Weeks 2–3 work).
3. Expose FastAPI inference service and hook up monitoring stack (Grafana/Prometheus/Loki).
4. Tighten GitOps story: CI plans, automated applies, and workload delivery via Helm.

## Repo tour
```
infra/         Terraform (AKS, modules)
docs/          Runbooks, plans, how-to guides
airflow/       DAG scaffolding (to be filled in)
ml/            Feature engineering + clustering code
inference/     FastAPI service + K8s manifests
monitoring/    Prometheus / Grafana / Loki configs
```

## Handy commands
```bash
# Terraform
cd infra/aks
terraform init
terraform plan -var-file=terraform.dev.tfvars

# Grab kubeconfig for AKS
az aks get-credentials --resource-group rally-mlops-rg-dev --name rally-mlops-aks-dev
kubectl get nodes
```

## Roadmap snapshot
- ✅ Week 1: AKS infra, storage, registry, Key Vault, docs.
- 🔄 In progress: worker pool tweaks, quota requests.
- ⏳ Week 2–3: Airflow pipeline, data processing, ML experiments.
- ⏳ Week 4: FastAPI deploy, monitoring stack, CI/CD polish.

MIT licensed. Contributions welcome once the core plumbing settles.
