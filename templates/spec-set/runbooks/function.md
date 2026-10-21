# Runbook — [function]

*Spec-set skeleton for `runbooks/<function>.md`. One runbook per function with a P1 alert. Six sections, in this order.*

**Alert:** [name] · **Owner:** [team] · **Last exercised:** YYYY-MM-DD

## 1. What the customer sees

[The symptom in the customer's words.]

## 2. First five minutes

1. [Open the function-detail dashboard: is it one class of error or all?]
2. [Is a dependency down? Check its status tile.]
3. [Declare or not: criteria.]

## 3. Mitigate

[Steps that reduce customer impact without a fix: failover, feature flag, queue.]

## 4. Risky switches

[Actions that can make it worse, and who may approve them.]

## 5. Customers left in an unknown state

[How to find attempts with an unknown outcome and reconcile them (refund, retry, contact).]

## 6. Close

[When to resolve; what goes into the firing review; follow-ups with owners.]
