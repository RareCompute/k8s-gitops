# nvidia-device-plugin

## Test deployment

```
apiVersion: v1
kind: Pod
metadata:
  name: nvidia-test
  namespace: kube-system
spec:
  restartPolicy: OnFailure
  containers:
    - name: cuda-vector-add
      image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda11.7.1-ubuntu20.04"
      resources:
        limits:
          nvidia.com/gpu: 1
```
