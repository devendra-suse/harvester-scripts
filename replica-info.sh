#!/bin/bash

# Check if VM name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <vm-name>"
  exit 1
fi

VM_NAME="$1"

echo "Fetching PVCs for VM: $VM_NAME..."
PVC_LIST=$(kubectl get vm "$VM_NAME" -o jsonpath="{.spec.template.spec.volumes[*].persistentVolumeClaim.claimName}")

if [ -z "$PVC_LIST" ]; then
  echo "No PVCs found for VM: $VM_NAME"
  exit 1
fi

echo "PVCs found:"
echo "$PVC_LIST"
echo "--------------------------------------------"

echo "Fetching PVs for the PVCs..."
PV_LIST=$(kubectl get pvc $PVC_LIST -o custom-columns="PVC:.metadata.name,PV:.spec.volumeName" | awk 'NR>1 {print $2}')

if [ -z "$PV_LIST" ]; then
  echo "No PVs found for the given PVCs."
  exit 1
fi

echo "PVs found:"
echo "$PV_LIST"
echo "--------------------------------------------"

echo "Fetching replica details for the PVs..."
for PV in $PV_LIST; do
  echo "Replica details for PV: $PV"
  kubectl get replicas -A -o wide | grep "$PV" || echo "No replicas found for PV: $PV"
  echo "--------------------------------------------"
done

