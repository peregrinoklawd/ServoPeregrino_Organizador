# RPT analysis — Weapons 0.6-F R5

The R5 manual behavior was reported as correct.

Automated result in the supplied RPT:
- 592 PASS
- 2 FAIL
- 594 total

The two FAILs are stale test contracts, not evidence of the observed manual flows failing:

1. The pending-draft accessory gate still works, but the R5 player-friendly hotfix changed the internal result code from `WEAPONS_UI_NEW_DRAFT_REQUIRES_WEAPON` to `WEAPONS_UI_DRAFT_BASE_WEAPON_REQUIRED`. R6 aligns the assertion with the new contract.

2. The `SALVAR COMO NOVO` isolation assertion still hard-coded `arifle_MXC_F` as the source weapon. Earlier in the same R5 test, the source is deliberately changed and saved as a P07 to validate cross-slot authoring. R6 verifies source immutability by comparing the saved source snapshot before and after `SALVAR COMO NOVO`, including target slot, instead of hard-coding an obsolete weapon class.

The repeated CBA `addPerFrameHandler` parameter errors are not referenced anywhere in this mission source. Their RPT adjacency to SP_ORG initialization is not enough to establish causality. No SP_ORG change is made for those errors in R6.
