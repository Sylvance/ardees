# Colors for terminal output
BOLD := $(shell tput bold)
NORMAL := $(shell tput sgr0)
GREEN := $(shell tput setaf 2)
RED := $(shell tput setaf 1)
YELLOW := $(shell tput setaf 3)

PYTHON_VERSION = 3.12

.PHONY: help install update clean lint format test shell dev-deps notebooks

help:
	@echo "$(BOLD)Available commands:$(NORMAL)"
	@echo "$(GREEN)make install$(NORMAL)         - Install all dependencies"
	@echo "$(GREEN)make update$(NORMAL)          - Update all dependencies"
	@echo "$(GREEN)make clean$(NORMAL)           - Remove Python file artifacts"
	@echo "$(GREEN)make dev-deps$(NORMAL)        - Install development dependencies"
	@echo "$(GREEN)make jupyter.start$(NORMAL)   - Start JupyterLab server"
	@echo "$(GREEN)make jupyter.install$(NORMAL) - Install Jupyter kernel for ardees"
	@echo "$(GREEN)make jupyter.remove$(NORMAL)  - Remove Jupyter kernel for ardees"
	@echo "$(GREEN)make lint$(NORMAL)            - Check code style with flake8"
	@echo "$(GREEN)make format$(NORMAL)          - Format code with black"
	@echo "$(GREEN)make test$(NORMAL)            - Run tests"
	@echo "$(GREEN)make shell$(NORMAL)           - Start a Poetry shell"
	@echo "$(GREEN)make notebooks$(NORMAL)       - Start JupyterLab"
	@echo "$(GREEN)make recreate$(NORMAL)        - Recreate virtual environment"
	@echo "$(GREEN)make run$(NORMAL)             - Run the main application"
	@echo "$(GREEN)make run MODULE=<module>$(NORMAL) - Run a specific module"
	@echo "$(GREEN)make run SCRIPT=<script>$(NORMAL) - Run a specific script"
	@echo ""
	@echo "$(BOLD)Examples:$(NORMAL)"
	@echo "$(YELLOW)make run$(NORMAL)                              - Run main application"
	@echo "$(YELLOW)make run MODULE=data.make_dataset$(NORMAL)     - Run data processing module"
	@echo "$(YELLOW)make run MODULE=models.train_model$(NORMAL)    - Run model training module"
	@echo "$(YELLOW)make run SCRIPT=scripts/analysis.py$(NORMAL)   - Run specific script file"
	@echo "$(YELLOW)make run.data$(NORMAL)                         - Quick data processing"
	@echo "$(YELLOW)make run.model$(NORMAL)                        - Quick model training"
	@echo "$(YELLOW)make format && make test && make run$(NORMAL)  - Format, test, then run"

install:
	@echo "$(BOLD)Setting up Python $(PYTHON_VERSION) environment...$(NORMAL)"
	poetry env remove --all
	poetry env use python$(PYTHON_VERSION)
	poetry install
	poetry run pre-commit install
	@echo "$(GREEN)Installation complete!$(NORMAL)"

dev-deps:
	@echo "$(BOLD)Installing development dependencies...$(NORMAL)"
	poetry add --group dev black@23.12.1 flake8 pytest pytest-cov pre-commit isort
	@echo "$(GREEN)Development dependencies installed!$(NORMAL)"

update:
	@echo "$(BOLD)Updating dependencies...$(NORMAL)"
	poetry update
	@echo "$(GREEN)Dependencies updated!$(NORMAL)"

clean:
	@echo "$(BOLD)Cleaning project...$(NORMAL)"
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.py[co]" -delete
	find . -type f -name "*.so" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	find . -type d -name "*.egg" -exec rm -rf {} +
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
	find . -type d -name ".coverage" -delete
	find . -type d -name "htmlcov" -exec rm -rf {} +
	find . -type f -name ".coverage" -delete
	find . -type f -name ".DS_Store" -delete
	rm -rf .venv
	@echo "$(GREEN)Clean complete!$(NORMAL)"


jupyter.start:
	poetry run jupyter lab

jupyter.install:
	poetry add ipykernel
	poetry run python -m ipykernel install --user --name ardees

jupyter.remove:
	poetry run jupyter kernelspec uninstall ardees

lint: dev-deps
	@echo "$(BOLD)Running linter...$(NORMAL)"
	poetry run flake8 src tests || (echo "$(RED)Linting failed!$(NORMAL)" && exit 1)
	@echo "$(GREEN)Linting passed!$(NORMAL)"

format: dev-deps
	@echo "$(BOLD)Formatting code...$(NORMAL)"
	poetry run isort src tests
	poetry run black src tests || (echo "$(RED)Formatting failed!$(NORMAL)" && exit 1)
	@echo "$(GREEN)Formatting complete!$(NORMAL)"

test: dev-deps
	@echo "$(BOLD)Running tests...$(NORMAL)"
	poetry run pytest || (echo "$(RED)Tests failed!$(NORMAL)" && exit 1)
	@echo "$(GREEN)Tests passed!$(NORMAL)"

shell:
	poetry shell

notebooks:
	poetry run jupyter lab

recreate: clean install
	@echo "$(GREEN)Environment recreated successfully!$(NORMAL)"

setup: clean
	@echo "Creating project structure..."
	mkdir -p data/{raw,processed,interim,external}
	mkdir -p notebooks
	mkdir -p src/{data,features,models,visualization}
	mkdir -p tests
	touch data/{raw,processed,interim,external}/.gitkeep
	touch src/{data,features,models,visualization}/__init__.py
	touch src/__init__.py
	@echo "$(GREEN)Project structure created successfully!$(NORMAL)"

# Run commands - choose the approach that fits your needs
run:
ifdef MODULE
	@echo "$(BOLD)Running module: $(MODULE)$(NORMAL)"
	poetry run python -m src.$(MODULE)
else ifdef SCRIPT
	@echo "$(BOLD)Running script: $(SCRIPT)$(NORMAL)"
	poetry run python $(SCRIPT)
else
	@echo "$(BOLD)Running main application...$(NORMAL)"
	poetry run python -m src.main
endif

# Alternative: Specific run targets for common tasks
run.data:
	@echo "$(BOLD)Running data processing...$(NORMAL)"
	poetry run python -m src.data.make_dataset

run.features:
	@echo "$(BOLD)Running feature engineering...$(NORMAL)"
	poetry run python -m src.features.build_features

run.model:
	@echo "$(BOLD)Running model training...$(NORMAL)"
	poetry run python -m src.models.train_model

run.predict:
	@echo "$(BOLD)Running predictions...$(NORMAL)"
	poetry run python -m src.models.predict_model

run.viz:
	@echo "$(BOLD)Running visualization...$(NORMAL)"
	poetry run python -m src.visualization.visualize
