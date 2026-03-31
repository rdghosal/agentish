#!/usr/bin/env bash
# Setup script to verify and install all skills
#
# Checks for:
# - Custom skills (from rdghosal/skills)
# - Planning skills (from mattpocock/skills)
# - Tooling skills (from mitsuhiko/agent-stuff)
# - Design skills (from pbakaus/impeccable)
#
# Run after cloning or to verify workspace setup.

set -e

# Skills directories for different AI coding assistants
# Use PI_CODING_AGENT_DIR if set, otherwise fall back to default
PI_SKILLS_DIR="${PI_CODING_AGENT_DIR:+$PI_CODING_AGENT_DIR/skills}"
PI_SKILLS_DIR="${PI_SKILLS_DIR:-$HOME/.pi/agent/skills}"
AGENTS_SKILLS_DIR="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
CLAUDE_SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
OPENCODE_SKILLS_DIR="${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills}"

# Directories that need symlinks (managed by us, not npx skills)
SYMLINK_DIRS=(
  "$PI_SKILLS_DIR"
  "$OPENCODE_SKILLS_DIR"
)

# All skills directories as an array
ALL_SKILLS_DIRS=(
  "$PI_SKILLS_DIR"
  "$AGENTS_SKILLS_DIR"
  "$CLAUDE_SKILLS_DIR"
  "$OPENCODE_SKILLS_DIR"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=== AI Coding Assistant Skills Setup ==="
echo ""
echo "Skills directories:"
echo "  Pi:       $PI_SKILLS_DIR"
echo "  Agents:   $AGENTS_SKILLS_DIR"
echo "  Claude:   $CLAUDE_SKILLS_DIR"
echo "  OpenCode: $OPENCODE_SKILLS_DIR"
echo ""

# Check if a skill exists in all skills directories
skill_exists() {
  for dir in "${ALL_SKILLS_DIRS[@]}"; do
    [ -d "$dir/$1" ] || return 1
  done
  return 0
}

# Mark a skill as present
mark_present() {
  printf "  ${GREEN}✓${NC} $1\n"
}

# Mark a skill as missing
mark_missing() {
  printf "  ${RED}✗${NC} $1 (missing)\n"
}

# Check a list of skills and return missing ones via global array
# Args: $1 = category name, $2... = skill names
# Sets: MISSING_SKILLS array, MISSING_COUNT
check_skills() {
  local category="$1"
  shift
  MISSING_SKILLS=()
  MISSING_COUNT=0

  echo "$category:"

  for skill in "$@"; do
    if skill_exists "$skill"; then
      mark_present "$skill"
    else
      mark_missing "$skill"
      MISSING_SKILLS+=("$skill")
      MISSING_COUNT=$((MISSING_COUNT + 1))
    fi
  done
  echo ""
}

# Build skill args for npx skills add (multiple --skill flags)
# Args: $1... = skill names
# Output: sets SKILL_ARGS array
build_skill_args() {
  SKILL_ARGS=()
  for skill in "$@"; do
    SKILL_ARGS+=("--skill" "$skill")
  done
}

# Create symlinks from ~/.agents/skills to Pi and OpenCode directories
# Args: $1... = skill names
symlink_skills() {
  for skill in "$@"; do
    # Skip if source doesn't exist
    [ -d "$AGENTS_SKILLS_DIR/$skill" ] || continue

    for target_dir in "${SYMLINK_DIRS[@]}"; do
      # Create target directory if it doesn't exist
      mkdir -p "$target_dir"

      # Remove existing file/symlink/directory if present
      [ -e "$target_dir/$skill" ] && rm -rf "${target_dir:?}/${skill:?}"

      # Create relative symlink
      ln -s "$AGENTS_SKILLS_DIR/$skill" "$target_dir/$skill"
    done
  done
}

# ============================================
# Skill definitions
# ============================================
CUSTOM_SKILLS=(
  "design-an-interface"
  "improve-codebase-architecture"
  "init-pre-commit"
  "prd-to-todos"
  "review-and-commit"
)

MATTP_SKILLS=("write-a-prd" "prd-to-plan" "grill-me" "tdd")

MITSU_SKILLS=("tmux" "uv" "update-changelog")

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
  "teach-impeccable"
)

# ============================================
# Check all skills
# ============================================
echo "=== Checking Skills ==="
echo ""

check_skills "Custom skills (from rdghosal/skills)" "${CUSTOM_SKILLS[@]}"
CUSTOM_MISSING=("${MISSING_SKILLS[@]}")
CUSTOM_COUNT=$MISSING_COUNT

check_skills "Planning skills (from mattpocock/skills)" "${MATTP_SKILLS[@]}"
MATTP_MISSING=("${MISSING_SKILLS[@]}")
MATTP_COUNT=$MISSING_COUNT

check_skills "Tooling skills (from mitsuhiko/agent-stuff)" "${MITSU_SKILLS[@]}"
MITSU_MISSING=("${MISSING_SKILLS[@]}")
MITSU_COUNT=$MISSING_COUNT

check_skills "Design skills (from pbakaus/impeccable)" "${IMPECCABLE_SKILLS[@]}"
IMPECCABLE_MISSING=("${MISSING_SKILLS[@]}")
IMPECCABLE_COUNT=$MISSING_COUNT

# ============================================
# Summary
# ============================================
echo "=== Summary ==="

TOTAL_MISSING=$((CUSTOM_COUNT + MATTP_COUNT + MITSU_COUNT + IMPECCABLE_COUNT))

if [ $TOTAL_MISSING -eq 0 ]; then
  printf "${GREEN}All skills are installed!${NC}\n"
  exit 0
fi

printf "${YELLOW}Missing skills detected.${NC}\n\n"

# ============================================
# Install missing skills
# ============================================
echo "=== Installing Missing Skills ==="
echo ""

if [ $CUSTOM_COUNT -gt 0 ]; then
  printf "${BLUE}Installing custom skills:${NC}\n"
  echo "  Source: https://github.com/rdghosal/skills"
  build_skill_args "${CUSTOM_MISSING[@]}"
  npx skills add rdghosal/skills "${SKILL_ARGS[@]}" --agent '*' -g -y
  symlink_skills "${CUSTOM_MISSING[@]}"
  echo ""
fi

if [ $MATTP_COUNT -gt 0 ]; then
  printf "${BLUE}Installing planning skills:${NC}\n"
  echo "  Source: https://github.com/mattpocock/skills"
  build_skill_args "${MATTP_MISSING[@]}"
  npx skills add mattpocock/skills "${SKILL_ARGS[@]}" --agent '*' -g -y
  symlink_skills "${MATTP_MISSING[@]}"
  echo ""
fi

if [ $MITSU_COUNT -gt 0 ]; then
  printf "${BLUE}Installing tooling skills:${NC}\n"
  echo "  Source: https://github.com/mitsuhiko/agent-stuff"
  build_skill_args "${MITSU_MISSING[@]}"
  npx skills add mitsuhiko/agent-stuff "${SKILL_ARGS[@]}" --agent '*' -g -y
  symlink_skills "${MITSU_MISSING[@]}"
  echo ""
fi

if [ $IMPECCABLE_COUNT -gt 0 ]; then
  printf "${BLUE}Installing design skills:${NC}\n"
  echo "  Source: https://github.com/pbakaus/impeccable"
  build_skill_args "${IMPECCABLE_MISSING[@]}"
  npx skills add pbakaus/impeccable "${SKILL_ARGS[@]}" --agent '*' -g -y
  symlink_skills "${IMPECCABLE_MISSING[@]}"
  echo ""
fi

# ============================================
# Re-validate installations
# ============================================
echo "=== Re-validating ==="
echo ""

check_skills "Custom skills" "${CUSTOM_SKILLS[@]}"
check_skills "Planning skills" "${MATTP_SKILLS[@]}"
check_skills "Tooling skills" "${MITSU_SKILLS[@]}"
check_skills "Design skills" "${IMPECCABLE_SKILLS[@]}"

echo "=== Done ==="
