# ECAM Web Version - Architecture Proposal

## Executive Summary

**ECAM (Energy Charting and Metrics)** is an Excel-based tool for energy measurement and verification (M&V), building re-tuning, and Strategic Energy Management (SEM). Currently implemented as a 45,000-line VBA add-in, this proposal outlines a modern web-based version that maintains all core functionality while enabling cloud collaboration, real-time data integration, and automated reporting.

**Target Users:** Energy engineers, M&V professionals, commissioning agents, facility managers, utility program administrators

**Key Value Proposition:** Web-based ECAM enables multi-building portfolio analysis, automated data pipelines, team collaboration, and compliance with IPMVP protocols while maintaining the flexibility and analytical power of the original tool.

---

## Current ECAM Capabilities

### 1. M&V and IPMVP Compliance

**Measurement & Verification (IPMVP Options A, B, C)**
- Baseline model development and agreement process
- Pre/post-installation energy analysis
- Savings calculation and uncertainty quantification
- ASHRAE fractional savings uncertainty
- Automated outlier detection and handling
- MAPE (Mean Absolute Percentage Error) calculation
- Confidence interval calculations for models
- Annualization using TMY3 weather data
- Support for both interval meter data (Option C) and logger data (Options A & B)

### 2. Data Import and Management

**Data Sources**
- Interval meter data (15-min, hourly, or custom intervals)
- Monthly utility billing data
- Change-of-value (COV) data from BAS systems
- Historical weather data (automated downloads)
- TMY3 typical weather data
- Multiple data formats and resampling to common timestamps

**Data Processing**
- Automatic data normalization (per sq ft, per ton, etc.)
- Day-typing (weekday/weekend/holiday classification)
- Occupancy schedule creation
- Holiday customization
- Temperature binning
- Data quality checking and validation

### 3. Visualization and Charts

**Time Series Charts**
- Point history charts
- Load profiles by: daytype, day of week, month-year, date range, year, day
- 3D load profiles (multiple days with color coding)
- Surface charts (energy colors/contour charts)
- Calendar view load profiles
- Box plot load profiles

**Scatter/Regression Charts**
- X-Y scatter by occupancy
- X-Y scatter by date range (pre/post comparison)
- Baseline and post-period regression models
- Model residual plots
- Uncertainty interval visualization
- Recent day highlighting

**Other Chart Types**
- Load duration curves (frequency distribution)
- Schedule verification charts
- Matrix charts (thumbnail arrays of multiple charts)
- Building re-tuning diagnostic charts (PNNL protocol)

### 4. Energy Analysis and Modeling

**Statistical Modeling**
- Linear regression models with change points
- Multi-variable models (temperature, occupancy, time)
- Categorical variable creation and combination
- Model goodness-of-fit statistics (R², CV-RMSE)
- Residual analysis and normalization
- Automated model selection and comparison

**Building System Analysis**
- Central plant performance metrics
- Air handler unit (AHU) analysis
- Zone-level analysis
- Equipment efficiency metrics (kW/ton, W/CFM)
- Economizer performance evaluation
- Component and subsystem tracking

### 5. Strategic Energy Management (SEM)

**Monitoring, Targeting, and Reporting (MTR)**
- Continuous performance tracking
- Heat maps for performance visualization
- Behavioral change detection
- Trend analysis over time
- Multi-fuel tracking (electric, gas, steam, chilled water)

### 6. Automation Features

**Batch Processing**
- Automated M&V modeling from template files
- Multi-fuel model generation
- Batch chart creation
- Template-based workflows
- XML model export

### 7. Building Re-Tuning (PNNL Protocol)

**Automated Diagnostic Charts**
- Central plant performance charts
- Air Handler Unit (AHU) diagnostics
- Zone-level analysis charts
- AHU scatter chart analysis
- Economizer performance for all AHUs
- Automated fault detection support

---

## Proposed Web Architecture

### Technology Stack

**Frontend**
- **Framework:** React 18+ with TypeScript
- **State Management:** Redux Toolkit / Zustand
- **Charting:** Plotly.js (interactive charts matching Excel functionality)
- **Data Grid:** AG-Grid (Excel-like data manipulation)
- **UI Components:** Material-UI / shadcn/ui
- **Forms:** React Hook Form with Zod validation

**Backend**
- **API:** FastAPI (Python) - maintains compatibility with existing algorithms
- **Database:** PostgreSQL (time-series data) + TimescaleDB extension
- **Task Queue:** Celery + Redis (for long-running analyses)
- **File Storage:** S3-compatible storage (AWS S3 / MinIO)
- **Authentication:** Auth0 / Keycloak (OAuth2/SAML)
**Data Processing & Analytics**
- **Statistical Computing:** Python (NumPy, SciPy, Pandas, Statsmodels)
- **Machine Learning:** Scikit-learn (for advanced model selection)
- **Weather Data:** Integration with NOAA APIs
- **Time Series:** Apache Arrow for efficient columnar data

**Infrastructure**
- **Deployment:** Docker + Kubernetes
- **CI/CD:** GitHub Actions
- **Monitoring:** Prometheus + Grafana
- **Logging:** ELK Stack (Elasticsearch, Logstash, Kibana)

### Application Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  React Web   │  │ Mobile PWA   │  │  Desktop     │     │
│  │  Application │  │  (Future)    │  │  (Electron)  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      API GATEWAY                            │
│         (Authentication, Rate Limiting, Routing)            │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ Data Import  │    │  Analytics   │    │   Reporting  │
│   Service    │    │   Service    │    │   Service    │
│              │    │              │    │              │
│ - CSV/Excel  │    │ - M&V Models │    │ - PDF Export │
│ - API Import │    │ - Statistics │    │ - Dashboards │
│ - BAS Connect│    │ - Charts     │    │ - Templates  │
└──────────────┘    └──────────────┘    └──────────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    DATA LAYER                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ PostgreSQL + │  │    Redis     │  │   S3/MinIO   │     │
│  │ TimescaleDB  │  │    Cache     │  │ File Storage │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

---

## Core Modules & Features

### 1. Data Management Module

**Import System**
- Drag-and-drop file upload (CSV, Excel, XML)
- API integrations:
  - Utility AMI/AMR systems
  - Building Automation Systems (BACnet, Modbus)
  - Weather APIs (NOAA, Weather Underground)
- Automated data validation and QC
- Support for multiple timestamp formats
- Change-of-value (COV) data handling
- Data resampling with multiple interpolation methods

**Data Organization**
- Project-based organization
- Building portfolio management
- Point mapping and tagging system
- Custom point hierarchies
- Metadata management

### 2. Preprocessing Module

**Schedule Management**
- Visual schedule builder (drag-and-drop calendar interface)
- Week-based schedules
- Annual special event schedules
- Holiday customization (recurring + specific dates)
- Schedule validation charts

**Day-typing Engine**
- Automated day-type classification
- Load profile clustering
- Manual override capabilities
- Visual day-type evaluation tools

**Data Normalization**
- Per square foot normalization
- Custom normalization factors
- Bin temperature creation
- Occupancy-based adjustments

### 3. Visualization Module

**Interactive Charts** (All chart types from Excel version, but interactive)
- **Time Series:**
  - Point history with zoom/pan
  - Load profiles (multiple aggregation levels)
  - 3D surface plots with rotation
  - Calendar heat maps
  - Box plot distributions
  
- **Scatter Plots:**
  - Baseline vs. post comparison
  - Regression model overlays
  - Residual plots
  - Interactive point highlighting
  - Confidence interval bands

- **Specialized:**
  - Load duration curves
  - Matrix/thumbnail views
  - Performance heat maps
  - Custom composite charts

**Chart Features**
- Export to PNG, SVG, PDF
- Interactive tooltips with data details
- Synchronized chart zooming across multiple charts
- Annotation tools
- Custom styling and branding

### 4. Statistical Modeling Module

**Regression Models**
- Linear regression with change points
- Multi-variable regression (up to 5 independent variables)
- Piecewise linear models
- Automated model selection using AIC/BIC
- Model validation (R², CV-RMSE, NMBE)
- Residual analysis and diagnostics

**Model Types**
- Temperature-based (HDD, CDD)
- Time-of-week models
- Occupancy-based models
- Multi-fuel models
- Custom categorical variables

**Statistical Features**
- Confidence intervals (user-selectable levels)
- Outlier detection (Cook's distance, standardized residuals)
- Autocorrelation analysis
- Heteroscedasticity tests
- MAPE calculation

### 5. M&V Module (IPMVP Compliant)

**Baseline Development**
- Interactive baseline period selection
- Model comparison tools
- Baseline agreement workflow
- Weather normalization
- Model documentation

**Savings Calculation**
- Avoided energy use calculation
- Normalized savings estimation
- Uncertainty quantification (ASHRAE Guideline 14)
- Fractional savings uncertainty
- Savings tracking over time

**Reporting & Compliance**
- IPMVP-compliant report generation
- Automated savings reports (monthly, annual)
- Annualized savings with TMY3 data
- Model performance monitoring
- Savings persistence tracking

### 6. Strategic Energy Management (SEM) Module

**Monitoring & Targeting**
- CUSUM (Cumulative Sum) charts
- Performance heat maps
- Target setting and tracking
- Behavioral change detection
- Project log management

**Continuous Performance**
- Automated model updates
- Anomaly detection
- Performance alerts
- Trend analysis
- Portfolio-level dashboards

### 7. Building Re-Tuning Module (PNNL Protocol)

**Automated Diagnostics**
- Central plant efficiency tracking
- AHU performance analysis
- Zone-level diagnostics
- Economizer fault detection
- Automated chart generation

**Fault Detection**
- Rule-based fault detection
- Statistical anomaly detection
- Performance degradation alerts
- Maintenance recommendations

### 8. Collaboration & Workflow Module

**Multi-User Features**
- Role-based access control (Admin, Engineer, Viewer)
- Project sharing and permissions
- Comment threads on charts/analyses
- Audit trail for all changes
- Version control for models

**Workflow Automation**
- Scheduled data imports
- Automated report generation
- Email alerts and notifications
- Template-based workflows
- Batch processing jobs

### 9. API & Integration Module

**RESTful API**
- Full CRUD operations for all entities
- Bulk data import/export
- Real-time data streaming (WebSocket)
- Webhook notifications
- API key management

**Integrations**
- BMS/BAS systems
- Utility portals
- CMMS systems
- Excel import/export (maintain compatibility)
- GIS mapping integration

---

## Key Advantages of Web Version

### 1. Scalability & Performance
- **Portfolio Analysis:** Analyze hundreds of buildings simultaneously
- **Cloud Computing:** Leverage serverless functions for heavy computations
- **Real-time Updates:** Live data feeds from BAS systems
- **Parallel Processing:** Distributed computing for complex analyses

### 2. Collaboration
- **Multi-User Access:** Teams can work on same project simultaneously
- **Centralized Data:** No more emailing Excel files
- **Version Control:** Track all changes and revert if needed
- **Review Workflows:** Built-in approval processes for M&V reports

### 3. Accessibility
- **Cross-Platform:** Access from any device (desktop, tablet, mobile)
- **No Installation:** Browser-based, always up-to-date
- **Offline Mode:** PWA capabilities for field work
- **Remote Access:** Work from anywhere with internet

### 4. Data Management
- **Centralized Storage:** All projects in one secure location
- **Automated Backups:** Never lose data
- **Data Governance:** Compliance with data retention policies
- **Integration:** Direct connections to utility APIs and BAS systems

### 5. Enhanced Analytics
- **Machine Learning:** Advanced pattern recognition and anomaly detection
- **Predictive Models:** Forecast future energy use
- **Portfolio Benchmarking:** Compare buildings across portfolio
- **Advanced Visualization:** Interactive 3D charts, AR/VR potential

---

## Implementation Phases

### Phase 1: Core Platform (Months 1-4)
**Deliverables:**
- User authentication and project management
- Data import (CSV, Excel)
- Basic time-series and scatter charts
- Simple linear regression models
- PDF report generation

**Milestone:** MVP launch for beta testing with 5-10 users

### Phase 2: M&V Capabilities (Months 5-8)
**Deliverables:**
- Full IPMVP Option C compliance
- Baseline/post modeling workflow
- Savings calculation and uncertainty
- Weather data integration
- Automated report generation

**Milestone:** First production M&V project completed

### Phase 3: Advanced Features (Months 9-12)
**Deliverables:**
- SEM/MTR module
- Building re-tuning diagnostics
- Matrix charts and advanced visualization
- API integrations (BAS, utility APIs)
- Mobile-responsive interface

**Milestone:** Feature parity with Excel version

### Phase 4: Scale & Optimize (Months 13-16)
**Deliverables:**
- Portfolio management
- Machine learning integration
- Real-time data streaming
- Performance optimization
- Advanced collaboration tools

**Milestone:** 100+ active users, 1000+ buildings

---

## User Interface Mockups (Key Screens)

### Dashboard
```
┌─────────────────────────────────────────────────────────────┐
│  ECAM Web                          🔔 Profile ▼            │
├─────────────────────────────────────────────────────────────┤
│  [Projects] [Buildings] [Reports] [Settings]                │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  My Projects                                    [+ New]      │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐  │
│  │ Office Tower  │  │ Hospital A    │  │ Retail Mall   │  │
│  │ 📊 Active M&V │  │ ⚠️ Alert      │  │ ✓ Complete    │  │
│  │ 45 days left  │  │ Review needed │  │ Verified      │  │
│  └───────────────┘  └───────────────┘  └───────────────┘  │
│                                                              │
│  Recent Activity                                             │
│  • Model updated: Office Tower - Baseline                   │
│  • Report generated: Hospital A - Monthly Savings           │
│  • Data imported: Retail Mall - November interval data      │
│                                                              │
│  Portfolio Summary                                           │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  Total Savings YTD: 2,450 MWh  ($245,000)              ││
│  │  ████████░░ 82% of target                               ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### Project View
```
┌─────────────────────────────────────────────────────────────┐
│  Office Tower Building - M&V Project                         │
├──────────────┬──────────────────────────────────────────────┤
│ [Import Data]│  Data Summary                                 │
│ [Charts]     │  ┌────────────────────────────────────────┐  │
│ [Models]     │  │ Date Range: Jan 2023 - Nov 2024       │  │
│ [M&V]        │  │ Points: 45                              │  │
│ [Reports]    │  │ Interval: 15-min                        │  │
│              │  │ Weather: NOAA Station 12345            │  │
│              │  └────────────────────────────────────────┘  │
│              │                                               │
│              │  Project Timeline                             │
│              │  ┌────────────────────────────────────────┐  │
│              │  │ Baseline: ████████░░░░░░░░░░░░         │  │
│              │  │ Jan 2023 - Dec 2023                     │  │
│              │  │                                          │  │
│              │  │ Post: ░░░░░░░░░░░░░░████████            │  │
│              │  │ Jan 2024 - Nov 2024                     │  │
│              │  └────────────────────────────────────────┘  │
│              │                                               │
│              │  Quick Actions                                │
│              │  [Create Baseline Model]  [Generate Report]  │
└──────────────┴──────────────────────────────────────────────┘
```

### Chart Builder
```
┌─────────────────────────────────────────────────────────────┐
│  Create Chart                                        [×]     │
├─────────────────────────────────────────────────────────────┤
│  Chart Type: [Load Profile ▼]                               │
│                                                              │
│  Aggregation: [By Daytype ▼]                                │
│                                                              │
│  Select Points:                                              │
│  ☑ Whole Building Electric (kW)                             │
│  ☑ Chiller Plant (tons)                                     │
│  ☐ Outdoor Air Temperature (°F)                             │
│                                                              │
│  Date Range: [Jan 2024] to [Dec 2024]                      │
│                                                              │
│  Filters:                                                    │
│  Daytype: ☑ Weekday  ☑ Weekend  ☑ Holiday                  │
│  Occupancy: ☑ Occupied  ☑ Unoccupied                       │
│                                                              │
│  [Preview]  [Create Chart]  [Cancel]                        │
└─────────────────────────────────────────────────────────────┘
```

---

## Migration Strategy from Excel

### Backward Compatibility
1. **Excel Import:** Import existing .xlam files and extract data/models
2. **Template Export:** Export web projects as Excel templates
3. **Hybrid Mode:** Continue using Excel while transitioning to web
4. **Data Bridge:** API to sync data between Excel and web version

### Training & Adoption
1. **Video Tutorials:** Step-by-step guides for each feature
2. **Webinar Series:** Live training sessions
3. **Documentation:** Comprehensive user guide (like current PDF)
4. **Support Portal:** Knowledge base and ticketing system
5. **User Community:** Forum for sharing tips and templates

### Data Migration Tools
1. **Automated Import:** One-click import of existing ECAM projects
2. **Validation:** Ensure data integrity after migration
3. **Model Verification:** Compare results between Excel and web
4. **Batch Migration:** Tools for migrating multiple projects

---

## Technical Specifications

### Database Schema (Key Tables)

**Projects**
- project_id, name, description, owner_id, created_at, updated_at

**Buildings**
- building_id, project_id, name, address, area_sqft, building_type

**TimeSeriesData**
- data_id, building_id, point_id, timestamp, value, quality_flag

**Points**
- point_id, building_id, name, unit, system_type, subsystem_type

**Models**
- model_id, project_id, model_type, parameters (JSON), statistics (JSON)

**Schedules**
- schedule_id, building_id, schedule_type, rules (JSON)

**Reports**
- report_id, project_id, report_type, generated_at, file_url

### API Endpoints (Sample)

```
POST   /api/v1/projects                    Create project
GET    /api/v1/projects/{id}               Get project details
POST   /api/v1/projects/{id}/data/import   Import data
GET    /api/v1/projects/{id}/data          Query time-series data
POST   /api/v1/projects/{id}/charts        Create chart
POST   /api/v1/projects/{id}/models        Create model
GET    /api/v1/projects/{id}/models/{id}   Get model results
POST   /api/v1/projects/{id}/reports       Generate report
GET    /api/v1/weather/stations            Get weather stations
POST   /api/v1/weather/download            Download weather data
```

### Performance Targets

- **Data Import:** 1M rows in < 30 seconds
- **Chart Rendering:** < 1 second for 10K points
- **Model Calculation:** < 5 seconds for standard regression
- **Page Load:** < 2 seconds (initial load)
- **API Response:** < 200ms for most endpoints
- **Concurrent Users:** Support 500+ simultaneous users

---

## Security & Compliance

### Data Security
- Encryption at rest (AES-256)
- Encryption in transit (TLS 1.3)
- Role-based access control (RBAC)
- Multi-factor authentication (MFA)
- SOC 2 Type II compliance

### Data Privacy
- GDPR compliant
- Data residency options
- Data retention policies
- Right to deletion
- Data export capabilities

### Audit & Compliance
- Complete audit logs
- Change tracking
- Compliance reports
- IPMVP protocol adherence
- ASHRAE Guideline 14 compliance

---

## Cost Estimate & Business Model

### Development Costs (Estimated)

**Phase 1 (MVP):** $200,000 - $300,000
- 3 developers × 4 months
- UI/UX designer
- DevOps setup
- Initial testing

**Phase 2 (M&V Features):** $150,000 - $250,000
- 2 developers × 4 months
- Energy engineer consultant
- Testing & validation

**Phase 3 (Advanced Features):** $200,000 - $300,000
- 3 developers × 4 months
- Additional integrations
- Performance optimization

**Phase 4 (Scale):** $150,000 - $200,000
- Infrastructure scaling
- ML integration
- Ongoing optimization

**Total Development:** $700,000 - $1,050,000

### Operating Costs (Annual)

- Infrastructure (AWS/GCP): $50,000 - $100,000
- Support & maintenance: $100,000 - $150,000
- Marketing: $50,000 - $100,000
- **Total Annual:** $200,000 - $350,000

### Revenue Model

**Subscription Pricing (Per User/Month)**
- Basic: $49 (limited features, 3 buildings)
- Professional: $149 (full features, 25 buildings)
- Enterprise: $499 (unlimited, API access, white-label)

**Alternative Models**
- Per-building pricing ($20-50/building/month)
- Utility program licensing
- Enterprise site licenses
- Consulting/training services

---

## Success Metrics

### Technical KPIs
- System uptime: > 99.9%
- API response time: < 200ms (95th percentile)
- Data import success rate: > 99%
- Chart rendering time: < 1 second

### User KPIs
- Daily active users: Track growth
- Projects created per user: > 3
- Time to first report: < 1 hour
- User satisfaction: > 4.5/5

### Business KPIs
- Monthly recurring revenue (MRR)
- Customer acquisition cost (CAC)
- Lifetime value (LTV)
- Churn rate: < 5% monthly

---

## Risks & Mitigation

### Technical Risks
1. **Performance with Large Datasets**
   - Mitigation: Implement data pagination, caching, and query optimization
   
2. **Complex Statistical Calculations**
   - Mitigation: Port existing VBA algorithms carefully, extensive validation

3. **Browser Compatibility**
   - Mitigation: Support modern browsers only, progressive enhancement

### Business Risks
1. **User Adoption**
   - Mitigation: Maintain Excel compatibility, provide migration tools
   
2. **Competition**
   - Mitigation: Focus on IPMVP compliance, unique features, community

3. **Feature Parity**
   - Mitigation: Phased approach, prioritize most-used features

---

## Next Steps

### Immediate Actions
1. **Stakeholder Interviews:** Meet with current ECAM users for feedback
2. **Technical Proof-of-Concept:** Build core data import and charting in 2 weeks
3. **Design Mockups:** Create detailed UI/UX designs for key screens
4. **Cost Refinement:** Get detailed quotes from development teams

### Decision Points
1. **Build vs. Buy:** Evaluate if existing platforms (e.g., EnergyCAP, BuildingOS) could be extended
2. **Open Source:** Decide if this should be open-source (like current ECAM)
3. **Funding:** Seek grants from DOE, utilities, or venture funding
4. **Partnership:** Consider partnering with established energy management platforms

---

## Conclusion

A web-based version of ECAM would transform energy management and verification workflows by enabling:
- **Scalability:** Portfolio-level analysis
- **Collaboration:** Multi-user project work
- **Automation:** Real-time data integration
- **Accessibility:** Work from anywhere
- **Compliance:** Built-in IPMVP/ASHRAE protocols

The proposed architecture maintains the analytical power of the Excel version while leveraging modern web technologies for enhanced user experience, collaboration, and scalability. With an estimated development cost of $700K-$1M and a subscription-based revenue model, this could become a sustainable SaaS business serving the growing energy efficiency market.

**Recommended Path Forward:** Begin with a 3-month proof-of-concept focusing on core data import, visualization, and basic M&V modeling to validate technical feasibility and user interest before committing to full development.

---

## Appendix: Code Migration Examples

### Example 1: VBA Function → Python

**Original VBA:**
```vba
Function CalculateRSquared(rngActual As Range, rngPredicted As Range) As Double
    Dim dblSumSqResiduals As Double
    Dim dblSumSqTotal As Double
    Dim dblMean As Double
    Dim i As Long
    
    dblMean = Application.WorksheetFunction.Average(rngActual)
    
    For i = 1 To rngActual.Count
        dblSumSqResiduals = dblSumSqResiduals + _
            (rngActual.Cells(i).Value - rngPredicted.Cells(i).Value) ^ 2
        dblSumSqTotal = dblSumSqTotal + _
            (rngActual.Cells(i).Value - dblMean) ^ 2
    Next i
    
    CalculateRSquared = 1 - (dblSumSqResiduals / dblSumSqTotal)
End Function
```

**Python Equivalent:**
```python
import numpy as np
from sklearn.metrics import r2_score

def calculate_r_squared(actual: np.ndarray, predicted: np.ndarray) -> float:
    """
    Calculate R-squared value for regression model.
    
    Args:
        actual: Array of actual values
        predicted: Array of predicted values
        
    Returns:
        R-squared value (coefficient of determination)
    """
    return r2_score(actual, predicted)

# Alternative manual calculation
def calculate_r_squared_manual(actual: np.ndarray, predicted: np.ndarray) -> float:
    residuals = actual - predicted
    ss_residuals = np.sum(residuals ** 2)
    ss_total = np.sum((actual - np.mean(actual)) ** 2)
    return 1 - (ss_residuals / ss_total)
```

### Example 2: Chart Creation

**Original VBA (simplified):**
```vba
Sub CreateLoadProfile()
    Dim cht As Chart
    Set cht = ActiveSheet.ChartObjects.Add(Left:=100, Top:=100, _
        Width:=400, Height:=300).Chart
    
    cht.ChartType = xlLine
    cht.SetSourceData Source:=Range("A1:B25")
    cht.HasTitle = True
    cht.ChartTitle.Text = "Load Profile"
End Sub
```

**Python/React Equivalent:**
```python
# FastAPI endpoint
from fastapi import APIRouter
from plotly import graph_objects as go

router = APIRouter()

@router.post("/charts/load-profile")
async def create_load_profile(data: LoadProfileRequest):
    """Create interactive load profile chart."""
    
    # Query data
    df = await get_timeseries_data(
        project_id=data.project_id,
        point_ids=data.point_ids,
        start_date=data.start_date,
        end_date=data.end_date
    )
    
    # Create Plotly figure
    fig = go.Figure()
    
    for point_id in data.point_ids:
        point_data = df[df['point_id'] == point_id]
        fig.add_trace(go.Scatter(
            x=point_data['timestamp'],
            y=point_data['value'],
            name=point_data['point_name'].iloc[0],
            mode='lines'
        ))
    
    fig.update_layout(
        title="Load Profile",
        xaxis_title="Time",
        yaxis_title="Value",
        hovermode='x unified'
    )
    
    return {
        "chart_data": fig.to_json(),
        "chart_id": str(uuid.uuid4())
    }
```

```typescript
// React Component
import Plot from 'react-plotly.js';

interface LoadProfileChartProps {
  projectId: string;
  pointIds: string[];
  dateRange: [Date, Date];
}

export const LoadProfileChart: React.FC<LoadProfileChartProps> = ({
  projectId,
  pointIds,
  dateRange
}) => {
  const { data, isLoading } = useQuery(
    ['load-profile', projectId, pointIds],
    () => createLoadProfile({ projectId, pointIds, dateRange })
  );

  if (isLoading) return <Skeleton height={300} />;

  return (
    <Plot
      data={JSON.parse(data.chart_data).data}
      layout={JSON.parse(data.chart_data).layout}
      config={{ responsive: true }}
    />
  );
};
```

---

## Contact Information

For questions about this proposal or to discuss ECAM web development:

**Steve Kromer**
- Email: johnstephenkromer@iCloud.com
- GitHub: github.com/yourusername/ECAM

**Current ECAM Information:**
- Website: https://sbwconsulting.com/ecam/
- Contact: Michael Baker (mbaker@sbwconsulting.com)
- SBW Consulting: (425) 827-0330

---

*Document Version: 1.0*  
*Date: November 24, 2024*  
*Status: Proposal Draft*
