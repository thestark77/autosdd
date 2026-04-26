---
name: knowledge-graph
description: >
  Generates a visual knowledge graph of the AI's memory, decisions, user profile,
  guidelines, and their relationships. Exports as JSON (for D3.js/web viewers) or
  as an Obsidian vault with wikilinks. Helps users understand what the AI knows,
  what connections exist, and where gaps are.
version: "1.0.0"
license: MIT
metadata:
  author: gentleman-programming
  repository: https://github.com/thestark77/autosdd
  requires:
    - autoSDD framework (active)
    - Engram MCP (primary data source)
  compatible_agents:
    - Claude Code
    - Cursor
    - Windsurf
---

# Knowledge Graph — Skill

> Visualize the AI's mind: what it knows, what it remembers, and how everything connects.

## Trigger

Activated when:
- User invokes `/knowledge-graph`
- User asks "what do you know?", "show me your memory", "qué sabés?", "mostrame tu memoria"
- User asks "knowledge graph", "mind map", "memory map"

## Commands

| Command | Description |
|---------|------------|
| `/knowledge-graph` | Generate full graph (JSON + optional HTML viewer) |
| `/knowledge-graph obsidian` | Generate Obsidian-compatible vault |
| `/knowledge-graph focus:{topic}` | Graph centered on a specific topic |
| `/knowledge-graph stats` | Summary statistics without full graph |

## Data Collection Protocol

Collect data from these sources IN ORDER. Stop early if token budget exceeded.

### Step 1: Engram Memories (primary source)
```
mem_search(query: "decision OR architecture OR pattern OR convention OR bugfix", project: "{project}", limit: 50)
```
For each result, extract: id, title, type, topic_key, created_at, content summary (first 100 chars).

### Step 2: User Profile
Read `context/user_context.md` — extract: name, role, skills, preferences, skill gaps.

### Step 3: Guidelines & Conventions
Read `context/guidelines.md` — extract: section headers, key rules, anti-patterns.

### Step 4: Business Logic
Read `context/business_logic.md` — extract: entities, workflows, domain terms.

### Step 5: Version History
List `context/appVersions/v*/` directories. For each, read ONLY `feedback.md` first line (version + score).

### Step 6: Feedback Patterns
```
mem_search(query: "feedback/user-patterns", project: "{project}")
```
Extract: recurring skill gaps, improvement trends.

## Graph Schema

### Node Types

| Type | Icon | Color | Source |
|------|------|-------|--------|
| `user` | 👤 | blue | user_context.md |
| `decision` | 🔷 | purple | Engram (type: decision) |
| `architecture` | 🏗️ | orange | Engram (type: architecture) |
| `guideline` | 📏 | green | guidelines.md sections |
| `convention` | 📐 | teal | Engram (type: pattern/convention) |
| `bugfix` | 🐛 | red | Engram (type: bugfix) |
| `discovery` | 💡 | yellow | Engram (type: discovery) |
| `entity` | 📦 | gray | business_logic.md entities |
| `workflow` | 🔄 | cyan | business_logic.md workflows |
| `version` | 📋 | white | appVersions/ directories |
| `skill-gap` | ⚠️ | amber | feedback/user-patterns |
| `preference` | ⚙️ | slate | Engram (type: preference) |

### Edge Types

| Type | Meaning | Example |
|------|---------|---------|
| `decided-in` | Decision was made during version | decision → version |
| `resulted-in` | Discovery led to guideline | discovery → guideline |
| `has-gap` | User has this skill gap | user → skill-gap |
| `prefers` | User preference | user → preference |
| `governs` | Guideline governs entity | guideline → entity |
| `uses` | Workflow uses entity | workflow → entity |
| `fixed-in` | Bug was fixed in version | bugfix → version |
| `related-to` | General relationship | any → any |
| `evolved-from` | Convention evolved from decision | convention → decision |
| `contradicts` | Two nodes conflict (needs resolution) | any → any |

### JSON Export Format

Output to `context/knowledge-graph.json`:

```json
{
  "metadata": {
    "project": "{project}",
    "generated": "{ISO date}",
    "total_nodes": 0,
    "total_edges": 0,
    "data_sources": ["engram", "user_context", "guidelines", "business_logic", "versions"]
  },
  "nodes": [
    {
      "id": "unique-id",
      "type": "decision|architecture|guideline|...",
      "label": "Short display label",
      "description": "One-line description",
      "source": "engram|file|inferred",
      "created": "ISO date or null",
      "metadata": {}
    }
  ],
  "edges": [
    {
      "source": "node-id",
      "target": "node-id",
      "type": "decided-in|resulted-in|...",
      "label": "Optional edge label",
      "weight": 1
    }
  ],
  "clusters": [
    {
      "id": "cluster-id",
      "label": "Cluster name",
      "nodes": ["node-id-1", "node-id-2"]
    }
  ]
}
```

### HTML Viewer (pre-installed template)

The HTML viewer is a **static template** pre-installed by the autoSDD installer at `context/knowledge-graph.html`. **Do NOT regenerate the HTML file.** It loads data dynamically from a JS file.

After generating `context/knowledge-graph.json`, also write a data loader file:

**`context/knowledge-graph-data.js`:**
```js
window.GRAPH_DATA = <contents of knowledge-graph.json>;
```

This is the ONLY file the HTML viewer needs. The user opens `context/knowledge-graph.html` in a browser and the graph renders automatically from the data file.

Features (built into the template): color-coded nodes by type, size by connection count, hover highlighting, click sidebar, search/filter, zoom/pan.

### Obsidian Export

When `/knowledge-graph obsidian` is invoked, generate an Obsidian vault:

```
context/knowledge-vault/
├── _index.md              # Dashboard with stats and links
├── decisions/
│   └── {decision-name}.md # [[wikilinks]] to related nodes
├── architecture/
│   └── {arch-name}.md
├── guidelines/
│   └── {guideline-name}.md
├── entities/
│   └── {entity-name}.md
├── versions/
│   └── {version}.md
├── user-profile.md
└── skill-gaps.md
```

Each .md file uses Obsidian wikilinks: `[[decisions/auth-pattern|Auth Pattern Decision]]`

## Token Budget

- `/knowledge-graph`: Max 3000 tokens. Only generates JSON + data.js (HTML is pre-installed).
- `/knowledge-graph stats`: Max 500 tokens. Just counts and top-5 lists.
- `/knowledge-graph focus:{topic}`: Max 2000 tokens. Only nodes within 2 hops of topic.
- `/knowledge-graph obsidian`: Max 8000 tokens (more files to write).

## Edge Inference Rules

Edges are not always explicit. Infer relationships:

1. **Temporal**: If a decision and a guideline share the same version → `decided-in` + `resulted-in`
2. **Topic key**: If two Engram memories share a topic_key prefix → `related-to`
3. **Content**: If a bugfix mentions a guideline by name → `violates` or `follows`
4. **Skill gaps**: If a feedback report mentions a gap that a guideline addresses → `addresses`
5. **Entity-workflow**: If business_logic.md shows an entity in a workflow → `uses`
