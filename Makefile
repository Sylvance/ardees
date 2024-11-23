# Colors for terminal output
BOLD := $(shell tput bold)
NORMAL := $(shell tput sgr0)
GREEN := $(shell tput setaf 2)
RED := $(shell tput setaf 1)

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
