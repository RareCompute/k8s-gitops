#!/bin/bash

list_pods() {
    echo "Listing pods in the 'machine-learning' namespace..."
    kubectl get pods -n machine-learning
}

shell_into_pod() {
    local pod_name=$1
    if [[ -z "$pod_name" ]]; then
        echo "Error: You must specify a pod name."
        return 1
    fi
    echo "Starting shell in pod '$pod_name'..."
    kubectl exec -it "$pod_name" -n machine-learning -- /bin/bash
}

restart_pod() {
    local pod_name=$1
    if [[ -z "$pod_name" ]]; then
        echo "Error: You must specify a pod name."
        return 1
    fi
    echo "Restarting pod '$pod_name'..."
    kubectl delete pod "$pod_name" -n machine-learning
}

show_help() {
    cat << EOF
Usage: rare <command> [PODNAME]

Commands:
  ls                 List all pods in the 'machine-learning' namespace.
  shell <PODNAME>    Shell into the specified pod.
  restart <PODNAME>  Restart the specified pod.
  help               Show this help message.

Examples:
  rare ls
  rare shell my-pod-name
  rare restart my-pod-name
EOF
}

rare() {
    local command=$1
    shift

    case "$command" in
        ls)
            list_pods
            ;;
        shell)
            shell_into_pod "$@"
            ;;
        restart)
            restart_pod "$@"
            ;;
        help|""|-h|--help)
            show_help
            ;;
        *)
            echo "Error: Unknown command '$command'."
            show_help
            return 1
            ;;
    esac
}

export -f rare
