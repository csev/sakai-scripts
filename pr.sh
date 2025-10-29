#! /bin/bash

if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi
source config-dist.sh
if [ "$PORT" == "" ]; then 
    echo "Bad configuration or wrong shell"; 
    exit 
fi

# ==========================================
# Validate input argument (PR number)
# ==========================================
if [ $# -ne 1 ]; then
    echo "ERROR: Expected exactly one argument (a PR number)"
    echo "Usage: $0 <PR_NUMBER>"
    exit 1
fi

if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "ERROR: PR number must be numeric"
    echo "Usage: $0 <PR_NUMBER>"
    exit 1
fi

z4pr="$1"
echo "✅ PR number accepted: $z4pr"

# ==========================================
# Repo settings
# ==========================================
REPO_URL="https://github.com/sakaiproject/sakai.git"
TARGET_DIR="trunk"
REMOTE="origin"
BRANCH="pr-${z4pr}-merge"

# ==========================================
# Clean and clone into trunk
# ==========================================
if [ -d "$TARGET_DIR" ]; then
    echo "⚠️  Removing existing $TARGET_DIR directory..."
    rm -rf "$TARGET_DIR"
fi

if [ -d "$TARGET_DIR" ]; then
  tfile="$(mktemp -d /tmp/old-$TARGET_DIR-XXXXXXXXX)"
  echo "Removing $TARGET_DIR folder...."
  mv $TARGET_DIR $tfile
  rm -rf $TARGET_DIR
  rm -rf /tmp/old-$TARGET_DIR-* &
fi


echo "➡️ Cloning $REPO_URL into $TARGET_DIR..."
if ! git clone "$REPO_URL" "$TARGET_DIR"; then
    echo "❌ ERROR: Git clone failed"
    exit 2
fi

cd "$TARGET_DIR" || exit 3

# ==========================================
# Fetch & checkout merge commit for PR
# ==========================================
echo "➡️ Fetching merge commit for PR #$z4pr..."
if ! git fetch "$REMOTE" pull/"$z4pr"/merge:"$BRANCH"; then
    echo "❌ ERROR: Failed to fetch merge commit for PR #$z4pr"
    exit 4
fi

echo "➡️ Checking out $BRANCH..."
if ! git checkout "$BRANCH"; then
    echo "❌ ERROR: Failed to check out branch: $BRANCH"
    exit 5
fi

# ==========================================
# Confirm switch succeeded
# ==========================================
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" != "$BRANCH" ]; then
    echo "❌ ERROR: Expected branch $BRANCH but got $current_branch"
    exit 6
fi

echo "✅ Successfully checked out merge commit for PR #$z4pr"
git --no-pager log --oneline -1



