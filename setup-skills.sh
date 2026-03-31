#!/usr/bin/env bash
# Setup script to verify and install all skills
#
# Checks for:
# - Custom skills (from this repo)
# - Planning skills (from mattpocock/skills)
# - Tooling skills (from mitsuhiko/agent-stuff)
# - Design skills (from Impeccable)
#
# Run after cloning or to verify workspace setup.

set -e

SKILLS_DIR="${PI_SKILLS_DIR:-$HOME/.config/pi/agent/skills}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=== Pi Skills Setup ==="
echo "Skills directory: $SKILLS_DIR"
echo ""

# Check if a skill exists
skill_exists() {
  [ -d "$SKILLS_DIR/$1" ] || [ -f "$SKILLS_DIR/$1/SKILL.md" ]
}

# Mark a skill as present
mark_present() {
  printf "  ${GREEN}✓${NC} $1\n"
}

# Mark a skill as missing
mark_missing() {
  printf "  ${RED}✗${NC} $1 (missing)\n"
}

# ============================================
# Check custom skills (from this repo)
# ============================================
echo "Custom skills (from this repo):"

CUSTOM_SKILLS=("init-pre-commit" "prd-to-todos" "review-and-commit")
CUSTOM_MISSING=0

for skill in "${CUSTOM_SKILLS[@]}"; do
  if [ -d "$REPO_DIR/skills/$skill" ]; then
    mark_present "$skill"
  else
    mark_missing "$skill"
    CUSTOM_MISSING=1
  fi
done

if [ $CUSTOM_MISSING -eq 1 ]; then
  echo ""
  echo "  ${YELLOW}Warning:${NC} Some custom skills are missing from the repo."
  echo "  Make sure you've cloned the complete repository."
fi

echo ""

# ============================================
# Check mattpoclock skills
# ============================================
echo "Planning skills (from mattpocock/skills):"

MATTP_SKILLS=("write-a-prd" "prd-to-plan" "grill-me" "design-an-interface" "tdd" "improve-codebase-architecture")
MATTP_MISSING=()

for skill in "${MATTP_SKILLS[@]}"; do
  if skill_exists "$skill"; then
    mark_present "$skill"
  else
    mark_missing "$skill"
    MATTP_MISSING+=("$skill")
  fi
done

echo ""

# ============================================
# Check mitsupi skills
# ============================================
echo "Tooling skills (from mitsuhiko/agent-stuff via mitsupi):"

MITSU_SKILLS=("tmux" "uv" "update-changelog")
MITSU_MISSING=()

for skill in "${MITSU_SKILLS[@]}"; do
  if skill_exists "$skill"; then
    mark_present "$skill"
  else
    mark_missing "$skill"
    MITSU_MISSING+=("$skill")
  fi
done

echo ""

# ============================================
# Check Impeccable skills
# ============================================
echo "Design skills (from Impeccable):"

IMPECCABLE_SKILLS=(
  "frontend-design"
  "audit"
  "critique"
  "polish"
  "normalize"
  "distill"
  "clarify"
  "optimize"
  "harden"
  "adapt"
  "arrange"
  "typeset"
  "onboard"
  "extract"
  "animate"
  "colorize"
  "bolder"
  "quieter"
  "delight"
  "overdrive"
  "teach-impeccable"
)
IMPECCABLE_COUNT=0

for skill in "${IMPECCABLE_SKILLS[@]}"; do
  if skill_exists "$skill"; then
    IMPECCABLE_COUNT=$((IMPECCABLE_COUNT + 1))
  fi
done

if [ $IMPECCABLE_COUNT -eq ${#IMPECCABLE_SKILLS[@]} ]; then
  printf "  ${GREEN}✓${NC} All ${#IMPECCABLE_SKILLS[@]} Impeccable skills installed\n"
else
  printf "  ${RED}✗${NC} Only $IMPECCABLE_COUNT/${#IMPECCABLE_SKILLS[@]} Impeccable skills installed\n"
fi

echo ""

# ============================================
# Summary
# ============================================
echo "=== Summary ==="

TOTAL_MATTP=${#MATTP_MISSING[@]}
TOTAL_MITSU=${#MITSU_MISSING[@]}
TOTAL_IMPECCABLE=$((${#IMPECCABLE_SKILLS[@]} - IMPECCABLE_COUNT))

if [ $TOTAL_MATTP -eq 0 ] && [ $TOTAL_MITSU -eq 0 ] && [ $TOTAL_IMPECCABLE -eq 0 ]; then
  printf "${GREEN}All skills are installed!${NC}\n"
  exit 0
fi

printf "${YELLOW}Missing skills detected.${NC}\n\n"

# ============================================
# Installation instructions
# ============================================
echo "=== Installation Instructions ==="
echo ""

if [ $TOTAL_MATTP -gt 0 ]; then
  printf "${BLUE}Planning skills:${NC}\n"
  echo "  Source: https://github.com/mattpocock/skills"
  echo "  Missing: ${MATTP_MISSING[*]}"
  echo ""
  echo "  npx skills@latest add mattpocock/skills --skill '*' -g -a pi -y"
  echo ""
fi

if [ $TOTAL_MITSU -gt 0 ]; then
  printf "${BLUE}Tooling skills:${NC}\n"
  echo "  Source: https://github.com/mitsuhiko/agent-stuff"
  echo "  Missing: ${MITSU_MISSING[*]}"
  echo ""
  echo "  # Option 1: Install via npm (if published)"
  echo "  npm install -g mitsupi"
  echo ""
  echo "  # Option 2: Clone and symlink"
  echo "  git clone https://github.com/mitsuhiko/agent-stuff.git ~/code/agent-stuff"
  echo "  ln -s ~/code/agent-stuff/skills/* $SKILLS_DIR/"
  echo ""
fi

if [ $TOTAL_IMPECCABLE -gt 0 ]; then
  printf "${BLUE}Design skills:${NC}\n"
  echo "  Source: https://impeccable.style"
  echo "  Missing: $TOTAL_IMPECCABLE skills"
  echo ""
  echo "  # Download from website or clone:"
  echo "  git clone https://github.com/paulbakaus/impeccable.git ~/code/impeccable"
  echo "  cp -r ~/code/impeccable/dist/pi/.pi/* $SKILLS_DIR/"
  echo ""
  read -p "  Open impeccable.style in browser? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "https://impeccable.style" 2>/dev/null || xdg-open "https://impeccable.style" 2>/dev/null
  fi
fi

echo ""
echo "Re-run this script after installation to verify."
