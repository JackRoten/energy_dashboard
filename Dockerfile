# ----------------------------
# 1. Build Vite React frontend
# ----------------------------
FROM node:18 AS frontend-builder

WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install

COPY frontend/ ./
RUN npm run build     # Creates frontend/dist/


# ----------------------------
# 2. Build Python backend
# ----------------------------
FROM python:3.11-slim AS backend

WORKDIR /app

# Install dependencies
COPY backend/api_proxy/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend files
COPY backend/api_proxy ./backend/api_proxy

# Copy Vite build into backend serving directory
COPY --from=frontend-builder /app/frontend/dist ./frontend/dist

ENV PORT=5000
EXPOSE 5000

CMD ["gunicorn", "-b", "0.0.0.0:5000", "backend.api_proxy.app:app"]
