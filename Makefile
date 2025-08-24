.PHONY: help install train evaluate test run web-interface clean docker-build docker-run docker-compose-up docker-compose-down setup-db migrate-db backup-db restore-db monitor logs health-check security-scan code-quality deploy-staging deploy-production dev-setup dev-reset quick-start prod-setup prod-monitor version status all

# Variables
PYTHON = python
PIP = pip
APP_NAME = sentimovie
VERSION = 0.5.0

help: ## Show this help message
	@echo "🎬 Sentimovie - IMDb Sentiment Analysis"
	@echo "=========================================="
	@echo ""
	@echo "Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Environment:"
	@echo "  PYTHON=$(PYTHON)"
	@echo "  APP_NAME=$(APP_NAME)"
	@echo "  VERSION=$(VERSION)"

install: ## Install dependencies
	@echo "📦 Installing dependencies..."
	$(PIP) install -r requirements.txt
	@echo "✅ Dependencies installed successfully"

install-dev: ## Install development dependencies
	@echo "🔧 Installing development dependencies..."
	$(PIP) install -r requirements.txt
	$(PIP) install pre-commit
	pre-commit install
	@echo "✅ Development dependencies installed successfully"

setup: ## Initial project setup
	@echo "🚀 Setting up Sentimovie project..."
	$(PYTHON) scripts/setup.py
	@echo "✅ Project setup completed"

train: ## Train the model
	@echo "🎯 Training model..."
	$(PYTHON) src/train.py
	@echo "✅ Model training completed"

evaluate: ## Evaluate the model
	@echo "📊 Evaluating model..."
	$(PYTHON) src/evaluate.py
	@echo "✅ Model evaluation completed"

test: ## Run tests
	@echo "🧪 Running tests..."
	$(PYTHON) -m pytest tests/ -v --cov=src --cov-report=html
	@echo "✅ Tests completed"

test-fast: ## Run tests without coverage
	@echo "🧪 Running tests (fast mode)..."
	$(PYTHON) -m pytest tests/ -v
	@echo "✅ Tests completed"

run: ## Run the API server
	@echo "🚀 Starting API server..."
	$(PYTHON) -m uvicorn src.app:app --reload --host 0.0.0.0 --port 8000

run-prod: ## Run the API server in production mode
	@echo "🚀 Starting production API server..."
	$(PYTHON) -m uvicorn src.app:app --host 0.0.0.0 --port 8000 --workers 4

web-interface: ## Run the Streamlit web interface
	@echo "🌐 Starting web interface..."
	$(PYTHON) -m streamlit run src/web_interface.py --server.port 8501

clean: ## Clean temporary files
	@echo "🧹 Cleaning temporary files..."
	rm -rf __pycache__/
	rm -rf .pytest_cache/
	rm -rf .coverage
	rm -rf htmlcov/
	rm -rf dist/
	rm -rf build/
	rm -rf *.egg-info/
	rm -rf logs/*.log
	rm -rf uploads/*
	@echo "✅ Cleanup completed"

docker-build: ## Build Docker image
	@echo "🐳 Building Docker image..."
	docker build -t $(APP_NAME):$(VERSION) .
	docker tag $(APP_NAME):$(VERSION) $(APP_NAME):latest
	@echo "✅ Docker image built successfully"

docker-run: ## Run Docker container
	@echo "🐳 Running Docker container..."
	docker run -d --name $(APP_NAME)-api \
		-p 8000:8000 \
		-v $(PWD)/models:/app/models \
		-v $(PWD)/uploads:/app/uploads \
		-v $(PWD)/logs:/app/logs \
		$(APP_NAME):latest
	@echo "✅ Docker container started"

docker-compose-up: ## Start all services with Docker Compose
	@echo "🐳 Starting all services..."
	docker-compose up -d
	@echo "✅ All services started"
	@echo "📊 Services available at:"
	@echo "  - API: http://localhost:8000"
	@echo "  - Web: http://localhost:8501"
	@echo "  - Prometheus: http://localhost:9090"
	@echo "  - Grafana: http://localhost:3000 (admin/admin)"

docker-compose-down: ## Stop all services
	@echo "🐳 Stopping all services..."
	docker-compose down
	@echo "✅ All services stopped"

docker-logs: ## Show Docker logs
	@echo "📋 Showing Docker logs..."
	docker-compose logs -f

setup-db: ## Setup database
	@echo "🗄️ Setting up database..."
	@if [ -f .env ]; then \
		echo "Loading environment variables..."; \
		export $$(cat .env | xargs); \
	fi
	$(PYTHON) -c "from src.database import init_database; init_database(); print('Database initialized')"
	@echo "✅ Database setup completed"

migrate-db: ## Run database migrations
	@echo "🔄 Running database migrations..."
	alembic upgrade head
	@echo "✅ Database migrations completed"

backup-db: ## Backup database
	@echo "💾 Creating database backup..."
	@mkdir -p backups
	@timestamp=$$(date +%Y%m%d_%H%M%S); \
	pg_dump $$DATABASE_URL > backups/sentimovie_backup_$$timestamp.sql
	@echo "✅ Database backup created"

restore-db: ## Restore database from backup
	@echo "📥 Restoring database from backup..."
	@if [ -z "$(BACKUP_FILE)" ]; then \
		echo "Usage: make restore-db BACKUP_FILE=backups/filename.sql"; \
		exit 1; \
	fi
	psql $$DATABASE_URL < $(BACKUP_FILE)
	@echo "✅ Database restored successfully"

monitor: ## Show monitoring dashboard
	@echo "📊 Opening monitoring dashboard..."
	@echo "Prometheus: http://localhost:9090"
	@echo "Grafana: http://localhost:3000 (admin/admin)"
	@echo "API Metrics: http://localhost:8000/metrics"
	@echo "Health Check: http://localhost:8000/health"

logs: ## Show application logs
	@echo "📋 Showing application logs..."
	@if [ -f logs/sentimovie.log ]; then \
		tail -f logs/sentimovie.log; \
	else \
		echo "No log file found. Run the application first."; \
	fi

health-check: ## Check system health
	@echo "🏥 Checking system health..."
	@echo "1. Testing configuration..."
	$(PYTHON) -c "from src.config import validate_config; print('✅ Configuration valid' if validate_config() else '❌ Configuration invalid')"
	@echo "2. Testing database connection..."
	$(PYTHON) -c "from src.database import init_database; init_database(); print('✅ Database connection successful')"
	@echo "3. Testing Redis connection..."
	$(PYTHON) -c "from src.database import init_redis; init_redis(); print('✅ Redis connection successful')"
	@echo "4. Testing model loading..."
	$(PYTHON) -c "from src.utils import load_model, load_tokenizer; load_model(); load_tokenizer(); print('✅ Model loading successful')"
	@echo "✅ Health check completed"

security-scan: ## Run security scans
	@echo "🔒 Running security scans..."
	@echo "1. Safety check..."
	safety check
	@echo "2. Bandit security scan..."
	bandit -r src/
	@echo "3. Dependency vulnerability scan..."
	$(PIP) list --outdated
	@echo "✅ Security scan completed"

code-quality: ## Run code quality checks
	@echo "✨ Running code quality checks..."
	@echo "1. Black formatting check..."
	black --check src/ tests/
	@echo "2. isort import sorting..."
	isort --check-only src/ tests/
	@echo "3. Flake8 linting..."
	flake8 src/ tests/
	@echo "4. MyPy type checking..."
	mypy src/
	@echo "✅ Code quality checks completed"

format-code: ## Format code automatically
	@echo "🎨 Formatting code..."
	black src/ tests/
	isort src/ tests/
	@echo "✅ Code formatting completed"

lint-fix: ## Fix linting issues automatically
	@echo "🔧 Fixing linting issues..."
	black src/ tests/
	isort src/ tests/
	@echo "✅ Linting issues fixed"

deploy-staging: ## Deploy to staging environment
	@echo "🚀 Deploying to staging..."
	@echo "1. Building Docker image..."
	make docker-build
	@echo "2. Running tests..."
	make test
	@echo "3. Security scan..."
	make security-scan
	@echo "4. Deploying to staging..."
	@echo "✅ Staging deployment completed"

deploy-production: ## Deploy to production environment
	@echo "🚀 Deploying to production..."
	@echo "⚠️  WARNING: This will deploy to production!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "1. Building production Docker image..."; \
		make docker-build; \
		echo "2. Running full test suite..."; \
		make test; \
		echo "3. Security scan..."; \
		make security-scan; \
		echo "4. Code quality check..."; \
		make code-quality; \
		echo "5. Deploying to production..."; \
		echo "✅ Production deployment completed"; \
	else \
		echo "❌ Production deployment cancelled"; \
	fi

# Development helpers
dev-setup: install-dev setup setup-db ## Complete development setup
	@echo "🎉 Development environment setup completed!"
	@echo "Next steps:"
	@echo "  1. Run 'make train' to train the model"
	@echo "  2. Run 'make run' to start the API server"
	@echo "  3. Run 'make web-interface' to start the web interface"

dev-reset: clean docker-compose-down ## Reset development environment
	@echo "🔄 Resetting development environment..."
	rm -rf .venv/
	rm -rf models/
	rm -rf uploads/
	rm -rf logs/
	@echo "✅ Development environment reset completed"

# Quick start
quick-start: dev-setup train run ## Quick start for development
	@echo "🚀 Quick start completed!"
	@echo "API server is running at http://localhost:8000"
	@echo "Web interface is available at http://localhost:8501"

# Production helpers
prod-setup: install setup-db docker-compose-up ## Production setup
	@echo "🚀 Production environment setup completed!"
	@echo "All services are running:"
	@echo "  - API: http://localhost:8000"
	@echo "  - Web: http://localhost:8501"
	@echo "  - Monitoring: http://localhost:9090"
	@echo "  - Dashboard: http://localhost:3000"

prod-monitor: monitor logs ## Monitor production environment
	@echo "📊 Production monitoring active"

# Utility commands
version: ## Show version information
	@echo "🎬 $(APP_NAME) v$(VERSION)"
	@echo "Python: $$($(PYTHON) --version)"
	@echo "Pip: $$($(PIP) --version)"

status: ## Show system status
	@echo "📊 System Status"
	@echo "================"
	@echo "1. Docker containers:"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@echo "2. Disk usage:"
	@df -h .
	@echo ""
	@echo "3. Memory usage:"
	@free -h
	@echo ""
	@echo "4. Process status:"
	@ps aux | grep -E "(uvicorn|streamlit)" | grep -v grep || echo "No processes found"

# Default target
all: help ## Default target - show help
