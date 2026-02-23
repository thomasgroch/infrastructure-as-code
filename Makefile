.PHONY: deploy test check clean logs shell install

# Default target
all: deploy

# Install dependencies
install:
	@echo "Installing Ansible..."
	apt-get update
	apt-get install -y ansible python3-pip python3-docker
	pip3 install requests selenium

# Deploy infrastructure
deploy:
	@echo "🚀 Deploying Passbolt infrastructure..."
	ansible-playbook -i ansible/inventory ansible/playbooks/site.yml

# Run in check mode (dry-run)
check:
	@echo "🔍 Running deployment check (dry-run)..."
	ansible-playbook -i ansible/inventory ansible/playbooks/site.yml --check --diff

# Run integration tests
test:
	@echo "🧪 Running integration tests..."
	bash tests/run-tests.sh

# View logs
logs:
	docker logs -f passbolt-app

# SSH into Passbolt container
shell:
	docker exec -it passbolt-app /bin/bash

# Stop and remove containers
clean:
	@echo "🧹 Cleaning up..."
	cd /opt/passbolt && docker compose down -v || true

# Full reset (DANGER: removes data)
reset:
	@echo "⚠️  WARNING: This will remove all Passbolt data!"
	@read -p "Are you sure? [y/N] " confirm && [ $$confirm = y ] || exit 1
	cd /opt/passbolt && docker compose down -v
	rm -rf /opt/passbolt/data

# Help
help:
	@echo "Available targets:"
	@echo "  install  - Install Ansible and dependencies"
	@echo "  deploy   - Deploy Passbolt infrastructure"
	@echo "  check    - Run deployment in check mode (dry-run)"
	@echo "  test     - Run integration tests"
	@echo "  logs     - View Passbolt logs"
	@echo "  shell    - SSH into Passbolt container"
	@echo "  clean    - Stop and remove containers"
	@echo "  reset    - Full reset (removes all data)"
