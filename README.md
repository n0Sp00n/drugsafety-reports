# Drug Safety Reporting API

A Spring Boot REST API for managing drug safety reports with basic authentication and in-memory storage.

## Quick Start

### Prerequisites
- Java 17+
- Maven 3.6+
- Docker (optional)

### Running Locally

1. **Clone and build**
   ```bash
   git clone <your-repo>
   cd drug-safety-api
   mvn clean package
   ```

2. **Run the application**
   ```bash
   mvn spring-boot:run
   ```

   Or run the JAR directly:
   ```bash
   java -jar target/drug-safety-api-0.0.1-SNAPSHOT.jar
   ```

3. **Access the API**
    - Base URL: `http://localhost:8080`
    - Swagger UI: `http://localhost:8080/swagger-ui.html`
    - Health Check: `http://localhost:8080/actuator/health`

### Authentication
- **Username**: `admin`
- **Password**: `password123`

Use Basic Authentication for all API calls (except Swagger UI and health endpoint).

## API Endpoints

### 1. Create Report
```http
POST /api/reports
Content-Type: application/json
Authorization: Basic YWRtaW46cGFzc3dvcmQxMjM=

{
  "reporterName": "John Doe",
  "productName": "Aspirin",
  "issueDescription": "Severe headache after taking medication"
}
```

**Response (201)**:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "reporterName": "John Doe",
  "productName": "Aspirin",
  "issueDescription": "Severe headache after taking medication",
  "timestamp": "2025-06-12T10:30:00",
  "status": "NEW"
}
```

### 2. Get Report by ID
```http
GET /api/reports/{id}
Authorization: Basic YWRtaW46cGFzc3dvcmQxMjM=
```

### 3. List Reports (with optional filters)
```http
GET /api/reports?status=NEW&productName=aspirin
Authorization: Basic YWRtaW46cGFzc3dvcmQxMjM=
```

### 4. Update Report Status
```http
PUT /api/reports/{id}/status?status=IN_REVIEW
Authorization: Basic YWRtaW46cGFzc3dvcmQxMjM=
```

## Docker Deployment

### Build and run with Docker
```bash
mvn clean package
docker build -t drug-safety-api .
docker run -p 8080:8080 drug-safety-api
```

### Using Docker Compose
```bash
docker-compose up --build
```

## AWS Deployment

### Option 1: AWS Elastic Beanstalk
1. Package the application:
   ```bash
   mvn clean package
   ```

2. Create a new Elastic Beanstalk application:
    - Platform: Java 17 (Corretto)
    - Upload `target/drug-safety-api-0.0.1-SNAPSHOT.jar`

3. Configure environment variables if needed

### Option 2: AWS ECS with Docker
1. Build and push to ECR:
   ```bash
   aws ecr create-repository --repository-name drug-safety-api
   docker build -t drug-safety-api .
   docker tag drug-safety-api:latest <account-id>.dkr.ecr.<region>.amazonaws.com/drug-safety-api:latest
   docker push <account-id>.dkr.ecr.<region>.amazonaws.com/drug-safety-api:latest
   ```

2. Create ECS task definition and service

### Option 3: AWS Lambda (with Spring Cloud Function)
For serverless deployment, the application would need modification to work with AWS Lambda.

## Testing

### Run unit tests
```bash
mvn test
```

### Manual testing with curl
```bash
# Create a report
curl -X POST http://localhost:8080/api/reports \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQxMjM=" \
  -d '{
    "reporterName": "Jane Smith",
    "productName": "Ibuprofen",
    "issueDescription": "Stomach upset"
  }'

# Get the report (use ID from previous response)
curl -X GET http://localhost:8080/api/reports/{report-id} \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQxMjM="

# List all reports
curl -X GET http://localhost:8080/api/reports \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQxMjM="
```

## Configuration

Key configuration in `application.yml`:
- Server port: 8080
- Security: Basic auth with in-memory user
- Logging: DEBUG level for application packages
- Management endpoints: Health and info exposed

---

# System Overview

## Architecture

### High-Level Design
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Client/UI     │───▶│  Spring Boot API │───▶│  In-Memory      │
│  (Swagger UI)   │    │   (Controllers)  │    │   Repository    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │  Security Layer  │
                       │  (Basic Auth)    │
                       └──────────────────┘
```

### Folder Structure
```
src/
├── main/
│   ├── java/com/drugsafety/
│   │   ├── DrugSafetyApiApplication.java    # Main Spring Boot app
│   │   ├── config/
│   │   │   ├── SecurityConfig.java          # Authentication setup
│   │   │   └── OpenApiConfig.java           # Swagger configuration
│   │   ├── controller/
│   │   │   └── SafetyReportController.java  # REST endpoints
│   │   ├── dto/
│   │   │   └── CreateReportRequest.java     # Request DTOs
│   │   ├── model/
│   │   │   ├── SafetyReport.java            # Domain model
│   │   │   └── ReportStatus.java            # Status enum
│   │   ├── repository/
│   │   │   └── SafetyReportRepository.java  # Data access layer
│   │   └── service/
│   │       └── SafetyReportService.java     # Business logic
│   └── resources/
│       └── application.yml                  # Configuration
└── test/
    └── java/com/drugsafety/
        ├── controller/
        │   └── SafetyReportControllerTest.java
        └── service/
            └── SafetyReportServiceTest.java
```

## Design Decisions

### 1. **Layered Architecture**
- **Controller Layer**: Handles HTTP requests/responses, validation
- **Service Layer**: Contains business logic
- **Repository Layer**: Data access abstraction
- **Model Layer**: Domain entities and DTOs

**Rationale**: Clean separation of concerns, testability,