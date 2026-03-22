ExternalDNS GitHub: https://github.com/kubernetes-sigs/external-dns

ExternalDNS Artifacthub: https://artifacthub.io/packages/helm/bitnami/external-dns

Install ExternalDNS using Helm:

```helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/```

```helm repo update external-dns```

```helm search repo external-dns/external-dns```

```helm install external-dns external-dns/external-dns -n kube-system --version 1.19.0 -f external-dns-values.yaml ```

Note: https://github.com/kubernetes-sigs/external-dns/blob/v0.12.2/docs/registry.md