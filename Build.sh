#!/bin/bash

# Cloudflare Pages build script
# This injects the BACKEND_URL environment variable into index.html

if [ -z "$BACKEND_URL" ]; then
  echo "⚠️  Warning: BACKEND_URL environment variable not set"
  echo "Using fallback URL in code"
else
  echo "✓ Injecting BACKEND_URL: $BACKEND_URL"
  # Replace the placeholder with actual env var
  sed -i "s|const API_URL = typeof BACKEND_URL|const BACKEND_URL = '$BACKEND_URL'; const API_URL = typeof BACKEND_URL|g" index.html
fi

echo "Build complete"