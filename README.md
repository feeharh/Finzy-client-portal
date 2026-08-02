# Finzy Client Portal

A client and workflow management platform for alteration businesses.

## Documentation

- [Vision](./docs/vision.md)
- [Requirements](./docs/requirements.md)
- [Architecture](./docs/architecture.md)
- [ERD](./docs/erd.md)
- [API Specification](./docs/api-spec.md)
- [Auth Decisions](./docs/auth-decision.md)
- [Postman Collection](./docs/postman/README.md)

## Project Structure

```text
Finzy-client-portal/
├── backend/          Spring Boot API (Java 17)
├── frontend/         Next.js app (TypeScript, Tailwind)
├── infrastructure/   Docker Compose for local services
└── docs/             Product and technical documentation
```

## Prerequisites

- Java 17+
- Maven 3.8+
- Node.js 20+
- Docker Desktop (for local PostgreSQL and MailHog)

## Local Development

### 1. Start infrastructure

```bash
cd infrastructure
docker compose up -d
```

Services:

| Service    | URL / Port                          |
|------------|-------------------------------------|
| PostgreSQL | `localhost:5432` (db: `finzy_portal`) |
| MailHog UI | http://localhost:8025               |
| MailHog SMTP | `localhost:1025`                  |

### 2. Start backend

```bash
cd backend
mvn spring-boot:run
```

API base URL: http://localhost:8080/api/v1

Health check: http://localhost:8080/api/v1/health

### 3. Start frontend

```bash
cd frontend
cp .env.local.example .env.local
npm install
npm run dev
```

App: http://localhost:3000

## Build & Test

```bash
# Backend
cd backend && mvn test

# Frontend
cd frontend && npm run build
```

## Implementation Phases

| Phase | Status | Scope |
|-------|--------|-------|
| 1 | Done | Docker, Spring Boot skeleton, Next.js skeleton |
| 2 | Done | Database migrations, admin auth, validation, seed admin |
| 3 | Next | Appointment workflow, portal, measurements, quotes |
| 4 | Planned | File uploads, email, WhatsApp, calendar |
| 5 | Planned | Dashboard, audit logs, tests, deploy pipeline |

## Environment Variables

### Backend (`application-local.yml`)

| Variable | Default |
|----------|---------|
| Database URL | `jdbc:postgresql://localhost:5432/finzy_portal` |
| Database user | `finzy` |
| Database password | `finzy_dev_password` |

### Frontend (`.env.local`)

| Variable | Default |
|----------|---------|
| `NEXT_PUBLIC_API_URL` | `http://localhost:8080/api/v1` |
