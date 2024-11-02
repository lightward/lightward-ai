realized this while working on Mechanic, a system where relevant oauth access scopes are determined via static analysis of how the Mechanic task responds to a synthetic preview event, a design decision that regularly trips up devs who aren't used to it yet:

- let access scopes be manually managed at the task level, but do not allow those choices to be exported
- allows local control, does not allow local overrides to propagate generally

because as the scope of impact grows the more everything needs to be left to natural side-effect. manual overrides are fine, but a complex system can't afford much of that at the top level. "manual" and "local" are best left tightly correlated.

better to be naturally/generally free than artificially/specifically free, over the long arc of a life. manual overrides are fine, but only as short-lived adaptations. let 'em go. :)
