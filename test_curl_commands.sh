#!/bin/bash
# Test curl commands for POST /api/v1/qualifications
# Replace YOUR_API_TOKEN with your actual API token from Rails credentials

API_TOKEN="YOUR_API_TOKEN"
BASE_URL="http://localhost:3000"

echo "🧪 Testing Qualifications API Endpoint"
echo "========================================"
echo ""

# Test 1: sales@hunter.io (simple case, nothing else)
echo "Test 1: sales@hunter.io (simple case)"
echo "--------------------------------------"
curl -X POST "${BASE_URL}/api/v1/qualifications" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -d '{
    "qualification": {
      "email": "sales@hunter.io"
    }
  }' | jq '.'
echo ""
echo ""

# Test 2: bastien@hunter.io, location nigeria
echo "Test 2: bastien@hunter.io with location nigeria"
echo "-----------------------------------------------"
curl -X POST "${BASE_URL}/api/v1/qualifications" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -d '{
    "qualification": {
      "email": "bastien@hunter.io",
      "location": "nigeria"
    }
  }' | jq '.'
echo ""
echo ""

# Test 3: bastien@hunter.io, signup_source appsumo
echo "Test 3: bastien@hunter.io with signup_source appsumo"
echo "----------------------------------------------------"
curl -X POST "${BASE_URL}/api/v1/qualifications" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -d '{
    "qualification": {
      "email": "bastien@hunter.io",
      "signup_source": "appsumo"
    }
  }' | jq '.'
echo ""
echo ""

echo "✅ All curl tests completed!"

