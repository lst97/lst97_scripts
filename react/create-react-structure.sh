#!/bin/bash

# A script to create a comprehensive, scalable, and well-organized folder structure for a React project.

# --- Configuration ---
# Set the root directory for the source files. Default is 'src'.
SRC_DIR="src"

# --- Colors for Output ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Helper Functions ---
# A function to log messages with a specific format.
log() {
  echo -e "${BLUE}INFO:${NC} $1"
}

# A function to create a directory and a README file inside it explaining its purpose.
create_dir_with_readme() {
  local dir_path=$1
  local readme_content=$2
  mkdir -p "$dir_path"
  echo -e "$readme_content" > "$dir_path/README.md"
  # Add a .gitkeep file so empty directories can be committed to git
  touch "$dir_path/.gitkeep"
}

# --- Main Script Logic ---
echo -e "${YELLOW}🚀 Starting the creation of your new React project structure...${NC}"

# 1. Create top-level directories
# ------------------------------------------------
log "Creating top-level project directories..."
mkdir -p public .storybook .github/workflows "$SRC_DIR"
touch .github/workflows/ci.yml
touch .storybook/main.js
touch .storybook/preview.js
log "Created: public, .storybook, .github, and $SRC_DIR"

# 2. Create the main source directory structure
# ------------------------------------------------
log "Creating core structure inside '${SRC_DIR}'..."
mkdir -p "$SRC_DIR"/{api,assets,components,constants,context,hooks,pages,routes,services,store,types,utils,lib}
log "Core directories created under '${SRC_DIR}'."

# 3. Create detailed sub-directories and explanatory READMEs
# ------------------------------------------------

log "Detailing sub-directories and adding documentation..."

# /api
create_dir_with_readme "$SRC_DIR/api" \
"### API Layer\n\nThis folder contains all API-related logic.\n- **Instances:** Axios or Fetch instances.\n- **Endpoints:** Functions that map to specific API endpoints."

# /assets
create_dir_with_readme "$SRC_DIR/assets" \
"### Assets\n\nContains all static assets for the project."
mkdir -p "$SRC_DIR/assets"/{fonts,icons,images,styles}
create_dir_with_readme "$SRC_DIR/assets/styles" \
"### Global Styles\n\n- **base/:** Global resets, typography.\n- **themes/:** Theme files (e.g., light-theme.scss, dark-theme.scss).\n- **utils/:** Sass mixins, functions, variables."
mkdir -p "$SRC_DIR/assets/styles"/{base,themes,utils}

# /components
create_dir_with_readme "$SRC_DIR/components" \
"### Components\n\nContains all React components, organized by scope."
mkdir -p "$SRC_DIR/components"/{ui,layout,features}
create_dir_with_readme "$SRC_DIR/components/ui" \
"### UI Components\n\nGeneric, reusable, and 'dumb' UI components like Button, Input, Modal, etc. They should have no business logic."
create_dir_with_readme "$SRC_DIR/components/layout" \
"### Layout Components\n\nComponents that define the structure of pages, like Header, Footer, Sidebar, PageWrapper, etc."
create_dir_with_readme "$SRC_DIR/components/features" \
"### Feature Components\n\nComplex components that are specific to a business feature (e.g., UserProfile, ProductCard, LoginForm)."

# /constants
create_dir_with_readme "$SRC_DIR/constants" \
"### Constants\n\nApplication-wide constants. E.g., `export const API_URL = '...'`, `export const NAV_ITEMS = [...]`."

# /context
create_dir_with_readme "$SRC_DIR/context" \
"### Context\n\nReact Context providers and consumers for global state management (e.g., AuthContext, ThemeContext)."

# /hooks
create_dir_with_readme "$SRC_DIR/hooks" \
"### Custom Hooks\n\nCustom React hooks that encapsulate reusable logic (e.g., useDebounce, useLocalStorage, useApi)."

# /pages
create_dir_with_readme "$SRC_DIR/pages" \
"### Pages\n\nEach file here represents a page/route in the application. These components compose layouts and feature components."
touch "$SRC_DIR/pages/HomePage.jsx"
touch "$SRC_DIR/pages/AboutPage.jsx"

# /routes
create_dir_with_readme "$SRC_DIR/routes" \
"### Routes\n\nRouting configuration. May contain route definitions, protected routes logic, etc. for `react-router-dom`."
touch "$SRC_DIR/routes/index.js"

# /services
create_dir_with_readme "$SRC_DIR/services" \
"### Services\n\nBusiness logic that is not tied to a specific component. Often interacts with the API layer (e.g., AuthService, UserService)."

# /store (for Redux, Zustand, etc.)
create_dir_with_readme "$SRC_DIR/store" \
"### Store\n\nGlobal state management logic (e.g., Redux Toolkit slices, Zustand stores)."
mkdir -p "$SRC_DIR/store/slices"

# /types
create_dir_with_readme "$SRC_DIR/types" \
"### Types / Interfaces\n\nContains all TypeScript type definitions and interfaces, shared across the application."
mkdir -p "$SRC_DIR/types/api"

# /utils
create_dir_with_readme "$SRC_DIR/utils" \
"### Utilities\n\nUtility functions that can be used anywhere in the application (e.g., formatters, validators)."

# /lib
create_dir_with_readme "$SRC_DIR/lib" \
"### Libraries\n\nConfiguration and instances of external libraries (e.g., axios instance, i18n setup)."

# --- Finalization ---
echo -e "\n${GREEN}✅ Success! Your comprehensive React project structure has been created.${NC}"
echo -e "Run ${YELLOW}ls -R${NC} to see the full structure."