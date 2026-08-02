Finzy-client-portal/
├── docs/
│   ├── vision.md
│   ├── requirements.md
│   ├── architecture.md
│   ├── auth-decision.md
│   ├── erd.md
│   └── api-spec.md
├── backend/
│   ├── pom.xml
│   └── src/
│       ├── main/java/com/finzyportal/
│       │   ├── auth/
│       │   ├── appointment/
│       │   ├── audit/
│       │   ├── calendar/
│       │   ├── communication/
│       │   ├── config/
│       │   ├── customer/
│       │   ├── file/
│       │   ├── garment/
│       │   ├── measurement/
│       │   ├── notification/
│       │   ├── quote/
│       │   └── shared/
│       └── main/resources/
│           ├── application.yml
│           ├── application-local.yml
│           └── db/migration/
├── frontend/
│   └── src/
│       ├── app/
│       │   ├── book/
│       │   ├── portal/[accessToken]/
│       │   └── admin/
│       └── lib/
├── infrastructure/
│   └── docker-compose.yml
└── README.md
