#!/bin/bash

# A script to create a comprehensive, scalable, and well-organized folder structure
# for a modern Express.js (TypeScript) backend project.

# --- Colors for Output ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
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

# 1. Validate Input
# ------------------------------------------------
if [ $# -eq 0 ]; then
  echo -e "${RED}Error: Project path is required.${NC}"
  echo "Usage: $0 <path/to/your-project-name>"
  exit 1
fi

PROJECT_PATH=$1
PROJECT_NAME=$(basename "$PROJECT_PATH")
SRC_DIR="src"

echo -e "${YELLOW}🚀 Creating a new Express.js project named '${PROJECT_NAME}' at '${PROJECT_PATH}'...${NC}"

# 2. Create Project Root and Top-Level Files
# ------------------------------------------------
log "Creating project root directory and essential configuration files..."
mkdir -p "$PROJECT_PATH"
cd "$PROJECT_PATH" || exit

# Create package.json
cat <<EOF > package.json
{
  "name": "${PROJECT_NAME}",
  "version": "1.0.0",
  "description": "A Node.js Express API",
  "main": "dist/server.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/server.js",
    "dev": "ts-node-dev --respawn --transpile-only src/server.ts",
    "test": "jest"
  },
  "keywords": [],
	"author": "",
	"license": "ISC",
	"dependencies": {
		"cors": "^2.8.5",
		"dotenv": "^16.5.0",
		"express": "^5.1.0",
		"helmet": "^8.1.0"
	},
	"devDependencies": {
		"@types/cors": "^2.8.18",
		"@types/express": "^5.0.2",
		"@types/jest": "^29.5.14",
		"@types/node": "^22.15.30",
		"jest": "^29.7.0",
		"ts-jest": "^29.3.4",
		"ts-node-dev": "^2.0.0",
		"typescript": "^5.8.3"
	}
}
EOF

# Create tsconfig.json
cat <<EOF > tsconfig.json
{
  "compilerOptions": {
    "target": "es2020",
    "module": "commonjs",
    "rootDir": "./src",
    "outDir": "./dist",
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.test.ts"]
}
EOF

# Create .gitignore
cat <<EOF > .gitignore
# Dependencies
/node_modules

# Build output
/dist

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# OS-specific
.DS_Store
Thumbs.db
EOF

# Create other root files
touch .env README.md

# Populate README.md
cat <<EOF > README.md
# ${PROJECT_NAME}

This is a Node.js Express API.

## Getting Started

### Prerequisites

- Node.js
- npm or yarn

### Installation

1. Clone the repository:
   \`\`\`bash
   git clone <your-repo-url>
   cd ${PROJECT_NAME}
   \`\`\`
2. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`
3. Create a \`.env\` file in the root directory and add your environment variables (see \`.env.example\` if provided).

### Running the Application

- **Development mode (with hot-reloading):**
  \`\`\`bash
  npm run dev
  \`\`\`

- **Production mode:**
  \`\`\`bash
  npm run build
  npm start
  \`\`\`
EOF

# 3. Create Docker and CI/CD files
# ------------------------------------------------
log "Setting up Docker and CI/CD boilerplate..."
mkdir -p .github/workflows

# Create Dockerfile
cat <<EOF > Dockerfile
# Stage 1: Build the application
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Create the production image
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/package*.json ./
RUN npm install --only=production
COPY --from=builder /app/dist ./dist
EXPOSE 3000
CMD ["node", "dist/server.js"]
EOF

# Create .dockerignore
cat <<EOF > .dockerignore
node_modules
.git
.gitignore
Dockerfile
README.md
EOF

# Create a basic CI workflow
cat <<EOF > .github/workflows/ci.yml
name: Node.js CI

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    - name: Use Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18.x'
        cache: 'npm'
    - run: npm ci
    - run: npm run build --if-present
    # - run: npm test # Uncomment when tests are set up
EOF


# 4. Create the Core Application Structure
# ------------------------------------------------
log "Creating core application structure inside '${SRC_DIR}'..."
mkdir -p "${SRC_DIR}"

create_dir_with_readme "${SRC_DIR}/api" "### API Routes\n\nContains all the route definitions, grouped by resource (e.g., \`users.routes.ts\`, \`products.routes.ts\`). This layer connects HTTP requests to controllers."
create_dir_with_readme "${SRC_DIR}/config" "### Configuration\n\nApplication-wide configuration files. E.g., \`database.ts\`, \`cors.ts\`, \`rate-limiter.ts\`."
create_dir_with_readme "${SRC_DIR}/controllers" "### Controllers\n\nThe controller layer handles incoming requests, validates them (often using middleware), and calls the appropriate service to handle the business logic. It then formats and sends the response."
create_dir_with_readme "${SRC_DIR}/interfaces" "### Interfaces\n\nContains all TypeScript type definitions and interfaces, especially for data models and API payloads."
create_dir_with_readme "${SRC_DIR}/lib" "### Libraries\n\nThird-party library initializations or custom library wrappers (e.g., \`logger.ts\`, \`redis.ts\`)."
create_dir_with_readme "${SRC_DIR}/middlewares" "### Middlewares\n\nCustom Express middleware functions (e.g., \`auth.middleware.ts\`, \`errorHandler.middleware.ts\`, \`validation.middleware.ts\`)."
create_dir_with_readme "${SRC_DIR}/models" "### Models\n\nDatabase models or schemas (e.g., Mongoose Schemas, Sequelize Models). This layer defines the shape of your data."
create_dir_with_readme "${SRC_DIR}/services" "### Services\n\nThis layer contains the core business logic. Services are called by controllers and are responsible for orchestrating data operations, often by interacting with models or repositories."
create_dir_with_readme "${SRC_DIR}/tests" "### Tests\n\nContains all tests for the application, often mirroring the \`src\` structure (e.g., \`tests/services/user.service.test.ts\`)."
create_dir_with_readme "${SRC_DIR}/utils" "### Utilities\n\nReusable utility functions that don't fit anywhere else (e.g., \`apiResponse.ts\` for consistent JSON responses, \`dateFormatter.ts\`)."

# 5. Create the Server Entry Point
# ------------------------------------------------
log "Creating the main server entry point: '${SRC_DIR}/server.ts'..."
cat <<EOF > "${SRC_DIR}/server.ts"
import express, { Express, Request, Response } from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import helmet from 'helmet';

dotenv.config();

const app: Express = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors()); // Enable Cross-Origin Resource Sharing
app.use(helmet()); // Set various HTTP headers for security
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies

// Health check endpoint
app.get('/', (req: Request, res: Response) => {
  res.send('API is running...');
});

app.listen(PORT, () => {
  console.log(\`⚡️[server]: Server is running at http://localhost:\${PORT}\`);
});
EOF

# --- Finalization ---
echo -e "\n${GREEN}✅ Success! Your Express.js project structure has been created at '${PROJECT_PATH}'.${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "1. Navigate to your project: ${GREEN}cd ${PROJECT_PATH}${NC}"
echo -e "2. Install dependencies: ${GREEN}npm install${NC}"
echo -e "3. Start the development server: ${GREEN}npm run dev${NC}"