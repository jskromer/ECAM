# ECAM Web Version - Project Documentation

## Overview

This repository contains comprehensive documentation for transforming **ECAM (Energy Charting and Metrics)** from an Excel VBA add-in into a modern web application.

ECAM is a powerful tool for energy measurement and verification (M&V), building re-tuning, and Strategic Energy Management (SEM). It's currently used by energy engineers, M&V professionals, and facility managers for IPMVP-compliant energy analysis.

## Documentation Files

### 1. [ECAM Web Version Proposal](./ECAM_Web_Version_Proposal.md)
**Comprehensive business and technical proposal**

This document provides:
- Complete feature inventory from current ECAM
- Proposed web architecture and technology stack
- User interface mockups
- Business model and cost estimates
- Migration strategy from Excel
- Success metrics and risk analysis

**Who should read this:** Stakeholders, decision-makers, product managers, potential investors

### 2. [ECAM Technical Roadmap](./ECAM_Technical_Roadmap.md)
**Detailed 16-month implementation plan**

This document provides:
- Sprint-by-sprint development plan
- Team structure and resource allocation
- Technical standards and best practices
- Risk management strategies
- Budget breakdown
- Success criteria for each phase

**Who should read this:** Engineering leads, project managers, CTOs, development teams

### 3. [ECAM Developer Quick Start](./ECAM_Developer_Quick_Start.md)
**Hands-on guide to start building**

This document provides:
- Step-by-step setup instructions
- Code examples for backend (Python/FastAPI) and frontend (React/TypeScript)
- Sample implementations of key algorithms
- Testing strategies
- Docker configuration
- Common commands and troubleshooting

**Who should read this:** Developers, DevOps engineers, technical contributors

## Quick Links

- **Current ECAM:** https://sbwconsulting.com/ecam/
- **ECAM User Guide:** [Included in upload: ECAM-v6-User-Guide-2018-06-18.pdf]
- **GitHub Repository:** [To be created]
- **Contact:** johnstephenkromer@iCloud.com

## Current ECAM Capabilities (Summary)

ECAM currently provides:

✅ **M&V and IPMVP Compliance**
- Baseline and post-installation modeling
- Savings calculation with uncertainty quantification
- ASHRAE Guideline 14 compliance
- Support for IPMVP Options A, B, and C

✅ **Data Management**
- Interval meter data (15-min, hourly)
- Monthly utility billing data
- Automated weather data integration
- Change-of-value (COV) data handling

✅ **Advanced Visualization**
- 20+ chart types including time-series, scatter, 3D surface, heat maps
- Interactive load profiles
- Matrix charts for portfolio views

✅ **Statistical Modeling**
- Linear regression with change points
- Multi-variable models
- Automated outlier detection
- Model validation statistics

✅ **Building Re-Tuning**
- PNNL protocol automated diagnostics
- Central plant, AHU, and zone analysis
- Fault detection and diagnostics

✅ **Strategic Energy Management**
- Continuous performance tracking
- CUSUM charts and heat maps
- Behavioral change detection

## Proposed Web Version Highlights

### Technology Stack
- **Frontend:** React + TypeScript, Material-UI, Plotly.js
- **Backend:** Python FastAPI, PostgreSQL + TimescaleDB
- **Infrastructure:** Docker, Kubernetes, AWS/GCP

### Key Advantages
1. **Scalability:** Analyze 100s of buildings simultaneously
2. **Collaboration:** Real-time multi-user access
3. **Integration:** Direct BAS and utility API connections
4. **Accessibility:** Browser-based, works on any device
5. **Enhanced Analytics:** ML-powered insights and predictions

### Development Timeline
- **Phase 1 (MVP):** Months 1-4
- **Phase 2 (M&V):** Months 5-8
- **Phase 3 (Advanced):** Months 9-12
- **Phase 4 (Scale):** Months 13-16

### Estimated Costs
- **Development:** $700K - $1M
- **Annual Operations:** $200K - $350K
- **Revenue Potential:** $150K (Year 1) → $3M (Year 4)

## Getting Started

### For Stakeholders
1. Read the [Web Version Proposal](./ECAM_Web_Version_Proposal.md)
2. Review cost-benefit analysis in Section "Cost Estimate & Business Model"
3. Provide feedback on priorities and timeline

### For Project Managers
1. Review the [Technical Roadmap](./ECAM_Technical_Roadmap.md)
2. Assess resource requirements
3. Plan sprint schedules and milestones

### For Developers
1. Follow the [Developer Quick Start](./ECAM_Developer_Quick_Start.md)
2. Set up local development environment
3. Start with proof-of-concept features

## Project Status

**Current Status:** Planning / Proposal Stage

**Next Steps:**
- [ ] Gather feedback from current ECAM users
- [ ] Build proof-of-concept (data import + basic charts)
- [ ] Finalize technical architecture
- [ ] Secure funding (grants, partnerships, or VC)
- [ ] Assemble development team

## Key Decision Points

### 1. Open Source vs. Proprietary?
- **Current ECAM:** Apache 2.0 License (open source)
- **Consideration:** Maintain open source to encourage adoption, or go proprietary for revenue?

### 2. Build vs. Buy?
- Could existing platforms (EnergyCAP, BuildingOS) be extended?
- Or build from scratch to maintain full control?

### 3. SaaS vs. On-Premise?
- Cloud-first SaaS approach (recommended)
- Offer on-premise deployment for enterprise customers?

### 4. Pricing Model?
- Per-user subscription
- Per-building pricing
- Enterprise site licenses
- Freemium model?

## Contributing

We welcome contributions from:
- Energy engineers (domain expertise)
- Software developers (implementation)
- UI/UX designers (user experience)
- Technical writers (documentation)

**How to contribute:**
1. Review documentation
2. Provide feedback via issues/discussions
3. Submit pull requests with improvements
4. Join monthly community calls

## Funding Opportunities

Potential funding sources:
- **DOE Grants:** Building Technologies Office
- **Utility Programs:** Energy efficiency incentives
- **BPA:** Bonneville Power Administration (past sponsor)
- **NEEA:** Northwest Energy Efficiency Alliance
- **Venture Capital:** Climate tech investors

## Success Stories (Current ECAM)

ECAM has been successfully used for:
- Strategic Energy Management programs across the Pacific Northwest
- IPMVP-compliant M&V for commercial buildings
- Building re-tuning diagnostics (PNNL protocol)
- Utility demand response verification
- Energy efficiency program evaluation

## Technical Highlights

### Algorithm Porting
- **VBA → Python:** Carefully ported statistical algorithms
- **Validation:** Extensive testing against Excel results
- **Performance:** Optimized for large datasets

### Data Pipeline
```
BAS/Utility APIs → Data Import → Validation → TimescaleDB → 
Analytics Engine → Visualization → Reports/Dashboards
```

### Scalability
- **Interval Data:** Handle millions of timestamps
- **Concurrent Users:** Support 500+ simultaneous users
- **Response Time:** < 200ms API responses
- **Uptime:** 99.9% SLA

## Project Team

### Original ECAM Authors
- **Bill Koran, P.E.** - Creator and lead developer
- **Gina Hicks** - Recent features and improvements
- **SBW Consulting** - Development and maintenance

### Web Version Lead
- **Steve Kromer** - Project lead, architecture
- Contact: johnstephenkromer@iCloud.com

### Seeking Contributors
- Backend developers (Python/FastAPI)
- Frontend developers (React/TypeScript)
- Energy engineers (M&V expertise)
- DevOps engineers (Infrastructure)

## Resources

### Documentation
- **ECAM Website:** https://sbwconsulting.com/ecam/
- **User Guide:** ECAM-v6-User-Guide-2018-06-18.pdf (157 pages)
- **LinkedIn Article:** https://www.linkedin.com/pulse/energy-charting-metrics-ecam-bill-koran/

### Standards & Protocols
- **IPMVP:** https://evo-world.org/
- **ASHRAE Guideline 14:** https://www.ashrae.org/
- **PNNL Re-tuning:** https://buildingretuning.pnnl.gov/

### Similar Tools (Competitive Analysis)
- EnergyCAP
- BuildingOS (Lucid)
- EnergyPrint
- Energy Star Portfolio Manager
- SkySpark

## Frequently Asked Questions

**Q: Why move from Excel to web?**  
A: Excel ECAM is powerful but limited by single-user access, no real-time data, manual workflows, and difficulty scaling to portfolios.

**Q: Will the web version be free?**  
A: TBD - options include open-source with paid hosting, freemium model, or subscription-based.

**Q: Can I still use Excel ECAM?**  
A: Yes! Excel version will continue to be available. Web version will offer Excel import/export for compatibility.

**Q: How long until web version is ready?**  
A: MVP in 4 months, full feature parity in 12 months (estimated).

**Q: Will my existing ECAM projects transfer?**  
A: Yes, migration tools will be built to import existing projects.

**Q: Does this support real-time data?**  
A: Yes! Web version will support real-time BAS data streams and automated utility imports.

## License

**Current ECAM:** Apache License 2.0  
**Proposed Web Version:** TBD (likely Apache 2.0 to maintain community)

## Contact & Support

**General Inquiries:** johnstephenkromer@iCloud.com  
**Current ECAM Support:** mbaker@sbwconsulting.com  
**SBW Consulting:** (425) 827-0330

**Stay Updated:**
- GitHub: [Repository link]
- LinkedIn: [Group link]
- Email List: [Subscribe link]

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2024-11-24 | Steve Kromer | Initial proposal documentation |

---

## Acknowledgments

This project builds upon the excellent work of:
- Bill Koran and Gina Hicks (SBW Consulting) - Original ECAM development
- Bonneville Power Administration - Funding and support
- Northwest Energy Efficiency Alliance - Early funding
- Pacific Northwest National Laboratory - Re-tuning protocols
- California Energy Commission - PIER Buildings Program funding

Special thanks to all ECAM users who have provided feedback and shaped the tool over the years.

---

*"Making energy data analysis accessible, collaborative, and scalable."*

**ECAM Web - Empowering energy professionals with modern tools for a sustainable future.**
