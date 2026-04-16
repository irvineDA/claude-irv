---
name: obsidian
description: Search and retrieve markdown files from the Obsidian vault. Use when the user asks to search notes, find a note, look something up in Obsidian, or retrieve vault content. Trigger phrases include "search vault", "find note", "obsidian search", "look up in my notes", "what do my notes say about".
user-invocable: true
argument-hint: search query — keywords, topic, or filename to find in the vault
---

# Obsidian Vault Search & Retrieve

Search and retrieve markdown files from the Obsidian vault at `~/Documents/Obsidian Vault/`.

## Vault Location
**Always** use this path: `~/Documents/Obsidian Vault/`

This skill works regardless of the current working directory.

## Step 1: Search

Given the user's query, run **all three** searches in parallel to maximise recall:

1. **Filename search** — find files whose names match the query:
   ```
   find ~/Documents/Obsidian\ Vault -name "*.md" | grep -i "<query>"
   ```

2. **Content search** — find files containing the query terms:
   ```
   grep -rl --include="*.md" -i "<query>" ~/Documents/Obsidian\ Vault/
   ```

3. **Fuzzy/broad search** — if the query has multiple words, search for each word individually and intersect results. Also try partial matches and related terms.

Skip the `_assets` directory in all searches.

## Step 2: Present Results

- List matching files with their relative path from the vault root
- Group by folder (e.g., `reference/`, `notes/`, `projects/`)
- Show the total number of matches
- If there are many matches, present the top 10 most relevant (prefer exact filename matches over content-only matches)

## Step 3: Retrieve

- If the search returns a single clear match, read and display its contents immediately
- If multiple matches are found, present the list and ask the user which file(s) they want to read
- If the user specified a filename or was clearly looking for a specific note, read it directly
- When displaying note contents, preserve the original markdown formatting

## Tips
- Tags in Obsidian use `#tag` syntax — search for these with content search
- Wikilinks use `[[Note Name]]` — search for these to find backlinks
- Frontmatter is in YAML format between `---` delimiters at the top of files
- If nothing is found, suggest alternative search terms or browse relevant folders
