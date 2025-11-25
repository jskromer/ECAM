#!/bin/bash
# Setup script for ECAM repository

echo "Setting up ECAM repository..."

# Create directory structure
mkdir -p ECAM/docs ECAM/reference

# Navigate to ECAM directory
cd ECAM

# Initialize git
git init
git branch -M main

# Create .gitignore
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
venv/
__pycache__/
*.pyc

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Environment
.env
.env.local

# Build
dist/
build/
*.egg-info/

# Data
*.csv
*.xlsx
data/

# Large files (except reference)
*.xlam
!reference/*.xlam
EOF

echo "✅ Directory structure created"
echo "✅ Git initialized"
echo "✅ .gitignore created"
echo ""
echo "Next steps:"
echo "1. Download the markdown files from Claude and place them in:"
echo "   - README.md → ./README.md"
echo "   - ECAM_Web_Version_Proposal.md → ./docs/"
echo "   - ECAM_Technical_Roadmap.md → ./docs/"
echo "   - ECAM_Developer_Quick_Start.md → ./docs/"
echo ""
echo "2. Download reference files (if available):"
echo "   - ECAM_v6r6_2023-01-06.xlam → ./reference/"
echo "   - ECAM-v6-User-Guide-2018-06-18.pdf → ./reference/"
echo ""
echo "3. Once files are in place, run:"
echo "   git add ."
echo "   git config user.name 'Steve Kromer'"
echo "   git config user.email 'johnstephenkromer@iCloud.com'"
echo "   git commit -m 'Initial commit: ECAM web version documentation'"
echo "   git remote add origin https://github.com/Jskromer/ECAM.git"
echo "   git push -u origin main"
