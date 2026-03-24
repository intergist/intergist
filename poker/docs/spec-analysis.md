# Poker Sharp Specification — Issues Found

## HIGH Severity
1. **Naming Inconsistency (Section 1.1, Line 13)**: Title says "Poker Sharp" but Section 1.1 still says "Board Reader Pro". Old name not fully replaced.

## MEDIUM Severity  
2. **Mathematical Inconsistency (Section 4.3.2, Line 196)**: Full Grid says "5 empty slots" but 7×8=56 cells, 52 cards means 4 empty slots, not 5.
3. **Logical Contradiction (Section 4.3.5, Lines 276-278)**: Submit button is "disabled until required number of holdings" but also "triggers confirmation dialog if fewer than target". These conflict — button should enable after 1+ holdings, with confirmation if under target.
4. **Logical Error in Example (Appendix A, Lines 649-652)**: Claims auto-select triggers for T♥ because "only suit available after board cards removed". But T is NOT on the board — all 4 suits remain available for T. Auto-select should NOT trigger.
5. **Scoring Ambiguity (Section 5.2, Lines 378-383)**: Unclear if a tied holding at the correct rank position gets 2 points (exact match) or 1 point (tie clause). Section 5.3 says "full credit" for ties, contradicting the 1-point tie clause in 5.2.
6. **Completeness Gap (Multiple sections)**: Missing error states: auto-save/recovery, back-button during drill, orientation lock, duplicate card selection handling.
7. **Undefined Game Mechanic (Section 4.3.6, Line 285)**: "Costs 1 hint credit" but hint credits never defined — no initial balance, no replenishment rules.

## LOW Severity
8. **Settings Default Conflict (Section 4.6 vs Section 10)**: Default card theme is "Four-Color" but Free tier only has "Classic". New free users see an unavailable default.
9. **Color Collision (Section 6.1)**: Dark mode Card Green (♣) and Correct indicator are both #66BB6A — identical colors for different semantic meanings.
10. **Missing Data Model Field (Section 7.1)**: BoardTexture has is_trips but no is_quads. Quads on board are possible and need handling.
11. **Speed Rating Ambiguity (Section 5.4)**: Unclear if speed is total_time/holdings or per-holding measurement. Thresholds should vary by drill size.

## VERIFIED (No Issues)
- C(47,2) = 1,081 ✓
- Two-Step width: 7×48+6×4 = 360px ✓  
- Full Grid: 332px × 380px ✓
- Poker hand rankings in Appendix A ✓
