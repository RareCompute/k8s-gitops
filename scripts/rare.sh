#!/bin/bash
function show_help() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  login          Logs into teleport and sets up Kubernetes context"
    echo "  logout         Logs out from teleport"
    echo "  qlora          Executes into the qlora pod in the machine-learning namespace"
    echo ""
    echo "Options:"
    echo "  -u, --user      Specify the teleport user"
    echo "  -n, --namespace Specify the Kubernetes namespace (default: machine-learning)"
    echo "  -h, --help      Show this help message"
    echo ""
}

# Default values
NAMESPACE="machine-learning"

# Parse arguments
COMMAND=$1
shift

while [[ $# -gt 0 ]]; do
    case "$1" in
        -u|--user)
            USER="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

if [[ "$COMMAND" == "login" ]]; then
    if [[ -z "$USER" ]]; then
        echo "Error: --user is required for login"
        show_help
        exit 1
    fi

    echo "Logging into teleport..."
    tsh login --proxy=teleport.rarecompute.io:443 --auth=local --user="$USER" teleport.rarecompute.io

    echo "Setting KUBECONFIG..."
    export KUBECONFIG=~/teleport-kubeconfig.yaml
    echo "Logging into Kubernetes cluster..."
    tsh kube login arc1

    echo "Setting namespace to $NAMESPACE..."
    kubectl config set-context "$(kubectl config current-context)" --namespace="$NAMESPACE"

    echo "Login complete!"
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""
    echo "Run the following command in your shell to finalize:"
    echo "export KUBECONFIG=~/teleport-kubeconfig.yaml"
elif [[ "$COMMAND" == "logout" ]]; then
    echo "Logging out of teleport..."
    tsh logout
    echo "Logout complete!"
elif [[ "$COMMAND" == "qlora" ]]; then
    echo "Finding qlora pod..."
    POD_NAME=$(tsh kubectl get pods -n "$NAMESPACE" -o name | grep qlora | awk -F '/' '{print $2}')
    if [[ -z "$POD_NAME" ]]; then
        echo "Error: No qlora pod found in namespace $NAMESPACE"
        exit 1
    fi

    echo "Executing into pod $POD_NAME..."
    tsh kubectl exec -it "$POD_NAME" -n "$NAMESPACE" -- /bin/bash
else
    echo "Unknown command: $COMMAND"
    show_help
    exit 1
fi