#!/bin/bash

# Namespace where the pods are located
NAMESPACE="machine-learning"

# Function to list all pods in the specified namespace
list_pods() {
    echo "Listing pods in the '$NAMESPACE' namespace..."
    kubectl get pods -n "$NAMESPACE"
}

# Helper function to find a pod based on a partial name or regex pattern
find_pod() {
    local pattern="$1"
    local pods
    local count

    # Fetch all pod names and filter based on the pattern
    pods=$(kubectl get pods -n "$NAMESPACE" --no-headers -o custom-columns=NAME:.metadata.name | grep "$pattern")

    # Count the number of matching pods
    count=$(echo "$pods" | grep -c .)

    if [[ -z "$pods" ]]; then
        echo "Error: No pods found matching pattern '$pattern'."
        return 1
    elif [[ "$count" -eq 1 ]]; then
        echo "$pods"
    else
        echo "Multiple pods found matching pattern '$pattern':"
        echo "$pods"
        read -p "Please enter the full pod name: " selected_pod
        # Verify that the selected pod is in the list
        if echo "$pods" | grep -qw "$selected_pod"; then
            echo "$selected_pod"
        else
            echo "Error: Pod '$selected_pod' not found in the matching list."
            return 1
        fi
    fi
}

# Function to shell into a pod
shell_into_pod() {
    local pattern="$1"
    if [[ -z "$pattern" ]]; then
        echo "Error: You must specify a pod name or pattern."
        return 1
    fi

    local pod_name
    pod_name=$(find_pod "$pattern") || return 1

    echo "Starting shell in pod '$pod_name'..."
    kubectl exec -it "$pod_name" -n "$NAMESPACE" -- /bin/bash
}

# Function to restart a pod by deleting it
restart_pod() {
    local pattern="$1"
    if [[ -z "$pattern" ]]; then
        echo "Error: You must specify a pod name or pattern."
        return 1
    fi

    local pod_name
    pod_name=$(find_pod "$pattern") || return 1

    echo "Restarting pod '$pod_name'..."
    kubectl delete pod "$pod_name" -n "$NAMESPACE"
}

# Function to display help information
show_help() {
    cat << EOF
VERSION:  0.0.1

NOTE:     This machine has 1GB of persistent storage. A 2TB persistent volume is
          mounted in: /workspace

          File tools are included in this Alpine distribution, including: rsync,
          git, socat, aria2, wget, curl, unzip, and restic.

          Please contact Liana <liana@rarecompute.io> for requests.

USAGE:    rare <command> [PATTERN]

          Commands:
              ls                 List all pods in the '$NAMESPACE' namespace
              shell <PATTERN>    Shell into a pod matching the specified pattern
              restart <PATTERN>  Restart a pod matching the specified pattern
              help               Show this help message.

          Patterns:
              You can specify a full pod name, a partial name, or a regex pattern
              to match pods.

          Examples:
              rare ls
              rare shell boltz
              rare restart boltz
EOF
}

# Main function to handle commands
rare() {
    local command="$1"
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

# Export the rare function to make it available in the shell
export -f rare
