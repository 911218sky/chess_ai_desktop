## Observations
- `flutter test` fails in `test/widgets/control_panel_test.dart` with a `RenderFlex overflowed by 32 pixels on the bottom`.
- The overflow points to `lib/src/widgets/control_panel.dart:871`, inside `_FooterSelect`.
- The failing widget is rendered in multiple control-panel tests, so the same footer layout is the shared trigger.
- The footer card has a fixed height of `58`, while its label/value column can wrap on narrow widths.

## Hypotheses

### H1: The footer label/value text is wrapping to multiple lines in the fixed-height footer (ROOT HYPOTHESIS)
- Supports: the overflow is in `_FooterSelect`, and the footer is reused across all failing tests.
- Conflicts: none yet.
- Test: force both text fields to stay on one line and rerun `flutter test`.

### H2: The footer container height is too small for the current typography
- Supports: the footer height is hard-coded.
- Conflicts: the content should fit if it stays single-line.
- Test: increase the footer height slightly and see whether the overflow disappears.

### H3: The title/value column is vertically centered in a way that amplifies the overflow
- Supports: the column is centered inside a tight row.
- Conflicts: centering alone should not create a 32px overflow.
- Test: switch the column to a tighter layout and rerun the widget tests.

## Experiments
- Applied the single-line text constraint to `_FooterSelect` label/value fields.
- Result: `flutter test test/widgets/control_panel_test.dart` passed.

## Root Cause
- `_FooterSelect` allowed the footer value text to wrap inside a fixed-height footer, which overflowed under the test panel width.

## Fix
- Constrain both footer label and value text to one line with ellipsis.
