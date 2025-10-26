.PHONY: lint

lint:
    @BASE=${BASE:-origin/main}; \
    FILES=$$(git diff --name-only $${BASE}...HEAD | grep -E '\.dart$$' || true); \
    if [ -z "$$FILES" ]; then echo "No changed Dart files to lint"; exit 0; fi; \
    echo "Running flutter analyze on:"; printf "%s\n" $$FILES; \
    flutter analyze $$FILES
