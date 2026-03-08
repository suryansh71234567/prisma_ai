# Folder Summary

This folder acts as the root of the Prisma AI JEE tutoring project, containing the unified frontend `index.html` and the `backend` folder for the FastAPI orchestrator. The root focuses on providing the entry point to the system via a fully client-side single-page app interacting directly with the backend.

- **Last Action:** Created `index.html` as a single-file zero-build frontend strictly adhering to "Mission Control Dark" aesthetics, containing auth, session, break, and graph components.
- **Dependencies:** The frontend strictly relies on the FastAPI server instance running locally at `localhost:8000` for all operations (Auth, Session Management, Graph Serving) via API calls.
- **Next Steps:** Conduct end-to-end integration tests manually through the UI to verify `index.html` connects perfectly with all backend endpoints, especially graph and tutor session flows.
