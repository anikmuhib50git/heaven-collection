# heaven-collection

A self-contained single-page fashion storefront — product grid, cart sidebar, newsletter —
built as one static HTML file. No server, no build step, no dependencies.

```
heaven-collection/
├── website/
│   └── heaven-collection.html   # the entire app
├── Dockerfile                    # packages it behind nginx
└── k8s/
    └── deployment.yaml           # Namespace, Deployment, Service, Ingress
```

The image is built and pushed automatically to GitHub Container Registry on every push
to `main` (see `.github/workflows/deploy.yaml`), tagged both `:latest` and with the
commit SHA:

```
ghcr.io/anikmuhib50git/heaven-collection
```

---

## Option 1: Just open the file

No install, no server:

```bash
open website/heaven-collection.html
```

## Option 2: Run it with Docker

```bash
docker build -t heaven-collection .
docker run --rm -p 8080:80 heaven-collection
```

Open http://localhost:8080.

## Option 3: Run it on minikube

**Prerequisites:** minikube and kubectl installed, Docker Desktop running.

1. Start minikube and enable the ingress addon (skip if already done — this only
   needs to happen once per cluster):
   ```bash
   minikube start --driver=docker
   minikube addons enable ingress
   ```

2. Apply the manifests — this creates the `heaven-collection` namespace, a
   2-replica Deployment pulling `ghcr.io/anikmuhib50git/heaven-collection:latest`,
   a ClusterIP Service, and an Ingress for `heaven.local`:
   ```bash
   kubectl apply -f k8s/deployment.yaml
   ```

3. Watch the pods come up:
   ```bash
   kubectl get pods -n heaven-collection -w
   ```
   Press Ctrl+C once both show `1/1 Running`.

4. Point your Mac at the Ingress host. This only needs to be done once:
   ```bash
   echo "127.0.0.1 heaven.local" | sudo tee -a /etc/hosts
   ```

5. In a separate terminal, start the tunnel and leave it running (it may ask for
   your Mac password):
   ```bash
   minikube tunnel
   ```

6. Open **http://heaven.local** in your browser.

### Deploying a newer image

The Deployment always points at the `:latest` tag with `imagePullPolicy: Always`,
so once a new image has been pushed by CI, pulling the newest version into the
cluster is one command — no need to edit `k8s/deployment.yaml`:

```bash
kubectl rollout restart deployment/heaven-collection-deployment -n heaven-collection
```

### Cleanup

```bash
kubectl delete -f k8s/deployment.yaml
minikube stop           # or: minikube delete, to remove the cluster entirely
```
