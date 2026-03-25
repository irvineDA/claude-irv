# Irvine's Claude Code Setup

## Quick Install

```bash
# Step 1: Add the marketplace
/plugin marketplace add irvineDA/claude-irv

# Step 2: Install the plugin
/plugin install claude-irv
```

## What's Inside

### 📋 Development Commands (4)

- `/new-task` - Analyze code for performance issues
- `/feature-plan` - Feature implementation planning
- `/lint` - Linting and fixes
- `/docs-generate` - Documentation generation

### 🎨 UI Commands (1)

- `/component-new` - Create React components

### 🤖 Specialized AI Agents (11)

**Architecture & Planning**
- **spring-boot-engineer** - Production-ready Spring and cloud-native Java development.
- **security-engineer** - Expertise in infrastructure and cloud security.
- **kubernetes-specialist** - Deploying complex Kubernetes clusters.
- **docker-expert** - Production-grade container images and orchestration.
- **devops-engineer** - Scalable automated infrastructure and deployment pipelines.
- **tech-stack-researcher** - Technology choice recommendations with trade-offs
- **system-architect** - Scalable system architecture design
- **backend-architect** - Backend systems with data integrity & security
- **frontend-architect** - Performant, accessible UI architecture
- **requirements-analyst** - Transform ideas into concrete specifications

**Code Quality & Performance**
- **code-reviewer** - Identifying code quality issues and optimization opportunities.
- **refactoring-expert** - Systematic refactoring and clean code
- **performance-engineer** - Measurement-driven optimization
- **security-engineer** - Vulnerability identification and security standards

**Documentation & Research**
- **technical-writer** - Clear, comprehensive documentation
- **learning-guide** - Teaching programming concepts progressively
- **deep-research-agent** - Comprehensive research with adaptive strategies

## Usage Examples

### Planning a Feature

```bash
/feature-plan
# Then describe your feature idea
```

### Research Tech Choices

Just ask Claude questions like:
- "Should I use WebSockets or SSE?"
- "How should I structure this database?"
- "What's the best library for X?"

The tech-stack-researcher agent automatically activates and provides detailed, researched answers.
