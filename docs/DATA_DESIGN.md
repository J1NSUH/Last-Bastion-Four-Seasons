# Data Design

이 문서는 **Last Bastion: Four Seasons**의 기획을 데이터로 옮기기 위한 기준입니다.

목표는 카드, 적, 웨이브, 아티팩트, 보스, 상점이 같은 규칙으로 관리되게 만드는 것입니다.

## 데이터 설계 원칙

- 모든 콘텐츠는 고유 ID를 가집니다.
- 표시 이름과 내부 ID를 분리합니다.
- 수치와 설명을 분리합니다.
- 키워드는 문자열 설명이 아니라 태그로 관리합니다.
- 웨이브 겹치기 보상 증가는 데이터로도 만들 수 없게 제한합니다.
- 카드와 적은 직업/계절/위험도 태그를 가집니다.
- 테스트 중 수치 변경이 쉽도록 모든 밸런스 값은 데이터화합니다.

## ID 규칙

ID는 영어 소문자와 밑줄만 사용합니다.

```text
class_guardian
card_guardian_taunt_wall
enemy_gray_march
artifact_unstable_clock
boss_silent_colossus
wave_day_010_boss
event_cracked_storehouse
```

권장 접두사:

| 분류 | 접두사 |
| --- | --- |
| 직업 | `class_` |
| 카드 | `card_` |
| 구조물 | `structure_` |
| 적 | `enemy_` |
| 웨이브 | `wave_` |
| 보스 | `boss_` |
| 보스 부위 | `boss_part_` |
| 아티팩트 | `artifact_` |
| 이벤트 | `event_` |
| 런 | `run_` |
| 스케일링 프로필 | `scaling_` |
| 상점 항목 | `shop_` |
| 키워드 | `keyword_` |
| 상태이상 | `status_` |

## 공통 필드

모든 데이터 항목은 가능한 한 아래 공통 필드를 가집니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 내부 고유 ID |
| `nameKo` | string | 한국어 표시명 |
| `descriptionKo` | string | 한국어 설명 |
| `tags` | string[] | 검색과 필터링용 태그 |
| `enabledInMvp` | boolean | MVP 포함 여부 |
| `notes` | string | 기획 메모 |

## 런 설정 데이터

런 설정 데이터는 로비에서 선택하는 값입니다.

이 값은 아직 전투 결과가 아니며, 런 시작 버튼을 누르는 순간 `RunState`로 확정됩니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `runId` | string | 런 고유 ID |
| `mode` | enum | `test_10`, `mvp_30`, `standard_100` |
| `playerSlots` | object[] | 참여 플레이어와 선택 직업 |
| `startingDay` | number | 기본 1 |
| `seed` | string/number | 웨이브와 보상 난수 시드 |
| `difficulty` | enum | MVP에서는 `normal`만 사용 |
| `setupFlowId` | string | `new_run_setup_flow` |
| `nextRunSuggestionIds` | string[] | 결과/도감/훈련장에서 넘어온 제안, 최대 2개 |
| `previewActiveDirections` | string[] | 현재 로비 인원 기준 미리보기 방향 |
| `forcedClassId` | string/null | 항상 null |
| `forcedCardIds` | string[] | 항상 빈 배열 |

`playerSlots` 예시:

```json
[
  {"playerId": "p1", "classId": "class_guardian"},
  {"playerId": "p2", "classId": "class_elementalist"}
]
```

### 새 런 준비 데이터

새 런 준비는 `new_run_setup_flow`로 구성합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `setupId` | string | 새 런 준비 흐름 ID |
| `sourceType` | enum | `main_menu`, `result`, `meta`, `knowledge_revisit`, `continue` |
| `suggestionIds` | string[] | 참고 제안, 최대 2개 |
| `playerSlots` | object[] | 현재 로비 참여자와 선택 직업 |
| `previewPlayerCount` | number | 로비 현재 인원수 |
| `previewActiveDirections` | string[] | 시작하면 열릴 방향 미리보기 |
| `selectedMode` | enum | `test_10`, `mvp_30`, `standard_100` |
| `selectedDifficulty` | enum | MVP에서는 `normal` |
| `partyIntentTextId` | string/null | 이번 런에서 시험할 운영 한 줄 |
| `readyPlayerIds` | string[] | 준비 완료 플레이어 |
| `runStateLocked` | boolean | 시작 버튼 후 true |
| `forbiddenAutoSetupTags` | string[] | 자동 빌드/강제 추천 금지 태그 |

`forbiddenAutoSetupTags`에는 `forced_class`, `forced_card`, `auto_build`, `stack_reward_mode`, `direction_recalculation_after_start`를 넣습니다.

새 런 제안은 로비 문구와 즐겨찾기만 바꿀 수 있습니다.

직업, 카드, 아티팩트, 활성 방향, 보상 확률을 자동으로 바꾸지 않습니다.

## 접근성/연출 설정 데이터

접근성과 연출 설정은 `accessibility_presentation_options`를 사용합니다.

이 데이터는 플레이어별 표시와 소리 설정이며, `RunState`나 밸런스 계산에 사용하지 않습니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `playerId` | string | 설정 소유 플레이어 |
| `accessibilityOptionsId` | string | `accessibility_presentation_options` |
| `uiScale` | number | UI 배율 |
| `cardTextSize` | enum | `normal`, `large`, `extra_large` |
| `screenShakeLevel` | enum | `off`, `low`, `normal` |
| `cameraInertiaLevel` | enum | `off`, `low`, `normal` |
| `lowFrequencyBossVolume` | number | 저주파 보스음 음량 |
| `warningVolume` | number | 경고음 음량 |
| `pingVolume` | number | 핑 소리 음량 |
| `alwaysShowPaths` | boolean | 경로선 상시 표시 |
| `enemyOutlineLevel` | enum | `normal`, `strong` |
| `bossPartHighlightLevel` | enum | `normal`, `strong` |
| `colorAssistMode` | enum | `off`, `deuteranopia`, `protanopia`, `tritanopia`, `high_contrast` |
| `directionLabelMode` | enum | `icon`, `icon_text`, `text` |
| `bossPatternCaptions` | boolean | 보스 패턴 자막 표시 |
| `pingCaptionLog` | boolean | 핑 자막 로그 표시 |

금지 필드:

- `damageMultiplier`
- `rewardMultiplier`
- `extraCardChoices`
- `rarityBonus`
- `activeDirectionOverride`
- `enemyCountModifier`

접근성 설정은 개인별로 다를 수 있습니다.

한 플레이어가 경로 상시 표시를 켜도 다른 플레이어의 화면이나 파티의 실제 경로 판정은 바뀌지 않습니다.

## 런 상태 데이터

런 상태 데이터는 런 시작 시 확정되고 저장 파일에 남는 값입니다.

인원수별 활성 침공 방향은 이 단계에서 고정합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `runId` | string | 런 고유 ID |
| `playerCountAtStart` | number | 런 시작 시 확정된 인원수 |
| `activeDirections` | string[] | 일반 웨이브가 사용할 수 있는 방향 |
| `scalingProfileId` | string | 인원수별 스케일링 프로필 ID |
| `currentDay` | number | 현재 일자 |
| `currentSeason` | enum | `spring`, `summer`, `autumn`, `winter` |
| `baseHp` | number | 현재 기지 체력 |
| `baseHealthRuleId` | string | 적용 중인 기지 체력 규칙 |
| `equippedArtifacts` | string[] | 장착 중인 아티팩트 |
| `partyGold` | number | 파티 공유 골드 |
| `bossShards` | number | 보스 파편 |
| `baseWaveStackLimit` | number | 기본 웨이브 겹치기 한도, 기본 3 |
| `currentWaveStackLimit` | number | 아티팩트 적용 후 현재 겹치기 한도 |

예시:

```json
{
  "runId": "run_2026_07_21_001",
  "playerCountAtStart": 3,
  "activeDirections": ["west", "north", "east"],
  "scalingProfileId": "scaling_players_3",
  "currentDay": 1,
  "currentSeason": "spring",
  "baseHp": 30,
  "baseHealthRuleId": "base_health_rule_mvp_001",
  "equippedArtifacts": [],
  "partyGold": 0,
  "bossShards": 0,
  "baseWaveStackLimit": 3,
  "currentWaveStackLimit": 3
}
```

런 도중 플레이어가 나가거나 재접속해도 `playerCountAtStart`, `activeDirections`, `scalingProfileId`는 바꾸지 않습니다.

현재 접속 인원은 별도 세션 상태로 관리하고, 런 밸런스 기준으로 쓰지 않습니다.

## 기지 체력 규칙 데이터

`BaseHealthRule`은 기지 최대 체력, 상태 구간, 패배 처리, 회복 경제를 한곳에서 정의합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 기지 체력 규칙 ID |
| `baseHpMax` | number | 기지 최대 체력 |
| `safeHpRange` | number[] | 안정 상태 범위 |
| `dangerHpRange` | number[] | 위험 상태 범위 |
| `criticalHpRange` | number[] | 치명 상태 범위 |
| `collapsedHp` | number | 패배 판정 체력 |
| `waveStackUnanimousHpPercent` | number | 겹치기 전원 동의 전환 기준 |
| `baseDamageBundleWindowSeconds` | number | 여러 누수를 하나의 표시 묶음으로 묶는 시간 |
| `baseOuterWarningSeconds` | number | 기지 도달 임박 경고 목표 시간 |
| `normalWaveFatalPolicy` | enum | `defeat_on_zero_after_packet` 권장 |
| `bossReachPolicyIds` | string[] | 보스별 기지 도달 정책 |
| `recoveryRuleIds` | string[] | 사용할 `BaseRecoveryRule.id` |
| `forbiddenRecoveryTags` | string[] | 회복 경제에 붙으면 안 되는 보정 태그 |
| `notes` | string | 설계 의도 |

예시:

```json
{
  "id": "base_health_rule_mvp_001",
  "baseHpMax": 30,
  "safeHpRange": [21, 30],
  "dangerHpRange": [10, 20],
  "criticalHpRange": [1, 9],
  "collapsedHp": 0,
  "waveStackUnanimousHpPercent": 0.30,
  "baseDamageBundleWindowSeconds": 0.75,
  "baseOuterWarningSeconds": 3,
  "normalWaveFatalPolicy": "defeat_on_zero_after_packet",
  "bossReachPolicyIds": ["boss_reach_policy_silent_colossus_010"],
  "recoveryRuleIds": ["base_recovery_shop_small_3", "base_recovery_shop_boss_5"],
  "forbiddenRecoveryTags": [
    "wave_stack_discount",
    "kill_count_discount",
    "clear_time_discount",
    "accessibility_price_modifier",
    "overheal",
    "combat_instant_base_heal"
  ],
  "notes": "기지 체력은 작게 유지하고, 회복은 실수 삭제가 아니라 다음 전투 여유를 사는 선택으로 둔다."
}
```

### 기지 피해 패킷 데이터

`BaseDamagePacket`은 적이 기지에 도달해 실제 피해를 줄 때 생성되는 전투 기록입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 피해 패킷 ID |
| `runId` | string | 런 ID |
| `day` | number | 일자 |
| `waveId` | string | 웨이브 ID |
| `sourceEnemyId` | string/null | 피해를 준 적 |
| `sourceBossId` | string/null | 보스 도달이면 보스 ID |
| `direction` | enum/null | 피해가 발생한 활성 방향 |
| `baseDamage` | number | 실제 기지 피해 |
| `mitigatedByIds` | string[] | 연막 장막 등 피해 감소 원천 |
| `hpBefore` | number | 피해 전 기지 체력 |
| `hpAfter` | number | 피해 후 기지 체력 |
| `bundleId` | string/null | 0.75초 안에 묶인 누수 표시 ID |
| `wasFatal` | boolean | 패배로 이어졌는지 |
| `reportCauseTags` | string[] | 리포트와 패배 분석 태그 |

`BaseDamagePacket`은 피해를 줄이지 않는 UI 묶음과 실제 피해 계산을 분리합니다.

여러 적이 동시에 도달해도 피해는 합산되며, 표시만 하나의 누수 묶음으로 정리할 수 있습니다.

### 기지 회복 규칙 데이터

`BaseRecoveryRule`은 상점과 이벤트에서 기지 체력을 회복하는 항목의 제한을 정의합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 회복 규칙 ID |
| `sourceType` | enum | `shop`, `event`, `artifact` |
| `linkedShopItemId` | string/null | 상점 항목이면 연결된 `ShopItem.id` |
| `restoreAmount` | number | 회복량 |
| `basePriceGold` | number/null | 기본 골드 가격 |
| `emergencySurchargeGold` | number | 치명 정비 할증 |
| `emergencyThresholdHp` | number | 할증과 위험 문구가 켜지는 체력 |
| `maxPurchasesPerSession` | number | 같은 상점 세션 구매 제한 |
| `overhealAllowed` | boolean | MVP에서는 false |
| `combatUseAllowed` | boolean | MVP에서는 false |
| `recommendedForTags` | string[] | 추천 태그 |
| `competingItemIds` | string[] | 같은 문제를 다르게 푸는 대안 |
| `forbiddenPatterns` | string[] | 금지 효과 |

대표 회복 규칙:

| ID | 회복량 | 가격 | 노출 | 제한 |
| --- | ---: | ---: | --- | --- |
| `base_recovery_shop_small_3` | 3 | 30 | 작은 상점 | 같은 세션 1회, 초과 회복 불가 |
| `base_recovery_shop_boss_5` | 5 | 45 | 보스 후 상점 | 같은 세션 1회, 체력 10 이하 가격 +20 |
| `base_recovery_event_trade_3` | 3 | 이벤트 결과 | 이벤트 | 숨은 벌칙 없이 사전 표시 |

기지 회복은 `wave_stack_count`, `kill_count_total`, `clear_time`, `accessibility_setting`, `solo_mode`로 가격이나 회복량이 바뀌지 않습니다.

## 세션 상태 데이터

세션 상태는 현재 접속과 재개 흐름을 관리하는 값입니다.

`RunState`와 달리 접속 상태에 따라 바뀔 수 있지만, 런 밸런스 기준으로 사용하지 않습니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `sessionId` | string | 현재 세션 ID |
| `runId` | string | 연결된 런 ID |
| `resumeFlowId` | string | `session_resume_flow` |
| `hostPlayerId` | string | 현재 호스트 또는 권위 판정자 |
| `connectedPlayerIds` | string[] | 현재 접속 중인 플레이어 |
| `reservedRoles` | object[] | 일시 이탈자의 직업 보류 상태 |
| `lastSavepointId` | string | 마지막 안정 저장점 |
| `pendingVoteId` | string/null | 진행 중 투표 |
| `interruptState` | enum | `none`, `input_idle`, `disconnected`, `host_timeout` |
| `resumeSnapshotId` | string/null | 복귀 플레이어에게 전달한 스냅샷 |

`reservedRoles` 예시:

```json
[
  {
    "playerId": "player_2",
    "classId": "class_architect",
    "reservedUntilSeconds": 120,
    "mode": "hold",
    "canSpendPersonalCards": false,
    "canAiPlayCards": false
  }
]
```

보류 모드는 구조물 소유권을 보존하지만 개인 카드와 개인 자원을 새로 소비하지 않습니다.

이 값은 접속 복구를 위한 상태이며, 보상 배율이나 난이도 보정으로 쓰지 않습니다.

## 인원수별 활성 방향 데이터

활성 방향은 데이터 테이블로 관리합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `playerCount` | number | 런 시작 인원수 |
| `activeDirections` | string[] | 일반 웨이브 스폰 후보 |
| `defaultFocus` | string | UI에서 처음 강조할 방향 |
| `notes` | string | 설계 의도 |

초기 테이블:

```json
[
  {
    "playerCount": 1,
    "activeDirections": ["east"],
    "defaultFocus": "east",
    "notes": "솔로 조작 부담을 줄이기 위한 단일 라인"
  },
  {
    "playerCount": 2,
    "activeDirections": ["north", "east"],
    "defaultFocus": "east",
    "notes": "짧은 동쪽과 느린 북쪽의 기본 분담"
  },
  {
    "playerCount": 3,
    "activeDirections": ["west", "north", "east"],
    "defaultFocus": "west",
    "notes": "빠른 서쪽 라인과 순회 지원 추가"
  },
  {
    "playerCount": 4,
    "activeDirections": ["west", "north", "east", "south"],
    "defaultFocus": "west",
    "notes": "네 방향 전체가 열린 협동 방어"
  }
]
```

`activeDirections`는 런 전체에서 사용할 수 있는 입구 목록입니다.

4인 런은 `west`, `north`, `east`, `south`가 모두 활성화되지만, 개별 `WaveSpawnPlan`이 항상 네 방향을 동시에 사용해야 한다는 뜻은 아닙니다. 동시 사용 방향 수는 일자, 보스, 리허설 의도에 맞춰 별도 필드에서 제한합니다.

## 스케일링 프로필 데이터

스케일링 프로필은 인원수별 튜닝값을 데이터로 묶습니다.

2인을 기준값 1.0으로 둡니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 스케일링 프로필 ID |
| `playerCount` | number | 런 시작 인원수 |
| `threatBudgetMultiplier` | number | 웨이브 위험도 예산 배율 |
| `enemyCountMultiplier` | number | 적 수량 배율 |
| `bossHpMultiplier` | number | 보스 본체 체력 배율 |
| `bossPartHpMultiplier` | number | 보스 부위 체력 배율 |
| `eliteFrequencyMultiplier` | number | 정예 등장 빈도 배율 |
| `structureDamageMultiplier` | number | 보스/적의 구조물 피해 배율 |

초기 테이블:

```json
[
  {
    "id": "scaling_players_1",
    "playerCount": 1,
    "threatBudgetMultiplier": 0.65,
    "enemyCountMultiplier": 0.60,
    "bossHpMultiplier": 0.65,
    "bossPartHpMultiplier": 0.60,
    "eliteFrequencyMultiplier": 0.50,
    "structureDamageMultiplier": 0.75
  },
  {
    "id": "scaling_players_2",
    "playerCount": 2,
    "threatBudgetMultiplier": 1.00,
    "enemyCountMultiplier": 1.00,
    "bossHpMultiplier": 1.00,
    "bossPartHpMultiplier": 1.00,
    "eliteFrequencyMultiplier": 1.00,
    "structureDamageMultiplier": 1.00
  },
  {
    "id": "scaling_players_3",
    "playerCount": 3,
    "threatBudgetMultiplier": 1.15,
    "enemyCountMultiplier": 1.10,
    "bossHpMultiplier": 1.15,
    "bossPartHpMultiplier": 1.10,
    "eliteFrequencyMultiplier": 1.15,
    "structureDamageMultiplier": 1.10
  },
  {
    "id": "scaling_players_4",
    "playerCount": 4,
    "threatBudgetMultiplier": 1.30,
    "enemyCountMultiplier": 1.20,
    "bossHpMultiplier": 1.25,
    "bossPartHpMultiplier": 1.20,
    "eliteFrequencyMultiplier": 1.25,
    "structureDamageMultiplier": 1.15
  }
]
```

스케일링 프로필은 웨이브 보상, 카드 희귀도, 시간 경과 마나 회복을 건드리지 않습니다.

## 전투 튜닝 프로필 데이터

`CombatTuningProfile`은 첫 프로토타입에서 공유할 전투 기준선입니다.

이 데이터는 개별 카드나 적을 강하게 만들기 위한 값이 아니라, 웨이브가 어떤 시간 감각으로 흘러야 하는지 고정하는 기준입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 전투 튜닝 프로필 ID |
| `baselinePlayerCount` | number | 기준 인원수, 기본 2 |
| `baseHpMax` | number | 기지 최대 체력 |
| `baseDangerHp` | number | 위험 상태 기준 체력 |
| `baseCriticalHp` | number | 치명 상태 기준 체력 |
| `targetNormalWaveSeconds` | number[] | 일반 웨이브 목표 시간 범위 |
| `targetBossWaveSeconds` | number[] | 보스전 목표 시간 범위 |
| `firstEnemyContactSeconds` | number[] | 첫 적이 방어선과 만나는 목표 시간 |
| `firstStructureBreakCandidateSeconds` | number[] | 첫 구조물 파괴 후보가 생기는 목표 시간 |
| `postBreakRecoveryWindowSeconds` | number[] | 파괴 후 복구 판단을 보장할 시간 |
| `firstBaseDamageEarliestSeconds` | number | 첫 기지 피해가 너무 빨리 나지 않게 보는 기준 |
| `baseEnemyMoveSpeedTilesPerSecond` | number | 속도 1.0의 타일/초 기준 |
| `directionTravelTargets` | object | 방향별 방어선 없는 도달 시간 목표 |
| `structureSurvivalTargets` | object | 구조물별 피격 생존창 |
| `defaultEnemyStructureAttackIntervalSeconds` | number | 일반 구조물 공격 간격 기준 |
| `manaGaugeMax` | number | 마나 게이지 최대치 |
| `drawGaugeMax` | number | 드로우 게이지 최대치 |
| `combatManaMax` | number | 전투 마나 저장 한도 |
| `killBurstWindowSeconds` | number | 처치 몰림 보정 시간창 |
| `killBurstTiers` | object[] | 처치 몰림 보정 구간 |
| `forbiddenTuningLevers` | string[] | 튜닝에 쓰지 않을 보정 |

예시:

```json
{
  "id": "combat_tuning_mvp_baseline_001",
  "baselinePlayerCount": 2,
  "baseHpMax": 30,
  "baseDangerHp": 20,
  "baseCriticalHp": 9,
  "targetNormalWaveSeconds": [45, 70],
  "targetBossWaveSeconds": [120, 240],
  "firstEnemyContactSeconds": [6, 10],
  "firstStructureBreakCandidateSeconds": [12, 25],
  "postBreakRecoveryWindowSeconds": [6, 12],
  "firstBaseDamageEarliestSeconds": 20,
  "baseEnemyMoveSpeedTilesPerSecond": 1.0,
  "directionTravelTargets": {
    "east": [15, 20],
    "west": [16, 22],
    "north": [22, 30],
    "south": [24, 34]
  },
  "structureSurvivalTargets": {
    "basic_tower": [8, 14],
    "taunt_tower": [12, 20],
    "basic_barricade": [8, 16],
    "explosive_barricade": [4, 10],
    "aura_device": [4, 8],
    "temporary_structure": [3, 7]
  },
  "defaultEnemyStructureAttackIntervalSeconds": 1.5,
  "manaGaugeMax": 100,
  "drawGaugeMax": 100,
  "combatManaMax": 10,
  "killBurstWindowSeconds": 3,
  "killBurstTiers": [
    {"killCountMin": 1, "killCountMax": 10, "resourceMultiplier": 1.00},
    {"killCountMin": 11, "killCountMax": 25, "resourceMultiplier": 0.80},
    {"killCountMin": 26, "killCountMax": 50, "resourceMultiplier": 0.60},
    {"killCountMin": 51, "killCountMax": null, "resourceMultiplier": 0.40}
  ],
  "forbiddenTuningLevers": [
    "wave_stack_reward_bonus",
    "last_hit_bonus",
    "time_based_mana_regen",
    "accessibility_power_adjustment"
  ]
}
```

이 프로필의 수치는 최종 밸런스가 아니라, 첫 테스트에서 흔들리지 않을 기준선입니다.

수치가 맞지 않을 때도 먼저 웨이브 순서, 스폰 간격, 경로 길이, 예고 시간을 조정하고, 구조물 체력과 자원 충전량은 늦게 조정합니다.

## 직업 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 직업 ID |
| `nameKo` | string | 표시명 |
| `roleTags` | string[] | `defense`, `maze`, `aoe`, `support` 등 |
| `startingDeck` | string[] | 시작 카드 ID 목록 |
| `seedManaSolo` | number | 솔로 시작 시드 마나 |
| `seedManaMulti` | number | 멀티 시작 시드 마나 |
| `signatureKeywords` | string[] | 대표 키워드 |
| `growthRouteId` | string | 100일 성장 루트 ID |
| `cardPoolContractIds` | string[] | 이 직업이 사용하는 카드 풀 계약 ID 목록 |
| `synergyTags` | string[] | 다른 직업과 맞물리는 시너지 태그 |
| `soloCompensationProfileId` | string | 솔로 보완 기준 ID |

예시:

```json
{
  "id": "class_guardian",
  "nameKo": "수호자",
  "roleTags": ["defense", "taunt", "thorns"],
  "startingDeck": [
    "card_guardian_taunt_wall",
    "card_guardian_taunt_wall",
    "card_guardian_shield_wrap",
    "card_guardian_shield_wrap",
    "card_guardian_thorn_growth",
    "card_guardian_thorn_growth",
    "card_guardian_binding_oath",
    "card_guardian_last_gate",
    "card_guardian_counter_stance",
    "card_guardian_counter_stance"
  ],
  "seedManaSolo": 4,
  "seedManaMulti": 3,
  "signatureKeywords": ["keyword_taunt", "keyword_thorns"],
  "growthRouteId": "class_growth_guardian_001_100",
  "cardPoolContractIds": ["class_card_pool_contract_guardian_first_010", "class_card_pool_contract_guardian_mvp_030"],
  "synergyTags": ["synergy_trigger_taunt_cluster", "synergy_trigger_delayed_repair"],
  "soloCompensationProfileId": "solo_compensation_guardian"
}
```

직업 데이터는 솔로와 멀티에서 다른 기믹을 제공하지 않습니다.

솔로 보완은 활성 방향, 적 수, 시드 마나, 공용 카드 추천으로 처리합니다.

## 대응 태그 데이터

대응 태그는 카드, 아티팩트, 훈련장, 적 역할 프로필이 공유하는 행동 언어입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 대응 태그 ID |
| `labelKo` | string | UI와 제작표에 쓰는 표시명 |
| `opensAction` | string | 플레이어에게 열어주는 행동 |
| `supportedEnemyRoleProfileIds` | string[] | 주로 대응하는 적 역할 프로필 |
| `recommendedCardTags` | string[] | 이 대응 태그를 가진 카드가 보통 함께 가지는 카드 태그 |
| `hardCounterForbidden` | boolean | 이 태그가 단일 정답 카운터가 되면 안 되는지 |

예시:

```json
{
  "id": "taunt_anchor",
  "labelKo": "도발 앵커",
  "opensAction": "적 목표를 한 지점으로 모아 딜타임을 만든다.",
  "supportedEnemyRoleProfileIds": ["enemy_role_profile_swarm", "enemy_role_profile_runner", "enemy_role_profile_breaker"],
  "recommendedCardTags": ["taunt", "structure", "defense"],
  "hardCounterForbidden": true
}
```

## 카드 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 카드 ID |
| `nameKo` | string | 표시명 |
| `classId` | string/null | 직업 카드면 직업 ID, 공용이면 null |
| `poolLaneId` | string/null | 직업 카드의 주 카드 풀 라인 ID, 공용 카드면 null 가능 |
| `archetypeIds` | string[] | 이 카드가 지원하는 카드 아키타입 |
| `archetypeRole` | enum | `starter`, `signal`, `pivot`, `payoff`, `risk_accelerator`, `patch` |
| `commitmentLevel` | enum | `none`, `soft`, `commit` |
| `decisionQuestionKo` | string | 이 카드를 들고 고민해야 하는 질문 |
| `timingWindows` | string[] | 카드가 가장 강한 전투 타이밍 |
| `rarity` | enum | `common`, `rare`, `heroic`, `curse` |
| `cost` | number | 마나 비용 |
| `specProfileId` | string | 연결된 `CardSpecProfile.id` |
| `type` | enum | `build`, `upgrade`, `instant`, `conditional`, `economy` |
| `keywords` | string[] | 키워드 ID |
| `targetType` | enum | `tile`, `structure`, `enemy`, `area`, `self`, `none` |
| `castRangeTiles` | number/null | 기본 시전 거리, 거리 무시 카드면 null |
| `areaShape` | enum/null | `single`, `circle`, `line`, `cone`, `path_segment`, `aura`, `global_party` |
| `areaRadiusTiles` | number/null | 원형/오라 계열 반경 |
| `durationSeconds` | number/null | 기본 지속 시간, 즉발/영구 구조물은 null |
| `windupSeconds` | number | 발동 전 예고 시간 |
| `repeatLimitPerWave` | number/null | 웨이브당 사용 또는 가치 발동 제한 |
| `triggerLimitPerCast` | number/null | 한 번의 시전으로 발생 가능한 조건 발동 상한 |
| `bossEffectPolicyId` | string/null | 보스 본체/부위 적용 변환 규칙 |
| `uiPreviewType` | enum | `target`, `area`, `path`, `structure_link`, `wave_info`, `none` |
| `specRiskTags` | string[] | `free_action`, `global_target`, `area_large`, `hard_cc`, `resource_positive`, `structure_save`, `boss_direct`, `repeat_trigger`, `path_cost_change` |
| `effects` | object[] | 효과 목록 |
| `upgradeOptions` | string[] | 연결된 `CardUpgradeOption.id` 목록 |
| `tags` | string[] | 빌드 태그 |
| `responseTags` | string[] | 적 역할 압박에 대응하는 행동 태그 |
| `supportedEnemyRoleProfileIds` | string[] | 이 카드가 약하게 대응할 수 있는 적 역할 프로필 |
| `counterStrength` | enum | `soft`, `normal`, `strong` |
| `tradeoffTags` | string[] | 마나 외에 감수하는 대가 |
| `comboHookTags` | string[] | 같이 쓰면 좋은 카드, 구조물, 직업 시너지 |
| `missCostTag` | string | 잘못 사용했을 때 생기는 대표 손해 |
| `displayComplexity` | enum | `simple`, `tactical`, `buildaround` |

카드 효과는 여러 개를 가질 수 있습니다.

예시:

```json
{
  "id": "card_guardian_taunt_wall",
  "nameKo": "도발벽",
  "classId": "class_guardian",
  "poolLaneId": "guardian_taunt_anchor",
  "archetypeIds": ["archetype_guardian_iron_anchor"],
  "archetypeRole": "starter",
  "commitmentLevel": "none",
  "decisionQuestionKo": "첫 공격을 어디로 끌어들일 것인가?",
  "timingWindows": ["prebuild", "first_contact"],
  "rarity": "common",
  "cost": 1,
  "specProfileId": "spec_card_guardian_taunt_wall_mvp",
  "type": "build",
  "keywords": ["keyword_taunt"],
  "targetType": "tile",
  "castRangeTiles": 6,
  "areaShape": "aura",
  "areaRadiusTiles": 2,
  "durationSeconds": null,
  "windupSeconds": 0,
  "repeatLimitPerWave": null,
  "triggerLimitPerCast": null,
  "bossEffectPolicyId": "boss_policy_taunt_weakened",
  "uiPreviewType": "path",
  "specRiskTags": ["path_cost_change"],
  "effects": [
    {
      "kind": "spawn_structure",
      "structureId": "structure_taunt_tower",
      "duration": null
    }
  ],
  "upgradeOptions": ["upgrade_taunt_wall_sturdy_front", "upgrade_taunt_wall_wide_taunt"],
  "tags": ["defense", "taunt", "structure"],
  "responseTags": ["taunt_anchor", "repair_window"],
  "supportedEnemyRoleProfileIds": ["enemy_role_profile_runner", "enemy_role_profile_breaker"],
  "counterStrength": "normal",
  "tradeoffTags": ["low_damage", "position_commitment"],
  "comboHookTags": ["elementalist_area_damage", "tinkerer_repair_window"],
  "missCostTag": "bad_taunt_position_clusters_enemies",
  "displayComplexity": "simple"
}
```

## 카드 스펙 프로필 데이터

`CardSpecProfile`은 카드의 실제 수치와 적용 정책을 한 곳에 묶는 데이터입니다.

`CardData`가 카드의 정체성, 보상 풀, 아키타입을 설명한다면, `CardSpecProfile`은 전투 중 판정에 필요한 숫자와 제한을 설명합니다.

카드 강화, 아티팩트, 이벤트가 카드 수치를 바꿀 때도 원본 `CardSpecProfile`의 어떤 축을 바꾸는지 남겨야 합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 스펙 프로필 ID |
| `cardId` | string | 대상 카드 ID |
| `revisionTag` | string | 수치 조정 버전 |
| `manaCost` | number | 실제 전투 비용 |
| `targetType` | enum | 대상 타입 |
| `validTargetRules` | string[] | 설치 불가, 체력 조건, 도발 조건 등 대상 조건 |
| `castRangeTiles` | number/null | 시전 거리 |
| `areaShape` | enum/null | 효과 범위 형태 |
| `areaRadiusTiles` | number/null | 범위 반경 |
| `durationSeconds` | number/null | 지속 시간 |
| `windupSeconds` | number | 예고 시간 |
| `effectBudgetId` | string | 비용/범위/지속 예산 기준 |
| `effectValues` | object | 피해, 회복, 감속, 공격 속도 등 실제 값 |
| `statusApplication` | object/null | 상태이상 적용과 반복 저항 |
| `resourceDelta` | object/null | 마나, 드로우, 골드 변동 |
| `structureDelta` | object/null | 구조물 생성, 수리, 피해, 체력 변화 |
| `enemyGradeMultipliers` | object/null | 일반, 정예, 보스 부위, 보스 본체 배율 |
| `bossPolicy` | object/null | 보스 본체/부위 적용 변환 |
| `repeatLimitPerWave` | number/null | 웨이브당 반복 제한 |
| `triggerLimitPerCast` | number/null | 시전당 조건 발동 제한 |
| `uiPreviewType` | enum | 대상/범위/경로/구조물 연결/웨이브 정보 표시 방식 |
| `failureFeedbackTags` | string[] | 무효 대상, 길막, 범위 밖, 조건 불충족 피드백 |
| `telemetryTags` | string[] | 전투 기록에 남길 태그 |
| `notes` | string | 설계 의도 |

예시:

```json
{
  "id": "spec_card_elementalist_fireball_mvp",
  "cardId": "card_elementalist_fireball",
  "revisionTag": "mvp_001",
  "manaCost": 1,
  "targetType": "area",
  "validTargetRules": ["target_must_be_in_active_lane_space", "can_target_visible_enemy_or_ground"],
  "castRangeTiles": 6,
  "areaShape": "circle",
  "areaRadiusTiles": 1.5,
  "durationSeconds": null,
  "windupSeconds": 0.35,
  "effectBudgetId": "budget_cost1_small_area_instant",
  "effectValues": {
    "damage": 3
  },
  "statusApplication": null,
  "resourceDelta": null,
  "structureDelta": null,
  "enemyGradeMultipliers": {
    "normal": 1.0,
    "elite": 0.7,
    "bossPart": 0.4,
    "bossBody": 0.2
  },
  "bossPolicy": {
    "policyId": "boss_policy_direct_damage_reduced",
    "cannotCancelPattern": true
  },
  "repeatLimitPerWave": null,
  "triggerLimitPerCast": null,
  "uiPreviewType": "area",
  "failureFeedbackTags": ["out_of_range", "no_visible_area", "target_left_warning"],
  "telemetryTags": ["area_damage", "small_aoe", "mvp_baseline"],
  "notes": "기본 광역 카드. 킬존에 모인 일반 적을 정리하지만 보스 대응은 약하다."
}
```

### 카드 스펙 예산 ID

| ID | 기준 |
| --- | --- |
| `budget_cost0_connector` | 비용 0, 순이득 없음, 손패/타이밍 연결 |
| `budget_cost0_risky_boost` | 비용 0, 구조물 피해나 다음 드로우 감소 같은 명확한 대가 |
| `budget_cost1_aura_device` | 비용 1, 설치 위치와 오라 중첩 상한을 가진 보조 구조물 |
| `budget_cost1_single_basic` | 비용 1, 단일 대상 기본 행동 |
| `budget_cost1_risky_focus` | 비용 1, 특정 우선 대상에 강하지만 전선 운영이나 자원 효율 대가가 있음 |
| `budget_cost1_small_area_instant` | 비용 1, 작은 범위, 낮은 피해, 짧은 예고 |
| `budget_cost1_global_support` | 비용 1, 전장 전체 편의성, 낮은 수치와 반복 보정 |
| `budget_cost2_tactical_shift` | 비용 2, 전술 방향 변경, 조건 또는 제한 필요 |
| `budget_cost3_engine_commitment` | 비용 3, 준비된 구조물 배치를 장기 운영 축으로 바꾸는 선택 |
| `budget_cost3_crisis_answer` | 비용 3, 큰 위기 대응, 예고 또는 후속 대가 필요 |
| `budget_cost4_commitment` | 비용 4 이상, 준비된 빌드의 결전 선택 |

### MVP 카드 수치 예산 잠금 데이터

`MvpCardStatBudgetLock`은 `CardSpecProfile.effectBudgetId`가 실제 비용, 범위, 지속, 반복 제한과 맞는지 검증하는 기준입니다.

이 데이터는 카드 효과를 강하게 만들기 위한 보정표가 아니라, 한 축이 강해졌을 때 다른 축의 대가가 빠지지 않게 하는 잠금표입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 수치 예산 잠금 ID |
| `allowedEffectBudgetIds` | string[] | 연결 가능한 `effectBudgetId` |
| `costRange` | object | 허용 마나 비용 범위 |
| `maxAreaRadiusTiles` | number/null | 기본 허용 반경 |
| `maxDurationSeconds` | number/null | 기본 허용 지속 |
| `maxCastRangeTiles` | number/null | 기본 시전 거리 |
| `requiresWindupAtOrAboveRadius` | object/null | 특정 반경 이상에서 필요한 예고 시간 |
| `requiredCompensationTags` | string[] | 초과 시 필요한 대가 태그 |
| `requiredPolicyIds` | string[] | 보스, 경로, 반복, 수리 등 필수 정책 |
| `forbiddenSpecTags` | string[] | 금지 조합 태그 |
| `notes` | string | 설계 의도 |

MVP 기본 잠금표:

| ID | 예산 | 비용 | 기본 상한 | 필수 대가/정책 |
| --- | --- | --- | --- | --- |
| `stat_budget_connector_0` | 0비용 연결 | 0 | 피해/회복 없음 | 순수 드로우/마나 순증가 금지, 대가 태그 필요 |
| `stat_budget_risky_boost_0` | 0비용 위험 가속 | 0 | 즉시 버프/임시 설치 가능 | 구조물 피해, 수리 효율 감소, 드로우 손실, 회수 가치 제외 중 1개 이상 |
| `stat_budget_basic_1` | 1비용 기본 | 1 | 반경 1.5, 지속 6초 | 낮은 보스 배율 또는 대상 조건 |
| `stat_budget_flexible_1` | 1비용 편의 | 1 | 원격 가능, 낮은 수치 | 반복 효율 감소, 대상 조건 |
| `stat_budget_tactical_2` | 2비용 전술 | 2 | 반경 2.5, 지속 10초 | 중첩 제한, 보스 약화 변환 |
| `stat_budget_crisis_3` | 3비용 위기 | 3 | 반경 3.5, 큰 예고 | 1초 이상 예고 또는 후유증, 웨이브당 제한 |
| `stat_budget_commit_4` | 4비용 결전 | 4 이상 | 빌드 결전 | 선행 아키타입, 큰 실패 손해 |
| `stat_budget_curse` | 저주 계약 | 0~1 | 즉시 이득 큼 | 명시 확인, 장기 대가, 제거/안정화 연결 |

검증 예시:

```json
{
  "id": "stat_budget_basic_1",
  "allowedEffectBudgetIds": [
    "budget_cost1_single_basic",
    "budget_cost1_small_area_instant"
  ],
  "costRange": {"min": 1, "max": 1},
  "maxAreaRadiusTiles": 1.5,
  "maxDurationSeconds": 6,
  "maxCastRangeTiles": 7,
  "requiresWindupAtOrAboveRadius": {"radiusTiles": 1.5, "minWindupSeconds": 0.35},
  "requiredCompensationTags": ["target_condition_or_low_boss_multiplier"],
  "requiredPolicyIds": ["boss_policy_direct_damage_reduced"],
  "forbiddenSpecTags": ["global_target", "hard_cc_without_resistance", "free_resource_positive"],
  "notes": "1비용 기본 행동은 자주 쓰는 카드이므로 작은 범위와 명확한 실패 가능성을 가진다."
}
```

### 수호자 카드 보스 정책

수호자 카드는 보스 압박을 지연할 수 있지만, 보스 본체 패턴을 지우면 안 됩니다.

아래 정책은 `CardSpecProfile.bossPolicy`나 `bossEffectPolicyId`에서 사용합니다.

| ID | 적용 카드 | 정책 |
| --- | --- | --- |
| `boss_policy_taunt_weakened` | 도발벽, 철벽 전개, 불굴의 성문 | 보스 본체의 강제 패턴은 도발보다 우선하며, 보스 부위와 동반 웨이브만 도발 영향을 강하게 받습니다. |
| `boss_policy_guardian_slow_weakened` | 붙잡는 맹세, 균열 방패 | 보스 본체에는 정지가 아니라 10% 이하 감속으로 변환하고, 보스 부위에는 짧은 취약 표시로 변환할 수 있습니다. |
| `boss_policy_no_body_stun` | 불굴의 성문 | 보스 본체는 행동 중단되지 않고, 보스 부위 취약이나 다음 패턴 예고 연장으로만 변환합니다. |
| `boss_policy_thorn_reflect_reduced` | 가시 성장, 반사의 맹세, 가시 왕좌 | 보스 본체 반사 피해는 50%로 줄이고, 부위 반사 피해는 70%로 줄입니다. |
| `boss_policy_crisis_hold_limited` | 최후의 문, 마지막 수호 | 구조물 생존 시간은 벌 수 있지만, 보스 경로 차단이나 보스 공격 취소로 처리하지 않습니다. |

### 건축가 카드 경로/회수 정책

건축가 카드는 경로와 파괴 기록을 직접 다루므로, 스펙 프로필에서 아래 정책을 명시적으로 참조합니다.

| ID | 적용 카드 | 정책 |
| --- | --- | --- |
| `route_policy_no_full_block_card` | 바리케이드, 이중 바리케이드, 무리한 증축 | 카드 사용 전 모든 활성 입구에서 기지까지 유효 경로가 남아야 합니다. |
| `route_policy_temporary_structure_no_salvage` | 급조 통로, 무리한 증축 | 무료 또는 임시 구조물은 회수 작업, 파편 회수, 연쇄 붕괴의 자원 가치로 계산하지 않습니다. |
| `route_policy_debris_soft_reopen` | 바리케이드, 잔해 폭발, 미끄러운 잔해 | 잔해로 완전 길막이 생기면 가장 오래된 잔해를 약화하거나 `밟힌 잔해`로 바꿉니다. |
| `route_policy_inverted_path_soft_cost` | 뒤집힌 통로 | 경로 비용만 높이고, 기지 경로나 보스 경로를 완전히 차단하지 않습니다. |
| `salvage_policy_distinct_structure_window` | 회수 작업, 파편 회수 | 최근 파괴된 서로 다른 구조물 기록만 계산하고, 한 기록은 한 번만 소모합니다. |
| `collapse_policy_single_structure_explosion_cap` | 잔해 폭발, 지연 폭약, 연쇄 붕괴 | 구조물 1개에서 발생하는 폭발 보너스는 상한을 가지며, 같은 구조물로 반복 발동하지 않습니다. |
| `boss_policy_path_cost_reduced` | 둔화 말뚝, 뒤집힌 통로 | 보스 본체는 경로 비용 증가와 둔화를 약화된 값으로만 받으며, 보스 경로를 막지 않습니다. |

### 원소술사 카드 상태이상/보스 정책

원소술사 카드는 광역 피해와 상태이상 변환이 많으므로, 스펙 프로필에서 아래 정책을 명시적으로 참조합니다.

| ID | 적용 카드 | 정책 |
| --- | --- | --- |
| `boss_policy_element_damage_reduced` | 화염구, 번개 연결, 대폭발, 화염 고리, 낙뢰 의식 | 보스 본체 피해는 약화된 계수로만 적용하고, 피해로 보스 패턴을 취소하지 않습니다. 보스 부위는 본체보다 높은 계수를 받을 수 있습니다. |
| `boss_policy_control_to_slow` | 빙결 지대, 밀어내기, 되감는 돌풍, 정지의 눈 | 보스 본체 빙결과 넉백은 약한 둔화로 변환합니다. 보스 부위에는 짧은 취약 표시나 부위 피해 보정으로 변환할 수 있습니다. |
| `boss_policy_mark_part_focus` | 원소 표식, 원소 균열, 금지된 등불 | 표식은 보스 부위 집중을 가장 강하게 지원하고, 보스 본체에는 약화된 값만 적용합니다. 표식으로 보스 패턴을 취소하지 않습니다. |
| `status_policy_repeated_control_resistance` | 빙결 지대, 밀어내기, 서리 파편, 되감는 돌풍, 정지의 눈 | 같은 적에게 둔화, 빙결, 넉백을 반복 적용하면 `SYSTEM_RULES_AND_EDGE_CASES.md`의 반복 감소 규칙을 따릅니다. |
| `area_policy_fixed_warning_points` | 대폭발, 낙뢰 의식 | 큰 광역 카드는 예고된 고정 지점을 사용하며, 시전 후 적을 자동 추적하지 않습니다. |
| `kill_chain_policy_trigger_cap` | 번개 연결, 과충전 번개 | 연쇄 피해와 처치 전이는 시전당 발동 상한과 같은 대상 재타격 금지를 가집니다. |

원소술사 스펙 검증 규칙:

- 보스 본체는 빙결, 넉백, 완전 정지로 행동이 중단되지 않습니다.
- 큰 광역 카드는 경고 지점, 예고 시간, 실패 피드백을 반드시 가집니다.
- 연쇄 피해와 처치 전이는 `triggerLimitPerCast` 또는 `repeatLimitPerWave`를 명시합니다.
- 표식 카드는 보상량, 희귀도, 후보 수를 바꾸지 않고 전투 중 목표 집중만 바꿉니다.
- 솔로 동쪽 전선에서도 군집, 돌파, 정예, 보스 부위 질문이 모두 `LaneProjection`으로 등장해야 합니다.

### 땜장이 카드 오라/수리/과부하 정책

땜장이 카드는 구조물의 수명과 화력 창을 직접 다루므로, 스펙 프로필에서 아래 정책을 명시적으로 참조합니다.

| ID | 적용 카드 | 정책 |
| --- | --- | --- |
| `repair_policy_diminishing_returns` | 원격 수리, 보강판, 강화 나사 | 같은 구조물을 짧은 시간 안에 반복 회복하거나 보강하면 효율이 감소합니다. 수리는 파괴 타이밍을 늦추지만 구조물 손실을 삭제하지 않습니다. |
| `aura_policy_stack_cap` | 증폭기, 긴급 배선, 예열 장치, 공명 증폭기 | 같은 능력치 오라와 공격 속도 버프는 합산 상한을 가지며, 가장 강한 효과 이후에는 약화된 값으로만 공유됩니다. |
| `overdrive_policy_penalty_queue` | 과부하, 자동 소화, 위험한 개조 | 과부하 계열 효과는 지속 종료 시 피해나 수리 효율 감소를 남깁니다. 페널티 무효화는 명시된 1회 효과만 허용합니다. |
| `maintenance_resource_policy_no_loop` | 예비 부품, 자동 복구, 재조립 기계 | 임시 구조물, 자동 복구로 살아난 구조물, 같은 구조물 반복 파괴 기록은 자원 회수 가치로 반복 계산하지 않습니다. |
| `rebuild_policy_repeat_penalty` | 자동 복구, 재조립 기계 | 같은 구조물이나 같은 타일을 반복 복구하면 낮은 체력, 수리 효율 감소, 경로 검사 같은 페널티를 적용합니다. |
| `boss_policy_maintenance_no_pattern_cancel` | 원격 수리, 보강판, 자동 복구, 재조립 기계 | 보스 본체의 확정 피해나 강제 패턴을 수리와 복구로 취소하지 않습니다. 구조물 생존 시간을 벌 수는 있지만 보스 경로를 막지는 않습니다. |

땜장이 스펙 검증 규칙:

- 전장 전체 수리는 낮은 회복량, 반복 효율 감소, 치명 대상 표시를 함께 가집니다.
- 오라 장치는 위치 위험과 중첩 상한을 가지며, 사방 모든 전선을 동시에 안정화하지 않습니다.
- 과부하 계열 카드는 종료 피해, 수리 효율 감소, 대상 체력 조건 중 하나 이상을 가집니다.
- 자동 복구와 재조립은 파괴 순간 효과, 회수 보상, 보스 패턴 취소를 반복 생성하지 않습니다.
- 솔로 동쪽 전선에서도 수리, 오라, 과부하, 유지보수 경제 질문이 모두 등장해야 합니다.

### 공용 카드 약한 보완 정책

공용 카드는 파티 조합의 빈틈을 약하게 보완하지만, 직업 전용 카드의 핵심 역할을 같은 강도로 대체하지 않습니다.

| ID | 적용 카드 | 정책 |
| --- | --- | --- |
| `common_policy_soft_gap_only` | 모든 공용 카드 | 공용 카드의 `counterStrength`는 기본적으로 `soft` 또는 `normal`이며, 직업 카드 풀 계약의 `forbiddenReplacementResponseTags`에 대해 `strong`을 가질 수 없습니다. |
| `common_policy_no_discard_reward_trigger` | 재정비, 마나 전환, 빠른 손놀림 | 카드 효과로 버린 카드는 비상 탈출기 마나 회복, 버리기 스택 보상, 별도 버리기 보상 효과를 발동하지 않습니다. |
| `common_policy_resource_loop_cap` | 마나 전환, 빠른 손놀림, 재정비 | 0비용 공용 카드는 손패, 마나, 드로우를 동시에 순증가시키지 않습니다. 마나 전환은 웨이브당 발동 상한을 가집니다. |
| `common_policy_soft_focus_not_mark` | 집중 사격 | 집중 사격은 단일/타워 피해 중심의 약한 목표 표시이며, 원소 표식의 광역 피해 증폭을 대체하지 않습니다. 같은 대상 증폭은 높은 값만 적용합니다. |
| `common_policy_weak_repair_not_tinkerer` | 긴급 보수 | 긴급 보수는 사거리 제한과 낮은 회복량을 가지며, 원격 수리나 자동 복구 수준의 구조물 유지력을 제공하지 않습니다. |
| `common_policy_collapse_soft_control` | 전장 수습 | 전장 수습은 파괴 이후 짧은 둔화만 제공하고, 잔해 생성, 폭발 피해, 회수 가치, 완전 길막을 제공하지 않습니다. |
| `common_policy_information_no_answer` | 전술 지도 | 전술 지도는 활성 방향의 예고 정보를 명확히 하지만, 정답 배치, 자동 추천, 비활성 방향 정보 공개를 하지 않습니다. |
| `common_policy_temporary_no_salvage` | 임시 포탑 | 임시 포탑은 도발, 오라, 잔해, 회수 가치, 직업 전용 타워 성능을 가지지 않습니다. |

공용 카드 스펙 검증 규칙:

- 공용 카드는 빠진 직업의 약점을 완전히 지우지 않고, 느리지만 가능한 대응만 엽니다.
- 0비용 공용 카드는 조건 없는 순수 드로우, 마나 순증가, 버리기 보상 루프를 만들지 않습니다.
- 공용 수리와 공용 제어는 직업 전용 수리, 잔해, 상태이상보다 안정적이면 안 됩니다.
- 공용 정보 카드는 위험을 읽게 하지만 플레이어 대신 배치 결정을 내리지 않습니다.
- 솔로 동쪽 전선에서도 공용 카드는 직업 기믹 변경 없이 약한 보완으로만 작동해야 합니다.

### 카드 타이밍 창과 대가 태그

`timingWindows`는 카드가 가장 강하게 읽히는 전투 순간입니다.

| ID | 의미 |
| --- | --- |
| `prebuild` | 웨이브 시작 전 첫 방어선 구축 |
| `first_contact` | 적이 첫 구조물에 닿는 순간 |
| `swarm_compressed` | 적이 킬존에 모인 순간 |
| `structure_critical` | 구조물이 파괴 직전인 순간 |
| `collapse_aftershock` | 구조물이 부서진 직후 |
| `priority_exposed` | 정예, 지원형, 보스 부위가 노출된 순간 |
| `hand_jammed` | 손패가 막혀 다음 행동이 끊긴 순간 |
| `stack_pressure` | 겹친 웨이브로 전선 밀도가 높아진 순간 |
| `boss_commit` | 보스 부위나 마지막 접근에 자원을 몰아야 하는 순간 |
| `base_critical` | 기지 체력이 낮아 다음 피해가 치명적인 순간 |

`tradeoffTags`는 카드 비용 외의 대가입니다.

| ID | 의미 |
| --- | --- |
| `position_commitment` | 특정 위치에 미리 배치해야 강합니다. |
| `structure_hp_loss` | 구조물 체력이나 내구를 대가로 씁니다. |
| `repair_efficiency_down` | 수리 효율을 낮춥니다. |
| `next_draw_down` | 다음 드로우나 손패 품질을 낮춥니다. |
| `temporary_only` | 짧은 시간만 유지됩니다. |
| `requires_prior_setup` | 선행 구조물, 상태이상, 표식이 있어야 강합니다. |
| `low_damage` | 직접 피해가 낮습니다. |
| `repeat_penalty` | 같은 효과를 반복하면 효율이 줄어듭니다. |
| `aura_stack_cap` | 오라나 버프를 여러 개 겹쳐도 합산 상한이 있습니다. |
| `overdrive_penalty` | 지속 종료 후 구조물 피해나 수리 효율 감소가 남습니다. |
| `rebuild_decay` | 같은 구조물이나 같은 타일을 반복 복구하면 효율이 낮아집니다. |
| `resource_loop_guard` | 파괴나 수리에서 얻는 자원이 반복 루프로 이어지지 않게 제한합니다. |
| `soft_gap_only` | 직업 전용 역할을 약하게만 보완합니다. |
| `no_discard_reward` | 버리기 자체가 추가 보상이나 자원 루프로 이어지지 않습니다. |
| `information_only` | 정보를 제공하지만 정답 행동을 추천하지 않습니다. |
| `temporary_no_salvage` | 임시 구조물이 파괴 보상이나 회수 가치로 계산되지 않습니다. |

## 카드 아키타입 데이터

`CardArchetype`은 여러 카드 풀 라인을 묶어 한 런의 덱 방향을 정의합니다.

카드 풀 라인이 "카드가 어떤 역할을 하는가"라면, 카드 아키타입은 "플레이어가 이번 런에서 어떤 운영을 밀고 있는가"를 나타냅니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 카드 아키타입 ID |
| `classId` | string/null | 대상 직업, 공용 아키타입이면 null |
| `nameKo` | string | 표시명 |
| `runStage` | enum | `first_010`, `mvp_030`, `full_100`, `final_finish` |
| `primaryLaneIds` | string[] | 핵심 카드 풀 라인 |
| `secondaryLaneIds` | string[] | 보조 카드 풀 라인 |
| `coreDecisionKo` | string | 이 아키타입이 반복해서 묻는 질문 |
| `starterCardIds` | string[] | 방향을 시작하거나 보강하는 카드 |
| `pivotCardIds` | string[] | 플레이 방식을 바꾸는 카드 |
| `payoffCardIds` | string[] | 준비된 덱을 보상하는 카드 |
| `riskCardIds` | string[] | 저주, 계약, 큰 대가를 가진 카드 |
| `strongEnemyRoleProfileIds` | string[] | 강하게 대응하는 적 역할 |
| `weakEnemyRoleProfileIds` | string[] | 약하게 남겨야 하는 적 역할 |
| `partnerSynergyTags` | string[] | 다른 직업과 맞물리는 시너지 |
| `soloProjectionNotes` | string | 솔로 동쪽 전선에서 어떻게 경험되는지 |
| `forbiddenPatterns` | string[] | 만들면 안 되는 패턴 |
| `notes` | string | 설계 의도 |

예시:

```json
{
  "id": "archetype_guardian_thorn_citadel",
  "classId": "class_guardian",
  "nameKo": "가시 성채",
  "runStage": "mvp_030",
  "primaryLaneIds": ["guardian_taunt_anchor", "guardian_thorns_value"],
  "secondaryLaneIds": ["guardian_line_delay"],
  "coreDecisionKo": "맞는 구조물을 피해원으로 바꾸되 수리 효율 저하를 감수할 것인가?",
  "starterCardIds": ["card_guardian_taunt_wall", "card_guardian_thorn_growth"],
  "pivotCardIds": ["card_guardian_reflective_oath", "card_guardian_crack_shield"],
  "payoffCardIds": ["card_guardian_thorn_throne"],
  "riskCardIds": ["card_guardian_heavy_oath"],
  "strongEnemyRoleProfileIds": ["enemy_role_profile_swarm", "enemy_role_profile_breaker"],
  "weakEnemyRoleProfileIds": ["enemy_role_profile_support", "enemy_role_profile_disruptor"],
  "partnerSynergyTags": ["synergy_trigger_taunt_cluster", "synergy_trigger_delayed_repair"],
  "soloProjectionNotes": "동쪽 전선의 짧은 접촉 구간에 군집형과 파괴형을 압축해 가시 가치가 보이게 한다.",
  "forbiddenPatterns": ["infinite_repair_reflect_loop", "ranged_support_auto_answer", "all_damage_from_tanking_only"],
  "notes": "수호자가 직접 광역 딜러가 되지 않으면서 맞는 시간을 피해 가치로 바꾸는 빌드"
}
```

아키타입은 플레이어를 잠그는 직업 특성 트리가 아닙니다.

카드 선택과 상점 구매를 통해 자연스럽게 기울어지는 덱 방향이며, 준비되지 않은 영웅 카드는 거절할 수 있어야 합니다.

## 카드 강화 옵션 데이터

`CardUpgradeOption`은 특정 카드 인스턴스에 적용할 수 있는 영구 강화 후보입니다.

MVP에서는 카드 1장당 강화 1회만 허용하고, 한 카드가 동시에 표시할 수 있는 강화 후보는 최대 2개입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 강화 옵션 ID |
| `cardId` | string | 대상 카드 ID |
| `nameKo` | string | 표시명 |
| `upgradeType` | enum | `stabilize`, `specialize`, `pivot`, `curse_stabilize`, `heroic_tune` |
| `sourceTypes` | enum[] | `shop`, `boss_shop`, `event_contract`, `artifact_unlock` |
| `allowedDayRange` | number[] | 등장 가능 일자 |
| `priceGold` | number/null | 기본 골드 가격 |
| `priceBossShard` | number/null | 보스 파편 가격 |
| `requiredArchetypeIds` | string[] | 이 강화가 의미 있으려면 필요한 아키타입 |
| `requiredSupportCardCount` | number | 확정 조율에 필요한 같은 아키타입 선행 카드 수 |
| `newArchetypeIds` | string[] | 강화 후 추가로 약하게 지원하는 아키타입 |
| `modifiedTimingWindows` | string[] | 강화 후 더 강해지는 타이밍 |
| `effectDelta` | object[] | 바뀌는 효과 |
| `addedTradeoffTags` | string[] | 강화로 추가되는 대가 |
| `reducedTradeoffTags` | string[] | 완화되는 대가 |
| `decisionQuestionKo` | string | 강화 후 새로 물어야 하는 질문 |
| `incompatibleUpgradeIds` | string[] | 같은 카드 인스턴스에 함께 적용할 수 없는 강화 |
| `forbiddenPatterns` | string[] | 만들면 안 되는 결과 |
| `notes` | string | 설계 의도 |

예시:

```json
{
  "id": "upgrade_taunt_wall_wide_taunt",
  "cardId": "card_guardian_taunt_wall",
  "nameKo": "넓은 도발",
  "upgradeType": "specialize",
  "sourceTypes": ["shop", "boss_shop"],
  "allowedDayRange": [10, 100],
  "priceGold": 35,
  "priceBossShard": null,
  "requiredArchetypeIds": ["archetype_guardian_iron_anchor", "archetype_guardian_gate_shift"],
  "requiredSupportCardCount": 0,
  "newArchetypeIds": ["archetype_guardian_gate_shift"],
  "modifiedTimingWindows": ["prebuild", "first_contact"],
  "effectDelta": [
    {"kind": "modify_taunt_radius", "amount": 1},
    {"kind": "modify_incoming_structure_damage_taken", "multiplier": 1.10}
  ],
  "addedTradeoffTags": ["structure_hp_loss"],
  "reducedTradeoffTags": [],
  "decisionQuestionKo": "더 넓게 끌어들이는 대신 이 구조물을 살릴 수 있는가?",
  "incompatibleUpgradeIds": ["upgrade_taunt_wall_sturdy_front"],
  "forbiddenPatterns": ["permanent_full_hold", "no_repair_required", "all_enemies_forced_forever"],
  "notes": "도발 범위를 키우되 수리와 위치 판단 부담을 함께 올린다."
}
```

강화 옵션은 기존 카드의 `decisionQuestionKo`를 삭제하지 않습니다.

좋은 강화는 원래 질문에 새로운 단서를 붙입니다.

나쁜 강화는 질문을 없애고 숫자만 올립니다.

### 카드 강화 옵션 검증 정책

`CardUpgradeOption`은 아래 정책을 통과해야 상점 후보로 들어갈 수 있습니다.

| ID | 적용 대상 | 정책 |
| --- | --- | --- |
| `upgrade_policy_one_axis_change` | 모든 강화 | 안정 강화는 실패 손해, 특화 강화는 강한 타이밍, 전환 강화는 보조 아키타입, 안정화 강화는 대가 형태, 확정 조율은 준비된 빌드 마무리 중 하나를 주로 바꿉니다. |
| `upgrade_policy_no_strict_superior` | 모든 강화 | 비용, 피해, 범위, 지속, 대가가 동시에 좋아지는 순수 상위호환 강화를 금지합니다. |
| `upgrade_policy_two_choice_cap` | 모든 강화 | 한 카드 인스턴스에 동시에 표시되는 강화 후보는 두 개까지만 허용합니다. |
| `upgrade_policy_heroic_requires_build` | 영웅 카드 확정 조율 | `requiredSupportCardCount` 2 이상 또는 동등한 아키타입 조건을 요구합니다. 준비되지 않은 영웅 카드는 거절 선택이 분명해야 합니다. |
| `upgrade_policy_curse_keeps_cost` | 저주 안정화 | 저주의 대가는 제거하지 않고, 예측 가능한 형태나 다른 대가로 바꿉니다. |
| `upgrade_policy_common_low_frequency` | 공용 카드 강화 | 공용 강화는 안정 강화 위주로 제한하고, 직업 전용 역할을 같은 강도로 대체하지 않습니다. |
| `upgrade_policy_no_reward_modifiers` | 모든 강화 | 강화 옵션은 웨이브 겹치기 보상, 카드 후보 수, 희귀도, 처치 보상 총량을 바꾸지 않습니다. |

강화 옵션 데이터 검증 규칙:

- `effectDelta`는 최소 1개, `decisionQuestionKo`는 반드시 있어야 합니다.
- `upgradeType: specialize`는 `addedTradeoffTags` 또는 명확한 조건을 가져야 합니다.
- `upgradeType: pivot`은 `newArchetypeIds`를 가지되, 직업 약점을 삭제하면 안 됩니다.
- `upgradeType: heroic_tune`은 `requiredSupportCardCount` 또는 `requiredArchetypeIds`를 가져야 합니다.
- 공용 카드 강화는 `soft_gap_only` 또는 `information_only` 같은 약한 보완 태그를 유지해야 합니다.

## 직업 카드 풀 계약 데이터

`ClassCardPoolContract`는 직업 카드가 많아질수록 정체성이 흐려지지 않게 잡아주는 기준입니다.

이 데이터는 보상 후보 수나 희귀도를 올리는 장치가 아니라, 카드가 어느 역할 라인을 채우는지 검증하는 장치입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 카드 풀 계약 ID |
| `classId` | string | 대상 직업 ID |
| `poolStage` | enum | `first_010`, `mvp_030`, `full_100` |
| `minimumCardTypeCount` | number | 해당 단계에서 필요한 최소 카드 종류 수 |
| `requiredLaneIds` | string[] | 이 직업이 반드시 유지할 카드 풀 라인 |
| `requiredArchetypeIds` | string[] | 이 단계에서 보여줘야 하는 카드 아키타입 |
| `minimumCardsPerLane` | number | 시작 카드와 보상 카드를 합친 라인별 최소 카드 수 |
| `requiredResponseTags` | string[] | 직업 카드 풀 전체가 열어야 하는 대응 태그 |
| `allowedSoftGapResponseTags` | string[] | 공용 카드가 약하게 보완해도 되는 태그 |
| `forbiddenReplacementResponseTags` | string[] | 공용 카드나 아티팩트가 같은 강도로 대체하면 안 되는 태그 |
| `soloProjectionPolicy` | enum | `use_active_lane_projection` 권장 |
| `rewardProfileIds` | string[] | 이 계약을 참조하는 카드 보상 프로필 |
| `partnerSynergyTags` | string[] | 다른 직업과 맞물리는 시너지 태그 |
| `forbiddenTextTags` | string[] | 카드 설명이나 보상 UI에 쓰면 안 되는 문구 태그 |
| `notes` | string | 설계 의도 |

예시:

```json
{
  "id": "class_card_pool_contract_guardian_mvp_030",
  "classId": "class_guardian",
  "poolStage": "mvp_030",
  "minimumCardTypeCount": 14,
  "requiredLaneIds": [
    "guardian_taunt_anchor",
    "guardian_thorns_value",
    "guardian_line_delay",
    "guardian_boss_hold"
  ],
  "requiredArchetypeIds": [
    "archetype_guardian_iron_anchor",
    "archetype_guardian_thorn_citadel",
    "archetype_guardian_gate_shift"
  ],
  "minimumCardsPerLane": 2,
  "requiredResponseTags": ["taunt_anchor", "sacrifice_value", "repair_window", "focus_fire_mark"],
  "allowedSoftGapResponseTags": ["area_damage", "path_extension", "resource_unjam"],
  "forbiddenReplacementResponseTags": ["taunt_anchor", "repair_window"],
  "soloProjectionPolicy": "use_active_lane_projection",
  "rewardProfileIds": ["reward_profile_first_010_phase_001_core", "reward_profile_first_010_phase_006_boss"],
  "partnerSynergyTags": ["synergy_trigger_taunt_cluster", "synergy_trigger_delayed_repair"],
  "forbiddenTextTags": ["fixed_compass_only", "required_class", "guaranteed_solution"],
  "notes": "수호자는 적을 삭제하는 직업이 아니라 적이 때릴 위치와 시간을 정하는 직업이다."
}
```

## MVP 카드 카탈로그 항목 데이터

`MvpCardCatalogEntry`는 1~30일 MVP에서 카드 한 장이 어떤 경로로 덱에 들어올 수 있는지 고정하는 제작 단위입니다.

이 데이터는 카드 효과 수치를 직접 담는 테이블이 아니라, 시작 덱, 라운드 보상, 보스 개인 보상, 상점, 이벤트 계약이 같은 카드 ID를 서로 다르게 오해하지 않게 만드는 연결 데이터입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 카탈로그 항목 ID |
| `cardId` | string | 실제 카드 ID |
| `classId` | string/null | 직업 전용 카드면 직업 ID, 공용이면 null |
| `catalogRole` | enum | `starter`, `class_round_loot`, `class_heroic_commit`, `class_curse_contract`, `common_soft_gap`, `common_expansion_locked` |
| `rarity` | enum | `common`, `rare`, `heroic`, `curse` |
| `manaCost` | number | 기본 비용 |
| `poolLaneId` | string/null | 직업 카드 풀 라인 |
| `archetypeIds` | string[] | 지원하는 카드 아키타입 |
| `archetypeRole` | enum | `starter`, `signal`, `pivot`, `payoff`, `risk_accelerator`, `patch` |
| `commitmentLevel` | enum | `low`, `medium`, `commit`, `risk` |
| `allowedSourceTypes` | enum[] | `starting_deck`, `round`, `boss_personal`, `shop`, `event_contract`, `artifact_unlock` |
| `allowedDayRange` | number[] | 등장 가능 일자 |
| `starterDeckCopies` | number | 시작 덱에 들어가는 매수, 시작 카드가 아니면 0 |
| `rewardEligible` | boolean | 기본 보상 후보로 들어갈 수 있는지 |
| `requiresExplicitConsent` | boolean | 저주나 위험 계약처럼 확인 UI가 필요한지 |
| `requiresSupportCardCount` | number | 영웅 확정 카드 노출에 필요한 같은 아키타입 선행 카드 수 |
| `maxCopiesInDeck` | number/null | 한 덱에 허용하는 최대 매수 |
| `responseTags` | string[] | 대응 태그 |
| `timingWindows` | string[] | 강한 전투 타이밍 |
| `forbiddenScalingTags` | string[] | 이 카드 노출에 영향을 주면 안 되는 보정 태그 |
| `soloProjectionSafe` | boolean | 솔로 동쪽 전선에서도 죽은 카드가 되지 않는지 |
| `notes` | string | 설계 의도 |

예시:

```json
{
  "id": "mvp_card_catalog_guardian_front_swap",
  "cardId": "card_guardian_front_swap",
  "classId": "class_guardian",
  "catalogRole": "class_round_loot",
  "rarity": "rare",
  "manaCost": 1,
  "poolLaneId": "guardian_taunt_anchor",
  "archetypeIds": ["archetype_guardian_gate_shift"],
  "archetypeRole": "pivot",
  "commitmentLevel": "medium",
  "allowedSourceTypes": ["round", "boss_personal", "shop"],
  "allowedDayRange": [5, 30],
  "starterDeckCopies": 0,
  "rewardEligible": true,
  "requiresExplicitConsent": false,
  "requiresSupportCardCount": 0,
  "maxCopiesInDeck": 2,
  "responseTags": ["taunt_anchor", "rear_rebuild"],
  "timingWindows": ["collapse_aftershock", "boss_commit"],
  "forbiddenScalingTags": ["wave_stack_count", "clear_time", "kill_count", "inactive_direction_pressure"],
  "soloProjectionSafe": true,
  "notes": "고정 방위가 아니라 현재 활성 전선 안에서 도발 구조물을 옮기는 전환 카드다."
}
```

MVP 카드 카탈로그 검증 규칙:

- 각 직업의 `mvp_030` 카탈로그는 시작 카드 6종과 직업 보상 카드 8종을 합쳐 정확히 14종 이상이어야 합니다.
- 시작 덱은 `catalogRole: starter` 카드만 참조하고, 총 10장으로 구성합니다.
- `starterDeckCopies`의 합은 직업별로 10이어야 하며, 고유 시작 카드 수는 6종이어야 합니다.
- 기본 라운드 보상은 `catalogRole: starter` 카드를 직접 복제하지 않고, 시작 행동을 다른 조건으로 여는 보상 카드를 우선합니다.
- `class_heroic_commit` 카드는 21일 이후, `requiresSupportCardCount` 2 이상일 때만 일반 라운드 후보로 밀 수 있습니다.
- `class_curse_contract` 카드는 `requiresExplicitConsent: true`와 `allowedSourceTypes`의 `event_contract` 또는 `shop`을 가져야 합니다.
- `common_soft_gap` 카드는 직업 전용 `poolLaneId`를 갖지 않고, `counterStrength`가 강한 대체 수준이 되면 안 됩니다.
- `common_expansion_locked` 카드는 30일 MVP 일반 라운드 기본 풀에 들어가지 않습니다.
- 모든 직업 전용 카드는 `soloProjectionSafe: true`여야 하며, `fixed_compass_only` 문구를 쓰지 않습니다.
- `forbiddenScalingTags`에는 `wave_stack_count`, `clear_time`, `kill_count`가 반드시 들어갑니다.

## 카드 전리품 풀 데이터

`CardLootPool`은 시작 덱 밖에서 얻을 수 있는 카드 후보 묶음입니다.

이 데이터는 보상량을 늘리는 장치가 아니라, 라운드, 보스, 상점, 이벤트가 어떤 카드 후보를 사용할지 정하는 장치입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 전리품 풀 ID |
| `sourceType` | enum | `round`, `boss_personal`, `shop`, `event_contract`, `meta_unlock` |
| `dayRange` | number[] | 적용 일자 범위 |
| `runModeIds` | string[] | 적용 런 모드 |
| `classId` | string/null | 특정 직업 전용 풀, 공용이면 null |
| `includedCardIds` | string[] | 후보에 들어갈 카드 ID |
| `includedPoolLaneIds` | string[] | 이 풀에서 열 수 있는 카드 풀 라인 |
| `includedArchetypeIds` | string[] | 이 풀에서 열 수 있는 카드 아키타입 |
| `includedResponseTags` | string[] | 이 풀에서 다루는 대응 태그 |
| `rarityProfileId` | string | 적용할 희귀도 프로필 |
| `rarityWeights` | object | 기본 희귀도 가중치 |
| `maxHeroicCandidates` | number | 한 보상 화면에 허용되는 영웅 후보 수 |
| `cursePolicy` | enum | `none`, `explicit_offer_only`, `shop_contract_only`, `event_only` |
| `requiresPlayerConsent` | boolean | 저주나 계약형 카드처럼 명시 동의가 필요한지 |
| `forbiddenScalingTags` | string[] | 이 풀에 영향을 주면 안 되는 보정 태그 |
| `notes` | string | 설계 의도 |

예시:

```json
{
  "id": "loot_pool_round_mvp_021_030_guardian",
  "sourceType": "round",
  "dayRange": [21, 30],
  "runModeIds": ["run_mvp_030", "run_standard_100"],
  "classId": "class_guardian",
  "includedCardIds": [
    "card_guardian_iron_wall",
    "card_guardian_reflective_oath",
    "card_guardian_front_swap",
    "card_guardian_crack_shield",
    "card_guardian_last_guard",
    "card_guardian_thorn_throne",
    "card_guardian_unbroken_gate"
  ],
  "includedPoolLaneIds": [
    "guardian_taunt_anchor",
    "guardian_thorns_value",
    "guardian_line_delay",
    "guardian_boss_hold"
  ],
  "includedArchetypeIds": [
    "archetype_guardian_iron_anchor",
    "archetype_guardian_thorn_citadel",
    "archetype_guardian_gate_shift"
  ],
  "includedResponseTags": ["taunt_anchor", "sacrifice_value", "repair_window", "focus_fire_mark"],
  "rarityProfileId": "rarity_profile_round_021_030",
  "rarityWeights": {"common": 60, "rare": 35, "heroic": 5, "curse": 0},
  "maxHeroicCandidates": 1,
  "cursePolicy": "none",
  "requiresPlayerConsent": false,
  "forbiddenScalingTags": ["wave_stack_count", "clear_time", "kill_count", "accessibility_option", "reconnect_state"],
  "notes": "30일 MVP 후반 수호자 보상 풀. 영웅은 빌드 확정용으로만 낮게 등장한다."
}
```

저주 카드는 일반 라운드 전리품 풀의 `rarityWeights.curse`에 넣지 않습니다.

저주는 이벤트 계약, 특수 상점, 명시된 계약형 선택에서만 `requiresPlayerConsent: true`로 제공합니다.

## 카드 희귀도 프로필 데이터

`CardRarityProfile`은 전리품 후보 3장을 만들 때 쓰는 희귀도 비율입니다.

이 프로필은 플레이 성과 보너스가 아니라 일자, 획득 경로, 런 모드에 따라 고정되는 제작 규칙입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 희귀도 프로필 ID |
| `sourceTypes` | enum[] | 적용 획득 경로 |
| `dayRange` | number[] | 적용 일자 범위 |
| `runModeIds` | string[] | 적용 런 모드 |
| `rarityWeights` | object | `common`, `rare`, `heroic`, `curse` 가중치 |
| `maxHeroicCandidates` | number | 한 보상 화면에 허용되는 영웅 후보 수 |
| `cursePolicy` | enum | `none`, `explicit_offer_only`, `shop_contract_only`, `event_only` |
| `explicitChoiceOnly` | boolean | 가중치 추첨이 아니라 명시 선택 UI를 쓰는지 |
| `forbiddenScalingTags` | string[] | 이 프로필을 바꾸면 안 되는 보정 태그 |
| `notes` | string | 설계 의도 |

예시:

```json
{
  "id": "rarity_profile_round_021_030",
  "sourceTypes": ["round"],
  "dayRange": [21, 30],
  "runModeIds": ["run_mvp_030", "run_standard_100"],
  "rarityWeights": {"common": 60, "rare": 35, "heroic": 5, "curse": 0},
  "maxHeroicCandidates": 1,
  "cursePolicy": "none",
  "explicitChoiceOnly": false,
  "forbiddenScalingTags": ["wave_stack_count", "clear_time", "kill_count", "accessibility_option", "reconnect_state"],
  "notes": "MVP 후반부터 영웅 카드를 낮은 확률로 열어 빌드 확정 선택지를 만든다."
}
```

이벤트 계약이나 특수 상점처럼 저주가 낀 선택지는 `explicitChoiceOnly: true`로 두고, 일반 3장 랜덤 보상과 다른 확인 UI를 사용합니다.

## MVP 전리품 희귀도 잠금 데이터

`MvpLootRarityLock`은 1~30일 MVP에서 어떤 획득 경로가 어떤 희귀도 프로필과 후보 구성 제한을 쓰는지 고정합니다.

이 데이터는 `CardRarityProfile`의 비율을 다시 계산하는 장치가 아니라, 보상 생성기가 사용할 잠금표입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 희귀도 잠금 ID |
| `sourceType` | enum | `round`, `boss_personal`, `shop`, `event_contract` |
| `dayRange` | number[] | 적용 일자 |
| `rarityProfileId` | string | 참조할 `CardRarityProfile.id` |
| `lootPoolIds` | string[] | 후보를 가져올 `CardLootPool.id` |
| `candidateMode` | enum | `three_card_reward`, `shop_slot`, `explicit_contract` |
| `candidateCount` | number/null | 카드 보상 후보 수, 상점/계약형이면 null 가능 |
| `requiredClassCandidateRange` | number[]/null | 3장 보상에서 직업 전용 후보 허용 범위, 상점/계약형이면 null 가능 |
| `maxCommonSoftGapCandidates` | number/null | 공용 보완 후보 최대 수 |
| `maxRareCandidates` | number/null | 후보 화면에 동시에 허용되는 희귀 카드 수 |
| `maxHeroicCandidates` | number/null | 후보 화면에 동시에 허용되는 영웅 카드 수 |
| `heroicGatePolicy` | enum | `blocked`, `requires_two_archetype_support_cards`, `shop_tune_only`, `explicit_contract_only` |
| `cursePolicy` | enum | `none`, `explicit_contract_only`, `shop_contract_only` |
| `fallbackRarity` | enum | 선행 조건 실패 시 내려갈 희귀도 |
| `forbiddenModifierTags` | string[] | 이 잠금표를 바꾸면 안 되는 보정 태그 |
| `notes` | string | 설계 의도 |

예시:

```json
{
  "id": "loot_lock_round_021_030",
  "sourceType": "round",
  "dayRange": [21, 30],
  "rarityProfileId": "rarity_profile_round_021_030",
  "lootPoolIds": [
    "loot_pool_round_mvp_021_030_class",
    "loot_pool_common_soft_gap_mvp"
  ],
  "candidateMode": "three_card_reward",
  "candidateCount": 3,
  "requiredClassCandidateRange": [2, 3],
  "maxCommonSoftGapCandidates": 1,
  "maxRareCandidates": 2,
  "maxHeroicCandidates": 1,
  "heroicGatePolicy": "requires_two_archetype_support_cards",
  "cursePolicy": "none",
  "fallbackRarity": "rare",
  "forbiddenModifierTags": [
    "wave_stack_count",
    "clear_time",
    "kill_count",
    "boss_part_break_count",
    "inactive_direction_pressure",
    "accessibility_option",
    "reconnect_state"
  ],
  "notes": "21~30일 일반 라운드 보상은 낮은 영웅 비율을 사용하지만, 준비되지 않은 덱에는 같은 역할의 희귀 후보로 내려간다."
}
```

MVP 잠금표:

| ID | 경로 | 일자 | 프로필 | 후보 방식 | 주요 제한 |
| --- | --- | --- | --- | --- | --- |
| `loot_lock_round_001_004` | 일반 라운드 | 1~4일 | `rarity_profile_round_001_004` | 3장 보상 | 희귀 최대 1장, 영웅/저주 없음 |
| `loot_lock_round_005_010` | 일반 라운드 | 5~10일 | `rarity_profile_round_005_010` | 3장 보상 | 희귀 최대 1장, 첫 보스 준비 |
| `loot_lock_round_011_020` | 일반 라운드 | 11~20일 | `rarity_profile_round_011_020` | 3장 보상 | 희귀 최대 2장, 영웅/저주 없음 |
| `loot_lock_round_021_030` | 일반 라운드 | 21~30일 | `rarity_profile_round_021_030` | 3장 보상 | 영웅 최대 1장, 선행 2장 필요 |
| `loot_lock_boss_010` | 보스 개인 | 10일 | `rarity_profile_boss_personal_010` | 3장 보상 | 보스 역할 태그 편향, 성과 보정 없음 |
| `loot_lock_boss_020` | 보스 개인 | 20일 | `rarity_profile_boss_personal_020` | 3장 보상 | 변형 보스 실패 태그 회수, 영웅 게이트 |
| `loot_lock_boss_030` | 보스 개인 | 30일 | `rarity_profile_boss_personal_030` | 3장 보상 | MVP 덱 확정 질문, 영웅 게이트 |
| `loot_lock_shop_card_005` | 상점 | 5일 | `rarity_profile_shop_card_005` | 상점 슬롯 | 낮은 비용 카드, 영웅/저주 없음 |
| `loot_lock_shop_card_010_015` | 상점 | 10~15일 | `rarity_profile_shop_card_010_015` | 상점 슬롯 | 일반/희귀 카드만 판매 |
| `loot_lock_shop_card_020_030` | 상점 | 20~30일 | `rarity_profile_shop_card_020_030` | 상점 슬롯 | 영웅 랜덤 판매 없음, `shop_heroic_tune`으로 분리 |
| `loot_lock_event_contract_mvp` | 이벤트 계약 | 1~30일 | `rarity_profile_event_contract_mvp` | 명시 계약 | 저주와 특수 카드는 확인 UI 필요 |

### MVP 보상/상점/이벤트 일자 시뮬레이션 데이터

`MvpRewardShopEventDay`는 1~30일 MVP에서 각 일자가 어떤 보상 잠금, 이벤트 계약, 상점 세션을 실행하는지 한 행으로 묶는 데이터입니다.

이 데이터는 보상을 계산하는 장치가 아니라, 이미 정의된 잠금표를 실행 순서에 배치하는 계약입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `day` | number | 1~30 사이의 일자 |
| `dayKind` | enum | `normal`, `boss`, `transition` |
| `primaryRewardLockId` | string | 일반 또는 보스 개인 카드 보상 잠금 ID |
| `artifactPoolId` | string/null | 보스 후 아티팩트 후보 풀 |
| `eventContractLockId` | string/null | 후속 이벤트 계약 잠금 ID |
| `shopSessionLockId` | string/null | 후속 상점 잠금 ID |
| `rewardOrder` | string[] | 전투 종료 후 화면 순서 |
| `expectedDeckPressureBand` | number[] | 해당 일자 종료 후 기대 덱 장수 범위 |
| `heroicGatePolicy` | enum | `blocked`, `requires_two_archetype_support_cards`, `shop_tune_only` |
| `curseEntryPolicy` | enum | `blocked`, `explicit_event_contract_only`, `owned_curse_service_only` |
| `waveStackHandling` | enum | `separate_reward_packets`, `not_stackable`, `result_only` |
| `forbiddenModifierTags` | string[] | 이 일자에서 절대 참조하지 않을 보정 태그 |
| `notes` | string | 설계 의도 |

예시:

```json
{
  "day": 25,
  "dayKind": "transition",
  "primaryRewardLockId": "loot_lock_round_021_030",
  "artifactPoolId": null,
  "eventContractLockId": "event_contract_lock_mvp_025",
  "shopSessionLockId": "mvp_shop_lock_day_025",
  "rewardOrder": [
    "round_summary",
    "personal_card_reward",
    "season_transition_event",
    "small_shop",
    "next_pressure_preview"
  ],
  "expectedDeckPressureBand": [20, 26],
  "heroicGatePolicy": "requires_two_archetype_support_cards",
  "curseEntryPolicy": "owned_curse_service_only",
  "waveStackHandling": "separate_reward_packets",
  "forbiddenModifierTags": [
    "wave_stack_reward_bonus",
    "increase_card_reward_choices",
    "increase_card_rarity",
    "boss_tier_reward",
    "inactive_direction_pressure"
  ],
  "notes": "25일은 계절 전환 정비일이지만 보스일이 아니므로 후반 일반 라운드 보상 잠금만 사용한다."
}
```

MVP 일자 시뮬레이션 잠금:

| 일자 | 종류 | 보상 잠금 | 아티팩트 | 이벤트 | 상점 | 덱 압박 |
| ---: | --- | --- | --- | --- | --- | --- |
| 1~4 | `normal` | `loot_lock_round_001_004` | 없음 | 없음 | 없음 | 11~14장 |
| 5 | `normal` | `loot_lock_round_005_010` | 없음 | 없음 | `mvp_shop_lock_day_005` | 13~15장 |
| 6~9 | `normal` | `loot_lock_round_005_010` | 없음 | 없음 | 없음 | 14~18장 |
| 10 | `boss` | `loot_lock_boss_010` | `artifact_pool_foundation_010` | 없음 | `mvp_shop_lock_day_010` | 15~19장 |
| 11~14 | `normal` | `loot_lock_round_011_020` | 없음 | 없음 | 없음 | 16~21장 |
| 15 | `transition` | `loot_lock_round_011_020` | 없음 | `event_contract_lock_mvp_015` | `mvp_shop_lock_day_015` | 17~22장 |
| 16~19 | `normal` | `loot_lock_round_011_020` | 없음 | 없음 | 없음 | 18~23장 |
| 20 | `boss` | `loot_lock_boss_020` | `artifact_pool_branch_020` | 없음 | `mvp_shop_lock_day_020` | 19~24장 |
| 21~24 | `normal` | `loot_lock_round_021_030` | 없음 | 없음 | 없음 | 20~25장 |
| 25 | `transition` | `loot_lock_round_021_030` | 없음 | `event_contract_lock_mvp_025` | `mvp_shop_lock_day_025` | 20~26장 |
| 26~29 | `normal` | `loot_lock_round_021_030` | 없음 | 없음 | 없음 | 21~27장 |
| 30 | `boss` | `loot_lock_boss_030` | `artifact_pool_mvp_result_030` | 없음 | `mvp_shop_lock_day_030` | 21~28장 |

## 카드 보상 프로필 데이터

카드 보상은 매일 3장 중 1장 규칙을 유지합니다.

보상 프로필은 후보를 더 많이 주거나 희귀도를 올리는 데이터가 아니라, 현재 일자와 직업, 방금 겪은 문제 태그에 맞는 후보 풀을 고르는 필터입니다.

### 보상 프로필 필드

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 보상 프로필 ID |
| `dayRange` | number[] | 적용 일자 범위 |
| `phaseIndex` | number | 첫 10일 덱 성장 구간 태그 |
| `lootPoolIds` | string[] | 후보를 가져올 카드 전리품 풀 |
| `allowedRarities` | string[] | 허용 희귀도 |
| `preferredRoleTags` | string[] | 우선 후보 역할 태그 |
| `preferredResponseTags` | string[] | 이번 보상에서 우선 보여줄 대응 태그 |
| `preferredArchetypeIds` | string[] | 이번 보상에서 자연스럽게 보여줄 아키타입 |
| `classBiasTags` | object | 직업별로 조금 더 자주 볼 태그 |
| `observedNeedTags` | string[] | 방금 전투에서 관찰한 약점 태그 |
| `nextWaveIntentIds` | string[] | 다음 구간에서 다시 물을 웨이브 의도 |
| `nextEnemyRoleProfileIds` | string[] | 다음 구간에서 압박할 적 역할 프로필 |
| `candidateCount` | number | 항상 3 |
| `allowGoldDecline` | boolean | 카드 대신 골드 선택 가능 여부 |
| `maxSameRoleCandidates` | number | 같은 역할 후보가 한 화면에 나올 수 있는 최대 수 |
| `maxSameResponseTagCandidates` | number | 같은 대응 태그 후보가 한 화면에 나올 수 있는 최대 수 |
| `maxSamePoolLaneCandidates` | number | 같은 카드 풀 라인 후보가 한 화면에 나올 수 있는 최대 수 |
| `maxSameArchetypeCandidates` | number | 같은 아키타입 후보가 한 화면에 나올 수 있는 최대 수 |
| `heroicCommitPolicy` | enum | `blocked`, `requires_two_support_cards`, `allowed` |
| `forbiddenTags` | string[] | 이 구간에서 제외할 태그 |
| `excludedResponseTags` | string[] | 이 구간에서 제외할 대응 태그 |
| `notes` | string | 설계 의도 |

예시:

```json
{
  "id": "reward_profile_first_010_phase_004_collapse",
  "dayRange": [6, 7],
  "phaseIndex": 4,
  "lootPoolIds": ["loot_pool_round_first_005_010_class", "loot_pool_common_soft_gap_mvp"],
  "allowedRarities": ["common", "rare"],
  "preferredRoleTags": ["repair", "debris", "planned_collapse", "rebuild"],
  "preferredResponseTags": ["repair_window", "sacrifice_value", "rear_rebuild"],
  "preferredArchetypeIds": [
    "archetype_architect_planned_demolition",
    "archetype_architect_rear_rebuild",
    "archetype_tinkerer_emergency_maintenance"
  ],
  "classBiasTags": {
    "class_guardian": ["taunt", "thorns", "damage_delay"],
    "class_architect": ["barrier", "debris", "salvage"],
    "class_elementalist": ["area_damage", "slow", "vulnerable"],
    "class_tinkerer": ["repair", "aura", "overdrive"]
  },
  "observedNeedTags": ["structure_destroyed", "line_collapsed"],
  "nextWaveIntentIds": ["intent_planned_structure_break", "intent_relocation_after_loss"],
  "nextEnemyRoleProfileIds": ["enemy_role_profile_breaker", "enemy_role_profile_pressure"],
  "candidateCount": 3,
  "allowGoldDecline": true,
  "maxSameRoleCandidates": 2,
  "maxSameResponseTagCandidates": 1,
  "maxSamePoolLaneCandidates": 1,
  "maxSameArchetypeCandidates": 2,
  "heroicCommitPolicy": "blocked",
  "forbiddenTags": ["heroic_build_start", "curse_forced", "wave_stack_reward", "complete_path_block"],
  "excludedResponseTags": ["resource_unjam", "focus_fire_mark"],
  "notes": "첫 파괴형 이후 구조물 손실을 전술 선택으로 읽게 만드는 보상"
}
```

### 첫 10일 보상 처리 규칙

1. `candidateCount`는 3으로 고정합니다.
2. 웨이브 겹치기 횟수는 `allowedRarities`, `candidateCount`, `preferredRoleTags`를 바꾸지 않습니다.
3. 같은 보상 화면에서 같은 역할 태그 후보는 2장을 넘지 않습니다.
4. 같은 보상 화면에서 같은 대응 태그 후보는 1장을 기본값으로 둡니다.
5. 같은 보상 화면에서 같은 카드 풀 라인 후보는 1장을 기본값으로 둡니다.
6. 같은 보상 화면에서 같은 아키타입 후보는 2장을 넘지 않습니다.
7. 직업 전용 후보가 최소 1장, 공용 보완 후보가 최대 1장 보이도록 우선합니다.
8. 첫 10일에는 저주 후보를 이벤트 선택 없이 일반 보상에 넣지 않습니다.
9. 첫 10일에는 영웅 확정 카드를 일반 보상에 넣지 않습니다.
10. 10일 보스 직전 보상은 보스 부위 집중이나 지연을 도와도, 보스 본체를 장시간 정지시키면 안 됩니다.

## 구조물 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 구조물 ID |
| `nameKo` | string | 표시명 |
| `hp` | number | 기본 체력 |
| `armor` | number | 피해 감소 |
| `attackDamage` | number | 공격력 |
| `attackRate` | number | 초당 공격 횟수 |
| `range` | number | 타일 기준 사거리 |
| `blocksPath` | boolean | 경로 비용에 영향 주는지 |
| `canPlaceOnPath` | boolean | 경로 타일 배치 가능 여부 |
| `onDestroyed` | object[] | 파괴 시 효과 |
| `aura` | object/null | 오라 효과 |
| `structureRoleTags` | string[] | 구조물의 기본 전술 역할 |
| `repairProfileId` | string/null | 수리 효율과 제한 프로필 |
| `destroyValueProfileId` | string/null | 파괴 시 전술 가치 프로필 |
| `rebuildPolicyId` | string/null | 같은 위치 재건 제한과 보정 |
| `riskFeedbackTags` | string[] | 표식, 과열, 결빙, 압력 UI 표시 태그 |

구조물 예시:

```json
{
  "id": "structure_explosive_barricade",
  "nameKo": "폭발 바리케이드",
  "hp": 8,
  "armor": 0,
  "attackDamage": 0,
  "attackRate": 0,
  "range": 0,
  "blocksPath": true,
  "canPlaceOnPath": false,
  "onDestroyed": [
    {
      "kind": "area_damage",
      "radius": 2,
      "damage": 5
    }
  ],
  "aura": null,
  "structureRoleTags": ["path_bend", "planned_collapse"],
  "repairProfileId": "repair_profile_basic_structure",
  "destroyValueProfileId": "destroy_value_explosive_debris",
  "rebuildPolicyId": "rebuild_policy_same_tile_soft_penalty",
  "riskFeedbackTags": ["marked_if_low_hp", "good_sacrifice_candidate"]
}
```

## 구조물 생애주기 프로필 데이터

구조물 생애주기 프로필은 수리, 파괴 가치, 재건 제한을 같은 기준으로 관리합니다.

### 수리 프로필

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 수리 프로필 ID |
| `baseRepairMultiplier` | number | 기본 수리 효율 |
| `overheatedMultiplier` | number | 과열 권역 수리 효율 |
| `frozenMultiplier` | number | 결빙 권역 수리 효율 |
| `pressureMultiplier` | number | 보스 압력 권역 수리 효율 |
| `maxEmergencyRepairsPerWave` | number | 한 웨이브 안 긴급 복구성 수리 기준 |
| `uiFeedbackTag` | string | 수리 감소 UI 태그 |

### 파괴 가치 프로필

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 파괴 가치 프로필 ID |
| `leavesDebris` | boolean | 잔해 생성 여부 |
| `debrisDurationSeconds` | number | 잔해 지속 시간 |
| `onDestroyTags` | string[] | 폭발, 둔화, 가시, 회수 등 파괴 효과 태그 |
| `salvageLimitWindowSeconds` | number | 회수 반복 제한 시간 |
| `maxSalvageTriggersPerWindow` | number | 제한 시간 안 회수 허용 횟수 |

### 재건 정책

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 재건 정책 ID |
| `sameTilePenaltyWindowSeconds` | number | 같은 타일 재건 페널티 시간 |
| `sameTileHpMultiplier` | number | 같은 타일 빠른 재건 시 체력 보정 |
| `blockedInPressureZones` | boolean | 압력 권역 안 재건 금지 여부 |
| `previewWarningTag` | string | 재건 미리보기 경고 태그 |

## EnemyRoleProfile 데이터

`EnemyRoleProfile`은 적 개체가 아니라 적 역할의 제작 규칙입니다.

같은 역할을 가진 적이 여러 종류여도, 어떤 `WaveIntent`에 쓰이는지, 어떤 예고가 필요한지, 어떤 대응을 허용해야 하는지는 이 프로필에서 먼저 정의합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 적 역할 프로필 ID |
| `enemyType` | enum | `swarm`, `runner`, `breaker`, `resistant`, `disruptor`, `elite`, `pressure`, `support` |
| `intentAffinityIds` | string[] | 잘 맞는 `WaveIntent.id` 목록 |
| `primaryQuestionTags` | string[] | 이 역할이 강하게 던지는 질문 |
| `requiredWarningTags` | string[] | 전투 전 또는 등장 직전 반드시 보여야 하는 예고 |
| `minimumCounterTags` | string[] | 적어도 하나 이상 열려 있어야 하는 대응 태그 |
| `softCounterTags` | string[] | 특정 직업 없이도 가능한 보조 대응 |
| `counterWindowSeconds` | number | 예고 후 플레이어가 대응을 고를 수 있어야 하는 최소 시간 |
| `overloadPairTags` | string[] | 동시에 강하게 쓰면 과부하가 되는 역할 조합 |
| `soloStrongQuestionLimit` | number | 1인 웨이브에서 이 역할이 강한 질문으로 들어갈 수 있는 최대 개수 |
| `failureHintTags` | string[] | 실패 리포트와 도감 재방문에 연결할 태그 |

예시:

```json
{
  "id": "enemy_role_profile_breaker",
  "enemyType": "breaker",
  "intentAffinityIds": ["intent_planned_structure_break", "intent_relocation_after_loss"],
  "primaryQuestionTags": ["planned_collapse", "repair_or_abandon"],
  "requiredWarningTags": ["marked_structure", "incoming_structure_hit"],
  "minimumCounterTags": ["repair", "sacrifice_structure", "taunt", "burst_damage", "path_extension"],
  "softCounterTags": ["slow", "temporary_barricade", "rear_rebuild"],
  "counterWindowSeconds": 4,
  "overloadPairTags": ["runner_burst", "resource_disruption"],
  "soloStrongQuestionLimit": 1,
  "failureHintTags": ["structure_marked_missed", "repair_or_sacrifice_needed"]
}
```

## 적 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 적 ID |
| `nameKo` | string | 표시명 |
| `enemyType` | enum | `swarm`, `runner`, `breaker`, `resistant`, `disruptor`, `elite`, `pressure`, `support` |
| `enemyRoleProfileId` | string | 연결된 적 역할 프로필 ID |
| `hp` | number | 체력 |
| `speed` | number | 기본 속도 배율 |
| `structureDamage` | number | 구조물 1회 공격 피해 |
| `structureAttackIntervalSeconds` | number | 구조물 공격 간격 |
| `baseDamage` | number | 기지 피해 |
| `threatCost` | number | 웨이브 위험도 비용 |
| `resourceTier` | enum | `weak`, `normal`, `danger`, `elite`, `boss_part` |
| `resistances` | object | 상태이상 저항 |
| `statusResistanceProfileId` | string | 상태이상 저항 프로필 ID |
| `statusFeedbackTags` | string[] | 저항/약화 UI에 표시할 태그 |
| `behavior` | object | AI 행동 |
| `roleQuestionTags` | string[] | 이 적이 던지는 판단 질문 |
| `intentAffinityIds` | string[] | 이 적을 넣기 좋은 `WaveIntent.id` 목록 |
| `primaryResponseTags` | string[] | 가장 자연스러운 대응 방식 |
| `softCounterTags` | string[] | 직업이 없어도 가능한 보조 대응 |
| `requiredWarningTags` | string[] | 예고 UI에 반드시 포함할 위험 태그 |
| `counterWindowSeconds` | number | 대응 판단을 보장해야 하는 최소 시간 |
| `forbiddenPairTags` | string[] | 같이 배치하면 과부하가 되기 쉬운 조합 태그 |

예시:

```json
{
  "id": "enemy_crack_hammer",
  "nameKo": "균열 망치",
  "enemyType": "breaker",
  "enemyRoleProfileId": "enemy_role_profile_breaker",
  "hp": 8,
  "speed": 0.8,
  "structureDamage": 3,
  "structureAttackIntervalSeconds": 1.8,
  "baseDamage": 2,
  "threatCost": 3,
  "resourceTier": "danger",
  "statusResistanceProfileId": "status_profile_breaker_normal",
  "resistances": {
    "slow": 0,
    "freeze": 0,
    "knockback": 0,
    "taunt": 0,
    "silence": 0
  },
  "statusFeedbackTags": ["normal_cc_response"],
  "behavior": {
    "priority": "nearest_structure",
    "canBreakStructures": true
  },
  "roleQuestionTags": ["structure_break", "planned_collapse"],
  "intentAffinityIds": ["intent_planned_structure_break", "intent_relocation_after_loss"],
  "primaryResponseTags": ["maze", "repair", "taunt"],
  "softCounterTags": ["burst_damage", "slow", "path_extension"],
  "requiredWarningTags": ["marked_structure", "incoming_structure_hit"],
  "counterWindowSeconds": 4,
  "forbiddenPairTags": ["unwarned_breaker", "random_structure_delete"]
}
```

## 상태이상 저항 프로필 데이터

상태이상 저항 프로필은 적이 CC를 얼마나 약하게 받는지 정의합니다.

완전 면역보다 부분 저항과 변환 효과를 기본으로 둡니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 프로필 ID |
| `targetGrade` | enum | `normal`, `danger`, `elite`, `boss_part`, `boss_body` |
| `slowMultiplier` | number | 둔화 효과 배율 |
| `freezeDurationMultiplier` | number | 빙결 정지 시간 배율 |
| `freezeConvertToSlow` | boolean | 빙결을 정지 대신 감속으로 바꾸는지 |
| `knockbackDistanceMultiplier` | number | 넉백 거리 배율 |
| `tauntDurationMultiplier` | number | 도발 지속 배율 |
| `disruptionMultiplier` | number | 침묵/방해 효과를 받는 배율 |
| `diminishingReturnWindowSeconds` | number | 반복 감소 유지 시간 |
| `uiFeedbackTag` | string | UI 표시 태그 |

예시:

```json
{
  "id": "status_profile_elite_heavy",
  "targetGrade": "elite",
  "slowMultiplier": 0.45,
  "freezeDurationMultiplier": 0.25,
  "freezeConvertToSlow": false,
  "knockbackDistanceMultiplier": 0.25,
  "tauntDurationMultiplier": 0.50,
  "disruptionMultiplier": 0.70,
  "diminishingReturnWindowSeconds": 5,
  "uiFeedbackTag": "cc_reduced_elite"
}
```

보스 본체 예시:

```json
{
  "id": "status_profile_boss_silent_colossus_body",
  "targetGrade": "boss_body",
  "slowMultiplier": 0.20,
  "freezeDurationMultiplier": 0,
  "freezeConvertToSlow": true,
  "knockbackDistanceMultiplier": 0.05,
  "tauntDurationMultiplier": 0,
  "disruptionMultiplier": 0.30,
  "diminishingReturnWindowSeconds": 5,
  "uiFeedbackTag": "cc_converted_boss"
}
```

## WaveIntent 데이터

`WaveIntent`는 웨이브가 플레이어에게 묻는 전투 질문입니다.

방향, 적 수량, 실제 스폰 타이밍은 `WaveIntent`가 아니라 `WaveData`와 `WaveSpawnPlan`에서 확정합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 웨이브 의도 ID |
| `questionTag` | string | 핵심 질문 태그 |
| `primaryPressureTag` | string | 가장 강하게 들어가는 압박 |
| `allowedSecondaryTags` | string[] | 함께 섞을 수 있는 보조 압박 |
| `forbiddenMixTags` | string[] | 동시에 섞으면 과부하가 되는 압박 |
| `expectedResponseTags` | string[] | 플레이어가 사용할 수 있어야 하는 대응 |
| `failureHintTags` | string[] | 실패 리포트, 재도전 힌트, 튜토리얼 재방문에 쓰는 태그 |
| `soloProjectionHint` | string | 1인 동쪽 전선에서 이 의도를 표현하는 힌트 |
| `multiProjectionHint` | string | 2~4인 활성 방향 안에서 이 의도를 표현하는 힌트 |
| `authoringNotes` | string | 제작자가 확인할 주의점 |

예시:

```json
{
  "id": "intent_fast_response",
  "questionTag": "fast_response",
  "primaryPressureTag": "runner_burst",
  "allowedSecondaryTags": ["light_swarm", "route_read"],
  "forbiddenMixTags": ["resource_disruption", "unwarned_structure_break"],
  "expectedResponseTags": ["slow", "knockback", "short_line_reinforce", "priority_target"],
  "failureHintTags": ["fast_enemy_leaked", "short_path_unreinforced"],
  "soloProjectionHint": "east_short_side_path",
  "multiProjectionHint": "prefer_fast_active_direction_else_timing_substitute",
  "authoringNotes": "솔로에서도 동쪽 샛길과 스폰 타이밍만으로 빠른 적 대응 질문이 살아야 한다."
}
```

## ChapterIntentPlan 데이터

`ChapterIntentPlan`은 10일 챕터가 어떤 `WaveIntent`를 새로 강하게 묻고, 어떤 의도를 다시 확인할지 정의합니다.

개별 웨이브는 이 계획을 참고하되, 실제 압박 강도와 스폰 방향은 `WaveData`와 `WaveSpawnPlan`에서 확정합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 챕터 의도 계획 ID |
| `dayRange` | string | 적용 일자 범위 |
| `chapterFlowId` | string | 연결되는 챕터 운영 흐름 ID |
| `primaryWaveIntentIds` | string[] | 이 챕터에서 새로 강하게 묻는 의도 |
| `recallWaveIntentIds` | string[] | 이전에 배운 것을 다시 묻는 의도 |
| `bossReviewIntentIds` | string[] | 챕터 보스가 회수해야 하는 의도 |
| `forbiddenNewIntentIds` | string[] | 이 챕터에서 새로 추가하면 안 되는 의도 |
| `soloProjectionRequired` | boolean | 1인 동쪽 투영 검증이 필수인지 |
| `multiplayerDistributionNote` | string | 2~4인에서 의도를 어떻게 나눌지에 대한 제작 메모 |

예시:

```json
{
  "id": "chapter_intent_plan_081_090",
  "dayRange": "81-90",
  "chapterFlowId": "winter2_pressure_flow_081_090",
  "primaryWaveIntentIds": ["intent_relocation_after_loss", "intent_final_focus"],
  "recallWaveIntentIds": ["intent_secondary_killzone", "intent_priority_target"],
  "bossReviewIntentIds": ["intent_relocation_after_loss", "intent_final_focus"],
  "forbiddenNewIntentIds": ["intent_new_system_teach"],
  "soloProjectionRequired": true,
  "multiplayerDistributionNote": "압력 권역은 활성 방향 안에서만 순차 이동하고, 4인도 사방 동시 최대 압박을 기본값으로 쓰지 않는다."
}
```

## 웨이브 데이터

웨이브 데이터는 보상 배율을 가지지 않습니다.

웨이브 겹치기는 여러 웨이브를 시간적으로 겹치는 기능이지, 웨이브 보상을 바꾸는 기능이 아닙니다.

웨이브 데이터는 방향별 콘텐츠가 아니라 `WaveIntent`와 `LaneProjection`으로 나눠 생각합니다.

`WaveIntent`는 이 웨이브가 묻는 전투 질문이고, `LaneProjection`은 그 질문을 현재 인원수의 활성 방향 안에 배치하는 규칙입니다.

솔로는 동쪽만 사용하지만 모든 핵심 `WaveIntent`를 경험해야 합니다. 멀티플레이는 새 의도를 해금하는 것이 아니라 같은 의도를 여러 전선에 나누어 처리하게 만듭니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 웨이브 ID |
| `day` | number | 등장 일자 |
| `season` | enum | `spring`, `summer`, `autumn`, `winter` |
| `waveIntentId` | string | 이 웨이브가 묻는 전투 질문 ID |
| `primaryQuestionTag` | string | 가장 강하게 묻는 질문 태그 |
| `secondaryQuestionTag` | string/null | 보조로 섞는 질문 태그 |
| `preferredDirections` | string[] | 제작자가 의도한 선호 방향 |
| `directionRole` | enum/null | `fast`, `slow`, `killzone`, `short`, `any` |
| `laneProjectionRules` | object/null | 인원수별 실제 방향, 경로 성격, 스폰 타이밍 대체 규칙 |
| `enemyGroups` | object[] | 적 묶음 |
| `threatBudget` | number | 위험도 예산 |
| `roleQuestionBudget` | number | 이 웨이브가 동시에 던지는 강한 질문 수 |
| `roleMixTags` | string[] | 웨이브에 섞인 적 역할 질문 |
| `expectedResponseTags` | string[] | 플레이어가 사용할 수 있어야 하는 대응 태그 |
| `learningPhaseIndex` | number/null | 첫 10일 학습 압박 구간 태그 |
| `chapterPhaseIndex` | number/null | 10일 챕터 안 운영 압박 구간 태그 |
| `chapterFlowId` | string/null | 해당 웨이브가 속한 챕터 운영 흐름 ID |
| `maxDirectionsByPlayerCount` | object/null | 인원수별 허용 실제 방향 수 |
| `classResponseChecks` | object/null | 직업별 관찰하고 싶은 대응 태그 |
| `forbiddenRoleMixTags` | string[] | 이 웨이브에서 함께 쓰면 안 되는 압박 태그 |
| `failureHintTags` | string[] | 실패 리포트와 튜토리얼 재방문에 연결할 태그 |
| `warnings` | string[] | 예고 UI에 표시할 경고 |
| `isBossWave` | boolean | 보스 웨이브 여부 |

원본 웨이브 데이터는 선호 방향을 가질 수 있습니다.

하지만 실제 전투에 사용하는 방향은 아래 `WaveSpawnPlan`에서 확정합니다.

예시:

```json
{
  "id": "wave_day_006_breaker_intro",
  "day": 6,
  "season": "spring",
  "waveIntentId": "intent_planned_structure_break",
  "primaryQuestionTag": "planned_collapse",
  "secondaryQuestionTag": "swarm_clear",
  "preferredDirections": ["east"],
  "directionRole": "short",
  "laneProjectionRules": {
    "1": {"directions": ["east"], "routeProfile": "east_main_structure_target"},
    "2": {"directions": ["east"], "routeProfile": "east_short_pressure"},
    "3": {"directions": ["east"], "routeProfile": "east_short_pressure"},
    "4": {"directions": ["east"], "routeProfile": "east_short_pressure"}
  },
  "enemyGroups": [
    {"enemyId": "enemy_gray_march", "count": 12, "spawnDelay": 0.6},
    {"enemyId": "enemy_crack_hammer", "count": 2, "spawnDelay": 4.0}
  ],
  "threatBudget": 18,
  "roleQuestionBudget": 2,
  "roleMixTags": ["swarm_clear", "structure_break"],
  "expectedResponseTags": ["area_damage", "planned_collapse", "repair", "taunt"],
  "learningPhaseIndex": 4,
  "maxDirectionsByPlayerCount": {"1": 1, "2": 1, "3": 1, "4": 1},
  "classResponseChecks": {
    "class_guardian": ["taunt_breaker", "thorns_value"],
    "class_architect": ["planned_collapse", "debris_value"],
    "class_elementalist": ["focus_breaker", "area_after_collapse"],
    "class_tinkerer": ["remote_repair", "save_or_abandon"]
  },
  "forbiddenRoleMixTags": ["runner_burst", "unwarned_disruptor"],
  "failureHintTags": ["structure_marked_missed", "repair_or_sacrifice_needed"],
  "warnings": ["파괴형 적 등장", "구조물 체력 주의"],
  "isBossWave": false
}
```

### 첫 10일 웨이브 레시피 데이터

첫 10일 웨이브는 `learningPhaseIndex`를 반드시 가집니다.

이 값은 난이도를 직접 바꾸지 않고, 예고 UI, 패배 분석, 보상 프로필, 플레이테스트 집계를 같은 학습 단계로 묶기 위한 태그입니다.

| 일자 | `learningPhaseIndex` | 강한 질문 | `maxDirectionsByPlayerCount` 기본값 |
| ---: | ---: | --- | --- |
| 1 | 1 | 경로 읽기 | 1/1/1/1 |
| 2 | 1 | 경로 늘리기 | 1/1/1/1 |
| 3 | 2 | 빠른 적 대응 | 1/1/1/1 |
| 4 | 2 | 군집과 빠른 적 구분 | 1/1/1/1 |
| 5 | 3 | 정비 연결 | 1/1/1/1 |
| 6 | 4 | 파괴 예고 | 1/1/1/1 |
| 7 | 4 | 잔해 활용 | 1/2/2/2 |
| 8 | 5 | 겹치기 판단 | 1/1/1/1 |
| 9 | 5 | 우선 처치 | 1/2/2/2 |
| 10 | 6 | 첫 보스 부위 | 1/2/2/2 |

표의 `1/2/2/2`는 1인, 2인, 3인, 4인 순서입니다.

실제 `directions`는 여전히 `activeDirections`의 부분집합이어야 합니다.

1인은 어떤 일자에서도 동쪽 외 일반 웨이브를 만들지 않습니다.

첫 10일 데이터는 다음 태그를 금지합니다.

- `three_direction_pressure`
- `four_direction_pressure`
- `unwarned_breaker`
- `heavy_disruptor`
- `forced_curse`
- `stack_reward_bonus`

### 11~20일 운영 흐름 데이터

11~20일 웨이브는 `chapterFlowId: "spring2_operation_flow_011_020"`를 가집니다.

`chapterPhaseIndex`는 난이도 배율이 아니라, 보상 체감, 우선순위, 상점 선택, 방향 분담, 겹치기 판단, 변형 보스를 같은 운영 흐름으로 묶는 태그입니다.

| 일자 | `chapterPhaseIndex` | 운영 질문 | 기본 제한 |
| ---: | ---: | --- | --- |
| 11 | 1 | 첫 보상 선택이 유리 껍질 대응에 의미 있는가? | 새 보상 무력화 금지 |
| 12 | 1 | 성장 체감이 실제 전투에서 느껴지는가? | 공짜 파밍 보상 증가 금지 |
| 13 | 2 | 침묵 운반자를 우선 처치하는가? | 예고 없는 방해형 대량 금지 |
| 14 | 2 | 빠른 적과 저항형에 화력을 나누는가? | 광역 완전 무효 적 금지 |
| 15 | 3 | 강점 강화와 약점 보완 중 하나를 고르는가? | 상점 항목 과다 금지 |
| 16 | 4 | 2방향 압박에서 역할 분담이 되는가? | 인원수별 비활성 방향 스폰 금지 |
| 17 | 4 | 강화 구조물과 버릴 구조물을 구분하는가? | 자동 복구 정답화 금지 |
| 18 | 5 | 겹치기 안정 상태를 판단하는가? | 겹치기 보상 증가 금지 |
| 19 | 5 | 21일 정예 압박을 예고로 읽는가? | 강한 정예 본격 투입 금지 |
| 20 | 6 | 첫 보스 학습을 변형에 적용하는가? | 새 부위/새 패턴/강한 동반 웨이브 동시 추가 금지 |

11~20일 데이터는 다음 태그를 금지합니다.

- `four_direction_pressure`
- `solo_non_east_spawn`
- `strong_elite_intro`
- `unwarned_heavy_disruptor`
- `aoe_full_nullifier`
- `stack_reward_bonus`

20일 변형 보스는 `boss_silent_colossus_variant`와 별도로 `variantReasonTags`를 기록할 수 있습니다.

이 태그는 11~19일 전투 리포트에서 가장 많이 나온 실패 원인을 설명하기 위한 것이며, 추가 보상 계산에 사용하지 않습니다.

### 21~30일 MVP 협동 흐름 데이터

21~30일 웨이브는 `chapterFlowId: "mvp30_coop_flow_021_030"`를 가집니다.

이 흐름은 정예 타이밍, 방향 분담, 계절 전환, 여름 템포, 고밀도 리허설, 관측자 예고형을 하나의 협동 시험으로 묶습니다.

| 일자 | `chapterPhaseIndex` | 협동 질문 | 기본 제한 |
| ---: | ---: | --- | --- |
| 21 | 1 | 검은 등짐 처치 타이밍을 합의하는가? | 정예 체력벽화 금지 |
| 22 | 2 | 킬존을 활성 방향 성격에 맞게 다시 짜는가? | 비활성 방향 예고 금지 |
| 23 | 2 | 도발 약화 지원형을 다른 대응과 함께 처리하는가? | 수호자 역할 완전 무효화 금지 |
| 24 | 2 | 빠른 라인과 방해 라인을 나눠 보는가? | 2인 3방향 압박 금지 |
| 25 | 3 | 계절 전환 선택을 다음 5일 대비로 읽는가? | 보스 보상급 대형 보상 금지 |
| 26 | 4 | 여름의 빠른 템포를 이해하는가? | 새 여름 규칙 과다 투입 금지 |
| 27 | 4 | 방해형과 정예형 우선순위를 합의하는가? | 강한 방해형/정예 동시 대량 금지 |
| 28 | 5 | 3웨이브 겹치기를 위험 판단으로 쓰는가? | 겹치기 보상 증가 금지 |
| 29 | 5 | MVP 압박을 설명하며 대응하는가? | 새 적 추가 금지 |
| 30 | 6 | 불완전한 예고 속에서 활성 방향 안 분담을 하는가? | 거짓 예고, 비활성 방향 스폰 금지 |

30일 사계의 관측자 예고형은 `observerPreviewCandidateDirections`를 기록할 수 있습니다.

이 값은 실제 후보 방향이며 반드시 `activeDirections`의 부분집합이어야 합니다.

후보가 2개보다 적은 1인 플레이에서는 방향 후보 교란 대신 동쪽 안의 경로 후보 또는 스폰 타이밍 후보로 대체합니다.

### 30일 MVP 일자 계약 데이터

`Mvp30DayContract`는 30일 MVP 런에서 각 일자가 반드시 남겨야 하는 플레이 질문과 잠금 조건을 정의합니다.

이 데이터는 수치 밸런스가 아니라 콘텐츠 순서와 학습 약속을 고정합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `day` | number | 1~30 |
| `waveId` | string | 해당 일자의 기본 웨이브 ID |
| `chapterFlowId` | string | 10일 단위 흐름 ID |
| `phaseIndex` | number | 10일 안 운영 단계 |
| `dayRole` | enum | `learn`, `practice`, `shop`, `tempo_test`, `boss`, `transition`, `rehearsal` |
| `lockedLearningPromiseTag` | string | 해당 일자가 반드시 남겨야 하는 핵심 질문 |
| `primaryEnemyRoleTags` | string[] | 주 압박 역할 |
| `allowedSupportRoleTags` | string[] | 보조로 섞을 수 있는 역할 |
| `rewardProfileId` | string/null | 연결 카드 보상 프로필 |
| `shopSessionId` | string/null | 연결 상점 또는 정비 세션 |
| `bossPhasePlanId` | string/null | 보스 일자일 때 연결 보스 흐름 |
| `activeDirectionProjectionPolicyId` | string | 인원수별 방향 투영 정책 |
| `carryOverTagsFromPreviousDays` | string[] | 이전 일자에서 회수해야 하는 태그 |
| `reportRecallTags` | string[] | 웨이브 후 리포트가 회수할 태그 |
| `tunableFields` | string[] | 테스트 중 조정 가능한 수치 필드 |
| `lockedContentTags` | string[] | 바꾸면 안 되는 콘텐츠 순서 태그 |
| `forbiddenTags` | string[] | 금지 태그 |

예시:

```json
{
  "day": 28,
  "waveId": "wave_day_028_three_stack_trial",
  "chapterFlowId": "mvp30_coop_flow_021_030",
  "phaseIndex": 5,
  "dayRole": "tempo_test",
  "lockedLearningPromiseTag": "three_stack_as_risk_not_reward",
  "primaryEnemyRoleTags": ["swarm", "breaker_light"],
  "allowedSupportRoleTags": ["route_read"],
  "rewardProfileId": "reward_profile_mvp_021_030_phase_005_stack",
  "shopSessionId": null,
  "bossPhasePlanId": null,
  "activeDirectionProjectionPolicyId": "active_direction_projection_mvp30",
  "carryOverTagsFromPreviousDays": ["priority_target", "fast_lane_split"],
  "reportRecallTags": ["stack_risk_read", "base_warning_checked", "hold_is_valid"],
  "tunableFields": ["enemyCount", "spawnInterval", "baseDamage", "riskBudget"],
  "lockedContentTags": ["wave_stack_cap_3", "no_reward_bonus", "no_new_enemy_role"],
  "forbiddenTags": ["rewardBonus", "rarityBoost", "cardCandidateIncrease", "inactiveDirectionSpawn"]
}
```

30일 MVP 계약에서 잠그는 항목:

- 5일, 15일, 25일의 정비/상점/전환 역할
- 10일, 20일, 30일 보스 배치
- 8일 기능 학습, 18일 판단 압박, 28일 고밀도 리허설의 웨이브 겹치기 역할
- 21일 정예 첫 본격 등장
- 29~30일 새 일반 적 역할 추가 금지

30일 MVP 계약에서 튜닝 가능한 항목:

- 적 수, 체력, 이동 속도, 스폰 간격
- 위험도 예산과 실제 스폰 묶음
- 구조물 파괴 예고 시간
- 기지 피해량
- 보스 부위 체력과 패턴 주기
- 상점 가격과 추천 정렬

`Mvp30DayContract`는 웨이브 겹치기 보상, 카드 후보 수, 희귀도, 활성 방향 목록을 바꿀 수 없습니다.

### 30일 MVP 시간 예산 데이터

`MvpRuntimeBudgetProfile`은 30일 MVP가 목표 시간 안에 끝나는지 검증하기 위한 계측 기준입니다.

이 데이터는 난이도 보정이나 보상 계산에 사용하지 않고, 플레이테스트 리포트와 템포 조정 순서를 정하는 데만 사용합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 시간 예산 프로필 ID |
| `runMode` | enum | `mvp_30_day` |
| `startMeasurementAt` | enum | `day_001_started` |
| `endMeasurementAt` | enum | `day_030_result_summary_completed` |
| `excludeContinueShop` | boolean | 30일 이후 계속하기 상점을 MVP 시간에서 제외 |
| `targetTotalSecondsMin` | number | 목표 하한 |
| `targetTotalSecondsMax` | number | 목표 상한 |
| `warningTotalSeconds` | number | 템포 경고 기준 |
| `failureTotalSeconds` | number | 흐름 실패 기준 |
| `segmentBudgets` | object[] | 구간별 목표 시간 |
| `activityBudgets` | object[] | 전투, 보스, 보상, 상점 등 활동별 목표 시간 |
| `expectedWaveStackCallsMin` | number | 권장 웨이브 호출 하한 |
| `expectedWaveStackCallsMax` | number | 권장 웨이브 호출 상한 |
| `forbiddenAdjustmentTags` | string[] | 시간 문제 해결에 쓰면 안 되는 조정 |

MVP 기준값:

| ID | 총 목표 | 경고 | 실패 | 겹치기 호출 기대 | 제외 시간 |
| --- | ---: | ---: | ---: | ---: | --- |
| `runtime_budget_mvp_030` | 30~45분 | 45분 초과 | 50분 초과 | 4~8회 | 30일 이후 계속하기 상점 |

구간 예산:

| 구간 ID | 일자 | 목표 | 포함 |
| --- | --- | ---: | --- |
| `runtime_segment_001_010` | 1~10일 | 11~15분 | 기본 전투, 5일 상점, 10일 첫 보스 |
| `runtime_segment_011_020` | 11~20일 | 11~15분 | 첫 아티팩트 체감, 15일 이벤트/상점, 20일 변형 보스 |
| `runtime_segment_021_030` | 21~30일 | 10~14분 | 정예 분담, 25일 전환, 28일 리허설, 30일 관측자 예고형 |
| `runtime_segment_buffer` | 전체 | 2~4분 | 로딩, 짧은 토론, 재접속, 입력 지연 |

활동 예산:

| 활동 ID | 목표 | 실패 신호 |
| --- | ---: | --- |
| `runtime_activity_normal_combat` | 16~20분 | 23분 이상이면 스폰 간격 또는 적 잔존 시간이 과함 |
| `runtime_activity_boss_combat` | 7~9분 | 11분 이상이면 부위 판단보다 체력 반복전 |
| `runtime_activity_reward_settlement` | 6~8분 | 10분 이상이면 카드 후보 또는 압축 정산이 길어짐 |
| `runtime_activity_shop_event_artifact` | 7~10분 | 12분 이상이면 선택지와 투표가 과함 |
| `runtime_activity_result_summary` | 60~90초 | 120초 이상이면 회고가 상점처럼 느껴짐 |

예시:

```json
{
  "id": "runtime_budget_mvp_030",
  "runMode": "mvp_30_day",
  "startMeasurementAt": "day_001_started",
  "endMeasurementAt": "day_030_result_summary_completed",
  "excludeContinueShop": true,
  "targetTotalSecondsMin": 1800,
  "targetTotalSecondsMax": 2700,
  "warningTotalSeconds": 2700,
  "failureTotalSeconds": 3000,
  "expectedWaveStackCallsMin": 4,
  "expectedWaveStackCallsMax": 8,
  "forbiddenAdjustmentTags": [
    "wave_stack_reward_bonus",
    "rarity_boost",
    "card_candidate_increase",
    "gold_total_increase",
    "time_based_mana_regen",
    "inactive_direction_spawn",
    "active_direction_recalculation"
  ]
}
```

### 31~40일 과열 운영 흐름 데이터

31~40일 웨이브는 `chapterFlowId: "summer1_heat_flow_031_040"`를 가집니다.

이 흐름은 과열 타일 학습, 빠른 적 대응, 뜨거운 킬존, 냉각 상점, 과열 분담, 고열 겹치기, 과열된 거상을 하나의 자리 운영 시험으로 묶습니다.

| 일자 | `chapterPhaseIndex` | 과열 질문 | 기본 제한 |
| ---: | ---: | --- | --- |
| 31 | 1 | 과열 타일을 위험한 강화 지점으로 이해하는가? | 과열 순수 함정화 금지 |
| 32 | 1 | 빠른 적을 과열 화력이나 제어로 늦추는가? | 체력 증가로 난이도 보정 금지 |
| 33 | 2 | 과열 킬존을 쓰되 구조물 손실을 관리하는가? | 보상 타일처럼 표시 금지 |
| 34 | 2 | 잿불 석공의 달굼을 예고로 읽는가? | 예고 없는 과열 생성 금지 |
| 35 | 3 | 수리, 체력, 빠른 대응 중 무엇을 보완하는가? | 상점 항목 과다 금지 |
| 36 | 4 | 두 방향 과열 중 어디를 살릴지 나누는가? | 비활성 방향 과열 금지 |
| 37 | 4 | 수리 효율 감소 속에서 버릴 구조물을 고르는가? | 수리로 모든 위험 삭제 금지 |
| 38 | 5 | 과열 구조물 상태를 보고 겹치기를 판단하는가? | 겹치기 보상 증가 금지 |
| 39 | 5 | 빠른 적, 과열, 파괴형을 함께 설명하는가? | 새 요소 추가 금지 |
| 40 | 6 | 보스 열 자취를 이용하면서 붕괴를 통제하는가? | 강한 동반 웨이브 동시 과부하 금지 |

과열 데이터는 아래 정보를 가질 수 있습니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `overheatZoneProfileId` | string/null | 과열 타일 수치 프로필 ID |
| `overheatCandidateTiles` | string[] | 전투 시작 전 예고할 과열 후보 타일 |
| `temporaryHeatSources` | object[] | 잿불 석공, 보스 열 자취 등 임시 과열 생성 원인 |
| `overheatRiskTags` | string[] | 구조물 피해 증가, 수리 효율 감소, 빠른 적 대응 등 표시 태그 |

`overheatCandidateTiles`는 반드시 활성 방향 설치 구역 안에 있어야 합니다.

비활성 방향에는 과열 타일, 과열 예고, 과열 보상 표시를 만들지 않습니다.

`OverheatZoneProfile`:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `overheatZoneProfileId` | string | 과열 수치 프로필 ID |
| `attackSpeedMultiplier` | number | 과열 위 구조물 공격 속도 배율 |
| `structureDamageTakenMultiplier` | number | 과열 위 구조물 받는 피해 배율 |
| `repairEfficiencyMultiplier` | number | 과열 위 구조물 수리 효율 배율 |
| `fixedDurationSeconds` | number/null | 고정 과열 지속 시간 |
| `temporaryDurationSeconds` | number/null | 임시 과열 지속 시간 |
| `warningSeconds` | number | 활성화 전 예고 시간 |
| `maxActiveTilesPerDirection` | number | 활성 방향당 동시에 켜질 수 있는 과열 타일 수 |
| `forbiddenRewardTags` | string[] | 보상, 희귀도, 후보 수 증가 금지 태그 |

첫 프로토타입 프로필:

| ID | 공격 속도 | 받는 피해 | 수리 효율 | 지속 | 용도 |
| --- | ---: | ---: | ---: | --- | --- |
| `overheat_profile_intro_031` | 1.20 | 1.25 | 0.85 | 20~30초 | 31~33일 고정 과열 학습 |
| `overheat_profile_mason_temp_034` | 1.20 | 1.30 | 0.80 | 10~14초 | 잿불 석공 임시 과열 |
| `overheat_profile_split_036` | 1.18 | 1.25 | 0.85 | 18~24초 | 36~37일 두 방향 과열 |
| `overheat_profile_boss_wake_040` | 1.15 | 1.30 | 0.80 | 10~16초 | 40일 보스 열 자취 |

과열 프로필은 난이도 보정용 숨은 배율이 아닙니다.

모든 과열 수치는 UI 위험 태그와 연결되어야 하며, 수치가 바뀌면 플레이테스트 대시보드의 과열 사용률과 구조물 생존 시간이 함께 검토되어야 합니다.

### 41~50일 붕괴 운영 흐름 데이터

41~50일 웨이브는 `chapterFlowId: "summer2_collapse_flow_041_050"`를 가집니다.

이 흐름은 보스 후 재건, 표식 구조물, 열차단 상점, 과열 회전, 파괴형 겹치기, 사계의 관측자 강화형을 구조물 손실 판단으로 묶습니다.

| 일자 | `chapterPhaseIndex` | 붕괴 질문 | 기본 제한 |
| ---: | ---: | --- | --- |
| 41 | 1 | 손상된 방어선을 유지할지 다시 짤지 정하는가? | 새 압박 즉시 과부하 금지 |
| 42 | 2 | 열톱니 표식을 읽고 대응하는가? | 예고 없는 구조물 파괴 금지 |
| 43 | 2 | 표식 바리케이드를 희생해 딜타임을 버는가? | 무조건 파괴 강제 금지 |
| 44 | 3 | 빠른 적과 파괴형 우선순위를 합의하는가? | 동시 최대 압박 금지 |
| 45 | 3 | 수리, 체력, 예고 강화 중 무엇을 보완하는가? | 모든 약점 해결 상점 금지 |
| 46 | 4 | 과열 지점을 고정하지 않고 옮겨 쓰는가? | 비활성 방향 과열 금지 |
| 47 | 4 | 후보 방향 예고를 분담하는가? | 비활성 방향 후보 금지 |
| 48 | 5 | 표식이 많은 상태에서 겹치기를 판단하는가? | 겹치기 보상 증가 금지 |
| 49 | 5 | 과열, 빠른 적, 파괴형, 예고 교란을 설명하는가? | 새 요소 추가 금지 |
| 50 | 6 | 관측자 강화형에서 방향과 수리 우선순위를 나누는가? | 후보 밖 기습 스폰 금지 |

표식 구조물 데이터:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `markedStructureId` | string | 표식 대상 구조물 ID |
| `markSourceId` | string | 열톱니, 보스 패턴 등 표식 원인 |
| `markWarningSeconds` | number | 실제 공격 전 예고 시간 |
| `saveOptions` | string[] | 수리, 도발 이전, 임시 구조물, 후방 재건 등 가능한 대응 |
| `collapseValueTags` | string[] | 버렸을 때 얻은 잔해, 폭발, 지연, 딜타임 가치 |

표식 구조물은 반드시 파괴되어야 하는 대상이 아닙니다.

살릴 수도 있고, 버릴 수도 있으며, 두 선택 모두 결과 리포트에서 전술 선택으로 기록되어야 합니다.

`Summer2CollapseSpawnPacketLock`:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `lockId` | string | 41~50일 스폰 패킷 잠금 ID |
| `day` | number | 41~50일 |
| `waveId` | string | 연결 `WaveData.id` |
| `baselinePlayerCount` | number | 기준 인원수, 2 |
| `packetIds` | string[] | 해당 일자의 `WaveSpawnPacket.packetId` 목록 |
| `baselineEnemySummary` | object[] | 2인 기준 적 ID와 수량 요약 |
| `maxActualDirectionCount` | number | 2인 기준 실제 스폰 방향 상한 |
| `candidateDirectionPolicy` | enum | `none`, `active_only`, `solo_replace_with_tile_candidate` |
| `stackHandling` | enum | `normal`, `warning_only`, `boss_locked` |
| `forbiddenModifierTags` | string[] | 보상, 희귀도, 카드 후보, 비활성 방향 변경 금지 태그 |

41~50일 2인 기준 패킷 잠금:

| 일자 | 잠금 ID | `packetIds` 요약 | 실제 방향 수 | 후보/겹치기 정책 |
| ---: | --- | --- | ---: | --- |
| 41 | `summer2_spawn_lock_day_041` | 회색 행렬 22, 여름 질주자 3 | 1~2 | 후보 없음, 일반 겹치기 |
| 42 | `summer2_spawn_lock_day_042` | 열톱니 2, 회색 행렬 14 | 1 | 후보 없음, 일반 겹치기 |
| 43 | `summer2_spawn_lock_day_043` | 회색 행렬 18, 열톱니 2, 균열 망치 2 | 1~2 | 후보 없음, 일반 겹치기 |
| 44 | `summer2_spawn_lock_day_044` | 여름 질주자 9, 열톱니 2, 회색 행렬 12 | 1~2 | 후보 없음, 일반 겹치기 |
| 45 | `summer2_spawn_lock_day_045` | 회색 행렬 12, 열톱니 1, 여름 질주자 3 | 1 | 후보 없음, 낮은 겹치기 친화도 |
| 46 | `summer2_spawn_lock_day_046` | 잿불 석공 2, 열톱니 2, 회색 행렬 16, 균열 망치 2 | 1~2 | 후보 없음, 일반 겹치기 |
| 47 | `summer2_spawn_lock_day_047` | 회색 행렬 20, 여름 질주자 4 | 후보 2, 실제 1 | 후보는 활성 방향 안에서만 표시 |
| 48 | `summer2_spawn_lock_day_048` | 회색 행렬 24, 열톱니 3, 균열 망치 2 | 1~2 | `warning_only`, 보상 증가 없음 |
| 49 | `summer2_spawn_lock_day_049` | 여름 질주자 6, 잿불 석공 2, 열톱니 3, 회색 행렬 18, 균열 망치 2 | 2 | 50일 보스 호출 금지 |
| 50 | `summer2_spawn_lock_day_050` | 사계의 관측자 강화형 1, 선택적 회색 행렬 8, 선택적 열톱니 1 | 후보 2, 실제 1 | `boss_locked`, 동반 패킷 보상 없음 |

인원수별 패킷 투영:

| 인원수 | 투영 |
| ---: | --- |
| 1 | 모든 `WaveSpawnPacket.directions`는 `east`만 사용합니다. 47/50일 후보 방향은 후보 타일, 과열 위치, 표식 대상으로 대체합니다. |
| 2 | `north`, `east`만 실제 방향으로 사용합니다. `west` 선호 패킷은 동쪽 빠른 경로 또는 북쪽 긴 경로로 대체합니다. |
| 3 | `west`, `north`, `east`만 실제 방향으로 사용합니다. `south` 후보나 일반 웨이브를 만들지 않습니다. |
| 4 | `south`는 후보 또는 보조 압박으로 사용할 수 있지만, 41~50일 기본 일반 웨이브에서 사방 동시 압박을 만들지 않습니다. |

48일 겹치기 후보는 47~49일 일반 웨이브 안에서만 구성합니다.

50일 보스 스폰 플랜은 48일 또는 49일 겹치기 호출 대상이 아닙니다.

### 51~60일 경로 재설계 흐름 데이터

51~60일 웨이브는 `chapterFlowId: "autumn1_path_flow_051_060"`를 가집니다.

이 흐름은 낙엽 타일, 가을의 묵자, 오래 남는 잔해, 무너진 길 상점, 오라 분산, 무너진 종탑을 경로 재설계 판단으로 묶습니다.

| 일자 | `chapterPhaseIndex` | 경로 질문 | 기본 제한 |
| ---: | ---: | --- | --- |
| 51 | 1 | 낙엽 예고를 보고 적 경로 비용 변화를 이해하는가? | 예고 없는 경로 변화 금지 |
| 52 | 1 | 마나 방해형과 경로 재배치 중 우선순위를 정하는가? | 마나 완전 봉쇄 금지 |
| 53 | 2 | 오래 남는 잔해를 임시 경로 비용으로 쓰는가? | 잔해 완전 길막 금지 |
| 54 | 2 | 낙엽 우회를 보고 킬존을 옮기는가? | 1인 두 방향 재설계 금지 |
| 55 | 3 | 잔해 정리, 예고, 수리, 방해 저항 중 무엇을 보완하는가? | 모든 약점 해결 상점 금지 |
| 56 | 4 | 오라 밀집 위험을 보고 보조 킬존을 여는가? | 땜장이 역할 삭제 금지 |
| 57 | 4 | 경로 변화 예고가 있는 상태에서 겹치기를 판단하는가? | 겹치기 보상 증가 금지 |
| 58 | 5 | 잔해와 낙엽으로 이동 킬존을 만드는가? | 비활성 방향 활용 강제 금지 |
| 59 | 5 | 낙엽, 잔해, 방해형, 분산 배치를 함께 설명하는가? | 새 요소 추가 금지 |
| 60 | 6 | 무너진 종탑의 무음 권역 속에서 분산/재집결하는가? | 오라/수리 0, 권역 기습 금지 |

가을 1장 경로 데이터:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `leafPathChangePlanId` | string/null | 낙엽 변화 위치와 타이밍을 묶은 계획 ID |
| `leafCandidateTiles` | string[] | 전투 시작 전 예고할 낙엽 후보 타일 |
| `persistentDebrisPolicyId` | string/null | 오래 남는 잔해 지속 시간과 약화 규칙 |
| `routeReopenPolicyId` | string | 완전 길막이 발생할 때 경로를 다시 여는 규칙 |
| `auraSpreadHintTags` | string[] | 오라 분산, 보조 킬존, 원격 수리 우선순위 힌트 |

`leafCandidateTiles`는 반드시 활성 방향 안의 경로 또는 설치 영향권에 있어야 합니다.

낙엽과 잔해가 모든 경로를 막으면 `routeReopenPolicyId`에 따라 가장 오래된 잔해를 `밟힌 잔해`로 바꾸고, 이 처리를 전투 리포트에 기록합니다.

`Autumn1PathSpawnPacketLock`:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `lockId` | string | 51~60일 스폰 잠금 ID |
| `day` | number | 적용 일자 |
| `waveId` | string | 연결 웨이브 ID |
| `baselinePlayerCount` | number | 기준 인원수. 기본값 2 |
| `packetIds` | string[] | 연결되는 `WaveSpawnPacket.packetId` 목록 |
| `baselineEnemySummary` | object | 2인 기준 적 종류와 수량 요약 |
| `leafPathChangePlanId` | string/null | 전투 시작 전 보여줄 낙엽 변화 계획 |
| `persistentDebrisPolicyId` | string/null | 오래 남는 잔해 정책 |
| `routeReopenPolicyId` | string | 완전 길막 방지 정책 |
| `maxLeafChangesDuringWave` | number | 웨이브 중 실제 낙엽 변화 횟수. 기본 최대 1 |
| `maxActualDirectionCount` | number | 2인 기준 실제 동시 압박 방향 수 |
| `inactiveDirectionProjectionPolicy` | enum | `active_only`, `replace_with_long_route`, `replace_with_inner_bend`, `boss_zone_only` |
| `stackHandling` | enum | `normal`, `warning_only`, `boss_locked` |
| `forbiddenModifierTags` | string[] | 붙일 수 없는 보정 태그 |

| ID | 일자 | 웨이브 | 패킷 | 낙엽/잔해 | 방향/겹치기 |
| --- | ---: | --- | --- | --- | --- |
| `autumn1_spawn_lock_day_051` | 51 | `wave_day_051_leaf_drift_intro` | 회색 행렬 22, 유리 껍질 3 | `leaf_plan_day_051_intro_one_change` | 1방향, `normal` |
| `autumn1_spawn_lock_day_052` | 52 | `wave_day_052_autumn_mute_intro` | 회색 행렬 22, 가을의 묵자 2 | `leaf_plan_day_052_mute_lane_read` | 1방향, `normal` |
| `autumn1_spawn_lock_day_053` | 53 | `wave_day_053_persistent_debris` | 회색 행렬 18, 균열 망치 2, 가을의 묵자 1 | `leaf_plan_day_053_debris_reopen_check`, `debris_policy_autumn_long_basic` | 1방향, `normal` |
| `autumn1_spawn_lock_day_054` | 54 | `wave_day_054_leaf_reroute` | 회색 행렬 24, 여름 질주자 6 | `leaf_plan_day_054_reroute_midwave` | 2방향, `normal` |
| `autumn1_spawn_lock_day_055` | 55 | `wave_day_055_fallen_path_market` | 회색 행렬 14, 가을의 묵자 1, 유리 껍질 2 | `leaf_plan_day_055_shop_preview_static` | 1방향, `normal` |
| `autumn1_spawn_lock_day_056` | 56 | `wave_day_056_aura_spread_test` | 유리 껍질 6, 가을의 묵자 2, 회색 행렬 12 | `leaf_plan_day_056_split_aura` | 2방향, `normal` |
| `autumn1_spawn_lock_day_057` | 57 | `wave_day_057_stack_reroute_risk` | 회색 행렬 24, 침묵 운반자 2, 균열 망치 2 | `leaf_plan_day_057_stack_warning` | 2방향, `warning_only` |
| `autumn1_spawn_lock_day_058` | 58 | `wave_day_058_debris_killzone_shift` | 균열 망치 4, 뒤틀린 표식 2, 회색 행렬 14 | `leaf_plan_day_058_mobile_killzone`, `debris_policy_autumn_long_basic` | 2방향, `normal` |
| `autumn1_spawn_lock_day_059` | 59 | `wave_day_059_autumn_first_mix` | 회색 행렬 26, 가을의 묵자 2, 뒤틀린 표식 2, 유리 껍질 2 | `leaf_plan_day_059_recap_one_change` | 2방향, `normal` |
| `autumn1_spawn_lock_day_060` | 60 | `wave_day_060_fallen_belltower` | 무너진 종탑 1, 선택 동반 회색 행렬 8, 선택 동반 유리 껍질 2 | `leaf_plan_day_060_belltower_toll`, `silence_zone_plan_belltower_060` | 1방향, `boss_locked` |

51~60일 투영 규칙:

- 1인 런에서는 모든 실제 패킷 방향이 `east`여야 합니다.
- 2인 런에서는 실제 방향이 `north`, `east`의 부분집합이어야 합니다.
- 3인 런에서는 실제 방향과 낙엽 후보에 `south`를 사용할 수 없습니다.
- 4인 런에서도 59일과 60일 기본 스폰은 사방 동시 압박을 사용하지 않습니다.
- `replace_with_long_route`는 서쪽 선호를 북쪽 긴 경로나 동쪽 후방 굴곡으로 바꿉니다.
- `replace_with_inner_bend`는 남쪽 킬존 선호를 활성 방향 안의 안쪽 굴곡 또는 후방 킬존 후보로 바꿉니다.
- 57일 겹치기 후보는 57~59일 일반 웨이브 안에서만 구성합니다.
- 60일 보스 스폰 플랜은 57~59일 겹치기 호출 대상이 아닙니다.
- 60일 선택적 동반 패킷은 보상, 카드 후보, 보스 파편, 아티팩트 드롭 수를 바꾸지 않습니다.

### 61~70일 우선순위 흐름 데이터

61~70일 웨이브는 `chapterFlowId: "autumn2_priority_flow_061_070"`를 가집니다.

이 흐름은 종탑 후 재배치, 방해형/정예 우선순위, 후미 정예, 수확 상점, 분산 우선순위, 침묵 속 겹치기, 무너진 종탑 변형을 하나의 우선 처치 판단으로 묶습니다.

| 일자 | `chapterPhaseIndex` | 우선순위 질문 | 기본 제한 |
| ---: | ---: | --- | --- |
| 61 | 1 | 무음 권역 이후 우선 처치 핑과 방어선을 다시 잡는가? | 새 규칙 즉시 추가 금지 |
| 62 | 2 | 묵자와 검은 등짐 중 먼저 자를 대상을 합의하는가? | 방해형/정예 동시 과부하 금지 |
| 63 | 2 | 후미 정예 예고를 보고 집중 시간을 남기는가? | 후미 정예 무예고 금지 |
| 64 | 3 | 낙엽 변화와 자원 방해를 함께 읽는가? | 손패/마나 동시 완전 봉쇄 금지 |
| 65 | 3 | 정예 처치, 예고, 방해 저항 중 무엇을 보완하는가? | 모든 약점 해결 상점 금지 |
| 66 | 4 | 두 활성 방향의 서로 다른 위험을 나눠 맡는가? | 1인 두 방향 판단 금지 |
| 67 | 4 | 방해형이 남은 상태에서 겹치기를 판단하는가? | 겹치기 보상 증가 금지 |
| 68 | 5 | 잔해로 느려진 정예 라인을 끝까지 처리하는가? | 제어 완전 무효 정예 금지 |
| 69 | 5 | 방해형, 정예, 낙엽, 잔해 우선순위를 함께 설명하는가? | 새 요소 추가 금지 |
| 70 | 6 | 종탑 변형의 동반 웨이브 우선 처치 대상을 정하는가? | 새 부위/새 패턴/강한 동반 동시 추가 금지 |

가을 2장 우선순위 데이터:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `priorityThreatPairId` | string/null | 방해형과 정예처럼 서로 비교하게 만드는 위험 묶음 ID |
| `eliteSpawnTimingProfileId` | string/null | 선두 정예, 후미 정예, 시간차 정예 등 스폰 순서 프로필 |
| `disruptorEliteMixPolicyId` | string | 방해형과 정예 동시 투입 강도를 제한하는 정책 |
| `splitPriorityAssignmentTags` | string[] | 방향, 직업, 핑, 우선 처치 대상 분담 태그 |
| `bossCompanionVariantId` | string/null | 70일 종탑 변형에서 선택된 약한 동반 웨이브 조합 ID |

`priorityThreatPairId`는 보상 계산에 쓰지 않습니다.

이 필드는 전투 전 예고, 겹치기 위험 문구, 패배 리포트, 플레이테스트 분석이 같은 우선순위 질문을 보도록 연결하는 표시 데이터입니다.

`Autumn2PrioritySpawnPacketLock`:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `lockId` | string | 61~70일 스폰 잠금 ID |
| `day` | number | 적용 일자 |
| `waveId` | string | 연결 웨이브 ID |
| `baselinePlayerCount` | number | 기준 인원수. 기본값 2 |
| `packetIds` | string[] | 연결되는 `WaveSpawnPacket.packetId` 목록 |
| `baselineEnemySummary` | object | 2인 기준 적 종류와 수량 요약 |
| `priorityThreatPairId` | string/null | 비교하게 만들 방해형/정예/보스 부위 위험 묶음 |
| `eliteSpawnTimingProfileId` | string/null | 정예가 선두, 중간, 후미, 시간차 중 어디에 나오는지 |
| `disruptorEliteMixPolicyId` | string | 방해형과 정예 동시 투입 강도 제한 정책 |
| `leafPathChangePlanId` | string/null | 낙엽 변화 계획. 이미 배운 경로 압박만 사용 |
| `persistentDebrisPolicyId` | string/null | 오래 남는 잔해 정책 |
| `bossCompanionVariantId` | string/null | 70일 선택 동반 조합 ID |
| `maxActualDirectionCount` | number | 2인 기준 실제 동시 압박 방향 수 |
| `inactiveDirectionProjectionPolicy` | enum | `active_only`, `same_lane_time_shift`, `replace_with_long_route`, `replace_with_inner_bend`, `boss_companion_single` |
| `stackHandling` | enum | `normal`, `warning_only`, `boss_locked` |
| `forbiddenModifierTags` | string[] | 붙일 수 없는 보정 태그 |

| ID | 일자 | 웨이브 | 패킷 | 우선순위/정예 타이밍 | 방향/겹치기 |
| --- | ---: | --- | --- | --- | --- |
| `autumn2_spawn_lock_day_061` | 61 | `wave_day_061_post_tower_realign` | 회색 행렬 24, 유리 껍질 2 | `priority_plan_day_061_realign_ping` | 1방향, `normal` |
| `autumn2_spawn_lock_day_062` | 62 | `wave_day_062_mute_elite_priority` | 회색 행렬 22, 가을의 묵자 2, 검은 등짐 1 | `priority_pair_mute_black_pack_same_lane`, `elite_timing_midline_visible` | 1방향, `normal` |
| `autumn2_spawn_lock_day_063` | 63 | `wave_day_063_rear_elite_pressure` | 회색 행렬 30, 후미 검은 등짐 1 | `priority_pair_rear_elite_swarm`, `elite_timing_rear_after_swarm_warned` | 1방향, `normal` |
| `autumn2_spawn_lock_day_064` | 64 | `wave_day_064_leaf_mute_crossfire` | 회색 행렬 22, 가을의 묵자 2, 유리 껍질 3 | `priority_pair_leaf_mute_cross` | 2방향, `normal` |
| `autumn2_spawn_lock_day_065` | 65 | `wave_day_065_harvest_market` | 회색 행렬 20, 검은 등짐 예고형 1, 가을의 묵자 1 | `priority_plan_day_065_harvest_diagnosis`, `elite_timing_preview_only` | 1방향, `normal` |
| `autumn2_spawn_lock_day_066` | 66 | `wave_day_066_split_priority` | 회색 행렬 24, 가을의 묵자 2, 검은 등짐 1 | `priority_pair_split_mute_elite`, `elite_timing_split_visible` | 2방향, `normal` |
| `autumn2_spawn_lock_day_067` | 67 | `wave_day_067_stack_under_silence` | 회색 행렬 26, 침묵 운반자 2, 가을의 묵자 1 | `priority_plan_day_067_disruptor_stack_warning` | 2방향, `warning_only` |
| `autumn2_spawn_lock_day_068` | 68 | `wave_day_068_elite_debris_lane` | 균열 망치 3, 무거운 순례자 1, 회색 행렬 14 | `priority_pair_debris_heavy_lane`, `elite_timing_slow_lane_visible` | 2방향, `normal` |
| `autumn2_spawn_lock_day_069` | 69 | `wave_day_069_autumn_second_mix` | 회색 행렬 28, 가을의 묵자 2, 검은 등짐 1, 뒤틀린 표식 2 | `priority_pair_autumn2_recap`, `elite_timing_mixed_visible` | 2방향, `normal` |
| `autumn2_spawn_lock_day_070` | 70 | `wave_day_070_fallen_belltower_variant` | 무너진 종탑 변형 1, 선택 동반 1종 | `priority_pair_boss_companion`, `boss_companion_variant_single_priority_070` | 1방향, `boss_locked` |

61~70일 투영 규칙:

- `priorityThreatPairId`는 보상, 카드 후보, 희귀도, 골드 계산에 사용할 수 없습니다.
- 1인 런에서는 모든 실제 패킷 방향이 `east`여야 하며, 66일 분산 우선순위는 같은 라인 안의 시간차 스폰으로 바꿉니다.
- 2인 런에서는 실제 방향이 `north`, `east`의 부분집합이어야 합니다.
- 3인 런에서는 실제 방향과 동반 웨이브 후보에 `south`를 사용할 수 없습니다.
- 4인 런에서도 69일과 70일 기본 스폰은 사방 동시 압박을 사용하지 않습니다.
- 후미 정예가 있는 웨이브는 `eliteSpawnTimingProfileId`와 전투 전 예고 또는 스폰 순서 경고를 가져야 합니다.
- 67일 겹치기 후보는 67~69일 일반 웨이브 안에서만 구성합니다.
- 70일 보스 스폰 플랜은 67~69일 겹치기 호출 대상이 아닙니다.
- 70일 `bossCompanionVariantId`는 한 번에 하나만 선택하며, 새 부위나 새 보스 패턴을 동시에 열 수 없습니다.
- 70일 선택적 동반 패킷은 보상, 카드 후보, 보스 파편, 아티팩트 드롭 수를 바꾸지 않습니다.

`BelltowerVariantBossPhasePlan`:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `phasePlanId` | string | 70일 종탑 변형 단계 계획 ID |
| `bossId` | string | `boss_fallen_belltower_variant` |
| `day` | number | 70 |
| `sourceBossPatternIds` | string[] | 60일에서 재사용하는 보스 패턴 ID |
| `sourceBossPartIds` | string[] | 60일에서 재사용하는 부위 ID |
| `phaseIds` | string[] | 순서대로 실행되는 단계 ID |
| `companionVariantPolicyId` | string | 선택 동반 조합 정책 ID |
| `maxCompanionVariantCount` | number | 한 전투에서 선택 가능한 동반 조합 수. 기본값 1 |
| `suppressionOverlapPolicyId` | string | 무음 권역과 동반 조합의 과부하를 제한하는 정책 |
| `resultBridgeTags` | string[] | 71~80일 공간 압박으로 넘길 결과 태그 |
| `forbiddenBossAdditions` | string[] | 70일에 추가할 수 없는 보스 요소 |

70일 종탑 변형 단계:

| 단계 ID | 권장 시간 | 사용하는 요소 | 예고 | 성공 질문 |
| --- | --- | --- | --- | --- |
| `boss_phase_070_variant_warning` | 전투 전 | 동반 조합 후보 1종 표시 | 필수 | 이번 보스의 추가점이 동반 조합뿐임을 이해하는가? |
| `boss_phase_070_first_suppression` | 0~45초 | `boss_pattern_mute_peal` | 권역 8초 전 | 60일처럼 오라와 수리를 분산하는가? |
| `boss_phase_070_companion_choice` | 45~90초 | 선택 동반 패킷 1종 | 등장 8초 전 | 부위, 정예, 방해형, 군집 중 첫 대상을 정하는가? |
| `boss_phase_070_priority_under_zone` | 90~155초 | `boss_pattern_mute_peal`, `boss_pattern_leaf_toll` | 권역/낙엽 각각 예고 | 권역 안팎으로 화력을 다시 배분하는가? |
| `boss_phase_070_last_regroup` | 155~230초 | `boss_pattern_debris_resonance` | 잔해 공명 예고 | 권역 종료 후 수리와 화력을 다시 모으는가? |
| `boss_phase_070_result_bridge` | 종료 | 결과 태그 기록 | 전투 리포트 | 71~80일 공간 압박 대비 약점을 기록하는가? |

70일 동반 조합 정책:

| ID | 선택 패킷 | 선택 기준 태그 | 우선순위 태그 | 제한 |
| --- | --- | --- | --- | --- |
| `belltower_variant_companion_black_pack` | `spawn_packet_day_070_optional_black_pack_companion` | `elite_timing_failed`, `priority_target_late` | `elite_first`, `boss_part_delay` | 검은 등짐 사망 효과는 보스 본체를 가속하지 않음 |
| `belltower_variant_companion_gray_pressure` | `spawn_packet_day_070_optional_gray_pressure` | `lane_neglected`, `boss_tunnel_vision` | `lane_stabilize_first`, `boss_part_delay` | 추가 보상 웨이브로 계산하지 않음 |
| `belltower_variant_companion_autumn_mute` | `spawn_packet_day_070_optional_autumn_mute_companion` | `resource_disruptor_ignored`, `card_timing_late` | `disruptor_first`, `boss_part_delay` | 마나 사용과 획득을 완전히 봉쇄하지 않음 |

`boss_phase_plan_belltower_variant_070`은 `boss_part_cracked_bell`, `boss_part_fallen_clapper`, `boss_pattern_mute_peal`, `boss_pattern_leaf_toll`을 재사용합니다.

새 부위, 새 보스 패턴, 강한 동반 웨이브, 사방 동시 압박, 보상 증가 필드는 이 단계 계획에 들어갈 수 없습니다.

### 71~80일 공간 압박 흐름 데이터

71~80일 웨이브는 `chapterFlowId: "winter1_space_flow_071_080"`를 가집니다.

이 흐름은 첫 서리, 겨울 껍질, 좁아진 방어선, 해동/이전 상점, 결빙 증가, 얼어붙은 수리, 공간 축소 중 겹치기, 겨울의 문 예고형을 공간 이전 판단으로 묶습니다.

| 일자 | `chapterPhaseIndex` | 공간 질문 | 기본 제한 |
| ---: | ---: | --- | --- |
| 71 | 1 | 결빙 예고를 보고 설치 위치를 바꾸는가? | 예고 없는 결빙 금지 |
| 72 | 1 | 겨울 껍질을 오래 묶어 잡는가? | 체력벽화 금지 |
| 73 | 2 | 줄어든 설치 공간에서 킬존을 유지하는가? | 비활성 방향 결빙 금지 |
| 74 | 2 | 느린 대형 적을 기지 전에 충분히 녹이는가? | 빠른 적 대량 과부하 금지 |
| 75 | 3 | 해동, 이전, 대형 적 대응 중 무엇을 보완하는가? | 겨울 압박 삭제 상점 금지 |
| 76 | 4 | 활성 방향별 결빙 증가를 감당하는가? | 경로 타일 결빙 금지 |
| 77 | 4 | 수리 효율이 낮은 구조물을 살릴지 버릴지 정하는가? | 수리 역할 삭제 금지 |
| 78 | 5 | 설치 공간이 줄어든 상태에서 겹치기를 판단하는가? | 겹치기 보상 증가 금지 |
| 79 | 5 | 결빙, 대형 적, 잔해, 분산 배치를 함께 설명하는가? | 새 요소 추가 금지 |
| 80 | 6 | 겨울의 문 예고형에서 얼 권역을 보고 방어선을 옮기는가? | 장기 공간 봉쇄 금지 |

겨울 1장 공간 데이터:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `frostZonePlanId` | string/null | 결빙 예정 위치, 예고 시간, 지속 시간을 묶은 계획 ID |
| `frostCandidateTiles` | string[] | 준비 단계 전에 예고할 결빙 후보 설치 타일 |
| `thawOptionIds` | string[] | 상점이나 카드로 해동할 수 있는 후보 옵션 |
| `structureRelocationOptionIds` | string[] | 구조물 이전, 후방 재건, 임시 이전 관련 선택지 |
| `remainingBuildSpaceScore` | number | 현재 활성 방향 안에서 남은 설치 공간 평가값 |
| `largeEnemyHoldProfileId` | string/null | 겨울 껍질, 무거운 순례자 등 느린 대형 적 지연 검증 프로필 |

`frostCandidateTiles`는 경로 타일을 포함할 수 없습니다.

결빙은 새 구조물 설치를 막고 기존 구조물 효율을 낮추지만, 구조물을 즉시 삭제하거나 보상 배율을 만들지 않습니다.

### 81~90일 최종 이전 흐름 데이터

81~90일 웨이브는 `chapterFlowId: "winter2_pressure_flow_081_090"`를 가집니다.

이 흐름은 문 뒤의 재정비, 보스 압력 타일 학습, 압력 속 대형 적, 마지막 재설계 상점, 압력 회전, 압력 중 겹치기, 마지막 킬존 이동, 겨울의 문을 최종 이전 판단으로 묶습니다.

| 일자 | `chapterPhaseIndex` | 이전 질문 | 기본 제한 |
| ---: | ---: | --- | --- |
| 81 | 1 | 80일 이후 후방 킬존을 준비하는가? | 새 규칙 즉시 과부하 금지 |
| 82 | 1 | 압력 권역이 설치 효율을 낮춘다는 것을 읽는가? | 압력 기습, 구조물 삭제 금지 |
| 83 | 2 | 압력 속에서도 겨울 껍질을 오래 묶어 잡는가? | 체력벽화 금지 |
| 84 | 2 | 전방 킬존을 포기하고 중후방으로 옮기는가? | 빠른 적 과부하 금지 |
| 85 | 3 | 구조물 이전, 압력 예고, 해동 중 무엇을 보완하는가? | 압력 삭제 상점 금지 |
| 86 | 4 | 압력 권역이 이동할 때 보조 킬존을 준비하는가? | 비활성 방향 압력 금지 |
| 87 | 4 | 압력 권역이 남은 상태에서 겹치기를 판단하는가? | 겹치기 보상 증가 금지 |
| 88 | 5 | 마지막 킬존을 압력 밖으로 옮기는가? | 비활성 방향 킬존 강제 금지 |
| 89 | 5 | 결빙, 압력, 대형 적, 분산 배치를 함께 설명하는가? | 새 요소 추가 금지 |
| 90 | 6 | 겨울의 문에서 이동 압력을 보고 방어선을 이전하는가? | 장기 압력 권역 금지 |

겨울 2장 압력 데이터:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `pressureTilePlanId` | string/null | 압력 권역 위치, 이동 순서, 예고 시간, 지속 시간을 묶은 계획 ID |
| `pressureCandidateZones` | string[] | 전투 시작 전 또는 패턴 전에 예고할 압력 후보 설치 권역 |
| `pressureRotationProfileId` | string/null | 압력 권역이 앞/중간/후방 또는 활성 방향 안에서 이동하는 순서 |
| `rearKillzoneCandidateTags` | string[] | 후방 킬존 후보, 보조 화력 지점, 이전 후보 태그 |
| `relocationDecisionTags` | string[] | 구조물 이전, 포기, 수리 유지, 새 설치 등 실제 대응 태그 |
| `pressureBuildSpaceScore` | number | 압력 권역 적용 후 남은 설치 공간 평가값 |

`pressureCandidateZones`는 반드시 `activeDirections` 안의 설치 권역이어야 하며 경로 타일을 포함할 수 없습니다.

보스 압력 타일은 구조물을 즉시 삭제하지 않고, 보상 배율이나 보상 후보 수를 바꾸지 않습니다.

## 웨이브 스폰 계획 데이터

웨이브 스폰 계획은 런 상태와 원본 웨이브 데이터를 조합해 만든 전투용 확정 데이터입니다.

이 데이터만 실제 스폰 시스템이 읽습니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `spawnPlanId` | string | 전투용 확정 스폰 계획 ID |
| `waveId` | string | 원본 웨이브 ID |
| `day` | number | 등장 일자 |
| `playerCountAtStart` | number | 런 시작 인원수 |
| `activeDirections` | string[] | 런 시작 시 확정된 활성 방향 |
| `directions` | string[] | 실제 스폰 방향 |
| `waveIntentId` | string | 실제 전투에서 보여줄 웨이브 의도 |
| `previewQuestionTag` | string | 예고 카드가 보여줄 핵심 질문 |
| `previewEnemyRoleProfileIds` | string[] | 예고 카드에 표시할 주 적 역할 프로필 |
| `previewResponseTags` | string[] | 예고 카드에 표시할 열린 대응 태그 |
| `scaledThreatBudget` | number | 스케일링 적용 후 위험도 예산 |
| `scaledEnemyGroups` | object[] | 스케일링 적용 후 적 묶음 |
| `spawnPackets` | object[] | 실제 스폰 시작 시점, 간격, 방향 역할을 가진 스폰 패킷 |
| `warnings` | string[] | 실제 예고 문구 |
| `previewCards` | object[] | 하루 시작 예고 UI에 보여줄 위험 카드 |
| `criticalWarningTags` | string[] | 전투 중 큰 경고로 승격할 수 있는 위험 태그 |
| `stackRiskLevel` | enum | `low`, `medium`, `high`, `locked` |
| `stackRiskReason` | string | 겹치기 투표 UI에 보여줄 위험 이유 |

예시:

```json
{
  "spawnPlanId": "spawn_plan_day_006_breaker_intro",
  "waveId": "wave_day_006_breaker_intro",
  "day": 6,
  "playerCountAtStart": 1,
  "activeDirections": ["east"],
  "directions": ["east"],
  "waveIntentId": "intent_planned_structure_break",
  "previewQuestionTag": "planned_collapse",
  "previewEnemyRoleProfileIds": ["enemy_role_profile_breaker", "enemy_role_profile_swarm"],
  "previewResponseTags": ["repair_window", "sacrifice_value", "rear_rebuild"],
  "scaledThreatBudget": 12,
  "scaledEnemyGroups": [
    {"enemyId": "enemy_gray_march", "count": 7, "spawnDelay": 0.75},
    {"enemyId": "enemy_crack_hammer", "count": 1, "spawnDelay": 4.5}
  ],
  "spawnPackets": [
    {
      "packetId": "day_006_p01_swarm",
      "enemyId": "enemy_gray_march",
      "count": 7,
      "directionRole": "short",
      "directions": ["east"],
      "firstSpawnTimeSeconds": 8,
      "intervalSeconds": 1.6,
      "routeProfileId": "route_east_short_pressure",
      "budgetUsed": 7
    },
    {
      "packetId": "day_006_p02_breaker",
      "enemyId": "enemy_crack_hammer",
      "count": 1,
      "directionRole": "short",
      "directions": ["east"],
      "firstSpawnTimeSeconds": 18,
      "intervalSeconds": null,
      "routeProfileId": "route_east_structure_target",
      "budgetUsed": 3
    }
  ],
  "warnings": ["파괴형 적 등장", "동쪽 구조물 체력 주의"],
  "previewCards": [
    {
      "type": "direction",
      "title": "동쪽 압박",
      "body": "짧은 경로에 파괴형이 섞입니다.",
      "iconTag": "east_breaker"
    },
    {
      "type": "response",
      "title": "구조물 보호",
      "body": "수리, 도발, 버릴 바리케이드가 유효합니다.",
      "iconTag": "repair_taunt"
    }
  ],
  "criticalWarningTags": ["structure_marked", "base_breach_soon"],
  "stackRiskLevel": "medium",
  "stackRiskReason": "파괴형이 구조물을 표식한 상태에서 다음 웨이브가 겹치면 전선이 빨리 무너질 수 있음"
}
```

`directions`는 반드시 `activeDirections`의 부분집합이어야 합니다.

웨이브 겹치기는 이미 만들어진 `WaveSpawnPlan`을 앞당길 뿐, 새로운 방향을 추가하지 않습니다.

`previewCards`와 `warnings`는 표시용 데이터입니다.

이 필드는 보상, 적 수, 스폰 방향, 마나 회복량을 바꾸지 않습니다.

### WaveSpawnPacket 데이터

`WaveSpawnPacket`은 한 웨이브 안에서 같은 적을 같은 리듬으로 내보내는 최소 스폰 묶음입니다.

`enemyGroups`가 제작 의도에 가까운 묶음이라면, `spawnPackets`는 실제 전투 타이밍에 가까운 묶음입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `packetId` | string | 스폰 패킷 ID |
| `enemyId` | string | 소환할 적 ID |
| `count` | number | 소환 수 |
| `directionRole` | enum | `short`, `slow`, `fast`, `killzone`, `boss`, `any` |
| `directions` | string[] | 실제 스폰 방향. `WaveSpawnPlan.directions`의 부분집합 |
| `firstSpawnTimeSeconds` | number | 웨이브 시작 후 첫 스폰 시점 |
| `intervalSeconds` | number/null | 같은 패킷 안 스폰 간격. 단일 적이면 null 허용 |
| `routeProfileId` | string | 해당 방향 안에서 사용할 경로 성격 |
| `warningLeadTimeSeconds` | number | 예고를 먼저 띄워야 하는 시간 |
| `budgetUsed` | number | 위험도 예산 사용량 |
| `isOptionalAssistPacket` | boolean | 보스전 동반 웨이브처럼 테스트에서 생략 가능한 보조 패킷인지 |
| `forbiddenWhenStacked` | boolean | 겹치기 상태에서 함께 호출하면 과부하라 잠그는지 |

스폰 패킷 검증 규칙:

- `directions`는 `WaveSpawnPlan.directions` 밖의 방향을 가질 수 없습니다.
- 1인 런의 모든 `directions`는 `east`여야 합니다.
- 새 적 첫 등장일의 `firstSpawnTimeSeconds`는 대응 예고가 먼저 보일 만큼 여유를 둡니다.
- `budgetUsed` 합은 `scaledThreatBudget`를 넘지 않아야 합니다. 학습일에는 예산을 남길 수 있습니다.
- `isOptionalAssistPacket`은 보상 팩을 추가하지 않습니다.
- `forbiddenWhenStacked`는 겹치기 잠금이나 경고에만 쓰며, 보상량을 바꾸지 않습니다.

### WaveStackVoteSession 데이터

`WaveStackVoteSession`은 다음 웨이브를 앞당길지 확인하는 짧은 투표 상태입니다.

이 데이터는 예정된 `WaveSpawnPlan`을 현재 전투에 합류시킬지 결정할 뿐, 보상량이나 스폰 방향을 새로 만들지 않습니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 겹치기 투표 ID |
| `runId` | string | 연결 런 ID |
| `sessionId` | string | 연결 세션 ID |
| `day` | number | 현재 일자 |
| `sourceType` | enum | `button`, `ping`, `auto_prompt` |
| `sourcePlayerId` | string/null | 제안한 플레이어 |
| `sourcePingId` | string/null | `wave_call_suggest` 핑에서 시작된 경우 |
| `currentWaveIds` | string[] | 현재 전투 중인 웨이브 |
| `candidateWaveIds` | string[] | 앞당길 후보 웨이브 |
| `candidateSpawnPlanIds` | string[] | 이미 확정된 `WaveSpawnPlan` ID |
| `stackCountBefore` | number | 투표 전 겹침 수 |
| `stackCountAfter` | number | 실행 시 겹침 수 |
| `currentWaveStackLimit` | number | 현재 적용 중인 겹치기 한도 |
| `baseHpPercentAtStart` | number | 투표 시작 시 기지 체력 비율 |
| `requiredConsentMode` | enum | `solo_confirm`, `majority`, `unanimous` |
| `voteDurationSeconds` | number | 기본 8 |
| `timeoutAction` | enum | 항상 `hold` |
| `yesPlayerIds` | string[] | 호출 동의 |
| `holdPlayerIds` | string[] | 보류 선택 |
| `claimedPlayerIds` | string[] | 위험 대응을 맡겠다고 표시한 플레이어 |
| `stackRiskLevel` | enum | `low`, `medium`, `high`, `locked` |
| `stackRiskReasonTextId` | string | 위험 이유 문구 |
| `previewCardIds` | string[] | 투표에 표시할 `WavePreviewCard.id` |
| `linkedWarningIds` | string[] | 관련 `CombatWarningSignal.id` |
| `blockedReasonTags` | string[] | 호출 불가 이유 |
| `resolvedAction` | enum/null | `called`, `held`, `expired`, `cancelled`, `blocked` |
| `resolvedReasonTags` | string[] | 결정 이유 |
| `spawnCountdownSeconds` | number | 호출 확정 뒤 스폰까지 짧은 예고 시간 |
| `forbiddenRewardFields` | string[] | 데이터에 있으면 안 되는 보상 필드 |

예시:

```json
{
  "id": "stack_vote_day_008_001",
  "runId": "run_2026_07_21_001",
  "sessionId": "session_local_001",
  "day": 8,
  "sourceType": "ping",
  "sourcePlayerId": "player_guardian",
  "sourcePingId": "ping_008_wave_call_suggest",
  "currentWaveIds": ["wave_day_008_runner_mix"],
  "candidateWaveIds": ["wave_day_009_priority_intro"],
  "candidateSpawnPlanIds": ["spawn_plan_day_009_priority_intro"],
  "stackCountBefore": 1,
  "stackCountAfter": 2,
  "currentWaveStackLimit": 3,
  "baseHpPercentAtStart": 0.42,
  "requiredConsentMode": "majority",
  "voteDurationSeconds": 8,
  "timeoutAction": "hold",
  "yesPlayerIds": ["player_guardian", "player_elementalist"],
  "holdPlayerIds": ["player_tinkerer"],
  "claimedPlayerIds": ["player_tinkerer"],
  "stackRiskLevel": "medium",
  "stackRiskReasonTextId": "stack_risk_marked_structure_before_call",
  "previewCardIds": ["preview_card_day_009_lane", "preview_card_day_009_enemy_role"],
  "linkedWarningIds": ["warning_day_008_east_marked_structure"],
  "blockedReasonTags": [],
  "resolvedAction": "held",
  "resolvedReasonTags": ["hold_repair_first"],
  "spawnCountdownSeconds": 2,
  "forbiddenRewardFields": ["goldMultiplier", "rarityBonus", "extraCardChoices"]
}
```

`timeoutAction`은 항상 `hold`입니다.

시간 초과, 보류, 취소는 자원 페널티를 만들지 않고 개인 책임 태그로 기록하지 않습니다.

### WaveRewardPacket 데이터

`WaveRewardPacket`은 한 웨이브가 원래 지급해야 하는 기본 정산 단위입니다.

웨이브 겹치기 여부와 상관없이 같은 규칙으로 생성됩니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 보상 팩 ID |
| `runId` | string | 연결 런 ID |
| `waveId` | string | 보상을 만든 웨이브 ID |
| `spawnPlanId` | string | 연결된 `WaveSpawnPlan.id` |
| `day` | number | 정산 일자 |
| `rewardProfileId` | string | 사용한 카드 보상 프로필 |
| `goldEarned` | number | 해당 웨이브에서 얻은 파티 골드 |
| `declineGold` | number | 카드 거절 시 받을 골드 |
| `candidateCardIdsByPlayer` | object | 플레이어별 카드 후보 3장 |
| `candidateRoleTagsByPlayer` | object | 후보 카드의 역할 태그 |
| `candidatePoolLaneIdsByPlayer` | object | 후보 카드의 카드 풀 라인, 공용 카드는 `common_soft_gap` 사용 |
| `candidateArchetypeIdsByPlayer` | object | 후보 카드의 아키타입, 공용 카드는 `common_soft_gap` 사용 |
| `responseTagsReferenced` | string[] | 직전 전투와 연결되는 대응 태그 |
| `generatedInsideSettlementBatchId` | string/null | 압축 정산 묶음 ID |
| `forbiddenBonusFields` | string[] | 데이터에 있으면 안 되는 보너스 필드 |

`candidateCardIdsByPlayer`는 플레이어마다 정확히 3장을 가져야 합니다.

웨이브 겹치기는 `WaveRewardPacket`의 후보 수, 희귀도, 골드 총량을 바꾸지 않습니다.

예시:

```json
{
  "id": "reward_packet_day_009_priority_intro",
  "runId": "run_2026_07_21_001",
  "waveId": "wave_day_009_priority_intro",
  "spawnPlanId": "spawn_plan_day_009_priority_intro",
  "day": 9,
  "rewardProfileId": "reward_profile_priority_response_basic",
  "goldEarned": 18,
  "declineGold": 12,
  "candidateCardIdsByPlayer": {
    "player_guardian": ["card_guardian_binding_oath", "card_common_focus_fire", "card_guardian_shield_wrap"],
    "player_tinkerer": ["card_tinkerer_remote_repair", "card_common_battlefield_cleanup", "card_tinkerer_spare_parts"]
  },
  "candidateRoleTagsByPlayer": {
    "player_guardian": ["taunt_anchor", "focus_fire_mark", "repair_window"],
    "player_tinkerer": ["repair_window", "slow_or_knockback", "resource_unjam"]
  },
  "candidatePoolLaneIdsByPlayer": {
    "player_guardian": ["guardian_taunt_anchor", "common_soft_gap", "guardian_line_delay"],
    "player_tinkerer": ["tinkerer_repair_window", "common_soft_gap", "tinkerer_maintenance_economy"]
  },
  "candidateArchetypeIdsByPlayer": {
    "player_guardian": ["archetype_guardian_iron_anchor", "common_soft_gap", "archetype_guardian_iron_anchor"],
    "player_tinkerer": ["archetype_tinkerer_emergency_maintenance", "common_soft_gap", "archetype_tinkerer_emergency_maintenance"]
  },
  "responseTagsReferenced": ["focus_fire_mark", "repair_window"],
  "generatedInsideSettlementBatchId": "settlement_batch_day_008_to_010",
  "forbiddenBonusFields": ["goldMultiplier", "rarityBonus", "extraCardChoices", "stackClearBonus"]
}
```

### SettlementBatch 데이터

`SettlementBatch`는 여러 `WaveRewardPacket`을 한 화면에서 빠르게 잠그기 위한 UI 상태입니다.

보상 총량을 계산하는 데이터가 아니라, 이미 만들어진 보상 팩을 일자 순서로 묶는 데이터입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 정산 묶음 ID |
| `runId` | string | 연결 런 ID |
| `sourceCombatId` | string | 정산을 만든 전투 ID |
| `sourceWaveIds` | string[] | 포함된 웨이브 ID |
| `rewardPacketIds` | string[] | 포함된 `WaveRewardPacket.id` |
| `displayMode` | enum | `single`, `compressed_rows`, `paged_rows` |
| `goldTotal` | number | 포함된 파티 골드 합계 |
| `goldBreakdown` | object[] | 웨이브별 골드 내역 |
| `playerChoiceStates` | object[] | 플레이어별 행 선택 상태 |
| `temporaryLockPolicy` | object | 제한 시간 종료 시 미선택 행 처리 |
| `reversibleUntil` | enum | `before_first_paid_shop_vote`, `shop_end_reconnect_only`, `none` |
| `forbiddenSummaryTextTags` | string[] | 표시 금지 문구 태그 |
| `forbiddenBonusFields` | string[] | 데이터에 있으면 안 되는 보너스 필드 |

예시:

```json
{
  "id": "settlement_batch_day_008_to_010",
  "runId": "run_2026_07_21_001",
  "sourceCombatId": "combat_day_008_stack_003",
  "sourceWaveIds": ["wave_day_008_runner_mix", "wave_day_009_priority_intro", "wave_day_010_boss"],
  "rewardPacketIds": ["reward_packet_day_008_runner_mix", "reward_packet_day_009_priority_intro", "reward_packet_day_010_boss"],
  "displayMode": "compressed_rows",
  "goldTotal": 61,
  "goldBreakdown": [
    {"waveId": "wave_day_008_runner_mix", "goldEarned": 16},
    {"waveId": "wave_day_009_priority_intro", "goldEarned": 18},
    {"waveId": "wave_day_010_boss", "goldEarned": 27}
  ],
  "playerChoiceStates": [
    {"playerId": "player_guardian", "packetId": "reward_packet_day_008_runner_mix", "state": "locked", "choiceType": "card"},
    {"playerId": "player_guardian", "packetId": "reward_packet_day_009_priority_intro", "state": "temporary_locked", "choiceType": "card"}
  ],
  "temporaryLockPolicy": {"afterSeconds": 25, "onlyUnlockedRows": true, "canRevert": true},
  "reversibleUntil": "before_first_paid_shop_vote",
  "forbiddenSummaryTextTags": ["triple_reward", "stack_bonus", "rarity_up", "extra_choice"],
  "forbiddenBonusFields": ["goldMultiplier", "rarityBonus", "extraCardChoices", "stackClearBonus"]
}
```

`displayMode: compressed_rows`는 기본 겹치기 한도 3개까지 사용합니다.

이후 아티팩트로 겹치기 한도가 늘어나면 `paged_rows`로 나누어 표시하고, 한 화면에 3개를 넘겨 쌓지 않습니다.

### RewardChoiceLock 데이터

`RewardChoiceLock`은 플레이어가 보상 팩 하나에서 카드 선택 또는 골드 거절을 잠근 상태입니다.

보상 후보를 새로 만드는 데이터가 아니라, 이미 생성된 `WaveRewardPacket`에 대한 플레이어의 선택 기록입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 보상 선택 잠금 ID |
| `settlementBatchId` | string | 연결 `SettlementBatch.id` |
| `rewardPacketId` | string | 연결 `WaveRewardPacket.id` |
| `playerId` | string | 선택한 플레이어 |
| `choiceType` | enum | `card`, `decline_for_gold`, `temporary_card`, `pending_curse_confirm` |
| `chosenCardId` | string/null | 선택한 카드 ID |
| `declineGoldAdded` | number | 거절로 더해질 파티 골드 |
| `isTemporary` | boolean | 제한 시간으로 임시 잠금되었는지 |
| `reversalDeadline` | enum | `before_first_paid_shop_vote`, `shop_end_reconnect_only`, `none` |
| `requiresExplicitConfirm` | boolean | 저주 또는 특수 카드 확인 필요 여부 |
| `sourceReasonTags` | string[] | 후보 표시 근거 태그 |
| `forbiddenLockTags` | string[] | 금지 처리 태그 |

검증 규칙:

- `choiceType: card`이면 `chosenCardId`가 `candidateCardIdsByPlayer[playerId]` 안에 있어야 합니다.
- `choiceType: decline_for_gold`이면 `chosenCardId`는 null이어야 하고, `declineGoldAdded`는 `WaveRewardPacket.declineGold`와 같아야 합니다.
- `choiceType: temporary_card`는 안전 후보만 사용할 수 있고, `isTemporary`가 true여야 합니다.
- 저주 카드는 `temporary_card`가 될 수 없고, 반드시 `pending_curse_confirm` 이후 확정됩니다.
- `forbiddenLockTags`에는 보상 배율, 희귀도 보정, 카드 후보 수 증가, 강제 저주, 파티 강요를 포함합니다.

### RewardToMaintenanceGate 데이터

`RewardToMaintenanceGate`는 보상 화면에서 상점, 이벤트, 다음 웨이브 예고로 넘어갈 수 있는지 판단하는 UI 게이트입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 게이트 ID |
| `runId` | string | 연결 런 ID |
| `settlementBatchId` | string/null | 직전 정산 묶음 |
| `pendingRewardChoiceLockIds` | string[] | 아직 끝나지 않은 개인 보상 선택 |
| `pendingCurseConfirmIds` | string[] | 아직 끝나지 않은 저주 확인 |
| `nextScreenType` | enum | `wave_preview`, `event_contract`, `artifact_choice`, `shop`, `mvp_result` |
| `firstPaidShopVoteStarted` | boolean | 이전 보상 되돌리기 마감 여부 |
| `maintenanceSummaryTags` | string[] | 정비 메모에 표시할 공개 태그 |
| `forbiddenGateTags` | string[] | 금지 처리 태그 |

`RewardToMaintenanceGate`는 개인 선택이 끝나지 않았을 때 파티 유료 투표를 열 수 없습니다.

이미 선택을 끝낸 플레이어에게는 상점 미리보기와 덱 보기만 허용합니다.

### WavePreviewCard 데이터

`WavePreviewCard`는 하루 시작 예고와 겹치기 투표 UI에 쓰는 짧은 카드입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 예고 카드 ID |
| `waveId` | string | 연결 웨이브 ID |
| `cardType` | enum | `question`, `lane`, `enemy_role`, `response`, `tempo`, `boss` |
| `priority` | number | 표시 우선순위 |
| `titleTextId` | string | 제목 문구 ID |
| `bodyTextId` | string | 본문 문구 ID |
| `direction` | enum/null | 관련 실제 스폰 방향 |
| `waveIntentId` | string/null | 관련 `WaveIntent.id` |
| `enemyRoleProfileIds` | string[] | 관련 적 역할 프로필 |
| `responseTags` | string[] | 표시할 대응 태그 |
| `warningTags` | string[] | 연결 경고 태그 |
| `forbiddenTextTags` | string[] | 카드 문구에 들어가면 안 되는 태그 |

예시:

```json
{
  "id": "preview_card_day_006_response",
  "waveId": "wave_day_006_breaker_intro",
  "cardType": "response",
  "priority": 2,
  "titleTextId": "preview_title_response_open",
  "bodyTextId": "preview_body_repair_sacrifice_rebuild",
  "direction": "east",
  "waveIntentId": "intent_planned_structure_break",
  "enemyRoleProfileIds": ["enemy_role_profile_breaker"],
  "responseTags": ["repair_window", "sacrifice_value", "rear_rebuild"],
  "warningTags": ["marked_structure"],
  "forbiddenTextTags": ["required_class", "guaranteed_solution", "reward_bonus"]
}
```

## 튜토리얼 데이터

튜토리얼 데이터는 강제 조작 순서가 아니라, 어떤 판단을 언제 안전하게 보여줄지 정의합니다.

### 튜토리얼 장면 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 튜토리얼 장면 ID |
| `phaseIndex` | number | 학습 묶음 태그 |
| `sceneIndex` | number | 1~8 장면 번호 |
| `teachesTags` | string[] | 이 장면에서 가르칠 핵심 태그 |
| `allowedCards` | string[] | 표시 가능한 카드 |
| `enemyIds` | string[] | 등장 적 |
| `successCriteriaTags` | string[] | 성공 판정 조건 |
| `retryPolicy` | object | 실패 시 즉시 재시도 규칙 |
| `hintEscalation` | object[] | 10초, 20초, 35초, 60초 힌트 단계 |
| `lockedActionTags` | string[] | 아직 막아둘 행동 |
| `unlockTags` | string[] | 완료 후 해제되는 행동 |
| `linkedFirstSessionDays` | number[] | 첫 10일에서 다시 확인할 일자 |

예시:

```json
{
  "id": "tutorial_step_004_no_full_block",
  "phaseIndex": 2,
  "sceneIndex": 4,
  "teachesTags": ["no_full_block", "path_preview"],
  "allowedCards": ["card_basic_barricade"],
  "enemyIds": ["enemy_gray_march"],
  "successCriteriaTags": ["saw_block_reject", "placed_valid_barricade"],
  "retryPolicy": {"canRetryImmediately": true, "baseDamageFatal": false},
  "hintEscalation": [
    {"afterSeconds": 10, "hintLevel": 1, "hintId": "hint_show_blocked_path"},
    {"afterSeconds": 35, "hintLevel": 3, "hintId": "hint_show_two_valid_tiles"}
  ],
  "lockedActionTags": ["wave_stack_call"],
  "unlockTags": ["path_bend_ready"],
  "linkedFirstSessionDays": [2]
}
```

### 첫 세션 체크포인트 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `day` | number | 1~10 |
| `linkedTutorialPhase` | number | 되묻는 학습 단계 |
| `expectedLearningTag` | string | 플레이어가 이해해야 할 문장 태그 |
| `requiredObservedActionTags` | string[] | 관찰하고 싶은 행동 |
| `forbiddenPressureTags` | string[] | 첫 세션에서 금지할 과부하 |
| `revisitTutorialStepId` | string/null | 실패 후 제안할 튜토리얼 장면 |

첫 세션 체크포인트는 보상이나 난이도를 바꾸지 않습니다.

패배 분석과 힌트 표시가 어떤 튜토리얼 장면을 다시 제안할지 연결하는 데이터입니다.

### FirstSessionDayContract 데이터

`FirstSessionDayContract`는 첫 10일 각 일자가 플레이어에게 남겨야 할 학습 약속을 묶는 데이터입니다.

이 데이터는 웨이브, 보상, 힌트, 리포트를 같은 문장으로 연결하기 위한 계약이며, 적 수나 보상량을 직접 보정하지 않습니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `day` | number | 1~10 |
| `waveId` | string | 연결 웨이브 ID |
| `linkedTutorialStepIds` | string[] | 되짚을 튜토리얼 장면 |
| `learningPromiseTag` | string | 해당 일자가 남겨야 할 핵심 감각 |
| `expectedPlayerSentenceTextId` | string | 플레이어가 말하길 기대하는 문장 |
| `primaryWaveIntentId` | string | 핵심 웨이브 의도 |
| `maxStrongQuestionCount` | number | 첫 세션 강한 질문 수, 기본 1 |
| `maxSpawnDirectionCount` | number | 실제 스폰 방향 최대 수 |
| `allowedMistakeTags` | string[] | 허용할 실수 |
| `recoverySignalTags` | string[] | 실수 후 읽힘을 돕는 표시 |
| `rewardProfileId` | string/null | 연결 카드 보상 프로필 |
| `shopProfileId` | string/null | 연결 상점 프로필 |
| `reportRecallTags` | string[] | 웨이브 후 리포트가 회수할 태그 |
| `defeatRevisitTutorialStepId` | string/null | 패배 시 제안할 장면 |
| `forbiddenPressureTags` | string[] | 해당 일자에서 금지할 과부하 |
| `forbiddenOutcomeTags` | string[] | 결과/보상에서 금지할 처리 |

예시:

```json
{
  "day": 6,
  "waveId": "wave_day_006_destroyer_intro",
  "linkedTutorialStepIds": ["tutorial_step_005_structure_break"],
  "learningPromiseTag": "repair_or_abandon_marked_structure",
  "expectedPlayerSentenceTextId": "first_session_sentence_day_006_save_or_sacrifice",
  "primaryWaveIntentId": "intent_planned_structure_break",
  "maxStrongQuestionCount": 1,
  "maxSpawnDirectionCount": 1,
  "allowedMistakeTags": ["tries_to_save_every_structure"],
  "recoverySignalTags": ["marked_structure", "repair_ping_candidate", "sacrifice_value_preview"],
  "rewardProfileId": "reward_profile_first_010_phase_004_collapse",
  "shopProfileId": null,
  "reportRecallTags": ["planned_collapse", "repair_or_abandon", "rear_rebuild"],
  "defeatRevisitTutorialStepId": "tutorial_step_005_structure_break",
  "forbiddenPressureTags": ["unwarned_structure_delete", "runner_burst_pair", "multi_direction_overload"],
  "forbiddenOutcomeTags": ["personal_blame", "damage_rank", "forced_auto_rebuild"]
}
```

첫 세션 계약은 플레이어가 성공했는지 판정하기 위한 시험지가 아닙니다.

해당 일자의 웨이브와 보상이 같은 학습 문장을 향하고 있는지 확인하는 제작 기준입니다.

### 첫 10일 문구/훈련 연결 데이터

`FirstSessionCopyTrainingBridge`는 첫 10일의 짧은 UI 문구, 튜토리얼 재방문, 훈련 장면, 도감 카드를 같은 학습 태그로 연결합니다.

이 데이터는 보상, 난이도, 적 수를 바꾸지 않습니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 연결 데이터 ID |
| `dayRange` | number[] | 적용 일자 범위 |
| `learningPromiseTag` | string | 연결되는 첫 세션 학습 태그 |
| `triggerSurface` | enum | `wave_preview`, `combat_hint`, `post_wave_recap`, `defeat_card`, `reward_reason`, `boss_result` |
| `triggerCauseTags` | string[] | 문구나 재방문 제안을 여는 원인 태그 |
| `copyKeyId` | string | 사용할 `MvpUiCopyKeyLock.id` |
| `linkedTutorialStepId` | string/null | 되돌아갈 튜토리얼 장면 |
| `linkedTrainingScenarioId` | string/null | 연결 훈련 장면 |
| `linkedEncyclopediaEntryId` | string/null | 연결 도감 카드 |
| `offerButtons` | string[] | `short_practice`, `three_line_entry`, `carry_note`, `close` 중 표시 |
| `maxOffersPerDay` | number | 하루 최대 제안 횟수 |
| `autoOpen` | boolean | 항상 false |
| `forbiddenCopyTags` | string[] | 금지 문구 태그 |

첫 10일 연결:

| ID | 일자 | 문구 키 | 연결 재방문 | 제안 조건 |
| --- | ---: | --- | --- | --- |
| `bridge_first_001_path` | 1 | `copy_first_path_anchor` | `tutorial_step_001_path_tower` | 첫 설치 지연, 경로 미확인 |
| `bridge_first_002_no_full_block` | 2 | `copy_first_no_full_block` | `tutorial_step_004_no_full_block` | 완전 길막 시도 |
| `bridge_first_003_004_runner` | 3~4 | `copy_first_runner_slow` | `training_scenario_runner_slowdown` | 빠른 적 누수 반복 |
| `bridge_first_005_shop_context` | 5 | `copy_first_shop_context` | `encyclopedia_entry_shop_context` | 구매 강제 오해 |
| `bridge_first_006_007_structure_mark` | 6~7 | `copy_first_structure_mark` | `training_scenario_breaker_rebuild` | 표식 구조물 연쇄 붕괴 |
| `bridge_first_008_009_stack_tempo` | 8~9 | `copy_first_stack_tempo` | `encyclopedia_entry_wave_stack_tempo` | 겹치기 보상 오해 |
| `bridge_first_010_boss_part` | 10 | `copy_first_boss_part` | `training_scenario_boss_part_focus` | 본체 집중, 부위 방치 |

예시:

```json
{
  "id": "bridge_first_006_007_structure_mark",
  "dayRange": [6, 7],
  "learningPromiseTag": "repair_or_abandon_marked_structure",
  "triggerSurface": "post_wave_recap",
  "triggerCauseTags": ["marked_structure_destroyed", "tried_to_save_every_structure"],
  "copyKeyId": "copy_first_structure_mark",
  "linkedTutorialStepId": "tutorial_step_005_structure_break",
  "linkedTrainingScenarioId": "training_scenario_breaker_rebuild",
  "linkedEncyclopediaEntryId": "encyclopedia_entry_structure_mark",
  "offerButtons": ["short_practice", "three_line_entry", "carry_note", "close"],
  "maxOffersPerDay": 1,
  "autoOpen": false,
  "forbiddenCopyTags": ["personal_blame", "forced_training", "required_card", "reward_bonus"]
}
```

`short_practice`는 실제 런 자원과 덱을 변경하지 않는 훈련 장면만 엽니다.

`carry_note`는 새 런 준비 화면의 한 줄 메모로만 이어지며, 직업, 카드, 아티팩트, 활성 방향을 자동으로 바꾸지 않습니다.

## 전투 경고 데이터

`CombatWarningSignal`은 전투 중 위험을 화면에 올릴지, 핑 후보로 접어둘지 판단하는 표시 데이터입니다.

이 데이터는 플레이어 행동을 실행하지 않고, 경고 강도와 관련 핑 후보만 제공합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 경고 ID |
| `waveId` | string | 연결 웨이브 ID |
| `warningTag` | string | 경고 태그 |
| `level` | enum | `notice`, `warning`, `critical` |
| `sourceType` | enum | `preview`, `enemy`, `structure`, `boss`, `hand`, `stack` |
| `direction` | enum/null | 관련 실제 방향 |
| `targetType` | enum/null | `tile`, `enemy`, `structure`, `boss_part`, `hand`, `wave_stack_button` |
| `targetId` | string/null | 대상 ID |
| `waveIntentId` | string/null | 관련 `WaveIntent.id` |
| `enemyRoleProfileIds` | string[] | 관련 적 역할 프로필 |
| `responseTagsSuggested` | string[] | 제안 가능한 대응 태그 |
| `suggestedPingTypes` | string[] | 플레이어가 펼칠 수 있는 핑 후보 |
| `etaSeconds` | number/null | 기지, 구조물, 패턴 도달까지 남은 예상 시간 |
| `expectedBaseDamage` | number/null | 이 경고가 해소되지 않을 때 예상되는 기지 피해 |
| `baseHealthStateAtShown` | enum/null | `stable`, `danger`, `critical`, `collapse` |
| `priorityScore` | number | 화면 우선순위 계산값 |
| `shownAsMajorWarning` | boolean | 큰 경고로 표시 중인지 |
| `majorWarningSlotPolicyId` | string/null | 큰 경고 슬롯 점유와 밀어내기 규칙 |
| `createdAt` | number/string | 생성 시점 |
| `escalateAt` | number/string/null | 더 강한 경고로 승격될 수 있는 시점 |
| `expireAt` | number/string | 자동 제거 시점 |
| `suppressedByActionTags` | string[] | 경고를 낮추는 행동 태그 |
| `forbiddenActionTags` | string[] | 경고가 직접 실행하면 안 되는 행동 태그 |

예시:

```json
{
  "id": "warning_day_006_east_marked_structure",
  "waveId": "wave_day_006_breaker_intro",
  "warningTag": "structure_marked",
  "level": "warning",
  "sourceType": "structure",
  "direction": "east",
  "targetType": "structure",
  "targetId": "structure_east_barricade_03",
  "waveIntentId": "intent_planned_structure_break",
  "enemyRoleProfileIds": ["enemy_role_profile_breaker"],
  "responseTagsSuggested": ["repair_window", "sacrifice_value", "rear_rebuild"],
  "suggestedPingTypes": ["repair", "hold", "path_check"],
  "etaSeconds": 3.2,
  "expectedBaseDamage": null,
  "baseHealthStateAtShown": "stable",
  "priorityScore": 74,
  "shownAsMajorWarning": true,
  "majorWarningSlotPolicyId": "major_warning_slot_default_2",
  "createdAt": 16.8,
  "escalateAt": 20.0,
  "expireAt": 25.0,
  "suppressedByActionTags": ["repair_card_used", "structure_sacrificed", "rear_rebuild_started"],
  "forbiddenActionTags": ["auto_play_card", "auto_move_structure", "auto_spend_mana"]
}
```

자동 경고는 동시에 큰 표시 2개까지만 허용합니다.

세 번째 이후 경고는 위험 알림 목록에 접히며, `critical` 경고가 생기면 기존 `warning` 표시를 밀어낼 수 있습니다.

### 기지 도달 경고 프로필

`BaseBreachWarningProfile`은 적이 기지에 도달하기 전 몇 초 동안 어떤 경고와 핑 후보를 보여줄지 정의합니다.

이 데이터는 피해량을 바꾸지 않고, 플레이어가 마지막 대응을 할 수 있는 표시와 후보만 제공합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 기지 도달 경고 프로필 ID |
| `level` | enum | `notice`, `warning`, `critical`, `boss_reach` |
| `etaSecondsMin` | number/null | 표시 시작 예상 시간 하한 |
| `etaSecondsMax` | number/null | 표시 시작 예상 시간 상한 |
| `expectedDamageMin` | number | 표시를 강제할 최소 예상 피해 |
| `fatalIfUnanswered` | boolean | 해소되지 않으면 기지 체력 0 가능성이 있는지 |
| `baseHealthStates` | string[] | 이 프로필이 적용되는 기지 체력 상태 |
| `displayPriority` | number | 다른 전투 경고와의 우선순위 |
| `maxMajorInstances` | number | 동시에 크게 표시 가능한 개수 |
| `suggestedPingTypes` | string[] | 펼칠 수 있는 핑 후보 |
| `suppressedByActionTags` | string[] | 경고를 낮추거나 닫는 행동 태그 |
| `forbiddenTextTags` | string[] | UI 문구에서 금지할 태그 |

예시:

```json
{
  "id": "base_breach_warning_critical_mvp",
  "level": "critical",
  "etaSecondsMin": 0,
  "etaSecondsMax": 3,
  "expectedDamageMin": 1,
  "fatalIfUnanswered": true,
  "baseHealthStates": ["critical"],
  "displayPriority": 98,
  "maxMajorInstances": 1,
  "suggestedPingTypes": ["control", "focus_fire", "move_killzone", "hold"],
  "suppressedByActionTags": ["enemy_delayed", "enemy_killed", "rear_rebuild_started", "wave_stack_vote_held"],
  "forbiddenTextTags": ["reward_bonus", "required_class", "inactive_direction"]
}
```

`boss_reach` 프로필은 일반 기지 경고와 같은 데이터를 쓰지만, 보스 전용 카운트다운 슬롯을 사용합니다.

보스 전용 카운트다운은 일반 큰 경고 2개 제한 안으로 접지 않습니다.

## 핑 데이터

핑 데이터는 협동 요청을 전장 위에 짧게 남기기 위한 표시 상태입니다.

핑은 다른 플레이어의 행동을 강제하지 않고, 카드 사용이나 자원 사용을 자동 실행하지 않습니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 핑 ID |
| `pingType` | enum | `repair`, `focus_fire`, `path_check`, `taunt_shift`, `control`, `move_killzone`, `boss_part_focus`, `wave_call_suggest`, `hold`, `consumable` |
| `sourceType` | enum | `player`, `warning`, `tutorial` |
| `sourcePlayerId` | string/null | 플레이어가 만든 핑일 때의 ID |
| `targetType` | enum | `tile`, `enemy`, `structure`, `boss_part`, `direction`, `wave_stack_button` |
| `targetId` | string/null | 대상 ID |
| `direction` | enum/null | 관련 방향 |
| `roleTag` | string/null | 관련 적 역할 또는 대응 태그 |
| `priority` | number | 표시 우선순위 |
| `createdAt` | number/string | 생성 시점 |
| `fadeAt` | number/string | 흐려지기 시작하는 시점 |
| `expireAt` | number/string | 자동 제거 시점 |
| `linkedWarningTag` | string/null | 연결된 경고 태그 |
| `linkedWarningId` | string/null | 연결된 `CombatWarningSignal.id` |
| `sourceDisplayMode` | enum | `player_owned`, `system_suggested`, `tutorial_hint` |
| `visibleToPlayerIds` | string[] | 비어 있으면 파티 전체 표시 |
| `ackPlayerIds` | string[] | 동의한 플레이어 |
| `claimedByPlayerIds` | string[] | 대응하겠다고 맡은 플레이어, 큰 표시는 최대 2명 |
| `maxClaimCount` | number | 맡음 표시 최대 인원 |
| `resolutionWindowSeconds` | number | 해소 판정 시간 |
| `resolvedByActionTags` | string[] | 실제 해소에 연결된 행동 태그 |
| `isCommand` | boolean | 항상 false |

예시:

```json
{
  "id": "ping_006_018_repair_east_barricade",
  "pingType": "repair",
  "sourceType": "player",
  "sourcePlayerId": "player_tinkerer",
  "targetType": "structure",
  "targetId": "structure_east_barricade_03",
  "direction": "east",
  "roleTag": "structure_marked",
  "priority": 3,
  "createdAt": 18.2,
  "fadeAt": 22.2,
  "expireAt": 26.2,
  "linkedWarningTag": "structure_marked",
  "linkedWarningId": "warning_day_006_east_marked_structure",
  "sourceDisplayMode": "player_owned",
  "visibleToPlayerIds": [],
  "ackPlayerIds": ["player_guardian"],
  "claimedByPlayerIds": ["player_tinkerer"],
  "maxClaimCount": 2,
  "resolutionWindowSeconds": 8,
  "resolvedByActionTags": ["repair_card_used"],
  "isCommand": false
}
```

자동 경고에서 펼친 핑 후보는 `sourceDisplayMode: system_suggested`로 시작하지만, 플레이어가 확정하기 전에는 `ping_created`로 기록하지 않습니다.

플레이어가 확정한 순간부터 직접 핑 한도와 만료 규칙을 적용합니다.

### 위험 핑 후보 프로필

`DangerPingCandidateProfile`은 자동 경고가 어떤 핑 후보를 어떤 순서로 펼칠지 정의합니다.

후보는 플레이어가 누르기 전까지 행동도, 핑도, 평가 기록도 아닙니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 위험 핑 후보 프로필 ID |
| `sourceWarningTags` | string[] | 연결 경고 태그 |
| `baseWarningLevels` | string[] | 적용되는 기지 경고 단계 |
| `candidatePingTypes` | string[] | 노출 후보 핑 |
| `maxVisibleCandidates` | number | 한 번에 보여줄 후보 수 |
| `soloDisplayMode` | enum | `self_reminder`, `party_call` |
| `requiresPlayerConfirm` | boolean | 항상 true |
| `hideWhenActionTags` | string[] | 후보를 숨길 조건 |
| `forbiddenActionTags` | string[] | 후보가 자동 실행하면 안 되는 행동 |
| `forbiddenTextTags` | string[] | 후보 문구에서 금지할 태그 |

예시:

```json
{
  "id": "danger_ping_base_breach_critical_mvp",
  "sourceWarningTags": ["base_breach"],
  "baseWarningLevels": ["critical"],
  "candidatePingTypes": ["control", "focus_fire", "move_killzone", "hold"],
  "maxVisibleCandidates": 4,
  "soloDisplayMode": "self_reminder",
  "requiresPlayerConfirm": true,
  "hideWhenActionTags": ["target_already_dead", "inactive_direction"],
  "forbiddenActionTags": ["auto_play_card", "auto_spend_mana", "auto_move_structure"],
  "forbiddenTextTags": ["reward_bonus", "required_class", "personal_blame"]
}
```

### 방향 대체 규칙

원본 웨이브의 선호 방향이 비활성 상태라면 `directionRole`에 따라 대체 방향을 고릅니다.

| `directionRole` | 우선 대체 |
| --- | --- |
| `short` | 동쪽, 그 다음 활성 방향 중 기본 이동 시간이 가장 짧은 방향 |
| `slow` | 북쪽, 그 다음 활성 방향 중 기본 이동 시간이 가장 긴 방향 |
| `fast` | 서쪽, 그 다음 활성 방향 중 돌파형 압박에 적합한 방향 |
| `killzone` | 남쪽, 그 다음 활성 방향 중 굴곡이 많은 방향 |
| `any` | 현재 일자에 가장 덜 사용된 활성 방향 |

대체 결과가 플레이어에게 불공정해지면 웨이브 자체를 약화시키고, 비활성 방향을 억지로 열지 않습니다.

## 보스 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 보스 ID |
| `nameKo` | string | 표시명 |
| `baseHp` | number | 스케일링 전 본체 체력 |
| `speed` | number | 이동 속도 |
| `pathWidth` | number | 보스 경로 폭 |
| `parts` | object[] | 부위 목록 |
| `patterns` | object[] | 패턴 목록 |
| `onReachBase` | object | 기지 도달 처리 |
| `recommendedFirstPartId` | string/null | 첫 보스에서 은은하게 추천할 첫 부위 |
| `firstBossPhasePlanId` | string/null | 첫 보스 전투 흐름 ID |
| `companionWavePolicyId` | string/null | 동반 웨이브 제한 정책 ID |
| `failureCauseTags` | string[] | 보스 결과 화면과 상점 추천에 연결할 원인 태그 |

보스 부위:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 부위 ID |
| `nameKo` | string | 표시명 |
| `baseHp` | number | 스케일링 전 부위 체력 |
| `targetPriority` | number | UI 추천 우선순위 |
| `activeEffect` | object | 살아 있을 때 효과 |
| `destroyReward` | object | 파괴 보상 |
| `bodyDamageShare` | number | 부위 피해 중 본체 체력으로 전이되는 비율 |

보스 실제 체력은 `RunState.scalingProfileId`가 가리키는 스케일링 프로필로 계산합니다.

보스 경로 폭, 기지 도달 예고, 부위 보상 구조는 인원수에 따라 바꾸지 않습니다.

예시:

```json
{
  "id": "boss_silent_colossus",
  "nameKo": "침묵의 거상",
  "baseHp": 120,
  "speed": 0.35,
  "pathWidth": 3,
  "recommendedFirstPartId": "boss_part_legs",
  "firstBossPhasePlanId": "boss_phase_plan_silent_colossus_010",
  "companionWavePolicyId": "boss_companion_policy_silent_colossus_010",
  "failureCauseTags": [
    "boss_legs_ignored",
    "boss_front_ignored",
    "boss_lantern_ignored",
    "defense_overclustered",
    "stack_overreach"
  ],
  "parts": [
    {
      "id": "boss_part_front",
      "nameKo": "전면부",
      "baseHp": 35,
      "targetPriority": 2,
      "activeEffect": {"patternId": "boss_pattern_crushing_hand", "interval": 12},
      "destroyReward": {"patternIntervalOverride": 20, "structureDamageMultiplier": 0.70},
      "bodyDamageShare": 0.30
    },
    {
      "id": "boss_part_legs",
      "nameKo": "다리부",
      "baseHp": 50,
      "targetPriority": 1,
      "activeEffect": {"movementMultiplier": 1.00},
      "destroyReward": {"movementMultiplier": 0.75, "knockbackResistDelta": -0.10},
      "bodyDamageShare": 0.30
    },
    {
      "id": "boss_part_lantern",
      "nameKo": "등불부",
      "baseHp": 25,
      "targetPriority": 3,
      "activeEffect": {"drawGaugeGainMultiplierNearBoss": 0.80},
      "destroyReward": {"drawCardsForAllPlayers": 1},
      "bodyDamageShare": 0.30
    }
  ],
  "patterns": [
    {"id": "boss_pattern_silent_stride", "trigger": "always"},
    {"id": "boss_pattern_crushing_hand", "trigger": "interval"},
    {"id": "boss_pattern_lantern_gloom", "trigger": "bodyHpBelow70AndLanternAlive"},
    {"id": "boss_pattern_last_reach", "trigger": "baseOuterRingReached"}
  ],
  "onReachBase": {"firstDamage": 15, "secondDamageDelay": 5}
}
```

### 첫 보스 전투 단계 데이터

첫 보스의 이 흐름은 보스 본체 데이터와 분리합니다.

같은 침묵의 거상이라도 20일 변형이나 테스트 모드에서는 다른 단계 계획을 붙일 수 있어야 합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 보스 단계 계획 ID |
| `bossId` | string | 연결된 보스 ID |
| `day` | number | 기본 등장 일자 |
| `phaseSteps` | object[] | 전투 흐름 |
| `roleCheckProfileId` | string | 직업별 대응 체크 ID |
| `companionWavePolicyId` | string | 동반 웨이브 제한 정책 ID |
| `resultBridgeTags` | string[] | 보상, 상점, 다음 일자 예고에 연결할 태그 |

예시:

```json
{
  "id": "boss_phase_plan_silent_colossus_010",
  "bossId": "boss_silent_colossus",
  "day": 10,
  "roleCheckProfileId": "boss_role_check_silent_colossus_010",
  "companionWavePolicyId": "boss_companion_policy_silent_colossus_010",
  "phaseSteps": [
    {
      "index": 1,
      "id": "boss_phase_010_entry_warning",
      "trigger": "preCombat",
      "focusTags": ["path_width", "recommended_part_legs"],
      "forbiddenTags": ["damage", "companion_wave_start"]
    },
    {
      "index": 2,
      "id": "boss_phase_010_legs_focus",
      "trigger": "bossEnteredOuterRing",
      "focusTags": ["slow_boss", "part_focus"],
      "recommendedPartId": "boss_part_legs"
    },
    {
      "index": 3,
      "id": "boss_phase_010_crush_choice",
      "trigger": "firstCrushWarning",
      "focusTags": ["save_or_sacrifice_structure", "front_part_optional"]
    },
    {
      "index": 4,
      "id": "boss_phase_010_lantern_choice",
      "trigger": "bodyHpBelow70AndLanternAlive",
      "focusTags": ["draw_gauge_pressure", "lantern_part_choice"]
    },
    {
      "index": 5,
      "id": "boss_phase_010_last_reach",
      "trigger": "baseOuterRingReached",
      "focusTags": ["final_delay", "spend_remaining_cards"]
    },
    {
      "index": 6,
      "id": "boss_phase_010_result_bridge",
      "trigger": "bossCombatResolved",
      "focusTags": ["failure_cause", "artifact_shop_bridge"]
    }
  ],
  "resultBridgeTags": ["next_10_days_pressure", "shop_recommendation", "artifact_choice"]
}
```

첫 보스 단계 계획은 핵심 전투 흐름으로 시작합니다.

각 단계는 UI 힌트, 플레이테스트 지표, 전투 리포트 태그 중 최소 1개와 연결되어야 합니다.

### MVP 보스 수치 프로필 데이터

`BossNumericProfile`은 보스 본체 데이터와 분리된 일자별 수치 잠금입니다.

같은 보스라도 10일 첫 등장, 20일 변형, 30일 예고형은 서로 다른 검증 질문을 가지므로 별도 프로필로 관리합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 수치 프로필 ID |
| `bossId` | string | 연결 보스 ID |
| `day` | number | 등장 일자 |
| `bodyHp` | number | 2인 기준 본체 체력 |
| `bodySpeed` | number | 2인 기준 이동 속도 |
| `pathWidth` | number | 보스 경로 폭 |
| `partHp` | object | 부위별 2인 기준 체력 |
| `patternTiming` | object | 패턴 주기와 예고 시간 |
| `reachPolicy` | object | 기지 도달 피해와 예고 |
| `variantPolicyId` | string/null | 변형 선택 규칙 |
| `companionPolicyId` | string/null | 동반 웨이브 정책 |
| `forbiddenRewardFields` | string[] | 존재하면 안 되는 보상 필드 |
| `directionConstraintTags` | string[] | 활성 방향 제한 태그 |

MVP 보스 수치 프로필:

| ID | 보스 | 일자 | 본체 | 부위 | 패턴 잠금 |
| --- | --- | ---: | ---: | --- | --- |
| `boss_numeric_profile_silent_colossus_010` | `boss_silent_colossus` | 10 | 120 | 전면부 35, 다리부 50, 등불부 25 | 짓누르기 12초, 전면부 파괴 후 20초, 등불부 70% |
| `boss_numeric_profile_silent_colossus_variant_020` | `boss_silent_colossus_variant` | 20 | 150 | 전면부 42, 다리부 58, 등불부 32 | 기본 주기 유지, 변형 1개만 적용 |
| `boss_numeric_profile_observer_preview_030` | `boss_season_observer_preview` | 30 | 165 | 관측핵 55 | 흐린 관측 28초, 후보 6/10초, 실제 확정 3/6초 전 |

예시:

```json
{
  "id": "boss_numeric_profile_silent_colossus_variant_020",
  "bossId": "boss_silent_colossus_variant",
  "day": 20,
  "bodyHp": 150,
  "bodySpeed": 0.35,
  "pathWidth": 3,
  "partHp": {
    "boss_part_front": 42,
    "boss_part_legs": 58,
    "boss_part_lantern": 32
  },
  "patternTiming": {
    "crushIntervalSeconds": 12,
    "crushIntervalAfterFrontDestroyedSeconds": 20,
    "crushWarningSeconds": 4,
    "lanternTriggerBodyHpPercent": 70
  },
  "reachPolicy": {
    "firstDamage": 15,
    "secondDamageDelaySeconds": 5
  },
  "variantPolicyId": "boss_variant_policy_silent_colossus_020",
  "companionPolicyId": "boss_companion_policy_silent_colossus_020",
  "forbiddenRewardFields": ["goldBonus", "extraCardChoices", "rarityBonus", "bossShardBonus"],
  "directionConstraintTags": ["active_directions_only", "no_new_direction_from_variant"]
}
```

20일 변형 정책:

| 변형 ID | 적용 조건 태그 | 변경값 | 금지 |
| --- | --- | --- | --- |
| `boss_variant_fast_lantern_020` | `draw_starved`, `disruptor_ignored` | `lanternTriggerBodyHpPercent: 80` | 등불부 효과량 증가 |
| `boss_variant_short_crush_warning_020` | `structure_marked_missed`, `repair_late` | `crushWarningSeconds: 3` | 짓누르기 주기 단축 |
| `boss_variant_weak_companion_020` | `single_target_overfocus`, `lane_neglected` | `spawn_packet_day_020_optional_gray_companion` 활성 | 보상 증가, 강한 동반 웨이브 |

20일 변형은 한 런에서 하나만 적용합니다.

30일 관측자 예고형 정책:

- 후보 방향 수는 `min(2, activeDirections.length)`입니다.
- 1인은 후보 방향과 실제 방향이 항상 `east`입니다.
- 실제 스폰 방향은 한 번에 1개만 확정합니다.
- 관측핵 생존 시 후보 표시 6초, 실제 확정 스폰 3초 전입니다.
- 관측핵 파괴 후 후보 표시 10초, 실제 확정 스폰 6초 전입니다.
- 30일 보스 스폰 플랜은 28일 웨이브 겹치기 호출 대상이 아닙니다.

`forbiddenRewardFields`는 보스 수치 프로필에도 반드시 들어갑니다.

보스 부위 파괴, 동반 웨이브, 관측핵 파괴는 보상 팩, 카드 후보, 희귀도, 골드, 보스 파편을 늘릴 수 없습니다.

### 보스 시간 예산 데이터

`BossEncounterBudgetProfile`은 보스전의 목표 시간, 반복 패턴 상한, 시간 초과 시 조정 순서를 정의합니다.

이 데이터는 보스 체력을 자동 보정하는 장치가 아니라 플레이테스트와 제작 검증 기준입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 보스 시간 예산 ID |
| `bossId` | string | 연결 보스 ID |
| `day` | number | 기본 등장 일자 |
| `targetDurationSeconds` | object | 목표 최소/최대 시간 |
| `warningDurationSeconds` | number | 피로 경고선 |
| `hardCapSeconds` | number | 실패 검토선 |
| `phaseBudgetSeconds` | object | 단계별 권장 시간 |
| `patternRepeatCaps` | object | 패턴별 반복 상한 |
| `companionWaveCap` | number | 보스전 중 동반 웨이브 상한 |
| `overBudgetAdjustmentOrder` | string[] | 시간 초과 시 조정 순서 |
| `forbiddenAdjustmentTags` | string[] | 시간 문제 해결에 쓰면 안 되는 조정 |

보스 시간 예산 프로필:

| ID | 보스 | 일자 | 목표 | 경고 | 반복 상한 |
| --- | --- | ---: | ---: | ---: | --- |
| `boss_budget_silent_colossus_010` | `boss_silent_colossus` | 10 | 120~210초 | 240초 | 짓누르기 4회 |
| `boss_budget_silent_colossus_variant_020` | `boss_silent_colossus_variant` | 20 | 150~228초 | 270초 | 변형 1종, 동반 1회 |
| `boss_budget_observer_preview_030` | `boss_season_observer_preview` | 30 | 180~270초 | 300초 | 흐린 관측 3회 |
| `boss_budget_overheated_colossus_040` | `boss_overheated_colossus` | 40 | 180~288초 | 330초 | 열 자취 3회, 짓누르기 3회 |
| `boss_budget_observer_enhanced_050` | `boss_season_observer` | 50 | 210~300초 | 360초 | 이중 예고 3회 |
| `boss_budget_fallen_belltower_060` | `boss_fallen_belltower` | 60 | 210~300초 | 360초 | 무음 권역 4회 |
| `boss_budget_belltower_variant_070` | `boss_fallen_belltower_variant` | 70 | 210~312초 | 360초 | 동반 조합 1종 |
| `boss_budget_winter_gate_preview_080` | `boss_winter_gate_preview` | 80 | 240~330초 | 390초 | 결빙 권역 4회 |
| `boss_budget_winter_gate_090` | `boss_winter_gate` | 90 | 270~360초 | 420초 | 압력 회전 4회 |
| `boss_budget_winter_gate_final_100` | `boss_winter_gate_final` | 100 | 300~420초 | 480초 | 6단계 고정 |

예시:

```json
{
  "id": "boss_budget_overheated_colossus_040",
  "bossId": "boss_overheated_colossus",
  "day": 40,
  "targetDurationSeconds": {"min": 180, "max": 288},
  "warningDurationSeconds": 330,
  "hardCapSeconds": 360,
  "patternRepeatCaps": {
    "boss_pattern_heat_wake": 3,
    "boss_pattern_furnace_crush": 3,
    "boss_pattern_uncooled_shell": 2
  },
  "companionWaveCap": 1,
  "overBudgetAdjustmentOrder": [
    "trim_empty_phase_time",
    "reduce_pattern_repeats",
    "reduce_companion_wave",
    "adjust_part_hp_or_body_damage_share",
    "adjust_body_hp"
  ],
  "forbiddenAdjustmentTags": [
    "reward_bonus",
    "rarity_bonus",
    "extra_card_choice",
    "inactive_direction_spawn",
    "unavoidable_instant_death"
  ]
}
```

보스 시간 예산 텔레메트리:

| 이벤트 | 추가 필드 |
| --- | --- |
| `boss_encounter_budget_sampled` | `bossBudgetProfileId`, `bossId`, `day`, `durationSeconds`, `targetMinSeconds`, `targetMaxSeconds`, `warningExceeded` |
| `boss_pattern_loop_capped` | `bossBudgetProfileId`, `patternId`, `repeatCount`, `repeatCap`, `skippedOrConverted` |
| `boss_encounter_budget_exceeded` | `bossBudgetProfileId`, `durationSeconds`, `hardCapSeconds`, `largestOverBudgetPhaseId`, `recommendedAdjustmentTag` |

## 전투 리포트 데이터

전투 리포트 데이터는 웨이브 후 짧은 요약과 패배 분석 카드를 만들기 위한 기록입니다.

플레이어 순위표나 개인 책임 계산에 사용하지 않습니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `waveId` | string | 대상 웨이브 ID |
| `day` | number | 일자 |
| `result` | enum | `cleared`, `failed` |
| `waveIntentId` | string | 이 웨이브가 물었던 의도 |
| `askedQuestionTag` | string | 리포트에 회수할 핵심 질문 |
| `previewCardIds` | string[] | 전투 전에 보여준 예고 카드 |
| `responseTagsOffered` | string[] | 예고에서 열어준 대응 태그 |
| `responseTagsUsed` | string[] | 실제 전투 중 사용된 대응 태그 |
| `missingResponseTags` | string[] | 열려 있었지만 거의 쓰이지 않은 대응 태그 |
| `primaryCauseTag` | string/null | 가장 설명력이 큰 원인 태그 |
| `secondaryCauseTags` | string[] | 보조 원인 태그, 최대 2개 |
| `breachedDirections` | object[] | 방향별 기지 피해, 누수 횟수 |
| `structureLossSummary` | object | 구조물 파괴 수, 종류, 평균 생존 시간 |
| `enemyRolePressure` | object[] | 적 역할별 압박과 대응 태그 |
| `reportCards` | object[] | 웨이브 후 회수 카드, 최대 3개 |
| `handLockSeconds` | number | 손패가 가득 차 드로우 손실이 난 시간 |
| `stackRiskSpike` | boolean | 겹치기 후 20초 안에 위험이 급증했는지 |
| `recommendationTextId` | string/null | 결과 화면에 표시할 추천 문구 ID |

예시:

```json
{
  "waveId": "wave_day_006_breaker_intro",
  "day": 6,
  "result": "failed",
  "waveIntentId": "intent_planned_structure_break",
  "askedQuestionTag": "planned_collapse",
  "previewCardIds": ["preview_card_day_006_question", "preview_card_day_006_lane", "preview_card_day_006_response"],
  "responseTagsOffered": ["repair_window", "sacrifice_value", "rear_rebuild"],
  "responseTagsUsed": ["repair_window"],
  "missingResponseTags": ["sacrifice_value", "rear_rebuild"],
  "primaryCauseTag": "structure_chain_break",
  "secondaryCauseTags": ["east_breach", "slow_response_missing"],
  "breachedDirections": [
    {"direction": "east", "baseDamageTaken": 9, "leakCount": 3}
  ],
  "structureLossSummary": {
    "destroyedCount": 4,
    "mostDestroyedType": "barricade",
    "averageSurvivalSeconds": 7.5
  },
  "enemyRolePressure": [
    {"role": "breaker", "responseTagsUsed": ["repair"], "unansweredCount": 2}
  ],
  "reportCards": [
    {
      "cardType": "question_recall",
      "textId": "report_day_006_question_recall",
      "linkedTags": ["planned_collapse"]
    },
    {
      "cardType": "missed_response",
      "textId": "report_day_006_missing_rebuild",
      "linkedTags": ["rear_rebuild"]
    }
  ],
  "handLockSeconds": 0,
  "stackRiskSpike": false,
  "recommendationTextId": "defeat_tip_protect_marked_barricade"
}
```

### 패배 분석 카드 데이터

`DefeatAnalysisCard`는 전투 리포트와 결과 회고 사이에 놓이는 짧은 원인 카드입니다.

카드는 개인 책임이 아니라 전장 사건, 반복 패턴, 다음 시도 태그만 담습니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 패배 분석 카드 ID |
| `sourceReportId` | string | 연결 `CombatReport` 또는 결과 회고 ID |
| `cardType` | enum | `breached_direction`, `structure_chain_break`, `unanswered_role`, `resource_jam`, `stack_overreach`, `boss_pattern`, `information_gap`, `next_try` |
| `priorityRank` | number | 표시 순서, 1~3 |
| `titleTextId` | string | 카드 제목 문구 |
| `summaryTextId` | string | 한 줄 요약 문구 |
| `evidenceTags` | string[] | 원인을 뒷받침하는 태그 |
| `evidenceValues` | object | 누수 횟수, 피해량, 생존 시간 같은 제한된 수치 |
| `direction` | enum/null | 관련 실제 활성 방향 |
| `mapSnapshotRef` | string/null | 짧은 전장 스냅샷 참조 |
| `replayWindowSeconds` | number | 보여줄 전장 스냅샷 길이, 5~10초 권장 |
| `linkedWarningIds` | string[] | 관련 경고 ID |
| `linkedPingIds` | string[] | 관련 핑 ID |
| `suggestedResponseTags` | string[] | 다음 시도 대응 태그, 최대 3개 |
| `nextRunSuggestionIds` | string[] | 연결 재도전 제안 ID |
| `revisitTutorialStepId` | string/null | 연결 튜토리얼 또는 훈련 장면 |
| `forbiddenBlameFields` | string[] | 개인 책임으로 읽히는 금지 필드 |

예시:

```json
{
  "id": "defeat_card_006_east_breach",
  "sourceReportId": "combat_report_day_006",
  "cardType": "breached_direction",
  "priorityRank": 1,
  "titleTextId": "defeat_card_title_east_breach",
  "summaryTextId": "defeat_card_summary_runner_repeated_east",
  "evidenceTags": ["east_breach", "fast_enemy_leaked", "path_extension_missing"],
  "evidenceValues": {"leakCount": 4, "baseDamageTaken": 9},
  "direction": "east",
  "mapSnapshotRef": "snapshot_day_006_last_breach",
  "replayWindowSeconds": 8,
  "linkedWarningIds": ["warning_base_breach_006_east_critical"],
  "linkedPingIds": ["ping_006_control_east"],
  "suggestedResponseTags": ["slow_or_knockback", "taunt_anchor", "path_extension"],
  "nextRunSuggestionIds": ["next_run_try_east_first_bend_slow"],
  "revisitTutorialStepId": "training_scenario_runner_slowdown",
  "forbiddenBlameFields": ["playerId", "damageRank", "killRank", "mistakeOwner", "pingIgnoredByPlayerId"]
}
```

### 재도전 제안 데이터

`NextRunSuggestion`은 결과 화면, 메타 진행, 새 런 준비 화면을 잇는 참고 메모입니다.

제안은 런 설정을 자동 변경하지 않고, 플레이어가 다음에 시험할 운영을 한 줄로 남깁니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 재도전 제안 ID |
| `sourceCauseTags` | string[] | 제안을 만든 패배/회고 원인 태그 |
| `suggestionType` | enum | `lane_plan`, `structure_policy`, `priority_target`, `resource_flow`, `tempo_hold`, `boss_part`, `training_revisit` |
| `displayTextId` | string | 결과 화면 문구 |
| `lobbyNoteTextId` | string | 새 런 준비 화면에 붙일 짧은 메모 |
| `activeDirectionScope` | enum | `actual_active_direction`, `direction_agnostic` |
| `suggestedResponseTags` | string[] | 연결 대응 태그, 최대 3개 |
| `linkedTrainingScenarioId` | string/null | 선택적 훈련 장면 |
| `linkedEncyclopediaEntryId` | string/null | 선택적 도감 항목 |
| `maxCarryCount` | number | 새 런 준비로 가져갈 수 있는 개수 |
| `autoApply` | boolean | 항상 false |
| `forbiddenTags` | string[] | 금지 태그 |

예시:

```json
{
  "id": "next_run_try_east_first_bend_slow",
  "sourceCauseTags": ["east_breach", "fast_enemy_leaked"],
  "suggestionType": "lane_plan",
  "displayTextId": "next_run_suggest_first_bend_slow",
  "lobbyNoteTextId": "lobby_note_try_slow_first_bend",
  "activeDirectionScope": "actual_active_direction",
  "suggestedResponseTags": ["slow_or_knockback", "path_extension"],
  "linkedTrainingScenarioId": "training_scenario_runner_slowdown",
  "linkedEncyclopediaEntryId": "encyclopedia_enemy_role_runner",
  "maxCarryCount": 2,
  "autoApply": false,
  "forbiddenTags": ["forcedClass", "forcedCard", "activeDirectionOverride", "rewardBonus", "rarityBoost"]
}
```

## MVP UI 문구 키 데이터

`MvpUiCopyKeyLock`은 보상, 압축 정산, 상점, 이벤트, 저주 계약 화면에서 반드시 사용해야 하는 현지화 키와 금지 문구 태그를 정의합니다.

임시 문자열은 MVP 빌드에서 허용하지 않습니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 문구 잠금 ID |
| `namespace` | enum | `reward`, `settlement`, `shop`, `event`, `curse`, `vote`, `runtime` |
| `requiredKey` | string | 반드시 존재해야 하는 현지화 키 |
| `defaultKo` | string | 한국어 기준 문구 |
| `defaultEn` | string | 영어 기준 문구 |
| `surfaceIds` | string[] | 이 키를 쓰는 화면 ID |
| `maxKoLength` | number | 한국어 최대 길이 |
| `forbiddenCopyTags` | string[] | 들어가면 안 되는 문구 태그 |
| `requiredSemanticTags` | string[] | 반드시 전달해야 하는 의미 |

MVP 필수 키:

| ID | 키 | 기본 문구 | 화면 |
| --- | --- | --- | --- |
| `copy_reward_pick_card` | `ui.reward.pick_card` | 카드 1장을 덱에 넣습니다. | 일반 보상 |
| `copy_reward_take_gold` | `ui.reward.take_gold` | 카드를 고르지 않고 골드를 받습니다. | 일반 보상 |
| `copy_reward_temporary_lock` | `ui.reward.temporary_lock` | 미선택 보상은 안전 후보로 임시 선택됩니다. | 일반/압축 보상 |
| `copy_reward_revert_until_shop` | `ui.reward.revert_until_shop` | 첫 유료 상점 투표 전까지 되돌릴 수 있습니다. | 임시 선택 배지 |
| `copy_settlement_row_day` | `ui.settlement.row_day` | {day}일 정산 | 압축 정산 |
| `copy_settlement_no_bonus` | `ui.settlement.no_bonus` | 각 일자의 보상을 한 화면에서 정리합니다. | 압축 정산 |
| `copy_shop_skip` | `ui.shop.skip` | 구매 없이 넘어갑니다. | 상점 |
| `copy_shop_vote_start` | `ui.shop.vote_start` | 파티 골드를 사용할까요? | 파티 구매 투표 |
| `copy_shop_timeout_decline` | `ui.shop.timeout_decline` | 시간이 끝나면 구매하지 않습니다. | 상점 제한 시간 |
| `copy_event_keep_state` | `ui.event.choice_keep_state` | 현재 상태를 유지합니다. | 이벤트 안전 선택 |
| `copy_event_timeout_safe` | `ui.event.timeout_safe` | 시간이 끝나면 안전 선택을 적용합니다. | 이벤트 제한 시간 |
| `copy_curse_confirm_title` | `ui.curse.confirm_title` | {cardName}을 받을까요? | 저주 확인 |
| `copy_curse_service_hint` | `ui.curse.service_hint` | 제거/안정화는 다음 상점부터 가능합니다. | 저주 확인 |
| `copy_curse_decline` | `ui.curse.decline` | 받지 않습니다. | 저주 확인 |
| `copy_first_path_anchor` | `ui.first_session.path_anchor` | 경로를 먼저 보고 첫 타워를 놓습니다. | 첫 10일 회수 |
| `copy_first_no_full_block` | `ui.first_session.no_full_block` | 길은 닫지 말고 돌아가게 만듭니다. | 첫 10일 회수 |
| `copy_first_runner_slow` | `ui.first_session.runner_slow` | 빠른 적은 첫 굴곡에서 몇 초만 늦춰도 됩니다. | 첫 10일 회수 |
| `copy_first_shop_context` | `ui.first_session.shop_context` | 상점은 방금 드러난 약점을 정리하는 곳입니다. | 첫 상점 회수 |
| `copy_first_structure_mark` | `ui.first_session.structure_mark` | 표식 구조물은 살릴지 버릴지 먼저 정합니다. | 첫 10일 회수 |
| `copy_first_stack_tempo` | `ui.first_session.stack_tempo` | 겹치기는 보상을 늘리지 않고 기다림을 줄입니다. | 겹치기 회수 |
| `copy_first_boss_part` | `ui.first_session.boss_part` | 보스는 본체보다 부위와 시간을 먼저 봅니다. | 첫 보스 회수 |
| `copy_revisit_short_practice` | `ui.revisit.short_practice` | 짧게 연습 | 재방문 버튼 |
| `copy_revisit_three_line_entry` | `ui.revisit.three_line_entry` | 3줄 보기 | 재방문 버튼 |
| `copy_revisit_carry_note` | `ui.revisit.carry_note` | 메모로 가져가기 | 재방문 버튼 |
| `copy_revisit_close` | `ui.revisit.close` | 닫기 | 재방문 버튼 |

예시:

```json
{
  "id": "copy_settlement_no_bonus",
  "namespace": "settlement",
  "requiredKey": "ui.settlement.no_bonus",
  "defaultKo": "각 일자의 보상을 한 화면에서 정리합니다.",
  "defaultEn": "Review each day's reward on one screen.",
  "surfaceIds": ["settlement_batch_screen"],
  "maxKoLength": 45,
  "forbiddenCopyTags": ["bonus_reward", "stack_bonus", "rarity_up", "extra_choice"],
  "requiredSemanticTags": ["no_reward_multiplier", "same_reward_rules"]
}
```

`ForbiddenCopyTag`는 금지 뉘앙스를 태그로 관리합니다.

| 태그 | 금지 의미 |
| --- | --- |
| `bonus_reward` | 보상 증가, 추가 보상, 보너스 보상 |
| `stack_bonus` | 겹치기 보너스, 3배 보상, 러시 보상 |
| `rarity_up` | 희귀도 상승, 고급 보상 확률 증가 |
| `extra_choice` | 추가 카드 후보, 선택지 증가 |
| `loss_wording` | 포기, 손해, 실패 |
| `forced_purchase` | 자동 구매, 강제 구매 |
| `forced_curse` | 강제 저주, 희생 필요, 떠안기 |
| `free_reward` | 공짜 보상, 대가 없는 이득 |
| `hidden_penalty` | 숨은 대가, 나중에 공개되는 불이익 |
| `same_maintenance_cleanup` | 방금 받은 저주를 같은 정비에서 처리 가능하다는 암시 |
| `party_pressure` | 파티를 위해, 반드시 필요 |
| `guaranteed_solution` | 정답, 최고 효율, 무조건 제거 |
| `inactive_direction` | 비활성 방향을 위험 방향으로 암시 |

## 텔레메트리 데이터

텔레메트리는 밸런스 조정을 위한 기록입니다.

플레이어 평가나 순위표로 사용하지 않습니다.

공통 필드:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `eventName` | string | 이벤트 이름 |
| `runId` | string | 런 ID |
| `day` | number/null | 관련 일자 |
| `playerCountAtStart` | number | 런 시작 인원수 |
| `activeDirections` | string[] | 런 시작 시 확정된 활성 방향 |
| `timestamp` | number/string | 기록 시점 |

### MVP 플레이테스트 대시보드 집계 데이터

플레이테스트 대시보드는 원본 텔레메트리를 그대로 나열하지 않고, 기획 질문별로 집계한 내부 진단 데이터입니다.

플레이어에게 노출되는 결과 화면이나 순위표 데이터가 아닙니다.

`PlaytestDashboardRun`:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `dashboardRunId` | string | 대시보드 집계 ID |
| `runId` | string | 원본 런 ID |
| `buildId` | string | 테스트 빌드 ID |
| `playtestGroupId` | string | 테스트 그룹 ID |
| `runMode` | string | `run_test_010`, `run_mvp_030`, `run_standard_100` |
| `playerCountAtStart` | number | 런 시작 인원수 |
| `activeDirections` | string[] | 런 시작 시 확정된 활성 방향 |
| `outcome` | string | `cleared`, `failed`, `abandoned` |
| `finalDay` | number | 종료 일자 |
| `totalDurationSeconds` | number | 총 소요 시간 |
| `combatDurationSeconds` | number | 전투 소요 시간 합 |
| `idleDurationSeconds` | number | 보상, 상점, 이벤트, 웨이브 대기 시간 합 |
| `baseDamageTotal` | number | 총 기지 피해 |
| `waveStackCount` | number | 실제 겹치기 횟수 |
| `primaryFailureTag` | string/null | 가장 설명력이 큰 실패 원인 |
| `createdAt` | number/string | 집계 생성 시점 |

`PlaytestDashboardPanel`:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `panelId` | string | 패널 ID |
| `questionTag` | string | 패널이 답해야 하는 기획 질문 |
| `sourceEventNames` | string[] | 집계에 쓰는 원본 이벤트 |
| `derivedMetricIds` | string[] | 표시할 파생 지표 |
| `redFlagRuleIds` | string[] | 위험 신호 규칙 |
| `forbiddenDisplayTags` | string[] | 대시보드에서 금지할 표시 방식 |

`PlaytestDerivedMetric`:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `metricId` | string | 파생 지표 ID |
| `unit` | string | `seconds`, `percent`, `count`, `tag` |
| `formulaDescription` | string | 사람이 읽는 계산식 설명 |
| `targetRange` | string/null | 목표 범위 |
| `segmentKeys` | string[] | `runMode`, `dayRange`, `playerCountAtStart`, `activeDirections` 등 |
| `sourceEventNames` | string[] | 계산에 필요한 이벤트 |

MVP 필수 패널:

| 패널 ID | 필수 파생 지표 | 금지 표시 |
| --- | --- | --- |
| `dashboard_run_summary` | `metric_total_duration`, `metric_final_day`, `metric_base_damage_total` | 개인 순위 |
| `dashboard_pacing` | `metric_combat_time_share`, `metric_idle_time_share`, `metric_longest_idle_bucket` | 지루함 원인을 하나로 단정 |
| `dashboard_wave_stack_tempo` | `metric_stack_usage_by_day`, `metric_stack_hold_reason`, `metric_post_stack_damage_20s` | 보상 효율 |
| `dashboard_defense_line` | `metric_base_damage_by_direction`, `metric_structure_lifetime`, `metric_path_extension_seconds` | 비활성 방향 실패 원인 |
| `dashboard_cards_resources` | `metric_hand_lock_seconds`, `metric_cards_played_per_wave`, `metric_mana_draw_spike` | 마지막 타격 기여도 |
| `dashboard_reward_shop_event` | `metric_reward_choice_time`, `metric_shop_skip_rate`, `metric_event_safe_timeout_rate`, `metric_curse_decline_rate` | 구매 강제, 저주 강제 |
| `dashboard_learning_recall` | `metric_day_contract_pass_rate`, `metric_next_run_action_clarity`, `metric_defeat_cause_match` | 개인 실수 목록 |
| `dashboard_copy_guardrail` | `metric_missing_copy_key_count`, `metric_forbidden_copy_tag_count`, `metric_reward_misunderstanding_rate` | 임시 문자열 허용 |

`PlaytestDashboardViewLayout`:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `layoutId` | string | 대시보드 화면 레이아웃 ID |
| `dashboardRunId` | string | 연결된 집계 ID |
| `topStripFields` | string[] | 상단 런 스트립에 고정 표시할 필드 |
| `panelOrder` | string[] | 패널 카드 표시 순서 |
| `defaultExpandedPanelId` | string/null | 처음 펼칠 패널 |
| `drilldownSections` | string[] | 위험 신호 상세 섹션 |
| `actionQueueRuleIds` | string[] | 다음 빌드 액션 큐 생성 규칙 |
| `comparisonKeys` | string[] | 비교 기준, `buildId`, `runMode`, `playerCountAtStart`, `activeDirections` 등 |
| `hiddenFieldTags` | string[] | 숨겨야 할 표시 태그 |

`PlaytestDashboardRedFlagRule`:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `redFlagRuleId` | string | 위험 신호 규칙 ID |
| `panelId` | string | 연결 패널 |
| `severity` | enum | `info`, `warning`, `critical` |
| `conditionDescription` | string | 사람이 읽는 조건 설명 |
| `sourceMetricIds` | string[] | 판단에 쓰는 파생 지표 |
| `sourceEventNames` | string[] | 원본 확인 이벤트 |
| `observerNoteTags` | string[] | 연결할 관찰자 메모 태그 |
| `recommendedReviewTag` | string | 먼저 검토할 제작 영역 |
| `forbiddenFixTags` | string[] | 이 신호로 제안하면 안 되는 조정 |

`PlaytestDashboardActionQueueItem`:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `actionItemId` | string | 액션 큐 항목 ID |
| `dashboardRunId` | string | 연결 대시보드 |
| `redFlagRuleId` | string | 발생한 위험 신호 |
| `hypothesisTextId` | string | 다음 테스트 가설 문구 |
| `reviewOwnerTag` | string | 검토할 제작 영역 태그 |
| `linkedDocumentIds` | string[] | 확인할 문서나 데이터 ID |
| `expectedMetricChangeIds` | string[] | 다음 테스트에서 다시 볼 지표 |
| `status` | enum | `proposed`, `accepted_for_next_build`, `deferred`, `resolved` |
| `forbiddenAutoApply` | boolean | 자동 적용 금지 여부, 항상 true |

MVP 레이아웃:

| 레이아웃 영역 | 고정 항목 | 금지 표시 |
| --- | --- | --- |
| `top_run_strip` | `buildId`, `runMode`, `playerCountAtStart`, `activeDirections`, `finalDay`, `totalDurationSeconds`, `baseDamageTotal` | 개인 이름별 성과 |
| `panel_card_grid` | 8개 MVP 패널 상태, 핵심 지표 1~3개, 가장 큰 위험 신호 | 모든 원본 로그 무제한 표시 |
| `red_flag_drilldown` | 조건, 연결 이벤트 3~5개, 관찰자 메모 요약, 가능한 의미 | 수치 하나로 원인 단정 |
| `next_build_action_queue` | 다음 테스트 가설, 확인할 문서/데이터, 다시 볼 지표 | 자동 수치 보정, 자동 보상 조정 |

MVP 위험 신호 규칙:

| 규칙 ID | 패널 | 조건 | 우선 검토 | 금지 조정 |
| --- | --- | --- | --- | --- |
| `redflag_missing_run_context` | `dashboard_run_summary` | 빌드, 런 모드, 인원수, 활성 방향 중 하나가 없음 | 텔레메트리 공통 필드 | 추정값으로 비교 |
| `redflag_idle_time_dominates` | `dashboard_pacing` | 비전투 시간이 총 시간의 40% 이상이고 피로 메모가 연결됨 | 정산/상점/웨이브 대기 UX | 적 보상 증가 |
| `redflag_stack_used_for_reward_expectation` | `dashboard_wave_stack_tempo` | 겹치기 이유 태그나 인터뷰에 보상 기대가 반복됨 | 겹치기 문구/보상 정산 표시 | 보상 배율, 희귀도 보정 |
| `redflag_post_stack_damage_spike` | `dashboard_wave_stack_tempo` | 겹친 뒤 20초 안에 기지 피해나 구조물 연쇄 파괴가 급증 | 안정 판단 UI, 위험 예고 | 겹치기 보상 증가 |
| `redflag_inactive_direction_counted` | `dashboard_defense_line` | `activeDirections` 밖 방향이 피해/실패 원인으로 집계됨 | 방향 집계 필터 | 비활성 방향 추천 |
| `redflag_hand_lock_over_target` | `dashboard_cards_resources` | 손패 8~10장 유지 시간이 목표치를 초과함 | 버리기, 저코스트 밀도, 제거 후보 표시 | 시간 경과 마나 회복 |
| `redflag_shop_choice_forced` | `dashboard_reward_shop_event` | 상점/저주/이벤트 선택을 손해 회피로만 이해함 | 선택 문구, 안전 선택, 비교 행 | 자동 구매, 강제 저주 |
| `redflag_learning_recall_failed` | `dashboard_learning_recall` | 다음 행동 설명률이나 일자 문장 회수율이 목표 미만 | 힌트/리포트/훈련 연결 | 강제 튜토리얼 |
| `redflag_forbidden_copy_detected` | `dashboard_copy_guardrail` | 금지 태그 문구 또는 임시 문자열이 발견됨 | 현지화 키와 문구 잠금 | 임시 문자열 허용 |

예시:

```json
{
  "panelId": "dashboard_wave_stack_tempo",
  "questionTag": "was_stack_used_for_tempo",
  "sourceEventNames": [
    "wave_stack_vote_started",
    "wave_stack_vote_resolved",
    "wave_stacked",
    "base_damage_taken",
    "idle_time_summary"
  ],
  "derivedMetricIds": [
    "metric_stack_usage_by_day",
    "metric_stack_hold_reason",
    "metric_post_stack_damage_20s"
  ],
  "redFlagRuleIds": [
    "redflag_stack_used_for_reward_expectation",
    "redflag_post_stack_damage_spike"
  ],
  "forbiddenDisplayTags": ["reward_efficiency", "rarity_efficiency", "player_blame"]
}
```

화면 레이아웃 예시:

```json
{
  "layoutId": "playtest_dashboard_layout_mvp",
  "dashboardRunId": "dashboard_run_010_2026_001",
  "topStripFields": [
    "buildId",
    "runMode",
    "playerCountAtStart",
    "activeDirections",
    "finalDay",
    "totalDurationSeconds",
    "baseDamageTotal"
  ],
  "panelOrder": [
    "dashboard_run_summary",
    "dashboard_pacing",
    "dashboard_wave_stack_tempo",
    "dashboard_defense_line",
    "dashboard_cards_resources",
    "dashboard_reward_shop_event",
    "dashboard_learning_recall",
    "dashboard_copy_guardrail"
  ],
  "defaultExpandedPanelId": "dashboard_pacing",
  "drilldownSections": [
    "condition",
    "source_events",
    "observer_notes",
    "possible_meaning",
    "next_test_hypothesis"
  ],
  "actionQueueRuleIds": [
    "redflag_stack_used_for_reward_expectation",
    "redflag_inactive_direction_counted",
    "redflag_learning_recall_failed"
  ],
  "comparisonKeys": ["buildId", "runMode", "playerCountAtStart", "activeDirections"],
  "hiddenFieldTags": ["player_rank", "reward_efficiency", "inactive_direction_blame"]
}
```

대시보드 집계 이벤트:

| 이벤트 | 추가 필드 |
| --- | --- |
| `playtest_dashboard_run_aggregated` | `dashboardRunId`, `runId`, `panelIds`, `metricIds`, `redFlagRuleIdsTriggered` |
| `playtest_dashboard_panel_flagged` | `dashboardRunId`, `panelId`, `redFlagRuleId`, `severity`, `recommendedReviewTag` |
| `playtest_observer_note_attached` | `dashboardRunId`, `panelId`, `noteTag`, `quoteSummary`, `linkedEventNames` |
| `playtest_dashboard_action_queued` | `dashboardRunId`, `actionItemId`, `redFlagRuleId`, `reviewOwnerTag`, `status` |

주요 이벤트:

| 이벤트 | 추가 필드 |
| --- | --- |
| `wave_started` | `waveId`, `directions`, `enemyGroups` |
| `wave_preview_shown` | `waveId`, `previewCards`, `stackRiskLevel`, `warnings` |
| `wave_stack_vote_started` | `voteSessionId`, `sourceType`, `candidateWaveIds`, `stackRiskLevel`, `requiredConsentMode` |
| `wave_stack_vote_resolved` | `voteSessionId`, `resolvedAction`, `resolvedReasonTags`, `yesCount`, `holdCount` |
| `wave_stacked` | `voteSessionId`, `stackCount`, `voters`, `baseHp`, `stackRiskLevel` |
| `wave_completed` | `duration`, `baseDamageTaken`, `destroyedStructures` |
| `base_damage_taken` | `day`, `waveId`, `direction`, `baseDamage`, `hpBefore`, `hpAfter`, `bundleId`, `wasFatal`, `reportCauseTags` |
| `base_breach_warning_raised` | `warningId`, `waveId`, `direction`, `level`, `etaSeconds`, `expectedBaseDamage`, `baseHealthStateAtShown`, `suggestedPingTypes` |
| `base_breach_warning_resolved` | `warningId`, `resolvedReasonTag`, `etaSecondsAtResolution`, `damagePreventedEstimate`, `confirmedPingType` |
| `base_recovery_purchased` | `shopSessionId`, `recoveryRuleId`, `restoreAmount`, `priceGold`, `emergencySurchargeGold`, `hpBefore`, `hpAfter` |
| `combat_tuning_sampled` | `combatTuningProfileId`, `firstEnemyContactAt`, `firstStructureDamagedAt`, `firstStructureDestroyedAt`, `firstBaseDamageAt`, `pathExtensionSeconds`, `manaGainedPerPlayer`, `drawsTriggeredPerPlayer`, `handLockSeconds` |
| `wave_spawn_packet_resolved` | `waveId`, `spawnPlanId`, `packetId`, `enemyId`, `count`, `directions`, `firstSpawnTimeSeconds`, `intervalSeconds`, `budgetUsed`, `wasStackAdvanced` |
| `wave_learning_phase_resolved` | `day`, `waveId`, `learningPhaseIndex`, `roleMixTags`, `responseTagsUsed` |
| `first_wave_role_check` | `day`, `playerId`, `classId`, `expectedResponseTags`, `observedResponseTags`, `passed` |
| `chapter_phase_resolved` | `day`, `waveId`, `chapterFlowId`, `chapterPhaseIndex`, `operationQuestionTag`, `responseTagsUsed` |
| `mvp30_day_contract_resolved` | `day`, `waveId`, `lockedLearningPromiseTag`, `dayRole`, `lockedContentTags`, `tunedFieldNames`, `forbiddenTagDetected` |
| `spring2_operation_choice_resolved` | `day`, `choiceSource`, `chosenFocusTag`, `weaknessTag`, `validatedByWaveId` |
| `observer_preview_resolved` | `bossId`, `candidateDirections`, `actualDirection`, `partDestroyed`, `reassignmentActions` |
| `overheat_tile_decision_resolved` | `day`, `tileId`, `usedAsKillzone`, `abandonedBeforeBreak`, `structureLost`, `reasonTags` |
| `overheated_colossus_phase_started` | `bossId`, `phaseIndex`, `heatSourceTags`, `activeOverheatTiles`, `shownWarningTags` |
| `marked_structure_decision_resolved` | `day`, `markedStructureId`, `markSourceId`, `saved`, `sacrificed`, `collapseValueTags` |
| `observer_enhanced_phase_started` | `bossId`, `phaseIndex`, `candidateDirections`, `candidateHeatTiles`, `markedStructureIds` |
| `leaf_path_decision_resolved` | `day`, `leafPathChangePlanId`, `movedKillzone`, `keptOriginalPath`, `reasonTags` |
| `debris_route_reopen_triggered` | `day`, `debrisTileId`, `routeReopenPolicyId`, `convertedToSteppedDebris`, `affectedDirections` |
| `fallen_belltower_phase_started` | `bossId`, `phaseIndex`, `suppressionZoneIds`, `auraReduction`, `repairReduction`, `shownWarningTags` |
| `priority_target_decision_resolved` | `day`, `priorityThreatPairId`, `firstTargetRole`, `targetChanged`, `reasonTags` |
| `split_priority_assignment_resolved` | `day`, `directions`, `assignedRoleTags`, `reassignmentActions`, `unresolvedThreatTags` |
| `belltower_variant_companion_resolved` | `bossId`, `bossCompanionVariantId`, `spawnedDirection`, `priorityTargetRole`, `resolvedBeforeZoneEnded` |
| `frost_zone_decision_resolved` | `day`, `frostZonePlanId`, `relocatedStructures`, `thawedTiles`, `remainingBuildSpaceScore` |
| `large_enemy_hold_resolved` | `day`, `largeEnemyHoldProfileId`, `holdDuration`, `leakedToBase`, `responseTagsUsed` |
| `winter_gate_preview_phase_started` | `bossId`, `phaseIndex`, `frostZoneIds`, `remainingBuildSpaceScore`, `shownWarningTags` |
| `pressure_tile_decision_resolved` | `day`, `pressureTilePlanId`, `relocationDecisionTags`, `pressureBuildSpaceScore`, `reasonTags` |
| `rear_killzone_shift_resolved` | `day`, `fromZoneId`, `toZoneId`, `structuresMoved`, `stabilizedBeforeNextPressure` |
| `winter_gate_phase_started` | `bossId`, `phaseIndex`, `pressureCandidateZones`, `pressureBuildSpaceScore`, `shownWarningTags` |
| `first_boss_phase_started` | `bossId`, `phasePlanId`, `phaseIndex`, `phaseStepId`, `activeDirections`, `shownHintTags` |
| `first_boss_role_check` | `bossId`, `playerId`, `classId`, `expectedResponseTags`, `observedResponseTags`, `passed` |
| `first_boss_failure_cause_resolved` | `bossId`, `result`, `primaryCauseTag`, `secondaryCauseTags`, `destroyedPartIds`, `companionWaveUsed` |
| `boss_encounter_budget_sampled` | `bossBudgetProfileId`, `bossId`, `durationSeconds`, `targetMinSeconds`, `targetMaxSeconds`, `warningExceeded` |
| `boss_pattern_loop_capped` | `bossBudgetProfileId`, `patternId`, `repeatCount`, `repeatCap`, `skippedOrConverted` |
| `boss_encounter_budget_exceeded` | `bossBudgetProfileId`, `durationSeconds`, `hardCapSeconds`, `largestOverBudgetPhaseId`, `recommendedAdjustmentTag` |
| `combat_warning_raised` | `warningId`, `warningTag`, `level`, `sourceType`, `direction`, `targetId`, `suggestedPingTypes` |
| `defeat_analysis_card_presented` | `cardId`, `cardType`, `priorityRank`, `causeTags`, `direction`, `suggestedResponseTags` |
| `defeat_replay_opened` | `cardId`, `replayWindowSeconds`, `openedFromResultScreen` |
| `next_run_suggestion_presented` | `suggestionId`, `sourceCauseTags`, `suggestionType`, `autoApply` |
| `next_run_suggestion_carried` | `suggestionId`, `targetFlow`, `carriedToLobby`, `linkedTrainingScenarioId` |
| `combat_report_created` | `result`, `primaryCauseTag`, `secondaryCauseTags`, `recommendationTextId` |
| `structure_lifecycle_summary` | `structureId`, `purposeTag`, `riskTags`, `finalState`, `valueTags` |
| `structure_rebuilt` | `structureId`, `previousStructureId`, `sameTile`, `rebuildPolicyId` |
| `ping_suggestion_opened` | `warningId`, `suggestedPingTypes`, `openedByPlayerId` |
| `ping_created` | `pingType`, `sourceType`, `sourceDisplayMode`, `targetType`, `direction`, `linkedWarningId`, `linkedWarningTag` |
| `ping_acknowledged` | `pingId`, `playerId`, `ackType` |
| `ping_resolved` | `pingId`, `resolvedByActionTags`, `expired`, `secondsToResolve` |
| `tutorial_step_started` | `tutorialStepId`, `phaseIndex`, `teachesTags` |
| `tutorial_step_completed` | `tutorialStepId`, `duration`, `retryCount`, `hintLevelReached`, `successCriteriaTags` |
| `onboarding_hint_shown` | `hintId`, `tutorialStepId`, `day`, `hintLevel`, `reasonTag` |
| `first_session_checkpoint` | `day`, `linkedTutorialPhase`, `expectedLearningTag`, `observedActionTags` |
| `first_session_day_contract_resolved` | `day`, `waveId`, `learningPromiseTag`, `allowedMistakeTags`, `recoverySignalTags`, `reportRecallTags`, `strongHintCount`, `playerSentenceMatched` |
| `card_reward_presented` | `day`, `playerId`, `rewardProfileId`, `lootPoolIds`, `candidateCardIds`, `candidateRarities`, `candidateRoleTags`, `candidatePoolLaneIds`, `candidateArchetypeIds`, `excludedTags` |
| `card_play_decision_resolved` | `playerId`, `cardId`, `expectedTimingWindows`, `observedTimingWindow`, `decisionQuestionMatched`, `comboHookUsed`, `missCostTriggered` |
| `card_effect_resolved` | `playerId`, `cardId`, `specProfileId`, `targetType`, `validTarget`, `manaCost`, `effectValueSummary`, `durationObserved`, `triggeredCount`, `bossPolicyApplied`, `invalidReasonTag` |
| `card_stat_budget_lock_checked` | `cardId`, `specProfileId`, `effectBudgetId`, `statBudgetLockId`, `passed`, `compensationTagsApplied`, `policyIdsApplied` |
| `card_stat_budget_violation_detected` | `cardId`, `specProfileId`, `statBudgetLockId`, `violatedAxis`, `missingCompensationTags`, `missingPolicyIds`, `blockedFromBuild` |
| `card_archetype_signal_presented` | `playerId`, `rewardProfileId`, `candidateArchetypeIds`, `currentDeckArchetypeCounts`, `signalCardIds`, `sameArchetypeCandidateCount` |
| `card_archetype_commit_resolved` | `playerId`, `archetypeId`, `commitCardId`, `commitmentLevel`, `supportCardCountBeforePick`, `picked`, `declinedForGold`, `reasonTag` |
| `card_loot_choice_resolved` | `playerId`, `rewardProfileId`, `lootPoolIds`, `pickedCardId`, `pickedRarity`, `choiceReasonTag`, `rejectedForGold`, `heroicAutoPickWarning`, `curseConsentConfirmed` |
| `card_upgrade_presented` | `shopSessionId`, `playerId`, `cardInstanceId`, `cardId`, `upgradeOptionIds`, `currentArchetypeCounts`, `recommendedByTags` |
| `card_upgrade_resolved` | `shopSessionId`, `playerId`, `cardInstanceId`, `cardId`, `selectedUpgradeOptionId`, `upgradeType`, `pricePaidGold`, `pricePaidBossShard`, `declined`, `reasonTag` |
| `class_card_pool_contract_checked` | `classId`, `poolStage`, `missingLaneIds`, `hardCounterWarnings`, `directionLockedCardIds`, `commonReplacementWarnings`, `passed` |
| `settlement_batch_opened` | `settlementBatchId`, `rewardPacketIds`, `displayMode`, `goldTotal`, `packetCount` |
| `settlement_packet_choice_locked` | `settlementBatchId`, `rewardPacketId`, `playerId`, `choiceType`, `temporaryLocked` |
| `settlement_batch_resolved` | `settlementBatchId`, `duration`, `temporaryLockCount`, `revertedChoiceCount`, `bonusFieldDetected` |
| `early_deck_choice_resolved` | `day`, `playerId`, `pickedCardId`, `choiceReasonTag`, `deckSizeAfter`, `rejectedForGold` |
| `status_effect_applied` | `statusType`, `targetGrade`, `finalMultiplier`, `convertedEffectTag` |
| `status_effect_resisted` | `statusType`, `enemyId`, `resistanceProfileId`, `feedbackTag` |
| `boss_reward_granted` | `bossId`, `gold`, `bossShards`, `artifactCandidateIds` |
| `artifact_choice_presented` | `artifactPoolId`, `candidateIds`, `equippedArtifactIds`, `nextPressureTags`, `slotState` |
| `artifact_choice_resolved` | `artifactPoolId`, `selectedArtifactId`, `voteDuration`, `reasonTags` |
| `artifact_replacement_resolved` | `selectedArtifactId`, `replacedArtifactId`, `keptCurrent`, `voteDuration`, `reasonTags` |
| `final_loadout_audit_presented` | `profileId`, `equippedArtifactIds`, `deadCardCount`, `weaknessTags`, `recommendedCommitmentTags` |
| `final_artifact_commitment_resolved` | `profileId`, `selectedArtifactId`, `replacedArtifactId`, `keptCurrent`, `artifactActionCount`, `reasonTags` |
| `final_market_lock_applied` | `profileId`, `shopSessionId`, `lockedBuildAxisTags`, `abandonedWeaknessTags`, `partyPurchasesUsed` |
| `shop_session_started` | `shopSessionId`, `day`, `itemIds`, `maxPartyPurchases`, `timeLimitSeconds` |
| `shop_purchase` | `shopSessionId`, `itemId`, `priceGold`, `priceBossShard`, `surchargeGold`, `requiresVote`, `voteResult`, `competingItemIdsViewed` |
| `shop_recommendation_shown` | `shopSessionId`, `diagnosticTags`, `nextPressureTags`, `recommendedItemIds`, `alternativeItemIds` |
| `shop_consumable_used` | `runId`, `day`, `consumableId`, `useWindow`, `targetScope`, `targetId`, `direction`, `effectValue`, `preventedDamage`, `activationPlayerId` |
| `shop_session_completed` | `shopSessionId`, `duration`, `partyPurchasesUsed`, `extensionsUsed`, `skippedPurchase`, `viewedItemCount` |
| `event_choice_presented` | `eventId`, `triggerTags`, `choiceIds`, `timeoutDefaultChoiceId` |
| `event_choice_resolved` | `eventId`, `selectedChoiceId`, `choiceOwner`, `requiresVote`, `voteDuration`, `consequenceTags` |
| `event_contract_lock_resolved` | `day`, `lockId`, `shownEventIds`, `skippedByTimeout`, `safeChoiceApplied` |
| `curse_contract_presented` | `day`, `eventId`, `playerId`, `curseContractProfileId`, `cardId`, `immediateBenefitTags`, `longTermCostTags` |
| `curse_contract_confirmed` | `day`, `eventId`, `playerId`, `curseContractProfileId`, `cardId`, `confirmDurationSeconds` |
| `curse_contract_declined` | `day`, `eventId`, `playerId`, `curseContractProfileId`, `declineReasonTag` |
| `final_phase_started` | `phaseIndex`, `dayFrom`, `dayTo`, `focusTags`, `forbiddenNewSystemTags` |
| `final_rehearsal_phase_resolved` | `chapterFlowId`, `phaseIndex`, `dayFrom`, `dayTo`, `resolvedQuestionTags`, `failedQuestionTags`, `noNewSystemPassed` |
| `final_weakness_commitment_resolved` | `shopSessionId`, `chosenFocusTags`, `abandonedWeaknessTags`, `partyPurchasesUsed`, `newArchetypeBlocked` |
| `winter_gate_final_phase_started` | `bossId`, `combatPhaseIndex`, `pressurePlanId`, `activeDirections`, `forbiddenPressureTags` |
| `final_market_resolved` | `shopSessionId`, `chosenFocusTags`, `abandonedWeaknessTags`, `partyPurchasesUsed` |
| `final_boss_phase_completed` | `phaseIndex`, `pressureZonesUsed`, `relocationsMade`, `partDestroyedIds`, `baseDamageTaken` |
| `final_result_reflection_started` | `resultId`, `outcome`, `finalDay`, `duration`, `playerCountAtStart`, `activeDirections` |
| `runtime_budget_sampled` | `runtimeBudgetProfileId`, `runMode`, `measurementStartEvent`, `measurementEndEvent`, `excludeContinueShop` |
| `runtime_segment_completed` | `runtimeBudgetProfileId`, `segmentId`, `dayFrom`, `dayTo`, `durationSeconds`, `targetMinSeconds`, `targetMaxSeconds`, `warningExceeded` |
| `runtime_activity_bucket_completed` | `runtimeBudgetProfileId`, `activityId`, `durationSeconds`, `targetMinSeconds`, `targetMaxSeconds`, `sourceEventNames` |
| `runtime_budget_exceeded` | `runtimeBudgetProfileId`, `totalDurationSeconds`, `thresholdType`, `largestOverBudgetActivityId`, `forbiddenAdjustmentTagsChecked` |
| `ui_copy_key_checked` | `copyKeyLockId`, `requiredKey`, `locale`, `surfaceId`, `missing`, `lengthExceeded`, `forbiddenCopyTagsDetected` |
| `playtest_dashboard_run_aggregated` | `dashboardRunId`, `panelIds`, `metricIds`, `redFlagRuleIdsTriggered` |
| `playtest_dashboard_panel_flagged` | `dashboardRunId`, `panelId`, `redFlagRuleId`, `severity`, `recommendedReviewTag` |
| `playtest_observer_note_attached` | `dashboardRunId`, `panelId`, `noteTag`, `quoteSummary`, `linkedEventNames` |
| `playtest_dashboard_action_queued` | `dashboardRunId`, `actionItemId`, `redFlagRuleId`, `reviewOwnerTag`, `status` |
| `decisive_moment_card_presented` | `resultId`, `momentType`, `sourceDay`, `sourcePhase`, `direction`, `riskTags` |
| `party_chronicle_saved` | `resultId`, `outcome`, `partyClassIds`, `artifactIds`, `finalDefenseSummaryTags`, `nextRunSuggestionIds` |
| `post_run_meta_progression_started` | `resultId`, `profileId`, `outcome`, `finalDay`, `learningTags` |
| `meta_unlock_resolved` | `profileId`, `unlockType`, `unlockId`, `unlockReasonTags`, `powerAffecting` |
| `encyclopedia_entry_unlocked` | `profileId`, `entryId`, `sourceEnemyId`, `sourceBossId`, `revealedInfoTags` |
| `training_scenario_unlocked` | `profileId`, `scenarioId`, `linkedFailureTags`, `linkedTutorialStepIds` |
| `knowledge_revisit_started` | `profileId`, `sourceType`, `sourceId`, `reasonTag`, `suggestedEntryIds` |
| `encyclopedia_entry_viewed` | `profileId`, `entryId`, `entryType`, `viewDuration`, `openedFrom` |
| `training_scenario_started` | `profileId`, `scenarioId`, `linkedEntryId`, `targetLearningTag`, `rewardDisabled` |
| `training_scenario_completed` | `profileId`, `scenarioId`, `attemptCount`, `usedResponseTags`, `suggestedResponseTags` |
| `knowledge_revisit_to_run_linked` | `profileId`, `scenarioId`, `entryIds`, `nextRunSuggestionId`, `forcedBuildApplied` |
| `next_run_prep_loaded` | `profileId`, `suggestionIds`, `relatedUnlockIds`, `forcedClassId`, `forcedCardIds` |
| `new_run_setup_started` | `setupId`, `sourceType`, `suggestionIds`, `previewPlayerCount`, `previewActiveDirections` |
| `lobby_active_direction_previewed` | `setupId`, `previewPlayerCount`, `previewActiveDirections`, `inactiveDirectionsShownDimmed` |
| `class_selection_resolved` | `setupId`, `playerId`, `classId`, `roleTags`, `wasSuggested`, `wasForced` |
| `party_intent_confirmed` | `setupId`, `partyIntentTextId`, `suggestionIds`, `readyPlayerIds` |
| `run_state_locked` | `setupId`, `runId`, `playerCountAtStart`, `activeDirections`, `scalingProfileId`, `seed` |
| `session_savepoint_created` | `sessionId`, `runId`, `savepointId`, `savepointType`, `currentDay`, `currentPhase` |
| `session_interrupt_detected` | `sessionId`, `playerId`, `interruptState`, `currentDay`, `combatPhase`, `wasHost` |
| `player_role_reserved` | `sessionId`, `playerId`, `classId`, `reservedUntilSeconds`, `canAiPlayCards` |
| `resume_snapshot_delivered` | `sessionId`, `playerId`, `snapshotId`, `currentDay`, `pendingVoteId`, `activeDirections` |
| `long_absence_resolved` | `sessionId`, `playerId`, `classId`, `resolutionMode`, `savepointId` |
| `session_resume_confirmed` | `sessionId`, `playerId`, `classId`, `sameRunStateConfirmed`, `remainingVoteSeconds` |
| `accessibility_readability_checked` | `playerId`, `uiScale`, `cardTextSize`, `previewCompleted` |
| `presentation_motion_adjusted` | `playerId`, `screenShakeLevel`, `cameraInertiaLevel`, `bossApproachShakeLevel` |
| `presentation_audio_adjusted` | `playerId`, `lowFrequencyBossVolume`, `warningVolume`, `pingVolume`, `captionsEnabled` |
| `tactical_visibility_assist_enabled` | `playerId`, `alwaysShowPaths`, `enemyOutlineLevel`, `bossPartHighlightLevel` |
| `coop_signal_assist_enabled` | `playerId`, `colorAssistMode`, `directionLabelMode`, `pingCaptionLog` |
| `presentation_safety_guardrail_passed` | `contentId`, `noJumpScare`, `noGore`, `noInfoObscured`, `noUiDistortion` |
| `run_failed` | `cause`, `baseHp`, `stackCount`, `mostLeakedDirection` |
| `run_completed` | `duration`, `finalDay`, `artifactIds`, `finalDefenseSummaryTags` |

`directions`는 실제 스폰 방향이고, `activeDirections`는 런에서 허용된 방향 전체입니다.

둘을 분리해 기록해야 "열린 방향은 많았지만 실제로 어느 방향에서 무너졌는지"를 볼 수 있습니다.

## 최종 구간 데이터

91~100일은 별도의 새 규칙 모음이 아니라, 기존 규칙을 어떤 순서로 다시 묻는지 정의하는 데이터입니다.

### 91~100일 최종 리허설 흐름 데이터

최종 10일은 `chapterFlowId: final_rehearsal_flow_091_100`으로 묶습니다.

| 일자 | `chapterPhaseIndex` | 구간 ID | 필수 기록 |
| ---: | ---: | --- | --- |
| 91 | 1 | `final_phase_001_last_line_check` | `finalKillzonePlanId`, `remainingStructureTags` |
| 92~94 | 2 | `final_phase_002_weakness_recheck` | `finalWeaknessCheckTags`, `resolvedWeaknessTags` |
| 95 | 3 | `final_phase_003_last_market` | `abandonedWeaknessTags`, `shopSessionId` |
| 96~97 | 4 | `final_phase_004_final_relocation` | `finalKillzonePlanId`, `longPressurePlanId` |
| 98~99 | 5 | `final_phase_005_last_stack_rehearsal` | `stackUsedForTempoOnly`, `finalRehearsalNoNewSystemTags` |
| 100 | 6 | `final_phase_006_winter_gate_final` | `finalBossPhasePlanId`, `finalDefenseSummaryTags` |

이 흐름의 필수 필드:

- `chapterFlowId`
- `chapterPhaseIndex`
- `finalWeaknessCheckTags`
- `abandonedWeaknessTags`
- `finalKillzonePlanId`
- `longPressurePlanId`
- `finalBossPhasePlanId`
- `finalRehearsalNoNewSystemTags`

`finalRehearsalNoNewSystemTags`에는 91~100일에 새 적, 새 타일, 새 상태이상, 새 아키타입 시작, 겹치기 보상 증가가 들어오지 않았는지 기록합니다.

### 최종 장비 마감 데이터

`FinalLoadoutClosureProfile`은 91~100일에서 덱, 아티팩트, 상점 선택을 어디까지 바꿀 수 있는지 정의합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 최종 장비 마감 프로필 ID |
| `auditDay` | number | 최종 점검을 보여주는 일자, 기본 91 |
| `finalMarketDay` | number | 마지막 상점을 여는 일자, 기본 95 |
| `lockAfterDay` | number | 이후 장비/상점 선택을 잠그는 일자, 기본 95 |
| `artifactPoolId` | string | 95일에 사용할 최종 아티팩트 후보 풀 |
| `shopSessionId` | string | 95일 마지막 상점 세션 |
| `maxPartyPurchases` | number | 큰 파티 구매 한도, 기본 2 |
| `maxArtifactActions` | number | 아티팩트 교체 행동 한도, 기본 1 |
| `abandonedWeaknessTagCount` | object | 포기한 약점 최소/최대 개수 |
| `lockedBuildAxisTags` | string[] | 유지하기로 확정한 운영 축 |
| `forbiddenLateOfferTags` | string[] | 91일 이후 후보에서 제외할 효과 태그 |
| `telemetryEvents` | string[] | 이 흐름에서 기록할 이벤트 |

최종 장비 마감 프로필:

| ID | 점검 | 마지막 상점 | 잠금 | 아티팩트 행동 | 포기 약점 | 금지 핵심 |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| `final_loadout_closure_091_100` | 91 | 95 | 95 | 1회 | 1~2개 | 새 아키타입, 슬롯 증가, 겹치기 보상, 희귀도 보정 |

예시:

```json
{
  "id": "final_loadout_closure_091_100",
  "auditDay": 91,
  "finalMarketDay": 95,
  "lockAfterDay": 95,
  "artifactPoolId": "artifact_pool_final_closure_095",
  "shopSessionId": "shop_session_day_095_final_market",
  "maxPartyPurchases": 2,
  "maxArtifactActions": 1,
  "abandonedWeaknessTagCount": { "min": 1, "max": 2 },
  "lockedBuildAxisTags": ["keep_core_loop", "final_killzone_support"],
  "forbiddenLateOfferTags": [
    "new_archetype_starter",
    "artifact_slot_increase",
    "wave_stack_reward",
    "card_candidate_increase",
    "rarity_boost",
    "inactive_direction_pressure"
  ],
  "telemetryEvents": [
    "final_loadout_audit_presented",
    "final_artifact_commitment_resolved",
    "final_market_lock_applied"
  ]
}
```

`artifact_pool_final_closure_095`는 새 빌드 시작형이 아니라 기존 운영 마감형 아티팩트만 포함합니다.

후보 방향:

- 위치 이전, 후방 킬존, 보스 부위 대응
- 손패 막힘 완화, 방치 카드 안정화, 수리/오라 위험 완화
- 빠른 적, 방해형, 구조물 파괴 중 1개 약점 완화

제외 방향:

- 슬롯 증가
- 웨이브 겹치기 보상 증가
- 웨이브 겹치기 최대치 신규 증가
- 카드 후보 수 증가
- 카드 희귀도 보정
- 비활성 방향 압박
- 새 아키타입 시작형 효과

최종 장비 마감 텔레메트리:

| 이벤트 | 필드 |
| --- | --- |
| `final_loadout_audit_presented` | `profileId`, `equippedArtifactIds`, `deadCardCount`, `weaknessTags`, `recommendedCommitmentTags` |
| `final_artifact_commitment_resolved` | `profileId`, `selectedArtifactId`, `replacedArtifactId`, `keptCurrent`, `artifactActionCount`, `reasonTags` |
| `final_market_lock_applied` | `profileId`, `shopSessionId`, `lockedBuildAxisTags`, `abandonedWeaknessTags`, `partyPurchasesUsed` |

### 100일 결과 회고 데이터

100일 결과 화면은 `final_result_reflection_flow`로 구성합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 결과 회고 ID |
| `outcome` | enum | `victory`, `defeat`, `abandoned` |
| `finalDay` | number | 종료 일자 |
| `durationSeconds` | number | 전체 플레이 시간 |
| `playerCountAtStart` | number | 런 시작 인원수 |
| `activeDirections` | string[] | 런에서 열린 방향 |
| `finalKillzonePlanId` | string/null | 마지막 방어선 요약 |
| `finalRelocationCount` | number | 최종 방어선 이전 횟수 |
| `heldStructureIds` | string[] | 오래 버틴 핵심 구조물 |
| `abandonedWeaknessTags` | string[] | 95일에 포기한 약점 |
| `finalShopChoiceTags` | string[] | 마지막 상점 선택 |
| `decisiveMomentCards` | object[] | 결정적 장면 카드, 최대 3장 |
| `defeatAnalysisCardIds` | string[] | 패배일 때 연결되는 `DefeatAnalysisCard.id`, 최대 3개 |
| `nextRunSuggestionIds` | string[] | 다음 런 제안, 최대 2개 |
| `partyChronicleId` | string/null | 저장된 파티 기록 |
| `forbiddenScoreFields` | string[] | 결과 화면에 쓰지 않을 개인 점수 필드 |

`decisiveMomentCards`는 개인별 딜량이나 실수 기록이 아니라 방향, 구조물, 위험 태그, 보스 단계 같은 전장 사건만 사용합니다.

`defeatAnalysisCardIds`는 `outcome: defeat`일 때만 결과 화면의 원인 카드 영역에 표시합니다.

`forbiddenScoreFields`에는 `damageRank`, `killRank`, `mistakeOwner`, `stackRewardEfficiency`처럼 협동 회고를 개인 평가나 보상 효율로 바꾸는 필드를 넣습니다.

### 런 이후 메타 진행 데이터

런 이후 메타 진행은 `post_run_meta_flow`로 구성합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `profileId` | string | 플레이어 또는 파티 프로필 ID |
| `sourceResultId` | string | 연결된 결과 회고 ID |
| `reachedDayBand` | string | 도달 구간, 예: `day_001_010`, `day_091_100` |
| `learningTags` | string[] | 반복된 실패 원인, 포기한 약점, 자주 쓴 대응 |
| `discoveredEnemyIds` | string[] | 이번 런에서 만난 적 |
| `discoveredBossPartIds` | string[] | 본 보스 부위 |
| `unlockedCardPoolIds` | string[] | 새로 열린 카드 후보 풀 |
| `unlockedArtifactPoolIds` | string[] | 새로 열린 아티팩트 후보 풀 |
| `encyclopediaEntryIds` | string[] | 새로 열린 도감 항목 |
| `trainingScenarioIds` | string[] | 새로 열린 훈련 장면 |
| `cosmeticUnlockIds` | string[] | 새 외형 보상 |
| `nextRunSuggestionIds` | string[] | 다음 런 준비 제안, 최대 2개 |
| `forbiddenPowerFields` | string[] | 메타 진행에 쓰지 않는 파워 필드 |

`forbiddenPowerFields`에는 `permanentAttackBonus`, `permanentStructureHpBonus`, `permanentManaRegen`, `stackRewardMultiplier`, `rarityBoostFromMeta`를 넣습니다.

메타 해금 조건은 도달 구간, 발견, 학습 태그, 보스 조우, 튜토리얼 재방문 같은 정보성 조건을 우선합니다.

딜량, 처치 수, 웨이브 겹치기 횟수, 개인 실수 태그는 메타 해금량을 늘리는 조건으로 쓰지 않습니다.

### 도감/훈련장 재방문 데이터

도감과 훈련장은 `knowledge_revisit_flow`로 구성합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 재방문 흐름 ID |
| `sourceType` | enum | `defeat`, `result`, `meta_unlock`, `main_menu`, `manual` |
| `reasonTag` | string | 재방문을 제안한 이유 |
| `entryType` | enum | `enemy`, `boss_part`, `structure`, `status`, `wave_stack`, `class_role` |
| `entryId` | string | 연결된 도감 항목 |
| `trainingScenarioId` | string/null | 연결된 훈련 장면 |
| `targetLearningTag` | string | 확인할 단일 학습 태그 |
| `sourceObjectId` | string/null | 연결된 패배 카드, 결과 회고, 적, 보스 부위 ID |
| `reasonTextId` | string | 재방문 이유 카드 문구 |
| `entrySummaryTextIds` | string[] | 3줄 도감 카드 문구 |
| `allowedResponseTags` | string[] | 유효 대응 태그 |
| `suggestedResponseTags` | string[] | 훈련 후 보여줄 다른 가능성, 최대 2개 |
| `durationTargetSeconds` | number | 30~60초 권장 |
| `exitOptions` | string[] | `retry`, `view_entry`, `carry_to_lobby`, `close` 중 노출할 선택 |
| `rewardDisabled` | boolean | 실제 보상 지급 여부, 항상 true |
| `forcedBuildApplied` | boolean | 자동 빌드 적용 여부, 항상 false |
| `forbiddenTrainingTags` | string[] | 금지 태그 |

`forbiddenTrainingTags`에는 `realReward`, `metaPowerGain`, `rankScore`, `forcedClass`, `forcedCard`, `inactiveDirectionSpawn`, `multiRuleLesson`을 넣습니다.

훈련 장면은 하나의 학습 태그만 다룹니다.

방해형 우선 처치와 웨이브 겹치기 판단을 한 장면에 함께 넣지 않습니다.

### 훈련 장면 프로필 데이터

`TrainingScenarioProfile`은 실제 런을 복사하지 않고, 하나의 판단만 떼어낸 작은 전장을 정의합니다.

훈련 장면은 실전 보상이 없고, 플레이어 평가나 잠금 조건으로 사용하지 않습니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 훈련 장면 ID |
| `titleTextId` | string | 훈련 제목 |
| `targetLearningTag` | string | 이 장면에서 확인할 단일 학습 태그 |
| `sourceCauseTags` | string[] | 연결 패배/회고 원인 태그 |
| `entryType` | enum | `enemy`, `boss_part`, `structure`, `status`, `wave_stack`, `class_role` |
| `entryId` | string | 연결 도감 항목 |
| `microMapId` | string | 훈련 전장 ID |
| `activeDirectionPolicy` | enum | `use_actual_active_direction`, `solo_east_only`, `direction_agnostic` |
| `enemyGroupIds` | string[] | 등장 적 묶음 |
| `structurePresetIds` | string[] | 미리 놓인 구조물이나 후보 위치 |
| `trainingHandProfileId` | string | 고정 훈련 손패 |
| `seedMana` | number | 훈련 시작 마나 |
| `durationTargetSeconds` | number | 목표 소요 시간, 30~60초 |
| `hintEscalation` | object[] | 시간별 힌트 단계 |
| `successSignalTags` | string[] | 성공으로 볼 관찰 태그 |
| `softFailureSignalTags` | string[] | 다시 시도 제안 태그 |
| `resultCompareTags` | string[] | 사용 대응과 다른 가능성 비교 태그 |
| `rewardDisabled` | boolean | 항상 true |
| `runStateMutationDisabled` | boolean | 항상 true |
| `forbiddenTags` | string[] | 금지 태그 |

예시:

```json
{
  "id": "training_scenario_runner_slowdown",
  "titleTextId": "training_title_runner_slowdown",
  "targetLearningTag": "slow_fast_enemy_at_first_bend",
  "sourceCauseTags": ["fast_enemy_leaked", "short_path_unreinforced"],
  "entryType": "enemy",
  "entryId": "encyclopedia_enemy_role_runner",
  "microMapId": "micro_map_east_first_bend",
  "activeDirectionPolicy": "solo_east_only",
  "enemyGroupIds": ["training_group_runner_003"],
  "structurePresetIds": ["training_tile_first_bend", "training_tile_taunt_anchor"],
  "trainingHandProfileId": "training_hand_slow_or_taunt_basic",
  "seedMana": 3,
  "durationTargetSeconds": 45,
  "hintEscalation": [
    {"afterSeconds": 10, "hintLevel": 1, "hintTag": "show_first_bend"},
    {"afterSeconds": 25, "hintLevel": 2, "hintTag": "show_slow_candidate"}
  ],
  "successSignalTags": ["runner_delayed_before_base", "first_bend_used"],
  "softFailureSignalTags": ["runner_passed_first_bend_fast"],
  "resultCompareTags": ["slow_or_knockback", "taunt_anchor", "path_extension"],
  "rewardDisabled": true,
  "runStateMutationDisabled": true,
  "forbiddenTags": ["realReward", "deckMutation", "inactiveDirectionSpawn", "rankScore"]
}
```

### 최종 구간 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 최종 구간 ID |
| `phaseIndex` | number | 최종 리허설 구간 번호 |
| `dayFrom` | number | 시작 일자 |
| `dayTo` | number | 종료 일자 |
| `focusTags` | string[] | 이 단계가 확인할 핵심 압박 |
| `allowedWaveIds` | string[] | 사용할 웨이브 ID |
| `forbiddenNewSystemTags` | string[] | 새 규칙 추가 방지 태그 |
| `shopSessionId` | string/null | 연결 상점 |
| `bossPhaseId` | string/null | 연결 보스 단계 |
| `successCriteriaTags` | string[] | 성공 판정용 태그 |

예시:

```json
{
  "id": "final_phase_003_last_market",
  "phaseIndex": 3,
  "dayFrom": 95,
  "dayTo": 95,
  "focusTags": ["abandon_weakness", "last_shop", "final_build_lock"],
  "allowedWaveIds": ["wave_day_095_last_market"],
  "forbiddenNewSystemTags": ["new_archetype", "wave_stack_reward", "inactive_direction_pressure"],
  "shopSessionId": "shop_session_day_095_final_market",
  "bossPhaseId": null,
  "successCriteriaTags": ["max_two_party_purchases", "abandoned_weakness_recorded"]
}
```

최종 구간 데이터는 보상 총량, 웨이브 겹치기 보상, 활성 방향을 바꾸지 않습니다.

### 최종 보스 단계 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 보스 단계 ID |
| `bossId` | string | `boss_winter_gate_final` |
| `phaseIndex` | number | 1~3 |
| `pressureZoneCount` | number | 기본 1, 최종 단계에서만 제한적으로 증가 |
| `pressureZoneDurationRule` | enum | `until_phase_end` |
| `companionWaveTags` | string[] | 동반 웨이브 역할 태그 |
| `relocationWindowSeconds` | number | 단계 사이 짧은 재배치 시간 |
| `forbiddenPressureTags` | string[] | 경로 차단, 비활성 방향 압박 등 금지 |

장기 압력 권역은 설치 권역 압박이며 경로 타일 차단이 아닙니다.

## 보스 보상 데이터

보스 보상 데이터는 보스 처치 후 어떤 순서로 성장 화면을 열지 정의합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 보스 보상 ID |
| `bossId` | string | 대상 보스 ID |
| `day` | number | 등장 일자 |
| `goldReward` | number | 파티 골드 보상 |
| `bossShardReward` | number | 보스 파편 보상 |
| `artifactCandidateCount` | number | 기본 아티팩트 후보 수 |
| `artifactPoolId` | string | 사용할 아티팩트 후보 풀 |
| `personalCardReward` | boolean | 개인 카드 보상 여부 |
| `personalCardRewardLockId` | string/null | 개인 보스 카드 보상 잠금 ID |
| `settlementScenarioId` | string | 보스 결산 시나리오 ID |
| `nextShopSessionId` | string | 이어서 열 상점 세션 |
| `nextPreviewDay` | number | 상점 후 예고할 일자 |

예시:

```json
{
  "id": "boss_reward_day_010_silent_colossus",
  "bossId": "boss_silent_colossus",
  "day": 10,
  "goldReward": 35,
  "bossShardReward": 1,
  "artifactCandidateCount": 3,
  "artifactPoolId": "artifact_pool_foundation_010",
  "personalCardReward": true,
  "personalCardRewardLockId": "loot_lock_boss_010",
  "settlementScenarioId": "boss_settlement_scenario_010_foundation",
  "nextShopSessionId": "shop_session_after_day_010",
  "nextPreviewDay": 11
}
```

첫 보스의 부위 파괴는 추가 보스 파편을 주지 않습니다.

부위 파괴 보상은 전투 중 패턴 약화, 이동 속도 감소, 카드 드로우처럼 즉시 체감되는 효과로 처리합니다.

MVP 보스 보상 잠금:

| ID | 일자 | 보스 | 골드 | 파편 | 아티팩트 풀 | 다음 화면 | 성과 보정 |
| --- | ---: | --- | ---: | ---: | --- | --- | --- |
| `boss_reward_day_010_silent_colossus` | 10 | `boss_silent_colossus` | 35 | 1 | `artifact_pool_foundation_010` | `shop_session_after_day_010` | 없음 |
| `boss_reward_day_020_silent_colossus_variant` | 20 | `boss_silent_colossus_variant` | 45 | 1 | `artifact_pool_branch_020` | `shop_session_after_day_020` | 없음 |
| `boss_reward_day_030_season_observer_preview` | 30 | `boss_season_observer_preview` | 50 | 1 | `artifact_pool_mvp_result_030` | 계속하기 선택 시 `shop_session_after_day_030_mvp_result` | 없음 |

### 보스 결산 시나리오 데이터

`BossSettlementScenario`는 보스 리포트 태그가 개인 카드 후보 이유, 아티팩트 후보 축, 상점 추천으로 어떻게 연결되는지 정의합니다.

이 데이터는 보상 품질을 올리는 장치가 아니라, 보스 결과 화면과 다음 정비 화면의 설명을 일관되게 만드는 연결표입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 결산 시나리오 ID |
| `day` | number | 적용 일자 |
| `bossRewardId` | string | 연결되는 `BossRewardData.id` |
| `primaryReportTagIds` | string[] | 결과 리포트에서 사용할 핵심 태그 |
| `personalCardRewardLockId` | string | 개인 보스 카드 잠금 ID |
| `artifactPoolId` | string | 아티팩트 후보 풀 ID |
| `shopSessionId` | string/null | 이어지는 상점 세션 ID |
| `continueRequiredForShop` | boolean | 계속하기 선택 후에만 상점을 열지 여부 |
| `tagToRewardReasonRules` | object[] | 리포트 태그별 카드/아티팩트/상점 연결 규칙 |
| `forbiddenSettlementTags` | string[] | 결산에서 절대 만들 수 없는 결과 태그 |
| `notes` | string | 설계 의도 |

MVP 결산 시나리오:

| ID | 일자 | 카드 잠금 | 아티팩트 풀 | 상점 | 핵심 질문 |
| --- | ---: | --- | --- | --- | --- |
| `boss_settlement_scenario_010_foundation` | 10 | `loot_lock_boss_010` | `artifact_pool_foundation_010` | `shop_session_after_day_010` | 첫 운영 축을 무엇으로 세울 것인가? |
| `boss_settlement_scenario_020_branch` | 20 | `loot_lock_boss_020` | `artifact_pool_branch_020` | `shop_session_after_day_020` | 기존 운영을 보완할 것인가, 위험한 전환을 감수할 것인가? |
| `boss_settlement_scenario_030_mvp_result` | 30 | `loot_lock_boss_030` | `artifact_pool_mvp_result_030` | `shop_session_after_day_030_mvp_result` | MVP 이후에도 현재 운영을 유지할 것인가? |

예시:

```json
{
  "id": "boss_settlement_scenario_020_branch",
  "day": 20,
  "bossRewardId": "boss_reward_day_020_silent_colossus_variant",
  "primaryReportTagIds": [
    "draw_starved",
    "structure_marked_missed",
    "single_target_overfocus",
    "lane_neglected",
    "build_axis_confirmed"
  ],
  "personalCardRewardLockId": "loot_lock_boss_020",
  "artifactPoolId": "artifact_pool_branch_020",
  "shopSessionId": "shop_session_after_day_020",
  "continueRequiredForShop": false,
  "tagToRewardReasonRules": [
    {
      "reportTagId": "build_axis_confirmed",
      "cardReasonTags": ["archetype_commit", "heroic_gate_candidate"],
      "artifactBuildAxisBias": ["boss", "tempo"],
      "shopRecommendationIds": ["shop_heroic_tune"],
      "requiresExistingBuild": true
    }
  ],
  "forbiddenSettlementTags": [
    "increase_card_reward_choices",
    "increase_card_rarity",
    "boss_shard_bonus_from_part_break",
    "wave_stack_reward_bonus",
    "inactive_direction_reward"
  ],
  "notes": "20일 결산은 준비된 빌드를 마무리할 수 있지만 새 영웅 빌드를 강제하지 않는다."
}
```

## 아티팩트 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 아티팩트 ID |
| `nameKo` | string | 표시명 |
| `rarity` | enum | `common`, `rare`, `heroic` |
| `effect` | object | 장착 효과 |
| `tradeoff` | object/null | 대가 또는 제한 |
| `tags` | string[] | 빌드 태그 |
| `maxStacks` | number | 중첩 가능 수 |
| `buildAxis` | enum | `taunt`, `debris`, `splash`, `aura`, `draw`, `boss`, `route`, `tempo`, `survival` |
| `pressureTags` | string[] | 어떤 다음 압박에 대응하는지 |
| `roleTags` | string[] | 어떤 파티 역할을 강화하는지 |
| `tradeoffSeverity` | enum | `none`, `low`, `medium`, `high` |
| `replacementHintTags` | string[] | 교체 판단에 사용할 태그 |
| `conflictArtifactIds` | string[] | 함께 장착하면 과도하거나 의미가 줄어드는 아티팩트 |
| `isLateBuildStarter` | boolean | 91일 이후 후보 풀에서 제외할 새 빌드 시작형 여부 |
| `slotModifier` | number | 슬롯 수 변화. 기본 0, 최대 적용 후 총 슬롯 4 |
| `stackLimitModifier` | number | 웨이브 겹치기 한도 변화. 기본 0 |
| `forbiddenEffectTags` | string[] | 이 아티팩트가 절대 제공하면 안 되는 효과 태그 |
| `uiWarningTags` | string[] | 선택 화면과 전투 HUD에 표시할 위험 문구 태그 |

중요 제한:

- 웨이브 겹치기 최대치 증가는 아티팩트 효과로만 허용합니다.
- 웨이브 겹치기 보상 증가 효과는 만들지 않습니다.
- 희귀도 보정 효과도 만들지 않습니다.
- 슬롯 증가 효과를 적용해도 총 아티팩트 슬롯은 4개를 넘지 않습니다.
- `isLateBuildStarter`가 true인 아티팩트는 91일 이후 기본 후보 풀에서 제외합니다.
- `artifact_pool_final_095`는 95일 최종 보스 약점 보완용 원본 풀입니다.
- `artifact_pool_final_closure_095`는 `artifact_pool_final_095`에서 새 아키타입 시작형, 슬롯 증가, 웨이브 겹치기 최대치 신규 증가 아티팩트를 제외한 95일 실제 상점 후보 풀입니다.
- 이미 장착한 웨이브 겹치기 한도 아티팩트는 유지할 수 있지만, 95일 상점에서 새로 추천하지 않습니다.

예시:

```json
{
  "id": "artifact_unstable_clock",
  "nameKo": "불안정한 시계",
  "rarity": "rare",
  "effect": {
    "kind": "modify_wave_stack_limit",
    "amount": 1
  },
  "tradeoff": {
    "kind": "increase_structure_damage_taken_during_stacked_waves",
    "amount": 0.20
  },
  "tags": ["tempo", "wave_stack", "risk_tradeoff"],
  "maxStacks": 1,
  "buildAxis": "tempo",
  "pressureTags": ["stack_risk_spike", "structure_chain_break"],
  "roleTags": ["tempo_control", "shared_risk"],
  "tradeoffSeverity": "medium",
  "replacementHintTags": ["tradeoff_risk_high", "next_pressure_fit"],
  "conflictArtifactIds": ["artifact_reverse_hourglass"],
  "isLateBuildStarter": false,
  "slotModifier": 0,
  "stackLimitModifier": 1,
  "forbiddenEffectTags": [
    "gold_multiplier",
    "card_candidate_count_bonus",
    "card_rarity_bonus",
    "boss_shard_bonus",
    "kill_resource_total_bonus"
  ],
  "uiWarningTags": ["no_reward_increase", "stack_structure_damage_up"],
  "notes": "숙련 파티의 대기 시간을 줄이지만 겹친 전투의 구조물 위험을 실제로 올린다."
}
```

### 아티팩트 후보 풀 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 후보 풀 ID |
| `artifactIds` | string[] | 포함 아티팩트 ID |
| `excludeArtifactIds` | string[] | 기본 후보에서 제외할 아티팩트 ID |
| `requiredBuildAxisDiversity` | number | 후보 3개 안에 필요한 최소 운영 축 수 |
| `nextPressureTags` | string[] | 이 풀을 고를 때 연결되는 다음 압박 태그 |
| `lateBuildStarterAllowed` | boolean | 새 빌드 시작형 허용 여부 |
| `notes` | string | 설계 의도 |

예시:

```json
{
  "id": "artifact_pool_foundation_010",
  "artifactIds": [
    "artifact_cracked_bell",
    "artifact_old_observation_lens",
    "artifact_broken_crown",
    "artifact_whispering_nail",
    "artifact_blue_capacitor",
    "artifact_last_lantern"
  ],
  "excludeArtifactIds": ["artifact_unstable_clock"],
  "requiredBuildAxisDiversity": 3,
  "nextPressureTags": ["foundation", "first_pressure_check"],
  "lateBuildStarterAllowed": true,
  "notes": "첫 보스 후에는 기본 운영 방향을 고르게 하고, 웨이브 겹치기 최대치 증가는 20일 이후로 미룸"
}
```

MVP 후보 풀:

| ID | 적용 | 포함 후보 | 제외 후보 | 목적 |
| --- | --- | --- | --- | --- |
| `artifact_pool_foundation_010` | 10일 보스 후 | `artifact_cracked_bell`, `artifact_old_observation_lens`, `artifact_broken_crown`, `artifact_whispering_nail`, `artifact_blue_capacitor`, `artifact_last_lantern` | `artifact_unstable_clock`, `artifact_silent_vault` | 첫 운영 방향 선택 |
| `artifact_pool_branch_020` | 20일 보스 후 | 10일 미장착 후보, `artifact_overheated_amp_core`, `artifact_black_anchor`, `artifact_unstable_clock` | `artifact_silent_vault` | 첫 빌드 보완과 위험한 전환 |
| `artifact_pool_mvp_result_030` | 30일 MVP 후 | 모든 MVP 후보, `artifact_silent_vault` 확장 후보 | 보상 증가형 아티팩트 전체 | 31일 이후 유지/교체 예고 |

아티팩트 후보 풀 검증 규칙:

- `artifactCandidateCount`는 기본 3입니다.
- 후보 3개 안에는 최소 3개 이상의 `buildAxis`가 들어가야 합니다.
- 10일 후보 풀에는 `stackLimitModifier`가 1 이상인 아티팩트를 넣지 않습니다.
- 20일 이후 `stackLimitModifier`가 있는 후보는 `uiWarningTags`에 `no_reward_increase`를 반드시 가집니다.
- 아티팩트 풀은 비활성 방향을 새 스폰 압박으로 열지 않습니다.
- 아티팩트 풀은 카드 희귀도, 카드 후보 수, 골드 총량, 보스 파편을 늘리는 효과를 포함하지 않습니다.

### 아티팩트 선택 세션 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 선택 세션 ID |
| `day` | number | 발생 일자 |
| `artifactPoolId` | string | 사용할 후보 풀 |
| `candidateCount` | number | 기본 3 |
| `equippedArtifactIds` | string[] | 현재 장착 중인 아티팩트 |
| `slotLimit` | number | 현재 슬롯 수 |
| `replacementRequired` | boolean | 빈 슬롯이 없어 교체가 필요한지 |
| `keepCurrentAllowed` | boolean | 현재 유지 선택 허용 여부 |
| `timeLimitSeconds` | number | 선택 제한 시간 |
| `replacementTimeLimitSeconds` | number | 교체 판단 제한 시간 |
| `timeoutDefaultAction` | enum | `equip_top_voted`, `keep_current` |
| `nextShopSessionId` | string/null | 이어질 상점 |

슬롯이 가득 찬 세션에서는 `keepCurrentAllowed`가 true여야 합니다.

교체 합의가 없을 때의 기본값은 `keep_current`입니다.

## 상점 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 상점 항목 ID |
| `nameKo` | string | 표시명 |
| `priceGold` | number/null | 골드 가격 |
| `priceBossShard` | number/null | 보스 파편 가격 |
| `availability` | object | 등장 조건 |
| `effect` | object | 구매 효과 |
| `purchaseScope` | enum | `personal_card`, `party_field`, `base`, `artifact`, `one_shot`, `party_consumable` |
| `linkedUpgradeOptionIds` | string[] | 카드 강화 항목이면 연결된 `CardUpgradeOption.id` |
| `maxPurchasesPerRun` | number/null | 런당 구매 제한 |
| `shopCategory` | enum | `deck_cleanup`, `deck_upgrade`, `field_repair`, `crisis_tool`, `long_term` |
| `ownerSelectionRequired` | boolean | 개인 카드 선택이 필요한지 |
| `recommendedForTags` | string[] | 어떤 피해 진단/다음 압박에 추천되는지 |
| `alternativeItemIds` | string[] | 같은 문제를 다른 방식으로 푸는 대안 |

### 상점 소모품 데이터

`ShopConsumableItem`은 구매 후 파티 소모품 슬롯에 들어가는 구조물 보강 소모품과 일회성 주문을 정의합니다.

상점 항목인 `ShopItem`이 구매 버튼이라면, `ShopConsumableItem`은 구매 후 실제 전투에서 쓰이는 효과입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 소모품 ID |
| `shopItemId` | string | 연결된 상점 항목 |
| `nameKo` | string | 표시명 |
| `consumableKind` | enum | `structure_boost`, `one_shot_spell`, `information_tool`, `resource_tool` |
| `priceRuleId` | string | 연결된 `ShopPriceRule.id` |
| `carrySlotGroup` | enum | `party_consumable` |
| `carrySlotCost` | number | 기본 1 |
| `validUntilPolicy` | object | 다음 1~3웨이브, 다음 보스 전 등 유효 기간 |
| `useWindow` | enum | `prebuild`, `combat`, `next_wave_start`, `boss_combat` |
| `targetScope` | enum | `structure_single`, `zone_3x3`, `active_lane_line`, `enemy_single`, `boss_part`, `base_next_hit`, `party_hand` |
| `effectProfile` | object | 수치와 지속 시간 |
| `allowedDiagnosticTags` | string[] | 추천 근거로 쓸 수 있는 진단 태그 |
| `allowedNextPressureTags` | string[] | 추천 근거로 쓸 수 있는 다음 압박 태그 |
| `usePermission` | enum | `any_player_with_ping` 권장 |
| `activationPingSeconds` | number | 전투 중 사용 예고 핑 시간 |
| `cooldownSeconds` | number | 같은 소모품 연속 사용 방지 시간 |
| `incompatibleConsumableIds` | string[] | 같은 구조물/구역에 동시에 쓰면 안 되는 소모품 |
| `forbiddenPatterns` | string[] | 금지 효과 |
| `notes` | string | 설계 의도 |

파티 소모품 슬롯:

| 항목 | 값 |
| --- | ---: |
| 기본 슬롯 | 2 |
| 한 소모품 슬롯 비용 | 1 |
| 전투 중 자동 사용 | 없음 |
| 시간 초과 기본 처리 | 유지 또는 만료, 자동 발동 없음 |
| 슬롯 초과 구매 | 기존 소모품 버리기 또는 구매 취소 |

MVP 구조물 보강 소모품:

| ID | 가격 규칙 | 사용 창 | 효과 요약 | 금지 패턴 |
| --- | --- | --- | --- | --- |
| `shop_consumable_bracing_kit` | `price_shop_structure_consumable` | `prebuild` | 구조물 1개 임시 체력 +6, 다음 웨이브 종료 시 제거 | `permanent_hp_gain`, `stack_same_structure` |
| `shop_consumable_spare_plating` | `price_shop_structure_consumable` | `combat` | 구조물 1개가 10초 동안 받는 피해 25% 감소 | `full_boss_slam_block`, `repair_effect` |
| `shop_consumable_path_ruler` | `price_shop_structure_consumable` | `prebuild` | 활성 방향 경로와 길막 위험 표시 강화 | `answer_placement`, `inactive_direction_reveal` |
| `shop_consumable_quick_scaffold` | `price_shop_structure_consumable` | `prebuild` | 낮은 체력 임시 바리케이드 1개, 다음 웨이브 후 해체 | `complete_block`, `debris_explosion`, `architect_replacement` |

15일 이후 구조물 보강 후보:

| ID | 가격 규칙 | 사용 창 | 효과 요약 | 금지 패턴 |
| --- | --- | --- | --- | --- |
| `shop_consumable_repair_chalk` | `price_shop_repair_efficiency` | `prebuild` | 3x3 구역 수리 효율 +20%, 다음 웨이브만 | `repair_over_100`, `tinkerer_aura_multiply` |
| `shop_consumable_anchor_spike` | `price_shop_structure_consumable` | `combat` | 구조물 1개가 8초 동안 밀림/흔들림 무시 | `damage_reduction`, `boss_body_stop` |

MVP 일회성 주문:

| ID | 가격 규칙 | 사용 창 | 효과 요약 | 금지 패턴 |
| --- | --- | --- | --- | --- |
| `shop_spell_signal_flare` | `price_shop_one_shot_spell` | `combat` | 정예 1체 또는 보스 부위 1개 우선 대상 표시 8초 | `damage_amp`, `force_boss_body_target` |
| `shop_spell_crosswind` | `price_shop_one_shot_spell` | `combat` | 활성 방향 한 줄 일반 적 짧은 밀림, 정예 절반 | `boss_body_knockback`, `full_rewind` |
| `shop_spell_emergency_bell` | `price_shop_one_shot_spell` | `combat` | 모든 플레이어가 1장 뽑고 1장 버림 | `mana_gain`, `discard_stack_increase` |
| `shop_spell_smoke_curtain` | `price_shop_one_shot_spell` | `combat` | 다음 기지 피해 1회 4 감소 | `base_invulnerability`, `enemy_stop` |

15~20일 이후 일회성 주문 후보:

| ID | 가격 규칙 | 사용 창 | 효과 요약 | 금지 패턴 |
| --- | --- | --- | --- | --- |
| `shop_spell_frost_line` | `price_shop_one_shot_spell` | `combat` | 4타일 선 위 적 5초 35% 둔화 | `hard_freeze`, `elementalist_replacement` |
| `shop_spell_quiet_lantern` | `price_shop_one_shot_spell` | `combat` | 방해형 1체 방해 오라 8초 30% 약화 | `silence_immunity`, `disruptor_delete` |
| `shop_spell_part_lens` | `price_shop_one_shot_spell` | `boss_combat` | 보스 부위 1개 우선 핑과 타워 우선순위 보정 8초 | `boss_pattern_cancel`, `extra_part_reward` |
| `shop_spell_reserve_core` | `price_shop_temporary_seed_mana` | `next_wave_start` | 선택 플레이어 다음 웨이브 시드 마나 +1 | `time_mana_regen`, `permanent_seed_mana` |

### 상점 가격 규칙 데이터

`ShopPriceRule`은 상점 항목의 기본 가격과 반복 구매 비용 변화를 정의합니다.

상점 항목 자체는 효과와 노출 조건을 가지고, 가격 변화는 `ShopPriceRule`에서 관리합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 가격 규칙 ID |
| `shopItemId` | string | 대상 상점 항목 |
| `basePriceGold` | number/null | 기본 골드 가격 |
| `basePriceBossShard` | number/null | 기본 보스 파편 가격 |
| `allowedDayRange` | number[] | 노출 가능 일자 범위 |
| `priceBand` | enum | `free`, `low`, `medium`, `high`, `boss_shard`, `special` |
| `repeatSurchargeRuleIds` | string[] | 반복 구매 비용 규칙 |
| `maxPurchasesPerSession` | number/null | 한 상점 세션 구매 제한 |
| `maxPurchasesPerRun` | number/null | 런 전체 구매 제한 |
| `requiresDiagnosticTag` | boolean | 피해 진단 태그가 있어야 추천되는지 |
| `competesWithCategoryIds` | string[] | 같은 자원을 두고 경쟁하는 상점 카테고리 |
| `forbiddenPriceModifierTags` | string[] | 가격에 영향을 주면 안 되는 태그 |
| `notes` | string | 설계 의도 |

대표 가격 규칙:

| ID | 항목 | 가격 | 노출 | 반복 변화 |
| --- | --- | ---: | --- | --- |
| `price_shop_common_card` | 공용 카드 구매 | 20 | 5일 이후 | 같은 상점 2장째 구매 불가 |
| `price_shop_class_card` | 직업 카드 구매 | 25~35 | 10일 이후 | 희귀 카드 조건에 따라 범위 안에서만 조정 |
| `price_shop_heroic_card` | 영웅 카드 구매 | 골드 60 + 보스 파편 1 | 31일 이후 특수 상점 | 낮은 빈도 |
| `price_shop_heroic_tune` | 영웅 확정 조율 | 골드 55 + 보스 파편 1 | 20일 이후, 선행 조건 충족 | 준비된 빌드 마무리 |
| `price_shop_intro_remove` | 첫 저가 제거 | 35 | 5일 첫 상점 | 런당 1회, 시작 카드 제거 불가 |
| `price_shop_remove_card` | 일반 카드 제거 | 55 | 10일 이후 | 파티 전체 제거마다 +20 |
| `price_shop_remove_start_card` | 시작 카드 제거 | 80 | 20일 이후 | 시작 카드 제거마다 +25 |
| `price_shop_advanced_remove_card` | 고급 카드 제거 | 골드 55 + 보스 파편 1 | 30일 이후 계속하기 | 파티 전체 제거 비용 증가를 무시하지 않음 |
| `price_shop_restore_base_3` | 기지 체력 3 회복 | 30 | 작은 상점 | 기지 체력 10 이하이면 경고 강화 |
| `price_shop_restore_base_5` | 기지 체력 5 회복 | 45 | 보스 후 상점 | 기지 체력 10 이하이면 +20 |
| `price_shop_structure_consumable` | 구조물 보강 소모품 | 20~30 | 5일 이후 | 다음 1~2웨이브만 적용 |
| `price_shop_structure_hp_upgrade` | 구조물 기본 체력 강화 | 50 | 10일 이후 | 같은 런 반복 구매 시 +25 |
| `price_shop_repair_efficiency` | 수리 효율 보강 | 45 | 15일 이후 | 땜장이 오라와 곱연산 금지 |
| `price_shop_one_shot_spell` | 일회성 주문 | 30~70 | 10일 이후 | 다음 압박과 직접 연결될 때만 |
| `price_shop_temporary_seed_mana` | 시드 마나 임시 보강 | 35 | 15일 이후 이벤트/소모품 | 다음 1웨이브만 적용 |
| `price_shop_artifact_peek` | 아티팩트 후보 1개 추가 확인 | 보스 파편 1 | 10일 이후 보스 후 상점 | 후보 확인만, 선택 후보 수 증가 아님 |
| `price_shop_artifact_replace` | 아티팩트 교체 | 보스 파편 1 | 30일 이후 계속하기 | 현재 유지 선택을 삭제하지 않음 |
| `price_shop_info_free` | 정보/요약/지나가기 | 0 | 모든 상점 | 구매 한도를 소모하지 않음 |
| `price_shop_final_patch_upgrade` | 30일 이후 보완 강화 | 35~45 | 30일 이후 계속하기 | 새 아키타입 시작 금지 |

모든 `ShopPriceRule.forbiddenPriceModifierTags`에는 아래 태그를 포함합니다.

- `wave_stack_count`
- `clear_time`
- `kill_count_total`
- `inactive_direction_pressure`
- `hidden_winrate_prediction`
- `card_rarity_bonus_from_performance`

### 카드 강화 상점 제안 데이터

`CardUpgradeShopOffer`는 상점 세션에서 실제로 표시되는 카드 강화 제안입니다.

`CardUpgradeOption`이 강화 후보의 원본 데이터라면, `CardUpgradeShopOffer`는 현재 런의 덱, 피해 진단, 다음 압박, 파티 자원 상태를 반영해 생성된 화면용 데이터입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 강화 제안 ID |
| `shopSessionId` | string | 표시되는 상점 세션 |
| `ownerPlayerId` | string | 대상 카드 소유자 |
| `cardInstanceId` | string | 강화할 카드 인스턴스 |
| `cardId` | string | 카드 원본 ID |
| `candidateUpgradeOptionIds` | string[] | 동시에 보여줄 강화 후보. 최대 2개 |
| `sourceDiagnosticTags` | string[] | 추천 근거가 된 피해 진단 태그 |
| `nextPressureTags` | string[] | 연결된 다음 3~5일 압박 태그 |
| `recommendationScoreBreakdown` | object | 사용 빈도, 진단 연결, 다음 압박, 파티 성장 편차 점수 |
| `basePriceGold` | number | 강화 유형별 기본 골드 가격 |
| `surchargeGold` | number | 반복 강화, 같은 상점 두 번째 강화 등으로 붙은 추가 비용 |
| `finalPriceGold` | number | 최종 골드 가격 |
| `priceBossShard` | number/null | 보스 파편 가격 |
| `surchargeReasonTags` | string[] | 할증 이유 |
| `competingItemIds` | string[] | 같은 문제를 다른 방식으로 푸는 상점 항목 |
| `requiresPartyVote` | boolean | 파티 골드를 쓰는지 |
| `timeoutDefaultAction` | enum | `decline` 권장 |
| `forbiddenOfferTags` | string[] | 검수기가 거부할 제안 태그 |

가격 밴드:

| ID | 강화 유형 | 기본 가격 | 추가 비용 | 해금 조건 |
| --- | --- | ---: | --- | --- |
| `upgrade_price_first_stable_lesson` | 안정 강화 | 25 | 없음 | 5일 첫 상점, 일반 카드 |
| `upgrade_price_stable` | 안정 강화 | 30 | 없음 | 10일 이후 |
| `upgrade_price_specialize` | 특화 강화 | 40 | 없음 | 10일 이후 |
| `upgrade_price_pivot` | 전환 강화 | 45 | 없음 | 15일 이후 |
| `upgrade_price_curse_stabilize` | 저주 안정화 | 40 | 없음 | 저주 보유 후 |
| `upgrade_price_heroic_tune` | 영웅 확정 조율 | 55 | 보스 파편 1 | 20일 이후, 선행 조건 충족 |
| `upgrade_price_final_patch` | 마지막 보완 강화 | 35~45 | 없음 | 91일 이후, 새 아키타입 시작 금지 |

할증 규칙:

| ID | 조건 | 추가 골드 |
| --- | --- | ---: |
| `upgrade_surcharge_owner_previous_shop` | 같은 플레이어가 직전 상점에서 파티 골드 강화를 받음 | 10 |
| `upgrade_surcharge_owner_ahead` | 대상 플레이어의 강화 수가 파티 최저보다 2개 이상 많음 | 15 |
| `upgrade_surcharge_second_party_upgrade` | 같은 상점 세션의 두 번째 파티 골드 강화 | 15 |
| `upgrade_surcharge_repeated_diagnostic` | 같은 진단 태그를 이유로 2회 연속 강화 구매 | 10 |

한 제안에 적용되는 `surchargeGold`는 최대 25입니다.

`CardUpgradeShopOffer` 검증 규칙:

- `candidateUpgradeOptionIds`는 1~2개만 허용합니다.
- `finalPriceGold`는 `basePriceGold + min(surchargeGold, 25)`로 계산합니다.
- `timeoutDefaultAction`은 자동 구매가 아니라 `decline`이어야 합니다.
- `competingItemIds`에는 같은 문제를 푸는 카드 제거, 기지 회복, 구조물 보강, 일회성 주문 중 최소 1개를 넣습니다.
- `sourceDiagnosticTags`와 `nextPressureTags`는 활성 방향과 현재 세션에서 공개된 정보만 사용할 수 있습니다.
- `forbiddenOfferTags`에는 `wave_stack_based_price`, `kill_count_discount`, `clear_time_discount`, `inactive_direction_recommendation`, `hidden_winrate_prediction`을 포함합니다.

### 상점 세션 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 상점 세션 ID |
| `day` | number | 열리는 일자 |
| `kind` | enum | `normal`, `boss`, `event`, `season`, `result`, `final` |
| `itemSlots` | string[] | 표시할 상점 항목 ID |
| `maxVisibleItems` | number | 화면에 보이는 최대 항목 수 |
| `maxPartyPurchases` | number | 파티 자원 구매 최대 횟수 |
| `timeLimitSeconds` | number | 기본 제한 시간 |
| `extensionSeconds` | number | 연장 1회당 추가 시간 |
| `maxExtensions` | number | 연장 가능 횟수 |
| `diagnosticTagSources` | string[] | 상점 추천에 사용할 전투 리포트 태그 |
| `nextPressureTags` | string[] | 상점 후 3~5일 압박 태그 |
| `recommendationRules` | object[] | 추천 항목 정렬 규칙 |
| `nextPreviewDay` | number/null | 상점 후 예고 일자 |

예시:

```json
{
  "id": "shop_session_after_day_010",
  "day": 10,
  "kind": "boss",
  "itemSlots": [
    "shop_remove_card",
    "shop_upgrade_card",
    "shop_restore_base_5",
    "shop_structure_hp_upgrade",
    "shop_one_shot_spell",
    "shop_common_card",
    "shop_boss_shard_extra_artifact_peek",
    "shop_next_pressure_recommendation"
  ],
  "maxVisibleItems": 8,
  "maxPartyPurchases": 2,
  "timeLimitSeconds": 120,
  "extensionSeconds": 30,
  "maxExtensions": 2,
  "diagnosticTagSources": ["breach_direction", "structure_chain_break", "hand_lock"],
  "nextPressureTags": ["resistant_intro", "priority_target"],
  "recommendationRules": [
    {
      "ifAnyDiagnosticTag": ["structure_chain_break"],
      "preferCategories": ["field_repair"],
      "reasonTextId": "shop_reason_structure_chain_break"
    },
    {
      "ifAnyDiagnosticTag": ["hand_lock"],
      "preferCategories": ["deck_cleanup"],
      "reasonTextId": "shop_reason_hand_lock"
    }
  ],
  "nextPreviewDay": 11
}
```

### 초반 상점 세션 데이터 예시

| ID | 일자 | 종류 | 슬롯 수 | 파티 구매 한도 | 목표 시간 | 역할 |
| --- | ---: | --- | ---: | ---: | ---: | --- |
| `shop_session_day_005_first_shop` | 5 | `normal` | 5~6 | 1 | 75초 | 저가 제거, 첫 안정 강화, 기지 소량 회복 학습 |
| `shop_session_after_day_010` | 10 | `boss` | 7~8 | 2 | 120초 | 첫 보스 결과를 다음 10일 운영으로 전환 |
| `shop_session_day_015_small_shop` | 15 | `normal` | 5~6 | 1 | 90초 | 11~14일 피해 진단을 강점 강화 또는 약점 보완으로 연결 |
| `shop_session_after_day_020` | 20 | `boss` | 7~8 | 2 | 120초 | 21~30일 협동 시험 준비 |
| `shop_session_day_025_season_turn` | 25 | `season` | 5~6 | 1 | 90초 | 봄 약점과 여름 속도 예고를 연결 |
| `shop_session_after_day_030_mvp_result` | 30 | `result` | 5~6 | 2 | 120초 | MVP 종료 후 계속하기 선택 시 31일 준비 |
| `shop_session_day_095_final_market` | 95 | `final` | 6~7 | 2 | 150초 | 최종 빌드 마감, 아티팩트 1회 행동, 포기한 약점 확정 |

세션별 필수 슬롯:

| 세션 | 필수 슬롯 | 금지 슬롯 |
| --- | --- | --- |
| `shop_session_day_005_first_shop` | `shop_intro_remove_card`, `shop_first_stable_upgrade`, `shop_restore_base_3`, `shop_skip` | 영웅 카드, 보스 파편, 아티팩트 교체, 전환 강화 |
| `shop_session_after_day_010` | `shop_remove_card`, `shop_upgrade_card`, `shop_restore_base_5`, `shop_next_pressure_recommendation` | 보상 배율, 카드 후보 수 증가, 영웅 카드 구매 |
| `shop_session_day_015_small_shop` | `shop_diagnostic_recommendation`, `shop_upgrade_card`, `shop_remove_card`, `shop_skip` | 보스 파편 사용 강제, 시작 카드 제거, 새 아티팩트 선택 |
| `shop_session_after_day_020` | `shop_remove_card`, `shop_upgrade_card`, `shop_restore_base_5`, `shop_next_pressure_recommendation` | 21~30일 새 시스템 선행 학습, 특정 직업 필수 구매 |
| `shop_session_day_025_season_turn` | `shop_season_turn_summary`, `shop_upgrade_card`, `shop_restore_base_3`, `shop_temporary_seed_mana`, `shop_skip` | 보스 보상급 대형 보상, 영웅 카드 강제 |
| `shop_session_after_day_030_mvp_result` | `shop_keep_current_build`, `shop_artifact_replace`, `shop_final_mvp_note` | 31일 새 아키타입 강제, MVP 평가를 보상 효율로 환산 |
| `shop_session_day_095_final_market` | `shop_keep_current_build`, `shop_final_weakness_patch`, `shop_late_deck_trim_bundle`, `shop_artifact_replace`, `shop_final_market_note` | 모든 약점 해결, 새 아키타입 시작, 슬롯 증가, 겹치기 보상 |

### MVP 상점 실제 슬롯 데이터

`MvpShopSessionLock`은 30일 MVP 안에서 실제로 보여줄 상점 슬롯을 잠그는 데이터입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 상점 잠금 ID |
| `shopSessionId` | string | 연결 `ShopSession.id` |
| `day` | number | 상점 일자 |
| `fixedSlotIds` | string[] | 항상 보여줄 상품 ID |
| `conditionalSlotPoolIds` | string[] | 피해 진단 태그로 고를 선택 슬롯 묶음 |
| `freeSlotIds` | string[] | 구매 한도를 소모하지 않는 정보/보류 항목 |
| `maxPartyPurchases` | number | 파티 자원 구매 한도 |
| `targetDurationSeconds` | number | 목표 체류 시간 |
| `forbiddenSlotIds` | string[] | 이 세션에서 절대 보여주지 않을 항목 |
| `forbiddenPricingTags` | string[] | 가격 계산에 쓰면 안 되는 태그 |

MVP 상점 잠금:

| ID | 세션 | 고정 슬롯 | 선택 슬롯 | 무료 슬롯 | 금지 핵심 |
| --- | --- | --- | --- | --- | --- |
| `mvp_shop_lock_day_005` | `shop_session_day_005_first_shop` | `shop_intro_remove_card`, `shop_first_stable_upgrade`, `shop_restore_base_3`, `shop_consumable_bracing_kit` | `shop_common_card`, `shop_consumable_path_ruler` | `shop_skip` | 시작 카드 제거, 영웅, 보스 파편 |
| `mvp_shop_lock_day_010` | `shop_session_after_day_010` | `shop_remove_card`, `shop_upgrade_card`, `shop_restore_base_5`, `shop_structure_hp_upgrade`, `shop_common_card`/`shop_class_card`, `shop_next_pressure_recommendation` | `shop_spell_signal_flare`, `shop_spell_crosswind`, `shop_boss_shard_extra_artifact_peek` | `shop_skip`, `shop_next_pressure_recommendation` | 영웅 구매, 보상 배율 |
| `mvp_shop_lock_day_015` | `shop_session_day_015_small_shop` | `shop_diagnostic_recommendation`, `shop_remove_card`, `shop_upgrade_card`, `shop_repair_efficiency_boost`, `shop_restore_base_3` | `shop_spell_emergency_bell`, `shop_consumable_spare_plating`, `shop_common_card` | `shop_skip`, `shop_diagnostic_recommendation` | 시작 카드 제거, 새 아티팩트 |
| `mvp_shop_lock_day_020` | `shop_session_after_day_020` | `shop_remove_card`, `shop_remove_start_card`, `shop_upgrade_card`, `shop_restore_base_5`, `shop_structure_hp_upgrade`, `shop_next_pressure_recommendation` | `shop_heroic_tune`, `shop_spell_part_lens`, `shop_spell_quiet_lantern` | `shop_skip`, `shop_next_pressure_recommendation` | 선행 없는 영웅, 새 시스템 강제 |
| `mvp_shop_lock_day_025` | `shop_session_day_025_season_turn` | `shop_season_turn_summary`, `shop_remove_card`, `shop_upgrade_card`, `shop_restore_base_3`, `shop_temporary_seed_mana` | `shop_spell_frost_line`, `shop_consumable_quick_scaffold` | `shop_skip`, `shop_season_turn_summary` | 보스 보상급 대형 보상 |
| `mvp_shop_lock_day_030` | `shop_session_after_day_030_mvp_result` | `shop_keep_current_build`, `shop_artifact_replace`, `shop_advanced_remove_card`, `shop_heroic_tune`, `shop_final_mvp_note` | `shop_restore_base_5`, `shop_final_patch_upgrade` | `shop_keep_current_build`, `shop_final_mvp_note` | 31일 새 아키타입 강제 |

모든 `MvpShopSessionLock.forbiddenPricingTags`에는 아래 태그를 포함합니다.

- `wave_stack_count`
- `clear_time`
- `kill_count_total`
- `inactive_direction_pressure`
- `hidden_winrate_prediction`
- `card_rarity_bonus_from_performance`

무료 슬롯은 정보, 요약, 보류 선택만 담당합니다.

무료 슬롯은 카드 후보 수, 희귀도, 골드, 보스 파편을 늘릴 수 없습니다.

## 이벤트 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 이벤트 ID |
| `nameKo` | string | 표시명 |
| `descriptionKo` | string | 설명 |
| `choices` | object[] | 선택지 |
| `conditions` | object | 등장 조건 |
| `weight` | number | 등장 가중치 |
| `triggerTags` | string[] | 등장 이유로 보여줄 태그 |
| `diagnosticTagHooks` | string[] | 피해 진단과 연결되는 태그 |
| `nextPressureTags` | string[] | 선택 후 다음 3~5일 예고에 연결할 태그 |
| `allowedActiveDirectionOnly` | boolean | 방향 영향이 활성 방향 안에서만 발생하는지 |
| `timeLimitSeconds` | number | 기본 선택 제한 시간 |
| `timeoutDefaultChoiceId` | string | 시간 초과 시 적용할 안전 선택 |

이벤트 선택지는 최소 2개, 최대 3개로 제한합니다.

전투 리듬을 위해 긴 텍스트 이벤트는 피합니다.

### 이벤트 선택지 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 선택지 ID |
| `labelKo` | string | 버튼에 표시할 짧은 결과 문구 |
| `owner` | enum | `personal`, `party`, `mixed` |
| `requiresVote` | boolean | 파티 투표 필요 여부 |
| `cost` | object/null | 기지 체력, 골드, 카드, 아티팩트 비용 |
| `reward` | object/null | 즉시 얻는 효과 |
| `nextWaveModifier` | object/null | 다음 웨이브 영향 |
| `shopModifier` | object/null | 다음 상점 영향 |
| `addsCurseCardId` | string/null | 선택으로 들어오는 저주 카드 |
| `previewTextId` | string | 선택 전 표시할 결과 설명 |
| `consequenceTags` | string[] | 결과 요약과 텔레메트리 태그 |
| `forbiddenOutcomeTags` | string[] | 검수기가 발견하면 거부할 결과 태그 |

선택지의 결과, 보상, 다음 웨이브 변경에는 아래 결과가 들어가면 안 됩니다.

검수기는 아래 태그를 발견하면 해당 이벤트 데이터를 거부합니다.

- `modify_wave_stack_reward`
- `increase_card_reward_choices`
- `increase_card_rarity`
- `open_inactive_direction_spawn`
- `hidden_penalty`
- `forced_curse`

예시:

```json
{
  "id": "event_cracked_storehouse",
  "nameKo": "갈라진 저장고",
  "descriptionKo": "무너진 저장고 안에서 쓸 만한 물자가 보입니다.",
  "triggerTags": ["low_gold", "breach_direction"],
  "diagnosticTagHooks": ["breach_direction"],
  "nextPressureTags": ["field_repair_needed"],
  "allowedActiveDirectionOnly": true,
  "timeLimitSeconds": 45,
  "timeoutDefaultChoiceId": "choice_leave_storehouse",
  "choices": [
    {
      "id": "choice_open_storehouse",
      "labelKo": "골드 +25 / 기지 체력 -3",
      "owner": "party",
      "requiresVote": true,
      "cost": {"baseHp": 3},
      "reward": {"gold": 25},
      "nextWaveModifier": null,
      "shopModifier": null,
      "addsCurseCardId": null,
      "previewTextId": "event_preview_open_storehouse",
      "consequenceTags": ["gold_gain", "base_hp_loss"],
      "forbiddenOutcomeTags": []
    },
    {
      "id": "choice_leave_storehouse",
      "labelKo": "지나가기",
      "owner": "party",
      "requiresVote": false,
      "cost": null,
      "reward": null,
      "nextWaveModifier": null,
      "shopModifier": null,
      "addsCurseCardId": null,
      "previewTextId": "event_preview_leave_storehouse",
      "consequenceTags": ["state_preserved"],
      "forbiddenOutcomeTags": []
    }
  ],
  "conditions": {"minDay": 5},
  "weight": 1
}
```

### MVP 이벤트 계약 잠금 데이터

`MvpEventContractLock`은 1~30일 MVP에서 이벤트가 등장하는 시점, 후보 수, 필수 이벤트, 시간 제한을 고정합니다.

이 데이터는 이벤트 등장 빈도를 보상처럼 올리는 장치가 아니라, 상점과 전투 리듬 사이에 들어갈 계약 화면의 크기를 제한하는 장치입니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 이벤트 계약 잠금 ID |
| `day` | number | 적용 일자 |
| `requiredEventIds` | string[] | 반드시 보여줄 이벤트 ID |
| `candidateEventIds` | string[] | 조건에 따라 고를 수 있는 이벤트 ID |
| `maxEventsShown` | number | 한 세션에 보여줄 이벤트 수 |
| `combinedShopEventTimeLimitSeconds` | number/null | 상점과 함께 쓸 때의 합산 시간 목표 |
| `defaultSafeChoicePolicy` | enum | `state_preserved`, `skip`, `no_volunteer_skip` |
| `allowedChoiceOwnerTypes` | enum[] | `personal`, `party`, `mixed` |
| `curseContractAllowed` | boolean | 저주 계약 선택 허용 여부 |
| `forbiddenModifierTags` | string[] | 이벤트가 바꾸면 안 되는 보정 태그 |
| `notes` | string | 설계 의도 |

MVP 잠금표:

| ID | 일자 | 필수 이벤트 | 후보 이벤트 | 최대 표시 | 합산 시간 | 저주 |
| --- | ---: | --- | --- | ---: | ---: | --- |
| `event_contract_lock_mvp_015` | 15 | 없음 | `event_cracked_storehouse`, `event_silent_pilgrim`, `event_fallen_workshop` | 1 | 90 | 허용 |
| `event_contract_lock_mvp_025` | 25 | `event_season_sign_025` | `event_reserve_core_025`, `event_quiet_contract_025` | 2 | 90 | 보유 저주 처리만 허용 |

### 저주 계약 프로필 데이터

`CurseContractProfile`은 저주 카드가 이벤트나 특수 상점에서 어떤 확인 절차와 활용/제거 경로를 갖는지 정의합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 저주 계약 프로필 ID |
| `cardId` | string | 연결 저주 카드 ID |
| `classId` | string | 제안 가능한 직업 ID |
| `offerSourceTypes` | enum[] | `event_contract`, `special_shop`, `artifact_unlock` |
| `immediateBenefitTags` | string[] | 즉시 이득 태그 |
| `longTermCostTags` | string[] | 장기 대가 태그 |
| `requiredConfirmFields` | string[] | UI가 반드시 표시해야 하는 정보 |
| `stabilizeUpgradeOptionIds` | string[] | 연결 안정화 강화 |
| `removalShopItemIds` | string[] | 연결 제거 항목 |
| `safeDeclineChoiceId` | string | 지원자 없음 또는 시간 초과 시 선택 |
| `soloProjectionSafe` | boolean | 솔로 동쪽 전선에서 사용 가능한지 |
| `forbiddenOutcomeTags` | string[] | 검수기가 거부할 결과 태그 |
| `notes` | string | 설계 의도 |

예시:

```json
{
  "id": "curse_contract_card_guardian_heavy_vow",
  "cardId": "card_guardian_heavy_vow",
  "classId": "class_guardian",
  "offerSourceTypes": ["event_contract", "special_shop"],
  "immediateBenefitTags": ["taunt_anchor", "resource_unjam"],
  "longTermCostTags": ["draw_loss", "structure_hp_loss"],
  "requiredConfirmFields": [
    "card_preview",
    "immediate_benefit",
    "long_term_cost",
    "remove_or_stabilize_hint"
  ],
  "stabilizeUpgradeOptionIds": ["upgrade_heavy_vow_scheduled_draw_loss"],
  "removalShopItemIds": ["shop_remove_card", "shop_advanced_remove_card"],
  "safeDeclineChoiceId": "choice_decline_curse_contract",
  "soloProjectionSafe": true,
  "forbiddenOutcomeTags": [
    "forced_curse",
    "hidden_penalty",
    "remove_all_tradeoffs",
    "modify_wave_stack_reward"
  ],
  "notes": "즉시 전선을 붙잡는 대가로 다음 드로우와 구조물 체력 부담을 남긴다."
}
```

### 저주 안정화/제거 정책 데이터

`CurseServicePolicy`는 저주를 언제 안정화하거나 제거할 수 있는지, 어떤 가격 하한과 할인 규칙을 쓰는지 정의합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 정책 ID |
| `curseContractProfileId` | string/null | 특정 저주 전용이면 연결 ID, 공통 정책이면 null |
| `sameMaintenanceServiceAllowed` | boolean | 저주 획득과 같은 정비에서 처리 가능한지 |
| `minimumCombatCountOwned` | number | 처리 전 최소 보유 전투 수 |
| `stabilizeBaseGold` | number | 안정화 기본 가격 |
| `stabilizeMinGoldAfterDiscount` | number | 할인 후 안정화 최저 가격 |
| `removeBaseGold` | number | 일반 제거 기본 가격 |
| `removeUsesPartyRemovalSurcharge` | boolean | 파티 전체 제거 할증을 적용하는지 |
| `removeMinGoldAfterDiscount` | number | 할인 후 제거 최저 가격 |
| `advancedRemoveBossShardCost` | number/null | 고급 제거 보스 파편 비용 |
| `discountReservationPolicy` | enum | `none`, `next_eligible_shop_only`, `same_day_shop_allowed_if_owned_before_event` |
| `maxDiscountReservationsPerCurse` | number | 저주 1장에 예약 가능한 할인 수 |
| `stabilizationKeepsCostTagCountMin` | number | 안정화 후 남겨야 하는 장기 대가 태그 수 |
| `forbiddenServiceTags` | string[] | 서비스가 만들면 안 되는 결과 태그 |

MVP 공통 정책:

| ID | 안정화 | 제거 | 고급 제거 | 할인 | 핵심 제한 |
| --- | ---: | ---: | --- | --- | --- |
| `curse_service_policy_mvp_common` | 40, 하한 25 | 55+제거 할증, 하한 35 | 제거 비용 + 보스 파편 1 | 다음 적법 상점 1회, 이미 보유한 저주는 25일 같은 상점 가능 | 같은 정비 즉시 처리 금지, 대가 완전 삭제 금지 |

예시:

```json
{
  "id": "curse_service_policy_mvp_common",
  "curseContractProfileId": null,
  "sameMaintenanceServiceAllowed": false,
  "minimumCombatCountOwned": 1,
  "stabilizeBaseGold": 40,
  "stabilizeMinGoldAfterDiscount": 25,
  "removeBaseGold": 55,
  "removeUsesPartyRemovalSurcharge": true,
  "removeMinGoldAfterDiscount": 35,
  "advancedRemoveBossShardCost": 1,
  "discountReservationPolicy": "same_day_shop_allowed_if_owned_before_event",
  "maxDiscountReservationsPerCurse": 1,
  "stabilizationKeepsCostTagCountMin": 1,
  "forbiddenServiceTags": [
    "same_maintenance_curse_cleanup",
    "remove_all_tradeoffs",
    "refund_immediate_benefit",
    "ignore_party_removal_surcharge",
    "wave_stack_reward_bonus"
  ]
}
```

### 저주 안정화 옵션 데이터

저주 안정화는 `CardUpgradeOption.upgradeType: curse_stabilize`를 사용하지만, 일반 강화와 다르게 "더 강한 카드"를 만드는 목적이 아닙니다.

| ID | 대상 저주 | 안정화 내용 | 남는 대가 |
| --- | --- | --- | --- |
| `upgrade_heavy_vow_scheduled_draw_loss` | `card_guardian_heavy_vow` | 다음 드로우 손실과 피해 증가 대상을 UI에 예약 표시 | 드로우 손실, 구조물 피해 부담 |
| `upgrade_overbuilt_marked_fragility` | `card_architect_overbuilt` | 취약 바리케이드의 붕괴 예고와 회수 제외 표시를 강화 | 취약 상태, 회수 보상 제외 |
| `upgrade_forbidden_lantern_fixed_mana_debt` | `card_elementalist_forbidden_lantern` | 일반 처치 마나 감소를 다음 1웨이브 첫 8기로 고정 | 처치 마나 손실 |
| `upgrade_risky_mod_visible_backlash` | `card_tinkerer_risky_mod` | 자해 타이머와 최대 피해를 표시 | 지속 중 수리 효율 감소 |

## 금지 데이터 패턴

아래 데이터는 만들지 않습니다.

```json
{
  "kind": "modify_wave_stack_reward",
  "goldMultiplier": 1.5
}
```

```json
{
  "kind": "modify_wave_stack_reward",
  "rarityBonus": 0.2
}
```

```json
{
  "kind": "mana_regen_over_time",
  "amountPerSecond": 1
}
```

허용되는 웨이브 겹치기 관련 효과:

```json
{
  "kind": "modify_wave_stack_limit",
  "amount": 1,
  "tradeoff": {
    "kind": "structure_damage_taken",
    "multiplier": 1.15,
    "onlyWhileStacked": true
  }
}
```

## 데이터 검증 규칙

빌드 전 자동 검사로 확인할 규칙입니다.

- 모든 ID는 중복되지 않습니다.
- 모든 카드의 비용은 0 이상입니다.
- 모든 카드의 키워드는 존재하는 키워드 ID입니다.
- 모든 카드의 `responseTags`는 존재하는 대응 태그만 사용합니다.
- 모든 카드는 비어 있지 않은 `decisionQuestionKo`와 1개 이상의 `timingWindows`를 가져야 합니다.
- 모든 카드는 존재하는 `CardSpecProfile.id`를 `specProfileId`로 참조해야 합니다.
- `CardData.cost`, `targetType`, `castRangeTiles`, `areaShape`, `areaRadiusTiles`, `durationSeconds`, `windupSeconds`는 연결된 `CardSpecProfile`의 기준값과 충돌하면 안 됩니다.
- 모든 `CardSpecProfile.cardId`는 존재하는 카드 ID를 참조해야 합니다.
- 모든 `CardSpecProfile.effectBudgetId`는 허용된 카드 스펙 예산 ID여야 합니다.
- 모든 `CardSpecProfile.effectBudgetId`는 하나 이상의 `MvpCardStatBudgetLock.allowedEffectBudgetIds`에 포함되어야 합니다.
- `CardSpecProfile.manaCost`, `areaRadiusTiles`, `durationSeconds`, `castRangeTiles`가 연결된 `MvpCardStatBudgetLock`의 기본 상한을 넘으면 `requiredCompensationTags`와 `requiredPolicyIds`를 충족해야 합니다.
- `MvpCardStatBudgetLock.id: stat_budget_connector_0`에 속한 카드는 조건 없는 피해, 수리, 순수 드로우, 마나 순증가를 가질 수 없습니다.
- `MvpCardStatBudgetLock.id: stat_budget_risky_boost_0`에 속한 카드는 구조물 피해, 수리 효율 감소, 다음 드로우 손실, 회수 가치 제외 중 1개 이상을 가져야 합니다.
- `MvpCardStatBudgetLock.id: stat_budget_flexible_1`에 속한 원격/전장 전체 카드는 반복 효율 감소, 대상 조건, 낮은 수치 중 2개 이상을 가져야 합니다.
- `MvpCardStatBudgetLock.id: stat_budget_crisis_3` 이상의 광역 카드는 1초 이상 예고, 웨이브당 제한, 보스 본체 약화 정책 중 2개 이상을 가져야 합니다.
- `MvpCardStatBudgetLock.id: stat_budget_curse`에 속한 카드는 `CurseContractProfile` 또는 명시 확인 UI를 가져야 하며, 일반 라운드 임시 선택 대상이 될 수 없습니다.
- 모든 `CardData.bossEffectPolicyId`와 `CardSpecProfile.bossPolicy.policyId`는 허용된 보스 정책 ID여야 합니다.
- 모든 `timingWindows`와 `tradeoffTags`는 허용 목록에 있는 값만 사용합니다.
- 카드 하나의 `responseTags`는 보통 1~3개를 권장하며, 5개 이상이면 역할 과다로 검토합니다.
- `supportedEnemyRoleProfileIds`는 존재하는 `EnemyRoleProfile.id`만 참조합니다.
- 모든 `CardData.archetypeIds`는 존재하는 `CardArchetype.id`만 참조합니다.
- 모든 `CardData.upgradeOptions`는 존재하는 `CardUpgradeOption.id`만 참조합니다.
- 모든 카드의 `upgradeOptions`는 MVP에서 2개를 넘을 수 없습니다.
- `CardData.commitmentLevel: commit` 카드는 `archetypeRole: payoff` 또는 `risk_accelerator`여야 합니다.
- `CardData.commitmentLevel: commit` 카드는 일반 라운드 1~20일 보상 풀에 들어갈 수 없습니다.
- 모든 직업 전용 카드는 자기 직업의 `ClassCardPoolContract.requiredLaneIds` 중 하나를 `poolLaneId`로 가져야 합니다.
- 모든 직업은 `first_010`, `mvp_030` 카드 풀 계약을 가져야 하며, 100일 풀런 콘텐츠는 `full_100` 계약을 추가로 가져야 합니다.
- MVP 카드 풀 계약의 `minimumCardTypeCount`는 시작 카드와 보상 카드를 합쳐 14종 이상이어야 합니다.
- MVP 카드 풀 계약은 각 `requiredLaneIds`에 최소 2종 이상의 카드를 배치해야 합니다.
- MVP 카드 풀 계약은 직업마다 3개 이상의 `requiredArchetypeIds`를 가져야 합니다.
- 모든 `ClassCardPoolContract.requiredArchetypeIds`는 존재하는 `CardArchetype.id`만 참조합니다.
- 모든 `CardArchetype.primaryLaneIds`와 `secondaryLaneIds`는 같은 직업의 카드 풀 라인만 참조합니다.
- 모든 MVP `CardArchetype`은 1개 이상의 시작 보강 카드, 1개 이상의 방향 신호 또는 전환 카드, 1개 이상의 확정 또는 위험 가속 카드를 가져야 합니다.
- 모든 `CardArchetype.weakEnemyRoleProfileIds`는 비어 있으면 안 됩니다.
- `CardArchetype.forbiddenPatterns`에는 만능 해결, 무한 자원, 특정 방위 전용 조건 중 필요한 금지 패턴을 포함합니다.
- 모든 `CardUpgradeOption.cardId`는 존재하는 카드 ID를 참조합니다.
- `CardUpgradeOption.upgradeType: heroic_tune`은 대상 카드의 `rarity: heroic`와 함께 사용해야 합니다.
- `CardUpgradeOption.upgradeType: curse_stabilize`는 대상 카드의 `rarity: curse` 또는 `tradeoffTags`가 큰 위험 카드를 대상으로 해야 합니다.
- 저주 안정화 강화는 모든 `tradeoffTags`를 제거할 수 없습니다.
- `CardUpgradeOption.newArchetypeIds`는 대상 카드 직업의 `CardArchetype.id`만 참조합니다.
- `CardUpgradeOption.requiredSupportCardCount`가 2 이상이면 상점 UI에 선행 카드 수를 표시해야 합니다.
- `CardUpgradeOption.effectDelta`는 비용, 범위, 지속, 대상 선택, 발동 조건, 실패 손해, 대가 중 보통 1개 축만 바꿔야 합니다.
- `CardUpgradeOption.forbiddenPatterns`에는 만능 해결, 무한 자원, 대가 제거, 새 직업 역할 대체 중 필요한 금지 패턴을 포함합니다.
- 카드 효과가 방향 조건을 사용한다면 고정 방위 단독 조건이 아니라 `activeDirections`와 `LaneProjection`으로 해석 가능해야 합니다.
- `ClassCardPoolContract.soloProjectionPolicy`는 솔로에서 새 직업 기믹을 만들지 않고 기존 카드 라인을 동쪽 전선에 투영해야 합니다.
- 공용 카드는 `forbiddenReplacementResponseTags`에 대해 `counterStrength: strong`을 가질 수 없습니다.
- 공용 카드의 `counterStrength`는 기본적으로 `soft` 또는 `normal`이어야 하며, 특정 직업 전용 대응을 완전히 대체하지 않습니다.
- 0비용 카드는 `tradeoffTags` 또는 명확한 선행 조건을 가져야 하며, 조건 없는 마나 순증가나 드로우 순증가를 만들 수 없습니다.
- `specRiskTags`에 `free_action`이 있으면 `CardSpecProfile.resourceDelta`는 즉시 순이득을 만들 수 없습니다.
- `specRiskTags`에 `global_target`이 있으면 낮은 효과값, 대상 조건, 반복 제한 중 하나 이상을 가져야 합니다.
- `specRiskTags`에 `hard_cc`가 있으면 `statusApplication`은 반복 저항과 보스 약화 변환을 가져야 합니다.
- `specRiskTags`에 `resource_positive` 또는 `repeat_trigger`가 있으면 `repeatLimitPerWave` 또는 `triggerLimitPerCast` 중 하나를 가져야 합니다.
- `specRiskTags`에 `path_cost_change`가 있으면 `uiPreviewType: path`와 완전 길막 검사를 가져야 합니다.
- 보스에게 직접 적용되는 카드 스펙은 `bossEffectPolicyId` 또는 `CardSpecProfile.bossPolicy`를 가져야 하며, 보스 본체 패턴을 취소할 수 없습니다.
- 전장 전체/원격 수리 카드는 파괴형 적과 보스 패턴을 지우지 않도록 연속 수리 보정 또는 대상 조건을 가져야 합니다.
- 무료 또는 임시 구조물을 만드는 건축가 카드는 회수 작업, 파편 회수, 연쇄 붕괴의 자원 가치로 계산할 수 없습니다.
- 건축가 카드가 파괴 기록을 소모하면 같은 파괴 기록을 다른 회수 카드가 다시 소모할 수 없습니다.
- 건축가 카드가 잔해 지속 시간을 늘리면 잔해 총 지속 상한과 경로 재개방 정책을 함께 가져야 합니다.
- 구조물 1개에서 발생하는 폭발 보너스는 `collapse_policy_single_structure_explosion_cap`을 따라야 하며, 같은 구조물 반복 폭발로 추가 피해를 무한히 만들 수 없습니다.
- 영웅 카드는 `displayComplexity: buildaround` 또는 명확한 `requires_prior_setup` 대가를 가져야 합니다.
- 저주 카드는 강한 즉시 이득과 장기 대가를 모두 가져야 하며, 플레이어 선택 없이 일반 보상에 강제로 들어갈 수 없습니다.
- 카드의 `missCostTag`가 비어 있으면 항상 좋은 카드로 간주하고 리워크 대상으로 표시합니다.
- 모든 `CardLootPool.includedCardIds`는 존재하는 카드 ID만 참조합니다.
- 모든 `CardLootPool.includedPoolLaneIds`는 존재하는 카드 풀 라인만 참조합니다.
- 모든 `CardLootPool.includedArchetypeIds`는 존재하는 `CardArchetype.id`만 참조합니다.
- 모든 `CardLootPool.rarityProfileId`는 존재하는 `CardRarityProfile.id`를 참조합니다.
- 모든 `CardLootPool.rarityWeights`는 `common`, `rare`, `heroic`, `curse` 키를 모두 가져야 합니다.
- 모든 `CardLootPool.rarityWeights`는 참조한 `CardRarityProfile.rarityWeights`와 충돌하면 안 됩니다.
- 일반 라운드 `CardLootPool`은 `rarityWeights.curse`를 0으로 둡니다.
- `CardLootPool.sourceType: boss_personal`은 보스 클리어 성과로 희귀도 가중치를 올릴 수 없습니다.
- `CardLootPool.forbiddenScalingTags`에는 웨이브 겹치기 횟수, 클리어 시간, 처치 수, 접근성 옵션, 재접속 상태를 포함합니다.
- `CardLootPool.cursePolicy`가 `explicit_offer_only`, `shop_contract_only`, `event_only`이면 `requiresPlayerConsent`가 true여야 합니다.
- 모든 `CardRarityProfile.rarityWeights`는 `common`, `rare`, `heroic`, `curse` 키를 모두 가져야 합니다.
- `CardRarityProfile.explicitChoiceOnly`가 false이면 `rarityWeights` 합계가 100이어야 합니다.
- 일반 라운드 `CardRarityProfile`은 `cursePolicy: none`이어야 하며 `rarityWeights.curse`를 0으로 둡니다.
- 1~20일 일반 라운드 `CardRarityProfile`은 `rarityWeights.heroic`을 0으로 둡니다.
- `CardRarityProfile.explicitChoiceOnly`가 true인 저주 선택지는 일반 랜덤 후보가 아니라 별도 확인 UI를 사용해야 합니다.
- `CardRarityProfile.forbiddenScalingTags`에는 웨이브 겹치기 횟수, 클리어 시간, 처치 수, 접근성 옵션, 재접속 상태를 포함합니다.
- 모든 `MvpLootRarityLock.rarityProfileId`는 존재하는 `CardRarityProfile.id`를 참조해야 합니다.
- 모든 `MvpLootRarityLock.lootPoolIds`는 존재하는 `CardLootPool.id`만 참조해야 합니다.
- `candidateMode: three_card_reward`인 `MvpLootRarityLock`은 `candidateCount`가 3이어야 합니다.
- 일반 라운드 `MvpLootRarityLock`은 `cursePolicy: none`이고 `maxCommonSoftGapCandidates`가 1 이하여야 합니다.
- 1~20일 일반 라운드 `MvpLootRarityLock`은 `maxHeroicCandidates`가 0이어야 합니다.
- 21~30일 일반 라운드와 20~30일 보스 개인 `MvpLootRarityLock`은 `heroicGatePolicy: requires_two_archetype_support_cards`를 사용해야 합니다.
- 상점 카드 슬롯 `MvpLootRarityLock`은 30일 MVP 안에서 영웅 랜덤 판매를 허용하지 않으며, 영웅은 `shop_heroic_tune` 상품 슬롯으로만 처리합니다.
- 이벤트 계약 `MvpLootRarityLock`은 `candidateMode: explicit_contract`와 저주 명시 동의 UI를 가져야 합니다.
- 모든 `MvpLootRarityLock.forbiddenModifierTags`에는 웨이브 겹치기 횟수, 클리어 시간, 처치 수, 보스 부위 파괴 수, 접근성 옵션, 재접속 상태를 포함합니다.
- 모든 `MvpRewardShopEventDay.day`는 중복 없이 1~30을 채워야 합니다.
- 모든 `MvpRewardShopEventDay.primaryRewardLockId`는 존재하는 `MvpLootRarityLock.id`를 참조해야 합니다.
- `dayKind: boss`인 `MvpRewardShopEventDay.day`는 10, 20, 30일로 제한합니다.
- 25일 `MvpRewardShopEventDay`는 `primaryRewardLockId: loot_lock_round_021_030`을 사용하며 `boss_tier_reward` 태그를 가질 수 없습니다.
- `MvpRewardShopEventDay.eventContractLockId`는 기본 MVP에서 15일과 25일에만 설정합니다.
- `MvpRewardShopEventDay.shopSessionLockId`는 5, 10, 15, 20, 25, 30일 잠금과만 연결합니다.
- 모든 `MvpRewardShopEventDay.waveStackHandling`은 보상 배율이 아니라 일자별 보상 팩 분리 처리를 뜻해야 합니다.
- 모든 `MvpRewardShopEventDay.forbiddenModifierTags`에는 웨이브 겹치기 보상 증가, 후보 수 증가, 희귀도 증가, 비활성 방향 압박을 포함합니다.
- 모든 `BossRewardData.settlementScenarioId`는 존재하는 `BossSettlementScenario.id`를 참조해야 합니다.
- 10, 20, 30일 `BossSettlementScenario`는 각각 `loot_lock_boss_010`, `loot_lock_boss_020`, `loot_lock_boss_030` 중 해당 일자의 잠금만 사용해야 합니다.
- 10일 `BossSettlementScenario.artifactPoolId`는 `artifact_pool_foundation_010`, 20일은 `artifact_pool_branch_020`, 30일은 `artifact_pool_mvp_result_030`이어야 합니다.
- `BossSettlementScenario.tagToRewardReasonRules`는 후보의 이유와 추천 정렬만 바꿀 수 있고, 카드 후보 수, 희귀도, 보스 파편, 골드 총량을 바꿀 수 없습니다.
- `boss_settlement_scenario_030_mvp_result.continueRequiredForShop`이 true이면, 결과 정비 상점은 계속하기 선택 전에는 열리지 않아야 합니다.
- 모든 보스는 `BossEncounterBudgetProfile`을 1개 이상 참조해야 합니다.
- `BossEncounterBudgetProfile.targetDurationSeconds.min`은 `targetDurationSeconds.max`보다 작아야 하며, `warningDurationSeconds`는 목표 최대 시간보다 커야 합니다.
- `BossEncounterBudgetProfile.patternRepeatCaps`는 비어 있을 수 없습니다.
- `BossEncounterBudgetProfile.companionWaveCap`은 100일 최종 보스를 제외하고 2를 넘을 수 없습니다.
- `BossEncounterBudgetProfile.forbiddenAdjustmentTags`에는 보상 증가, 희귀도 보정, 카드 후보 수 증가, 비활성 방향 스폰, 예고 없는 즉사를 포함해야 합니다.
- `boss_budget_winter_gate_final_100`은 6단계 흐름을 유지해야 하며, 같은 압박을 무한 반복하는 `repeatUntilDead`류 필드를 가질 수 없습니다.
- 모든 `ResponseTag.supportedEnemyRoleProfileIds`는 존재하는 `EnemyRoleProfile.id`만 참조합니다.
- `ResponseTag.hardCounterForbidden`이 `true`인 태그는 적을 즉시 삭제하거나 보스 패턴을 제거하는 효과로 쓰지 않습니다.
- 모든 `CardRewardProfile.preferredResponseTags`는 존재하는 `ResponseTag.id`만 참조합니다.
- 모든 `CardRewardProfile.preferredArchetypeIds`는 존재하는 `CardArchetype.id`만 참조합니다.
- 모든 `CardRewardProfile.lootPoolIds`는 존재하는 `CardLootPool.id`만 참조합니다.
- `CardRewardProfile.nextWaveIntentIds`는 존재하는 `WaveIntent.id`만 참조합니다.
- `CardRewardProfile.nextEnemyRoleProfileIds`는 존재하는 `EnemyRoleProfile.id`만 참조합니다.
- `CardRewardProfile.maxSameResponseTagCandidates`는 1~2 사이여야 하며, 기본값은 1입니다.
- `CardRewardProfile.maxSamePoolLaneCandidates`는 1~2 사이여야 하며, 기본값은 1입니다.
- `CardRewardProfile.maxSameArchetypeCandidates`는 1~2 사이여야 하며, 기본값은 2입니다.
- `CardRewardProfile.heroicCommitPolicy: requires_two_support_cards`이면 해당 아키타입 카드가 덱에 2장 이상 있을 때만 확정 카드를 보여줍니다.
- 모든 시작 덱은 정확히 10장입니다.
- 모든 `EnemyData.enemyRoleProfileId`는 존재하는 `EnemyRoleProfile.id`를 가리킵니다.
- `EnemyData.intentAffinityIds`는 존재하는 `WaveIntent.id`만 참조합니다.
- `EnemyData.structureAttackIntervalSeconds`는 0보다 커야 합니다.
- 모든 `EnemyRoleProfile`은 `minimumCounterTags`를 3개 이상 가져야 하며, 그중 최소 2개는 서로 다른 직업 또는 공용 대응으로 해결 가능해야 합니다.
- `EnemyRoleProfile.requiredWarningTags`가 비어 있으면 강한 역할 질문으로 사용할 수 없습니다.
- 1인 웨이브에서는 `EnemyRoleProfile.soloStrongQuestionLimit`을 넘는 강한 역할 질문을 만들지 않습니다.
- `playerCountAtStart`는 1~4 사이입니다.
- `activeDirections`는 인원수별 활성 방향 테이블과 일치합니다.
- `scalingProfileId`는 인원수와 맞는 스케일링 프로필을 가리킵니다.
- `CombatTuningProfile.baselinePlayerCount`는 2를 기본으로 합니다.
- `CombatTuningProfile.baseCriticalHp`는 `baseHpMax`의 30% 이하 기준과 일치해야 합니다.
- `CombatTuningProfile.killBurstWindowSeconds`는 3입니다.
- `CombatTuningProfile.forbiddenTuningLevers`에는 웨이브 겹치기 보상, 막타 보너스, 시간 경과 마나 회복, 접근성 전투력 보정을 포함합니다.
- 모든 런은 정확히 하나의 `BaseHealthRule`을 참조해야 합니다.
- `BaseHealthRule.baseHpMax`는 MVP에서 30입니다.
- `BaseHealthRule.criticalHpRange`는 `waveStackUnanimousHpPercent` 0.30 기준과 일치해야 합니다.
- `BaseHealthRule.baseDamageBundleWindowSeconds`는 UI 표시 묶음에만 쓰이며, 실제 기지 피해를 줄일 수 없습니다.
- `BaseHealthRule.normalWaveFatalPolicy`는 `defeat_on_zero_after_packet`이어야 합니다.
- 모든 `BaseDamagePacket.direction`은 null이 아니면 `RunState.activeDirections`의 부분집합이어야 합니다.
- 모든 `BaseDamagePacket.baseDamage`는 1 이상이어야 하며, `mitigatedByIds`로 줄어든 최종 피해도 0 미만이 될 수 없습니다.
- 모든 `BaseRecoveryRule.overhealAllowed`는 MVP에서 false입니다.
- 모든 `BaseRecoveryRule.combatUseAllowed`는 MVP에서 false입니다.
- 같은 상점 세션에서 `BaseRecoveryRule` 구매는 1회를 넘을 수 없습니다.
- 기지 회복 가격과 회복량은 웨이브 겹치기 횟수, 처치 수, 클리어 시간, 접근성 설정, 솔로 모드로 바뀔 수 없습니다.
- 1~10일은 각각 정확히 하나의 `FirstSessionDayContract`를 가져야 합니다.
- `FirstSessionDayContract.waveId`는 같은 일자의 `WaveData.id`를 참조해야 합니다.
- `FirstSessionDayContract.linkedTutorialStepIds`는 존재하는 `TutorialStep.id`만 참조합니다.
- `FirstSessionDayContract.rewardProfileId`가 null이 아니면 존재하는 `CardRewardProfile.id`를 참조해야 합니다.
- `FirstSessionDayContract.maxStrongQuestionCount`는 1을 넘을 수 없습니다.
- `FirstSessionDayContract.maxSpawnDirectionCount`는 1~4일에는 1, 10일에는 2 이하이어야 합니다.
- `FirstSessionDayContract.allowedMistakeTags`는 보상, 난이도, 적 수량을 직접 바꾸는 조건으로 사용할 수 없습니다.
- `FirstSessionDayContract.forbiddenOutcomeTags`에는 개인 책임, 딜량 순위, 처치 순위, 겹치기 점수 태그를 포함합니다.
- 모든 `WaveData.waveIntentId`는 존재하는 `WaveIntent.id`를 가리킵니다.
- `WaveData.primaryQuestionTag`는 연결된 `WaveIntent.questionTag` 또는 `primaryPressureTag`와 일치해야 합니다.
- `WaveData.laneProjectionRules`는 경로 성격과 타이밍을 제안할 수 있지만, 실제 방향은 `WaveSpawnPlan.directions`에서 확정합니다.
- 모든 10일 챕터는 `ChapterIntentPlan`을 가져야 합니다.
- `ChapterIntentPlan.primaryWaveIntentIds`, `recallWaveIntentIds`, `bossReviewIntentIds`는 존재하는 `WaveIntent.id`만 참조합니다.
- 91~100일 `ChapterIntentPlan`은 새 학습 의도를 추가하지 않고, 기존 핵심 `WaveIntent`만 다시 묻습니다.
- `FinalLoadoutClosureProfile.auditDay`는 91, `finalMarketDay`는 95, `lockAfterDay`는 95를 기본값으로 사용합니다.
- `FinalLoadoutClosureProfile.maxPartyPurchases`는 2를 넘을 수 없고, `maxArtifactActions`는 1을 넘을 수 없습니다.
- `FinalLoadoutClosureProfile.abandonedWeaknessTagCount.min`은 1 이상이어야 하며, `max`는 2를 넘을 수 없습니다.
- `artifact_pool_final_closure_095`는 `isLateBuildStarter: true`인 아티팩트, 슬롯 증가 아티팩트, 웨이브 겹치기 최대치 신규 증가 아티팩트를 기본 후보로 포함할 수 없습니다.
- `artifact_pool_final_closure_095`와 `shop_session_day_095_final_market`은 보상 증가, 카드 후보 수 증가, 카드 희귀도 보정, 골드 배율, 비활성 방향 압박 태그를 가질 수 없습니다.
- 96일 이후에는 `final_market_lock_applied` 이전 상태로 되돌아가는 아티팩트 교체, 대형 카드 제거, 영웅 확정 조율 상점을 열 수 없습니다.
- 1~30일 모든 `Mvp30DayContract.day`는 중복 없이 정확히 1~30을 채워야 합니다.
- `Mvp30DayContract.lockedLearningPromiseTag`는 해당 일자의 예고, 전투 리포트, 보상/상점 추천 중 최소 1곳에서 회수되어야 합니다.
- `Mvp30DayContract.dayRole`이 `boss`인 일자는 10, 20, 30일로 제한합니다.
- 5일, 15일, 25일은 첫 작은 상점, 작은 이벤트/상점, 계절 전환 이벤트 역할을 유지해야 합니다.
- 8일, 18일, 28일의 웨이브 겹치기 역할은 기능 학습, 안정 판단, 고밀도 리허설로 구분되어야 하며 보상 증가 태그를 가질 수 없습니다.
- 21일 전에는 강한 정예형을 본격 투입할 수 없습니다.
- 29~30일 `Mvp30DayContract.lockedContentTags`에는 새 일반 적 역할 추가 금지 태그가 있어야 합니다.
- `Mvp30DayContract.tunableFields`에 없는 필드를 테스트 조정값으로 바꿀 수 없습니다.
- `Mvp30DayContract`는 카드 후보 수, 희귀도, 웨이브 보상 총량, 활성 방향 목록을 변경할 수 없습니다.
- 모든 `MvpEventContractLock.requiredEventIds`와 `candidateEventIds`는 존재하는 `EventData.id`만 참조해야 합니다.
- 1~30일 MVP의 이벤트 계약 잠금은 15일과 25일만 기본 사용합니다.
- `event_contract_lock_mvp_015.maxEventsShown`은 1이어야 하며, 작은 상점과 합산 체류 목표가 90초를 넘으면 안 됩니다.
- `event_contract_lock_mvp_025.requiredEventIds`에는 `event_season_sign_025`가 포함되어야 합니다.
- `MvpEventContractLock.defaultSafeChoicePolicy`는 무작위 위험 선택이 아니라 상태 보존 또는 지나가기여야 합니다.
- `EventData.timeoutDefaultChoiceId`는 해당 이벤트의 안전 선택지를 참조해야 합니다.
- 저주 카드를 추가하는 `EventChoice`는 `owner: personal` 또는 `owner: mixed`여야 하며, 해당 플레이어의 명시 확인 UI를 요구해야 합니다.
- 모든 `EventChoice.addsCurseCardId`는 존재하는 `CurseContractProfile.cardId`와 연결되어야 합니다.
- 모든 `CurseContractProfile.cardId`는 `catalogRole: class_curse_contract` 카드여야 합니다.
- `CurseContractProfile.requiredConfirmFields`에는 카드 미리보기, 즉시 이득, 장기 대가, 제거/안정화 힌트가 포함되어야 합니다.
- `CurseContractProfile.safeDeclineChoiceId`는 지원자 없음 또는 시간 초과 시 적용할 안전 선택지여야 합니다.
- `CurseContractProfile.forbiddenOutcomeTags`에는 강제 저주, 숨은 패널티, 대가 완전 제거, 웨이브 겹치기 보상 변경을 포함합니다.
- `CurseContractProfile.soloProjectionSafe`는 MVP에서 true여야 합니다.
- 모든 저주 계약 카드는 `CurseServicePolicy`를 통해 안정화/제거 타이밍을 가져야 합니다.
- MVP 공통 `CurseServicePolicy.sameMaintenanceServiceAllowed`는 false여야 합니다.
- `CurseServicePolicy.minimumCombatCountOwned`는 1 이상이어야 하며, 방금 받은 저주는 같은 정비에서 제거하거나 안정화할 수 없습니다.
- `CurseServicePolicy.removeUsesPartyRemovalSurcharge`는 true여야 하며, 저주 제거가 파티 전체 제거 할증을 무시하면 안 됩니다.
- `CurseServicePolicy.stabilizationKeepsCostTagCountMin`은 1 이상이어야 하며, 안정화 후에도 장기 대가 태그가 최소 1개 남아야 합니다.
- `CurseServicePolicy.maxDiscountReservationsPerCurse`는 MVP에서 1을 넘을 수 없습니다.
- 저주 안정화/제거 할인은 웨이브 겹치기 횟수, 클리어 시간, 처치 수, 비활성 방향 압박을 가격 근거로 사용할 수 없습니다.
- 모든 MVP 보상/정비/상점/이벤트/저주 화면은 `MvpUiCopyKeyLock.requiredKey`를 참조해야 합니다.
- `ui.reward.*`, `ui.settlement.*`, `ui.shop.*`, `ui.event.*`, `ui.curse.*`, `ui.first_session.*`, `ui.revisit.*` 키는 한국어와 영어 현지화 파일에 모두 존재해야 합니다.
- `MvpUiCopyKeyLock.forbiddenCopyTags`에 걸린 문구는 빌드에 포함할 수 없습니다.
- 압축 정산 화면의 문구 잠금은 `bonus_reward`, `stack_bonus`, `rarity_up`, `extra_choice` 금지 태그를 반드시 가져야 합니다.
- 상점 시간 초과 문구는 자동 구매나 강제 구매를 암시할 수 없고, 기본 행동은 `decline`이어야 합니다.
- 저주 계약 문구는 `forced_curse`, `party_pressure`, `free_reward`, `hidden_penalty` 태그를 가질 수 없습니다.
- 모든 `FirstSessionCopyTrainingBridge.copyKeyId`는 존재하는 `MvpUiCopyKeyLock.id`를 참조해야 합니다.
- 모든 `FirstSessionCopyTrainingBridge.dayRange`는 1~10 범위 안에 있어야 합니다.
- `FirstSessionCopyTrainingBridge.autoOpen`은 항상 false여야 하며, `offerButtons`에는 `close`가 반드시 포함되어야 합니다.
- `FirstSessionCopyTrainingBridge.maxOffersPerDay`는 1을 넘을 수 없습니다.
- `FirstSessionCopyTrainingBridge.forbiddenCopyTags`에는 개인 책임, 강제 훈련, 필수 카드, 보상 증가, 희귀도 증가, 비활성 방향 압박을 포함해야 합니다.
- `FirstSessionCopyTrainingBridge.linkedTrainingScenarioId`가 있으면 해당 `TrainingScenarioProfile.rewardDisabled`와 `runStateMutationDisabled`는 true여야 합니다.
- 모든 30일 MVP 런은 `runtime_budget_mvp_030` 같은 `MvpRuntimeBudgetProfile`을 참조해야 합니다.
- `MvpRuntimeBudgetProfile.excludeContinueShop`은 MVP에서 true여야 합니다.
- `MvpRuntimeBudgetProfile.endMeasurementAt`은 30일 보스 결과 요약 완료 시점이어야 하며, 31일 준비 상점을 포함할 수 없습니다.
- `MvpRuntimeBudgetProfile.forbiddenAdjustmentTags`에는 웨이브 겹치기 보상 증가, 카드 후보 수 증가, 희귀도 보정, 골드 총량 증가, 시간 경과 마나 회복, 비활성 방향 스폰, 활성 방향 재계산을 포함해야 합니다.
- 시간 예산 초과는 보상, 희귀도, 후보 수, 골드, 활성 방향, 접근성 전투력 보정, 숨겨진 난이도 보정 값을 바꿀 수 없습니다.
- MVP 대시보드는 `dashboard_run_summary`, `dashboard_pacing`, `dashboard_wave_stack_tempo`, `dashboard_defense_line`, `dashboard_cards_resources`, `dashboard_reward_shop_event`, `dashboard_learning_recall`, `dashboard_copy_guardrail` 패널을 모두 가져야 합니다.
- `PlaytestDashboardPanel.forbiddenDisplayTags`에는 개인 순위, 개인 책임, 보상 효율, 희귀도 효율, 비활성 방향 실패 원인 중 해당 패널의 위험 표시를 포함해야 합니다.
- `PlaytestDerivedMetric.segmentKeys`에는 비교 가능한 지표마다 `runMode`, `playerCountAtStart`, `activeDirections` 중 필요한 세그먼트를 포함해야 합니다.
- MVP `PlaytestDashboardViewLayout`은 `top_run_strip`, `panel_card_grid`, `red_flag_drilldown`, `next_build_action_queue` 영역을 모두 가져야 합니다.
- `PlaytestDashboardViewLayout.topStripFields`에는 `buildId`, `runMode`, `playerCountAtStart`, `activeDirections`가 반드시 포함되어야 합니다.
- `PlaytestDashboardRedFlagRule.forbiddenFixTags`에는 해당 신호가 만들 수 없는 조정 태그를 반드시 포함해야 합니다.
- 모든 `PlaytestDashboardActionQueueItem.forbiddenAutoApply`는 true여야 하며, 전투/보상/상점 데이터를 직접 수정할 수 없습니다.
- `dashboard_wave_stack_tempo`는 보상, 희귀도, 카드 후보 수, 골드 총량을 파생 지표로 계산할 수 없습니다.
- `dashboard_defense_line`은 실제 `directions` 밖의 방향을 피해 방향이나 실패 방향으로 집계할 수 없습니다.
- `dashboard_learning_recall`은 플레이어 ID별 실수 횟수, 딜량 순위, 처치 순위를 파생 지표로 계산할 수 없습니다.
- `WaveSpawnPlan.directions`는 반드시 `activeDirections`의 부분집합입니다.
- `WaveSpawnPlan.previewEnemyRoleProfileIds`는 실제 `scaledEnemyGroups`의 `EnemyData.enemyRoleProfileId`와 연결되어야 합니다.
- `WaveSpawnPlan.previewResponseTags`는 존재하는 `ResponseTag.id`만 참조합니다.
- 모든 `WavePreviewCard.direction`은 `WaveSpawnPlan.directions` 안에 있어야 합니다.
- `WavePreviewCard.forbiddenTextTags`에는 `required_class`, `guaranteed_solution`, `reward_bonus` 중 필요한 금지 태그를 포함합니다.
- 31~40일 모든 WaveData는 `chapterFlowId: summer1_heat_flow_031_040`와 `chapterPhaseIndex`를 가져야 합니다.
- 31~40일 2인 기준 `WaveSpawnPlan.directions`는 북쪽과 동쪽의 부분집합이어야 합니다.
- `OverheatZoneProfile.attackSpeedMultiplier`는 1.0보다 커야 하며, `structureDamageTakenMultiplier`도 1.0보다 커야 합니다.
- `OverheatZoneProfile.repairEfficiencyMultiplier`는 0보다 크고 1.0보다 작거나 같아야 하며, 수리를 완전히 막을 수 없습니다.
- `OverheatZoneProfile.warningSeconds`는 임시 과열에서도 1.5초 이상이어야 합니다.
- `OverheatZoneProfile.maxActiveTilesPerDirection`은 MVP 이후 첫 여름 구간에서 1을 넘을 수 없습니다.
- `OverheatZoneProfile.forbiddenRewardTags`에는 보상 배율, 골드 증가, 희귀도 증가, 카드 후보 증가를 포함해야 합니다.
- 38일 `WaveStackVoteSession.candidateSpawnPlanIds`는 40일 보스 스폰 플랜을 참조할 수 없습니다.
- 41~50일 모든 `Summer2CollapseSpawnPacketLock.packetIds`는 존재하는 `WaveSpawnPacket.packetId`를 참조해야 합니다.
- 41~50일 1인 `WaveSpawnPacket.directions`는 모두 `east`여야 합니다.
- 41~50일 2인은 `west` 또는 `south`를 실제 일반 웨이브 방향으로 사용할 수 없습니다.
- 41~50일 3인은 `south`를 실제 일반 웨이브 방향이나 후보 방향으로 사용할 수 없습니다.
- 47일과 50일 `candidateDirectionPolicy`가 `active_only`이면 후보 방향은 반드시 `activeDirections`의 부분집합이어야 합니다.
- 48일 `Summer2CollapseSpawnPacketLock.stackHandling`은 `warning_only`여야 하며 보상, 희귀도, 카드 후보 수, 골드 총량을 바꿀 수 없습니다.
- 50일 `Summer2CollapseSpawnPacketLock.stackHandling`은 `boss_locked`여야 하며 47~49일 겹치기 후보가 될 수 없습니다.
- 51~60일 모든 `Autumn1PathSpawnPacketLock.packetIds`는 존재하는 `WaveSpawnPacket.packetId`를 참조해야 합니다.
- 51~60일 `leafPathChangePlanId`가 있으면 `maxLeafChangesDuringWave`는 1 이하여야 합니다.
- 51~60일 모든 `leafCandidateTiles`, `persistentDebrisPolicyId`, `silenceZonePlanId`의 실제 위치는 `activeDirections` 안에 있어야 합니다.
- 51~60일 1인 `WaveSpawnPacket.directions`는 모두 `east`여야 합니다.
- 51~60일 2인은 `west` 또는 `south`를 실제 일반 웨이브, 낙엽 후보, 잔해 압박 방향으로 사용할 수 없습니다.
- 51~60일 3인은 `south`를 실제 일반 웨이브, 낙엽 후보, 잔해 압박, 무음 권역 방향으로 사용할 수 없습니다.
- 57일 `Autumn1PathSpawnPacketLock.stackHandling`은 `warning_only`여야 하며 보상, 희귀도, 카드 후보 수, 골드 총량을 바꿀 수 없습니다.
- 60일 `Autumn1PathSpawnPacketLock.stackHandling`은 `boss_locked`여야 하며 57~59일 겹치기 후보가 될 수 없습니다.
- 60일 선택적 동반 패킷은 `isOptionalAssistPacket: true`이고 보상, 카드 후보, 보스 파편, 아티팩트 드롭 수를 바꿀 수 없습니다.
- 61~70일 모든 `Autumn2PrioritySpawnPacketLock.packetIds`는 존재하는 `WaveSpawnPacket.packetId`를 참조해야 합니다.
- 61~70일 모든 `priorityThreatPairId`는 보상, 카드 후보, 희귀도, 골드 계산에 사용될 수 없습니다.
- 61~70일 1인 `WaveSpawnPacket.directions`는 모두 `east`여야 하며 두 방향 우선순위를 요구할 수 없습니다.
- 61~70일 2인은 `west` 또는 `south`를 실제 일반 웨이브, 정예, 방해형, 동반 웨이브 방향으로 사용할 수 없습니다.
- 61~70일 3인은 `south`를 실제 일반 웨이브, 정예, 방해형, 동반 웨이브 방향으로 사용할 수 없습니다.
- 63일 후미 정예는 `eliteSpawnTimingProfileId`와 전투 전 예고 또는 스폰 순서 경고를 가져야 합니다.
- 67일 `Autumn2PrioritySpawnPacketLock.stackHandling`은 `warning_only`여야 하며 보상, 희귀도, 카드 후보 수, 골드 총량을 바꿀 수 없습니다.
- 70일 `Autumn2PrioritySpawnPacketLock.stackHandling`은 `boss_locked`여야 하며 67~69일 겹치기 후보가 될 수 없습니다.
- 70일 `bossCompanionVariantId`는 한 번에 하나만 선택해야 하며, 선택적 동반 패킷은 보상, 카드 후보, 보스 파편, 아티팩트 드롭 수를 바꿀 수 없습니다.
- 1인용 `laneProjectionRules`와 `WaveSpawnPlan.directions`는 동쪽만 사용해야 하며, 핵심 `WaveIntent`를 삭제하지 않습니다.
- 모든 `WaveStackVoteSession.candidateSpawnPlanIds`는 이미 확정된 `WaveSpawnPlan`만 참조합니다.
- `WaveStackVoteSession.stackCountAfter`는 `currentWaveStackLimit`을 넘을 수 없습니다.
- `WaveStackVoteSession.timeoutAction`은 항상 `hold`입니다.
- `WaveStackVoteSession.requiredConsentMode`는 솔로에서는 `solo_confirm`, `baseHpPercentAtStart`가 0.30 이하이면 `unanimous`여야 합니다.
- `WaveStackVoteSession.forbiddenRewardFields`에는 보상 배율, 희귀도 보정, 카드 후보 수 증가 필드를 포함합니다.
- 보류, 만료, 취소된 겹치기 투표는 자원 페널티나 개인 책임 태그를 만들 수 없습니다.
- 모든 `WaveRewardPacket.waveId`와 `spawnPlanId`는 실제 완료된 웨이브와 스폰 계획을 참조해야 합니다.
- `WaveRewardPacket.candidateCardIdsByPlayer`는 플레이어별로 정확히 3장 후보를 가져야 합니다.
- `WaveRewardPacket.candidatePoolLaneIdsByPlayer`는 후보 카드 수와 같은 길이여야 합니다.
- `WaveRewardPacket.candidateArchetypeIdsByPlayer`는 후보 카드 수와 같은 길이여야 합니다.
- `WaveRewardPacket`은 같은 플레이어의 후보 3장에 같은 카드 풀 라인이나 같은 카드 아키타입만 반복해서 넣을 수 없습니다.
- `WaveRewardPacket.forbiddenBonusFields`에는 보상 배율, 희귀도 보정, 카드 후보 수 증가, 겹치기 클리어 보너스를 포함합니다.
- `SettlementBatch.rewardPacketIds` 수는 `sourceWaveIds` 수와 일치해야 합니다.
- `SettlementBatch.goldTotal`은 포함된 `WaveRewardPacket.goldEarned` 합계와 일치해야 합니다.
- `SettlementBatch.temporaryLockPolicy.onlyUnlockedRows`는 true여야 하며, 이미 잠근 선택을 덮어쓸 수 없습니다.
- `SettlementBatch.forbiddenSummaryTextTags`에는 3배 보상, 겹침 보너스, 희귀도 상승, 추가 선택지 태그를 포함합니다.
- 모든 `RewardChoiceLock.rewardPacketId`는 연결된 `SettlementBatch.rewardPacketIds` 안에 있어야 합니다.
- `RewardChoiceLock.choiceType: temporary_card`는 저주, 영웅 확정 조율, 이벤트 계약 카드를 선택할 수 없습니다.
- `RewardChoiceLock.reversalDeadline: before_first_paid_shop_vote`가 지나면 선택을 되돌릴 수 없습니다.
- `RewardChoiceLock.forbiddenLockTags`에는 보상 배율, 희귀도 보정, 카드 후보 수 증가, 강제 저주, 파티 강요 태그를 포함합니다.
- `RewardToMaintenanceGate.pendingRewardChoiceLockIds` 또는 `pendingCurseConfirmIds`가 남아 있으면 유료 상점 투표를 시작할 수 없습니다.
- `RewardToMaintenanceGate.maintenanceSummaryTags`는 공개된 전투 리포트, 보상 선택, 현재 덱 상태, 활성 방향 예고에서만 가져와야 합니다.
- 모든 `CombatWarningSignal.direction`은 null이 아니면 `WaveSpawnPlan.directions` 안에 있어야 합니다.
- `CombatWarningSignal.responseTagsSuggested`는 존재하는 `ResponseTag.id`만 참조합니다.
- `CombatWarningSignal.suggestedPingTypes`는 존재하는 `PingData.pingType` 후보만 참조합니다.
- `CombatWarningSignal.forbiddenActionTags`에는 자동 카드 사용, 자동 마나 소비, 자동 구조물 조작 금지 태그를 포함합니다.
- `CombatWarningSignal.shownAsMajorWarning`은 동시에 2개를 넘지 않습니다.
- `BaseBreachWarningProfile.suggestedPingTypes`는 존재하는 `PingData.pingType`만 참조해야 합니다.
- `BaseBreachWarningProfile.maxMajorInstances`는 MVP에서 1을 넘지 않습니다.
- `BaseBreachWarningProfile.forbiddenTextTags`에는 보상 증가, 특정 직업 필수, 비활성 방향 위험 표시 금지 태그를 포함합니다.
- `DangerPingCandidateProfile.requiresPlayerConfirm`은 항상 true여야 합니다.
- `DangerPingCandidateProfile.soloDisplayMode`는 솔로에서 협동 명령 문구가 아니라 자기 리마인더 문구를 사용해야 합니다.
- `DangerPingCandidateProfile.candidatePingTypes`는 웨이브 호출 제안을 기지 치명 상황의 기본 후보로 넣을 수 없습니다.
- `PingData.linkedWarningId`가 있으면 존재하는 `CombatWarningSignal.id`를 참조해야 합니다.
- `PingData.isCommand`는 항상 false입니다.
- 플레이어가 확정하지 않은 시스템 핑 후보는 직접 핑 한도와 `ping_created` 기록에 포함하지 않습니다.
- `CombatReport.responseTagsOffered`는 해당 웨이브의 `previewResponseTags`와 충돌하면 안 됩니다.
- `CombatReport.reportCards`는 최대 3개이며, 개인 책임, 딜량 순위, 보상 효율을 표시하지 않습니다.
- `DefeatAnalysisCard.priorityRank`는 1~3만 허용하며, 같은 결과 화면에 3장을 초과해 표시할 수 없습니다.
- `DefeatAnalysisCard.direction`은 null이 아니면 해당 런의 `activeDirections` 안에 있어야 합니다.
- `DefeatAnalysisCard.forbiddenBlameFields`에는 플레이어 ID, 딜량 순위, 처치 순위, 실수 소유자, 핑 미응답자 필드를 포함합니다.
- `DefeatAnalysisCard.suggestedResponseTags`는 존재하는 `ResponseTag.id`만 참조하고, 특정 직업 필수 태그를 만들 수 없습니다.
- `NextRunSuggestion.maxCarryCount`는 2를 넘을 수 없습니다.
- `NextRunSuggestion.autoApply`는 항상 false여야 합니다.
- `NextRunSuggestion.forbiddenTags`에는 직업 강제, 카드 강제, 활성 방향 변경, 보상 증가, 희귀도 보정을 포함합니다.
- `KnowledgeRevisitFlow.targetLearningTag`와 `TrainingScenarioProfile.targetLearningTag`는 같은 재방문에서 1개만 허용됩니다.
- `KnowledgeRevisitFlow.exitOptions`에는 최소 `close`가 있어야 하며, 새 런 시작을 막는 완료 조건을 만들 수 없습니다.
- `TrainingScenarioProfile.durationTargetSeconds`는 30~60초 범위여야 합니다.
- `TrainingScenarioProfile.rewardDisabled`와 `runStateMutationDisabled`는 항상 true여야 합니다.
- `TrainingScenarioProfile.activeDirectionPolicy`가 `solo_east_only`이면 동쪽 외 방향 스폰을 만들 수 없습니다.
- `TrainingScenarioProfile.forbiddenTags`에는 실제 보상, 덱 변경, 비활성 방향 스폰, 점수 등급, 메타 파워를 포함합니다.
- `SessionState.resumeFlowId`는 `session_resume_flow`입니다.
- `SessionState.connectedPlayerIds`는 `playerCountAtStart`를 덮어쓰지 않습니다.
- `reservedRoles.canAiPlayCards`는 MVP 데이터에서 `false`입니다.
- 재개 스냅샷은 `activeDirections`, `scalingProfileId`, `WaveSpawnPlan.directions`를 새로 계산하지 않습니다.
- 재접속/장기 이탈 데이터에는 보상 배율, 골드 보정, 희귀도 보정, 카드 후보 수 보정 필드가 없습니다.
- `AccessibilitySettings.accessibilityOptionsId`는 `accessibility_presentation_options`입니다.
- 접근성 설정에는 보상 배율, 카드 후보 수, 희귀도 보정, 적 수 보정, 활성 방향 변경, 체력 보정 필드가 없습니다.
- 접근성 설정은 플레이어별 표현 설정이며 `RunState`와 `WaveSpawnPlan`을 수정하지 않습니다.
- 색각 보조가 켜져도 위험, 방향, 소유권, 핑 종류는 아이콘 또는 텍스트로 함께 구분됩니다.
- 웨이브 데이터에는 보상 배율 필드가 없습니다.
- 아티팩트에는 웨이브 보상 증가 효과가 없습니다.
- 시간 기반 마나 회복 효과가 없습니다.
- 모든 적은 기지 피해와 위험도 비용을 가집니다.
- 모든 보스 부위는 파괴 보상 또는 방치 시 문제를 가집니다.
- 모든 유료 상점 항목은 골드 또는 보스 파편 가격을 가집니다. `shop_skip`과 정보성 추천 항목은 무료 가격 규칙을 사용합니다.
- `ShopItem.shopCategory: deck_upgrade`는 하나 이상의 `linkedUpgradeOptionIds`를 가져야 합니다.
- 모든 `ShopItem.linkedUpgradeOptionIds`는 존재하는 `CardUpgradeOption.id`만 참조합니다.
- `ShopItem.purchaseScope: personal_card`이면 `ownerSelectionRequired`가 true여야 합니다.
- 모든 `ShopPriceRule.shopItemId`는 존재하는 `ShopItem.id`를 참조해야 합니다.
- `ShopPriceRule.priceBand: free`가 아니면 골드 또는 보스 파편 가격 중 하나 이상을 가져야 합니다. `shop_skip`처럼 무료 선택이면 가격을 비워둘 수 있습니다.
- `ShopPriceRule.forbiddenPriceModifierTags`에는 웨이브 겹치기 횟수, 클리어 시간, 처치 수, 비활성 방향 압박, 성과 기반 희귀도 보정 태그를 포함합니다.
- 5일 상점 가격 규칙에는 영웅 카드 구매, 보스 파편 사용, 아티팩트 교체, 전환 강화가 들어갈 수 없습니다.
- `shop_session_day_005_first_shop`과 `shop_session_day_015_small_shop`은 `maxPartyPurchases`가 1을 넘을 수 없습니다.
- `shop_session_day_025_season_turn`은 `maxPartyPurchases`가 1을 넘을 수 없고, 보스 보상급 대형 보상 항목을 가질 수 없습니다.
- `shop_session_after_day_010`과 `shop_session_after_day_020`은 `maxPartyPurchases`가 2를 넘을 수 없습니다.
- `shop_session_after_day_030_mvp_result`는 MVP 종료 후 계속하기 선택 시에만 열리며, 31일 새 아키타입을 강제하는 항목을 가질 수 없습니다.
- `shop_session_day_095_final_market`은 `maxPartyPurchases`가 2를 넘을 수 없고, `shop_keep_current_build`, `shop_final_weakness_patch`, `shop_late_deck_trim_bundle`, `shop_artifact_replace`, `shop_final_market_note` 중 핵심 슬롯을 가져야 합니다.
- `shop_session_day_095_final_market`은 96일 이후 다시 열릴 수 없으며, 모든 약점 해결, 새 아키타입 시작, 아티팩트 슬롯 증가, 웨이브 겹치기 보상 증가 항목을 가질 수 없습니다.
- 모든 `MvpShopSessionLock.fixedSlotIds`, `conditionalSlotPoolIds`, `freeSlotIds`, `forbiddenSlotIds`는 존재하는 `ShopItem.id`를 참조해야 합니다.
- `MvpShopSessionLock.freeSlotIds`는 가격 0의 정보, 요약, 보류 항목만 가질 수 있고 파티 구매 한도를 소모하지 않습니다.
- `MvpShopSessionLock.maxPartyPurchases`는 연결된 `ShopSession.maxPartyPurchases`와 같아야 합니다.
- `MvpShopSessionLock.forbiddenPricingTags`에는 웨이브 겹치기 횟수, 클리어 시간, 처치 수, 비활성 방향 압박, 숨겨진 승률 예측, 성과 기반 희귀도 보정 태그를 포함합니다.
- 모든 `ShopConsumableItem.shopItemId`는 존재하는 `ShopItem.id`를 참조해야 합니다.
- 모든 `ShopConsumableItem.priceRuleId`는 존재하는 `ShopPriceRule.id`를 참조해야 합니다.
- `ShopConsumableItem.carrySlotGroup`은 MVP에서 `party_consumable`만 사용하고, 파티 소모품 슬롯 총합은 2를 넘을 수 없습니다.
- `ShopConsumableItem.usePermission`은 자동 사용이 아니라 `any_player_with_ping`이어야 합니다.
- `ShopConsumableItem.targetScope`가 방향을 가지면 해당 방향은 항상 `RunState.activeDirections`의 부분집합이어야 합니다.
- `ShopConsumableItem.validUntilPolicy`는 구매 화면에 표시되어야 하며, 만료 시 보상, 골드, 카드 후보로 환급하지 않습니다.
- 구조물 보강 소모품은 영구 최대 체력 증가, 완전 길막, 건축가 잔해 폭발 대체 효과를 가질 수 없습니다.
- 일회성 주문은 보스 본체 패턴 취소, 장기 정지, 보상 증가, 카드 후보 수 증가, 카드 희귀도 증가를 가질 수 없습니다.
- 카드 강화 상점 항목은 웨이브 겹치기 횟수, 클리어 시간, 처치 수로 가격이나 후보 수가 바뀌면 안 됩니다.
- 모든 `CardUpgradeShopOffer.candidateUpgradeOptionIds`는 존재하는 `CardUpgradeOption.id`만 참조합니다.
- `CardUpgradeShopOffer.candidateUpgradeOptionIds`는 2개를 넘을 수 없습니다.
- `CardUpgradeShopOffer.finalPriceGold`는 기본 가격과 할증 상한 25를 적용한 값이어야 합니다.
- `CardUpgradeShopOffer.timeoutDefaultAction`은 자동 구매가 아니라 `decline`이어야 합니다.
- `CardUpgradeShopOffer.competingItemIds`는 최소 1개 이상이어야 하며, 존재하는 `ShopItem.id`를 참조해야 합니다.
- `CardUpgradeShopOffer.sourceDiagnosticTags`와 `nextPressureTags`는 공개된 전투 리포트와 활성 방향 예고에서만 가져와야 합니다.
- `CardUpgradeShopOffer.forbiddenOfferTags`에는 웨이브 겹치기 기반 가격, 처치 수 할인, 클리어 시간 할인, 비활성 방향 추천, 숨겨진 승률 예측을 포함합니다.

추가 금지:

```json
{
  "directions": ["south"],
  "activeDirections": ["east"]
}
```

```json
{
  "playerCountAtStart": 1,
  "scalingProfileId": "scaling_players_4"
}
```

```json
{
  "kind": "open_inactive_direction_for_wave_stack"
}
```
