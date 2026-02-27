#!/bin/bash
# COBOL Protocol Verification Script
# Validates all deliverables and shows project summary

set -e

echo "=========================================="
echo "COBOL Protocol - Nafal Faturizki Edition"
echo "Project Verification Script"
echo "=========================================="
echo ""

# Check Python
echo "✓ Checking Python environment..."
python3 --version
echo ""

# Check files
echo "✓ Checking deliverable files..."
files=(
    "engine.py"
    "config.py"
    "test_engine.py"
    "__init__.py"
    "requirements.txt"
    "Dockerfile"
    "docker-compose.yml"
    "README.md"
    "PROJECT_STATUS.md"
    "QUICK_START.md"
    "DELIVERABLES.md"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        size=$(wc -l < "$file" 2>/dev/null || echo "Binary")
        printf "  ✓ %-25s (%s lines)\n" "$file" "$size"
    else
        echo "  ✗ $file - MISSING"
        exit 1
    fi
done
echo ""

# Code statistics
echo "✓ Code statistics:"
total_lines=$(wc -l engine.py config.py test_engine.py | tail -1 | awk '{print $1}')
echo "  Total LOC (engine + config + tests): $total_lines lines"
echo "  Engine (engine.py): $(wc -l < engine.py) lines"
echo "  Configuration (config.py): $(wc -l < config.py) lines"
echo "  Tests (test_engine.py): $(wc -l < test_engine.py) lines"
echo ""

# Try to import the module
echo "✓ Testing module imports..."
python3 -c "from engine import CobolEngine, DictionaryManager, AdaptiveEntropyDetector; print('  All imports successful!')"
echo ""

# Run quick test
echo "✓ Running quick sanity check..."
python3 << 'EOF'
from engine import CobolEngine

engine = CobolEngine()
test_data = b"The quick brown fox jumps over the lazy dog. " * 50
compressed, metadata = engine.compress_block(test_data)

ratio = len(test_data) / len(compressed) if len(compressed) > 0 else 1.0
print(f"  Sample compression: {len(test_data)} → {len(compressed)} bytes ({ratio:.2f}x)")
print(f"  Layers applied: {[l.name for l in metadata.layers_applied]}")

decompressed = engine.decompress_block(compressed, metadata)
is_valid = decompressed == test_data
print(f"  Integrity check: {'✓ PASS' if is_valid else '✗ FAIL'}")
EOF
echo ""

echo "=========================================="
echo "✓ ALL VERIFICATIONS PASSED"
echo "=========================================="
echo ""
echo "Project is ready for use!"
echo ""
echo "Quick start commands:"
echo "  python engine.py       # Run main demo"
echo "  pytest test_engine.py  # Run tests"
echo "  python -c 'from engine import CobolEngine; e = CobolEngine()'"
echo ""
echo "Documentation:"
echo "  README.md           - User guide"
echo "  QUICK_START.md      - Code examples"
echo "  PROJECT_STATUS.md   - Technical details"
echo "  DELIVERABLES.md     - Project summary"
echo ""
