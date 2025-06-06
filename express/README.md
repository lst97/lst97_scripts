# Express.js Project Structure Creator

This script automates the creation of a comprehensive, scalable, and well-organized folder structure for a modern Express.js (TypeScript) backend project. It sets up essential configuration files, a core application structure with dedicated directories for API, controllers, services, models, and more, and includes boilerplate for Docker and GitHub Actions CI.

## Usage

To use this script, run it from your terminal and provide the desired path for your new Express.js project as an argument.

```bash
./create-express-structure.sh <path/to/your-project-name>
```

**Example:**

```bash
./create-express-structure.sh my-express-app
cd my-express-app
pnpm install
pnpm run dev
```

### Prerequisites

- Node.js
- pnpm (as per user preference)

### Generated Project Structure Highlights

The script creates a detailed project structure, including:

- **`src/`**: Contains the core application logic, divided into:
  - **`api/`**: Route definitions.
  - **`config/`**: Application-wide configurations.
  - **`controllers/`**: Handles incoming requests and calls services.
  - **`interfaces/`**: TypeScript type definitions.
  - **`lib/`**: Third-party library initializations.
  - **`middlewares/`**: Custom Express middleware.
  - **`models/`**: Database models/schemas.
  - **`services/`**: Core business logic.
  - **`tests/`**: Unit and integration tests.
  - **`utils/`**: Reusable utility functions.
- **`dist/`**: Compiled TypeScript output.
- **`node_modules/`**: Project dependencies.
- **`package.json`**: Project metadata and scripts.
- **`tsconfig.json`**: TypeScript compiler configuration.
- **`.gitignore`**: Specifies untracked files to ignore.
- **`.env`**: Environment variables (empty, for user to fill).
- **`Dockerfile`**: Dockerfile for containerization.
- **`.dockerignore`**: Files to ignore when building Docker images.
- **`.github/workflows/ci.yml`**: Basic GitHub Actions CI workflow.

Each major directory within `src/` also contains a `README.md` file explaining its purpose.

After creation, navigate into the new project directory (`cd <path/to/your-project-name>`), install dependencies using `pnpm install`, and start the development server with `pnpm run dev`.
