#!/bin/bash

RARE_CLUSTER=${RARE_CLUSTER:-"arc1"}
RARE_NAMESPACE=${RARE_NAMESPACE:-"machine-learning"}

function show_help() {
    echo "Usage: $0 <command> [podname] [options]"
    echo ""
    echo "Commands:"
    echo "  login          Logs into teleport and sets up Kubernetes context"
    echo "  logout         Logs out from teleport"
    echo "  shell, sh      Shell into a specified pod"
    echo "  list, ls       List available pods in the namespace"
    echo "  destroy, rm    Destroy a specified pod and wait for automatic re-deployment"
    echo ""
    echo "Options:"
    echo "  -u, --user      Specify the teleport user"
    echo "  -c, --cluster   Specify the teleport cluster (default: RARE_CLUSTER environment variable)"
    echo "  -n, --namespace Specify the Kubernetes namespace (default: RARE_NAMESPACE environment variable)"
    echo "  -v, --verbose   Show verbose output"
    echo "  -h, --help      Show this help message"
    echo ""
}

function handle_ctrl_c() {
    echo ""
    echo "Exiting gracefully..."
    exit 1
}
trap handle_ctrl_c SIGINT

COMMAND=$1
POD_NAME=$2
VERBOSE="false"
shift

while [[ $# -gt 0 ]]; do
    case "$1" in
        -u|--user)
            TELEPORT_USER="$2"
            shift 2
            ;;
        -c|--cluster)
            TELEPORT_CLUSTER="$2"
            shift 2
            ;;
        -n|--namespace)
            RARE_NAMESPACE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE="true"
            shift
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

function list_pods() {
    echo "Available pods in namespace '$RARE_NAMESPACE':"
    # List pods and clean their names to strip suffixes
    tsh kubectl get pods -n "$RARE_NAMESPACE" -o custom-columns=":metadata.name" | grep -v "NAME" | sed -E 's/-[a-z0-9]+(-[a-z0-9]+)?$//' | while read -r pod; do
        echo "$pod"
    done

    # Add verbose output if the verbose flag is set
    if [[ "$VERBOSE" == "true" ]]; then
        echo ""
        echo "Detailed information for each pod:"
        echo "---------------------------------"
        tsh kubectl get pods -n "$RARE_NAMESPACE" -o custom-columns=":metadata.name" | grep -v "NAME" | while read -r pod; do
            echo "Pod: $pod"
            tsh kubectl describe pod "$pod" -n "$RARE_NAMESPACE" | grep -E "Name:|Namespace:|Status:|Node:|Containers:|Image:"
            echo "---------------------------------"
        done
    fi
    #tsh kubectl get pods -n "$RARE_NAMESPACE" -o custom-columns=":metadata.name" | grep -v "NAME" | sed -E 's/-[a-z0-9]+(-[a-z0-9]+)?$//'
}

function shell_into_pod() {
    if [[ -z "$POD_NAME" ]]; then
        echo "No pod specified. Listing available pods..."
        list_pods
        echo ""
        read -p "Enter the pod name to shell into: " POD_NAME
    fi

    if [[ -z "$POD_NAME" ]]; then
        echo "Error: No pod name provided."
        exit 1
    fi

    POD_TARGET=$(tsh kubectl get pods -n "$RARE_NAMESPACE" -o name | grep $POD_NAME | awk -F '/' '{print $2}')
    MAIN_CONTAINER=$(tsh kubectl get pod "$POD_TARGET" -n "$RARE_NAMESPACE" -o jsonpath="{.spec.containers[0].name}")

    if [[ -z "$MAIN_CONTAINER" ]]; then
        echo "Error: Unable to determine the main container for pod $POD_NAME."
        exit 1
    fi

    echo "Shelling into pod $POD_NAME..."
    tsh kubectl exec -it "$POD_TARGET" -n "$RARE_NAMESPACE" -c "$MAIN_CONTAINER" -- /bin/bash
}

function destroy_pod() {
    if [[ -z "$POD_NAME" ]]; then
        echo "No pod specified. Listing available pods..."
        list_pods
        echo ""
        read -p "Enter the pod name to destroy: " POD_NAME
    fi

    if [[ -z "$POD_NAME" ]]; then
        echo "Error: No pod name provided."
        exit 1
    fi

    POD_TARGET=$(tsh kubectl get pods -n "$RARE_NAMESPACE" -o name | grep $POD_NAME | awk -F '/' '{print $2}')
    echo "Destroying pod $POD_NAME..."
    tsh kubectl delete pod "$POD_TARGET" -n "$RARE_NAMESPACE"

    echo "Waiting for pod $POD_NAME to be re-deployed..."
    START_TIME=$(date +%s)
    TIMEOUT=60

    while true; do
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
        # Check if the pod exists and is running
        NEW_POD=$(tsh kubectl get pods -n "$RARE_NAMESPACE" -o name | grep "$POD_NAME")
        if [[ -n "$NEW_POD" ]]; then
            echo "Pod $POD_NAME ready in $ELAPSED_TIME seconds"
            if [[ "$VERBOSE" == "true" ]]; then
              echo "The new pod is identified by $NEW_POD"
            fi
            break
        fi

        # Check for timeout
        if [[ $ELAPSED_TIME -ge $TIMEOUT ]]; then
            echo "Error: Timeout reached while waiting for pod $POD_NAME to be re-deployed."
            exit 1
        fi

        sleep 5  # Wait 5 seconds before checking again
    done

}

if [[ "$COMMAND" == "login" ]]; then
    if [[ -z "$TELEPORT_USER" ]]; then
        echo "Error: --user is required for login"
        show_help
        exit 1
    fi
    echo "                                                            "
    echo "▗▄▄▖  ▗▄▖ ▗▄▄▖ ▗▄▄▄▖     ▗▄▄▖ ▗▄▖ ▗▖  ▗▖▗▄▄▖ ▗▖ ▗▖▗▄▄▄▖▗▄▄▄▖"
    echo "▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▐▌       ▐▌   ▐▌ ▐▌▐▛▚▞▜▌▐▌ ▐▌▐▌ ▐▌  █  ▐▌   "
    echo "▐▛▀▚▖▐▛▀▜▌▐▛▀▚▖▐▛▀▀▘    ▐▌   ▐▌ ▐▌▐▌  ▐▌▐▛▀▘ ▐▌ ▐▌  █  ▐▛▀▀▘"
    echo "▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▐▙▄▄▖    ▝▚▄▄▖▝▚▄▞▘▐▌  ▐▌▐▌   ▝▚▄▞▘  █  ▐▙▄▄▖"
    echo "                                                            "
    echo "                                                            "                                                           
    echo "Logging into teleport..."
    echo ""
    tsh login --proxy="teleport.rarecompute.io:443" --auth=local --user="$TELEPORT_USER" teleport.rarecompute.io

    echo "Setting KUBECONFIG..."
    export KUBECONFIG=~/teleport-kubeconfig.yaml
    tsh kube login $RARE_CLUSTER

    echo "Setting namespace to $RARE_NAMESPACE..."
    kubectl config set-context "$(kubectl config current-context)" --namespace="$RARE_NAMESPACE"

    echo ""
    echo "Login complete! If you run into any issues, try running:"
    echo ""
    echo "tsh kube login $RARE_CLUSTER"
    echo ""
    echo "-------------------------------------------------------------------------------"
    echo ""
    echo "Run the below command to finalize:"
    echo ""
    echo "export KUBECONFIG=~/teleport-kubeconfig.yaml"
    echo ""
elif [[ "$COMMAND" == "logout" ]]; then
    echo "Logging out of teleport..."
    tsh logout
    echo "Logout complete!"
elif [[ "$COMMAND" == "shell" || "$COMMAND" == "sh" ]]; then
    shell_into_pod
elif [[ "$COMMAND" == "list" || "$COMMAND" == "ls" ]]; then
    list_pods
elif [[ "$COMMAND" == "destroy" || "$COMMAND" == "rm" ]]; then
    destroy_pod
else
    echo "Unknown command: $COMMAND"
    show_help
    exit 1
fi
