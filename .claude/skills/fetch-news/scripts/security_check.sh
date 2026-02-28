#!/usr/bin/env bash
# セキュリティ検査スクリプト
# docs/ 配下のMarkdownファイルに秘密情報・個人情報が含まれていないか検査する
# 終了コード: 0=問題なし, 1=問題あり

set -euo pipefail

TARGET_DIR="${1:-docs}"
EXIT_CODE=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo " ArchLog Security Check"
echo "========================================="
echo "Target: ${TARGET_DIR}"
echo ""

# --- 1. 秘密情報パターン ---
echo "[1/5] Checking for secrets and credentials..."

SECRET_PATTERNS=(
  # API Keys / Tokens
  'AKIA[0-9A-Z]{16}'                          # AWS Access Key
  'aws_secret_access_key\s*='                  # AWS Secret Key
  'ghp_[a-zA-Z0-9]{36}'                       # GitHub PAT
  'gho_[a-zA-Z0-9]{36}'                       # GitHub OAuth
  'glpat-[a-zA-Z0-9\-]{20}'                   # GitLab PAT
  'sk-[a-zA-Z0-9]{20,}'                       # OpenAI / Stripe secret key
  'xox[bpors]-[a-zA-Z0-9\-]+'                 # Slack token
  'ya29\.[a-zA-Z0-9_\-]+'                     # Google OAuth
  # Generic secrets
  'password\s*[:=]\s*["\x27][^"\x27]{4,}'     # password = "..."
  'secret\s*[:=]\s*["\x27][^"\x27]{4,}'       # secret = "..."
  'token\s*[:=]\s*["\x27][^"\x27]{4,}'        # token = "..."
  'api_key\s*[:=]\s*["\x27][^"\x27]{4,}'      # api_key = "..."
  'apikey\s*[:=]\s*["\x27][^"\x27]{4,}'       # apikey = "..."
  # Private keys
  '-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----'
  '-----BEGIN PGP PRIVATE KEY BLOCK-----'
)

for pattern in "${SECRET_PATTERNS[@]}"; do
  if grep -rPn "$pattern" "$TARGET_DIR" --include='*.md' 2>/dev/null; then
    echo -e "${RED}[FAIL] Secret pattern detected: ${pattern}${NC}"
    EXIT_CODE=1
  fi
done

if [ $EXIT_CODE -eq 0 ]; then
  echo -e "${GREEN}  OK - No secrets found${NC}"
fi

# --- 2. 個人情報パターン ---
echo ""
echo "[2/5] Checking for PII (personal information)..."

PII_FOUND=0
# Email addresses (exclude example.com)
if grep -rPn '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' "$TARGET_DIR" --include='*.md' 2>/dev/null | grep -v 'example\.com' | grep -v 'example\.org'; then
  echo -e "${YELLOW}[WARN] Possible email address found${NC}"
  PII_FOUND=1
fi

# Japanese phone numbers
if grep -rPn '0[0-9]{1,4}-[0-9]{1,4}-[0-9]{4}' "$TARGET_DIR" --include='*.md' 2>/dev/null; then
  echo -e "${YELLOW}[WARN] Possible phone number found${NC}"
  PII_FOUND=1
fi

if [ $PII_FOUND -eq 0 ]; then
  echo -e "${GREEN}  OK - No PII found${NC}"
fi

# --- 3. 内部URL / IPアドレス ---
echo ""
echo "[3/5] Checking for internal URLs and IPs..."

INTERNAL_FOUND=0
# Private IPs
if grep -rPn '(10\.\d+\.\d+\.\d+|172\.(1[6-9]|2[0-9]|3[01])\.\d+\.\d+|192\.168\.\d+\.\d+)' "$TARGET_DIR" --include='*.md' 2>/dev/null; then
  echo -e "${YELLOW}[WARN] Private IP address found${NC}"
  INTERNAL_FOUND=1
fi

# Localhost URLs
if grep -rPn 'https?://(localhost|127\.0\.0\.1|0\.0\.0\.0)' "$TARGET_DIR" --include='*.md' 2>/dev/null; then
  echo -e "${YELLOW}[WARN] Localhost URL found${NC}"
  INTERNAL_FOUND=1
fi

# Internal hostnames
if grep -rPn 'https?://[a-zA-Z0-9.-]+\.(internal|local|corp|intranet)' "$TARGET_DIR" --include='*.md' 2>/dev/null; then
  echo -e "${YELLOW}[WARN] Internal hostname found${NC}"
  INTERNAL_FOUND=1
fi

if [ $INTERNAL_FOUND -eq 0 ]; then
  echo -e "${GREEN}  OK - No internal URLs/IPs found${NC}"
fi

# --- 4. クラウドアカウント固有情報 ---
echo ""
echo "[4/5] Checking for cloud account identifiers..."

CLOUD_FOUND=0
# AWS Account ID (12-digit number in certain contexts)
if grep -rPn 'arn:aws:[a-zA-Z0-9-]+:[a-z0-9-]*:[0-9]{12}:' "$TARGET_DIR" --include='*.md' 2>/dev/null; then
  echo -e "${YELLOW}[WARN] AWS ARN with account ID found${NC}"
  CLOUD_FOUND=1
fi

# Azure subscription ID
if grep -rPn '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' "$TARGET_DIR" --include='*.md' 2>/dev/null; then
  echo -e "${YELLOW}[WARN] Possible UUID (Azure subscription/resource ID) found${NC}"
  CLOUD_FOUND=1
fi

if [ $CLOUD_FOUND -eq 0 ]; then
  echo -e "${GREEN}  OK - No cloud account identifiers found${NC}"
fi

# --- 5. 脆弱性悪用手順 ---
echo ""
echo "[5/5] Checking for exploit-related content..."

EXPLOIT_FOUND=0
EXPLOIT_KEYWORDS=(
  'exploit'
  'shellcode'
  'reverse.shell'
  'sql.injection.*UNION.*SELECT'
  'DROP\s+TABLE'
  '<script>.*alert'
)

for keyword in "${EXPLOIT_KEYWORDS[@]}"; do
  if grep -rPin "$keyword" "$TARGET_DIR" --include='*.md' 2>/dev/null; then
    echo -e "${YELLOW}[WARN] Possible exploit content: ${keyword}${NC}"
    EXPLOIT_FOUND=1
  fi
done

if [ $EXPLOIT_FOUND -eq 0 ]; then
  echo -e "${GREEN}  OK - No exploit content found${NC}"
fi

# --- Summary ---
echo ""
echo "========================================="
if [ $EXIT_CODE -ne 0 ]; then
  echo -e "${RED}RESULT: FAILED - Secrets detected. Fix before committing.${NC}"
else
  echo -e "${GREEN}RESULT: PASSED - All checks passed.${NC}"
fi
echo "========================================="

exit $EXIT_CODE
