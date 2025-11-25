# ECAM Web - Developer Quick Start Guide

## Getting Started with ECAM Web Development

This guide will help you set up a local development environment and start building the web version of ECAM.

---

## Prerequisites

- **Node.js** 18+ and npm/yarn
- **Python** 3.11+
- **PostgreSQL** 15+
- **Docker** & Docker Compose
- **Git**

---

## Project Structure (Recommended)

```
ecam-web/
├── frontend/           # React application
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   ├── hooks/
│   │   └── utils/
│   ├── package.json
│   └── tsconfig.json
│
├── backend/            # Python FastAPI application
│   ├── app/
│   │   ├── api/
│   │   ├── models/
│   │   ├── services/
│   │   └── utils/
│   ├── tests/
│   ├── requirements.txt
│   └── pyproject.toml
│
├── docker/             # Docker configurations
│   ├── frontend.Dockerfile
│   ├── backend.Dockerfile
│   └── postgres.Dockerfile
│
├── docs/               # Documentation
├── scripts/            # Utility scripts
└── docker-compose.yml
```

---

## Step 1: Set Up Backend (FastAPI + Python)

### Create Backend Project

```bash
mkdir -p ecam-web/backend
cd ecam-web/backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install fastapi uvicorn sqlalchemy psycopg2-binary alembic
pip install python-multipart pydantic-settings python-jose[cryptography]
pip install pandas numpy scipy plotly
pip install pytest pytest-cov httpx
```

### Create requirements.txt

```txt
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
psycopg2-binary==2.9.9
alembic==1.12.1
pydantic==2.5.0
pydantic-settings==2.1.0
python-multipart==0.0.6
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
pandas==2.1.3
numpy==1.26.2
scipy==1.11.4
plotly==5.18.0
scikit-learn==1.3.2
pytest==7.4.3
pytest-cov==4.1.0
httpx==0.25.1
```

### Create Basic FastAPI App

**backend/app/main.py:**

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import projects, data, charts, models

app = FastAPI(
    title="ECAM Web API",
    description="API for Energy Charting and Metrics",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # Frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(projects.router, prefix="/api/v1/projects", tags=["projects"])
app.include_router(data.router, prefix="/api/v1/data", tags=["data"])
app.include_router(charts.router, prefix="/api/v1/charts", tags=["charts"])
app.include_router(models.router, prefix="/api/v1/models", tags=["models"])

@app.get("/")
async def root():
    return {"message": "ECAM Web API", "version": "1.0.0"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
```

### Create Database Models

**backend/app/models/database.py:**

```python
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, ForeignKey, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from datetime import datetime

SQLALCHEMY_DATABASE_URL = "postgresql://ecam:ecam@localhost/ecam_db"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class Project(Base):
    __tablename__ = "projects"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String)
    owner_id = Column(Integer)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    buildings = relationship("Building", back_populates="project")

class Building(Base):
    __tablename__ = "buildings"
    
    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id"))
    name = Column(String)
    address = Column(String)
    area_sqft = Column(Float)
    building_type = Column(String)
    
    project = relationship("Project", back_populates="buildings")
    points = relationship("Point", back_populates="building")

class Point(Base):
    __tablename__ = "points"
    
    id = Column(Integer, primary_key=True, index=True)
    building_id = Column(Integer, ForeignKey("buildings.id"))
    name = Column(String)
    unit = Column(String)
    system_type = Column(String)
    subsystem_type = Column(String)
    
    building = relationship("Building", back_populates="points")

class TimeSeriesData(Base):
    __tablename__ = "timeseries_data"
    
    id = Column(Integer, primary_key=True, index=True)
    point_id = Column(Integer, ForeignKey("points.id"))
    timestamp = Column(DateTime, index=True)
    value = Column(Float)
    quality_flag = Column(String)

# Create tables
Base.metadata.create_all(bind=engine)
```

### Create API Endpoint Example

**backend/app/api/projects.py:**

```python
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.models.database import SessionLocal, Project
from pydantic import BaseModel

router = APIRouter()

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Pydantic schemas
class ProjectCreate(BaseModel):
    name: str
    description: str
    owner_id: int

class ProjectResponse(BaseModel):
    id: int
    name: str
    description: str
    owner_id: int
    
    class Config:
        from_attributes = True

@router.post("/", response_model=ProjectResponse)
def create_project(project: ProjectCreate, db: Session = Depends(get_db)):
    """Create a new project"""
    db_project = Project(**project.dict())
    db.add(db_project)
    db.commit()
    db.refresh(db_project)
    return db_project

@router.get("/", response_model=List[ProjectResponse])
def list_projects(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """List all projects"""
    projects = db.query(Project).offset(skip).limit(limit).all()
    return projects

@router.get("/{project_id}", response_model=ProjectResponse)
def get_project(project_id: int, db: Session = Depends(get_db)):
    """Get project by ID"""
    project = db.query(Project).filter(Project.id == project_id).first()
    if project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    return project
```

### Run Backend

```bash
cd backend
uvicorn app.main:app --reload --port 8000
```

Visit: http://localhost:8000/docs for API documentation

---

## Step 2: Set Up Frontend (React + TypeScript)

### Create React App

```bash
cd ecam-web
npx create-react-app frontend --template typescript
cd frontend

# Install dependencies
npm install @mui/material @emotion/react @emotion/styled
npm install react-router-dom axios
npm install plotly.js react-plotly.js
npm install @tanstack/react-query
npm install ag-grid-react ag-grid-community
npm install date-fns
npm install zustand
```

### Create API Service

**frontend/src/services/api.ts:**

```typescript
import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api/v1';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Projects API
export const projectsApi = {
  list: () => api.get('/projects'),
  get: (id: string) => api.get(`/projects/${id}`),
  create: (data: any) => api.post('/projects', data),
  update: (id: string, data: any) => api.put(`/projects/${id}`, data),
  delete: (id: string) => api.delete(`/projects/${id}`),
};

// Data API
export const dataApi = {
  import: (projectId: string, file: File) => {
    const formData = new FormData();
    formData.append('file', file);
    return api.post(`/projects/${projectId}/data/import`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  },
  query: (projectId: string, params: any) => 
    api.get(`/projects/${projectId}/data`, { params }),
};

// Charts API
export const chartsApi = {
  create: (data: any) => api.post('/charts', data),
  list: (projectId: string) => api.get(`/charts?project_id=${projectId}`),
};

export default api;
```

### Create Project List Component

**frontend/src/components/ProjectList.tsx:**

```typescript
import React from 'react';
import { useQuery } from '@tanstack/react-query';
import {
  Card,
  CardContent,
  Typography,
  Grid,
  Button,
  Box,
} from '@mui/material';
import { projectsApi } from '../services/api';
import { useNavigate } from 'react-router-dom';

export const ProjectList: React.FC = () => {
  const navigate = useNavigate();
  
  const { data: projects, isLoading, error } = useQuery({
    queryKey: ['projects'],
    queryFn: async () => {
      const response = await projectsApi.list();
      return response.data;
    },
  });

  if (isLoading) return <Typography>Loading...</Typography>;
  if (error) return <Typography>Error loading projects</Typography>;

  return (
    <Box p={3}>
      <Box display="flex" justifyContent="space-between" mb={3}>
        <Typography variant="h4">My Projects</Typography>
        <Button 
          variant="contained" 
          onClick={() => navigate('/projects/new')}
        >
          New Project
        </Button>
      </Box>
      
      <Grid container spacing={3}>
        {projects?.map((project: any) => (
          <Grid item xs={12} md={6} lg={4} key={project.id}>
            <Card 
              sx={{ cursor: 'pointer' }}
              onClick={() => navigate(`/projects/${project.id}`)}
            >
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  {project.name}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  {project.description}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>
    </Box>
  );
};
```

### Create Basic Chart Component

**frontend/src/components/TimeSeriesChart.tsx:**

```typescript
import React from 'react';
import Plot from 'react-plotly.js';
import { Box, Paper, Typography } from '@mui/material';

interface TimeSeriesChartProps {
  data: Array<{
    x: Date[];
    y: number[];
    name: string;
  }>;
  title?: string;
}

export const TimeSeriesChart: React.FC<TimeSeriesChartProps> = ({ 
  data, 
  title 
}) => {
  const plotData = data.map(series => ({
    x: series.x,
    y: series.y,
    name: series.name,
    type: 'scatter',
    mode: 'lines',
  }));

  const layout = {
    title: title || 'Time Series',
    xaxis: {
      title: 'Time',
      type: 'date',
    },
    yaxis: {
      title: 'Value',
    },
    hovermode: 'x unified',
    autosize: true,
  };

  return (
    <Paper sx={{ p: 2 }}>
      <Plot
        data={plotData as any}
        layout={layout}
        config={{ responsive: true }}
        style={{ width: '100%', height: '400px' }}
      />
    </Paper>
  );
};
```

### Set Up Routing

**frontend/src/App.tsx:**

```typescript
import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider, createTheme, CssBaseline } from '@mui/material';
import { ProjectList } from './components/ProjectList';

const queryClient = new QueryClient();

const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
  },
});

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <BrowserRouter>
          <Routes>
            <Route path="/" element={<ProjectList />} />
            <Route path="/projects" element={<ProjectList />} />
            {/* Add more routes as needed */}
          </Routes>
        </BrowserRouter>
      </ThemeProvider>
    </QueryClientProvider>
  );
}

export default App;
```

### Run Frontend

```bash
cd frontend
npm start
```

Visit: http://localhost:3000

---

## Step 3: Set Up Database with Docker

### Create docker-compose.yml

**docker-compose.yml:**

```yaml
version: '3.8'

services:
  postgres:
    image: timescale/timescaledb:latest-pg15
    environment:
      POSTGRES_DB: ecam_db
      POSTGRES_USER: ecam
      POSTGRES_PASSWORD: ecam
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  backend:
    build:
      context: ./backend
      dockerfile: ../docker/backend.Dockerfile
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
    volumes:
      - ./backend:/app
    ports:
      - "8000:8000"
    depends_on:
      - postgres
      - redis
    environment:
      DATABASE_URL: postgresql://ecam:ecam@postgres/ecam_db
      REDIS_URL: redis://redis:6379

  frontend:
    build:
      context: ./frontend
      dockerfile: ../docker/frontend.Dockerfile
    command: npm start
    volumes:
      - ./frontend:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      REACT_APP_API_URL: http://localhost:8000/api/v1

volumes:
  postgres_data:
```

### Start All Services

```bash
docker-compose up -d
```

---

## Step 4: Implement Key Algorithm (Example)

### Linear Regression Module

**backend/app/services/regression.py:**

```python
import numpy as np
from scipy import stats
from typing import Dict, Tuple, Optional
import pandas as pd

class LinearRegressionModel:
    """
    Linear regression model for energy baseline/post modeling.
    Ported from ECAM VBA code.
    """
    
    def __init__(self):
        self.slope: Optional[float] = None
        self.intercept: Optional[float] = None
        self.r_squared: Optional[float] = None
        self.cv_rmse: Optional[float] = None
        self.nmbe: Optional[float] = None
        
    def fit(self, X: np.ndarray, y: np.ndarray) -> Dict:
        """
        Fit linear regression model.
        
        Args:
            X: Independent variable(s) - e.g., temperature
            y: Dependent variable - e.g., energy use
            
        Returns:
            Dictionary with model statistics
        """
        # Ensure X is 2D
        if X.ndim == 1:
            X = X.reshape(-1, 1)
            
        # Calculate regression using least squares
        slope, intercept, r_value, p_value, std_err = stats.linregress(
            X.flatten(), y
        )
        
        self.slope = slope
        self.intercept = intercept
        self.r_squared = r_value ** 2
        
        # Calculate predictions
        y_pred = self.predict(X)
        
        # Calculate CV(RMSE) - Coefficient of Variation of RMSE
        rmse = np.sqrt(np.mean((y - y_pred) ** 2))
        y_mean = np.mean(y)
        self.cv_rmse = (rmse / y_mean) * 100
        
        # Calculate NMBE - Normalized Mean Bias Error
        mbe = np.mean(y - y_pred)
        self.nmbe = (mbe / y_mean) * 100
        
        # Calculate additional statistics
        n = len(y)
        dof = n - 2  # degrees of freedom
        t_stat = self.slope / std_err
        
        return {
            'slope': self.slope,
            'intercept': self.intercept,
            'r_squared': self.r_squared,
            'cv_rmse': self.cv_rmse,
            'nmbe': self.nmbe,
            'p_value': p_value,
            'std_err': std_err,
            'n': n,
            'dof': dof,
            't_stat': t_stat
        }
    
    def predict(self, X: np.ndarray) -> np.ndarray:
        """Make predictions using fitted model."""
        if X.ndim == 1:
            X = X.reshape(-1, 1)
        return self.slope * X.flatten() + self.intercept
    
    def calculate_confidence_intervals(
        self, 
        X: np.ndarray, 
        confidence: float = 0.95
    ) -> Tuple[np.ndarray, np.ndarray]:
        """
        Calculate confidence intervals for predictions.
        
        Args:
            X: Independent variable values
            confidence: Confidence level (default 0.95 for 95%)
            
        Returns:
            Tuple of (lower_bound, upper_bound)
        """
        if X.ndim == 1:
            X = X.reshape(-1, 1)
            
        y_pred = self.predict(X)
        
        # This is simplified - full implementation would include
        # prediction interval calculation from VBA code
        # For now, using approximate method
        
        return y_pred, y_pred  # Placeholder


# Example usage
if __name__ == "__main__":
    # Sample data
    temperature = np.array([45, 50, 55, 60, 65, 70, 75, 80])
    energy_use = np.array([120, 110, 100, 90, 85, 90, 100, 115])
    
    model = LinearRegressionModel()
    stats = model.fit(temperature, energy_use)
    
    print("Model Statistics:")
    print(f"Slope: {stats['slope']:.4f}")
    print(f"Intercept: {stats['intercept']:.4f}")
    print(f"R²: {stats['r_squared']:.4f}")
    print(f"CV(RMSE): {stats['cv_rmse']:.2f}%")
    print(f"NMBE: {stats['nmbe']:.2f}%")
```

---

## Step 5: Testing

### Backend Tests

**backend/tests/test_regression.py:**

```python
import pytest
import numpy as np
from app.services.regression import LinearRegressionModel

def test_linear_regression_basic():
    """Test basic linear regression."""
    # Simple linear data: y = 2x + 1
    X = np.array([1, 2, 3, 4, 5])
    y = np.array([3, 5, 7, 9, 11])
    
    model = LinearRegressionModel()
    stats = model.fit(X, y)
    
    assert abs(stats['slope'] - 2.0) < 0.01
    assert abs(stats['intercept'] - 1.0) < 0.01
    assert stats['r_squared'] > 0.99

def test_model_predictions():
    """Test model predictions."""
    X = np.array([1, 2, 3, 4, 5])
    y = np.array([3, 5, 7, 9, 11])
    
    model = LinearRegressionModel()
    model.fit(X, y)
    
    # Test prediction
    X_new = np.array([6])
    y_pred = model.predict(X_new)
    
    assert abs(y_pred[0] - 13.0) < 0.01
```

Run tests:
```bash
cd backend
pytest tests/ -v
```

### Frontend Tests

**frontend/src/components/ProjectList.test.tsx:**

```typescript
import { render, screen } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { BrowserRouter } from 'react-router-dom';
import { ProjectList } from './ProjectList';

const queryClient = new QueryClient();

test('renders project list', () => {
  render(
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <ProjectList />
      </BrowserRouter>
    </QueryClientProvider>
  );
  
  expect(screen.getByText(/My Projects/i)).toBeInTheDocument();
});
```

Run tests:
```bash
cd frontend
npm test
```

---

## Additional Resources

### Documentation
- FastAPI: https://fastapi.tiangolo.com/
- React: https://react.dev/
- Material-UI: https://mui.com/
- Plotly: https://plotly.com/javascript/
- TimescaleDB: https://docs.timescale.com/

### ECAM Resources
- ECAM Website: https://sbwconsulting.com/ecam/
- IPMVP: https://evo-world.org/
- ASHRAE Guideline 14: https://www.ashrae.org/

### Community
- GitHub Discussions: [Link to repo]
- Slack Channel: [Link]
- Monthly Dev Calls: [Schedule]

---

## Common Commands

```bash
# Backend
cd backend
source venv/bin/activate
uvicorn app.main:app --reload
pytest tests/ -v

# Frontend
cd frontend
npm start
npm test
npm run build

# Docker
docker-compose up -d
docker-compose down
docker-compose logs -f backend

# Database
docker exec -it ecam-postgres psql -U ecam -d ecam_db
```

---

## Next Steps

1. **Complete MVP Features**
   - [ ] Implement remaining CRUD endpoints
   - [ ] Add file upload functionality
   - [ ] Create more chart types
   
2. **Add Authentication**
   - [ ] Implement JWT authentication
   - [ ] Add user registration/login
   - [ ] Set up RBAC
   
3. **Port More Algorithms**
   - [ ] Change-point regression
   - [ ] Multi-variable models
   - [ ] Statistical tests
   
4. **Improve UI/UX**
   - [ ] Add loading states
   - [ ] Implement error handling
   - [ ] Create responsive layouts

---

*Happy coding! Questions? Contact: johnstephenkromer@iCloud.com*
