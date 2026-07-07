#!/bin/sh
set -e

process_env_file() {
  local env_file=$1
  local env_name=$2
  local should_use_backup=$3
  local backup_file=$4

  if [ ! -f "$env_file" ]; then
    echo "IMAGE_TAG=$DOCKER_IMAGE_TAG" > "$env_file"
    return
  fi

  if [ "$should_use_backup" = "true" ] && [ -f "$backup_file" ]; then
    backup_tag=$(grep "^IMAGE_TAG=" "$backup_file" 2>/dev/null | cut -d'=' -f2)
    if [ -n "$backup_tag" ]; then
      sed -i "s/^IMAGE_TAG=.*/IMAGE_TAG=$backup_tag/" "$env_file"
      return
    fi
  fi

  if grep -q "^IMAGE_TAG=" "$env_file"; then
    sed -i "s/^IMAGE_TAG=.*/IMAGE_TAG=$DOCKER_IMAGE_TAG/" "$env_file"
  else
    echo "IMAGE_TAG=$DOCKER_IMAGE_TAG" >> "$env_file"
  fi
}

# Process .qs.env (use backup if DEPLOY_ENV is prod)
process_env_file \
  "$TARGET_STACK_DIR/.qs.env" \
  "qs" \
  "$([ "$DEPLOY_ENV" = "prod" ] && echo "true" || echo "false")" \
  "/tmp/.qs.env.bak"

# Process .prod.env (use backup if DEPLOY_ENV is qs)
process_env_file \
  "$TARGET_STACK_DIR/.prod.env" \
  "prod" \
  "$([ "$DEPLOY_ENV" = "qs" ] && echo "true" || echo "false")" \
  "/tmp/.prod.env.bak"
