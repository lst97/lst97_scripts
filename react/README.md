# React Project Structure Creator

This script automates the creation of a comprehensive, scalable, and well-organized folder structure for a React project. It sets up top-level directories, a detailed source directory structure with specific folders for components, API, assets, and more, and includes boilerplate for Storybook and GitHub Actions CI.

## Usage

To use this script, run it from your terminal.

```bash
./create-react-structure.sh
```

**Example:**

```bash
./create-react-structure.sh
cd your-react-app # assuming you create it in a new folder
pnpm install
pnpm start
```

### Prerequisites

- Node.js
- pnpm (as per user preference)

### Generated Project Structure Highlights

The script creates a detailed project structure, including:

- **`public/`**: Public assets.
- **`.storybook/`**: Storybook configuration.
- **`.github/workflows/ci.yml`**: Basic GitHub Actions CI workflow.
- **`src/`**: Contains the core application logic, divided into:
  - **`api/`**: API-related logic (Axios instances, endpoints).
  - **`assets/`**: Static assets (fonts, icons, images, styles).
  - **`components/`**: React components (ui, layout, features).
  - **`constants/`**: Application-wide constants.
  - **`context/`**: React Context providers.
  - **`hooks/`**: Custom React hooks.
  - **`pages/`**: Application pages/routes.
  - **`routes/`**: Routing configuration.
  - **`services/`**: Business logic not tied to components.
  - **`store/`**: Global state management (Redux, Zustand).
  - **`types/`**: TypeScript type definitions.
  - **`utils/`**: Reusable utility functions.
  - **`lib/`**: External library configurations.

Each major directory within `src/` also contains a `README.md` file explaining its purpose.

After creation, you would typically initialize a React project within this structure (e.g., using `create-react-app` or Vite), then install dependencies using `pnpm install`, and start the development server.
