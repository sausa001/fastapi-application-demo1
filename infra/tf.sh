#Helper Script to run terraform commands in the infra directory. This script will automatically set the correct working directory and environment variables for terraform commands.
#!/usr/bin/env bash
# Usage: ./infra/tf.sh <env> <stack> <init|plan|apply|destroy|output> [extra terraform args]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
ENV="${1:?env}"; STACK="${2:?stack}"; ACTION="${3:?action}"; shift 3

STACK_DIR="$ROOT/stacks/$STACK"
ENV_DIR="$ROOT/envs/$ENV"
[[ -d "$STACK_DIR" ]] || { echo "No stack: $STACK"; exit 1; }
[[ -d "$ENV_DIR"   ]] || { echo "No env: $ENV";   exit 1; }

cd "$STACK_DIR"
export TF_DATA_DIR=".terraform-$ENV"   # separate local cache per env

terraform init -input=false -reconfigure \
  -backend-config="$ENV_DIR/backend.hcl" \
  -backend-config="key=$ENV/$STACK/terraform.tfstate" >/dev/null

VARS=(-var-file="$ENV_DIR/common.tfvars" -var "stack=$STACK")
[[ -f "$ENV_DIR/$STACK.tfvars" ]] && VARS+=(-var-file="$ENV_DIR/$STACK.tfvars")

case "$ACTION" in
  init)                 echo "Initialized $ENV/$STACK" ;;
  plan|apply|destroy)   terraform "$ACTION" "${VARS[@]}" "$@" ;;
  output)               terraform output "$@" ;;
  *) echo "Unknown action: $ACTION"; exit 1 ;;
esac