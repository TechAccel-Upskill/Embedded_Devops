# Kubernetes manifests for the embedded OS Kubernetes Orchestrator
# This directory contains all deployment and service configurations

## Files:
## - namespace.yaml         - Kubernetes namespace for all embedded OS applications
## - services.yaml          - Service definitions for FreeRTOS, Mbed, and Zephyr apps
## - freertos-deployment.yaml  - FreeRTOS application deployment
## - mbed-deployment.yaml      - Mbed application deployment
## - zephyr-deployment.yaml    - Zephyr application deployment

## To deploy all applications:
## kubectl apply -f .

## To check the status:
## kubectl get pods -n embedded-os
## kubectl get services -n embedded-os

## To view logs:
## kubectl logs -n embedded-os <pod-name>

## To delete all:
## kubectl delete namespace embedded-os
