#!/bin/bash
# Generates dist/stats.svg: contribution totals from the GitHub GraphQL API,
# rendered as a dark glass card (radial spotlight, hairline border, SF stack).
set -euo pipefail
mkdir -p dist

DATA=$(curl -s -H "Authorization: bearer $GH_TOKEN" -X POST https://api.github.com/graphql -d '{"query":"query{user(login:\"sujink1999\"){followers{totalCount} repositories(ownerAffiliations:OWNER){totalCount} contributionsCollection{contributionCalendar{totalContributions} totalCommitContributions restrictedContributionsCount}}}"}')

CONTRIB=$(echo "$DATA" | python3 -c "import json,sys; d=json.load(sys.stdin)['data']['user']; print(d['contributionsCollection']['contributionCalendar']['totalContributions'])")
REPOS=$(echo "$DATA" | python3 -c "import json,sys; print(json.load(sys.stdin)['data']['user']['repositories']['totalCount'])")
FOLLOWERS=$(echo "$DATA" | python3 -c "import json,sys; print(json.load(sys.stdin)['data']['user']['followers']['totalCount'])")

cat > dist/stats.svg <<EOF
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 120" width="640" height="120">
  <defs>
    <radialGradient id="spot" cx="0.5" cy="0" r="1.1">
      <stop offset="0" stop-color="#1c1c1c"/>
      <stop offset="1" stop-color="#0a0a0a"/>
    </radialGradient>
  </defs>
  <rect x="1" y="1" width="638" height="118" rx="16" fill="url(#spot)" stroke="#ffffff" stroke-opacity="0.08" stroke-width="2"/>
  <g font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', Helvetica, Arial, sans-serif" text-anchor="middle">
    <text x="120" y="60" fill="#ffffff" font-size="30" font-weight="500">${CONTRIB}</text>
    <text x="120" y="86" fill="#ffffff" fill-opacity="0.45" font-size="10" letter-spacing="2">CONTRIBUTIONS / YR</text>
    <text x="320" y="60" fill="#ffffff" font-size="30" font-weight="500">${REPOS}</text>
    <text x="320" y="86" fill="#ffffff" fill-opacity="0.45" font-size="10" letter-spacing="2">REPOSITORIES</text>
    <text x="520" y="60" fill="#ffffff" font-size="30" font-weight="500">${FOLLOWERS}</text>
    <text x="520" y="86" fill="#ffffff" fill-opacity="0.45" font-size="10" letter-spacing="2">FOLLOWERS</text>
  </g>
</svg>
EOF
echo "stats: $CONTRIB contributions, $REPOS repos, $FOLLOWERS followers"
