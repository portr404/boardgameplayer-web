# BoardGamePlayer Functional Specification v1.3

> AI-oriented source of truth for implementation in Visual Studio Code. Do not implement out-of-scope items unless explicitly requested.

## Product
Flutter shared codebase for Web, Android, and iOS. Local-first board-game session manager with persistent sessions, players, timers, turns, scores, thumbnails, player order, first-player randomizer, and polyhedral dice roller.

## Navigation
```text
GameSessionsPage
  -> GameSessionDetailPage
       bottom-left: Pick first player
       bottom-center: Dice menu
       bottom-right: Add player
```

## Domain model
```dart
class GameSession {
  String id;
  String name;
  List<Player> players;
  String? selectedFirstPlayerId;
  DateTime createdAt;
  DateTime updatedAt;
}

class Player {
  String id;
  String sessionId;
  String name;
  String thumbnailId;
  int sortOrder;
  int elapsedSeconds;
  TimerState timerState;
  int turns; // 0..99
  double score;
  double scoreStep; // 0.5, 1, 5, 10, 50
}

enum DieType { d4, d6, d8, d10, d12, d20, d100 }
class DiceRoll { DieType dieType; int result; DateTime rolledAt; }
```

## Persistence invariants
- Sort players by `sortOrder` on load.
- `sortOrder` values are unique and normalized to `0..n-1` after insert/delete/reorder.
- New player is appended at the end.
- Persist reorder immediately.
- `selectedFirstPlayerId` is null or references a player in the same session.
- Deleting the selected first player clears `selectedFirstPlayerId`.
- Dice result does not modify player statistics.

## Player reordering
### Requirements
- Reorder the whole player card using drag-and-drop.
- Desktop/Web: mouse drag plus keyboard alternatives.
- Touch: long press or visible drag handle.
- Show lifted-card feedback and destination placeholder.
- Provide semantic `Move up` and `Move down` actions.
- Keep focus on the moved player.
- Announce the new position to assistive technology.
- Reordering must not stop active timers.

### Repository operation
```dart
Future<void> reorderPlayers(String sessionId, List<String> orderedPlayerIds);
```
The repository must validate membership, normalize positions, and persist atomically.

## First-player randomizer
### UI
- Bottom-left button with first-player semantic label.
- Disabled when player list is empty.
- Enabled with one or more players.
- Selected player shows a bold red `1st` badge next to the name.
- Highlight selected player card using border/surface/icon, not red alone.

### Behavior
```dart
Player pickFirstPlayer(List<Player> players, RandomSource random)
```
- Choose a uniform random index in `[0, players.length - 1]`.
- With one player, select that player.
- Repeated presses perform a new independent draw.
- The same player may be selected again.
- Do not reorder players.
- Remove previous selection before showing the new one.
- Scroll/focus the selected card into view.
- Persist `selectedFirstPlayerId`.
- Reduced motion: skip cycling animation and reveal immediately.

## Dice roller
### Supported dice
`d4`, `d6`, `d8`, `d10`, `d12`, `d20`, `d100`.

### UI
- Bottom-center button opens an adaptive selector.
- Mobile: modal bottom sheet.
- Desktop/Web: anchored popover or dialog.
- Each option displays die silhouette/icon plus text label.
- Keyboard, touch, mouse, Escape, screen reader supported.

### Random result
```dart
int rollDie(DieType type, RandomSource random) {
  final sides = type.sides;
  return random.nextInt(sides) + 1;
}
```
- Result is a uniform integer from `1` to `sides` inclusive.
- Calculate result once before animation reveal.
- Prevent concurrent rolls/double taps while rolling.
- Provide `Roll again` and `Change die`.
- Operates offline.

### Animation state machine
```text
idle -> anticipation -> rolling -> settling -> revealed -> idle/reroll
```
- Anticipation: press response, scale and shadow.
- Rolling: rotation/shake and rapidly changing placeholder values.
- Settling: deceleration and small bounce.
- Reveal: stable result, die label, subtle gold glow.
- Optional restrained critical feedback for minimum/maximum.
- d100 may use a percentile representation or stylized polyhedron; final result must be one integer 1..100.
- Allow 2D fallback on less capable devices.
- Do not rely on browser-unsupported APIs.
- Reduced motion: short fade and immediate result.
- Sound/haptics optional and disableable; never required to understand the result.

## Bottom action layout
- Left: first-player randomizer.
- Center: dice menu.
- Right: add player.
- Respect safe areas.
- On narrow screens use an adaptive bottom app bar.
- Minimum interactive target approximately 48 logical pixels where appropriate.
- Add tooltip and semantic label to every icon.

## Design tokens
```yaml
colors:
  dungeonInk: '#222633'
  deepNavy: '#1F3757'
  parchment: '#F6F3EC'
  antiqueGold: '#B7863B'
  emerald: '#2E8B57'
  amber: '#D99A24'
  crimson: '#B23A48'
  firstPlayerBadge: '#C62828'
motion:
  fastMs: 120
  standardMs: 220
  slowMs: 320
```
Do not hardcode animation duration in domain logic. Respect system reduced-motion preference.

## Suggested files
```text
lib/features/game_detail/
  presentation/widgets/
    player_reorder_handle.dart
    first_player_button.dart
    first_player_badge.dart
    dice_menu_button.dart
    dice_selector.dart
    dice_roll_overlay.dart
  application/
    reorder_players_controller.dart
    first_player_controller.dart
    dice_roller_controller.dart
  domain/
    die_type.dart
    dice_roll.dart
    random_source.dart
```

## Test specification
### Unit
- Normalize order after reorder/delete/insert.
- Reject cross-session player IDs.
- Random first player always belongs to the input list.
- One-player selection always returns the only player.
- Die result boundaries for all die types using deterministic random source.
- Deleting selected player clears selection.

### Widget
- First-player button disabled with zero players.
- `1st` badge and card highlight appear on exactly one player.
- Repeated selection replaces previous highlight.
- Dice selector exposes all seven types.
- Double tap cannot create concurrent rolls.
- Move up/down disabled at list boundaries.
- Focus remains on reordered item.
- Reduced-motion path does not run rotation-heavy animation.

### Integration
- Create session -> add players -> reorder -> pick first -> roll each die -> close -> reopen.
- Verify persisted order, selection, statistics, and thumbnails.
- Verify active timer survives UI reorder without duplication/reset.
- Verify Web keyboard flow, Android back, and iOS back gesture.

### Responsive/accessibility
- Phone: no horizontal scroll; bottom bar respects safe area.
- Tablet/desktop: controls remain aligned and reachable.
- Light/dark themes preserve contrast.
- VoiceOver/TalkBack announce disabled state, selected first player, die type, and result.

## Acceptance checklist
- [ ] Player order can be changed and survives restart.
- [ ] Reorder is possible without drag-and-drop.
- [ ] First-player button is disabled with zero players.
- [ ] Exactly one player has `1st` after selection.
- [ ] Repeated selections are independent and may repeat a player.
- [ ] Dice menu includes d4,d6,d8,d10,d12,d20,d100.
- [ ] Every roll is within inclusive die bounds.
- [ ] Animation does not determine or mutate the result.
- [ ] Reduced-motion and screen readers are supported.
- [ ] Existing timers, turns, scores, persistence, and thumbnails still work.

## Out of scope
- Persistent dice history.
- Multiple dice pools/modifiers.
- Cloud-synchronized rolls.
- Automatic score changes from dice.
- Excluding the previous first player from the next draw.
