#\!/usr/bin/env python3
import json
import sys
import os

# Constant
CONTEXT_LIMIT = 200000

# Read JSON from stdin
data = json.load(sys.stdin)

# Extract values
model = data['model']['display_name']
current_dir = os.path.basename(data['workspace']['current_dir'])

# Check for git branch
git_branch = ""
if os.path.exists('.git'):
    try:
        with open('.git/HEAD', 'r') as f:
            ref = f.read().strip()
            if ref.startswith('ref: refs/heads/'):
                git_branch = f" |⚡️ {ref.replace('ref: refs/heads/', '')}"
    except:
        pass

transcript_path = data['transcript_path']

# Parse transcript file to calculate context usage
context_used_token = 0

try:
    with open(transcript_path, 'r') as f:
        lines = f.readlines()
        
        # Iterate from last line to first line
        for line in reversed(lines):
            line = line.strip()
            if not line:
                continue
            
            try:
                obj = json.loads(line)
                # Check if this line contains token usage information
                if (obj.get('type') == 'assistant' and 'message' in obj and 'usage' in obj['message']):
                    usage = obj['message']['usage']
                    input_tokens = usage.get('input_tokens', 0)
                    cache_creation_input_tokens = usage.get('cache_creation_input_tokens', 0)
                    cache_read_input_tokens = usage.get('cache_read_input_tokens', 0)
                    output_tokens = usage.get('output_tokens', 0)
                    
                    context_used_token = input_tokens + cache_creation_input_tokens + cache_read_input_tokens + output_tokens
                    break
            except json.JSONDecodeError:
                continue
                
except Exception:
    pass

# Calculate percentage
context_percentage = (context_used_token / CONTEXT_LIMIT) * 100

# Print status line
print(f"[{model}] 📁 {current_dir}{git_branch} | Context used: {context_percentage:.1f}% ({context_used_token:,}/{CONTEXT_LIMIT:,} tokens)")