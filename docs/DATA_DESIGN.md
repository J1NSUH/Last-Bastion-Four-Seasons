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
| `setupLoopId` | string | `new_run_setup_loop_6step` |
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

새 런 준비는 `new_run_setup_loop_6step`으로 구성합니다.

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
| `equippedArtifacts` | string[] | 장착 중인 아티팩트 |
| `partyGold` | number | 파티 공유 골드 |
| `bossShards` | number | 보스 파편 |

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
  "equippedArtifacts": [],
  "partyGold": 0,
  "bossShards": 0
}
```

런 도중 플레이어가 나가거나 재접속해도 `playerCountAtStart`, `activeDirections`, `scalingProfileId`는 바꾸지 않습니다.

현재 접속 인원은 별도 세션 상태로 관리하고, 런 밸런스 기준으로 쓰지 않습니다.

## 세션 상태 데이터

세션 상태는 현재 접속과 재개 흐름을 관리하는 값입니다.

`RunState`와 달리 접속 상태에 따라 바뀔 수 있지만, 런 밸런스 기준으로 사용하지 않습니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `sessionId` | string | 현재 세션 ID |
| `runId` | string | 연결된 런 ID |
| `resumeLoopId` | string | `session_resume_loop_6step` |
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
    "notes": "네 방향 전체 협동 방어"
  }
]
```

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
  "synergyTags": ["synergy_trigger_taunt_cluster", "synergy_trigger_delayed_repair"],
  "soloCompensationProfileId": "solo_compensation_guardian"
}
```

직업 데이터는 솔로와 멀티에서 다른 기믹을 제공하지 않습니다.

솔로 보완은 활성 방향, 적 수, 시드 마나, 공용 카드 추천으로 처리합니다.

## 카드 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 카드 ID |
| `nameKo` | string | 표시명 |
| `classId` | string/null | 직업 카드면 직업 ID, 공용이면 null |
| `rarity` | enum | `common`, `rare`, `heroic`, `curse` |
| `cost` | number | 마나 비용 |
| `type` | enum | `build`, `upgrade`, `instant`, `conditional`, `economy` |
| `keywords` | string[] | 키워드 ID |
| `targetType` | enum | `tile`, `structure`, `enemy`, `area`, `self`, `none` |
| `effects` | object[] | 효과 목록 |
| `upgradeOptions` | object[] | 강화 후보 |
| `tags` | string[] | 빌드 태그 |

카드 효과는 여러 개를 가질 수 있습니다.

예시:

```json
{
  "id": "card_guardian_taunt_wall",
  "nameKo": "도발벽",
  "classId": "class_guardian",
  "rarity": "common",
  "cost": 1,
  "type": "build",
  "keywords": ["keyword_taunt"],
  "targetType": "tile",
  "effects": [
    {
      "kind": "spawn_structure",
      "structureId": "structure_taunt_tower",
      "duration": null
    }
  ],
  "upgradeOptions": [
    {
      "id": "upgrade_taunt_wall_hp",
      "nameKo": "내구 강화",
      "effect": {"kind": "modify_structure_hp", "amount": 3}
    },
    {
      "id": "upgrade_taunt_wall_radius",
      "nameKo": "도발 범위 증가",
      "effect": {"kind": "modify_taunt_radius", "amount": 1}
    }
  ],
  "tags": ["defense", "taunt", "structure"]
}
```

## 카드 보상 프로필 데이터

카드 보상은 매일 3장 중 1장 규칙을 유지합니다.

보상 프로필은 후보를 더 많이 주거나 희귀도를 올리는 데이터가 아니라, 현재 일자와 직업, 방금 겪은 문제 태그에 맞는 후보 풀을 고르는 필터입니다.

### 보상 프로필 필드

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 보상 프로필 ID |
| `dayRange` | number[] | 적용 일자 범위 |
| `phaseIndex` | number | 첫 10일 덱 성장 6단계 번호 |
| `allowedRarities` | string[] | 허용 희귀도 |
| `preferredRoleTags` | string[] | 우선 후보 역할 태그 |
| `classBiasTags` | object | 직업별로 조금 더 자주 볼 태그 |
| `observedNeedTags` | string[] | 방금 전투에서 관찰한 약점 태그 |
| `candidateCount` | number | 항상 3 |
| `allowGoldDecline` | boolean | 카드 대신 골드 선택 가능 여부 |
| `maxSameRoleCandidates` | number | 같은 역할 후보가 한 화면에 나올 수 있는 최대 수 |
| `forbiddenTags` | string[] | 이 구간에서 제외할 태그 |
| `notes` | string | 설계 의도 |

예시:

```json
{
  "id": "reward_profile_first_010_phase_004_collapse",
  "dayRange": [6, 7],
  "phaseIndex": 4,
  "allowedRarities": ["common", "rare"],
  "preferredRoleTags": ["repair", "debris", "planned_collapse", "rebuild"],
  "classBiasTags": {
    "class_guardian": ["taunt", "thorns", "damage_delay"],
    "class_architect": ["barrier", "debris", "salvage"],
    "class_elementalist": ["area_damage", "slow", "vulnerable"],
    "class_tinkerer": ["repair", "aura", "overdrive"]
  },
  "observedNeedTags": ["structure_destroyed", "line_collapsed"],
  "candidateCount": 3,
  "allowGoldDecline": true,
  "maxSameRoleCandidates": 2,
  "forbiddenTags": ["heroic_build_start", "curse_forced", "wave_stack_reward", "complete_path_block"],
  "notes": "첫 파괴형 이후 구조물 손실을 전술 선택으로 읽게 만드는 보상"
}
```

### 첫 10일 보상 처리 규칙

1. `candidateCount`는 3으로 고정합니다.
2. 웨이브 겹치기 횟수는 `allowedRarities`, `candidateCount`, `preferredRoleTags`를 바꾸지 않습니다.
3. 같은 보상 화면에서 같은 역할 태그 후보는 2장을 넘지 않습니다.
4. 직업 전용 후보가 최소 1장, 공용 보완 후보가 최대 1장 보이도록 우선합니다.
5. 첫 10일에는 저주 후보를 이벤트 선택 없이 일반 보상에 넣지 않습니다.
6. 10일 보스 직전 보상은 보스 부위 집중이나 지연을 도와도, 보스 본체를 장시간 정지시키면 안 됩니다.

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

## 적 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 적 ID |
| `nameKo` | string | 표시명 |
| `enemyType` | enum | `swarm`, `runner`, `breaker`, `resistant`, `disruptor`, `elite`, `pressure`, `support` |
| `hp` | number | 체력 |
| `speed` | number | 기본 속도 배율 |
| `structureDamage` | number | 구조물 피해 |
| `baseDamage` | number | 기지 피해 |
| `threatCost` | number | 웨이브 위험도 비용 |
| `resourceTier` | enum | `weak`, `normal`, `danger`, `elite`, `boss_part` |
| `resistances` | object | 상태이상 저항 |
| `statusResistanceProfileId` | string | 상태이상 저항 프로필 ID |
| `statusFeedbackTags` | string[] | 저항/약화 UI에 표시할 태그 |
| `behavior` | object | AI 행동 |
| `roleQuestionTags` | string[] | 이 적이 던지는 판단 질문 |
| `primaryResponseTags` | string[] | 가장 자연스러운 대응 방식 |
| `softCounterTags` | string[] | 직업이 없어도 가능한 보조 대응 |
| `forbiddenPairTags` | string[] | 같이 배치하면 과부하가 되기 쉬운 조합 태그 |

예시:

```json
{
  "id": "enemy_crack_hammer",
  "nameKo": "균열 망치",
  "enemyType": "breaker",
  "hp": 8,
  "speed": 0.8,
  "structureDamage": 3,
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
  "primaryResponseTags": ["maze", "repair", "taunt"],
  "softCounterTags": ["burst_damage", "slow", "path_extension"],
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

## 웨이브 데이터

웨이브 데이터는 보상 배율을 가지지 않습니다.

웨이브 겹치기는 여러 웨이브를 시간적으로 겹치는 기능이지, 웨이브 보상을 바꾸는 기능이 아닙니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 웨이브 ID |
| `day` | number | 등장 일자 |
| `season` | enum | `spring`, `summer`, `autumn`, `winter` |
| `preferredDirections` | string[] | 제작자가 의도한 선호 방향 |
| `directionRole` | enum/null | `fast`, `slow`, `killzone`, `short`, `any` |
| `enemyGroups` | object[] | 적 묶음 |
| `threatBudget` | number | 위험도 예산 |
| `roleQuestionBudget` | number | 이 웨이브가 동시에 던지는 강한 질문 수 |
| `roleMixTags` | string[] | 웨이브에 섞인 적 역할 질문 |
| `expectedResponseTags` | string[] | 플레이어가 사용할 수 있어야 하는 대응 태그 |
| `learningPhaseIndex` | number/null | 첫 10일 6단계 학습 압박 번호 |
| `chapterPhaseIndex` | number/null | 10일 챕터 안 6단계 운영 압박 번호 |
| `chapterLoopId` | string/null | 해당 웨이브가 속한 챕터 운영 루프 ID |
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
  "preferredDirections": ["east"],
  "directionRole": "short",
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

### 11~20일 운영 루프 데이터

11~20일 웨이브는 `chapterLoopId: "spring2_operation_loop_011_020"`를 가집니다.

`chapterPhaseIndex`는 난이도 배율이 아니라, 보상 체감, 우선순위, 상점 선택, 방향 분담, 겹치기 판단, 변형 보스를 같은 운영 루프로 묶는 태그입니다.

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

### 21~30일 MVP 협동 루프 데이터

21~30일 웨이브는 `chapterLoopId: "mvp30_coop_loop_021_030"`를 가집니다.

이 루프는 정예 타이밍, 방향 분담, 계절 전환, 여름 템포, 고밀도 리허설, 관측자 예고형을 하나의 협동 시험으로 묶습니다.

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

### 31~40일 과열 운영 루프 데이터

31~40일 웨이브는 `chapterLoopId: "summer1_heat_loop_031_040"`를 가집니다.

이 루프는 과열 타일 학습, 빠른 적 대응, 뜨거운 킬존, 냉각 상점, 과열 분담, 고열 겹치기, 과열된 거상을 하나의 자리 운영 시험으로 묶습니다.

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

### 41~50일 붕괴 운영 루프 데이터

41~50일 웨이브는 `chapterLoopId: "summer2_collapse_loop_041_050"`를 가집니다.

이 루프는 보스 후 재건, 표식 구조물, 열차단 상점, 과열 회전, 파괴형 겹치기, 사계의 관측자 강화형을 구조물 손실 판단으로 묶습니다.

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

### 51~60일 경로 재설계 루프 데이터

51~60일 웨이브는 `chapterLoopId: "autumn1_path_loop_051_060"`를 가집니다.

이 루프는 낙엽 타일, 가을의 묵자, 오래 남는 잔해, 무너진 길 상점, 오라 분산, 무너진 종탑을 경로 재설계 판단으로 묶습니다.

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

### 61~70일 우선순위 루프 데이터

61~70일 웨이브는 `chapterLoopId: "autumn2_priority_loop_061_070"`를 가집니다.

이 루프는 종탑 후 재배치, 방해형/정예 우선순위, 후미 정예, 수확 상점, 분산 우선순위, 침묵 속 겹치기, 무너진 종탑 변형을 하나의 우선 처치 판단으로 묶습니다.

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

### 71~80일 공간 압박 루프 데이터

71~80일 웨이브는 `chapterLoopId: "winter1_space_loop_071_080"`를 가집니다.

이 루프는 첫 서리, 겨울 껍질, 좁아진 방어선, 해동/이전 상점, 결빙 증가, 얼어붙은 수리, 공간 축소 중 겹치기, 겨울의 문 예고형을 공간 이전 판단으로 묶습니다.

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

### 81~90일 최종 이전 루프 데이터

81~90일 웨이브는 `chapterLoopId: "winter2_pressure_loop_081_090"`를 가집니다.

이 루프는 문 뒤의 재정비, 보스 압력 타일 학습, 압력 속 대형 적, 마지막 재설계 상점, 압력 회전, 압력 중 겹치기, 마지막 킬존 이동, 겨울의 문을 최종 이전 판단으로 묶습니다.

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
| `waveId` | string | 원본 웨이브 ID |
| `day` | number | 등장 일자 |
| `playerCountAtStart` | number | 런 시작 인원수 |
| `activeDirections` | string[] | 런 시작 시 확정된 활성 방향 |
| `directions` | string[] | 실제 스폰 방향 |
| `scaledThreatBudget` | number | 스케일링 적용 후 위험도 예산 |
| `scaledEnemyGroups` | object[] | 스케일링 적용 후 적 묶음 |
| `warnings` | string[] | 실제 예고 문구 |
| `previewCards` | object[] | 하루 시작 예고 UI에 보여줄 위험 카드 |
| `criticalWarningTags` | string[] | 전투 중 큰 경고로 승격할 수 있는 위험 태그 |
| `stackRiskLevel` | enum | `low`, `medium`, `high`, `locked` |
| `stackRiskReason` | string | 겹치기 투표 UI에 보여줄 위험 이유 |

예시:

```json
{
  "waveId": "wave_day_006_breaker_intro",
  "day": 6,
  "playerCountAtStart": 1,
  "activeDirections": ["east"],
  "directions": ["east"],
  "scaledThreatBudget": 12,
  "scaledEnemyGroups": [
    {"enemyId": "enemy_gray_march", "count": 7, "spawnDelay": 0.75},
    {"enemyId": "enemy_crack_hammer", "count": 1, "spawnDelay": 4.5}
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

## 튜토리얼 데이터

튜토리얼 데이터는 강제 조작 순서가 아니라, 어떤 판단을 언제 안전하게 보여줄지 정의합니다.

### 튜토리얼 단계 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 튜토리얼 단계 ID |
| `phaseIndex` | number | 1~6 학습 루프 번호 |
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

## 핑 데이터

핑 데이터는 협동 요청을 전장 위에 짧게 남기기 위한 표시 상태입니다.

핑은 다른 플레이어의 행동을 강제하지 않고, 카드 사용이나 자원 사용을 자동 실행하지 않습니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 핑 ID |
| `pingType` | enum | `repair`, `focus_fire`, `path_check`, `taunt_shift`, `control`, `move_killzone`, `boss_part_focus`, `wave_call_suggest`, `hold` |
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
| `ackPlayerIds` | string[] | 동의한 플레이어 |
| `claimedByPlayerIds` | string[] | 대응하겠다고 맡은 플레이어, 큰 표시는 최대 2명 |
| `resolvedByActionTags` | string[] | 실제 해소에 연결된 행동 태그 |

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
  "ackPlayerIds": ["player_guardian"],
  "claimedByPlayerIds": ["player_tinkerer"],
  "resolvedByActionTags": ["repair_card_used"]
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
| `firstBossPhasePlanId` | string/null | 첫 보스 6단계 전투 루프 ID |
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

첫 보스의 6단계 루프는 보스 본체 데이터와 분리합니다.

같은 침묵의 거상이라도 20일 변형이나 테스트 모드에서는 다른 단계 계획을 붙일 수 있어야 합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 보스 단계 계획 ID |
| `bossId` | string | 연결된 보스 ID |
| `day` | number | 기본 등장 일자 |
| `phaseSteps` | object[] | 6단계 전투 흐름 |
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

첫 보스 단계 계획은 정확히 6개 단계로 시작합니다.

각 단계는 UI 힌트, 플레이테스트 지표, 전투 리포트 태그 중 최소 1개와 연결되어야 합니다.

## 전투 리포트 데이터

전투 리포트 데이터는 웨이브 후 짧은 요약과 패배 분석 카드를 만들기 위한 기록입니다.

플레이어 순위표나 개인 책임 계산에 사용하지 않습니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `waveId` | string | 대상 웨이브 ID |
| `day` | number | 일자 |
| `result` | enum | `cleared`, `failed` |
| `primaryCauseTag` | string/null | 가장 설명력이 큰 원인 태그 |
| `secondaryCauseTags` | string[] | 보조 원인 태그, 최대 2개 |
| `breachedDirections` | object[] | 방향별 기지 피해, 누수 횟수 |
| `structureLossSummary` | object | 구조물 파괴 수, 종류, 평균 생존 시간 |
| `enemyRolePressure` | object[] | 적 역할별 압박과 대응 태그 |
| `handLockSeconds` | number | 손패가 가득 차 드로우 손실이 난 시간 |
| `stackRiskSpike` | boolean | 겹치기 후 20초 안에 위험이 급증했는지 |
| `recommendationTextId` | string/null | 결과 화면에 표시할 추천 문구 ID |

예시:

```json
{
  "waveId": "wave_day_006_breaker_intro",
  "day": 6,
  "result": "failed",
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
  "handLockSeconds": 0,
  "stackRiskSpike": false,
  "recommendationTextId": "defeat_tip_protect_marked_barricade"
}
```

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

주요 이벤트:

| 이벤트 | 추가 필드 |
| --- | --- |
| `wave_started` | `waveId`, `directions`, `enemyGroups` |
| `wave_preview_shown` | `waveId`, `previewCards`, `stackRiskLevel`, `warnings` |
| `wave_stacked` | `stackCount`, `voters`, `baseHp` |
| `wave_completed` | `duration`, `baseDamageTaken`, `destroyedStructures` |
| `wave_learning_phase_resolved` | `day`, `waveId`, `learningPhaseIndex`, `roleMixTags`, `responseTagsUsed` |
| `first_wave_role_check` | `day`, `playerId`, `classId`, `expectedResponseTags`, `observedResponseTags`, `passed` |
| `chapter_phase_resolved` | `day`, `waveId`, `chapterLoopId`, `chapterPhaseIndex`, `operationQuestionTag`, `responseTagsUsed` |
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
| `combat_warning_raised` | `warningTag`, `level`, `direction`, `targetId` |
| `combat_report_created` | `result`, `primaryCauseTag`, `secondaryCauseTags`, `recommendationTextId` |
| `structure_lifecycle_summary` | `structureId`, `purposeTag`, `riskTags`, `finalState`, `valueTags` |
| `structure_rebuilt` | `structureId`, `previousStructureId`, `sameTile`, `rebuildPolicyId` |
| `ping_created` | `pingType`, `sourceType`, `targetType`, `direction`, `linkedWarningTag` |
| `ping_acknowledged` | `pingId`, `playerId`, `ackType` |
| `ping_resolved` | `pingId`, `resolvedByActionTags`, `expired` |
| `tutorial_step_started` | `tutorialStepId`, `phaseIndex`, `teachesTags` |
| `tutorial_step_completed` | `tutorialStepId`, `duration`, `retryCount`, `hintLevelReached`, `successCriteriaTags` |
| `onboarding_hint_shown` | `hintId`, `tutorialStepId`, `day`, `hintLevel`, `reasonTag` |
| `first_session_checkpoint` | `day`, `linkedTutorialPhase`, `expectedLearningTag`, `observedActionTags` |
| `card_reward_presented` | `day`, `playerId`, `rewardProfileId`, `candidateCardIds`, `candidateRoleTags`, `excludedTags` |
| `early_deck_choice_resolved` | `day`, `playerId`, `pickedCardId`, `choiceReasonTag`, `deckSizeAfter`, `rejectedForGold` |
| `status_effect_applied` | `statusType`, `targetGrade`, `finalMultiplier`, `convertedEffectTag` |
| `status_effect_resisted` | `statusType`, `enemyId`, `resistanceProfileId`, `feedbackTag` |
| `boss_reward_granted` | `bossId`, `gold`, `bossShards`, `artifactCandidateIds` |
| `artifact_choice_presented` | `artifactPoolId`, `candidateIds`, `equippedArtifactIds`, `nextPressureTags`, `slotState` |
| `artifact_choice_resolved` | `artifactPoolId`, `selectedArtifactId`, `voteDuration`, `reasonTags` |
| `artifact_replacement_resolved` | `selectedArtifactId`, `replacedArtifactId`, `keptCurrent`, `voteDuration`, `reasonTags` |
| `shop_session_started` | `shopSessionId`, `itemIds`, `maxPartyPurchases` |
| `shop_purchase` | `itemId`, `priceGold`, `priceBossShard`, `requiresVote` |
| `shop_recommendation_shown` | `shopSessionId`, `diagnosticTags`, `nextPressureTags`, `recommendedItemIds` |
| `shop_session_completed` | `shopSessionId`, `duration`, `partyPurchasesUsed`, `extensionsUsed` |
| `event_choice_presented` | `eventId`, `triggerTags`, `choiceIds`, `timeoutDefaultChoiceId` |
| `event_choice_resolved` | `eventId`, `selectedChoiceId`, `choiceOwner`, `requiresVote`, `voteDuration`, `consequenceTags` |
| `final_phase_started` | `phaseIndex`, `dayFrom`, `dayTo`, `focusTags`, `forbiddenNewSystemTags` |
| `final_rehearsal_phase_resolved` | `chapterLoopId`, `phaseIndex`, `dayFrom`, `dayTo`, `resolvedQuestionTags`, `failedQuestionTags`, `noNewSystemPassed` |
| `final_weakness_commitment_resolved` | `shopSessionId`, `chosenFocusTags`, `abandonedWeaknessTags`, `partyPurchasesUsed`, `newArchetypeBlocked` |
| `winter_gate_final_phase_started` | `bossId`, `combatPhaseIndex`, `pressurePlanId`, `activeDirections`, `forbiddenPressureTags` |
| `final_market_resolved` | `shopSessionId`, `chosenFocusTags`, `abandonedWeaknessTags`, `partyPurchasesUsed` |
| `final_boss_phase_completed` | `phaseIndex`, `pressureZonesUsed`, `relocationsMade`, `partDestroyedIds`, `baseDamageTaken` |
| `final_result_reflection_started` | `resultId`, `outcome`, `finalDay`, `duration`, `playerCountAtStart`, `activeDirections` |
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
| `run_failed` | `cause`, `baseHp`, `stackCount`, `mostLeakedDirection` |
| `run_completed` | `duration`, `finalDay`, `artifactIds`, `finalDefenseSummaryTags` |

`directions`는 실제 스폰 방향이고, `activeDirections`는 런에서 허용된 방향 전체입니다.

둘을 분리해 기록해야 "열린 방향은 많았지만 실제로 어느 방향에서 무너졌는지"를 볼 수 있습니다.

## 최종 구간 데이터

91~100일은 별도의 새 규칙 모음이 아니라, 기존 규칙을 어떤 순서로 다시 묻는지 정의하는 데이터입니다.

### 91~100일 최종 리허설 루프 데이터

최종 10일은 `chapterLoopId: final_rehearsal_loop_091_100`으로 묶습니다.

| 일자 | `chapterPhaseIndex` | 단계 ID | 필수 기록 |
| ---: | ---: | --- | --- |
| 91 | 1 | `final_phase_001_last_line_check` | `finalKillzonePlanId`, `remainingStructureTags` |
| 92~94 | 2 | `final_phase_002_weakness_recheck` | `finalWeaknessCheckTags`, `resolvedWeaknessTags` |
| 95 | 3 | `final_phase_003_last_market` | `abandonedWeaknessTags`, `shopSessionId` |
| 96~97 | 4 | `final_phase_004_final_relocation` | `finalKillzonePlanId`, `longPressurePlanId` |
| 98~99 | 5 | `final_phase_005_last_stack_rehearsal` | `stackUsedForTempoOnly`, `finalRehearsalNoNewSystemTags` |
| 100 | 6 | `final_phase_006_winter_gate_final` | `finalBossPhasePlanId`, `finalDefenseSummaryTags` |

이 루프의 필수 필드:

- `chapterLoopId`
- `chapterPhaseIndex`
- `finalWeaknessCheckTags`
- `abandonedWeaknessTags`
- `finalKillzonePlanId`
- `longPressurePlanId`
- `finalBossPhasePlanId`
- `finalRehearsalNoNewSystemTags`

`finalRehearsalNoNewSystemTags`에는 91~100일에 새 적, 새 타일, 새 상태이상, 새 아키타입 시작, 겹치기 보상 증가가 들어오지 않았는지 기록합니다.

### 100일 결과 회고 데이터

100일 결과 화면은 `final_result_reflection_loop_6step`으로 구성합니다.

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
| `nextRunSuggestionIds` | string[] | 다음 런 제안, 최대 2개 |
| `partyChronicleId` | string/null | 저장된 파티 기록 |
| `forbiddenScoreFields` | string[] | 결과 화면에 쓰지 않을 개인 점수 필드 |

`decisiveMomentCards`는 개인별 딜량이나 실수 기록이 아니라 방향, 구조물, 위험 태그, 보스 단계 같은 전장 사건만 사용합니다.

`forbiddenScoreFields`에는 `damageRank`, `killRank`, `mistakeOwner`, `stackRewardEfficiency`처럼 협동 회고를 개인 평가나 보상 효율로 바꾸는 필드를 넣습니다.

### 런 이후 메타 진행 데이터

런 이후 메타 진행은 `post_run_meta_loop_6step`으로 구성합니다.

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

도감과 훈련장은 `knowledge_revisit_loop_6step`으로 구성합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 재방문 흐름 ID |
| `sourceType` | enum | `defeat`, `result`, `meta_unlock`, `main_menu`, `manual` |
| `reasonTag` | string | 재방문을 제안한 이유 |
| `entryType` | enum | `enemy`, `boss_part`, `structure`, `status`, `wave_stack`, `class_role` |
| `entryId` | string | 연결된 도감 항목 |
| `trainingScenarioId` | string/null | 연결된 훈련 장면 |
| `targetLearningTag` | string | 확인할 단일 학습 태그 |
| `allowedResponseTags` | string[] | 유효 대응 태그 |
| `suggestedResponseTags` | string[] | 훈련 후 보여줄 다른 가능성, 최대 2개 |
| `durationTargetSeconds` | number | 30~60초 권장 |
| `rewardDisabled` | boolean | 실제 보상 지급 여부, 항상 true |
| `forcedBuildApplied` | boolean | 자동 빌드 적용 여부, 항상 false |
| `forbiddenTrainingTags` | string[] | 금지 태그 |

`forbiddenTrainingTags`에는 `realReward`, `metaPowerGain`, `rankScore`, `forcedClass`, `forcedCard`, `inactiveDirectionSpawn`, `multiRuleLesson`을 넣습니다.

훈련 장면은 하나의 학습 태그만 다룹니다.

방해형 우선 처치와 웨이브 겹치기 판단을 한 장면에 함께 넣지 않습니다.

### 최종 단계 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 최종 단계 ID |
| `phaseIndex` | number | 1~6 |
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

최종 단계 데이터는 보상 총량, 웨이브 겹치기 보상, 활성 방향을 바꾸지 않습니다.

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
  "artifactPoolId": "artifact_pool_first_boss",
  "personalCardReward": true,
  "nextShopSessionId": "shop_session_after_day_010",
  "nextPreviewDay": 11
}
```

첫 보스의 부위 파괴는 추가 보스 파편을 주지 않습니다.

부위 파괴 보상은 전투 중 패턴 약화, 이동 속도 감소, 카드 드로우처럼 즉시 체감되는 효과로 처리합니다.

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

중요 제한:

- 웨이브 겹치기 최대치 증가는 아티팩트 효과로만 허용합니다.
- 웨이브 겹치기 보상 증가 효과는 만들지 않습니다.
- 희귀도 보정 효과도 만들지 않습니다.
- 슬롯 증가 효과를 적용해도 총 아티팩트 슬롯은 4개를 넘지 않습니다.
- `isLateBuildStarter`가 true인 아티팩트는 91일 이후 기본 후보 풀에서 제외합니다.

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
  "id": "artifact_pool_first_boss",
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
| `maxPurchasesPerRun` | number/null | 런당 구매 제한 |
| `shopCategory` | enum | `deck_cleanup`, `field_repair`, `crisis_tool`, `long_term` |
| `recommendedForTags` | string[] | 어떤 피해 진단/다음 압박에 추천되는지 |
| `alternativeItemIds` | string[] | 같은 문제를 다른 방식으로 푸는 대안 |

### 상점 세션 데이터

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | string | 상점 세션 ID |
| `day` | number | 열리는 일자 |
| `kind` | enum | `normal`, `boss`, `event`, `season` |
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
- 모든 시작 덱은 정확히 10장입니다.
- `playerCountAtStart`는 1~4 사이입니다.
- `activeDirections`는 인원수별 활성 방향 테이블과 일치합니다.
- `scalingProfileId`는 인원수와 맞는 스케일링 프로필을 가리킵니다.
- `WaveSpawnPlan.directions`는 반드시 `activeDirections`의 부분집합입니다.
- `SessionState.resumeLoopId`는 `session_resume_loop_6step`입니다.
- `SessionState.connectedPlayerIds`는 `playerCountAtStart`를 덮어쓰지 않습니다.
- `reservedRoles.canAiPlayCards`는 MVP 데이터에서 `false`입니다.
- 재개 스냅샷은 `activeDirections`, `scalingProfileId`, `WaveSpawnPlan.directions`를 새로 계산하지 않습니다.
- 재접속/장기 이탈 데이터에는 보상 배율, 골드 보정, 희귀도 보정, 카드 후보 수 보정 필드가 없습니다.
- 웨이브 데이터에는 보상 배율 필드가 없습니다.
- 아티팩트에는 웨이브 보상 증가 효과가 없습니다.
- 시간 기반 마나 회복 효과가 없습니다.
- 모든 적은 기지 피해와 위험도 비용을 가집니다.
- 모든 보스 부위는 파괴 보상 또는 방치 시 문제를 가집니다.
- 모든 상점 항목은 골드 또는 보스 파편 가격을 가집니다.

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
