package main

deny[msg] {
    input.kind = "Service"
    not input.spec.type = "NodePort"
    msg = sprintf("Service %s is not of type NodePort", [input.metadata.name])
}

deny[msg] {
    input.kind = "Deployment"
    not input.spec.template.spec.containers[0].securityContext.runAsNonRoot = true
    msg = sprintf("Container in Deployment %s is not running as non-root", [input.metadata.name])
}
