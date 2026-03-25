---
name: jira-ticket
description: Generate clear, copy-paste-ready Jira ticket descriptions from user requirements. Use this skill whenever the user asks to create a Jira ticket, write a ticket, generate a story, create a task description, or mentions anything related to writing tickets for a backlog, sprint planning, or issue tracking. Also trigger when users say things like "break this into tickets", "write acceptance criteria", "create user stories", or "I need a ticket for...".
---

# Jira Ticket Generator

Generate structured, high-signal Jira ticket descriptions that are immediately
copy-paste ready. Output ONLY the formatted ticket content — no wrapper code blocks,
no commentary, no metadata like story points or assignees.

## Information Gathering (MANDATORY — Do This First)

Before generating any ticket, determine whether you have enough information to write
a complete, actionable ticket. Do NOT generate a ticket with gaps or assumptions.

### Step 1: Classify the Ticket Type

Determine from the user's request whether this is:
- **[FE]** — Frontend work (UI, components, forms, client-side logic)
- **[BE]** — Backend work (APIs, database, services, infrastructure)

Prefix the ticket title with the appropriate tag.

### Step 2: Check for Missing Information

Review the user's input against the checklists below. If ANY relevant item is not
addressed or clearly implied, ask the user BEFORE generating the ticket.

Ask only the questions that are relevant — don't ask about database schemas for a
pure frontend ticket. Group your questions into a single message rather than
asking one at a time.

#### Common Questions (all ticket types)
- Are there any rules or permissions that control visibility of elements or access to this feature?

#### Frontend [FE] Questions
- Are there any Figma designs (or other mockups) for this feature?
- Are there any HATEOAS links from the API that convey permissions or available actions?
- Are there any validation rules on the form (field types, required fields, max lengths, patterns)?
- Are there any reusable components that should be used here (design system, shared component library)?
- What is the schema/shape of the data coming from the backend?

#### Backend [BE] Questions
- Are there any schema changes for the database required?
- Are there any infrastructure changes required (new services, queues, caches, environment config)?
- What is the expected request/response schema for the API?

### Step 3: Incorporate Answers

Once the user provides answers:
- Weave Figma links into the Background or Tech Notes (not Acceptance Criteria)
- Translate validation rules into specific Acceptance Criteria
- Reference reusable components in Tech Notes
- Include schema details in Tech Notes
- Capture permission/visibility rules as both User Stories (denied-access scenarios) and Acceptance Criteria
- Note infrastructure or DB migration needs in Tech Notes

If the user explicitly says information is not applicable or not yet known, note it
as a known gap in Tech Notes (e.g., "Schema TBD — awaiting API contract from backend team").

## Core Principles

1. **Gather before generating**: Never produce a ticket with assumptions. Ask for missing information first.
2. **High signal-to-noise**: Include only essential information. No repetition, no filler.
3. **Action-oriented**: Focus on what to build, not background research or history.
4. **Copy-paste ready**: Output goes directly into Jira's description field without modification.
5. **Right-sized**: Each ticket should represent ~3 business days of work. If the request is larger, break it into multiple tickets.
6. **No non-functional requirements**: Omit NFRs (performance targets, load times, etc.) — those belong at the epic level.

## Mandatory Ticket Structure

Every ticket MUST follow this exact structure, in this order:

### Title
A succinct, scannable title for the Jira board. Use the format: `[FE|BE] [Area/Feature] Action description`.

### Background
2–4 sentences maximum. Explain WHY this work matters and what problem it solves.
Focus on business/user impact. No implementation details here. 
This should contain any surrounding or relavent information that pertains to the ticket.

### User Stories
Gherkin-format stories wrapped in triple-backtick fenced code blocks for Jira syntax highlighting.
Include the `Feature:` and `Scenario:` keywords. 1–5 stories max, each a distinct user journey.

Use this exact format:

~~~
```
Feature: [Feature name]

  Scenario: [Scenario name]
    Given [initial context]
    When [action taken]
    Then [expected outcome]

  Scenario: [Another scenario]
    Given [initial context]
    When [action taken]
    Then [expected outcome]
```
~~~

### Acceptance Criteria
- Bullet-pointed, independently testable requirements
- Use clear measurable language: "should display", "must validate", "returns 200"
- Cover happy path AND key error/edge cases
- 3–7 criteria is typical
- No implementation details (those go in Tech Notes)

### Tech Notes
Implementation guidance, constraints, or discussion points. Include only if substantive:
- Dependencies on other tickets/systems
- API endpoints or services involved
- Performance or security considerations
- Breaking changes or migration needs
- Suggested approaches when trade-offs are non-obvious

Omit this section entirely if there's nothing worth noting.

## What to Exclude

- Verbose introductions or preambles
- Repetition across sections
- Information already conveyed by the title
- Generic platitudes ("ensure good UX", "code should work correctly")
- Non-functional requirements (belong at epic level)
- Implementation details in Acceptance Criteria (move to Tech Notes)
- Historical context unless directly relevant
- Explanatory text before or after the ticket
- Ticket IDs, story points, assignees, or other metadata

## Multi-Ticket Requests

When the scope exceeds ~3 business days of developer effort:
1. Break work into logical tickets, each ~3 days of effort
2. Present each ticket with the full mandatory structure
3. Separate tickets with a horizontal rule (`---`)
4. Order tickets by logical dependency or implementation sequence
5. Note cross-ticket dependencies in Tech Notes

## Output Rules

- Output ONLY the formatted ticket description(s)
- Do NOT wrap the entire output in a code block
- Do NOT add commentary about the ticket before or after
- The output must be immediately pasteable into Jira's description field