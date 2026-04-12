---
name: codex-merch-drop
description: >-
  Plan and execute a limited Codex merch drop with scarcity rules, launch assets,
  and post-drop analysis. Use when preparing a merch release, capsule launch,
  waitlist rollout, or sell-through recap.
user-invocable: false
argument-hint: [drop-name]
---

## Quick Start

Input:
- Drop name + launch date/time (timezone)
- Inventory by SKU/size
- Channels: site, email, social
- Constraints: legal copy, shipping regions, payment issues

Output:
1. One-page drop brief
2. Launch timeline (T-14 to T+2)
3. SKU + allocation table
4. Channel copy pack
5. Incident runbook + fallback comms
6. Post-drop recap template

## Workflow

1. Define scarcity model.
   - Hard cap: fixed units, no restock.
   - Soft cap: fixed first run + waitlist.
   - Rules: per-customer limits, geo constraints, anti-bot gates.
2. Build drop brief.
   - Theme, product list, target audience, price bands, success metrics.
3. Plan launch operations.
   - Web readiness, checkout/load test, inventory sync, support staffing.
4. Produce messaging.
   - Hero copy, product bullets, SMS/email/social variants, FAQ.
5. Prepare failure modes.
   - Oversell, payment outage, shipping delay, auth/captcha lockouts.
6. Close with recap.
   - Sell-through by SKU, conversion funnel, refund rate, lessons.

## Guardrails

- Never claim "last chance" unless inventory is actually fixed.
- Avoid artificial scarcity if replenishment is planned.
- Keep timezone explicit in every launch artifact.
- Keep legal terms consistent across site/email/social.
- Publish support path before launch goes live.

## Deliverable Templates

Use:
- [Drop Checklist](references/DROP_CHECKLIST.md)

## Done Criteria

- All launch artifacts approved and timestamped.
- Inventory and customer-limit checks validated in staging.
- Runbook owner assigned for launch window.
- T+1 recap slot booked with data owner.
