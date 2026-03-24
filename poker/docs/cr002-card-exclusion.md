Angel Largay's footnote explicitly states that card reuse across holdings should be **ignored for the drill**. However, v3 still contains card-exclusion logic in three distinct sections. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/10574477/c166d3dc-dbb4-4388-b514-e63b5dfe22f7/texas-hold-em_page2.jpg)

### Incorrect passages found in v3 of "poker sharp" specifications

**Section 4.3.2 — Mode A (Two-Step Picker):**
> *"Ranks already exhausted (all 4 suits on board or in holdings) are grayed out and disabled"*
> *"Suits already used for that rank on board or in holdings are grayed out and disabled"*

The board-card exclusion is correct — those cards are physically on the table. But disabling ranks/suits because they appear **in a user's holdings** is wrong. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/10574477/87d5057f-8b86-40af-8c96-48e3fc21f783/poker-sharp-specification-v3.md?AWSAccessKeyId=ASIA2F3EMEYE5BC6ADLF&Signature=A9PyaG5WRDD5pmaEOaxWlbROxeE%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEMf%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJGMEQCIG6VQdb%2FyBgTAATV7BNN3JDbX9bCL5Q8x2UV1DJByHXRAiBB%2FL5lk72oFPaciRq9lnbN5FrqG31WkiyeAMw23TxKcSr8BAiQ%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAEaDDY5OTc1MzMwOTcwNSIMglqkbxCBn60XyoXDKtAEnSbok3QkfQP%2FeIm4QXEr7r3Ec7txCGCkV1EpFCLEo4PIebcKF%2B1FCazWtzSXmfyhl4ZLjrdOhQRcr6nD6zQfijjqTmwDZ9JCGfkL5jt7F85X7CZrfuCdpncZv8WKFSs7uX3wTkzxYCUzEcv9AL93nfCamw5WdRA4MAsjNugsCa%2BUuvVG1EZE4VQKhc9GrO50INwOVq5p4qaG3JVWuqogYyB%2FmUw3WgwpPh%2FbEAE8Pcra4LcTFRpfCov3z%2B4lOzhxtrj%2FLzqwpU3tCvK6ZUY0fZfOImLv13PusVgf6nk5pXKSuX7zGJxlR0EiGX8VMzubFzpz4xUXhEMEz%2BusHcIZbXT1fB5shMe0iI5iwwUacAsEimIYsJqqMr6OI3rMBYdM1oovFT16gvng9vllVup3uGQk%2F1PDxRNcXzu4wcpgEbD0zn44dmWR1X1gICcZWzn6AWdm2qrRBRFl%2FIVi2ViQY44UUJvz2kLsd2OHtxWyL1dlwn%2BOKZy84tJWJTohjc9KlogxPG1DzKbkc%2F%2BRCqEDL3NYgUka%2Bq95YEzMrRZmVujr6tHTukF2MW2bykYJ61ZFt6jDcL1W%2BWEhIcSU7NlRrmj37eq2%2B5FD2XX22k4Xq6DT6RENf6UIRvdaNTcLY7pngPYB%2FAuuWfgHDP6zn4FzC%2BozOmAeba8W8ZLeBxkYAWXG%2BvZLNhjjbdIVFBpDKEUpcfREdknt4IS2FRJiUf4aVIChHot5XWzejOGNXaV5OjYRefcT5owS6RAXkV4Sq1eJwc4uHwDC2DF7OXvZZxAnpTCb3IjOBjqZAXSpQUJruLB0G9LmDP4GPMNR0oguG9Oz5nbdEVc7CebLeni3ijzOYtuP8eN559vM%2BgyysuA%2F6P8MJENuHXrWMGKs2ZIJqRLoWPDErl9M2uPRNBHsTdo67WidjRn1sQyoClJrey1uaTUYGnls6DJ5OUoXNAk9RLOe9blxSFFybo1C%2BtfOa7Kqy44E1RPASyaUfNmXD8OlG8z8fQ%3D%3D&Expires=1774334211)

**Section 4.3.2 — Mode B (Full Grid):**
> *"Cards already selected in holdings are dimmed (40% opacity) with a small badge showing rank number"*

Dimming cards from holdings implies they are consumed and visually unavailable, which contradicts the author's intent. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/10574477/87d5057f-8b86-40af-8c96-48e3fc21f783/poker-sharp-specification-v3.md?AWSAccessKeyId=ASIA2F3EMEYE5BC6ADLF&Signature=A9PyaG5WRDD5pmaEOaxWlbROxeE%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEMf%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJGMEQCIG6VQdb%2FyBgTAATV7BNN3JDbX9bCL5Q8x2UV1DJByHXRAiBB%2FL5lk72oFPaciRq9lnbN5FrqG31WkiyeAMw23TxKcSr8BAiQ%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAEaDDY5OTc1MzMwOTcwNSIMglqkbxCBn60XyoXDKtAEnSbok3QkfQP%2FeIm4QXEr7r3Ec7txCGCkV1EpFCLEo4PIebcKF%2B1FCazWtzSXmfyhl4ZLjrdOhQRcr6nD6zQfijjqTmwDZ9JCGfkL5jt7F85X7CZrfuCdpncZv8WKFSs7uX3wTkzxYCUzEcv9AL93nfCamw5WdRA4MAsjNugsCa%2BUuvVG1EZE4VQKhc9GrO50INwOVq5p4qaG3JVWuqogYyB%2FmUw3WgwpPh%2FbEAE8Pcra4LcTFRpfCov3z%2B4lOzhxtrj%2FLzqwpU3tCvK6ZUY0fZfOImLv13PusVgf6nk5pXKSuX7zGJxlR0EiGX8VMzubFzpz4xUXhEMEz%2BusHcIZbXT1fB5shMe0iI5iwwUacAsEimIYsJqqMr6OI3rMBYdM1oovFT16gvng9vllVup3uGQk%2F1PDxRNcXzu4wcpgEbD0zn44dmWR1X1gICcZWzn6AWdm2qrRBRFl%2FIVi2ViQY44UUJvz2kLsd2OHtxWyL1dlwn%2BOKZy84tJWJTohjc9KlogxPG1DzKbkc%2F%2BRCqEDL3NYgUka%2Bq95YEzMrRZmVujr6tHTukF2MW2bykYJ61ZFt6jDcL1W%2BWEhIcSU7NlRrmj37eq2%2B5FD2XX22k4Xq6DT6RENf6UIRvdaNTcLY7pngPYB%2FAuuWfgHDP6zn4FzC%2BozOmAeba8W8ZLeBxkYAWXG%2BvZLNhjjbdIVFBpDKEUpcfREdknt4IS2FRJiUf4aVIChHot5XWzejOGNXaV5OjYRefcT5owS6RAXkV4Sq1eJwc4uHwDC2DF7OXvZZxAnpTCb3IjOBjqZAXSpQUJruLB0G9LmDP4GPMNR0oguG9Oz5nbdEVc7CebLeni3ijzOYtuP8eN559vM%2BgyysuA%2F6P8MJENuHXrWMGKs2ZIJqRLoWPDErl9M2uPRNBHsTdo67WidjRn1sQyoClJrey1uaTUYGnls6DJ5OUoXNAk9RLOe9blxSFFybo1C%2BtfOa7Kqy44E1RPASyaUfNmXD8OlG8z8fQ%3D%3D&Expires=1774334211)

**Section 4.3.3 — Selected Holdings List:**
> *"Tapping it removes the holding, returns its two cards to the available pool in the picker, and renumbers the list."*

Returning cards to a pool implies they were taken from one — the pool concept itself is wrong. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/10574477/87d5057f-8b86-40af-8c96-48e3fc21f783/poker-sharp-specification-v3.md?AWSAccessKeyId=ASIA2F3EMEYE5BC6ADLF&Signature=A9PyaG5WRDD5pmaEOaxWlbROxeE%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEMf%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJGMEQCIG6VQdb%2FyBgTAATV7BNN3JDbX9bCL5Q8x2UV1DJByHXRAiBB%2FL5lk72oFPaciRq9lnbN5FrqG31WkiyeAMw23TxKcSr8BAiQ%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAEaDDY5OTc1MzMwOTcwNSIMglqkbxCBn60XyoXDKtAEnSbok3QkfQP%2FeIm4QXEr7r3Ec7txCGCkV1EpFCLEo4PIebcKF%2B1FCazWtzSXmfyhl4ZLjrdOhQRcr6nD6zQfijjqTmwDZ9JCGfkL5jt7F85X7CZrfuCdpncZv8WKFSs7uX3wTkzxYCUzEcv9AL93nfCamw5WdRA4MAsjNugsCa%2BUuvVG1EZE4VQKhc9GrO50INwOVq5p4qaG3JVWuqogYyB%2FmUw3WgwpPh%2FbEAE8Pcra4LcTFRpfCov3z%2B4lOzhxtrj%2FLzqwpU3tCvK6ZUY0fZfOImLv13PusVgf6nk5pXKSuX7zGJxlR0EiGX8VMzubFzpz4xUXhEMEz%2BusHcIZbXT1fB5shMe0iI5iwwUacAsEimIYsJqqMr6OI3rMBYdM1oovFT16gvng9vllVup3uGQk%2F1PDxRNcXzu4wcpgEbD0zn44dmWR1X1gICcZWzn6AWdm2qrRBRFl%2FIVi2ViQY44UUJvz2kLsd2OHtxWyL1dlwn%2BOKZy84tJWJTohjc9KlogxPG1DzKbkc%2F%2BRCqEDL3NYgUka%2Bq95YEzMrRZmVujr6tHTukF2MW2bykYJ61ZFt6jDcL1W%2BWEhIcSU7NlRrmj37eq2%2B5FD2XX22k4Xq6DT6RENf6UIRvdaNTcLY7pngPYB%2FAuuWfgHDP6zn4FzC%2BozOmAeba8W8ZLeBxkYAWXG%2BvZLNhjjbdIVFBpDKEUpcfREdknt4IS2FRJiUf4aVIChHot5XWzejOGNXaV5OjYRefcT5owS6RAXkV4Sq1eJwc4uHwDC2DF7OXvZZxAnpTCb3IjOBjqZAXSpQUJruLB0G9LmDP4GPMNR0oguG9Oz5nbdEVc7CebLeni3ijzOYtuP8eN559vM%2BgyysuA%2F6P8MJENuHXrWMGKs2ZIJqRLoWPDErl9M2uPRNBHsTdo67WidjRn1sQyoClJrey1uaTUYGnls6DJ5OUoXNAk9RLOe9blxSFFybo1C%2BtfOa7Kqy44E1RPASyaUfNmXD8OlG8z8fQ%3D%3D&Expires=1774334211)

**Section 8.4 — Error Handling / Edge Cases:**
> *"Duplicate-class blocking…This replaces simple duplicate-card prevention — the constraint operates at the class level, not the individual card level."*

This sentence acknowledges that the old logic prevented duplicate cards. The CR-001 fix correctly moved the constraint to class level, but the wording still implies individual card prevention was the prior norm. This needs clarification that **no card-level prevention exists at all**. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/10574477/87d5057f-8b86-40af-8c96-48e3fc21f783/poker-sharp-specification-v3.md?AWSAccessKeyId=ASIA2F3EMEYE5BC6ADLF&Signature=A9PyaG5WRDD5pmaEOaxWlbROxeE%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEMf%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJGMEQCIG6VQdb%2FyBgTAATV7BNN3JDbX9bCL5Q8x2UV1DJByHXRAiBB%2FL5lk72oFPaciRq9lnbN5FrqG31WkiyeAMw23TxKcSr8BAiQ%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAEaDDY5OTc1MzMwOTcwNSIMglqkbxCBn60XyoXDKtAEnSbok3QkfQP%2FeIm4QXEr7r3Ec7txCGCkV1EpFCLEo4PIebcKF%2B1FCazWtzSXmfyhl4ZLjrdOhQRcr6nD6zQfijjqTmwDZ9JCGfkL5jt7F85X7CZrfuCdpncZv8WKFSs7uX3wTkzxYCUzEcv9AL93nfCamw5WdRA4MAsjNugsCa%2BUuvVG1EZE4VQKhc9GrO50INwOVq5p4qaG3JVWuqogYyB%2FmUw3WgwpPh%2FbEAE8Pcra4LcTFRpfCov3z%2B4lOzhxtrj%2FLzqwpU3tCvK6ZUY0fZfOImLv13PusVgf6nk5pXKSuX7zGJxlR0EiGX8VMzubFzpz4xUXhEMEz%2BusHcIZbXT1fB5shMe0iI5iwwUacAsEimIYsJqqMr6OI3rMBYdM1oovFT16gvng9vllVup3uGQk%2F1PDxRNcXzu4wcpgEbD0zn44dmWR1X1gICcZWzn6AWdm2qrRBRFl%2FIVi2ViQY44UUJvz2kLsd2OHtxWyL1dlwn%2BOKZy84tJWJTohjc9KlogxPG1DzKbkc%2F%2BRCqEDL3NYgUka%2Bq95YEzMrRZmVujr6tHTukF2MW2bykYJ61ZFt6jDcL1W%2BWEhIcSU7NlRrmj37eq2%2B5FD2XX22k4Xq6DT6RENf6UIRvdaNTcLY7pngPYB%2FAuuWfgHDP6zn4FzC%2BozOmAeba8W8ZLeBxkYAWXG%2BvZLNhjjbdIVFBpDKEUpcfREdknt4IS2FRJiUf4aVIChHot5XWzejOGNXaV5OjYRefcT5owS6RAXkV4Sq1eJwc4uHwDC2DF7OXvZZxAnpTCb3IjOBjqZAXSpQUJruLB0G9LmDP4GPMNR0oguG9Oz5nbdEVc7CebLeni3ijzOYtuP8eN559vM%2BgyysuA%2F6P8MJENuHXrWMGKs2ZIJqRLoWPDErl9M2uPRNBHsTdo67WidjRn1sQyoClJrey1uaTUYGnls6DJ5OUoXNAk9RLOe9blxSFFybo1C%2BtfOa7Kqy44E1RPASyaUfNmXD8OlG8z8fQ%3D%3D&Expires=1774334211)

***

## CR-002: Remove Card Exclusion From Holdings; Retain Board-Card Exclusion Only

**Priority:** High — affects core gameplay interaction and fidelity to source material
**Version targeting:** v3.0
**Affected sections:** 4.3.2 (both modes), 4.3.3, 8.4
**Rationale:** Per Angel Largay's explicit footnote in *No-Limit Texas Hold'em: A Complete Course*, card availability conflicts between holdings are intentionally ignored in the drill. The exercise trains board-texture recognition, not combinatorial card counting. A card such as T♦ may and should appear in both the #1 holding (J♦T♦) and the #2 holding (T♦6♦) simultaneously. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/10574477/c166d3dc-dbb4-4388-b514-e63b5dfe22f7/texas-hold-em_page2.jpg)

***

### Change 1 — Section 4.3.2, Mode A (Two-Step Picker)

**Step 1 Rank Selection — Remove:**
> *"Ranks already exhausted (all 4 suits on board or in holdings) are grayed out and disabled"*

**Replace with:**
> Ranks are grayed out and disabled only when **all 4 suits of that rank appear among the 5 board cards** (i.e., none remain in the deck at all). Ranks used in existing holdings remain fully available.

**Step 2 Suit Selection — Remove:**
> *"Suits already used for that rank on board or in holdings are grayed out and disabled"*

**Replace with:**
> Suits are grayed out and disabled only when that specific card appears **on the board**. Suits used in existing holdings remain available for selection in new holdings.

***

### Change 2 — Section 4.3.2, Mode B (Full Grid)

**Remove:**
> *"Cards already selected in holdings are dimmed (40% opacity) with a small badge showing rank number"*

**Replace with:**
> Cards that appear on the board are shown as empty slots or grayed placeholders and are not selectable. All other 47 cards are displayed at full opacity and remain selectable regardless of whether they have been used in previously built holdings. There is no dimming or badging of cards based on holdings.

**Also update the wireframe note in Appendix C** which reads:
> `[ ] = on board hidden/grayed` ← keep
> `[◉] = card selected as part of a holding (dimmed + badge)` ← **remove entirely**

***

### Change 3 — Section 4.3.3 (Selected Holdings List)

**Remove from Editing subsection:**
> *"Tapping it removes the holding, returns its two cards to the available pool in the picker, and renumbers the list."*

**Replace with:**
> Tapping the Remove button deletes the holding from the list and renumbers the remaining entries. No change is made to card availability in the picker, since cards are never consumed by holdings.

***

### Change 4 — Section 8.4 (Error Handling / Edge Cases)

**Remove from Duplicate-class blocking bullet:**
> *"This replaces simple duplicate-card prevention — the constraint operates at the class level, not the individual card level."*

**Replace with:**
> Duplicate-class blocking operates at the equivalence class level only. There is no card-level prevention — the same card may appear in multiple holdings. The only card-level constraint is board-card exclusion: the 5 community cards cannot be selected as hole cards.

***

### Change 5 — Add clarifying note to Section 2.1 (The Drill)

**In step 2**, after *"The user selects and ranks two-card holdings from the remaining 47 cards"*, add:

> **Note:** The same card may appear in more than one holding. Card availability constraints apply only to the 5 board cards, which cannot be selected as hole cards. This follows the drill design described in the source material, where inter-holding card conflicts are intentionally ignored.

***

### No Change Required

- **Section 2.3 (Equivalence Grouping):** Duplicate-class blocking (preventing the same *equivalence class* from being ranked twice) remains correct and is unaffected by this CR. Blocking a class is not the same as blocking a card.
- **Section 5.1 (Correct Ranking Generation):** Already evaluates all 1,081 holdings independently with no mutual exclusion. No change needed.
- **Section 8.2 (Hand Evaluator Performance):** No change needed.
- **Appendix B (Test Cases):** No change needed — test cases already show T♦ appearing in both J♦T♦ (#1) and T♦6♦ (#2) on the example board. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/10574477/87d5057f-8b86-40af-8c96-48e3fc21f783/poker-sharp-specification-v3.md?AWSAccessKeyId=ASIA2F3EMEYE5BC6ADLF&Signature=A9PyaG5WRDD5pmaEOaxWlbROxeE%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEMf%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJGMEQCIG6VQdb%2FyBgTAATV7BNN3JDbX9bCL5Q8x2UV1DJByHXRAiBB%2FL5lk72oFPaciRq9lnbN5FrqG31WkiyeAMw23TxKcSr8BAiQ%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAEaDDY5OTc1MzMwOTcwNSIMglqkbxCBn60XyoXDKtAEnSbok3QkfQP%2FeIm4QXEr7r3Ec7txCGCkV1EpFCLEo4PIebcKF%2B1FCazWtzSXmfyhl4ZLjrdOhQRcr6nD6zQfijjqTmwDZ9JCGfkL5jt7F85X7CZrfuCdpncZv8WKFSs7uX3wTkzxYCUzEcv9AL93nfCamw5WdRA4MAsjNugsCa%2BUuvVG1EZE4VQKhc9GrO50INwOVq5p4qaG3JVWuqogYyB%2FmUw3WgwpPh%2FbEAE8Pcra4LcTFRpfCov3z%2B4lOzhxtrj%2FLzqwpU3tCvK6ZUY0fZfOImLv13PusVgf6nk5pXKSuX7zGJxlR0EiGX8VMzubFzpz4xUXhEMEz%2BusHcIZbXT1fB5shMe0iI5iwwUacAsEimIYsJqqMr6OI3rMBYdM1oovFT16gvng9vllVup3uGQk%2F1PDxRNcXzu4wcpgEbD0zn44dmWR1X1gICcZWzn6AWdm2qrRBRFl%2FIVi2ViQY44UUJvz2kLsd2OHtxWyL1dlwn%2BOKZy84tJWJTohjc9KlogxPG1DzKbkc%2F%2BRCqEDL3NYgUka%2Bq95YEzMrRZmVujr6tHTukF2MW2bykYJ61ZFt6jDcL1W%2BWEhIcSU7NlRrmj37eq2%2B5FD2XX22k4Xq6DT6RENf6UIRvdaNTcLY7pngPYB%2FAuuWfgHDP6zn4FzC%2BozOmAeba8W8ZLeBxkYAWXG%2BvZLNhjjbdIVFBpDKEUpcfREdknt4IS2FRJiUf4aVIChHot5XWzejOGNXaV5OjYRefcT5owS6RAXkV4Sq1eJwc4uHwDC2DF7OXvZZxAnpTCb3IjOBjqZAXSpQUJruLB0G9LmDP4GPMNR0oguG9Oz5nbdEVc7CebLeni3ijzOYtuP8eN559vM%2BgyysuA%2F6P8MJENuHXrWMGKs2ZIJqRLoWPDErl9M2uPRNBHsTdo67WidjRn1sQyoClJrey1uaTUYGnls6DJ5OUoXNAk9RLOe9blxSFFybo1C%2BtfOa7Kqy44E1RPASyaUfNmXD8OlG8z8fQ%3D%3D&Expires=1774334211)

***

### Summary Table

| Location | What changes | Direction |
|---|---|---|
| §4.3.2 Mode A — Step 1 | Rank disabling rule | Remove holdings from exclusion logic |
| §4.3.2 Mode A — Step 2 | Suit disabling rule | Remove holdings from exclusion logic |
| §4.3.2 Mode B — Grid | Card dimming/badging | Remove holdings-based dimming entirely |
| §4.3.2 Mode B — Appendix C wireframe | `[◉]` legend entry | Remove |
| §4.3.3 — Remove button | "Returns cards to pool" phrase | Remove pool concept |
| §8.4 — Duplicate-class blocking | Cross-reference to old card prevention | Clarify no card-level constraint exists |
| §2.1 — The Drill, step 2 | Card availability statement | Add explicit note permitting card reuse |
