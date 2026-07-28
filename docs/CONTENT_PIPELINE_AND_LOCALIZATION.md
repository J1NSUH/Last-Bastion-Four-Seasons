# Content Pipeline And Localization

이 문서는 **Last Bastion: Four Seasons**의 콘텐츠 제작, 검수, 현지화 기준을 정리합니다.

카드와 적이 늘어날수록 데이터 품질이 게임 품질이 됩니다.

## 목표

- 기획자가 콘텐츠를 표로 만들 수 있어야 합니다.
- 개발자는 표를 데이터로 쉽게 변환할 수 있어야 합니다.
- 카드 텍스트는 짧고 일관되어야 합니다.
- 한국어와 영어를 분리해 관리할 수 있어야 합니다.
- 금지된 효과가 데이터에 들어오지 않도록 검사합니다.

## 콘텐츠 제작 흐름

```text
아이디어
-> 기획 표 작성
-> ID 부여
-> 효과 태그 지정
-> 데이터 입력
-> 자동 검증
-> 테스트 빌드
-> 플레이테스트
-> 수치 조정
-> 문구 정리
```

## 파일 분리 기준

권장 데이터 파일:

```text
data/classes.json
data/cards_guardian.json
data/cards_architect.json
data/cards_elementalist.json
data/cards_tinkerer.json
data/cards_common.json
data/structures.json
data/enemies.json
data/waves_spring.json
data/waves_summer.json
data/waves_autumn.json
data/waves_winter.json
data/bosses.json
data/artifacts.json
data/artifact_side_effects.json
data/shop_items.json
data/events.json
data/party_chronicle_titles.json
data/party_chronicle_memory_tags.json
data/knowledge_entries.json
data/knowledge_revisit_offers.json
data/training_scenarios.json
data/training_hands.json
data/keywords.json
data/status_effects.json
```

현지화 파일:

```text
localization/ko.json
localization/en.json
```

MVP에서는 하나의 JSON으로 시작해도 되지만, 콘텐츠가 늘어나면 위 구조로 분리합니다.

## 콘텐츠 작성 규칙

### 카드

카드 작성 순서:

1. 카드 이름
2. 직업
3. 희귀도
4. 비용
5. 카드 유형
6. 키워드
7. 대상
8. 효과
9. 강화 방향
10. 의도

카드 설명은 두 줄 안에 들어가야 합니다.

예시:

```text
도발 타워를 설치합니다.
주변 적이 잠시 이 구조물을 우선 공격합니다.
```

피할 것:

```text
고대의 수호 의지가 깃든 방벽을 세워 적들의 증오와 분노를 한몸에 받습니다.
```

분위기는 이름과 일러스트에서 주고, 효과는 명확하게 씁니다.

### 적

적 작성 순서:

1. 이름
2. 유형
3. 체력
4. 속도
5. 기지 피해
6. 구조물 피해
7. 위험도 비용
8. 자원 등급
9. 특수 행동
10. 대응 포인트

적은 "무엇을 시험하는가"가 있어야 합니다.

체력만 높은 적은 좋은 적이 아닙니다.

### 아티팩트

아티팩트 작성 순서:

1. 이름
2. 강화하는 플레이 방식
3. 효과
4. 대가 또는 제한
5. 어울리는 직업
6. 위험한 조합
7. 운영 축
8. 다음 압박 태그
9. 교체 판단 태그

아티팩트는 단순 수치 증가보다 운영 방향을 바꿔야 합니다.

웨이브 겹치기 최대치 증가 아티팩트는 허용하지만, 보상 증가 아티팩트는 금지합니다.

슬롯 증가 아티팩트는 파워 누적보다 교체 압박 완화로 다룹니다.

어떤 효과를 적용해도 아티팩트 슬롯은 최대 4개를 넘지 않습니다.

## 현지화 키 규칙

키는 콘텐츠 ID를 기반으로 만듭니다.

예시:

```json
{
  "card.guardian_taunt_wall.name": "도발벽",
  "card.guardian_taunt_wall.desc": "도발 타워를 설치합니다.",
  "keyword.taunt.name": "도발",
  "keyword.taunt.desc": "적이 일정 시간 해당 구조물을 우선 공격합니다."
}
```

영어:

```json
{
  "card.guardian_taunt_wall.name": "Taunting Wall",
  "card.guardian_taunt_wall.desc": "Builds a taunt tower.",
  "keyword.taunt.name": "Taunt",
  "keyword.taunt.desc": "Enemies prioritize this structure for a short time."
}
```

### MVP UI 문구 키 잠금

MVP에서는 보상, 압축 정산, 상점, 이벤트, 저주 계약 문구를 임시 문자열로 만들지 않습니다.

화면 문구는 아래 네임스페이스를 사용합니다.

| 네임스페이스 | 사용 화면 | 목적 |
| --- | --- | --- |
| `ui.reward.*` | 일반 카드 보상 | 카드 선택과 골드 선택을 동등한 정상 선택으로 표시 |
| `ui.reward.heroic_*` | 20~30일 영웅 후보 | 준비된 운영, 지원 크레딧, 최근 증거, 하향 이유를 보상처럼 보이지 않게 표시 |
| `ui.settlement.*` | 겹친 웨이브 압축 정산 | 여러 정산을 묶되 추가 보상으로 보이지 않게 표시 |
| `ui.shop.*` | 상점과 파티 구매 투표 | 구매, 보류, 시간 초과 기본값을 명확히 표시 |
| `ui.shop.heroic_*` | 영웅 확정 조율 | 대상 플레이어 수락과 파티 자원 투표를 분리해 표시 |
| `ui.event.*` | 전투 사이 이벤트 | 선택의 비용, 다음 영향, 안전 선택을 짧게 표시 |
| `ui.curse.*` | 저주 계약과 저주 처리 | 개인 확인, 즉시 이득, 장기 대가, 처리 시점을 표시 |
| `ui.first_session.*` | 첫 10일 회수 문구 | 튜토리얼 판단을 실제 웨이브 사건과 한 문장으로 연결 |
| `ui.meta.*` | 런 이후 메타 진행 | 기록, 새 정보, 다음 판 메모를 보상처럼 보이지 않게 표시 |
| `ui.chronicle.*` | 파티 연대기 저장과 기록장 | 한 런을 점수표가 아니라 파티 기억 카드로 저장 |
| `chronicle.memory.*` | 파티 연대기 기억 태그 | 전장 사건과 운영 방식을 짧은 명사구로 표시 |
| `ui.revisit.*` | 도감/훈련장 재방문 | 짧게 연습, 3줄 보기, 메모, 닫기 버튼을 표시 |
| `ui.artifact.*` | 아티팩트 선택과 휴면 보관함 | 장착, 휴면, 재장착, 부작용을 보상 증가처럼 보이지 않게 표시 |
| `ui.setup.*` | 새 런 준비와 로비 | 참고 메모, 방향 미리보기, 역할 힌트, 시작 잠금을 자동 추천처럼 보이지 않게 표시 |
| `ui.vote.*` | 파티 투표 공통 | 동의, 보류, 시간 초과, 전원 동의 상태를 표시 |
| `ui.runtime.*` | 런 길이와 결과 요약 | 예상 시간과 완료 기준을 점수처럼 보이지 않게 표시 |

필수 MVP 키:

| 키 | 한국어 기본값 | 금지 태그 |
| --- | --- | --- |
| `ui.reward.title` | 보상 선택 | `bonus_reward` |
| `ui.reward.pick_card` | 카드 1장을 덱에 넣습니다. | `must_pick` |
| `ui.reward.take_gold` | 카드를 고르지 않고 골드를 받습니다. | `loss_wording` |
| `ui.reward.temporary_lock` | 미선택 보상은 안전 후보로 임시 선택됩니다. | `forced_choice` |
| `ui.reward.revert_until_shop` | 첫 유료 상점 투표 전까지 되돌릴 수 있습니다. | `hidden_rule` |
| `ui.reward.heroic_ready_badge` | 준비된 운영 | `power_reward` |
| `ui.reward.heroic_support_row` | 지원 카드 {actualCount}장 / 동등 지원 +{equivalentCount} | `hidden_rule` |
| `ui.reward.heroic_recent_proof` | 최근 전투에서 {proofSummary} | `kill_count_reward` |
| `ui.reward.heroic_tradeoff` | 남는 대가: {tradeoffSummary} | `free_power` |
| `ui.reward.heroic_downgrade_reason` | 아직 이 운영이 충분히 굴러가지 않았습니다. | `punishment_wording` |
| `ui.settlement.title` | 정산 {count}개 | `bonus_reward` |
| `ui.settlement.row_day` | {day}일 정산 | `stack_bonus` |
| `ui.settlement.no_bonus` | 각 일자의 보상을 한 화면에서 정리합니다. | `extra_choice` |
| `ui.shop.title` | 정비 상점 | `power_shop` |
| `ui.shop.skip` | 구매 없이 넘어갑니다. | `loss_wording` |
| `ui.shop.vote_start` | 파티 골드를 사용할까요? | `auto_buy` |
| `ui.shop.timeout_decline` | 시간이 끝나면 구매하지 않습니다. | `forced_purchase` |
| `ui.shop.recommendation_context` | 최근 피해와 다음 압박을 함께 봅니다. | `guaranteed_solution` |
| `ui.shop.heroic_tune_title` | 영웅 확정 조율 | `random_hero_sale` |
| `ui.shop.heroic_free_info` | 아직 조율 가능한 운영이 없습니다. | `locked_reward_tease` |
| `ui.shop.heroic_compare_only` | 비교만 할 수 있습니다. 후보 수는 늘어나지 않습니다. | `extra_choice` |
| `ui.shop.heroic_owner_first` | 받을 플레이어가 먼저 정합니다. | `party_pressure` |
| `ui.shop.heroic_owner_accept` | 이 카드를 받을까요? | `party_pressure` |
| `ui.shop.heroic_owner_hold` | 지금은 보류합니다. | `loss_wording` |
| `ui.shop.heroic_vote_title` | 영웅 조율에 파티 자원을 사용할까요? | `auto_buy` |
| `ui.shop.heroic_locked_no_shard` | 조건은 맞지만 보스 파편이 부족합니다. | `punishment_wording` |
| `ui.shop.heroic_locked_gate` | 아직 이 운영이 충분히 굴러가지 않았습니다. | `punishment_wording` |
| `ui.shop.heroic_already_bought` | 이번 상점에서는 이미 영웅을 조율했습니다. | `upsell_wording` |
| `ui.shop.heroic_no_reoffer` | 이번 상점에서는 조율을 보류했습니다. | `upsell_wording` |
| `ui.event.choice_keep_state` | 현재 상태를 유지합니다. | `loss_wording` |
| `ui.event.timeout_safe` | 시간이 끝나면 안전 선택을 적용합니다. | `random_punishment` |
| `ui.event.owner_personal` | 대상 플레이어가 직접 확정합니다. | `party_pressure` |
| `ui.event.owner_party` | 파티 투표가 필요합니다. | `auto_buy` |
| `ui.event.season_turn_title` | 계절 전환 | `season_reward` |
| `ui.event.season_sign_read` | 골드 15로 다음 압박 하나를 자세히 봅니다. | `bonus_reward` |
| `ui.event.season_sign_skip` | 넓은 요약만 보고 넘어갑니다. | `loss_wording` |
| `ui.event.reserve_core_exclusive` | 이번 정비의 임시 시드 마나 보강과 함께 쓸 수 없습니다. | `hidden_rule` |
| `ui.event.quiet_contract_owned_only` | 이미 보유한 저주 1장에만 예약합니다. | `new_curse_offer` |
| `ui.curse.confirm_title` | {cardName}을 받을까요? | `forced_curse` |
| `ui.curse.immediate` | 즉시 | `free_reward` |
| `ui.curse.cost` | 대가 | `hidden_penalty` |
| `ui.curse.service_hint` | 제거/안정화는 다음 상점부터 가능합니다. | `same_maintenance_cleanup` |
| `ui.curse.decline` | 받지 않습니다. | `party_pressure` |
| `ui.curse.service_title` | 저주 처리 | `purify_wording` |
| `ui.curse.stabilize` | 안정화 | `free_power` |
| `ui.curse.remove` | 제거 | `guaranteed_solution` |
| `ui.curse.defer` | 이번 상점에서는 처리하지 않습니다. | `loss_wording` |
| `ui.curse.discount_reserved` | 조용한 계약서 예약 -{amount} | `free_reward` |
| `ui.curse.owner_first` | 저주 소유자가 먼저 정합니다. | `party_pressure` |
| `ui.first_session.path_anchor` | 경로를 먼저 보고 첫 타워를 놓습니다. | `guaranteed_solution` |
| `ui.first_session.no_full_block` | 길은 닫지 말고 돌아가게 만듭니다. | `hard_block_solution` |
| `ui.first_session.runner_slow` | 빠른 적은 첫 굴곡에서 몇 초만 늦춰도 됩니다. | `required_card` |
| `ui.first_session.shop_context` | 상점은 방금 드러난 약점을 정리하는 곳입니다. | `forced_purchase` |
| `ui.first_session.structure_mark` | 표식 구조물은 살릴지 버릴지 먼저 정합니다. | `personal_blame` |
| `ui.first_session.stack_tempo` | 겹치기는 보상을 늘리지 않고 기다림을 줄입니다. | `stack_bonus` |
| `ui.first_session.boss_part` | 보스는 본체보다 부위와 시간을 먼저 봅니다. | `guaranteed_solution` |
| `ui.meta.run_record` | 이번 런의 기록 | `reward_firework` |
| `ui.meta.new_info` | 새로 기록된 정보 | `power_gain` |
| `ui.meta.next_note` | 다음 판 메모 | `auto_build` |
| `ui.meta.later` | 나중에 보기 | `loss_wording` |
| `ui.chronicle.save_title` | 파티 기록 저장 | `score_compare` |
| `ui.chronicle.pick_title` | 한 줄 제목을 고릅니다. | `leaderboard_wording` |
| `ui.chronicle.edit_title` | 짧게 고쳐 쓰기 | `personal_blame` |
| `ui.chronicle.memory_tags` | 기억할 장면 | `personal_achievement` |
| `ui.chronicle.save` | 기록장에 남기기 | `loss_wording` |
| `ui.chronicle.later` | 나중에 | `loss_wording` |
| `ui.chronicle.favorite` | 즐겨찾기 | `score_compare` |
| `ui.chronicle.empty` | 아직 저장한 파티 기록이 없습니다. | `loss_wording` |
| `chronicle.memory.first_bend_delay` | 첫 굴곡 지연 | `inactive_direction` |
| `chronicle.memory.rear_killzone` | 후방 킬존 | `score_compare` |
| `chronicle.memory.stack_held` | 겹치기 보류 | `stack_bonus` |
| `chronicle.memory.boss_part_focus` | 보스 부위 집중 | `guaranteed_solution` |
| `ui.revisit.short_practice` | 짧게 연습 | `forced_training` |
| `ui.revisit.three_line_entry` | 3줄 보기 | `homework_wording` |
| `ui.revisit.carry_note` | 메모로 가져가기 | `auto_build` |
| `ui.revisit.close` | 닫기 | `loss_wording` |
| `ui.revisit.reason` | 방금 장면과 이어집니다. | `forced_training` |
| `ui.revisit.retry` | 다시 시도 | `training_score` |
| `ui.revisit.used_tags` | 사용한 대응 | `personal_achievement` |
| `ui.revisit.other_options` | 다른 가능성 | `guaranteed_solution` |
| `ui.revisit.no_reward` | 실제 런 보상은 바뀌지 않습니다. | `loss_wording` |
| `ui.artifact.dormant_title` | 휴면 보관함 | `bonus_inventory` |
| `ui.artifact.effect_off` | 효과 꺼짐 | `hidden_rule` |
| `ui.artifact.reactivate` | 재장착 투표 | `auto_build` |
| `ui.artifact.reactivate_cost` | 보스 파편 {count} 필요 | `free_reward` |
| `ui.artifact.release` | 보관함에서 제외 | `loss_wording` |
| `ui.artifact.keep_current` | 현재 유지 | `loss_wording` |
| `ui.artifact.side_effect` | 대가 | `hidden_penalty` |
| `ui.artifact.no_reward_increase` | 보상은 늘어나지 않습니다. | `stack_bonus` |
| `ui.setup.suggestions` | 참고 메모 | `auto_build` |
| `ui.setup.no_suggestion` | 가져온 메모가 없습니다. | `loss_wording` |
| `ui.setup.direction_preview` | 시작하면 이 방향으로 고정됩니다. | `direction_recalc` |
| `ui.setup.lock_notice` | 시작 후에는 인원이 바뀌어도 방향과 규모가 유지됩니다. | `hidden_rule` |
| `ui.setup.role_hint` | 부족한 대응 태그 | `required_class` |
| `ui.setup.intent` | 이번에 시험할 운영 | `forced_setup` |
| `ui.setup.intent_empty` | 메모 없이 시작합니다. | `loss_wording` |
| `ui.setup.start` | 런 시작 | `reward_mode` |
| `ui.setup.ready_reset` | 인원이 바뀌어 준비 확인이 다시 필요합니다. | `personal_blame` |
| `ui.setup.no_auto_apply` | 메모는 세팅을 바꾸지 않습니다. | `auto_build` |

현지화 금지 태그 사전:

| 태그 | 막는 표현 |
| --- | --- |
| `bonus_reward` | 추가 보상, 보상 증가, 보너스 보상 |
| `season_reward` | 계절 전환을 보상 축제나 시즌 보너스로 보이게 하는 표현 |
| `stack_bonus` | 겹치기 보너스, 3배 보상, 러시 보상 |
| `rarity_up` | 희귀도 상승, 고급 보상 확률 증가 |
| `extra_choice` | 추가 카드 후보, 선택지 증가 |
| `bonus_inventory` | 추가 장비칸, 보너스 보관함, 효과 유지 보관 표현 |
| `must_pick` | 지금 안 고르면 손해, 필수 선택 |
| `loss_wording` | 포기, 손해, 버림패 같은 부정적 선택 표현 |
| `forced_purchase` | 자동 구매, 강제 구매 |
| `forced_curse` | 강제 저주, 떠안기, 희생 필요 |
| `free_reward` | 공짜 보상, 대가 없는 이득 |
| `free_power` | 대가 없는 강화, 순수 상위호환, 공짜 파워 |
| `power_reward` | 강한 보상, 상위 보상, 대박 카드 |
| `kill_count_reward` | 처치 수로 보상이나 영웅 조건이 좋아진다는 표현 |
| `random_hero_sale` | 상점에서 영웅 카드를 무작위로 판다는 표현 |
| `punishment_wording` | 조건 실패를 벌점, 실패, 손실처럼 보이게 하는 표현 |
| `upsell_wording` | 이미 산 뒤 추가 구매나 상위 상품을 권하는 표현 |
| `hidden_penalty` | 숨은 대가, 나중에 공개되는 불이익 |
| `hidden_rule` | 조건이나 되돌리기 가능 시점이 숨겨져 있다는 느낌의 표현 |
| `same_maintenance_cleanup` | 방금 받은 저주를 같은 정비에서 처리 가능하다는 암시 |
| `new_curse_offer` | 보유 저주 처리 화면을 새 저주 제안처럼 보이게 하는 표현 |
| `purify_wording` | 저주 정화, 치료, 완치처럼 대가가 사라지는 느낌의 표현 |
| `party_pressure` | 파티를 위해, 반드시 필요, 대신 희생 |
| `guaranteed_solution` | 정답, 추천 삭제, 무조건 제거 |
| `inactive_direction` | 비활성 방향을 위험 방향처럼 표시하는 표현 |
| `required_card` | 특정 카드가 필요하다는 표현 |
| `required_class` | 특정 직업이 필요하거나 정답 조합이라는 표현 |
| `hard_block_solution` | 완전 길막이 정답처럼 보이는 표현 |
| `personal_blame` | 특정 플레이어 책임, 실수 소유자 표현 |
| `forced_training` | 훈련 완료가 필요하거나 강제된다는 표현 |
| `homework_wording` | 숙제, 과제, 완료 체크리스트처럼 보이는 표현 |
| `auto_build` | 직업, 카드, 아티팩트, 방향을 자동으로 바꾼다는 표현 |
| `forced_setup` | 로비 메모나 힌트가 세팅을 강제로 정한다는 표현 |
| `reward_mode` | 런 길이, 웨이브 겹치기, 로비 선택이 보상 모드라는 표현 |
| `direction_recalc` | 시작 후 접속 인원으로 활성 방향이 다시 계산된다는 표현 |
| `power_gain` | 영구 공격력, 체력, 마나, 승률, 보상 확률이 오른다는 표현 |
| `reward_firework` | 결과 직후 해금을 큰 보상 폭죽이나 성과 상자처럼 보이게 하는 표현 |
| `leaderboard_wording` | 리더보드, 순위표, 랭킹, 최고 기록 표현 |
| `score_compare` | 점수, 승률, 평균 점수, 효율 비교 표현 |
| `personal_achievement` | MVP, 캐리, 개인 최고, 개인 업적 표현 |
| `training_score` | 훈련 점수, 성공률, 등급, 별점 평가 표현 |

예시:

```json
{
  "ui.reward.take_gold": "카드를 고르지 않고 골드를 받습니다.",
  "ui.settlement.no_bonus": "각 일자의 보상을 한 화면에서 정리합니다.",
  "ui.shop.timeout_decline": "시간이 끝나면 구매하지 않습니다.",
  "ui.event.timeout_safe": "시간이 끝나면 안전 선택을 적용합니다.",
  "ui.curse.service_hint": "제거/안정화는 다음 상점부터 가능합니다.",
  "ui.chronicle.save_title": "파티 기록 저장",
  "ui.chronicle.later": "나중에",
  "ui.revisit.reason": "방금 장면과 이어집니다.",
  "ui.revisit.no_reward": "실제 런 보상은 바뀌지 않습니다.",
  "ui.artifact.dormant_title": "휴면 보관함",
  "ui.artifact.effect_off": "효과 꺼짐",
  "ui.setup.no_auto_apply": "메모는 세팅을 바꾸지 않습니다.",
  "ui.setup.lock_notice": "시작 후에는 인원이 바뀌어도 방향과 규모가 유지됩니다."
}
```

## 한국어 문체

기본 문체:

- 짧게 씁니다.
- 효과 중심으로 씁니다.
- 존댓말보다 설명문을 씁니다.
- 카드 설명에는 감탄문을 쓰지 않습니다.

권장:

```text
선택한 구조물을 수리합니다.
파괴될 때 주변 적에게 피해를 줍니다.
```

비권장:

```text
선택한 구조물을 눈부신 기술력으로 완벽하게 수리해냅니다!
```

## 영어 문체

영어는 짧은 동사로 시작합니다.

권장:

```text
Build a barricade.
Deal damage in an area.
Repair a structure.
```

피할 것:

```text
You may choose a structure in order to restore some of its health.
```

## 키워드 관리

키워드는 별도 사전에 정의합니다.

카드 설명에서 같은 효과를 매번 풀어 쓰지 않습니다.

예시:

```text
도발 타워를 설치합니다.
```

키워드 툴팁:

```text
도발: 적이 일정 시간 해당 구조물을 우선 공격합니다.
```

## 텍스트 길이 제한

| 항목 | 한국어 권장 길이 |
| --- | ---: |
| 카드 이름 | 2~8자 |
| 카드 설명 | 35자 이하 2줄 |
| 키워드 설명 | 40자 이하 |
| 적 설명 | 60자 이하 |
| 아티팩트 설명 | 70자 이하 |
| 이벤트 선택지 | 45자 이하 |
| 보상/상점 버튼 | 18자 이하 |
| 보상/상점 보조 문구 | 45자 이하 |
| 이벤트 등장 이유 | 55자 이하 |
| 저주 확인 문구 | 항목당 45자 이하 |

짧은 문장은 UI 안정성을 높입니다.

## 자동 검증 규칙

콘텐츠 데이터는 빌드 전 자동 검사를 통과해야 합니다.

검사:

- ID 중복 없음
- 현지화 키 누락 없음
- MVP 보상/상점/이벤트/저주/결과 이후 화면의 필수 `ui.*` 키 누락 없음
- `ui.reward.*`, `ui.settlement.*`, `ui.shop.*`, `ui.event.*`, `ui.curse.*`, `ui.first_session.*`, `ui.meta.*`, `ui.chronicle.*`, `ui.revisit.*`, `ui.artifact.*`, `ui.setup.*` 키에 금지 태그 표현 없음
- 압축 정산 문구에 3배 보상, 겹치기 보너스, 희귀도 상승, 추가 선택지 표현 없음
- 상점 시간 초과 문구가 자동 구매나 강제 구매처럼 보이지 않음
- 저주 계약 문구에 희생 강요, 파티 압박, 공짜 보상 표현 없음
- 카드 비용 0 이상
- 시작 덱 정확히 10장
- 카드 설명 길이 제한
- 첫 10일 보상 프로필 후보 수 3장 고정
- 첫 10일 보상 화면의 같은 역할 태그 3장 동시 노출 금지
- 첫 10일 회수 문구가 `FirstSessionCopyTrainingBridge`와 `MvpUiCopyKeyLock`을 참조함
- 첫 10일 재방문 버튼에 닫기 선택이 있고 자동 훈련 진입이 없음
- 웨이브 보상 배율 필드 없음
- 웨이브 희귀도 보정 필드 없음
- 웨이브 겹치기 횟수 기반 카드 보상 프로필 변경 없음
- 시간 경과 마나 회복 효과 없음
- 첫 10일 WaveData의 `learningPhaseIndex` 누락 없음
- 첫 10일 새 적 등장일의 강한 다방향 압박 없음
- 1인 첫 10일 동쪽 외 일반 웨이브 없음
- 11~20일 WaveData의 `chapterFlowId`와 `chapterPhaseIndex` 누락 없음
- 11~20일 1인 동쪽 외 일반 웨이브 없음
- 11~20일 4인 사방 동시 압박 없음
- 20일 침묵의 거상 변형이 한 번에 2개 이상 변형을 선택하지 않음
- 21~30일 WaveData의 `chapterFlowId`와 `chapterPhaseIndex` 누락 없음
- 21~30일 1인 동쪽 외 일반 웨이브 없음
- 21~30일 2인 3방향 이상 동시 압박 없음
- 21~30일 3인 남쪽 일반 웨이브 없음
- 30일 관측자 예고형 후보 방향이 `activeDirections` 밖으로 나가지 않음
- 31~40일 WaveData의 `chapterFlowId`와 `chapterPhaseIndex` 누락 없음
- 과열 타일이 비활성 방향 설치 구역에 생성되지 않음
- 과열 타일 관련 보상 배율, 희귀도, 카드 후보 증가 필드 없음
- 잿불 석공과 과열된 거상의 과열 생성 예고 누락 없음
- 41~50일 WaveData의 `chapterFlowId`와 `chapterPhaseIndex` 누락 없음
- 열톱니와 파괴형 표식의 예고 시간 누락 없음
- 표식 구조물에 살림/희생/후방 재건 선택지 누락 없음
- 47일과 50일 후보 방향이 `activeDirections` 밖으로 나가지 않음
- 51~60일 WaveData의 `chapterFlowId`와 `chapterPhaseIndex` 누락 없음
- 낙엽 후보 타일이 `activeDirections` 밖으로 나가지 않음
- 낙엽 변화 예고 누락 없음
- 웨이브 중 낙엽 변화가 1회를 초과하지 않음
- 낙엽과 잔해로 완전 길막이 가능한 데이터에 `routeReopenPolicyId` 누락 없음
- 가을의 묵자가 마나 획득 또는 사용을 완전히 봉쇄하지 않음
- 57일 겹치기 안내에 보상, 희귀도, 카드 후보 증가 문구 없음
- 60일 무너진 종탑의 무음 권역 예고 누락 없음
- 60일 무너진 종탑의 오라/수리 약화값이 0으로 떨어지지 않음
- 60일 무음 권역, 낙엽 변화, 동반 웨이브가 `activeDirections` 밖으로 나가지 않음
- 61~70일 WaveData의 `chapterFlowId`와 `chapterPhaseIndex` 누락 없음
- 61~70일 후미 정예 예고 또는 스폰 순서 경고 누락 없음
- 61~70일 방해형/정예 동시 투입 데이터에 `disruptorEliteMixPolicyId` 누락 없음
- 61~70일 1인 데이터가 동쪽 외 일반 웨이브나 두 방향 우선순위 판단을 만들지 않음
- 61~70일 3인 데이터가 남쪽 정예, 방해형, 동반 웨이브를 만들지 않음
- 67일 겹치기 안내에 보상, 희귀도, 카드 후보 증가 문구 없음
- 70일 무너진 종탑 변형이 `boss_phase_plan_belltower_variant_070`을 사용함
- 70일 변형 보스가 새 부위, 새 패턴, 강한 동반 웨이브를 동시에 추가하지 않음
- 70일 동반 웨이브가 `activeDirections` 밖으로 나가지 않음
- 71~80일 WaveData의 `chapterFlowId`와 `chapterPhaseIndex` 누락 없음
- 결빙 후보 타일이 `activeDirections` 밖으로 나가지 않음
- 결빙 후보 타일이 경로 타일을 포함하지 않음
- 결빙 예고 누락 없음
- 71~79일 일반 웨이브 중 추가 결빙이 1회를 초과하지 않음
- 80일 보스 결빙은 `WinterGatePreviewFrostCycle`로만 관리됨
- 결빙이 구조물 즉시 삭제, 보상 배율, 골드 증가, 카드 후보 증가를 만들지 않음
- 겨울 껍질 데이터에 지속 화력, 둔화, 도발, 잔해 중 하나 이상의 대응 태그가 있음
- 78일 겹치기 안내에 보상, 희귀도, 카드 후보 증가 문구 없음
- 80일 겨울의 문 예고형이 `boss_phase_plan_winter_gate_preview_080`을 사용함
- 80일 보스가 장기 공간 봉쇄나 예고 없는 구조물 삭제를 사용하지 않음
- 80일 결빙 권역과 동반 웨이브가 `activeDirections` 밖으로 나가지 않음
- 81~90일 WaveData의 `chapterFlowId`와 `chapterPhaseIndex` 누락 없음
- 보스 압력 후보 권역이 `activeDirections` 밖으로 나가지 않음
- 보스 압력 후보 권역이 경로 타일을 포함하지 않음
- 보스 압력 예고 누락 없음
- 보스 압력 타일이 구조물 즉시 삭제, 보상 배율, 골드 증가, 카드 후보 증가를 만들지 않음
- 81~90일 `Winter2PressureSpawnPacketLock`이 존재하는 `WaveSpawnPacket`만 참조함
- 81~90일 `PressureTilePlanLock`의 동시 압력 권역이 1개를 넘지 않음
- 81~89일 일반 웨이브 중 압력 이동이 2회를 초과하지 않음
- 81~90일 2인 기준 실제 방향이 북쪽/동쪽 안에 있음
- 87일 겹치기 안내에 보상, 희귀도, 카드 후보 증가 문구 없음
- 87일 겹치기 후보가 87~89일 일반 웨이브만 참조하고 90일 보스를 참조하지 않음
- 90일 겨울의 문이 `boss_phase_plan_winter_gate_090`을 사용함
- 90일 보스가 100일 완전체처럼 지나간 권역을 장기 봉쇄하지 않음
- 90일 압력 권역과 동반 웨이브가 `activeDirections` 밖으로 나가지 않음
- 90일 선택적 동반 웨이브가 보상 팩, 카드 후보, 보스 파편, 아티팩트 드롭 수를 추가하지 않음
- 90일 `winter_gate_phase_lock_090`이 `boss_phase_plan_winter_gate_090`의 6단계만 참조함
- 90일 이동 압력 사이클이 4회를 초과하지 않음
- 90일 이동 압력 권역이 동시에 1개를 넘지 않음
- 90일 이동 압력 권역이 다음 사이클 전에 회복됨
- 90일 이동 압력 사이클이 경로 타일 차단, 장기 압력 권역, 구조물 즉시 삭제를 만들지 않음
- 91~100일 WaveData의 `chapterFlowId: final_rehearsal_flow_091_100`와 `chapterPhaseIndex` 누락 없음
- 91~100일에 새 적, 새 타일, 새 상태이상, 새 카드 규칙 학습 태그 없음
- 95일 마지막 상점에 큰 파티 구매 최대 2회 제한과 `abandonedWeaknessTags` 기록 있음
- 98일 겹치기 안내에 보상, 희귀도, 카드 후보 증가 문구 없음
- 99일 웨이브 데이터에 새 규칙 튜토리얼 문구 없음
- 100일 겨울의 문 완전체가 `boss_phase_plan_winter_gate_final_100`을 사용함
- 100일 장기 압력 권역이 `activeDirections` 밖으로 나가지 않음
- 100일 장기 압력 권역이 경로 타일을 포함하지 않음
- 100일 보스가 모든 압박을 한 순간에 최대 강도로 겹치지 않음
- 100일 결과 화면이 `final_result_reflection_flow`를 사용함
- 결과 화면의 결정적 장면 카드가 3장을 초과하지 않음
- 결과 화면 텍스트에 개인 딜량 순위, 처치 순위, 개인 실수 소유자 표현 없음
- 결과 화면 텍스트에 겹치기 보상 효율, 추가 보상, 희귀도 효율 표현 없음
- 다음 런 제안이 2개를 초과하지 않고 정답 빌드나 필수 직업처럼 표시되지 않음
- 파티 기록이 점수 랭킹보다 파티 조합, 아티팩트, 마지막 방어선 태그를 우선함
- 파티 연대기 제목 후보가 3개를 초과하지 않고 개인 책임, 캐리, 딜량, 처치 순위, 클리어 등급, 최고 점수 표현을 쓰지 않음
- 파티 연대기 기억 태그 라벨이 2~10자 정도의 짧은 명사구이며, 기본 48개 태그가 한국어/영어 키를 모두 가짐
- `chronicle.memory.*` 키에 개인 성과, 점수 비교, 겹치기 보상, 비활성 방향 위험 표현 없음
- 파티 연대기 기록장에 승률, 최고 점수, 평균 점수, 개인 기여도, 웨이브 겹치기 효율, 보상 효율 필터가 없음
- `ui.chronicle.later`가 저장하지 않으면 손해처럼 읽히지 않음
- 런 이후 메타 진행이 `post_run_meta_flow`를 사용함
- 메타 화면이 이번 런 기록 1장, 새 정보/훈련 해금 최대 2장, 다음 런 메모 1장만 크게 표시함
- 메타 문구에 영구 파워 증가, 보상 폭죽, 승률 보정처럼 읽히는 표현 없음
- 메타 데이터에 영구 공격력, 구조물 체력, 마나 회복량, 웨이브 보상 배율 증가 필드 없음
- 딜량, 처치 수, 웨이브 겹치기 횟수, 개인 실수 태그가 메타 해금량 증가 조건으로 쓰이지 않음
- 새 카드/아티팩트 해금 항목에 역할 태그와 등장 구간 누락 없음
- 다음 런 준비 제안이 2개를 초과하지 않고 직업이나 카드를 강제하지 않음
- 도감/훈련 해금이 실제 발견, 보스 조우, 실패/회고 태그 중 하나와 연결됨
- 외형 보상이 전투 수치나 보상 확률에 영향을 주지 않음
- 도감/훈련장 재방문이 `knowledge_revisit_flow`를 사용함
- 재방문 제안에 패배 원인, 결과 회고, 메타 해금, 처음 만난 적 중 하나의 이유 태그 있음
- 결과 직후 즉시 재방문 제안은 1개 이하이고 자동으로 훈련장을 열지 않음
- 같은 재방문 제안을 두 런 연속 닫으면 큰 카드 재노출을 막는 문구/상태가 있음
- 훈련 장면의 `targetLearningTag`가 1개만 있음
- 훈련 장면이 실제 골드, 카드, 아티팩트, 메타 파워를 지급하지 않음
- 훈련 장면이 `activeDirections` 밖 스폰이나 필수 방어 압박을 만들지 않음
- 도감 카드 텍스트에 정답 빌드, 필수 직업, 강제 카드 추천 표현 없음
- MVP 도감 카드 6개가 모두 3줄 요약을 가지며, 기본 노출에서 4줄 이상으로 늘어나지 않음
- MVP 훈련 장면 4개가 30~60초, 단일 학습 태그, 고정 훈련 손패, 보상 없음 조건을 만족함
- 훈련 결과 문구에 점수, 등급, 성공률, 개인 평가 표현 없음
- 대응 비교 화면에 점수, 등급, 개인 평가 표현 없음
- 재방문 완료 여부가 런 시작, 난이도, 보상 확률을 잠그거나 보정하지 않음
- 새 런 준비가 `new_run_setup_flow`를 사용함
- 다음 런 제안이 2개를 초과하지 않고 직업, 카드, 아티팩트, 활성 방향을 자동 변경하지 않음
- `ui.setup.*` 필수 키가 모두 존재하고 `forced_setup`, `reward_mode`, `direction_recalc`, `auto_build`, `required_class` 금지 태그 표현을 쓰지 않음
- 로비 활성 방향 미리보기가 인원수별 활성 방향 표와 일치함
- 로비 참고 메모 문구가 자동 적용, 정답 빌드, 필수 직업, 특정 카드 강요처럼 읽히지 않음
- 런 시작 후 `playerCountAtStart`, `activeDirections`, `scalingProfileId`, `seed` 변경 없음
- 런 설정 화면에 웨이브 겹치기 보상 모드, 희귀도 증가 모드, 카드 후보 수 증가 모드 없음
- 직업 선택 화면 텍스트에 필수 직업, 정답 조합, 자동 빌드 표현 없음
- 비활성 방향이 로비 미리보기에서 위험 방향이나 추천 방어 방향으로 표시되지 않음
- 중단과 재개가 `session_resume_flow`를 사용함
- 저장점은 하루 시작, 보스 처치 후, 상점 진입, 아티팩트 선택 완료 중 하나임
- 전투 중 완전 저장 버튼이나 수동 세이브 문구가 MVP UI에 없음
- 보류 모드 문구가 AI 자동 플레이, 개인 카드 자동 사용, 개인 마나 자동 소비처럼 보이지 않음
- 재접속/장기 이탈이 보상, 골드, 희귀도, 카드 후보 수, 웨이브 보상 배율을 바꾸지 않음
- 재개 화면이 현재 접속 인원으로 활성 방향, 스케일링, 웨이브 방향을 다시 계산한다고 표시하지 않음
- 접근성과 연출 옵션이 `accessibility_presentation_options`를 사용함
- 접근성 옵션 데이터에 보상 배율, 카드 후보 수, 희귀도, 적 수, 활성 방향, 체력 보정 필드 없음
- 접근성 옵션 문구에 쉬운 모드, 보상 증가, 희귀도 증가, 카드 후보 증가, 적 약화 표현 없음
- 화면 흔들림 감소 상태에서도 보스 치명 예고, 타이머, 타겟 하이라이트가 유지됨
- 저주파 보스음 감소 상태에서도 자막, 시각 경고, 핑 로그가 유지됨
- 위험, 방향, 소유권, 핑 종류가 색상 하나로만 구분되지 않음
- 공포 연출이 경로, 타겟, 보스 패턴, 기지 위험 정보를 숨기거나 왜곡하지 않음
- 아티팩트 슬롯 최대치 4 초과 없음
- 웨이브 겹치기 최대치 증가에는 대가 또는 제한이 있음
- 적은 위험도 비용을 가짐
- 보스 부위는 파괴 보상을 가짐

## 검수 체크리스트

카드 검수:

- 사용 타이밍이 명확한가?
- 특정 직업의 역할을 침범하지 않는가?
- 텍스트만 읽고 결과를 예측할 수 있는가?
- 키워드가 기존 정의와 일치하는가?
- 첫 10일 후보로 나올 때 배우지 않은 규칙을 요구하지 않는가?
- 비용, 범위, 지속, 반복 제한 중 강한 축에 대응하는 대가가 보이는가?
- 보스에게 약하게 적용되는 효과가 면역처럼 보이지 않고 약화 변환으로 읽히는가?
- 원격/전장 전체 편의 카드의 낮은 수치와 반복 효율 감소가 설명되는가?

적 검수:

- 어떤 방어선 약점을 찌르는가?
- 대응 수단이 존재하는가?
- 예고 UI에 표시할 정보가 있는가?
- 첫 10일에 등장한다면 그날의 학습 단계와 충돌하지 않는가?

아티팩트 검수:

- 운영 방향을 바꾸는가?
- 장점만 있는가?
- 특정 조합에서 무한 콤보를 만들지 않는가?
- 후보 풀 안에서 다른 아티팩트와 운영 축이 충분히 다른가?
- 91일 이후 후보 풀에 새 빌드 시작형이 들어가지 않는가?
- 슬롯이 가득 찼을 때 현재 유지 선택이 가능한가?
- 교체된 아티팩트가 휴면 상태에서 효과, 슬롯 증가, 겹치기 한도 증가를 모두 끄는가?
- 재장착 문구가 공짜 교체나 자동 추천처럼 읽히지 않는가?
- 부작용 태그가 후보 화면, 장착 슬롯, HUD에서 같은 이름으로 표시되는가?
- 부작용이 보상, 희귀도, 카드 후보 수, 보스 파편, 비활성 방향 스폰을 바꾸지 않는가?

이벤트 검수:

- 정답 선택이 고정되지 않는가?
- 전투 템포를 지나치게 끊지 않는가?
- 현재 런 상태에 따라 선택이 달라지는가?
- 선택지의 비용과 다음 영향이 숨겨지지 않는가?
- 시간 초과 기본값이 위험 선택이 아닌가?
- 비활성 방향, 웨이브 겹치기 보상, 카드 희귀도를 건드리지 않는가?
- 저주 계약은 받을 카드, 즉시 이득, 장기 대가, 제거/안정화 가능 시점을 모두 보여주는가?
- 저주 수령 문구가 희생 강요, 필수 선택, 공짜 보상처럼 읽히지 않는가?

보상/정비 UI 검수:

- 카드 선택과 골드 거절이 모두 정상 선택처럼 읽히는가?
- 골드 거절을 손해, 포기, 실패처럼 쓰지 않는가?
- 압축 정산이 추가 보상이나 누적 보너스로 읽히지 않는가?
- 제거 후보 배지가 정답 추천처럼 보이지 않는가?
- 상점 첫 유료 투표 전까지 임시 선택을 되돌릴 수 있다는 문구가 짧게 보이는가?
- 저주 확인은 자동 수령이나 파티 강요처럼 읽히지 않는가?

보상/정비 UI에서 쓰지 않는 표현:

- 지금 안 고르면 손해
- 파티를 위해 선택
- 최고 효율
- 추가 보상
- 겹치기 덕분
- 삭제 추천
- 무조건 제거

저주 계약에서 쓰지 않는 표현:

- 희생 필요
- 반드시 필요
- 공짜 보상
- 저주를 떠안기
- 보상 증가

## 금지 효과 사전

아래 효과는 콘텐츠 파이프라인에서 거부합니다.

| 효과 | 이유 |
| --- | --- |
| 웨이브 겹치기 골드 배율 증가 | 템포 시스템을 보상 시스템으로 바꿈 |
| 웨이브 겹치기 희귀도 증가 | 누르지 않으면 손해인 구조가 됨 |
| 시간 경과 마나 회복 | 배속 시스템과 충돌 |
| 마지막 타격 보너스 | 협동 방어선보다 개인 딜 경쟁 유도 |
| 완전 길막 허용 | 미로 설계가 정답 배치로 굳음 |

## 버전 관리

콘텐츠 변경은 패치 노트에 남깁니다.

기록할 것:

- 변경된 카드/적/아티팩트 ID
- 변경 전 수치
- 변경 후 수치
- 변경 이유
- 관련 플레이테스트 세션

예시:

```text
card_tinkerer_remote_repair
- cost: 1 -> 2
- reason: 땜장이가 있으면 구조물 파괴가 거의 발생하지 않음
- test: 4P_MVP_Day30_Run_003
```

## 제작 완료 기준

콘텐츠 하나가 완료되려면 아래를 만족해야 합니다.

- 데이터 ID가 있습니다.
- 한국어 이름과 설명이 있습니다.
- 효과가 데이터로 구현 가능합니다.
- 금지 효과를 사용하지 않습니다.
- 대응하거나 활용할 수 있는 상황이 있습니다.
- 플레이테스트에서 관찰할 지표가 있습니다.
