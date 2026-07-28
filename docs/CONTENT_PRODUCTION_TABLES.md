# Content Production Tables

이 문서는 실제 콘텐츠 제작을 위한 목록입니다.

각 항목은 데이터화할 때 사용할 ID, 역할, MVP 포함 여부를 함께 정리합니다.

## 콘텐츠 수량 목표

| 분류 | MVP | 100일 풀런 | 출시 후보 |
| --- | ---: | ---: | ---: |
| 직업 | 4 | 4 | 4~6 |
| 직업별 카드 | 14종 | 24종 | 30종 이상 |
| 공용 카드 | 8종 | 16종 | 24종 이상 |
| 전리품 변형 카드 | 12종 | 40종 이상 | 80종 이상 |
| 카드 강화 옵션 | 28종 | 80종 이상 | 120종 이상 |
| 적 | 8종 | 16종 | 24종 이상 |
| 보스 | 1~2종 | 4종 | 6종 이상 |
| 아티팩트 | 10종 | 25종 | 40종 이상 |
| 이벤트 | 5종 | 15종 | 30종 이상 |
| 맵 | 1종 | 4계절 변형 | 6종 이상 |
| 런 모드 데이터 | 1종 | 3종 | 5종 이상 |
| 활성 방향 프리셋 | 4종 | 4종 | 4종 |
| 인원수 스케일링 프로필 | 4종 | 4종 | 운영 튜닝용 12종 이상 |
| 웨이브 원본 데이터 | 90일분 | 100일분 | 120일분 이상 |
| WaveSpawnPlan 규칙 | 1세트 | 1세트 | 2세트 이상 |
| 보스 보상 데이터 | 1종 | 10종 | 12종 이상 |
| 보스 시간 예산 프로필 | 3종 | 10종 | 12종 이상 |
| 상점 세션 데이터 | 2종 | 20종 이상 | 30종 이상 |
| 텔레메트리 이벤트 | 8종 이상 | 14종 이상 | 20종 이상 |
| 플레이테스트 대시보드 패널 | 8종 | 12종 이상 | 16종 이상 |
| 플레이테스트 대시보드 화면 요소 | 4종 | 6종 이상 | 8종 이상 |
| MVP UI 문구 키 | 14종 이상 | 60종 이상 | 100종 이상 |

## 런 기반 데이터 제작표

카드, 적, 보스보다 먼저 고정해야 하는 기반 데이터입니다.

이 표가 있어야 모든 전투 콘텐츠가 인원수별 침공 방향과 같은 기준으로 작동합니다.

### 런 모드

| ID | 이름 | MVP | 역할 |
| --- | --- | --- | --- |
| `run_test_010` | 10일 테스트 런 | 예 | 핵심 전투, 첫 보스, 웨이브 겹치기 검증 |
| `run_mvp_030` | 30일 MVP 런 | 예 | 봄 시즌 완주와 초반 성장 검증 |
| `run_standard_100` | 100일 표준 런 | 아니오 | 정식 목표 구조 |

### 런 시간 예산

| ID | 연결 런 | MVP | 목표 시간 | 역할 |
| --- | --- | --- | ---: | --- |
| `runtime_budget_mvp_030` | `run_mvp_030` | 예 | 30~45분 | 1~30일 MVP의 전투, 보스, 보상, 상점, 결과 요약 시간을 계측 |

`runtime_budget_mvp_030`은 밸런스 보정 데이터가 아니라 플레이테스트 계측 기준입니다.

시간 초과를 이유로 웨이브 겹치기 보상, 카드 후보 수, 희귀도, 골드 총량, 비활성 방향을 바꾸지 않습니다.

### 플레이테스트 대시보드 패널

| ID | MVP | 역할 |
| --- | --- | --- |
| `dashboard_run_summary` | 예 | 인원수, 활성 방향, 승패, 종료 일자, 총 시간을 비교 |
| `dashboard_pacing` | 예 | 전투, 보상, 상점, 이벤트, 웨이브 대기 시간을 분리 |
| `dashboard_wave_stack_tempo` | 예 | 웨이브 겹치기가 보상 기대가 아니라 대기 감소용으로 쓰였는지 확인 |
| `dashboard_defense_line` | 예 | 기지 피해 방향, 구조물 생존, 재건 위치, 경로 연장 시간을 확인 |
| `dashboard_cards_resources` | 예 | 손패 막힘, 버리기 사용, 처치 기반 마나/드로우 흐름을 확인 |
| `dashboard_reward_shop_event` | 예 | 골드 선택, 상점 지나가기, 이벤트 안전 선택, 저주 거절 이해도를 확인 |
| `dashboard_learning_recall` | 예 | 일자별 학습 문장과 패배 원인 회수가 되었는지 확인 |
| `dashboard_copy_guardrail` | 예 | 현지화 키 누락, 금지 문구 태그, 보상/상점/저주 오해를 확인 |

대시보드 패널은 내부 QA와 기획 검토용입니다.

개인 딜량 순위, 개인 처치 순위, 개인 실수 목록, 웨이브 겹치기 보상 효율 패널은 만들지 않습니다.

### 플레이테스트 대시보드 화면 요소

| ID | MVP | 역할 |
| --- | --- | --- |
| `dashboard_top_run_strip` | 예 | 빌드, 런 모드, 인원수, 활성 방향, 도달 일자, 총 시간, 기지 피해를 한 줄로 표시 |
| `dashboard_panel_card_grid` | 예 | 8개 패널의 정상/주의/위험 상태와 핵심 수치 1~3개를 표시 |
| `dashboard_red_flag_drilldown` | 예 | 위험 신호 조건, 원본 이벤트, 관찰자 메모, 가능한 의미를 연결 |
| `dashboard_next_build_action_queue` | 예 | 위험 신호를 다음 테스트 가설과 검토 작업으로 저장 |

대시보드 화면 요소는 전투 데이터나 보상 데이터를 직접 수정하지 않습니다.

액션 큐는 자동 패치가 아니라 다음 테스트에서 확인할 가설 목록입니다.

### MVP UI 문구 키

| ID | 키 | 화면 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `copy_reward_pick_card` | `ui.reward.pick_card` | 보상 | 예 | 카드 추가를 정상 선택으로 표시 |
| `copy_reward_take_gold` | `ui.reward.take_gold` | 보상 | 예 | 골드 선택을 손해처럼 보이지 않게 표시 |
| `copy_reward_temporary_lock` | `ui.reward.temporary_lock` | 보상 | 예 | 미선택 보상 임시 처리 안내 |
| `copy_reward_revert_until_shop` | `ui.reward.revert_until_shop` | 보상 | 예 | 첫 유료 상점 투표 전 되돌리기 안내 |
| `copy_reward_variant_badge` | `ui.reward.variant_badge` | 보상 | 예 | 변형 후보를 강화가 아닌 변형 카드로 표시 |
| `copy_reward_variant_new_badge` | `ui.reward.variant_new_badge` | 보상 | 예 | 변형 후보가 새 카드로 들어감을 표시 |
| `copy_reward_variant_base` | `ui.reward.variant_base` | 보상 | 예 | 기준 카드를 강화 대상이 아닌 출처로 표시 |
| `copy_reward_variant_changed_axis` | `ui.reward.variant_changed_axis` | 보상 | 예 | 변형 카드에서 달라진 점 표시 |
| `copy_reward_variant_kept_weakness` | `ui.reward.variant_kept_weakness` | 보상 | 예 | 변형 카드에 남는 약점 표시 |
| `copy_reward_variant_reason` | `ui.reward.variant_reason` | 보상 | 예 | 변형 후보의 등장 이유 표시 |
| `copy_reward_variant_compare` | `ui.reward.variant_compare` | 보상 | 예 | 강화 비교가 아닌 차이 보기 버튼 |
| `copy_reward_variant_new_card_hint` | `ui.reward.variant_new_card_hint` | 보상 | 예 | 기존 카드를 바꾸지 않음을 안내 |
| `copy_reward_variant_temp_lock_blocked` | `ui.reward.variant_temp_lock_blocked` | 보상 | 예 | 위험 대가 변형의 자동 임시 선택 제한 안내 |
| `copy_reward_heroic_ready_badge` | `ui.reward.heroic_ready_badge` | 보상 | 예 | 영웅 후보를 상위 보상이 아닌 준비된 운영으로 표시 |
| `copy_reward_heroic_support_row` | `ui.reward.heroic_support_row` | 보상 | 예 | 실제 지원 카드와 동등 지원 크레딧을 분리 표시 |
| `copy_reward_heroic_recent_proof` | `ui.reward.heroic_recent_proof` | 보상 | 예 | 최근 전투 증거를 처치 수 보상처럼 보이지 않게 표시 |
| `copy_reward_heroic_tradeoff` | `ui.reward.heroic_tradeoff` | 보상 | 예 | 영웅 카드의 남는 대가를 짧게 표시 |
| `copy_reward_heroic_downgrade_reason` | `ui.reward.heroic_downgrade_reason` | 보상 | 예 | 하향 후보 사유를 벌점처럼 보이지 않게 표시 |
| `copy_shop_heroic_tune_title` | `ui.shop.heroic_tune_title` | 상점 | 예 | 영웅 확정 조율이 랜덤 판매가 아님을 고정 |
| `copy_shop_heroic_owner_accept` | `ui.shop.heroic_owner_accept` | 상점 | 예 | 대상 플레이어가 먼저 받을지 확인 |
| `copy_shop_heroic_owner_hold` | `ui.shop.heroic_owner_hold` | 상점 | 예 | 대상 보류를 정상 선택으로 표시 |
| `copy_shop_heroic_vote_title` | `ui.shop.heroic_vote_title` | 상점 | 예 | 대상 수락 후 파티 자원 투표 표시 |
| `copy_shop_heroic_locked_state` | `ui.shop.heroic_locked_*` | 상점 | 예 | 파편 부족, 게이트 부족, 구매 완료 상태를 구매 압박 없이 표시 |
| `copy_settlement_row_day` | `ui.settlement.row_day` | 압축 정산 | 예 | 정산 행을 일자 기준으로 표시 |
| `copy_settlement_no_bonus` | `ui.settlement.no_bonus` | 압축 정산 | 예 | 추가 보상이 아님을 표시 |
| `copy_shop_skip` | `ui.shop.skip` | 상점 | 예 | 구매하지 않음을 정상 선택으로 표시 |
| `copy_shop_vote_start` | `ui.shop.vote_start` | 상점 | 예 | 파티 자원 사용 투표 안내 |
| `copy_shop_timeout_decline` | `ui.shop.timeout_decline` | 상점 | 예 | 시간 초과 시 자동 구매 없음 표시 |
| `copy_event_keep_state` | `ui.event.choice_keep_state` | 이벤트 | 예 | 안전 선택과 지나가기를 표시 |
| `copy_event_timeout_safe` | `ui.event.timeout_safe` | 이벤트 | 예 | 시간 초과 안전 선택 안내 |
| `copy_curse_confirm_title` | `ui.curse.confirm_title` | 저주 | 예 | 대상 플레이어의 수령 확인 |
| `copy_curse_service_hint` | `ui.curse.service_hint` | 저주 | 예 | 제거/안정화 가능 시점 표시 |
| `copy_curse_decline` | `ui.curse.decline` | 저주 | 예 | 거절을 정상 선택으로 표시 |
| `copy_card_fail_not_enough_mana` | `ui.card.fail.not_enough_mana` | 카드 | 예 | 마나 부족 사용 불가 |
| `copy_card_fail_no_target` | `ui.card.fail.no_target` | 카드 | 예 | 대상 없음 사용 불가 |
| `copy_card_fail_out_of_range` | `ui.card.fail.out_of_range` | 카드 | 예 | 사거리 밖 사용 불가 |
| `copy_card_fail_path_blocked` | `ui.card.fail.path_blocked` | 카드 | 예 | 완전 길막/경로 차단 사용 불가 |
| `copy_card_fail_need_collapse_record` | `ui.card.fail.need_collapse_record` | 카드 | 예 | 파괴 기록 필요 안내 |
| `copy_card_fail_scattered_targets` | `ui.card.fail.scattered_targets` | 카드 | 예 | 광역 카드 조건 낮음 |
| `copy_card_fail_no_followup_focus` | `ui.card.fail.no_followup_focus` | 카드 | 예 | 표식/집중 후속 화력 없음 |
| `copy_card_fail_control_resisted` | `ui.card.fail.control_resisted` | 카드 | 예 | 반복 제어 저항 표시 |
| `copy_card_fail_discard_no_reward` | `ui.card.fail.discard_no_reward` | 카드 | 예 | 버리기 보상 미발동 안내 |
| `copy_card_fail_temporary_no_salvage` | `ui.card.fail.temporary_no_salvage` | 카드 | 예 | 임시 구조물 회수 제외 |
| `copy_card_fail_aura_stack_capped` | `ui.card.fail.aura_stack_capped` | 카드 | 예 | 오라 중첩 상한 안내 |
| `copy_card_fail_repair_repeated` | `ui.card.fail.repair_repeated` | 카드 | 예 | 반복 수리 효율 감소 |
| `copy_card_fail_overdrive_debt` | `ui.card.fail.overdrive_debt` | 카드 | 예 | 과부하 후유 피해 안내 |
| `copy_card_fail_boss_weakened` | `ui.card.fail.boss_weakened` | 카드 | 예 | 보스 약화 변환 안내 |
| `copy_card_fail_prebuild_only` | `ui.card.fail.prebuild_only` | 카드 | 예 | 전투 전 전용 카드 안내 |

위 키들은 한국어와 영어 현지화 파일에 모두 있어야 하며, 임시 문자열로 대체하지 않습니다.

### 활성 방향 프리셋

| ID | 플레이어 수 | 활성 방향 | 기본 강조 | MVP | 역할 |
| --- | ---: | --- | --- | --- | --- |
| `active_directions_players_1` | 1 | `east` | `east` | 예 | 솔로 조작 부담을 줄이는 단일 라인 |
| `active_directions_players_2` | 2 | `north`, `east` | `east` | 예 | 짧은 라인과 느린 라인의 기본 분담 |
| `active_directions_players_3` | 3 | `west`, `north`, `east` | `west` | 예 | 빠른 돌파 라인과 순회 지원 추가 |
| `active_directions_players_4` | 4 | `west`, `north`, `east`, `south` | `west` | 예 | 사방이 열린 협동 방어 |

활성 방향은 런 시작 시 `RunState`에 저장하고, 런 도중 접속 인원이 바뀌어도 다시 계산하지 않습니다.

활성 방향은 런 전체에서 사용할 수 있는 입구 목록입니다.

4인 런은 네 방향이 모두 활성화되지만, 개별 웨이브가 항상 사방 동시 스폰을 사용한다는 뜻은 아닙니다. 동시 압박 수는 각 웨이브와 보스 제작표의 제한을 따릅니다.

웨이브 겹치기는 비활성 방향을 새로 열지 않습니다.

### 인원수 스케일링 프로필

| ID | 플레이어 수 | 위협 예산 | 적 수량 | 보스 HP | 정예 빈도 | 구조물 피해 | MVP |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| `scaling_players_1` | 1 | x0.65 | x0.60 | x0.65 | x0.50 | x0.75 | 예 |
| `scaling_players_2` | 2 | x1.00 | x1.00 | x1.00 | x1.00 | x1.00 | 예 |
| `scaling_players_3` | 3 | x1.15 | x1.10 | x1.15 | x1.15 | x1.10 | 예 |
| `scaling_players_4` | 4 | x1.30 | x1.20 | x1.25 | x1.25 | x1.15 | 예 |

스케일링 프로필은 적 수와 체력 압박을 조정하지만, 웨이브 보상, 카드 희귀도, 시간 경과 마나 회복은 건드리지 않습니다.

### 방향 역할 제작표

| ID | 역할 | 우선 방향 | MVP | 설명 |
| --- | --- | --- | --- | --- |
| `direction_role_short` | 짧은 압박 | `east` | 예 | 빠르게 기지에 닿는 기본 압박 |
| `direction_role_slow` | 느린 압박 | `north` | 예 | 준비 시간은 길지만 누적 압박이 큰 라인 |
| `direction_role_fast` | 돌파 압박 | `west` | 예 | 빠른 적과 긴급 대응 검증 |
| `direction_role_killzone` | 킬존 압박 | `south` | 예 | 굴곡과 광역 처치 검증 |
| `direction_role_any` | 균등 분산 | 활성 방향 중 선택 | 예 | 최근 사용 빈도가 낮은 활성 방향 보정 |

원본 웨이브의 선호 방향이 비활성 상태라면 방향 역할에 맞춰 활성 방향 안에서 대체합니다.

비활성 방향을 억지로 여는 방식은 사용하지 않습니다.

## 새 런 준비 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `new_run_setup_flow` | 흐름 | 예 | 다음 런 제안, 인원/방향, 런 길이, 직업, 준비 합의, RunState 확정 |
| `setup_item_suggestion_review` | 준비 항목 | 아니오 | 결과/메타/도감에서 온 다음 런 제안 최대 2개 표시 |
| `setup_item_player_direction_preview` | 준비 항목 | 예 | 로비 인원수에 따른 활성 침공 방향 미리보기 |
| `setup_item_run_mode_select` | 준비 항목 | 예 | 10일 테스트, 30일 MVP, 100일 표준 런 선택 |
| `setup_item_class_select` | 준비 항목 | 예 | 직업 역할, 시작 덱, 파티 역할 빈틈 표시 |
| `setup_item_party_intent_confirm` | 준비 항목 | 아니오 | 이번 런에서 시험할 운영 한 줄 확인 |
| `setup_item_run_state_lock` | 준비 항목 | 예 | `playerCountAtStart`, `activeDirections`, `scalingProfileId`, `seed` 확정 |
| `setup_suggestion_slot` | 데이터 | 아니오 | 다음 런 제안 최대 2개를 참고 메모 슬롯으로 표시 |
| `lobby_direction_preset` | 데이터 | 예 | 1~4인 인원수별 활성/비활성 방향 프리셋 |
| `party_intent_note` | 데이터 | 아니오 | 제안에서 가져오거나 직접 쓴 이번 런 운영 한 줄 |
| `run_config_lock_snapshot` | 데이터 | 예 | 시작 시 확정값을 `RunState`로 넘기는 잠금 스냅샷 |
| `ui_lobby_direction_preview` | 로비 UI | 예 | 활성/비활성 방향을 맵 미리보기에서 구분 |
| `ui_lobby_suggestion_strip` | 로비 UI | 아니오 | 참고 메모 최대 2개를 접을 수 있는 상단 줄로 표시 |
| `ui_party_role_gap_hint` | 로비 UI | 아니오 | 부족한 역할 태그를 정답 강요 없이 표시 |
| `ui_run_intent_note` | 로비 UI | 아니오 | 파티가 이번 런의 실험 목표를 한 줄로 남김 |

새 런 준비 제작 기준:

| 제작물 | 제작 기준 | 금지선 |
| --- | --- | --- |
| 참고 메모 | 최대 2개, 접기 가능, 도감/훈련장 링크 가능 | 직업/카드/방향 자동 적용 |
| 방향 미리보기 | 1인 동쪽, 2인 북/동, 3인 서/북/동, 4인 사방 | 비활성 방향을 위험 방향으로 표시 |
| 런 길이 카드 | 예상 시간과 완료 기준만 표시 | 빠른 클리어 보상, 겹치기 보상 모드 |
| 직업 슬롯 | 역할, 시작 덱, 준비 상태 표시 | 필수 직업, 정답 조합, 자동 선택 |
| 역할 힌트 | 대응 태그 기준으로 약한 축을 짧게 표시 | 특정 직업/카드 강제 |
| 파티 의도 | 한 줄 메모, 비워도 시작 가능 | 보상/난이도/방향 변경 |
| 시작 잠금 | 확정 전 최종 확인, 확정 후 값 고정 | 시작 후 인원 변화로 재계산 |

## 중단/재개 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `session_resume_flow` | 흐름 | 예 | 저장점, 끊김 감지, 직업 보류, 복귀 스냅샷, 장기 이탈, 재개 확정 |
| `resume_rule_savepoint_create` | 재개 항목 | 예 | 안정 저장점 생성과 저장 완료 배지 |
| `resume_rule_interrupt_detect` | 재개 항목 | 예 | 연결 끊김, 입력 없음, 호스트 응답 지연 구분 |
| `resume_rule_role_reserve` | 재개 항목 | 예 | 이탈 플레이어 직업 보류와 개인 카드/마나 잠금 |
| `resume_rule_snapshot_deliver` | 재개 항목 | 예 | 현재 일자, 웨이브, 투표, 손패, 구조물 소유권 전달 |
| `resume_rule_long_absence_hold` | 재개 항목 | 예 | 2분 초과 장기 이탈을 다음 안정 저장점까지 보류 |
| `resume_rule_resume_confirm` | 재개 항목 | 예 | 같은 플레이어가 같은 직업을 이어받음 |
| `ui_savepoint_badge` | 세션 UI | 예 | 저장 완료와 마지막 저장점을 작게 표시 |
| `ui_player_connection_badge` | 세션 UI | 예 | 플레이어별 연결/보류 상태 표시 |
| `ui_resume_snapshot_panel` | 세션 UI | 예 | 복귀 시 현재 상태 요약과 남은 투표 시간 표시 |
| `session_state_store` | 데이터 | 예 | `RunState`와 분리된 접속 상태 저장 |

## 직업 목록

| ID | 이름 | 역할 | MVP |
| --- | --- | --- | --- |
| `class_guardian` | 수호자 | 도발, 방어, 가시 | 예 |
| `class_architect` | 건축가 | 미로, 바리케이드, 폭발 | 예 |
| `class_elementalist` | 원소술사 | 광역 피해, 둔화, 넉백 | 예 |
| `class_tinkerer` | 땜장이 | 오라, 수리, 과부하 | 예 |

### 직업 성장과 시너지 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `class_growth_guardian_001_100` | 직업 성장 루트 | 아니오 | 도발, 가시, 파괴 지연, 최종 전면 방어 성장 |
| `class_growth_architect_001_100` | 직업 성장 루트 | 아니오 | 바리케이드, 잔해, 계획 붕괴, 후방 킬존 재건 성장 |
| `class_growth_elementalist_001_100` | 직업 성장 루트 | 아니오 | 광역, 둔화, 넉백, 보스 부위 집중 성장 |
| `class_growth_tinkerer_001_100` | 직업 성장 루트 | 아니오 | 수리, 오라, 과부하, 최종 유지보수 성장 |
| `synergy_trigger_taunt_cluster` | 시너지 트리거 | 예 | 도발 군집 후 광역 정리 |
| `synergy_trigger_planned_collapse` | 시너지 트리거 | 예 | 바리케이드 파괴와 광역/둔화 타이밍 |
| `synergy_trigger_delayed_repair` | 시너지 트리거 | 예 | 도발 구조물을 몇 초 더 버티게 하는 수리 |
| `synergy_trigger_risky_aura` | 시너지 트리거 | 아니오 | 파괴 위험이 있는 밀집 오라 화력 |
| `synergy_trigger_rear_killzone_shift` | 시너지 트리거 | 아니오 | 압력 타일을 피해 후방 킬존 이전 |
| `synergy_trigger_boss_part_focus` | 시너지 트리거 | 예 | 보스 부위 집중 공격을 위한 파티 협동 |
| `party_profile_2p_guardian_elementalist` | 2인 조합 프로필 | 예 | 도발 군집과 광역 정리 |
| `party_profile_2p_architect_tinkerer` | 2인 조합 프로필 | 예 | 오래 가는 미로와 유지보수 |
| `party_profile_2p_guardian_architect` | 2인 조합 프로필 | 예 | 전면 방어와 경로 지연 |
| `party_profile_2p_elementalist_tinkerer` | 2인 조합 프로필 | 예 | 화력 증폭과 긴급 수리 |
| `party_profile_2p_architect_elementalist` | 2인 조합 프로필 | 아니오 | 계획 붕괴와 킬존 광역 |
| `party_profile_2p_guardian_tinkerer` | 2인 조합 프로필 | 아니오 | 오래 버티는 전면 방어 |

## 카드 제작표

### 수호자

| ID | 이름 | 희귀도 | 비용 | MVP | 역할 |
| --- | --- | --- | ---: | --- | --- |
| `card_guardian_taunt_wall` | 도발벽 | 일반 | 1 | 예 | 도발 구조물 |
| `card_guardian_shield_wrap` | 방패 두르기 | 일반 | 1 | 예 | 구조물 방어 |
| `card_guardian_thorn_growth` | 가시 성장 | 일반 | 1 | 예 | 반사 피해 |
| `card_guardian_binding_oath` | 붙잡는 맹세 | 일반 | 2 | 예 | 도발 대상 둔화 |
| `card_guardian_last_gate` | 최후의 문 | 희귀 | 3 | 예 | 파괴 방지 |
| `card_guardian_counter_stance` | 응전 태세 | 일반 | 0 | 예 | 저비용 연결 |
| `card_guardian_iron_wall` | 철벽 전개 | 일반 | 2 | 예 | 장기 방어 |
| `card_guardian_reflective_oath` | 반사의 맹세 | 일반 | 1 | 예 | 가시 강화 |
| `card_guardian_front_swap` | 전열 교대 | 희귀 | 1 | 예 | 도발 위치 조정 |
| `card_guardian_crack_shield` | 균열 방패 | 희귀 | 2 | 예 | 피해 시 둔화 |
| `card_guardian_last_guard` | 마지막 수호 | 희귀 | 2 | 예 | 기지 저체력 방어 |
| `card_guardian_thorn_throne` | 가시 왕좌 | 영웅 | 3 | 예 | 전체 가시 빌드 |
| `card_guardian_unbroken_gate` | 불굴의 성문 | 영웅 | 4 | 예 | 보스 저지 |
| `card_guardian_heavy_vow` | 무거운 서약 | 저주 | 0 | 예 | 위험한 마나 |

### 건축가

| ID | 이름 | 희귀도 | 비용 | MVP | 역할 |
| --- | --- | --- | ---: | --- | --- |
| `card_architect_barricade` | 바리케이드 | 일반 | 1 | 예 | 기본 미로 |
| `card_architect_slowing_stake` | 둔화 말뚝 | 일반 | 1 | 예 | 함정 |
| `card_architect_debris_blast` | 잔해 폭발 | 일반 | 1 | 예 | 파괴 피해 |
| `card_architect_temporary_path` | 급조 통로 | 일반 | 0 | 예 | 임시 경로 변경 |
| `card_architect_salvage_work` | 회수 작업 | 일반 | 1 | 예 | 파괴 회수 |
| `card_architect_compact_design` | 압축 설계 | 희귀 | 2 | 예 | 설치 강화 |
| `card_architect_double_barricade` | 이중 바리케이드 | 일반 | 2 | 예 | 경로 설계 |
| `card_architect_shard_recovery` | 파편 회수 | 일반 | 1 | 예 | 골드 회수 |
| `card_architect_delayed_charge` | 지연 폭약 | 희귀 | 1 | 예 | 능동 폭파 |
| `card_architect_slippery_debris` | 미끄러운 잔해 | 희귀 | 1 | 예 | 잔해 둔화 |
| `card_architect_reinforced_blueprint` | 보강 설계도 | 희귀 | 2 | 예 | 구조물 체력 |
| `card_architect_chain_collapse` | 연쇄 붕괴 | 영웅 | 3 | 예 | 폭발 연쇄 |
| `card_architect_inverted_path` | 뒤집힌 통로 | 영웅 | 3 | 예 | 경로 교란 |
| `card_architect_overbuilt` | 무리한 증축 | 저주 | 0 | 예 | 빠른 재건 |

### 원소술사

| ID | 이름 | 희귀도 | 비용 | MVP | 역할 |
| --- | --- | --- | ---: | --- | --- |
| `card_elementalist_fireball` | 화염구 | 일반 | 1 | 예 | 기본 광역 |
| `card_elementalist_frost_zone` | 빙결 지대 | 일반 | 1 | 예 | 둔화/정지 |
| `card_elementalist_pushback` | 밀어내기 | 일반 | 1 | 예 | 넉백 |
| `card_elementalist_chain_lightning` | 번개 연결 | 희귀 | 2 | 예 | 연쇄 피해 |
| `card_elementalist_mark` | 원소 표식 | 일반 | 0 | 예 | 취약 |
| `card_elementalist_big_blast` | 대폭발 | 희귀 | 3 | 예 | 위기 정리 |
| `card_elementalist_fire_ring` | 화염 고리 | 일반 | 2 | 예 | 지속 피해 |
| `card_elementalist_frost_shard` | 서리 파편 | 일반 | 1 | 예 | 빙결 연계 |
| `card_elementalist_rewind_gust` | 되감는 돌풍 | 희귀 | 2 | 예 | 큰 넉백 |
| `card_elementalist_overcharged_bolt` | 과충전 번개 | 희귀 | 2 | 예 | 연쇄 처치 |
| `card_elementalist_elemental_rift` | 원소 균열 | 희귀 | 1 | 예 | 광역 취약 |
| `card_elementalist_eye_of_stillness` | 정지의 눈 | 영웅 | 3 | 예 | 대형 제어 |
| `card_elementalist_storm_ritual` | 낙뢰 의식 | 영웅 | 4 | 예 | 전장 피해 |
| `card_elementalist_forbidden_lantern` | 금지된 등불 | 저주 | 1 | 예 | 보스 특화 |

### 땜장이

| ID | 이름 | 희귀도 | 비용 | MVP | 역할 |
| --- | --- | --- | ---: | --- | --- |
| `card_tinkerer_amplifier` | 증폭기 | 일반 | 1 | 예 | 오라 설치 |
| `card_tinkerer_remote_repair` | 원격 수리 | 일반 | 1 | 예 | 수리 |
| `card_tinkerer_armor_plate` | 보강판 | 일반 | 1 | 예 | 방어 강화 |
| `card_tinkerer_overdrive` | 과부하 | 일반 | 0 | 예 | 순간 화력 |
| `card_tinkerer_spare_parts` | 예비 부품 | 일반 | 1 | 예 | 파괴 회수 |
| `card_tinkerer_auto_rebuild` | 자동 복구 | 희귀 | 2 | 예 | 파괴 방지 |
| `card_tinkerer_lubrication` | 윤활 작업 | 일반 | 1 | 예 | 공격 속도 |
| `card_tinkerer_reinforced_screw` | 강화 나사 | 일반 | 1 | 예 | 체력 증가 |
| `card_tinkerer_emergency_wiring` | 긴급 배선 | 희귀 | 0 | 예 | 오라 위험 강화 |
| `card_tinkerer_preheater` | 예열 장치 | 희귀 | 2 | 예 | 웨이브 초반 화력 |
| `card_tinkerer_auto_extinguisher` | 자동 소화 | 희귀 | 1 | 예 | 과부하 안정 |
| `card_tinkerer_resonance_amp` | 공명 증폭기 | 영웅 | 3 | 예 | 오라 공유 |
| `card_tinkerer_reassembly_machine` | 재조립 기계 | 영웅 | 4 | 예 | 구조물 복구 |
| `card_tinkerer_risky_mod` | 위험한 개조 | 저주 | 0 | 예 | 위험 화력 |

### 공용

| ID | 이름 | 희귀도 | 비용 | MVP | 역할 |
| --- | --- | --- | ---: | --- | --- |
| `card_common_reorganize` | 재정비 | 일반 | 0 | 예 | 손패 정리 |
| `card_common_focus_fire` | 집중 사격 | 일반 | 1 | 예 | 우선 처치 |
| `card_common_emergency_repair` | 긴급 보수 | 일반 | 1 | 예 | 최소 수리 |
| `card_common_battlefield_cleanup` | 전장 수습 | 일반 | 1 | 예 | 붕괴 후 둔화 |
| `card_common_mana_convert` | 마나 전환 | 일반 | 0 | 예 | 버리기 연계 |
| `card_common_quick_hands` | 빠른 손놀림 | 일반 | 0 | 예 | 드로우/버리기 |
| `card_common_tactical_map` | 전술 지도 | 일반 | 1 | 예 | 예고 강화 |
| `card_common_temporary_turret` | 임시 포탑 | 일반 | 1 | 예 | 빈틈 보완 |
| `card_common_pressure_signal` | 압박 신호 | 희귀 | 1 | 아니오 | 집중 공격 |
| `card_common_reposition_line` | 방어선 재배치 | 희귀 | 2 | 아니오 | 구조물 이동 |
| `card_common_emergency_battery` | 비상 축전 | 희귀 | 0 | 아니오 | 손패 부족 보정 |
| `card_common_joint_operation` | 공동 작전 | 영웅 | 2 | 아니오 | 파티 드로우 |
| `card_common_silent_call` | 무음 호출 | 저주 | 0 | 아니오 | 위험한 템포 |

## 71~100일 후반 직업 전리품 카드 제작표

후반 신규 카드는 71일 이후 기존 아키타입을 보완하는 카드입니다.

새 아키타입을 여는 `signal` 카드가 아니라, `patch` 또는 기존 축의 `payoff`로만 등록합니다.

| ID | 이름 | 직업 | 희귀도 | 비용 | 등장 | 풀 라인 | 아키타입 역할 | 제작 메모 |
| --- | --- | --- | --- | ---: | --- | --- | --- | --- |
| `card_guardian_retreat_order` | 후퇴 명령 | 수호자 | 일반 | 1 | 71~99일 | `guardian_taunt_anchor` | `patch` | 도발 구조물 후방 이동, 완전 길막 금지 |
| `card_guardian_crack_brace` | 균열 받침 | 수호자 | 일반 | 1 | 71~99일 | `guardian_line_delay` | `patch` | 파괴 직전 2초 지연, 수리 불가 |
| `card_guardian_pressure_sigil` | 압력 밖 성표 | 수호자 | 희귀 | 2 | 81~99일 | `guardian_boss_hold` | `patch` | 압력 밖 도발 구조물 강화, 압력 안 효과 약화 |
| `card_guardian_thorn_graft` | 가시 이식 | 수호자 | 희귀 | 1 | 81~99일 | `guardian_thorns_value` | `patch` | 가시 일부 이전, 수리 효율 감소 |
| `card_guardian_gate_alarm` | 수문 경보 | 수호자 | 희귀 | 0 | 91~99일 | `guardian_line_delay` | `patch` | 기지 피해/내측 도달 조건, 웨이브당 1회 |
| `card_guardian_winter_gate` | 겨울 관문 | 수호자 | 영웅 | 3 | 91~99일 | `guardian_boss_hold` | `payoff` | 도발 구조물 2개 연결, 선행 아키타입 필요 |
| `card_architect_rear_foundation` | 후방 기초 | 건축가 | 일반 | 1 | 71~99일 | `architect_rear_rebuild` | `patch` | 후방 바리케이드 체력 증가, 파괴 보너스 감소 |
| `card_architect_pressure_survey` | 압력 측량 | 건축가 | 일반 | 0 | 81~99일 | `architect_rear_rebuild` | `patch` | 안전 설치 타일 표시, 보상/비용 증가 없음 |
| `card_architect_folding_maze` | 접히는 미로 | 건축가 | 희귀 | 2 | 71~99일 | `architect_path_extension` | `patch` | 바리케이드 2개 후방 이전, 경로 검사 필수 |
| `card_architect_debris_stake` | 잔해 말뚝 | 건축가 | 희귀 | 1 | 81~99일 | `architect_debris_control` | `patch` | 잔해 소모 둔화 말뚝, 회수/폭발 재사용 금지 |
| `card_architect_last_detour` | 마지막 우회로 | 건축가 | 희귀 | 2 | 91~99일 | `architect_rear_rebuild` | `patch` | 전방 구조물 파괴 시 취약 후방 바리케이드 예약 |
| `card_architect_winter_collapse_plan` | 겨울형 붕괴도 | 건축가 | 영웅 | 3 | 91~99일 | `architect_planned_collapse` | `payoff` | 파괴 기록 소모 지연 폭발, 기록 재사용 금지 |
| `card_elementalist_narrow_fireline` | 좁은 화염선 | 원소술사 | 일반 | 1 | 71~99일 | `elementalist_area_damage` | `patch` | 좁은 선형 피해, 도발/둔화 대상 추가 피해 |
| `card_elementalist_rime_mark` | 잔서리 표식 | 원소술사 | 일반 | 1 | 71~99일 | `elementalist_element_mark` | `patch` | 결빙/압력 경계 이탈 적에게 약한 표식 |
| `card_elementalist_outer_pressure_bolt` | 압력 밖 번개 | 원소술사 | 희귀 | 2 | 81~99일 | `elementalist_priority_burst` | `patch` | 압력 밖 전이 피해, 압력 안 대상 피해 감소 |
| `card_elementalist_thaw_burst` | 해동 파열 | 원소술사 | 희귀 | 1 | 80~99일 | `elementalist_slow_knockback` | `patch` | 결빙 주변 피해와 약한 밀침, 타일 결빙 제거 없음 |
| `card_elementalist_afterglow_mark` | 잔광 표식 | 원소술사 | 희귀 | 0 | 91~99일 | `elementalist_element_mark` | `patch` | 살아남은 표식 대상 갱신, 피해 없음 |
| `card_elementalist_white_storm_ritual` | 백색 낙뢰 의식 | 원소술사 | 영웅 | 4 | 91~99일 | `elementalist_priority_burst` | `payoff` | 표식 대상 지연 낙뢰, 자동 추적 금지 |
| `card_tinkerer_folding_amp` | 접이식 증폭기 | 땜장이 | 일반 | 1 | 71~99일 | `tinkerer_aura_timing` | `patch` | 오라 장치 이동, 이동 후 2초 약화 |
| `card_tinkerer_cooling_pin` | 냉각 핀 | 땜장이 | 일반 | 1 | 71~99일 | `tinkerer_overdrive_tradeoff` | `patch` | 과부하 후유 피해 감소와 보너스 감소 동시 적용 |
| `card_tinkerer_outer_pressure_circuit` | 압력 밖 회로 | 땜장이 | 희귀 | 2 | 81~99일 | `tinkerer_aura_timing` | `patch` | 압력 밖 오라가 경계 구조물 1개 보조 |
| `card_tinkerer_disassembly_repair` | 분해 수리 | 땜장이 | 희귀 | 1 | 81~99일 | `tinkerer_repair_window` | `patch` | 구조물 해체 후 수리, 파괴/회수 효과 발동 금지 |
| `card_tinkerer_shared_battery` | 비상 배터리 공유 | 땜장이 | 희귀 | 0 | 91~99일 | `tinkerer_maintenance_economy` | `patch` | 손패 3장 이하와 피해 구조물 조건, 대상 취약 대가 |
| `card_tinkerer_last_crew` | 최후의 정비반 | 땜장이 | 영웅 | 3 | 91~99일 | `tinkerer_repair_window` | `payoff` | 오라 범위 첫 파괴 구조물 2초 지연, 완전 부활 금지 |

후반 카드 제작 공통 검수:

- `allowedDayRange`는 100일 결과를 포함하지 않습니다.
- 모든 후반 카드는 `soloProjectionSafe: true`입니다.
- 모든 후반 영웅 카드는 `requiresSupportCardCount` 2 이상 또는 동등한 기존 아키타입 조건을 가집니다.
- 모든 0비용 후반 카드는 조건부이며, 조건 없는 드로우, 마나 순증가, 피해, 대량 수리를 만들 수 없습니다.
- 이동/재배치 카드는 경로 검사와 활성 전선 투영을 통과해야 합니다.

## MVP 카드 카탈로그 잠금 제작표

이 표는 카드 ID가 어느 보상 경로에 들어갈 수 있는지 잠그는 제작 기준입니다.

효과 수치가 바뀌어도 카탈로그 역할이 바뀌면 시작 덱, 전리품 풀, 상점, 이벤트 계약을 함께 다시 검토해야 합니다.

### 직업별 카탈로그 역할

| 직업 | 시작 카드 6종 | 1~20일 보상 중심 | 21~30일 확정 후보 | 명시 선택 전용 |
| --- | --- | --- | --- | --- |
| 수호자 | 도발벽, 방패 두르기, 가시 성장, 붙잡는 맹세, 최후의 문, 응전 태세 | 철벽 전개, 반사의 맹세, 전열 교대, 균열 방패, 마지막 수호 | 가시 왕좌, 불굴의 성문 | 무거운 서약 |
| 건축가 | 바리케이드, 둔화 말뚝, 잔해 폭발, 급조 통로, 회수 작업, 압축 설계 | 이중 바리케이드, 파편 회수, 지연 폭약, 미끄러운 잔해, 보강 설계도 | 연쇄 붕괴, 뒤집힌 통로 | 무리한 증축 |
| 원소술사 | 화염구, 빙결 지대, 밀어내기, 번개 연결, 원소 표식, 대폭발 | 화염 고리, 서리 파편, 되감는 돌풍, 과충전 번개, 원소 균열 | 정지의 눈, 낙뢰 의식 | 금지된 등불 |
| 땜장이 | 증폭기, 원격 수리, 보강판, 과부하, 예비 부품, 자동 복구 | 윤활 작업, 강화 나사, 긴급 배선, 예열 장치, 자동 소화 | 공명 증폭기, 재조립 기계 | 위험한 개조 |

### 직업별 MVP 카드 ID 잠금표

| ID | 직업 | 시작 카드 ID와 매수 | 보상 카드 ID | 영웅 ID | 저주 ID | 검수 |
| --- | --- | --- | --- | --- | --- | --- |
| `mvp_class_card_catalog_guardian_030` | 수호자 | `card_guardian_taunt_wall` x2, `card_guardian_shield_wrap` x2, `card_guardian_thorn_growth` x2, `card_guardian_binding_oath` x1, `card_guardian_last_gate` x1, `card_guardian_counter_stance` x2 | `card_guardian_iron_wall`, `card_guardian_reflective_oath`, `card_guardian_front_swap`, `card_guardian_crack_shield`, `card_guardian_last_guard` | `card_guardian_thorn_throne`, `card_guardian_unbroken_gate` | `card_guardian_heavy_vow` | 4개 풀 라인 모두 포함 |
| `mvp_class_card_catalog_architect_030` | 건축가 | `card_architect_barricade` x3, `card_architect_slowing_stake` x2, `card_architect_debris_blast` x2, `card_architect_temporary_path` x1, `card_architect_salvage_work` x1, `card_architect_compact_design` x1 | `card_architect_double_barricade`, `card_architect_shard_recovery`, `card_architect_delayed_charge`, `card_architect_slippery_debris`, `card_architect_reinforced_blueprint` | `card_architect_chain_collapse`, `card_architect_inverted_path` | `card_architect_overbuilt` | 완전 길막/무한 회수 금지 |
| `mvp_class_card_catalog_elementalist_030` | 원소술사 | `card_elementalist_fireball` x2, `card_elementalist_frost_zone` x2, `card_elementalist_pushback` x2, `card_elementalist_chain_lightning` x1, `card_elementalist_mark` x2, `card_elementalist_big_blast` x1 | `card_elementalist_fire_ring`, `card_elementalist_frost_shard`, `card_elementalist_rewind_gust`, `card_elementalist_overcharged_bolt`, `card_elementalist_elemental_rift` | `card_elementalist_eye_of_stillness`, `card_elementalist_storm_ritual` | `card_elementalist_forbidden_lantern` | 보스 패턴 삭제 금지 |
| `mvp_class_card_catalog_tinkerer_030` | 땜장이 | `card_tinkerer_amplifier` x2, `card_tinkerer_remote_repair` x3, `card_tinkerer_armor_plate` x2, `card_tinkerer_overdrive` x1, `card_tinkerer_spare_parts` x1, `card_tinkerer_auto_rebuild` x1 | `card_tinkerer_lubrication`, `card_tinkerer_reinforced_screw`, `card_tinkerer_emergency_wiring`, `card_tinkerer_preheater`, `card_tinkerer_auto_extinguisher` | `card_tinkerer_resonance_amp`, `card_tinkerer_reassembly_machine` | `card_tinkerer_risky_mod` | 무한 수리/상시 오라 금지 |

### 보상 후보 레일 제작표

| ID | 슬롯 | 후보 소스 | 입력 태그 | 후보 실패 시 대체 |
| --- | --- | --- | --- | --- |
| `reward_rail_direct_answer` | 1 | 직업 보상 카드 | 최근 피해, 누수, 구조물 붕괴, 적 역할 | 같은 대응 태그의 낮은 희귀도 카드 |
| `reward_rail_build_bridge` | 2 | 직업 보상 카드 | 현재 아키타입, 보유 아티팩트, 다음 3일 압박 | 같은 풀 라인의 `signal` 또는 `pivot` 카드 |
| `reward_rail_deck_state` | 3 | 공용 보완 또는 안전 직업 카드 | 덱 장수, 손패 막힘, 버리기 사용률, 마나 꼬임 | 골드 거절 버튼의 이유 강조 |

영웅 후보가 지원 크레딧, 실제 지원 카드 보유, 런 중 선택 지원, 최근 전투 증거, 대가 표시 조건을 만족하지 못하면 `heroic_candidate_downgraded`를 기록하고, 같은 아키타입 희귀 카드, 같은 대응 태그 일반 카드, 공용 보완, 안전 직업 카드 순서로 내려갑니다.

골드 거절은 카드 후보 슬롯이 아니라 항상 별도 버튼입니다.

보상 레일이 깨끗한 3번째 후보를 찾지 못하면 카드 슬롯은 안전 후보로 채우고, 골드 버튼에 `덱을 가볍게 유지` 이유를 붙입니다.

보상 후보 레일은 후보 수, 희귀도, 골드 총량을 늘리는 보상 장치가 아닙니다.

### 보상 후보 반복 피로도 제작표

작은 카드 풀에서는 같은 카드가 가끔 다시 보이는 것이 자연스럽지만, 같은 질문이 계속 반복되면 덱 빌딩이 좁게 느껴집니다.

반복 피로도 제작표는 새 카드를 보장하는 장치가 아니라, 최근에 본 카드와 같은 계열을 잠시 뒤로 미루는 제작 기준입니다.

| ID | 제작물 | MVP 필수 | 규칙 | 금지선 |
| --- | --- | --- | --- | --- |
| `reward_fatigue_guard_mvp_5pack` | 반복 피로도 가드 | 예 | 플레이어별 최근 5개 보상 팩을 기준으로 검사 | 후보 수, 희귀도, 골드량 변경 금지 |
| `reward_exposure_memory_player_scope` | 개인 노출 기억 | 예 | 실제 표시된 카드, 계열, 풀 라인, 대응 태그, 선택/거절을 플레이어별 기록 | 파티 전체 평균으로 개인 후보를 덮어쓰기 금지 |
| `reward_repeat_exact_card_suppress` | 같은 카드 억제 | 예 | 같은 카드가 최근 5팩 안에 2회 이상 보이면 같은 레일의 다른 후보 우선 | 미보유 카드 보장 또는 희귀도 천장으로 표시 금지 |
| `reward_repeat_family_variant_block` | 기준/변형 동시 차단 | 예 | 기준 카드와 변형 카드는 같은 보상 화면에 함께 표시하지 않음 | 변형 후보를 강화, 업그레이드, 추가 보상처럼 표시 금지 |
| `reward_repeat_pool_lane_cooldown` | 풀 라인 연속 억제 | 예 | 같은 `poolLaneId`가 3팩 연속 핵심 후보가 되면 다른 레일 연결 카드 우선 | 직업 약점을 지우는 공용 대체 카드 투입 금지 |
| `reward_repeat_declined_card_cooldown` | 반복 거절 카드 쿨다운 | 예 | 같은 카드가 2회 이상 골드 거절되면 5팩 동안 우선순위 하락 | 거절하면 영구 제외된다는 문구 금지 |
| `reward_repeat_allowed_reason_log` | 반복 허용 사유 로그 | 예 | 안전 풀이 너무 좁거나 보스 역할 회수가 필요하면 내부 사유로만 반복 허용 | 플레이어에게 보상 보정, 보너스, 정답 추천처럼 표시 금지 |

반복 피로도 규칙은 최종 후보 3장의 다양성을 높이지만, 새 카드 보장, 희귀도 보정, 후보 수 증가, 웨이브 겹치기 보상 증가로 쓰지 않습니다.

### 공용 카탈로그 역할

| 역할 | 카드 | MVP | 사용 경로 | 금지선 |
| --- | --- | --- | --- | --- |
| `common_soft_gap` | 재정비, 집중 사격, 긴급 보수, 전장 수습, 마나 전환, 빠른 손놀림, 전술 지도, 임시 포탑 | 예 | 라운드 보상, 보스 개인 보상, 낮은 등급 상점 | 빠진 직업 역할을 같은 강도로 대체하지 않음 |
| `common_expansion_locked` | 압박 신호, 방어선 재배치, 비상 축전, 공동 작전, 무음 호출 | 아니오 | 31일 이후, 아티팩트 해금, 이벤트 계약, 상점 실험 | 30일 MVP 일반 라운드 기본 풀에 넣지 않음 |

### 날짜별 카탈로그 노출 제작표

| ID | 일자 | 직업 전용 후보 | 공용 후보 | 영웅/저주 정책 | MVP | 검증 |
| --- | --- | --- | --- | --- | --- | --- |
| `mvp_card_catalog_band_001_004` | 1~4일 | 시작 행동을 보강하는 일반 카드와 낮은 복잡도 희귀 카드 | `common_soft_gap` 최대 1장 | 영웅/저주 없음 | 예 | 첫 4일 안에 직업 기본 루프를 설명할 수 있어야 함 |
| `mvp_card_catalog_band_005_010` | 5~10일 | 파괴, 손패 막힘, 첫 보스 부위 대응 카드 | `common_soft_gap` 최대 1장과 거절 골드 | 영웅/저주 없음 | 예 | 보상 선택 이유가 최근 피해 태그와 연결되어야 함 |
| `mvp_card_catalog_band_011_020` | 11~20일 | 첫 아티팩트와 맞물리는 희귀 전환 카드 | 정보, 수리, 손패 보완 중심 | 일반 라운드 영웅 없음, 저주 명시 선택 | 예 | 첫 빌드 방향의 약점이 남아야 함 |
| `mvp_card_catalog_band_021_030` | 21~30일 | 전체 직업 풀과 준비된 영웅 확정 카드 | `common_soft_gap` 최대 1장 | 영웅 한 화면 1장 이하, 저주 명시 선택 | 예 | 영웅 카드 거절이 실제 선택으로 남아야 함 |

### 카탈로그 검증 항목

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `mvp_card_catalog_entry_schema` | 데이터 | 예 | 카드별 `catalogRole`, `allowedSourceTypes`, `allowedDayRange`, `rewardEligible` 정의 |
| `mvp_card_catalog_starter_10_cards` | 시작 덱 | 예 | 직업별 시작 카드 6종이 중복 매수로 10장 시작 덱을 구성 |
| `mvp_card_catalog_class_14_cards` | 직업 카드 | 예 | 직업별 시작 6종과 보상 8종이 14종 계약을 충족 |
| `mvp_card_catalog_common_8_cards` | 공용 카드 | 예 | 30일 MVP 공용 보완 8종만 기본 풀에 사용 |
| `mvp_class_card_catalog_id_lock` | 직업 ID | 예 | 직업별 14종 카드 ID와 시작 덱 매수 고정 |
| `mvp_card_reward_rail_policy` | 후보 생성 | 예 | 직접 대응, 빌드 연결, 덱 상태 3레일로 보상 후보 구성 |
| `mvp_card_catalog_heroic_gate` | 영웅 카드 | 예 | 21일 이후 `MvpHeroicCommitGate`를 통과할 때만 낮은 비율로 노출 |
| `mvp_card_catalog_curse_consent` | 저주 카드 | 예 | 이벤트 계약 또는 특수 상점에서만 명시 선택으로 제공 |
| `mvp_card_catalog_no_stack_scaling` | 보상 정책 | 예 | 웨이브 겹치기로 후보 수, 희귀도, 골드 총량을 바꾸지 않음 |
| `mvp_card_catalog_solo_projection` | 인원수 | 예 | 모든 직업 카드가 솔로 동쪽 활성 전선에서도 죽은 카드가 되지 않음 |

## 직업 카드 풀 계약 제작표

직업 카드 풀 계약은 카드 종류를 추가하기 전에 먼저 채워야 하는 제작 기준입니다.

MVP의 직업별 14종은 시작 카드 6종과 보상 카드 8종을 합친 기준입니다.

### 계약 데이터

| ID | 직업 | 단계 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `class_card_pool_contract_guardian_first_010` | 수호자 | 1~10일 | 예 | 도발 위치, 가시, 전선 지연을 첫 세션 카드로 확인 |
| `class_card_pool_contract_architect_first_010` | 건축가 | 1~10일 | 예 | 바리케이드, 잔해, 파괴 회수를 첫 세션 카드로 확인 |
| `class_card_pool_contract_elementalist_first_010` | 원소술사 | 1~10일 | 예 | 광역, 둔화, 넉백, 표식을 첫 세션 카드로 확인 |
| `class_card_pool_contract_tinkerer_first_010` | 땜장이 | 1~10일 | 예 | 수리, 오라, 과부하, 보강을 첫 세션 카드로 확인 |
| `class_card_pool_contract_guardian_mvp_030` | 수호자 | 30일 MVP | 예 | 도발 앵커, 가시 가치, 전선 지연, 보스 붙잡기 4라인 유지 |
| `class_card_pool_contract_architect_mvp_030` | 건축가 | 30일 MVP | 예 | 경로 연장, 계획 붕괴, 잔해 제어, 후방 재건 4라인 유지 |
| `class_card_pool_contract_elementalist_mvp_030` | 원소술사 | 30일 MVP | 예 | 군집 광역, 둔화/넉백, 원소 표식, 우선 처치 4라인 유지 |
| `class_card_pool_contract_tinkerer_mvp_030` | 땜장이 | 30일 MVP | 예 | 수리 창, 오라 타이밍, 과부하 대가, 유지보수 경제 4라인 유지 |
| `class_card_pool_contract_guardian_full_100` | 수호자 | 100일 풀런 | 아니오 | 후퇴, 압력 밖 도발, 기지 위기 대응을 기존 3개 아키타입에만 연결 |
| `class_card_pool_contract_architect_full_100` | 건축가 | 100일 풀런 | 아니오 | 후방 기초, 압력 측량, 겨울형 붕괴를 기존 미로/붕괴/재건 아키타입에만 연결 |
| `class_card_pool_contract_elementalist_full_100` | 원소술사 | 100일 풀런 | 아니오 | 결빙 경계, 압력 밖 번개, 표식 낙뢰를 기존 광역/제어/표식 아키타입에만 연결 |
| `class_card_pool_contract_tinkerer_full_100` | 땜장이 | 100일 풀런 | 아니오 | 오라 이동, 압력 밖 회로, 최후 정비를 기존 오라/정비/과부하 아키타입에만 연결 |

### 카드 풀 라인

| ID | 직업 | 대표 대응 태그 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `guardian_taunt_anchor` | 수호자 | `taunt_anchor` | 예 | 적 목표를 한 지점으로 묶는 기본 전면 |
| `guardian_thorns_value` | 수호자 | `sacrifice_value` | 예 | 맞는 동안 반사와 지연 가치를 만듦 |
| `guardian_line_delay` | 수호자 | `repair_window` | 예 | 몇 초 더 버티는 전선 판단 |
| `guardian_boss_hold` | 수호자 | `focus_fire_mark` | 예 | 보스 부위 집중 시간을 벌어줌 |
| `architect_path_extension` | 건축가 | `path_extension` | 예 | 적 이동 시간을 늘리는 미로 설계 |
| `architect_planned_collapse` | 건축가 | `sacrifice_value` | 예 | 부서질 구조물을 미리 정하는 붕괴 설계 |
| `architect_debris_control` | 건축가 | `slow_or_knockback` | 예 | 잔해로 체류 시간과 재진입 동선을 만듦 |
| `architect_rear_rebuild` | 건축가 | `rear_rebuild` | 예 | 무너진 전선을 후방으로 이전 |
| `elementalist_area_damage` | 원소술사 | `area_damage` | 예 | 킬존 군집을 광역으로 정리 |
| `elementalist_slow_knockback` | 원소술사 | `slow_or_knockback` | 예 | 빠른 적과 대형 적의 도달을 늦춤 |
| `elementalist_element_mark` | 원소술사 | `focus_fire_mark` | 예 | 파티가 같은 정예나 부위를 보게 함 |
| `elementalist_priority_burst` | 원소술사 | `priority_burst` | 예 | 지원형, 방해형, 보스 부위를 짧게 끊음 |
| `tinkerer_repair_window` | 땜장이 | `repair_window` | 예 | 살릴 구조물과 버릴 구조물을 나눔 |
| `tinkerer_aura_timing` | 땜장이 | `focus_fire_mark` | 예 | 밀집 방어선의 화력 창을 열어줌 |
| `tinkerer_overdrive_tradeoff` | 땜장이 | `priority_burst` | 예 | 대가 있는 순간 화력으로 우선 대상을 끊음 |
| `tinkerer_maintenance_economy` | 땜장이 | `resource_unjam` | 예 | 수리, 부품, 마나 막힘을 제한적으로 해소 |

카드 풀 라인은 고정 방위가 아니라 현재 압박 전선에 투영됩니다.

솔로 동쪽 전선에서도 모든 라인이 죽은 카드가 되지 않아야 합니다.

### 카드 아키타입 제작표

카드 아키타입은 전리품 카드가 런의 덱 방향으로 읽히게 만드는 묶음입니다.

MVP에서는 직업마다 3개 아키타입을 먼저 제작합니다.

| ID | 직업 | 핵심 카드 풀 라인 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `archetype_guardian_iron_anchor` | 수호자 | 도발 앵커, 전선 지연, 보스 붙잡기 | 예 | 한 전면을 오래 붙잡아 파티 딜타임을 만듦 |
| `archetype_guardian_thorn_citadel` | 수호자 | 도발 앵커, 가시 가치, 전선 지연 | 예 | 맞는 구조물을 피해원으로 바꿈 |
| `archetype_guardian_gate_shift` | 수호자 | 도발 앵커, 보스 붙잡기, 전선 지연 | 예 | 도발 위치를 옮겨 새 킬존을 엶 |
| `archetype_architect_long_maze` | 건축가 | 경로 연장, 잔해 제어, 후방 재건 | 예 | 적 이동 시간을 늘리고 처치 구간을 만듦 |
| `archetype_architect_planned_demolition` | 건축가 | 계획 붕괴, 잔해 제어, 경로 연장 | 예 | 부서질 구조물을 미리 정해 피해와 시간을 남김 |
| `archetype_architect_rear_rebuild` | 건축가 | 후방 재건, 경로 연장, 계획 붕괴 | 예 | 무너진 전선을 뒤로 옮겨 다시 세움 |
| `archetype_elementalist_killzone_ignition` | 원소술사 | 군집 광역, 원소 표식, 둔화/넉백 | 예 | 모인 적을 구역 피해와 표식으로 정리 |
| `archetype_elementalist_frost_control` | 원소술사 | 둔화/넉백, 우선 처치, 원소 표식 | 예 | 빠른 접근을 늦추고 구조물 생존 시간을 확보 |
| `archetype_elementalist_mark_execution` | 원소술사 | 원소 표식, 우선 처치, 군집 광역 | 예 | 정예나 보스 부위를 파티 목표로 지정 |
| `archetype_tinkerer_aura_engine` | 땜장이 | 오라 타이밍, 과부하 대가, 유지보수 경제 | 예 | 밀집 방어선의 짧은 화력 창을 크게 엶 |
| `archetype_tinkerer_emergency_maintenance` | 땜장이 | 수리 창, 유지보수 경제, 오라 타이밍 | 예 | 살릴 구조물과 버릴 구조물을 나눠 전선을 연장 |
| `archetype_tinkerer_overdrive_burst` | 땜장이 | 과부하 대가, 오라 타이밍, 수리 창 | 예 | 구조물 피해를 감수하고 우선 대상을 끊음 |

각 아키타입은 최소 1개 이상의 시작 보강 카드, 방향 신호 또는 전환 카드, 확정 또는 위험 가속 카드를 가져야 합니다.

같은 보상 화면에 같은 아키타입 카드만 3장 표시하지 않습니다.

### 카드 리워크 필수 필드

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `card_field_archetype_ids` | 카드 설계 필드 | 예 | 카드가 지원하는 덱 아키타입 |
| `card_field_archetype_role` | 카드 설계 필드 | 예 | 시작 보강, 방향 신호, 전환, 확정, 위험 가속, 약점 보완 구분 |
| `card_field_commitment_level` | 카드 설계 필드 | 예 | 카드가 덱 방향을 얼마나 강하게 확정하는지 |
| `card_field_decision_question` | 카드 설계 필드 | 예 | 카드를 들고 고민해야 하는 질문 |
| `card_field_timing_windows` | 카드 설계 필드 | 예 | 카드가 가장 강한 전투 타이밍 |
| `card_field_tradeoff_tags` | 카드 설계 필드 | 예 | 마나 외에 감수하는 대가 |
| `card_field_combo_hook_tags` | 카드 설계 필드 | 예 | 함께 쓰면 좋은 카드, 구조물, 직업 시너지 |
| `card_field_miss_cost_tag` | 카드 설계 필드 | 예 | 잘못 사용했을 때 생기는 손해 |
| `card_field_display_complexity` | 카드 설계 필드 | 예 | 단순, 전술, 빌드 중심 카드 구분 |
| `card_field_spec_profile_id` | 카드 스펙 필드 | 예 | 카드가 참조하는 실제 수치 프로필 |
| `card_field_spec_range_duration` | 카드 스펙 필드 | 예 | 시전 거리, 범위, 지속 시간, 예고 시간 |
| `card_field_spec_limits` | 카드 스펙 필드 | 예 | 반복 제한, 보스 적용 정책, 위험 태그 |
| `card_rework_matrix_guardian_mvp_030` | 리워크 매트릭스 | 예 | 수호자 14종의 라인, 타이밍, 대가 기준 |
| `card_rework_matrix_architect_mvp_030` | 리워크 매트릭스 | 예 | 건축가 14종의 라인, 타이밍, 대가 기준 |
| `card_rework_matrix_elementalist_mvp_030` | 리워크 매트릭스 | 예 | 원소술사 14종의 라인, 타이밍, 대가 기준 |
| `card_rework_matrix_tinkerer_mvp_030` | 리워크 매트릭스 | 예 | 땜장이 14종의 라인, 타이밍, 대가 기준 |
| `card_rework_matrix_common_mvp_030` | 리워크 매트릭스 | 예 | 공용 8종의 보완 한계와 대체 금지선 |

### 수호자 14종 리워크 매트릭스 제작표

| 카드 ID | 아키타입 역할 | 타이밍 창 | 대가 태그 | 콤보 훅 | 실패 손해 태그 |
| --- | --- | --- | --- | --- | --- |
| `card_guardian_taunt_wall` | `starter` | `prebuild`, `first_contact` | `low_damage`, `position_commitment` | `elementalist_area_damage`, `architect_path_extension`, `tinkerer_repair_window` | `bad_taunt_position_clusters_enemies` |
| `card_guardian_shield_wrap` | `starter` | `structure_critical` | `requires_prior_setup`, `low_damage` | `tinkerer_repair_window`, `guardian_line_delay` | `premature_shield_low_value` |
| `card_guardian_thorn_growth` | `starter` | `first_contact`, `swarm_compressed` | `requires_prior_setup`, `repeat_penalty` | `elementalist_area_damage`, `tinkerer_repair_window` | `played_without_incoming_hits` |
| `card_guardian_binding_oath` | `starter` | `first_contact`, `boss_commit` | `requires_prior_setup`, `low_damage` | `elementalist_area_damage`, `architect_planned_collapse` | `no_taunted_targets` |
| `card_guardian_last_gate` | `starter` | `boss_commit`, `structure_critical` | `structure_hp_loss`, `requires_prior_setup`, `repeat_penalty` | `tinkerer_repair_window`, `architect_rear_rebuild` | `spent_crisis_on_nonlethal_damage` |
| `card_guardian_counter_stance` | `starter` | `structure_critical`, `hand_jammed` | `requires_prior_setup`, `resource_loop_guard` | `guardian_line_delay`, `card_common_mana_convert` | `no_incoming_hit_no_refund` |
| `card_guardian_iron_wall` | `signal` | `prebuild`, `first_contact` | `position_commitment`, `low_damage` | `tinkerer_repair_window`, `archetype_guardian_iron_anchor` | `overcommitted_wrong_front` |
| `card_guardian_reflective_oath` | `signal` | `swarm_compressed`, `first_contact` | `repair_efficiency_down`, `repeat_penalty` | `card_guardian_thorn_growth`, `tinkerer_repair_window` | `repair_debt_without_hits` |
| `card_guardian_front_swap` | `pivot` | `collapse_aftershock`, `boss_commit` | `position_commitment`, `requires_prior_setup` | `architect_rear_rebuild`, `elementalist_area_damage` | `moved_taunt_out_of_killzone` |
| `card_guardian_crack_shield` | `pivot` | `first_contact`, `stack_pressure` | `requires_prior_setup`, `repeat_penalty` | `card_guardian_reflective_oath`, `elementalist_slow_knockback` | `shield_never_triggered` |
| `card_guardian_last_guard` | `pivot` | `boss_commit`, `base_critical` | `requires_prior_setup`, `low_damage` | `tinkerer_repair_window`, `card_common_emergency_repair` | `spent_last_guard_before_real_leak` |
| `card_guardian_thorn_throne` | `payoff` | `stack_pressure`, `boss_commit` | `repair_efficiency_down`, `requires_prior_setup`, `repeat_penalty` | `card_guardian_reflective_oath`, `tinkerer_repair_window`, `elementalist_area_damage` | `locked_party_into_repair_debt` |
| `card_guardian_unbroken_gate` | `payoff` | `boss_commit`, `base_critical` | `position_commitment`, `requires_prior_setup`, `low_damage` | `card_common_focus_fire`, `elementalist_element_mark`, `tinkerer_aura_timing` | `placed_gate_without_followup_damage` |
| `card_guardian_heavy_vow` | `risk_accelerator` | `hand_jammed`, `stack_pressure`, `structure_critical` | `next_draw_down`, `structure_hp_loss` | `card_guardian_last_gate`, `card_guardian_counter_stance`, `tinkerer_repair_window` | `draw_loss_before_next_crisis` |

수호자 리워크 제작 검수:

- `card_guardian_counter_stance`와 `card_guardian_heavy_vow`는 0비용이지만 조건 없는 자원 순증가를 만들 수 없습니다.
- `card_guardian_thorn_throne`과 `card_guardian_unbroken_gate`는 `MvpHeroicCommitGate` 없이 21일 이전 기본 보상 후보로 들어갈 수 없습니다.
- `card_guardian_last_gate`, `card_guardian_unbroken_gate`는 보스 본체 패턴을 취소하지 않고 부위 집중 시간으로만 변환합니다.
- 모든 수호자 카드는 `soloProjectionSafe: true`이며 고정 방위 전용 문구를 쓰지 않습니다.
- 리워크 매트릭스는 웨이브 겹치기 보상, 카드 후보 수, 희귀도, 골드 총량을 바꾸지 않습니다.

### 건축가 14종 리워크 매트릭스 제작표

| 카드 ID | 아키타입 역할 | 타이밍 창 | 대가 태그 | 콤보 훅 | 실패 손해 태그 |
| --- | --- | --- | --- | --- | --- |
| `card_architect_barricade` | `starter` | `prebuild`, `first_contact` | `position_commitment`, `low_damage` | `guardian_taunt_anchor`, `elementalist_area_damage`, `tinkerer_repair_window` | `route_shortened_or_blocked_by_bad_wall` |
| `card_architect_slowing_stake` | `starter` | `prebuild`, `first_contact` | `position_commitment`, `requires_prior_setup` | `elementalist_slow_knockback`, `guardian_taunt_anchor` | `trap_placed_off_path` |
| `card_architect_debris_blast` | `starter` | `structure_critical`, `swarm_compressed` | `requires_prior_setup`, `repeat_penalty` | `guardian_taunt_anchor`, `elementalist_area_damage` | `no_collapse_no_blast` |
| `card_architect_temporary_path` | `starter` | `first_contact`, `collapse_aftershock` | `temporary_only`, `temporary_no_salvage` | `guardian_line_delay`, `card_common_battlefield_cleanup` | `temporary_path_expired_before_followup` |
| `card_architect_salvage_work` | `starter` | `collapse_aftershock`, `hand_jammed` | `resource_loop_guard`, `requires_prior_setup` | `card_architect_barricade`, `tinkerer_maintenance_economy` | `salvaged_records_needed_for_next_plan` |
| `card_architect_compact_design` | `starter` | `prebuild`, `collapse_aftershock` | `requires_prior_setup`, `position_commitment` | `card_architect_double_barricade`, `card_architect_reinforced_blueprint` | `held_discount_during_crisis` |
| `card_architect_double_barricade` | `signal` | `prebuild`, `stack_pressure` | `position_commitment`, `low_damage` | `elementalist_area_damage`, `guardian_taunt_anchor` | `maze_readability_broken` |
| `card_architect_shard_recovery` | `signal` | `collapse_aftershock`, `hand_jammed` | `resource_loop_guard`, `requires_prior_setup` | `shop_deck_trim`, `tinkerer_maintenance_economy` | `recovered_wrong_destroy_record` |
| `card_architect_delayed_charge` | `pivot` | `swarm_compressed`, `structure_critical` | `requires_prior_setup`, `position_commitment` | `card_architect_debris_blast`, `elementalist_area_damage` | `detonated_after_enemies_left` |
| `card_architect_slippery_debris` | `pivot` | `collapse_aftershock`, `stack_pressure` | `requires_prior_setup`, `repeat_penalty` | `card_architect_debris_blast`, `elementalist_slow_knockback` | `no_debris_to_extend` |
| `card_architect_reinforced_blueprint` | `pivot` | `prebuild`, `first_contact` | `position_commitment`, `requires_prior_setup` | `tinkerer_repair_window`, `archetype_architect_long_maze` | `overbuilt_when_collapse_needed` |
| `card_architect_chain_collapse` | `payoff` | `stack_pressure`, `swarm_compressed` | `requires_prior_setup`, `repeat_penalty`, `position_commitment` | `card_architect_delayed_charge`, `card_architect_debris_blast`, `guardian_taunt_anchor` | `chain_collapse_without_setup` |
| `card_architect_inverted_path` | `payoff` | `boss_commit`, `stack_pressure` | `position_commitment`, `requires_prior_setup` | `elementalist_area_damage`, `guardian_boss_hold` | `path_cost_changed_wrong_segment` |
| `card_architect_overbuilt` | `risk_accelerator` | `collapse_aftershock`, `hand_jammed`, `structure_critical` | `temporary_only`, `resource_loop_guard`, `structure_hp_loss` | `card_architect_salvage_work`, `guardian_line_delay` | `free_wall_fed_breakers` |

건축가 리워크 제작 검수:

- `card_architect_temporary_path`와 `card_architect_overbuilt`은 임시/취약 구조물을 보상 회수 가치로 만들 수 없습니다.
- `card_architect_salvage_work`와 `card_architect_shard_recovery`는 같은 파괴 기록을 중복 소모할 수 없습니다.
- `card_architect_chain_collapse`와 `card_architect_inverted_path`는 선행 구조물, 파괴 기록, 경로 읽기 없이 영웅 후보로 강제 노출되지 않습니다.
- 모든 경로 변경 카드는 완전 길막 검사와 사용 전후 경로 미리보기를 통과해야 합니다.
- 모든 건축가 카드는 `soloProjectionSafe: true`이며, 비활성 방향 설치/압박/보상을 만들지 않습니다.
- 리워크 매트릭스는 웨이브 겹치기 보상, 카드 후보 수, 희귀도, 골드 총량을 바꾸지 않습니다.

### 원소술사 14종 리워크 매트릭스 제작표

| 카드 ID | 아키타입 역할 | 타이밍 창 | 대가 태그 | 콤보 훅 | 실패 손해 태그 |
| --- | --- | --- | --- | --- | --- |
| `card_elementalist_fireball` | `starter` | `swarm_compressed` | `low_single_target`, `position_commitment` | `guardian_taunt_anchor`, `architect_path_extension`, `tinkerer_aura_timing` | `cast_on_scattered_targets` |
| `card_elementalist_frost_zone` | `starter` | `first_contact`, `structure_critical` | `repeat_penalty`, `low_damage` | `guardian_line_delay`, `architect_slippery_debris` | `froze_low_pressure_segment` |
| `card_elementalist_pushback` | `starter` | `structure_critical` | `repeat_penalty`, `position_commitment` | `guardian_boss_hold`, `architect_inverted_path` | `pushed_target_out_of_killzone` |
| `card_elementalist_chain_lightning` | `starter` | `swarm_compressed`, `priority_exposed` | `requires_prior_setup`, `low_single_target` | `guardian_taunt_anchor`, `tinkerer_overdrive_tradeoff` | `chain_broke_on_spread_targets` |
| `card_elementalist_mark` | `starter` | `priority_exposed`, `boss_commit` | `requires_followup`, `low_damage` | `card_elementalist_overcharged_bolt`, `tinkerer_aura_timing`, `guardian_boss_hold` | `marked_without_followup_focus` |
| `card_elementalist_big_blast` | `starter` | `stack_pressure`, `boss_commit` | `high_cost`, `forecast_required` | `architect_planned_collapse`, `guardian_taunt_anchor` | `spent_blast_after_cluster_split` |
| `card_elementalist_fire_ring` | `signal` | `prebuild`, `swarm_compressed` | `forecast_required`, `position_commitment` | `architect_path_extension`, `card_elementalist_frost_zone` | `fire_ring_missed_predicted_path` |
| `card_elementalist_frost_shard` | `signal` | `priority_exposed`, `structure_critical` | `requires_prior_setup`, `low_damage` | `card_elementalist_frost_zone`, `card_elementalist_mark` | `shard_without_chilled_target` |
| `card_elementalist_rewind_gust` | `pivot` | `structure_critical`, `stack_pressure` | `repeat_penalty`, `position_commitment`, `boss_weakened_conversion` | `guardian_line_delay`, `architect_inverted_path` | `rewound_wrong_segment` |
| `card_elementalist_overcharged_bolt` | `pivot` | `priority_exposed`, `swarm_compressed` | `requires_prior_setup`, `execution_check` | `card_elementalist_mark`, `tinkerer_overdrive_tradeoff` | `bolt_failed_to_execute_target` |
| `card_elementalist_elemental_rift` | `pivot` | `boss_commit`, `swarm_compressed` | `position_commitment`, `repeat_penalty` | `guardian_taunt_anchor`, `tinkerer_aura_timing`, `architect_path_extension` | `rift_zone_without_party_focus` |
| `card_elementalist_eye_of_stillness` | `payoff` | `stack_pressure`, `boss_commit` | `repeat_penalty`, `high_cost`, `boss_weakened_conversion` | `guardian_last_gate`, `architect_rear_rebuild` | `spent_stillness_before_real_stack` |
| `card_elementalist_storm_ritual` | `payoff` | `boss_commit`, `stack_pressure` | `forecast_required`, `high_cost`, `position_commitment` | `card_elementalist_mark`, `architect_planned_collapse`, `guardian_boss_hold` | `ritual_struck_empty_warning_tiles` |
| `card_elementalist_forbidden_lantern` | `risk_accelerator` | `boss_commit`, `hand_jammed` | `kill_mana_loss`, `requires_followup`, `curse_debt` | `card_elementalist_mark`, `card_elementalist_storm_ritual` | `lantern_slowed_normal_wave_economy` |

원소술사 리워크 제작 검수:

- `card_elementalist_fireball`, `card_elementalist_big_blast`, `card_elementalist_storm_ritual`은 전장 전체 자동 피해나 비활성 방향 피해를 만들 수 없습니다.
- `card_elementalist_frost_zone`, `card_elementalist_pushback`, `card_elementalist_rewind_gust`, `card_elementalist_eye_of_stillness`는 보스 본체 패턴을 취소하지 않고 약화 변환만 적용합니다.
- 넉백은 경로 밖, 기지 안쪽, 비활성 방향으로 적을 밀어내지 않습니다.
- `card_elementalist_mark`, `card_elementalist_overcharged_bolt`, `card_elementalist_forbidden_lantern`은 후속 화력 조건 없이 자동 처형이나 무제한 전이를 만들 수 없습니다.
- 모든 원소술사 카드는 `soloProjectionSafe: true`이며, 동쪽 전선 안에서 군집/누수/부위 노출 판단으로 투영됩니다.
- 리워크 매트릭스는 웨이브 겹치기 보상, 카드 후보 수, 희귀도, 골드 총량을 바꾸지 않습니다.

### 땜장이 14종 리워크 매트릭스 제작표

| 카드 ID | 아키타입 역할 | 타이밍 창 | 대가 태그 | 콤보 훅 | 실패 손해 태그 |
| --- | --- | --- | --- | --- | --- |
| `card_tinkerer_amplifier` | `starter` | `prebuild`, `first_contact` | `aura_stack_cap`, `position_commitment` | `elementalist_area_damage`, `guardian_line_delay`, `architect_path_extension` | `aura_core_clustered_in_boss_pressure` |
| `card_tinkerer_remote_repair` | `starter` | `structure_critical`, `collapse_aftershock` | `global_target_budget`, `repeat_penalty`, `low_damage` | `guardian_line_delay`, `architect_rear_rebuild` | `repaired_structure_without_lethal_pressure` |
| `card_tinkerer_armor_plate` | `starter` | `first_contact`, `structure_critical` | `requires_prior_setup`, `position_commitment` | `guardian_taunt_anchor`, `card_tinkerer_remote_repair` | `plated_safe_backline_structure` |
| `card_tinkerer_overdrive` | `starter` | `priority_exposed`, `swarm_compressed` | `structure_hp_loss`, `repair_debt`, `aura_stack_cap` | `elementalist_priority_burst`, `card_tinkerer_auto_extinguisher` | `overdrive_broke_needed_structure` |
| `card_tinkerer_spare_parts` | `starter` | `prebuild`, `collapse_aftershock` | `resource_loop_guard`, `requires_prior_setup` | `architect_planned_collapse`, `card_tinkerer_reassembly_machine` | `insurance_on_structure_that_survived` |
| `card_tinkerer_auto_rebuild` | `starter` | `structure_critical`, `boss_commit` | `repeat_penalty`, `requires_prior_setup`, `low_rebuild_hp` | `guardian_last_gate`, `architect_rear_rebuild` | `auto_rebuild_saved_wrong_structure` |
| `card_tinkerer_lubrication` | `signal` | `priority_exposed`, `swarm_compressed` | `aura_stack_cap`, `requires_target_window` | `card_elementalist_mark`, `guardian_taunt_anchor` | `buffed_tower_without_target_window` |
| `card_tinkerer_reinforced_screw` | `signal` | `prebuild`, `first_contact` | `position_commitment`, `repeat_penalty` | `guardian_line_delay`, `architect_path_extension` | `screw_locked_wrong_anchor` |
| `card_tinkerer_emergency_wiring` | `pivot` | `stack_pressure`, `structure_critical` | `structure_hp_loss`, `aura_stack_cap`, `repair_debt` | `card_tinkerer_amplifier`, `card_tinkerer_remote_repair` | `wiring_exposed_aura_core` |
| `card_tinkerer_preheater` | `pivot` | `prebuild`, `first_contact` | `timing_limited`, `structure_hp_loss` | `elementalist_area_damage`, `card_tinkerer_lubrication` | `preheater_after_opening_window` |
| `card_tinkerer_auto_extinguisher` | `pivot` | `priority_exposed`, `hand_jammed` | `requires_prior_setup`, `reduced_payoff`, `repeat_penalty` | `card_tinkerer_overdrive`, `card_tinkerer_risky_mod` | `extinguisher_without_overdrive_debt` |
| `card_tinkerer_resonance_amp` | `payoff` | `prebuild`, `stack_pressure` | `aura_stack_cap`, `position_commitment`, `area_pressure_vulnerable` | `card_tinkerer_amplifier`, `card_tinkerer_emergency_wiring`, `guardian_boss_hold` | `resonance_network_overclustered` |
| `card_tinkerer_reassembly_machine` | `payoff` | `collapse_aftershock`, `boss_commit` | `low_rebuild_hp`, `repeat_penalty`, `resource_loop_guard` | `architect_rear_rebuild`, `card_tinkerer_spare_parts` | `reassembled_without_followup_defense` |
| `card_tinkerer_risky_mod` | `risk_accelerator` | `priority_exposed`, `boss_commit` | `structure_hp_loss`, `repair_efficiency_down`, `curse_debt` | `card_tinkerer_auto_extinguisher`, `elementalist_priority_burst` | `risky_mod_backlash_collapsed_line` |

땜장이 리워크 제작 검수:

- `card_tinkerer_remote_repair`, `card_tinkerer_auto_rebuild`, `card_tinkerer_reassembly_machine`은 구조물 파괴를 삭제하지 않고 반복 효율 감소와 낮은 복구 체력을 가집니다.
- `card_tinkerer_amplifier`, `card_tinkerer_emergency_wiring`, `card_tinkerer_resonance_amp`는 오라 중첩 상한, 범위 미리보기, 밀집 위험 표시를 가집니다.
- `card_tinkerer_overdrive`, `card_tinkerer_auto_extinguisher`, `card_tinkerer_risky_mod`는 과부하 대가를 완전히 무효화하지 못합니다.
- 임시 구조물, 자동 복구 구조물, 재조립 구조물은 회수 가치와 파괴 보상 루프의 반복 자원이 될 수 없습니다.
- 모든 땜장이 카드는 `soloProjectionSafe: true`이며, 동쪽 전선 안에서 핵심 구조물/오라 중심/후방 재건 판단으로 투영됩니다.
- 리워크 매트릭스는 웨이브 겹치기 보상, 카드 후보 수, 희귀도, 골드 총량을 바꾸지 않습니다.

### 공용 8종 리워크 매트릭스 제작표

| 카드 ID | 아키타입 역할 | 타이밍 창 | 대가 태그 | 콤보 훅 | 실패 손해 태그 |
| --- | --- | --- | --- | --- | --- |
| `card_common_reorganize` | `common_soft_gap` | `hand_jammed` | `discard_no_reward`, `resource_loop_guard` | `card_common_mana_convert`, `card_guardian_counter_stance` | `discarded_needed_answer` |
| `card_common_focus_fire` | `common_soft_gap` | `priority_exposed`, `boss_commit` | `soft_gap_only`, `low_area_value` | `guardian_boss_hold`, `card_elementalist_mark`, `tinkerer_aura_timing` | `focused_without_party_damage` |
| `card_common_emergency_repair` | `common_soft_gap` | `structure_critical` | `low_repair`, `range_limit`, `repeat_penalty` | `guardian_line_delay`, `architect_rear_rebuild` | `repaired_after_lethal_window` |
| `card_common_battlefield_cleanup` | `common_soft_gap` | `collapse_aftershock` | `collapse_record_required`, `low_damage`, `temporary_no_salvage` | `architect_planned_collapse`, `elementalist_slow_knockback` | `cleanup_without_collapse_record` |
| `card_common_mana_convert` | `common_soft_gap` | `hand_jammed` | `discard_no_reward`, `resource_loop_guard`, `once_per_wave` | `card_common_reorganize`, `card_guardian_counter_stance` | `converted_future_answer` |
| `card_common_quick_hands` | `common_soft_gap` | `hand_jammed` | `discard_no_reward`, `no_net_draw`, `resource_loop_guard` | `card_common_reorganize`, `card_common_mana_convert` | `cycled_into_same_jam` |
| `card_common_tactical_map` | `common_soft_gap` | `prebuild` | `information_only`, `combat_locked`, `no_auto_recommend` | `architect_path_extension`, `guardian_taunt_anchor` | `map_used_after_commitment` |
| `card_common_temporary_turret` | `common_soft_gap` | `first_contact`, `collapse_aftershock` | `temporary_only`, `temporary_no_salvage`, `low_damage`, `slot_cap` | `card_common_battlefield_cleanup`, `tinkerer_repair_window` | `turret_replaced_needed_class_structure` |

공용 카드 리워크 제작 검수:

- 모든 공용 카드는 직업 카드 풀 계약의 `forbiddenReplacementResponseTags`를 `counterStrength: strong`으로 해결할 수 없습니다.
- `card_common_reorganize`, `card_common_mana_convert`, `card_common_quick_hands`는 버리기 보상, 비상 탈출기 마나 회복, 드로우/마나 루프를 발동하지 않습니다.
- `card_common_focus_fire`는 광역 피해 증폭이나 원소 표식 대체 효과를 가지지 않습니다.
- `card_common_emergency_repair`는 원격 수리보다 낮은 회복량, 짧은 사거리, 반복 수리 효율 감소를 가집니다.
- `card_common_battlefield_cleanup`은 잔해 생성, 폭발 피해, 회수 가치, 완전 길막을 제공하지 않습니다.
- `card_common_tactical_map`은 정답 배치, 자동 추천, 비활성 방향 정보 공개를 하지 않습니다.
- `card_common_temporary_turret`은 도발, 오라, 잔해, 회수 가치, 직업 전용 타워 성능을 가지지 않습니다.
- 모든 공용 카드는 `soloProjectionSafe: true`이며, 동쪽 전선 안에서 손패 막힘/누수/붕괴 자리/다음 압박 예고로 투영됩니다.
- 리워크 매트릭스는 웨이브 겹치기 보상, 카드 후보 수, 희귀도, 골드 총량을 바꾸지 않습니다.

### 카드 실패 피드백 제작표

| ID | 피드백 키 | 유형 | 연결 태그 | 표시 위치 | 소모 정책 | MVP |
| --- | --- | --- | --- | --- | --- | --- |
| `card_fail_not_enough_mana` | `ui.card.fail.not_enough_mana` | `hard_block` | `not_enough_mana` | 손패 카드 위 | 카드/마나 소모 없음 | 예 |
| `card_fail_no_target` | `ui.card.fail.no_target` | `hard_block` | `no_valid_target` | 손패 카드 위 | 카드/마나 소모 없음 | 예 |
| `card_fail_out_of_range` | `ui.card.fail.out_of_range` | `hard_block` | `out_of_range` | 대상 커서 옆 | 카드/마나 소모 없음 | 예 |
| `card_fail_path_blocked` | `ui.card.fail.path_blocked` | `hard_block` | `path_cost_change`, `full_block` | 설치 타일 | 카드/마나 소모 없음 | 예 |
| `card_fail_need_collapse_record` | `ui.card.fail.need_collapse_record` | `hard_block` | `collapse_record_required` | 카드 위 | 카드/마나 소모 없음 | 예 |
| `card_fail_scattered_targets` | `ui.card.fail.scattered_targets` | `soft_miss` | `low_single_target`, `swarm_not_compressed` | 대상 구역 | 카드/마나 소모 | 예 |
| `card_fail_no_followup_focus` | `ui.card.fail.no_followup_focus` | `soft_miss` | `requires_followup` | 표식 대상 | 카드/마나 소모 | 예 |
| `card_fail_control_resisted` | `ui.card.fail.control_resisted` | `resistance_conversion` | `repeat_penalty`, `hard_cc` | 대상 체력바 | 카드/마나 소모 | 예 |
| `card_fail_boss_weakened` | `ui.card.fail.boss_weakened` | `resistance_conversion` | `boss_weakened_conversion` | 보스 체력바 | 카드/마나 소모 | 예 |
| `card_fail_discard_no_reward` | `ui.card.fail.discard_no_reward` | `loop_guard_blocked` | `discard_no_reward` | 버리기/드로우 게이지 | 추가 보상 없음 | 예 |
| `card_fail_temporary_no_salvage` | `ui.card.fail.temporary_no_salvage` | `loop_guard_blocked` | `temporary_no_salvage` | 구조물 툴팁 | 회수 가치 없음 | 예 |
| `card_fail_aura_stack_capped` | `ui.card.fail.aura_stack_capped` | `tradeoff_resolved` | `aura_stack_cap` | 오라 범위 | 카드/마나 소모 | 예 |
| `card_fail_repair_repeated` | `ui.card.fail.repair_repeated` | `tradeoff_resolved` | `repeat_penalty`, `low_repair` | 구조물 체력바 | 카드/마나 소모 | 예 |
| `card_fail_overdrive_debt` | `ui.card.fail.overdrive_debt` | `tradeoff_preview`, `tradeoff_resolved` | `structure_hp_loss`, `repair_debt` | 카드/구조물 | 확정 후 소모 | 예 |
| `card_fail_prebuild_only` | `ui.card.fail.prebuild_only` | `hard_block` | `combat_locked` | 카드 위 | 카드/마나 소모 없음 | 예 |

카드 실패 피드백 제작 검수:

- `hard_block`은 카드와 마나를 소모할 수 없습니다.
- `soft_miss`, `resistance_conversion`, `tradeoff_resolved`는 효과가 실제 적용된 경우에만 카드와 마나를 소모합니다.
- 모든 `CardReworkMatrixEntry.failureFeedbackKey`는 위 표의 키 또는 직업별 확장 키를 참조해야 합니다.
- 피드백 문구는 보상 증가, 희귀도 증가, 카드 후보 증가, 비활성 방향 정보 공개를 암시하지 않습니다.
- 같은 플레이어에게 카드 실패 문구를 동시에 2개 이상 표시하지 않습니다.

### 카드 스펙 프로필 제작표

카드 스펙 프로필은 카드의 실제 수치와 적용 제한을 제작하는 항목입니다.

MVP에서는 모든 카드에 프로필이 필요하지만, 먼저 아래 카드로 핵심 위험 축을 검증합니다.

| ID | 대상 카드 | 예산 ID | MVP | 검증할 축 |
| --- | --- | --- | --- | --- |
| `spec_card_guardian_taunt_wall_mvp` | 도발벽 | `budget_cost1_single_basic` | 예 | 도발 반경, 설치 거리, 완전 길막 검사 |
| `spec_card_guardian_shield_wrap_mvp` | 방패 두르기 | `budget_cost1_single_basic` | 예 | 단일 구조물 피해 감소와 중첩 제한 |
| `spec_card_guardian_thorn_growth_mvp` | 가시 성장 | `budget_cost1_single_basic` | 예 | 피격 기반 반복 피해와 대상 조건 |
| `spec_card_guardian_binding_oath_mvp` | 붙잡는 맹세 | `budget_cost2_tactical_shift` | 예 | 도발 대상 둔화와 보스 약화 변환 |
| `spec_card_guardian_last_gate_mvp` | 최후의 문 | `budget_cost3_crisis_answer` | 예 | 짧은 파괴 방지와 후유증 대가 |
| `spec_card_guardian_counter_stance_mvp` | 응전 태세 | `budget_cost0_connector` | 예 | 0비용 조건부 자원 회수 |
| `spec_card_guardian_iron_wall_mvp` | 철벽 전개 | `budget_cost2_tactical_shift` | 예 | 도발 구조물 장기 방어와 대상당 제한 |
| `spec_card_guardian_reflective_oath_mvp` | 반사의 맹세 | `budget_cost1_single_basic` | 예 | 가시 강화와 수리 효율 감소 |
| `spec_card_guardian_front_swap_mvp` | 전열 교대 | `budget_cost1_single_basic` | 예 | 도발 구조물 이동과 경로 미리보기 |
| `spec_card_guardian_crack_shield_mvp` | 균열 방패 | `budget_cost2_tactical_shift` | 예 | 피격 시 둔화 발동과 발동 쿨다운 |
| `spec_card_guardian_last_guard_mvp` | 마지막 수호 | `budget_cost2_tactical_shift` | 예 | 낮은 기지 체력 조건과 위기 방어 |
| `spec_card_guardian_thorn_throne_mvp` | 가시 왕좌 | `budget_cost3_crisis_answer` | 예 | 전체 도발 구조물 가시와 총 발동 상한 |
| `spec_card_guardian_unbroken_gate_mvp` | 불굴의 성문 | `budget_cost4_commitment` | 예 | 대형 도발 구조물과 보스 정지 금지 |
| `spec_card_guardian_heavy_vow_mvp` | 무거운 서약 | `budget_cost0_risky_boost` | 예 | 저주형 즉시 마나와 다음 드로우 대가 |
| `spec_card_architect_barricade_mvp` | 바리케이드 | `budget_cost1_single_basic` | 예 | 설치 경로 미리보기와 길막 검증 |
| `spec_card_architect_slowing_stake_mvp` | 둔화 말뚝 | `budget_cost1_single_basic` | 예 | 함정 발동과 반복 둔화 저항 |
| `spec_card_architect_debris_blast_mvp` | 잔해 폭발 | `budget_cost1_single_basic` | 예 | 파괴 조건부 폭발과 발동 상한 |
| `spec_card_architect_temporary_path_mvp` | 급조 통로 | `budget_cost0_connector` | 예 | 무료 임시 구조물과 회수 가치 제외 |
| `spec_card_architect_salvage_work_mvp` | 회수 작업 | `budget_cost1_single_basic` | 예 | 파괴 기록 소모와 마나 회수 상한 |
| `spec_card_architect_compact_design_mvp` | 압축 설계 | `budget_cost2_tactical_shift` | 예 | 다음 설치 비용/체력 보정과 적용 제외 |
| `spec_card_architect_double_barricade_mvp` | 이중 바리케이드 | `budget_cost2_tactical_shift` | 예 | 2칸 동시 설치와 이중 경로 검사 |
| `spec_card_architect_shard_recovery_mvp` | 파편 회수 | `budget_cost1_single_basic` | 예 | 골드 회수와 기록 중복 소모 금지 |
| `spec_card_architect_delayed_charge_mvp` | 지연 폭약 | `budget_cost1_single_basic` | 예 | 능동 폭파와 구조물 폭발 피해 상한 |
| `spec_card_architect_slippery_debris_mvp` | 미끄러운 잔해 | `budget_cost1_single_basic` | 예 | 잔해 둔화와 잔해 지속 상한 |
| `spec_card_architect_reinforced_blueprint_mvp` | 보강 설계도 | `budget_cost2_tactical_shift` | 예 | 구조물 체력 증가와 파괴 가치 지연 |
| `spec_card_architect_chain_collapse_mvp` | 연쇄 붕괴 | `budget_cost3_crisis_answer` | 예 | 폭발 연쇄 보너스와 총 추가 피해 상한 |
| `spec_card_architect_inverted_path_mvp` | 뒤집힌 통로 | `budget_cost3_crisis_answer` | 예 | 경로 비용 증가와 완전 차단 금지 |
| `spec_card_architect_overbuilt_mvp` | 무리한 증축 | `budget_cost0_risky_boost` | 예 | 무료 취약 바리케이드와 회수 가치 제외 |
| `spec_card_elementalist_fireball_mvp` | 화염구 | `budget_cost1_small_area_instant` | 예 | 비용 1 작은 광역 피해 기준 |
| `spec_card_elementalist_frost_zone_mvp` | 빙결 지대 | `budget_cost1_small_area_instant` | 예 | hard CC 반복 저항과 보스 약화 변환 |
| `spec_card_elementalist_pushback_mvp` | 밀어내기 | `budget_cost1_single_basic` | 예 | 짧은 넉백과 경로 밖 밀어내기 금지 |
| `spec_card_elementalist_chain_lightning_mvp` | 번개 연결 | `budget_cost2_tactical_shift` | 예 | 근접 연쇄 피해와 같은 대상 재타격 금지 |
| `spec_card_elementalist_mark_mvp` | 원소 표식 | `budget_cost0_connector` | 예 | 0비용 후속 피해 조건 |
| `spec_card_elementalist_big_blast_mvp` | 대폭발 | `budget_cost3_crisis_answer` | 예 | 큰 예고 광역 피해와 보스 피해 약화 |
| `spec_card_elementalist_fire_ring_mvp` | 화염 고리 | `budget_cost2_tactical_shift` | 예 | 지속 피해 지대와 자동 추적 금지 |
| `spec_card_elementalist_frost_shard_mvp` | 서리 파편 | `budget_cost1_single_basic` | 예 | 둔화/빙결 선행 조건 피해 보정 |
| `spec_card_elementalist_rewind_gust_mvp` | 되감는 돌풍 | `budget_cost2_tactical_shift` | 예 | 큰 넉백과 반복 저항 |
| `spec_card_elementalist_overcharged_bolt_mvp` | 과충전 번개 | `budget_cost2_tactical_shift` | 예 | 처치 조건 전이와 시전당 발동 제한 |
| `spec_card_elementalist_elemental_rift_mvp` | 원소 균열 | `budget_cost1_small_area_instant` | 예 | 구역 광역 취약과 활성 수 제한 |
| `spec_card_elementalist_eye_of_stillness_mvp` | 정지의 눈 | `budget_cost3_crisis_answer` | 예 | 넓은 둔화와 종료 후 저항 대가 |
| `spec_card_elementalist_storm_ritual_mvp` | 낙뢰 의식 | `budget_cost4_commitment` | 예 | 고정 예고 지점 피해와 자동 추적 금지 |
| `spec_card_elementalist_forbidden_lantern_mvp` | 금지된 등불 | `budget_cost1_risky_focus` | 예 | 보스 부위 집중과 일반 처치 마나 대가 |
| `spec_card_tinkerer_amplifier_mvp` | 증폭기 | `budget_cost1_aura_device` | 예 | 오라 구조물 설치와 중첩 상한 |
| `spec_card_tinkerer_remote_repair_mvp` | 원격 수리 | `budget_cost1_global_support` | 예 | 전장 전체 대상의 낮은 회복량과 반복 보정 |
| `spec_card_tinkerer_armor_plate_mvp` | 보강판 | `budget_cost1_single_basic` | 예 | 단일 구조물 임시 내구와 중첩 제한 |
| `spec_card_tinkerer_overdrive_mvp` | 과부하 | `budget_cost0_risky_boost` | 예 | 0비용 위험 가속과 구조물 피해 대가 |
| `spec_card_tinkerer_spare_parts_mvp` | 예비 부품 | `budget_cost1_single_basic` | 예 | 파괴 보험과 자원 루프 방지 |
| `spec_card_tinkerer_auto_rebuild_mvp` | 자동 복구 | `budget_cost2_tactical_shift` | 예 | 파괴 직전 복구와 같은 구조물 제한 |
| `spec_card_tinkerer_lubrication_mvp` | 윤활 작업 | `budget_cost1_single_basic` | 예 | 단일 공격 속도 버프와 합산 상한 |
| `spec_card_tinkerer_reinforced_screw_mvp` | 강화 나사 | `budget_cost1_single_basic` | 예 | 장기 유지 구조물 선택과 대상당 제한 |
| `spec_card_tinkerer_emergency_wiring_mvp` | 긴급 배선 | `budget_cost0_risky_boost` | 예 | 오라 범위 위험 강화와 구조물 피해 |
| `spec_card_tinkerer_preheater_mvp` | 예열 장치 | `budget_cost2_tactical_shift` | 예 | 웨이브 초반 화력 창과 사용 시간 제한 |
| `spec_card_tinkerer_auto_extinguisher_mvp` | 자동 소화 | `budget_cost1_single_basic` | 예 | 과부하 페널티 1회 완화와 대상 조건 |
| `spec_card_tinkerer_resonance_amp_mvp` | 공명 증폭기 | `budget_cost3_engine_commitment` | 예 | 오라 공유 네트워크와 밀집 위험 |
| `spec_card_tinkerer_reassembly_machine_mvp` | 재조립 기계 | `budget_cost4_commitment` | 예 | 파괴 위치 재설치와 반복 재건 페널티 |
| `spec_card_tinkerer_risky_mod_mvp` | 위험한 개조 | `budget_cost0_risky_boost` | 예 | 저주형 순간 화력과 큰 종료 피해 |
| `spec_card_common_reorganize_mvp` | 재정비 | `budget_cost0_connector` | 예 | 손패 정리와 버리기 보상 차단 |
| `spec_card_common_focus_fire_mvp` | 집중 사격 | `budget_cost1_single_basic` | 예 | 약한 단일 목표 표시와 원소 표식 대체 금지 |
| `spec_card_common_emergency_repair_mvp` | 긴급 보수 | `budget_cost1_single_basic` | 예 | 낮은 수리량과 사거리 제한 |
| `spec_card_common_battlefield_cleanup_mvp` | 전장 수습 | `budget_cost1_small_area_instant` | 예 | 파괴 이후 약한 둔화와 회수 가치 없음 |
| `spec_card_common_mana_convert_mvp` | 마나 전환 | `budget_cost0_connector` | 예 | 버리기 기반 제한 마나와 루프 방지 |
| `spec_card_common_quick_hands_mvp` | 빠른 손놀림 | `budget_cost0_connector` | 예 | 순수 드로우가 아닌 손패 정리 |
| `spec_card_common_tactical_map_mvp` | 전술 지도 | `budget_cost1_single_basic` | 예 | 정보 카드와 정답 추천 금지 |
| `spec_card_common_temporary_turret_mvp` | 임시 포탑 | `budget_cost1_single_basic` | 예 | 약한 임시 공격 구조물과 회수 가치 없음 |
| `spec_card_guardian_narrow_anchor_mvp` | 좁은 닻 | `budget_cost1_single_basic` | 예 | 좁은 도발 반경과 높은 구조물 체력 |
| `spec_card_guardian_delayed_shield_mvp` | 늦은 방패 | `budget_cost1_single_basic` | 예 | 1초 예고 방어와 즉시 대응 약점 |
| `spec_card_guardian_brittle_barb_mvp` | 부서질 가시 | `budget_cost1_single_basic` | 예 | 낮은 체력 도발 구조물 반사와 최대 체력 대가 |
| `spec_card_architect_splinter_barricade_mvp` | 파편 바리케이드 | `budget_cost1_single_basic` | 예 | 파괴 후 잔해와 회수 가치 제외 |
| `spec_card_architect_blueprint_scrap_mvp` | 설계도 조각 | `budget_cost1_single_basic` | 예 | 파괴 기록을 다음 설치 준비로 전환 |
| `spec_card_architect_patient_charge_mvp` | 기다리는 폭약 | `budget_cost1_single_basic` | 예 | 오래 버틴 구조물 폭발 보너스 |
| `spec_card_elementalist_slow_bloom_mvp` | 느린 불꽃 | `budget_cost1_small_area_instant` | 예 | 긴 예고와 넓은 약한 지속 피해 지대 |
| `spec_card_elementalist_cracking_ice_mvp` | 갈라지는 얼음 | `budget_cost1_small_area_instant` | 예 | 짧은 빙결과 종료 취약 창 |
| `spec_card_elementalist_crosswind_mvp` | 가로바람 | `budget_cost1_single_basic` | 예 | 경로 안 적 재정렬과 비활성 방향 이동 금지 |
| `spec_card_tinkerer_patch_queue_mvp` | 수리 대기열 | `budget_cost1_global_support` | 예 | 낮은 즉시 회복과 예약 회복 소멸 |
| `spec_card_tinkerer_guarded_overdrive_mvp` | 보호 과부하 | `budget_cost0_risky_boost` | 예 | 낮은 공격 속도 보너스와 고정 후유 피해 |
| `spec_card_tinkerer_lean_field_amp_mvp` | 좁은 증폭장 | `budget_cost1_aura_device` | 예 | 좁은 오라 집중과 밀집 붕괴 위험 |

스펙 프로필 제작 시 모든 항목은 비용, 대상, 범위, 지속, 예고, 반복 제한, 보스 정책, UI 미리보기를 함께 채워야 합니다.

`free_action`, `global_target`, `hard_cc`, `resource_positive`, `path_cost_change`가 붙은 카드는 제작 리뷰에서 우선 확인합니다.

### MVP 카드 수치 예산 잠금 제작표

아래 항목은 카드 스펙 프로필이 비용, 범위, 지속, 반복 제한의 기준을 넘지 않는지 검수하는 제작 단위입니다.

| ID | 연결 예산 | MVP | 역할 |
| --- | --- | --- | --- |
| `stat_budget_connector_0` | `budget_cost0_connector` | 예 | 0비용 연결 카드의 순수 자원 증가 금지 |
| `stat_budget_risky_boost_0` | `budget_cost0_risky_boost` | 예 | 0비용 위험 가속 카드의 구조물 피해/드로우 손실 대가 확인 |
| `stat_budget_basic_1` | `budget_cost1_single_basic`, `budget_cost1_small_area_instant` | 예 | 1비용 기본 행동의 작은 범위와 실패 가능성 확인 |
| `stat_budget_flexible_1` | `budget_cost1_global_support`, `budget_cost1_aura_device` | 예 | 원격/전장 전체 편의 카드와 오라 장치의 낮은 수치, 반복 보정, 중첩 상한 확인 |
| `stat_budget_tactical_2` | `budget_cost2_tactical_shift` | 예 | 중간 범위, 경로 조정, 전술 버프의 예고/중첩 제한 확인 |
| `stat_budget_crisis_3` | `budget_cost3_crisis_answer`, `budget_cost3_engine_commitment` | 예 | 큰 위기 대응 카드의 예고, 후유증, 웨이브 제한 확인 |
| `stat_budget_commit_4` | `budget_cost4_commitment` | 예 | 결전 카드의 선행 조건과 실패 손해 확인 |
| `stat_budget_curse` | `budget_cost0_risky_boost`, `budget_cost1_risky_focus` | 예 | 저주 계약 카드의 명시 확인, 장기 대가, 제거/안정화 연결 확인 |

### MVP 카드 예산 배정 제작표

카드 스펙 제작자는 `effectBudgetId`와 `statBudgetLockId`를 둘 다 채웁니다.

`effectBudgetId`는 카드의 실제 효과 모양이고, `statBudgetLockId`는 어떤 수치 안전장치로 검수할지 정하는 값입니다.

| `effectBudgetId` | 기본 `statBudgetLockId` | 대표 Spec ID | 필수 확인 |
| --- | --- | --- | --- |
| `budget_cost0_connector` | `stat_budget_connector_0` | `spec_card_common_quick_hands_mvp` | 순수 드로우/마나 순증가 없음 |
| `budget_cost0_risky_boost` | `stat_budget_risky_boost_0` | `spec_card_tinkerer_overdrive_mvp` | 구조물 피해, 드로우 손실, 회수 가치 제외 중 1개 이상 |
| `budget_cost1_single_basic` | `stat_budget_basic_1` | `spec_card_guardian_taunt_wall_mvp` | 단일 대상, 작은 수치, 실패 피드백 |
| `budget_cost1_small_area_instant` | `stat_budget_basic_1` | `spec_card_elementalist_fireball_mvp` | 반경 1.5 기준, 낮은 보스 배율 |
| `budget_cost1_global_support` | `stat_budget_flexible_1` | `spec_card_tinkerer_remote_repair_mvp` | 낮은 수치, 반복 효율 감소, 대상 조건 |
| `budget_cost1_aura_device` | `stat_budget_flexible_1` | `spec_card_tinkerer_amplifier_mvp` | 오라 중첩 상한, 장치 위치 위험 |
| `budget_cost1_risky_focus` | `stat_budget_curse` | `spec_card_elementalist_forbidden_lantern_mvp` | 명시 계약/저주 확인, 장기 대가 |
| `budget_cost2_tactical_shift` | `stat_budget_tactical_2` | `spec_card_guardian_binding_oath_mvp` | 예고, 중첩 제한, 보스 약화 변환 |
| `budget_cost3_crisis_answer` | `stat_budget_crisis_3` | `spec_card_elementalist_big_blast_mvp` | 1초 이상 예고, 후유증, 웨이브 제한 |
| `budget_cost3_engine_commitment` | `stat_budget_crisis_3` | `spec_card_tinkerer_resonance_amp_mvp` | 네트워크 상한, 밀집 붕괴 위험 |
| `budget_cost4_commitment` | `stat_budget_commit_4` | `spec_card_guardian_unbroken_gate_mvp` | 영웅 게이트, 큰 실패 손해 |

예산 배정 검수:

- 모든 `spec_card_*_mvp`는 `effectBudgetId`와 `statBudgetLockId`를 함께 가져야 합니다.
- `budget_cost1_aura_device`가 `stat_budget_basic_1`로 들어가면 반려합니다.
- `budget_cost1_risky_focus`가 일반 라운드 랜덤 보상 카드에 쓰이면 반려합니다.
- 저주 카드가 `budget_cost0_risky_boost`를 쓰더라도 명시 계약이 있으면 `stat_budget_curse`로 검수합니다.
- 예산 배정은 솔로 보정, 웨이브 겹치기, 클리어 시간, 처치 수로 완화하지 않습니다.

제작 검수 항목:

- 비용 0 카드가 피해, 수리, 순수 드로우, 마나 순증가를 만들지 않는가?
- 비용 1 카드가 반경 1.5타일 또는 단일 대상 기준을 넘을 때 대가를 갖는가?
- 원격/전장 전체 카드는 낮은 수치, 반복 효율 감소, 대상 조건 중 2개 이상을 갖는가?
- 비용 3 이상 큰 광역은 1초 이상 예고, 웨이브 제한, 보스 본체 약화 정책 중 2개 이상을 갖는가?
- 공용 카드가 직업 전용 강점 예산을 같은 강도로 쓰지 않는가?

### 전리품 변형 카드 제작표

전리품 변형 카드는 기존 카드의 강화판이 아니라, 전리품 풀에 들어가는 별도 카드입니다.

MVP 변형 카드는 기본적으로 추가 강화 후보를 갖지 않고, 원래 카드 후보 3장 규칙 안에서만 등장합니다.

| ID | 기준 카드 | 희귀도 | MVP | 제작 의도 |
| --- | --- | --- | --- | --- |
| `card_guardian_narrow_anchor` | `card_guardian_taunt_wall` | 일반 | 예 | 좁은 도발과 긴 생존으로 전면 유지 판단을 바꿈 |
| `card_guardian_delayed_shield` | `card_guardian_shield_wrap` | 희귀 | 예 | 즉시 방어 대신 예고 피해 예측을 요구 |
| `card_guardian_brittle_barb` | `card_guardian_thorn_growth` | 희귀 | 예 | 치명 상태 구조물의 반사 피해를 키우되 수리 부담 유지 |
| `card_architect_splinter_barricade` | `card_architect_barricade` | 일반 | 예 | 오래 버티는 벽보다 부서진 뒤 잔해를 남기는 벽 |
| `card_architect_blueprint_scrap` | `card_architect_salvage_work` | 희귀 | 예 | 마나 회수 대신 다음 설치 준비로 변환 |
| `card_architect_patient_charge` | `card_architect_debris_blast` | 희귀 | 예 | 오래 버틴 구조물 폭발을 보상하되 즉시 폭파 가치는 낮춤 |
| `card_elementalist_slow_bloom` | `card_elementalist_fireball` | 일반 | 예 | 즉발 피해보다 예고된 넓은 킬존 화염 |
| `card_elementalist_cracking_ice` | `card_elementalist_frost_zone` | 희귀 | 예 | 긴 빙결 대신 종료 취약 창을 만듦 |
| `card_elementalist_crosswind` | `card_elementalist_pushback` | 희귀 | 예 | 경로 안에서 적 위치를 재정렬하는 약한 제어 |
| `card_tinkerer_patch_queue` | `card_tinkerer_remote_repair` | 일반 | 예 | 즉시 대량 수리 대신 짧은 예약 수리 |
| `card_tinkerer_guarded_overdrive` | `card_tinkerer_overdrive` | 희귀 | 예 | 낮은 과부하와 예측 가능한 후유 피해 |
| `card_tinkerer_lean_field_amp` | `card_tinkerer_amplifier` | 희귀 | 예 | 좁은 오라 집중과 밀집 붕괴 위험 |

MVP 변형 카드 수치 검수표:

| ID | Spec ID | 비용 | 핵심 수치 | 필수 제한 |
| --- | --- | ---: | --- | --- |
| `card_guardian_narrow_anchor` | `spec_card_guardian_narrow_anchor_mvp` | 1 | 도발 반경 1.25, 체력 +4 | 한 전선 동시 2개, 경로 검사 |
| `card_guardian_delayed_shield` | `spec_card_guardian_delayed_shield_mvp` | 1 | 1초 뒤 피해 감소 50%, 첫 큰 피해 추가 15% | 같은 구조물 8초 제한 |
| `card_guardian_brittle_barb` | `spec_card_guardian_brittle_barb_mvp` | 1 | 피해 40% 반사, 10회 상한 | 체력 60% 이하 도발 구조물, 최대 체력 -2 |
| `card_architect_splinter_barricade` | `spec_card_architect_splinter_barricade_mvp` | 1 | 파괴 후 잔해 둔화 20%, 4초 | 회수 가치 제외, 완전 길막 금지 |
| `card_architect_blueprint_scrap` | `spec_card_architect_blueprint_scrap_mvp` | 1 | 다음 설치 비용 -1, 체력 +2 | 유효 파괴 기록 1개, 웨이브당 1회 |
| `card_architect_patient_charge` | `spec_card_architect_patient_charge_mvp` | 1 | 폭발 피해 2, 8초 이상 생존 시 +2 | 시전당 1회, 즉시 파괴 보너스 없음 |
| `card_elementalist_slow_bloom` | `spec_card_elementalist_slow_bloom_mvp` | 1 | 반경 2, 즉발 1, 초당 1, 3초 | 0.9초 예고, 동시 지대 1개 |
| `card_elementalist_cracking_ice` | `spec_card_elementalist_cracking_ice_mvp` | 1 | 빙결 0.8초, 취약 15% 2초 | 반복 저항, 보스 약화 변환 |
| `card_elementalist_crosswind` | `spec_card_elementalist_crosswind_mvp` | 1 | 경로 안 재정렬 0.75타일, 둔화 15% 1.5초 | 경로 밖/기지 안쪽/비활성 방향 이동 금지 |
| `card_tinkerer_patch_queue` | `spec_card_tinkerer_patch_queue_mvp` | 1 | 즉시 2, 예약 2x2회 | 파괴 시 예약 회복 소멸, 반복 수리 효율 |
| `card_tinkerer_guarded_overdrive` | `spec_card_tinkerer_guarded_overdrive_mvp` | 0 | 공격 속도 +35%, 종료 피해 3 | 체력 30% 미만 대상 불가, 웨이브당 1회 |
| `card_tinkerer_lean_field_amp` | `spec_card_tinkerer_lean_field_amp_mvp` | 1 | 오라 반경 1.25, 중심 공격 속도 +25% | 체력 -2, 광역 피해 취약 +15%, 중첩 상한 |

변형 카드 제작 검수:

- 모든 변형 카드는 `CardVariantProfile`과 별도 `CardSpecProfile`을 가져야 합니다.
- 변형 카드는 기준 카드의 `upgradeOptions`를 자동 상속하지 않습니다.
- MVP 변형 카드의 `upgradeOptions`는 빈 배열을 기본값으로 둡니다.
- 변형 카드 문구에는 `강화`, `상급`, `+1` 같은 등급 표현을 쓰지 않습니다.
- 아티팩트가 변형 풀을 열어도 후보 수, 희귀도, 골드 총량은 바뀌지 않습니다.
- 변형 카드는 솔로 동쪽 전선 안에서도 사용 판단이 살아 있어야 합니다.

### 전리품 변형 보상 UI 제작표

전리품 변형 보상 UI는 카드 내용을 새로 만드는 표가 아니라, 이미 생성된 변형 후보가 보상 화면에서 어떻게 읽히는지 잠그는 제작표입니다.

| ID | 제작물 | 필수 요소 | 금지 요소 |
| --- | --- | --- | --- |
| `reward_variant_candidate_card_frame` | 후보 카드 프레임 | 일반 후보와 같은 크기, `변형 카드` 보조 배지, 희귀도 동일 위치 | 네 번째 후보, 보너스 슬롯, 강화 전용 프레임 |
| `reward_variant_base_line` | 기준 카드 줄 | `기준 카드: {cardName}` | `{cardName} 강화`, `{cardName} 업그레이드` |
| `reward_variant_delta_chips` | 카드 하단 칩 | 달라진 점, 남는 약점, 등장 이유 | 상승 화살표, 추천 등급, 순수 상위호환 문구 |
| `reward_variant_compare_drawer` | 상세 패널 | 기준 효과 1줄, 변형 효과 1줄, 대가 1줄 | 상점 가격, 파티 투표, 강화 후보 목록 |
| `reward_variant_pick_animation` | 선택 연출 | 새 카드 1장이 덱에 들어감 | 기존 카드 위에 덮어쓰기, 교체 화살표 |
| `reward_variant_temp_lock_badge` | 임시 선택 배지 | 새 카드 임시 선택, 되돌리기 마감 | 위험 대가 변형 자동 선택, 저주 자동 선택 |

검수 체크:

- 한 보상 팩의 카드 후보 슬롯은 항상 3장입니다.
- 변형 배지는 희귀도 보석보다 강하게 보이면 안 됩니다.
- 기준 카드 보유 수를 표시하더라도 대상 지정 프레임이나 연결선은 쓰지 않습니다.
- 변형 후보 표면은 상점 강화 화면의 색, 아이콘, 가격표를 재사용하지 않습니다.
- `RewardCandidatePresentationProfile.forbiddenVisualTags`에 걸린 요소가 아트/UX 시안에 있으면 반려합니다.

### 카드 강화 옵션 제작표

카드 강화는 카드의 수치 등급을 올리는 표가 아니라, 이미 고른 카드의 사용 타이밍과 아키타입 방향을 선명하게 만드는 제작 항목입니다.

| ID | 유형 | MVP | 역할 |
| --- | --- | --- | --- |
| `upgrade_type_stabilize` | 안정 강화 | 예 | 실패 손해와 대상 선택 부담을 줄임 |
| `upgrade_type_specialize` | 특화 강화 | 예 | 특정 타이밍에서 강해지는 대신 조건이나 대가를 추가 |
| `upgrade_type_pivot` | 전환 강화 | 예 | 보조 아키타입 하나를 약하게 지원 |
| `upgrade_type_curse_stabilize` | 저주 안정화 | 예 | 저주의 대가를 제거하지 않고 예측 가능하게 바꿈 |
| `upgrade_type_heroic_tune` | 확정 조율 | 예 | 준비된 영웅 카드의 빌드 마무리 |
| `upgrade_slot_common_2choice` | 강화 후보 슬롯 | 예 | 일반/시작 카드는 최대 2개 후보만 표시 |
| `upgrade_slot_rare_2choice` | 강화 후보 슬롯 | 예 | 희귀 카드는 안정/특화/전환 중 최대 2개 후보만 표시 |
| `upgrade_slot_heroic_limited` | 강화 후보 슬롯 | 예 | 영웅 카드는 게이트 조건이 있는 확정 조율만 표시 |
| `upgrade_slot_curse_stabilize` | 강화 후보 슬롯 | 예 | 저주는 안정화 또는 제거와 경쟁 |
| `curse_service_policy_mvp_common` | 저주 처리 정책 | 예 | 안정화/제거 타이밍, 가격, 할인, 금지선을 고정 |
| `curse_service_offer` | 상점 데이터 | 예 | 특정 저주 1장의 안정화, 제거, 보류 제안을 묶음 |
| `curse_service_compare_row` | 상점 UI | 예 | 저주 안정화와 제거를 같은 행에서 비교 |
| `curse_service_owner_confirm` | 개인 확인 | 예 | 저주 소유자가 안정화, 제거, 보류 중 먼저 선택 |
| `curse_service_party_vote` | 파티 투표 | 예 | 안정화/제거 확정 시 파티 골드 사용을 확인 |
| `curse_discount_reservation` | 할인 상태 | 예 | 25일 조용한 계약서의 -10 예약 할인과 만료 처리 |

### MVP 강화 옵션 예시

| ID | 대상 카드 | 유형 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `upgrade_taunt_wall_sturdy_front` | 도발벽 | 안정 강화 | 예 | 체력과 설치 피드백 보강 |
| `upgrade_taunt_wall_wide_taunt` | 도발벽 | 특화 강화 | 예 | 도발 범위 증가와 수리 부담 증가 |
| `upgrade_debris_blast_clear_warning` | 잔해 폭발 | 안정 강화 | 예 | 폭발 예고와 범위 표시 보강 |
| `upgrade_debris_blast_long_fuse` | 잔해 폭발 | 특화 강화 | 예 | 오래 버틴 구조물 폭발 보상 |
| `upgrade_fireball_clean_aim` | 화염구 | 안정 강화 | 예 | 조준 실패 감소 |
| `upgrade_fireball_killzone_burn` | 화염구 | 특화 강화 | 예 | 킬존 체류 적에게 추가 가치 |
| `upgrade_remote_repair_crisis_pick` | 원격 수리 | 안정 강화 | 예 | 치명 상태 구조물 선택 편의 |
| `upgrade_remote_repair_aura_focus` | 원격 수리 | 전환 강화 | 예 | 오라 안 수리 강화, 오라 밖 수리 약화 |
| `upgrade_overdrive_fail_safe` | 과부하 | 안정 강화 | 예 | 종료 피해 예고와 실패 손해 가독성 보강 |
| `upgrade_overdrive_execution` | 과부하 | 특화 강화 | 예 | 우선 대상 처치 시 대가 일부 완화 |
| `upgrade_thorn_growth_bloodless_barb` | 가시 성장 | 특화 강화 | 예 | 반사 피해 비율 증가와 발동 상한 감소 |
| `upgrade_last_gate_clear_aftershock` | 최후의 문 | 안정 강화 | 예 | 종료 예고와 후유증 표시 보강 |
| `upgrade_front_swap_path_preview` | 전열 교대 | 안정 강화 | 예 | 이동 전후 경로선 비교 |
| `upgrade_unbroken_gate_part_vow` | 불굴의 성문 | 확정 조율 | 예 | 보스 부위 취약 시간 보강과 선행 카드 조건 |
| `upgrade_barricade_clear_route` | 바리케이드 | 안정 강화 | 예 | 우회 경로와 예상 추가 이동 시간 표시 |
| `upgrade_barricade_splinter_frame` | 바리케이드 | 특화 강화 | 예 | 파괴 후 잔해 지속 증가와 체력 대가 |
| `upgrade_salvage_work_clean_records` | 회수 작업 | 안정 강화 | 예 | 유효/제외 파괴 기록 UI 구분 |
| `upgrade_chain_collapse_staged_fall` | 연쇄 붕괴 | 확정 조율 | 예 | 붕괴 연쇄 예고와 선행 카드 조건 |
| `upgrade_frost_zone_clear_resist` | 빙결 지대 | 안정 강화 | 예 | 반복 저항과 남은 둔화 시간 표시 |
| `upgrade_chain_lightning_cluster_rule` | 번개 연결 | 안정 강화 | 예 | 튕김 후보 시전 전 표시 |
| `upgrade_elemental_rift_part_focus` | 원소 균열 | 전환 강화 | 예 | 보스 부위 집중 강화와 일반 광역 취약 대가 |
| `upgrade_storm_ritual_numbered_strikes` | 낙뢰 의식 | 확정 조율 | 예 | 낙뢰 순서 표시와 선행 카드 조건 |
| `upgrade_amplifier_safe_spacing` | 증폭기 | 안정 강화 | 예 | 오라 범위와 밀집 위험 표시 |
| `upgrade_resonance_amp_limited_network` | 공명 증폭기 | 확정 조율 | 예 | 오라 공유 연결선과 선행 카드 조건 |
| `upgrade_reorganize_confirm_discard` | 재정비 | 안정 강화 | 예 | 버리기 확인과 실수 취소 |
| `upgrade_focus_fire_part_ping` | 집중 사격 | 안정 강화 | 예 | 표식 대상 핑과 남은 시간 표시 |
| `upgrade_tactical_map_role_clarity` | 전술 지도 | 안정 강화 | 예 | 적 역할 설명과 첫 압박 타이밍 표시 |
| `upgrade_temporary_turret_cleanup` | 임시 포탑 | 안정 강화 | 예 | 사라지기 전 예고와 위치 표시 |

### MVP 저주 안정화 제작표

| ID | 대상 저주 | 안정화 내용 | 남는 대가 |
| --- | --- | --- | --- |
| `upgrade_heavy_vow_scheduled_draw_loss` | `card_guardian_heavy_vow` | 다음 드로우 손실과 피해 증가 대상을 예약 표시 | 드로우 손실, 구조물 피해 부담 |
| `upgrade_overbuilt_marked_fragility` | `card_architect_overbuilt` | 취약 바리케이드의 붕괴 예고와 회수 제외 표시 강화 | 취약 상태, 회수 보상 제외 |
| `upgrade_forbidden_lantern_fixed_mana_debt` | `card_elementalist_forbidden_lantern` | 일반 처치 마나 감소를 다음 1웨이브 첫 8기로 고정 | 처치 마나 손실 |
| `upgrade_risky_mod_visible_backlash` | `card_tinkerer_risky_mod` | 자해 타이머와 최대 피해 표시 | 지속 중 수리 효율 감소 |

저주 안정화는 카드의 이득을 다시 발동시키지 않고, 저주 태그와 덱 장수 압박을 유지합니다.

### MVP 저주 서비스 제작표

| ID | 제작물 | MVP | 역할 |
| --- | --- | --- | --- |
| `curse_service_offer_active` | 데이터 | 예 | 활성 저주에 안정화, 제거, 보류를 표시 |
| `curse_service_offer_stabilized` | 데이터 | 예 | 안정화된 저주에 제거, 보류만 표시 |
| `curse_service_offer_new_locked` | 데이터 | 예 | 신규 저주는 같은 정비에서 처리 불가로 잠금 |
| `curse_service_compare_row` | UI | 예 | 현재 대가, 안정화 후 대가, 제거 비용, 보류를 한 행에서 비교 |
| `curse_service_discount_badge_025` | UI | 예 | 25일 예약 할인과 상점 종료 시 만료를 표시 |
| `curse_service_owner_first_rule` | 규칙 | 예 | 소유자 확인 전 파티 투표를 열지 않음 |
| `curse_service_purchase_limit_rule` | 규칙 | 예 | 구매 성공 시에만 큰 파티 구매 한도 소모 |
| `curse_service_removal_surcharge_rule` | 가격 | 예 | 제거 성공 시 파티 전체 제거 할증 증가 |
| `telemetry_curse_service_resolved` | 로그 | 예 | 안정화, 제거, 보류, 실패 이유와 가격을 기록 |

## 카드 전리품 풀 제작표

전리품 풀은 시작 덱 밖에서 얻을 수 있는 카드 후보 묶음입니다.

후보 수나 희귀도를 보상으로 올리는 데이터가 아니라, 일자와 획득 경로에 맞는 카드 후보를 고르는 데이터입니다.

각 전리품 풀은 하나의 `CardRarityProfile`을 `rarityProfileId`로 참조하고, 포함 가능한 `CardArchetype` 목록을 함께 가집니다.

| ID | 경로 | 적용 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `loot_pool_round_first_001_004_class` | 일반 라운드 | 1~4일 직업별 | 예 | 시작 덱과 같은 행동을 낮은 비용으로 보강 |
| `loot_pool_round_first_005_010_class` | 일반 라운드 | 5~10일 직업별 | 예 | 파괴, 손패, 첫 보스 준비 카드 제공 |
| `loot_pool_round_spring2_011_020_class` | 일반 라운드 | 11~20일 직업별 | 예 | 첫 아티팩트와 맞는 운영 보완 |
| `loot_pool_round_mvp_021_030_class` | 일반 라운드 | 21~30일 직업별 | 예 | 희귀와 낮은 영웅 비율로 MVP 빌드 확정 |
| `loot_pool_common_soft_gap_mvp` | 일반/보스 | 1~30일 공용 | 예 | 빠진 역할을 약하게 보완하는 공용 8종 |
| `loot_pool_boss_personal_010` | 보스 개인 | 10일 | 예 | 첫 보스에서 확인한 역할을 다음 10일로 연결 |
| `loot_pool_boss_personal_020` | 보스 개인 | 20일 | 예 | 변형 보스에서 드러난 약점을 다음 10일 준비로 연결 |
| `loot_pool_boss_personal_030` | 보스 개인 | 30일 | 예 | 30일 MVP 운영 결과를 덱 확정 또는 거절 선택으로 연결 |
| `loot_pool_shop_day_005_basic` | 상점 | 5일 | 예 | 제거, 강화, 공용 보완 중심의 낮은 희귀도 상점 |
| `loot_pool_shop_day_010_015_card` | 상점 | 10~15일 | 예 | 일반/희귀 카드 구매가 제거, 강화, 회복과 경쟁 |
| `loot_pool_shop_day_020_030_card` | 상점 | 20~30일 | 예 | 일반/희귀 카드 구매만 제공, 영웅은 조율 슬롯으로 분리 |
| `loot_pool_event_contract_mvp` | 이벤트 계약 | 1~30일 | 예 | 저주와 특수 전리품을 명시적 선택으로 제공 |
| `loot_pool_round_winter_space_071_080_class` | 일반 라운드 | 71~79일 직업별 | 아니오 | 좁아진 설치 공간, 후방 킬존, 결빙 이전에 맞는 카드만 제공 |
| `loot_pool_boss_personal_080` | 보스 개인 | 80일 | 아니오 | 결빙과 후방 재건 결과를 역할 태그로 회수 |
| `loot_pool_round_winter_pressure_081_090_class` | 일반 라운드 | 81~89일 직업별 | 아니오 | 압력 타일 밖 보조선, 구조물 이전, 우선 처치 대응 |
| `loot_pool_boss_personal_090` | 보스 개인 | 90일 | 아니오 | 91~100일 약점 보완과 기존 빌드 마무리 |
| `loot_pool_round_final_patch_091_094_class` | 일반 라운드 | 91~94일 직업별 | 아니오 | 빠른 누수, 자원 꼬임, 파괴 후 복구 보완 |
| `loot_pool_shop_final_095_card` | 상점 | 95일 | 아니오 | 새 빌드가 아니라 기존 아키타입 조율, 제거, 마지막 공용 보완 |
| `loot_pool_round_final_closure_096_099_class` | 일반 라운드 | 96~99일 직업별 | 아니오 | 마지막 위치 보정, 기지 위기 대응, 거절 골드 선택 |

### 전리품 희귀도 프로필

| ID | 적용 풀 | 일반 | 희귀 | 영웅 | 저주 | MVP | 금지선 |
| --- | --- | ---: | ---: | ---: | ---: | --- | --- |
| `rarity_profile_round_001_004` | 1~4일 라운드 | 90 | 10 | 0 | 0 | 예 | 복잡한 조건부, 영웅, 저주 금지 |
| `rarity_profile_round_005_010` | 5~10일 라운드 | 80 | 20 | 0 | 0 | 예 | 첫 10일 영웅 일반 보상 금지 |
| `rarity_profile_round_011_020` | 11~20일 라운드 | 70 | 30 | 0 | 0 | 예 | 보스 클리어 보너스식 희귀도 상승 금지 |
| `rarity_profile_round_021_030` | 21~30일 라운드 | 60 | 35 | 5 | 0 | 예 | 영웅 후보 2장 이상 동시 노출 금지 |
| `rarity_profile_boss_personal_010` | 10일 보스 개인 | 75 | 25 | 0 | 0 | 예 | 보스 성과로 희귀도 상승 금지 |
| `rarity_profile_boss_personal_020` | 20일 보스 개인 | 60 | 35 | 5 | 0 | 예 | 영웅은 게이트 조건 충족 시 최대 1장 |
| `rarity_profile_boss_personal_030` | 30일 보스 개인 | 50 | 40 | 10 | 0 | 예 | MVP 결과 보너스처럼 표시 금지 |
| `rarity_profile_shop_card_005` | 5일 상점 카드 슬롯 | 100 | 0 | 0 | 0 | 예 | 영웅 확정 조율 기본 노출 금지 |
| `rarity_profile_shop_card_010_015` | 10~15일 상점 카드 슬롯 | 70 | 30 | 0 | 0 | 예 | 영웅 카드 랜덤 판매 금지 |
| `rarity_profile_shop_card_020_030` | 20~30일 상점 일반 카드 슬롯 | 55 | 45 | 0 | 0 | 예 | 영웅은 `shop_heroic_tune` 슬롯으로만 제공 |
| `rarity_profile_event_contract_mvp` | 이벤트 계약 | 선택형 | 선택형 | 선택형 | 선택형 | 예 | 강제 저주 삽입 금지 |
| `rarity_profile_round_071_080` | 71~79일 라운드 | 50 | 35 | 15 | 0 | 아니오 | 새 아키타입 시작 금지 |
| `rarity_profile_boss_personal_080` | 80일 보스 개인 | 45 | 40 | 15 | 0 | 아니오 | 보스 성과로 희귀도 상승 금지 |
| `rarity_profile_round_081_090` | 81~89일 라운드 | 50 | 35 | 15 | 0 | 아니오 | 압력 타일 삭제권 금지 |
| `rarity_profile_boss_personal_090` | 90일 보스 개인 | 40 | 45 | 15 | 0 | 아니오 | 100일 보스 정답 카드 지급 금지 |
| `rarity_profile_round_091_094` | 91~94일 라운드 | 45 | 40 | 15 | 0 | 아니오 | 게이트 없는 영웅 후보 금지 |
| `rarity_profile_shop_final_095` | 95일 최종 상점 카드 슬롯 | 45 | 40 | 15 | 0 | 아니오 | 영웅 랜덤 판매 금지, 기존 아키타입 조율만 허용 |
| `rarity_profile_round_096_099` | 96~99일 라운드 | 45 | 40 | 15 | 0 | 아니오 | 새 콤보 진입 금지 |

`저주`가 `선택형`인 프로필은 일반 랜덤 후보가 아니라 별도 확인 선택을 사용합니다.

희귀도 프로필은 웨이브 겹치기, 클리어 시간, 처치 수로 바뀌지 않습니다.

### MVP 희귀도 노출 밴드 제작표

희귀도 노출 밴드는 카드 제작자가 "이 구간에 어떤 복잡도의 카드를 열어도 되는가"를 확인하는 표입니다.

런타임 천장이나 보상 보정이 아니며, 후보 수와 희귀도 비율을 바꾸지 않습니다.

| ID | 적용 일자 | 연결 프로필 | 새로 열 수 있는 것 | 금지 |
| --- | --- | --- | --- | --- |
| `rarity_band_mvp_core_001_002` | 1~2일 | `rarity_profile_round_001_004` | 직업 일반 보강, 낮은 복잡도 희귀 신호 | 변형, 영웅, 저주, 새 아키타입 |
| `rarity_band_mvp_response_003_004` | 3~4일 | `rarity_profile_round_001_004` | 빠른 적, 군집, 첫 누수 직접 대응 | 같은 대응 3장, 대가 전환 변형 |
| `rarity_band_mvp_shop_bridge_005` | 5일 | `rarity_profile_round_005_010`, `rarity_profile_shop_card_005` | 덱 상태 카드, 첫 상점과 비교되는 낮은 비용 카드 | 희귀 상점 보상, 영웅 판매 |
| `rarity_band_mvp_boss_prep_006_009` | 6~9일 | `rarity_profile_round_005_010` | 파괴, 잔해, 수리, 손패 보완 희귀 카드 | 겹치기 보상 문구, 보스 정답 카드 |
| `rarity_band_mvp_boss_010` | 10일 | `rarity_profile_boss_personal_010` | 첫 보스 역할 태그 회수 | 부위 파괴 희귀도 보너스 |
| `rarity_band_mvp_artifact_bridge_011_019` | 11~19일 | `rarity_profile_round_011_020` | 첫 아티팩트 연결 희귀 전환, 안전/타이밍 변형 | 일반 라운드 영웅 |
| `rarity_band_mvp_branch_boss_020` | 20일 | `rarity_profile_boss_personal_020` | 지원 크레딧과 전투 증거가 있는 영웅 후보, 변형 보스 약점 회수 | 보스 성과 기반 영웅 증가 |
| `rarity_band_mvp_commit_021_029` | 21~29일 | `rarity_profile_round_021_030` | 기존 아키타입 영웅 확정, 기존 축 변형 | 새 빌드 강제, 저주 랜덤 후보 |
| `rarity_band_mvp_result_030` | 30일 | `rarity_profile_boss_personal_030` | MVP 덱 유지/정리 판단 | 클리어 보너스 희귀도 상승 |

### MVP 카드 풀 단계 잠금 제작표

| ID | 적용 일자 | 허용 풀 | 미루는 풀 |
| --- | --- | --- | --- |
| `pool_stage_mvp_core_001_002` | 1~2일 | 직업 기본 보강, 공용 보완 일부 | 전리품 변형, 영웅, 저주 |
| `pool_stage_mvp_response_003_004` | 3~4일 | 빠른 적, 군집, 첫 누수 대응 | 보스 전용, 확정 빌드 |
| `pool_stage_mvp_shop_bridge_005` | 5일 | 낮은 비용 카드, 덱 상태 보완, 첫 상점 비교 카드 | 희귀 상점 보상, 영웅 판매 |
| `pool_stage_mvp_boss_prep_006_009` | 6~9일 | 파괴, 잔해, 수리 예약, 손패 보완 | 영웅, 새 아키타입 |
| `pool_stage_mvp_artifact_bridge_011_019` | 11~19일 | 아티팩트 연결 희귀 전환, 안전/타이밍 변형 | 일반 라운드 영웅 |
| `pool_stage_mvp_commit_020_030` | 20~30일 | 지원 크레딧과 전투 증거가 있는 영웅, 기존 아키타입 변형 | 새 아키타입 강제, 랜덤 저주 |

### MVP 전리품 희귀도 풀 잠금표

| ID | 연결 프로필 | 후보 수 | 직업 후보 | 공용 보완 | 영웅 제한 | 저주 제한 | 제작 메모 |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| `loot_lock_round_001_004` | `rarity_profile_round_001_004` | 3 | 2~3장 | 0~1장 | 0장 | 없음 | 시작 카드 직접 복제 대신 같은 행동의 낮은 복잡도 변형을 우선 |
| `loot_lock_round_005_010` | `rarity_profile_round_005_010` | 3 | 2~3장 | 0~1장 | 0장 | 없음 | 첫 상점, 구조물 파괴, 보스 부위 준비를 연결 |
| `loot_lock_round_011_020` | `rarity_profile_round_011_020` | 3 | 2~3장 | 0~1장 | 0장 | 없음 | 희귀 전환 카드는 최대 2장, 보스 성과 보정 금지 |
| `loot_lock_round_021_030` | `rarity_profile_round_021_030` | 3 | 2~3장 | 0~1장 | 최대 1장, 선행 2장 필요 | 없음 | 영웅을 빌드 확정 질문으로만 노출 |
| `loot_lock_boss_010` | `rarity_profile_boss_personal_010` | 3 | 2~3장 | 0~1장 | 0장 | 없음 | 보스에서 실제 사용한 역할 태그만 후보 편향 |
| `loot_lock_boss_020` | `rarity_profile_boss_personal_020` | 3 | 2~3장 | 0~1장 | 최대 1장, 선행 2장 필요 | 없음 | 변형 보스 실패 태그를 다음 구간 대응으로 회수 |
| `loot_lock_boss_030` | `rarity_profile_boss_personal_030` | 3 | 2~3장 | 0~1장 | 최대 1장, 선행 2장 필요 | 없음 | MVP 이후 유지할 덱 방향을 묻고 거절 골드를 허용 |
| `loot_lock_shop_card_005` | `rarity_profile_shop_card_005` | 슬롯형 | 0~1장 | 0~1장 | 0장 | 없음 | 공용 보완, 경로 자, 낮은 비용 카드 중 1개만 카드 슬롯으로 노출 |
| `loot_lock_shop_card_010_015` | `rarity_profile_shop_card_010_015` | 슬롯형 | 1~2장 | 0~1장 | 0장 | 없음 | 카드 구매가 카드 제거와 강화보다 항상 우월하지 않게 가격 경쟁 |
| `loot_lock_shop_card_020_030` | `rarity_profile_shop_card_020_030` | 슬롯형 | 1~2장 | 0~1장 | 랜덤 판매 0장 | 계약 슬롯 별도 | 영웅 확정 조율은 상품 슬롯, 전리품 랜덤 후보가 아님 |
| `loot_lock_event_contract_mvp` | `rarity_profile_event_contract_mvp` | 선택형 | 선택지별 | 선택지별 | 명시 선택 | 명시 선택 | 저주와 특수 카드는 확인 UI, 대가 문장, 거절 선택을 함께 표시 |

### 71~100일 전리품 희귀도 풀 잠금표

| ID | 연결 프로필 | 후보 수 | 직업 후보 | 공용 보완 | 영웅 제한 | 저주 제한 | 제작 메모 |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| `loot_lock_round_071_080` | `rarity_profile_round_071_080` | 3 | 2~3장 | 0~1장 | 최대 1장, 기존 축만 | 없음 | 좁은 설치 공간, 결빙 이전, 후방 킬존 대응을 우선 |
| `loot_lock_boss_080` | `rarity_profile_boss_personal_080` | 3 | 2~3장 | 0~1장 | 최대 1장, 기존 축만 | 없음 | 80일 보스에서 확인한 결빙/재건/부위 태그만 후보 편향 |
| `loot_lock_round_081_090` | `rarity_profile_round_081_090` | 3 | 2~3장 | 0~1장 | 최대 1장, 기존 축만 | 없음 | 압력 밖 보조선, 구조물 이전, 우선 처치 카드를 우선 |
| `loot_lock_boss_090` | `rarity_profile_boss_personal_090` | 3 | 2~3장 | 0~1장 | 최대 1장, 선행 아키타입 필요 | 없음 | 최종 10일 약점 보완, 100일 정답 카드 지급 금지 |
| `loot_lock_round_091_094` | `rarity_profile_round_091_094` | 3 | 2~3장 | 0~1장 | 최대 1장, 선행 아키타입 필요 | 없음 | 빠른 누수, 자원 꼬임, 파괴 후 복구 보완 |
| `loot_lock_shop_final_095` | `rarity_profile_shop_final_095` | 슬롯형 | 1~2장 | 0~1장 | 랜덤 판매 0장, 조율 슬롯만 | 계약 신규 금지 | 새 빌드보다 제거, 강화, 기존 축 마무리를 우선 |
| `loot_lock_round_096_099` | `rarity_profile_round_096_099` | 3 | 2~3장 | 0~1장 | 최대 1장, 선행 아키타입 필요 | 없음 | 마지막 위치 보정, 기지 위기 대응, 거절 골드 선택 |
| `loot_lock_boss_100_result` | 없음 | 0 | 없음 | 없음 | 없음 | 없음 | 완료한 런에 영향을 주는 카드 보상 없이 결과 기록과 해금 후보만 표시 |

### 1~30일 전리품 샘플 제작표

이 표는 카드 보상 후보 3장의 제작 의도를 일자별로 고정합니다.

고정 드랍표가 아니며, 모든 행은 후보 수 3장, 해당 일자의 `MvpLootRarityLock`, 골드 거절 값, 활성 방향 투영 규칙을 그대로 유지합니다.

| ID | 일자 | 잠금 | 직접 대응 태그 | 빌드 연결 태그 | 덱 상태 태그 | 금지/후속 |
| --- | ---: | --- | --- | --- | --- | --- |
| `mvp_loot_sample_day_001_first_gap` | 1 | `loot_lock_round_001_004` | `first_leak_patch`, `basic_build_gap` | `starter_loop_repeat` | `low_cost_curve` | 영웅/저주/상점 없음 |
| `mvp_loot_sample_day_002_fast_front` | 2 | `loot_lock_round_001_004` | `runner_delay`, `active_front_only` | `archetype_signal_low_complexity` | `mana_curve_check` | 비활성 방향 후보 금지 |
| `mvp_loot_sample_day_003_cluster_hold` | 3 | `loot_lock_round_001_004` | `cluster_hold`, `small_aoe_or_delay` | `class_control_identity` | `common_soft_gap_max_one` | 같은 대응 3장 금지 |
| `mvp_loot_sample_day_004_first_damage` | 4 | `loot_lock_round_001_004` | `structure_damage_recovery` | `save_or_sacrifice_structure` | `gold_decline_preview` | 보스 전용 정답 금지 |
| `mvp_loot_sample_day_005_first_shop_bridge` | 5 | `loot_lock_round_005_010` | `hand_jam_patch` | `remove_upgrade_recover_compare` | `deck_pressure_notice` | `mvp_shop_lock_day_005` 연결 |
| `mvp_loot_sample_day_006_collapse_intro` | 6 | `loot_lock_round_005_010` | `destructor_hold`, `repair_window` | `debris_or_taunt_bridge` | `dead_card_prevention` | 자동 완전 복구 금지 |
| `mvp_loot_sample_day_007_priority_prep` | 7 | `loot_lock_round_005_010` | `priority_burst`, `long_leak_delay` | `boss_part_focus_prep` | `mana_curve_patch` | 보스 삭제 카드 금지 |
| `mvp_loot_sample_day_008_stack_tempo` | 8 | `loot_lock_round_005_010` | `density_control`, `killzone_hold` | `tempo_recovery_bridge` | `discard_draw_window` | 겹치기 보상 문구 금지 |
| `mvp_loot_sample_day_009_boss_gap` | 9 | `loot_lock_round_005_010` | `last_boss_gap_patch` | `part_focus_or_delay_bridge` | `decline_or_trim_reason` | 보스 정답 카드 금지 |
| `mvp_loot_sample_day_010_boss_foundation` | 10 | `loot_lock_boss_010` | `boss_failure_tag_recall` | `foundation_build_choice` | `first_cleanup_pressure` | `artifact_pool_foundation_010`, 성과 보너스 금지 |
| `mvp_loot_sample_day_011_artifact_mismatch` | 11 | `loot_lock_round_011_020` | `artifact_gap_patch` | `rare_pivot_intro` | `deck_size_16_21_check` | 일반 라운드 영웅 금지 |
| `mvp_loot_sample_day_012_active_route` | 12 | `loot_lock_round_011_020` | `active_route_length_patch` | `artifact_timing_sync` | `common_gap_soft_only` | 비활성 방향 보상 이유 금지 |
| `mvp_loot_sample_day_013_repeat_tag` | 13 | `loot_lock_round_011_020` | `repeat_failure_tag_patch` | `party_or_solo_loop_bridge` | `low_cost_glue` | 같은 아키타입 3장 금지 |
| `mvp_loot_sample_day_014_contract_preview` | 14 | `loot_lock_round_011_020` | `pre_event_weakness_expose` | `strength_or_weakness_signal` | `save_gold_reason` | 계약 강요 금지 |
| `mvp_loot_sample_day_015_contract_shop` | 15 | `loot_lock_round_011_020` | `contract_risk_translation` | `event_shop_choice_bridge` | `small_shop_overbuy_guard` | `event_contract_lock_mvp_015`, 강제 저주 금지 |
| `mvp_loot_sample_day_016_choice_recall` | 16 | `loot_lock_round_011_020` | `choice_consequence_patch` | `artifact_card_fit_check` | `unused_card_visibility` | 미구매 선택 실패 표시 금지 |
| `mvp_loot_sample_day_017_priority_loop` | 17 | `loot_lock_round_011_020` | `fast_leak_or_priority_patch` | `combo_bridge_not_payoff` | `hand_limit_check` | 새 시스템 카드 금지 |
| `mvp_loot_sample_day_018_stack_tempo_recovery` | 18 | `loot_lock_round_011_020` | `density_recovery`, `repair_window` | `pressure_recovery_bridge` | `resource_unjam` | 겹치기 보상 금지 |
| `mvp_loot_sample_day_019_branch_prep` | 19 | `loot_lock_round_011_020` | `pre_variant_boss_gap` | `branch_or_keep_signal` | `trim_or_decline_value` | 확정 영웅 보장 금지 |
| `mvp_loot_sample_day_020_boss_branch` | 20 | `loot_lock_boss_020` | `variant_boss_failure_recall` | `commit_or_cleanup_bridge` | `core_card_ratio_check` | `artifact_pool_branch_020`, 성과 영웅 보너스 금지 |
| `mvp_loot_sample_day_021_commit_entry` | 21 | `loot_lock_round_021_030` | `elite_or_split_patch` | `heroic_gate_if_supported` | `pick_or_decline_normal` | 준비 안 된 영웅 금지 |
| `mvp_loot_sample_day_022_active_split` | 22 | `loot_lock_round_021_030` | `active_direction_role_split` | `class_synergy_position_bridge` | `common_soft_gap_max_one` | 비활성 방향 전용 카드 금지 |
| `mvp_loot_sample_day_023_collapse_pressure` | 23 | `loot_lock_round_021_030` | `collapse_pressure_patch` | `stable_build_with_weakness` | `hand_jam_check` | 만능 공용 대체 금지 |
| `mvp_loot_sample_day_024_transition_prep` | 24 | `loot_lock_round_021_030` | `pre_transition_leak_patch` | `weakness_visibility_keep` | `shop_event_gold_reason` | 보스급 전환 예고 금지 |
| `mvp_loot_sample_day_025_season_turn` | 25 | `loot_lock_round_021_030` | `season_weakness_patch` | `existing_archetype_next_pressure` | `contract_shop_one_focus` | `event_contract_lock_mvp_025`, 대형 보상 금지 |
| `mvp_loot_sample_day_026_speed_patch` | 26 | `loot_lock_round_021_030` | `late_speed_pressure_patch` | `current_build_timing_narrow` | `remove_decline_low_cost` | 새 아키타입 시작 금지 |
| `mvp_loot_sample_day_027_density_priority` | 27 | `loot_lock_round_021_030` | `density_priority_patch` | `heroic_gate_recheck` | `hand_limit_combo_check` | 랜덤 저주 금지 |
| `mvp_loot_sample_day_028_stack_rehearsal` | 28 | `loot_lock_round_021_030` | `high_density_killzone_hold` | `hold_or_rebuild_choice` | `draw_discard_unjam` | 겹치기 보상 증가 금지 |
| `mvp_loot_sample_day_029_final_position` | 29 | `loot_lock_round_021_030` | `final_position_patch` | `boss_part_or_relocation_preview` | `last_decline_trim_value` | 새 적 역할/새 시스템 금지 |
| `mvp_loot_sample_day_030_mvp_result` | 30 | `loot_lock_boss_030` | `observer_result_recall` | `keep_or_cleanup_mvp_build` | `next_run_deck_judgment` | `artifact_pool_mvp_result_030`, 31일 빌드 강제 금지 |

### 1~30일 샘플 카드 라우팅 제작표

`MvpLootSampleCardRouteSet`은 샘플 일자가 실제 카드 ID 후보를 어떤 우선순위로 볼지 고정합니다.

표의 `G/A/E/T`는 수호자, 건축가, 원소술사, 땜장이입니다.

영웅 카드가 들어간 행은 조건 충족 시 `빌드 연결` 레일에서만 쓰며, 게이트 조건이 없으면 같은 행의 일반/희귀 대체 카드로 내려갑니다.

| 라우트 ID | 일자 | 직접 대응 G/A/E/T | 빌드 연결 G/A/E/T | 덱 상태 공용 후보 | 제한 |
| --- | ---: | --- | --- | --- | --- |
| `route_mvp_loot_day_001_first_gap` | 1 | `card_guardian_iron_wall` / `card_architect_double_barricade` / `card_elementalist_fire_ring` / `card_tinkerer_reinforced_screw` | `card_guardian_reflective_oath` / `card_architect_reinforced_blueprint` / `card_elementalist_frost_shard` / `card_tinkerer_lubrication` | `card_common_tactical_map`, `card_common_temporary_turret` | 시작 카드 직접 복제 금지 |
| `route_mvp_loot_day_002_fast_front` | 2 | `card_guardian_crack_shield` / `card_architect_slippery_debris` / `card_elementalist_rewind_gust` / `card_tinkerer_lubrication` | `card_guardian_front_swap` / `card_architect_double_barricade` / `card_elementalist_frost_shard` / `card_tinkerer_preheater` | `card_common_temporary_turret`, `card_common_quick_hands` | 비활성 방향 후보 금지 |
| `route_mvp_loot_day_003_cluster_hold` | 3 | `card_guardian_reflective_oath` / `card_architect_delayed_charge` / `card_elementalist_fire_ring` / `card_tinkerer_preheater` | `card_guardian_crack_shield` / `card_architect_slippery_debris` / `card_elementalist_frost_shard` / `card_tinkerer_lubrication` | `card_common_focus_fire`, `card_common_temporary_turret` | 같은 대응 3장 금지 |
| `route_mvp_loot_day_004_first_damage` | 4 | `card_guardian_iron_wall` / `card_architect_shard_recovery` / `card_elementalist_rewind_gust` / `card_tinkerer_reinforced_screw` | `card_guardian_front_swap` / `card_architect_reinforced_blueprint` / `card_elementalist_frost_shard` / `card_tinkerer_lubrication` | `card_common_emergency_repair`, `card_common_battlefield_cleanup` | 보스 전용 정답 금지 |
| `route_mvp_loot_day_005_first_shop_bridge` | 5 | `card_guardian_last_guard` / `card_architect_shard_recovery` / `card_elementalist_frost_shard` / `card_tinkerer_auto_extinguisher` | `card_guardian_iron_wall` / `card_architect_reinforced_blueprint` / `card_elementalist_fire_ring` / `card_tinkerer_reinforced_screw` | `card_common_reorganize`, `card_common_mana_convert`, `card_common_quick_hands` | 첫 상점 희귀 보상화 금지 |
| `route_mvp_loot_day_006_collapse_intro` | 6 | `card_guardian_iron_wall` / `card_architect_slippery_debris` / `card_elementalist_rewind_gust` / `card_tinkerer_reinforced_screw` | `card_guardian_reflective_oath` / `card_architect_delayed_charge` / `card_elementalist_fire_ring` / `card_tinkerer_auto_extinguisher` | `card_common_emergency_repair`, `card_common_battlefield_cleanup` | 자동 완전 복구 금지 |
| `route_mvp_loot_day_007_priority_prep` | 7 | `card_guardian_crack_shield` / `card_architect_delayed_charge` / `card_elementalist_overcharged_bolt` / `card_tinkerer_lubrication` | `card_guardian_front_swap` / `card_architect_reinforced_blueprint` / `card_elementalist_elemental_rift` / `card_tinkerer_preheater` | `card_common_focus_fire`, `card_common_tactical_map` | 보스 삭제 카드 금지 |
| `route_mvp_loot_day_008_stack_tempo` | 8 | `card_guardian_reflective_oath` / `card_architect_delayed_charge` / `card_elementalist_fire_ring` / `card_tinkerer_preheater` | `card_guardian_crack_shield` / `card_architect_slippery_debris` / `card_elementalist_elemental_rift` / `card_tinkerer_emergency_wiring` | `card_common_quick_hands`, `card_common_mana_convert`, `card_common_reorganize` | 겹치기 보상 문구 금지 |
| `route_mvp_loot_day_009_boss_gap` | 9 | `card_guardian_last_guard` / `card_architect_reinforced_blueprint` / `card_elementalist_frost_shard` / `card_tinkerer_reinforced_screw` | `card_guardian_front_swap` / `card_architect_delayed_charge` / `card_elementalist_overcharged_bolt` / `card_tinkerer_auto_extinguisher` | `card_common_focus_fire`, `card_common_tactical_map`, `card_common_emergency_repair` | 보스 정답 카드 금지 |
| `route_mvp_loot_day_010_boss_foundation` | 10 | `card_guardian_last_guard` / `card_architect_reinforced_blueprint` / `card_elementalist_overcharged_bolt` / `card_tinkerer_auto_extinguisher` | `card_guardian_front_swap` / `card_architect_delayed_charge` / `card_elementalist_elemental_rift` / `card_tinkerer_emergency_wiring` | `card_common_focus_fire`, `card_common_tactical_map`, `card_common_emergency_repair` | 영웅 후보 없음 |
| `route_mvp_loot_day_011_artifact_mismatch` | 11 | `card_guardian_iron_wall` / `card_architect_reinforced_blueprint` / `card_elementalist_fire_ring` / `card_tinkerer_reinforced_screw` | `card_guardian_front_swap` / `card_architect_shard_recovery` / `card_elementalist_elemental_rift` / `card_tinkerer_emergency_wiring` | `card_common_tactical_map`, `card_common_quick_hands` | 일반 라운드 영웅 금지 |
| `route_mvp_loot_day_012_active_route` | 12 | `card_guardian_front_swap` / `card_architect_double_barricade` / `card_elementalist_rewind_gust` / `card_tinkerer_lubrication` | `card_guardian_crack_shield` / `card_architect_reinforced_blueprint` / `card_elementalist_fire_ring` / `card_tinkerer_preheater` | `card_common_tactical_map`, `card_common_temporary_turret` | 비활성 방향 보상 이유 금지 |
| `route_mvp_loot_day_013_repeat_tag` | 13 | `card_guardian_reflective_oath` / `card_architect_slippery_debris` / `card_elementalist_frost_shard` / `card_tinkerer_auto_extinguisher` | `card_guardian_front_swap` / `card_architect_delayed_charge` / `card_elementalist_overcharged_bolt` / `card_tinkerer_emergency_wiring` | `card_common_quick_hands`, `card_common_reorganize` | 같은 아키타입 3장 금지 |
| `route_mvp_loot_day_014_contract_preview` | 14 | `card_guardian_last_guard` / `card_architect_shard_recovery` / `card_elementalist_frost_shard` / `card_tinkerer_reinforced_screw` | `card_guardian_reflective_oath` / `card_architect_reinforced_blueprint` / `card_elementalist_elemental_rift` / `card_tinkerer_emergency_wiring` | `card_common_tactical_map`, `card_common_mana_convert` | 계약 강요 금지 |
| `route_mvp_loot_day_015_contract_shop` | 15 | `card_guardian_last_guard` / `card_architect_shard_recovery` / `card_elementalist_overcharged_bolt` / `card_tinkerer_auto_extinguisher` | `card_guardian_front_swap` / `card_architect_reinforced_blueprint` / `card_elementalist_elemental_rift` / `card_tinkerer_emergency_wiring` | `card_common_reorganize`, `card_common_mana_convert`, `card_common_emergency_repair` | 강제 저주 금지 |
| `route_mvp_loot_day_016_choice_recall` | 16 | `card_guardian_iron_wall` / `card_architect_slippery_debris` / `card_elementalist_fire_ring` / `card_tinkerer_reinforced_screw` | `card_guardian_reflective_oath` / `card_architect_delayed_charge` / `card_elementalist_frost_shard` / `card_tinkerer_preheater` | `card_common_battlefield_cleanup`, `card_common_quick_hands` | 미구매 선택 실패 표시 금지 |
| `route_mvp_loot_day_017_priority_loop` | 17 | `card_guardian_crack_shield` / `card_architect_delayed_charge` / `card_elementalist_overcharged_bolt` / `card_tinkerer_lubrication` | `card_guardian_front_swap` / `card_architect_shard_recovery` / `card_elementalist_elemental_rift` / `card_tinkerer_emergency_wiring` | `card_common_focus_fire`, `card_common_quick_hands` | 새 시스템 카드 금지 |
| `route_mvp_loot_day_018_stack_tempo_recovery` | 18 | `card_guardian_reflective_oath` / `card_architect_delayed_charge` / `card_elementalist_fire_ring` / `card_tinkerer_preheater` | `card_guardian_crack_shield` / `card_architect_slippery_debris` / `card_elementalist_rewind_gust` / `card_tinkerer_emergency_wiring` | `card_common_quick_hands`, `card_common_mana_convert`, `card_common_reorganize` | 겹치기 보상 금지 |
| `route_mvp_loot_day_019_branch_prep` | 19 | `card_guardian_last_guard` / `card_architect_reinforced_blueprint` / `card_elementalist_overcharged_bolt` / `card_tinkerer_auto_extinguisher` | `card_guardian_front_swap` / `card_architect_delayed_charge` / `card_elementalist_elemental_rift` / `card_tinkerer_emergency_wiring` | `card_common_focus_fire`, `card_common_tactical_map` | 확정 영웅 보장 금지 |
| `route_mvp_loot_day_020_boss_branch` | 20 | `card_guardian_last_guard` / `card_architect_reinforced_blueprint` / `card_elementalist_overcharged_bolt` / `card_tinkerer_auto_extinguisher` | `card_guardian_unbroken_gate` / `card_architect_inverted_path` / `card_elementalist_storm_ritual` / `card_tinkerer_reassembly_machine` | `card_common_focus_fire`, `card_common_tactical_map` | 영웅은 게이트 조건 충족 시만 |
| `route_mvp_loot_day_021_commit_entry` | 21 | `card_guardian_crack_shield` / `card_architect_slippery_debris` / `card_elementalist_frost_shard` / `card_tinkerer_lubrication` | `card_guardian_thorn_throne` / `card_architect_chain_collapse` / `card_elementalist_eye_of_stillness` / `card_tinkerer_resonance_amp` | `card_common_focus_fire`, `card_common_quick_hands` | 영웅 게이트 실패 시 하향 |
| `route_mvp_loot_day_022_active_split` | 22 | `card_guardian_front_swap` / `card_architect_double_barricade` / `card_elementalist_rewind_gust` / `card_tinkerer_lubrication` | `card_guardian_unbroken_gate` / `card_architect_inverted_path` / `card_elementalist_elemental_rift` / `card_tinkerer_resonance_amp` | `card_common_tactical_map`, `card_common_temporary_turret` | 비활성 방향 카드 금지 |
| `route_mvp_loot_day_023_collapse_pressure` | 23 | `card_guardian_reflective_oath` / `card_architect_delayed_charge` / `card_elementalist_fire_ring` / `card_tinkerer_reinforced_screw` | `card_guardian_thorn_throne` / `card_architect_chain_collapse` / `card_elementalist_eye_of_stillness` / `card_tinkerer_reassembly_machine` | `card_common_battlefield_cleanup`, `card_common_emergency_repair` | 만능 공용 대체 금지 |
| `route_mvp_loot_day_024_transition_prep` | 24 | `card_guardian_last_guard` / `card_architect_shard_recovery` / `card_elementalist_overcharged_bolt` / `card_tinkerer_auto_extinguisher` | `card_guardian_unbroken_gate` / `card_architect_inverted_path` / `card_elementalist_storm_ritual` / `card_tinkerer_resonance_amp` | `card_common_tactical_map`, `card_common_mana_convert` | 보스급 전환 예고 금지 |
| `route_mvp_loot_day_025_season_turn` | 25 | `card_guardian_front_swap` / `card_architect_reinforced_blueprint` / `card_elementalist_rewind_gust` / `card_tinkerer_emergency_wiring` | `card_guardian_thorn_throne` / `card_architect_chain_collapse` / `card_elementalist_eye_of_stillness` / `card_tinkerer_resonance_amp` | `card_common_reorganize`, `card_common_tactical_map`, `card_common_emergency_repair` | 대형 보상, 새 아티팩트 금지 |
| `route_mvp_loot_day_026_speed_patch` | 26 | `card_guardian_crack_shield` / `card_architect_double_barricade` / `card_elementalist_rewind_gust` / `card_tinkerer_preheater` | `card_guardian_front_swap` / `card_architect_inverted_path` / `card_elementalist_eye_of_stillness` / `card_tinkerer_resonance_amp` | `card_common_temporary_turret`, `card_common_quick_hands` | 새 아키타입 시작 금지 |
| `route_mvp_loot_day_027_density_priority` | 27 | `card_guardian_reflective_oath` / `card_architect_delayed_charge` / `card_elementalist_overcharged_bolt` / `card_tinkerer_lubrication` | `card_guardian_thorn_throne` / `card_architect_chain_collapse` / `card_elementalist_storm_ritual` / `card_tinkerer_resonance_amp` | `card_common_focus_fire`, `card_common_mana_convert` | 랜덤 저주 금지 |
| `route_mvp_loot_day_028_stack_rehearsal` | 28 | `card_guardian_crack_shield` / `card_architect_slippery_debris` / `card_elementalist_fire_ring` / `card_tinkerer_preheater` | `card_guardian_thorn_throne` / `card_architect_chain_collapse` / `card_elementalist_eye_of_stillness` / `card_tinkerer_emergency_wiring` | `card_common_quick_hands`, `card_common_mana_convert`, `card_common_reorganize` | 겹치기 보상 증가 금지 |
| `route_mvp_loot_day_029_final_position` | 29 | `card_guardian_front_swap` / `card_architect_reinforced_blueprint` / `card_elementalist_rewind_gust` / `card_tinkerer_emergency_wiring` | `card_guardian_unbroken_gate` / `card_architect_inverted_path` / `card_elementalist_storm_ritual` / `card_tinkerer_reassembly_machine` | `card_common_tactical_map`, `card_common_focus_fire` | 새 적 역할/새 시스템 금지 |
| `route_mvp_loot_day_030_mvp_result` | 30 | `card_guardian_last_guard` / `card_architect_reinforced_blueprint` / `card_elementalist_overcharged_bolt` / `card_tinkerer_auto_extinguisher` | `card_guardian_unbroken_gate` / `card_architect_inverted_path` / `card_elementalist_storm_ritual` / `card_tinkerer_reassembly_machine` | `card_common_tactical_map`, `card_common_reorganize`, `card_common_focus_fire` | 31일 빌드 강제 금지 |

### 20~30일 영웅 후보 게이트 제작표

`MvpHeroicCommitGate`는 위 라우트 표의 영웅 후보가 실제 보상 화면에 남을지 검사하는 제작 단위입니다.

모든 게이트는 공통으로 `allowedDayRange: [20, 30]`, `requiredSupportCardCount: 2`, `requiredRunChosenSupportCount: 1`, `requiredRecentProofCount: 1`, `recentProofLookbackDays: 5`, `soloProjectionSafe: true`를 사용합니다.

| 게이트 ID | 영웅 카드 | 출처 | 지원 카드 후보 | 최근 전투 증거 | 하향 후보 | UI 대가 태그 |
| --- | --- | --- | --- | --- | --- | --- |
| `heroic_gate_guardian_thorn_throne` | `card_guardian_thorn_throne` | 21~30 라운드, 20~30 `shop_heroic_tune` | `card_guardian_thorn_growth`, `card_guardian_reflective_oath`, `card_guardian_crack_shield`, `card_guardian_iron_wall` | `taunt_anchor_tanked_hits`, `thorn_damage_triggered`, `stack_pressure_hits_on_taunt` | `card_guardian_reflective_oath`, `card_guardian_crack_shield` | `repair_efficiency_down`, `repeat_hit_risk` |
| `heroic_gate_guardian_unbroken_gate` | `card_guardian_unbroken_gate` | 20/30 보스 개인, 21~30 라운드, 20~30 `shop_heroic_tune` | `card_guardian_last_gate`, `card_guardian_front_swap`, `card_guardian_iron_wall`, `card_guardian_binding_oath` | `boss_part_focus_window_created`, `base_critical_hold`, `taunt_anchor_survived` | `card_guardian_last_guard`, `card_guardian_front_swap` | `high_cost`, `boss_pattern_cancel_forbidden` |
| `heroic_gate_architect_chain_collapse` | `card_architect_chain_collapse` | 21~30 라운드, 20~30 `shop_heroic_tune` | `card_architect_debris_blast`, `card_architect_delayed_charge`, `card_architect_slippery_debris`, `card_architect_shard_recovery` | `planned_collapse_resolved`, `destroy_record_spent_correctly`, `swarm_compressed_by_debris` | `card_architect_delayed_charge`, `card_architect_slippery_debris` | `destroy_record_spent`, `salvage_loop_forbidden` |
| `heroic_gate_architect_inverted_path` | `card_architect_inverted_path` | 20/30 보스 개인, 21~30 라운드, 20~30 `shop_heroic_tune` | `card_architect_barricade`, `card_architect_double_barricade`, `card_architect_reinforced_blueprint`, `card_architect_compact_design` | `path_extension_seconds_high`, `maze_preview_used`, `boss_path_cost_read` | `card_architect_reinforced_blueprint`, `card_architect_double_barricade` | `path_check_required`, `complete_block_forbidden` |
| `heroic_gate_elementalist_eye_of_stillness` | `card_elementalist_eye_of_stillness` | 21~30 라운드, 20~30 `shop_heroic_tune` | `card_elementalist_frost_zone`, `card_elementalist_pushback`, `card_elementalist_rewind_gust`, `card_elementalist_frost_shard` | `control_window_prevented_leak`, `stack_pressure_control_used`, `boss_control_weakened_understood` | `card_elementalist_rewind_gust`, `card_elementalist_frost_shard` | `boss_cc_weakened`, `elite_resistance_visible` |
| `heroic_gate_elementalist_storm_ritual` | `card_elementalist_storm_ritual` | 20/30 보스 개인, 21~30 라운드, 20~30 `shop_heroic_tune` | `card_elementalist_mark`, `card_elementalist_overcharged_bolt`, `card_elementalist_elemental_rift`, `card_elementalist_fire_ring` | `marked_target_followed_up`, `boss_part_focus_marked`, `forecast_hit_landed` | `card_elementalist_overcharged_bolt`, `card_elementalist_elemental_rift` | `long_forecast`, `mark_required` |
| `heroic_gate_tinkerer_resonance_amp` | `card_tinkerer_resonance_amp` | 21~30 라운드, 20~30 `shop_heroic_tune` | `card_tinkerer_amplifier`, `card_tinkerer_lubrication`, `card_tinkerer_emergency_wiring`, `card_tinkerer_preheater` | `aura_target_window_used`, `overcluster_risk_survived`, `aura_core_repositioned` | `card_tinkerer_emergency_wiring`, `card_tinkerer_lubrication` | `overcluster_risk`, `aura_core_vulnerable` |
| `heroic_gate_tinkerer_reassembly_machine` | `card_tinkerer_reassembly_machine` | 20/30 보스 개인, 21~30 라운드, 20~30 `shop_heroic_tune` | `card_tinkerer_remote_repair`, `card_tinkerer_spare_parts`, `card_tinkerer_auto_rebuild`, `card_tinkerer_reinforced_screw` | `structure_destroyed_then_recovered`, `repair_window_saved_core`, `rebuild_penalty_understood` | `card_tinkerer_reinforced_screw`, `card_tinkerer_auto_extinguisher` | `rebuild_delay`, `same_tile_rebuild_penalty` |

게이트 실패 이유는 플레이어에게 벌점처럼 보이면 안 됩니다.

UI는 "조건 미달" 대신 "아직 이 운영이 충분히 굴러가지 않았습니다"에 가까운 문장으로 표시하고, 같은 역할의 하향 후보를 자연스럽게 제시합니다.

### 영웅 동등 지원 제작표

`HeroicEquivalentSupportProfile`은 적용 강화나 장착 아티팩트가 영웅 게이트의 지원 카드 조건을 최대 1장만큼 보조할 수 있는지를 정의합니다.

이 표는 영웅 후보를 더 자주 띄우는 보상표가 아닙니다. 실제 덱 카드가 최소 1장 있고, 최근 전투 증거가 있으며, 이미 적용된 강화/장착 아티팩트가 해당 운영을 명확히 보강할 때만 쓰는 검수표입니다.

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `heroic_equivalent_support_profiles` | 데이터 | 예 | 8개 영웅 게이트에 연결되는 24개 강화/아티팩트 지원 태그 정의 |
| `heroic_support_actual_card_required_check` | 판정 | 예 | 실제 덱 지원 카드가 0장이면 동등 지원을 무시 |
| `heroic_support_credit_cap_check` | 판정 | 예 | 한 게이트에서 동등 지원은 강화/아티팩트 합산 최대 1크레딧만 인정 |
| `heroic_support_upgrade_artifact_state_guard` | 판정 | 예 | 적용 해제 강화, 휴면/방출/훈련/임시 아티팩트를 차단 |
| `ui_heroic_support_credit_breakdown` | 보상 UI | 예 | 실제 카드, 강화, 아티팩트가 각각 몇 크레딧으로 계산됐는지 표시 |
| `ui_heroic_support_locked_reason` | 보상 UI | 예 | 실제 카드 부족, 휴면 아티팩트, 증거 부족 등 하향 이유 표시 |
| `heroic_equivalent_support_reward_neutral_guard` | 검수 | 예 | 후보 수, 희귀도, 골드, 보스 파편, 상점 가격, 웨이브 겹치기 보상 변경 금지 |
| `heroic_equivalent_support_solo_projection_check` | 검수 | 예 | 1인 동쪽 전선에서도 동등 지원 조건이 자연스럽게 성립하는지 확인 |

직업별 제작 잠금:

| 영웅 게이트 | 동등 지원 태그 수 | 대표 출처 | 제작 주의점 |
| --- | ---: | --- | --- |
| `heroic_gate_guardian_thorn_throne` | 3 | 가시 상한 강화, 파손 왕관, 넓은 도발 강화 | 실제 피격과 반사 운영 없이 자동 발동만으로 인정하지 않음 |
| `heroic_gate_guardian_unbroken_gate` | 3 | 검은 닻, 전방 교대 미리보기, 최후 방벽 여진 | 보스 본체 정지나 패턴 취소로 번역하지 않음 |
| `heroic_gate_architect_chain_collapse` | 3 | 속삭이는 못, 긴 도화선, 회수 기록 강화 | 파괴 기록과 폭발 가치가 남아야 함 |
| `heroic_gate_architect_inverted_path` | 3 | 낡은 관측 렌즈, 경로 표시 바리케이드 | 완전 길막 성공을 지원으로 인정하지 않음 |
| `heroic_gate_elementalist_eye_of_stillness` | 3 | 예측 제어 렌즈, 냉기 저항 표시, 킬존 점화 | 보스/정예 CC 약화 규칙을 유지 |
| `heroic_gate_elementalist_storm_ritual` | 3 | 검은 닻, 부위 집중 균열, 표식 핑 | 자동 추적 낙뢰나 처치 보상 증가 금지 |
| `heroic_gate_tinkerer_resonance_amp` | 3 | 과열 증폭 코어, 수리 오라, 안전 간격 강화 | 전역 버프가 아니라 배치 밀도와 위험을 읽어야 함 |
| `heroic_gate_tinkerer_reassembly_machine` | 3 | 금 간 종, 위기 수리, 과부하 안전장치 | 무료 재건이나 파괴 보상 루프로 이어지면 안 됨 |

### 영웅 게이트 UI 제작표

영웅 게이트 UI는 보상 화면, 카드 상세, 상점 조율 패널이 같은 판정 결과를 같은 말로 보여주게 만드는 제작 단위입니다.

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `heroic_gate_presentation_profiles` | 데이터 | 예 | 8개 MVP 영웅 게이트의 표시 상태, 배지, 상세 행, 잠금 이유를 정의 |
| `ui_reward_heroic_ready_badge` | 보상 UI | 예 | 통과한 영웅 후보에 `준비된 운영` 배지를 작게 표시 |
| `ui_reward_heroic_detail_rows` | 보상 UI | 예 | 지원 카드, 동등 지원, 최근 증거, 남는 대가 4줄 표시 |
| `ui_reward_heroic_downgrade_chip` | 보상 UI | 예 | 하향 후보 펼침 하단에 이유 칩 1개 표시 |
| `ui_shop_heroic_owner_confirm` | 상점 UI | 예 | 대상 플레이어가 먼저 받을지 보류할지 결정 |
| `ui_shop_heroic_party_vote` | 상점 UI | 예 | 대상 수락 후 파티 골드/보스 파편 투표 표시 |
| `ui_shop_heroic_compare_drawer_limited` | 상점 UI | 예 | 게이트 통과 후보가 여러 개일 때 최대 2개만 비교 |
| `copy_heroic_gate_ui_keys` | 문구 | 예 | `ui.reward.heroic_*`, `ui.shop.heroic_*` 키와 금지 태그 제작 |
| `heroic_gate_ui_forbidden_visual_guard` | 검수 | 예 | 큰 광채, 추천 왕관, 강화 화살표, 보상 가격표, 겹치기 광채 금지 |
| `heroic_gate_ui_solo_projection_guard` | 검수 | 예 | 솔로에서 북/서/남 증거 부족 문구가 나오지 않게 차단 |

상태별 제작 기준:

| 상태 | 보상 화면 | 상점 화면 | 검수 포인트 |
| --- | --- | --- | --- |
| 게이트 미통과 | 하향 후보만 표시 | 무료 조건 요약만 가능 | 잠긴 영웅 카드를 후보 슬롯에 남기지 않음 |
| 게이트 통과 | 영웅 후보 1장 이하 | 대상 수락 대기 | 큰 추천 연출 없음 |
| 파편 부족 | 보상에는 영향 없음 | 구매 버튼 없는 정보 패널 | 파편 부족을 벌점처럼 표시하지 않음 |
| 대상 보류 | 보상에는 영향 없음 | 구매 없음으로 상점 복귀 | 파티가 강제로 투표하지 않음 |
| 파티 투표 반대/시간 초과 | 보상에는 영향 없음 | 구매 없음 | 다음 후보 수/가격/희귀도 보정 없음 |

### 영웅 증거 태그 제작표

영웅 증거 태그는 전투 리포트에서 생성되고, 보상 후보와 `shop_heroic_tune`이 읽습니다.

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `combat_report_heroic_proof_tag_profiles` | 데이터 | 예 | 24개 MVP 영웅 증거 태그와 생성 조건 정의 |
| `combat_report_heroic_proof_event` | 전투 로그 | 예 | 플레이어, 직업, 활성 방향, 위치, 출처 카드/구조물, 영향값 기록 |
| `ui_combat_report_heroic_proof_chip` | 리포트 UI | 예 | "이 운영이 실제로 굴러감"을 짧은 태그로 표시 |
| `ui_heroic_gate_recent_proof_reason` | 보상 UI | 예 | 영웅 후보가 열린 이유나 내려간 이유를 최근 증거 태그로 설명 |
| `ui_shop_heroic_proof_summary` | 상점 UI | 예 | 영웅 조율 패널에 최근 5일 증거 요약 표시 |
| `heroic_proof_solo_projection_check` | 검수 | 예 | 모든 증거 태그가 1인 동쪽 전선에서 생성 가능한지 확인 |
| `heroic_proof_inactive_direction_guard` | 검수 | 예 | 비활성 방향 사건이 증거 태그로 기록되지 않도록 차단 |
| `heroic_proof_wave_stack_neutral_guard` | 검수 | 예 | 겹치기 여부가 태그 요구량, 보상, 가격, 후보 수를 바꾸지 않도록 확인 |

증거 태그 제작 금지선:

- 카드를 냈다는 사실만으로 증거 태그를 만들지 않습니다.
- 자동 아티팩트 발동만으로 증거 태그를 만들지 않습니다.
- 비활성 방향 사건은 증거 태그가 될 수 없습니다.
- 한 전투 리포트는 플레이어당 영웅 증거 태그를 최대 2개까지만 표시합니다.
- 같은 영웅 게이트에는 한 전투 리포트당 1개 증거만 계산합니다.
- 증거 태그는 보상, 골드, 카드 후보 수, 희귀도, 보스 파편, 상점 가격을 바꾸지 않습니다.

### 20~30일 영웅 카드 효과 잠금 제작표

`MvpHeroicCardSpecLock`은 영웅 게이트를 통과한 후보가 실제 전투에서 어느 수치와 상한으로 작동하는지 고정합니다.

영웅 효과는 강하지만 길게 남는 대가를 반드시 가집니다.

| 효과 잠금 ID | 카드 | 비용 | 대상/범위 | 발동/지속 | 효과 | 상한/대가 | 보스 정책 |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| `heroic_spec_lock_guardian_thorn_throne_mvp` | `card_guardian_thorn_throne` | 3 | 모든 아군 도발 구조물 | 1초 예고/웨이브 종료까지 | 받은 피해의 20% 반사, 기존 가시 +10%p | 수리 효율 -30%, 총 반사 60회, 실제 피격 필요 | 보스 본체 직접 피해 없음, 실제 피격 반사만 허용 |
| `heroic_spec_lock_guardian_unbroken_gate_mvp` | `card_guardian_unbroken_gate` | 4 | 빈 설치 타일, 6타일 | 1초 예고/영구 구조물 | 체력 24, 도발 반경 2.5타일, 파괴 시 일반 적 1.2초 행동 중단 | 공격 없음, 웨이브당 1회, 위치 실패 손해 | 정예 0.4초, 보스 본체 정지 없음, 보스 부위 취약 3초 |
| `heroic_spec_lock_architect_chain_collapse_mvp` | `card_architect_chain_collapse` | 3 | 자기 구조물 폭발 규칙 | 1초 예고/웨이브 종료까지 | 다음 3회 폭발 피해 +2, 4타일 안 연쇄 폭발이면 +1 추가 | 총 추가 피해 18, 같은 구조물 반복 폭발 불가 | 보스 본체 30%, 보스 부위 50%, 패턴 취소 없음 |
| `heroic_spec_lock_architect_inverted_path_mvp` | `card_architect_inverted_path` | 3 | 활성 전선 경로 5타일 | 1초 예고/6초 | 경로 비용 +4, 구간 내 적 이동 속도 -20% | 완전 길막 금지, 전후 경로 검사 필수 | 보스 본체 경로 비용 +1.5, 정지 없음 |
| `heroic_spec_lock_elementalist_eye_of_stillness_mvp` | `card_elementalist_eye_of_stillness` | 3 | 원형 반경 3타일, 6타일 | 1초 예고/5초 지대 | 일반 적 -70%, 정예 -35%, 보스 본체 -15% 이동 속도 | 종료 후 둔화 저항 +40% 8초, 완전 정지 아님 | 보스 본체 패턴 취소 없음, 부위 집중 보조만 허용 |
| `heroic_spec_lock_elementalist_storm_ritual_mvp` | `card_elementalist_storm_ritual` | 4 | 활성 전선 고정 지점 4개, 각 반경 1.2타일 | 1.5초 예고/즉발 | 각 지점 피해 6 | 자동 추적 없음, 같은 적 최대 2회 적중 | 보스 부위 50%, 보스 본체 25%, 패턴 취소 없음 |
| `heroic_spec_lock_tinkerer_resonance_amp_mvp` | `card_tinkerer_resonance_amp` | 3 | 빈 설치 타일, 6타일 | 1초 예고/영구 오라 구조물 | 체력 14, 반경 2타일 오라, 3타일 안 오라 효과 40% 공유 | 네트워크 3기, 총 공속 오라 +60%, 연결 구조물 범위 피해 +20% | 보스 압력 권역에서 밀집 취약, 패턴 완화 없음 |
| `heroic_spec_lock_tinkerer_reassembly_machine_mvp` | `card_tinkerer_reassembly_machine` | 4 | 최근 8초 안에 파괴된 비임시 구조물 위치, 7타일 | 1초 예고/즉발 | 같은 구조물을 최대 체력 35%로 재설치 | 버프/파괴 보상 기록 제거, 같은 타일 반복 재건 페널티 | 보스 경로 압박 삭제 금지, 경로 검사 실패 시 사용 불가 |

영웅 효과 잠금 금지선:

- 영웅 효과는 `MvpHeroicCommitGate` 실패를 우회할 수 없습니다.
- 영웅 효과는 카드 후보 수, 희귀도, 골드 거절량, 보스 파편, 아티팩트 후보 수를 바꾸지 않습니다.
- 웨이브 겹치기, 클리어 시간, 처치 수, 보스 부위 파괴 수는 영웅 효과의 수치와 상한을 바꾸지 않습니다.
- 4인에서도 한 영웅 카드가 모든 활성 전선을 동시에 안정화하면 안 됩니다.
- 솔로에서는 모든 대상과 증거가 동쪽 전선 안의 전방, 중간, 후방, 경로 길이, 적 역할로 투영되어야 합니다.

## 첫 10일 카드 보상 프로필 제작표

첫 10일 카드 보상 프로필은 새 보상을 추가하는 표가 아닙니다.

같은 3장 선택 규칙 안에서 어떤 후보 풀을 우선 볼지 정리하는 제작 기준입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `reward_profile_first_010_phase_001_core` | 1~2일 | 예 | 직업 시작 덱의 핵심 역할을 한 번 더 쓰게 함 |
| `reward_profile_first_010_phase_002_response` | 3~4일 | 예 | 빠른 적과 군집 대응을 직업식으로 보완 |
| `reward_profile_first_010_phase_003_first_shop` | 5일 | 예 | 새 카드, 거절 골드, 첫 강화 후보를 비교 |
| `reward_profile_first_010_phase_004_collapse` | 6~7일 | 예 | 파괴, 잔해, 수리, 후방 재건 후보 제공 |
| `reward_profile_first_010_phase_005_tempo` | 8~9일 | 예 | 손패 순환과 우선 처치 카드를 제공하되 겹치기 보상 표현 금지 |
| `reward_profile_first_010_phase_006_boss` | 10일 | 예 | 첫 보스 부위 집중과 지연 역할을 확정 |
| `reward_profile_common_soft_gap_fill` | 1~30일 | 예 | 빠진 역할을 약하게 보완하는 공용 후보 |
| `reward_profile_no_stack_bonus_guard` | 전체 | 예 | 웨이브 겹치기로 후보 수, 희귀도, 보상 총량이 바뀌지 않게 검증 |

MVP 11~30일 보상 프로필은 첫 10일 프로필을 대체하는 상위 보상이 아니라, 같은 3장 선택 안에서 후보 이유를 더 좁히는 필터입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `reward_profile_mvp_011_020_artifact_bridge` | 11~19일 | 예 | 첫 아티팩트와 전투 실패 태그를 연결하되 일반 라운드 영웅을 열지 않음 |
| `reward_profile_mvp_015_contract_shop` | 15일 | 예 | 이벤트 계약, 작은 상점, 카드 거절이 한 선택 묶음처럼 읽히게 함 |
| `reward_profile_mvp_020_boss_branch` | 20일 | 예 | 변형 보스 결산을 21~30일 빌드 확정 또는 정리로 연결 |
| `reward_profile_mvp_021_030_commit` | 21~29일 | 예 | 지원 크레딧과 전투 증거가 있는 덱에만 영웅 확정 후보를 낮게 열고, 나머지는 희귀/일반으로 하향 |
| `reward_profile_mvp_025_season_turn` | 25일 | 예 | 계절 전환을 보스 보상이 아니라 약점 정리와 과구매 방지로 처리 |
| `reward_profile_mvp_030_result` | 30일 | 예 | MVP 운영을 유지할지, 정리할지, 계속하기 전에 판단하게 함 |

보상 프로필은 `preferredResponseTags`, `nextWaveIntentIds`, `nextEnemyRoleProfileIds`를 함께 가져야 합니다.

카드 3장 후보는 방금 실패한 태그 하나만 반복해서 보여주는 목록이 아니라, 직접 대응, 빌드 연결, 덱 상태 판단이 함께 보이는 작은 운영 선택이어야 합니다.

골드 거절은 카드 후보 슬롯이 아니라 별도 버튼으로 유지합니다.

### 71~100일 카드 보상 프로필 제작표

후반 카드 보상 프로필은 새 전리품을 늘리는 표가 아니라, 이미 정의된 후반 잠금표 안에서 후보 이유를 좁히는 제작 기준입니다.

| ID | 적용 | 연결 잠금 | 우선 대응 태그 | 역할 |
| --- | --- | --- | --- | --- |
| `reward_profile_late_071_080_space_patch` | 71~79일 | `loot_lock_round_071_080` | `space_relocation`, `rear_rebuild`, `resource_unjam` | 좁아진 공간에서 덱이 돌도록 위치와 손패를 보완 |
| `reward_profile_boss_080_frost_rebuild` | 80일 보스 후 | `loot_lock_boss_080` | `frost_relocation`, `rear_rebuild`, `focus_fire_mark` | 결빙과 후방 재건 경험을 다음 10일 카드 이유로 회수 |
| `reward_profile_late_081_090_pressure_patch` | 81~89일 | `loot_lock_round_081_090` | `pressure_safe_zone`, `repair_window`, `priority_burst` | 압력 밖 보조선과 우선 처치 선택지를 제공 |
| `reward_profile_boss_090_final_patch` | 90일 보스 후 | `loot_lock_boss_090` | `pressure_safe_zone`, `resource_unjam`, `base_crisis_patch` | 최종 10일 약점 보완, 100일 정답 카드 지급 금지 |
| `reward_profile_final_091_094_leak_patch` | 91~94일 | `loot_lock_round_091_094` | `base_crisis_patch`, `resource_unjam`, `repair_window` | 빠른 누수와 손패 꼬임을 마지막으로 보완 |
| `reward_profile_final_shop_095_tune` | 95일 상점 | `loot_lock_shop_final_095` | `artifact_sync`, `space_relocation`, `rear_rebuild` | 기존 아티팩트와 카드 축을 조율하고 제거/강화와 경쟁 |
| `reward_profile_final_096_099_closure` | 96~99일 | `loot_lock_round_096_099` | `base_crisis_patch`, `pressure_safe_zone`, `focus_fire_mark` | 마지막 위치 보정과 보스 전 집중 대상을 확정 |
| `reward_profile_result_100_summary_only` | 100일 결과 | `loot_lock_boss_100_result` | 없음 | 카드 보상 없이 결과 기록과 해금 후보 안내만 표시 |

후반 보상 프로필은 `newArchetypeEntryAllowed: false`를 기본값으로 둡니다.

91일 이후 `commitmentLevel: commit` 후보는 이미 같은 아키타입 선행 카드가 있을 때만 보일 수 있습니다.

## 대응 태그 제작표

대응 태그는 카드가 어떤 적 역할 압박을 열어주는지 표시하는 값입니다.

| ID | 표시명 | 여는 행동 | 주 연결 적 역할 | 금지선 |
| --- | --- | --- | --- | --- |
| `area_damage` | 광역 정리 | 모인 적을 짧은 시간에 정리 | 군집형 | 단독으로 모든 웨이브 해결 |
| `taunt_anchor` | 도발 앵커 | 적 목표를 한 지점으로 모음 | 군집형, 돌파형, 파괴형 | 보스 패턴 완전 삭제 |
| `path_extension` | 경로 연장 | 이동 시간을 늘림 | 돌파형, 압박형, 저항형 | 완전 길막 |
| `slow_or_knockback` | 둔화/밀침 | 도달 시간을 늦춤 | 돌파형, 압박형, 보스 | 영구 정지 |
| `repair_window` | 수리 창 | 살릴 구조물을 몇 초 더 버티게 함 | 파괴형, 압박형 | 자동 완전 복구 |
| `sacrifice_value` | 희생 가치 | 부서지는 구조물에 이득을 남김 | 파괴형, 군집형 | 무한 회수 루프 |
| `priority_burst` | 우선 처치 | 먼저 끊어야 할 적을 집중 공격 | 방해형, 지원형, 정예형 | 정예/보스 즉시 삭제 |
| `resource_unjam` | 자원 풀림 | 손패/마나 꼬임을 일시 완화 | 방해형 | 무한 드로우/마나 |
| `rear_rebuild` | 후방 재건 | 무너진 전선을 뒤로 옮김 | 압박형, 파괴형, 보스 | 같은 자리 반복 재건 정답화 |
| `space_relocation` | 공간 재배치 | 설치 금지나 결빙 예정지 밖으로 핵심 구조물을 옮김 | 압박형, 보스 | 설치 공간 압박 삭제 |
| `frost_relocation` | 결빙 회피 | 결빙 예고를 보고 타워와 킬존을 짧게 이전 | 압박형, 보스 | 결빙 상태 면역화 |
| `pressure_safe_zone` | 압력 밖 운영 | 압력 타일 밖에 보조선과 임시 화력을 세움 | 압박형, 보스 | 압력 타일 삭제 또는 장기 무력화 |
| `base_crisis_patch` | 기지 위기 보완 | 빠른 누수 직전의 지연, 표식, 짧은 수리 창을 만듦 | 돌파형, 압박형, 보스 | 기지 피해 무효화 |
| `artifact_sync` | 아티팩트 조율 | 보유 아티팩트의 조건을 카드 타이밍과 맞춤 | 보스, 후반 복합 압박 | 아티팩트 슬롯/효과 수 증가 |
| `focus_fire_mark` | 집중 표식 | 파티가 같은 대상을 보게 함 | 정예형, 보스 부위, 지원형 | 다른 플레이어 행동 자동 실행 |

## 기지 체력과 피해 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `base_health_rule_mvp_001` | 기지 체력 규칙 | 예 | 최대 체력 30, 안정/위험/치명/붕괴 상태 정의 |
| `base_damage_packet_profile` | 기지 피해 처리 | 예 | 적 기지 도달, 0.75초 누수 묶음, 실제 피해 합산 |
| `base_recovery_shop_small_3` | 기지 회복 규칙 | 예 | 작은 상점 기지 체력 3 회복, 골드 30 |
| `base_recovery_shop_boss_5` | 기지 회복 규칙 | 예 | 보스 후 상점 기지 체력 5 회복, 골드 45 |
| `base_recovery_emergency_surcharge` | 가격 규칙 | 예 | 기지 체력 10 이하 회복 항목 +20과 위험 문구 |
| `base_defeat_cause_priority` | 패배 분석 | 예 | 마지막 적보다 반복 누수, 경로 부족, 우선 처치 실패를 우선 표시 |
| `base_critical_warning_ui` | UI | 예 | 치명 상태와 기지 도달 3초 전 경고 우선 표시 |
| `base_breach_warning_notice_6_10s` | UI | 예 | 도달 6~10초 전 방향 화살표와 얇은 경로 pulse 표시 |
| `base_breach_warning_warning_3_6s` | UI | 예 | 도달 3~6초 전 도착 지점 링과 핑 후보 열기 |
| `base_breach_warning_critical_0_3s` | UI | 예 | 치명 체력 또는 패배 가능 피해에서 중앙 경고와 최우선 표시 |
| `base_breach_warning_boss_countdown` | UI | 예 | 보스 기지 도달 전용 5초 카운트다운 |
| `danger_ping_base_breach_mvp` | 핑 후보 | 예 | 집중 화력, 둔화/제어, 경로 확인, 수리, 후방 이전, 보류 후보 |

## 상태이상과 CC 제작표

상태이상은 적을 삭제하는 정답이 아니라, 킬존과 구조물이 작동할 시간을 버는 전술입니다.

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `status_slow` | 상태이상 | 예 | 이동 속도를 낮춰 킬존 체류 시간을 늘림 |
| `status_freeze` | 상태이상 | 예 | 일반 적을 짧게 멈추고, 정예/보스에게는 약화된 효과로 변환 |
| `status_knockback` | 상태이상 | 예 | 적을 경로 뒤쪽으로 밀어 기지 도달을 늦춤 |
| `status_taunt` | 상태이상 | 예 | 적 목표를 구조물로 돌리되 보스 강제 패턴은 막지 않음 |
| `status_vulnerable` | 상태이상 | 예 | 부위 집중이나 정예 처치 타이밍을 만듦 |
| `status_disruption` | 방해 효과 | 예 | 드로우, 마나, 오라, 수리 효율을 부분적으로 흔듦 |
| `status_profile_normal` | 저항 프로필 | 예 | 일반 적 기본 CC 반응 |
| `status_profile_runner` | 저항 프로필 | 예 | 돌파형의 둔화 지속 감소와 넉백 취약 |
| `status_profile_resistant` | 저항 프로필 | 예 | 특정 피해/CC에 강하지만 완전 무효 금지 |
| `status_profile_elite_heavy` | 저항 프로필 | 예 | 정예의 짧은 정지, 약한 넉백, 부분 도발 |
| `status_profile_boss_silent_colossus_body` | 보스 저항 프로필 | 예 | 보스 본체의 빙결 변환, 약한 둔화, 넉백 강저항 |
| `status_ui_reduced_feedback` | UI | 예 | 저항, 감소, 변환 효과를 짧게 표시 |

## 구조물 생애주기 제작표

구조물은 전투 중 소비되는 전술 자산입니다.

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `structure_lifecycle_base` | 생애주기 규칙 | 예 | 설치, 위험, 선택, 파괴, 재건의 기본 흐름 |
| `structure_role_killzone_damage` | 역할 태그 | 예 | 킬존 지속 피해 담당 구조물 |
| `structure_role_taunt_anchor` | 역할 태그 | 예 | 적 목표를 모으는 도발 앵커 |
| `structure_role_path_bend` | 역할 태그 | 예 | 경로를 비트는 바리케이드 |
| `structure_role_aura_core` | 역할 태그 | 예 | 주변 구조물 효율을 올리는 핵심 오라 |
| `structure_role_temporary_delay` | 역할 태그 | 예 | 짧게 버티고 사라지는 임시 구조물 |
| `repair_profile_basic_structure` | 수리 프로필 | 예 | 일반 수리 효율과 위험 권역 보정 |
| `destroy_value_explosive_debris` | 파괴 가치 프로필 | 예 | 폭발, 잔해, 둔화 등 파괴 후 전술 가치 |
| `rebuild_policy_same_tile_soft_penalty` | 재건 정책 | 예 | 같은 타일 즉시 재건의 체력/효율 보정 |
| `ui_structure_lifecycle_warning` | UI | 예 | 살릴지 버릴지 판단해야 하는 구조물 표시 |

## WaveIntent 제작표

`WaveIntent`는 웨이브를 만들기 전에 먼저 채웁니다.

방향이나 적 이름이 아니라 "이 웨이브가 무엇을 묻는가"를 고정하고, 실제 방향은 `WaveSpawnPlan`에서 인원수별 활성 방향 안으로 투영합니다.

| ID | 질문 태그 | 주 압박 | 보조 허용 | MVP 필수 | 제작 역할 |
| --- | --- | --- | --- | --- | --- |
| `intent_route_read` | `route_read` | `route_read` | 없음 | 예 | 경로 미리보기와 기지 도달 위험을 읽게 합니다. |
| `intent_path_stretch` | `path_extend` | `path_extend` | `simple_swarm` | 예 | 구조물 배치로 이동 시간을 늘리는 감각을 만듭니다. |
| `intent_fast_response` | `fast_response` | `runner_burst` | `light_swarm`, `route_read` | 예 | 빠른 적을 일반 군집과 다르게 다루게 합니다. |
| `intent_swarm_compression` | `swarm_clear` | `swarm_clear` | `positioning` | 예 | 광역, 가시, 잔해 폭발의 가치를 보여줍니다. |
| `intent_planned_structure_break` | `planned_collapse` | `planned_collapse` | `repair_or_abandon` | 예 | 구조물 파괴를 벌칙이 아니라 선택으로 만듭니다. |
| `intent_priority_target` | `priority_target` | `priority_target` | `light_swarm` | 예 | 먼저 끊어야 할 적을 읽게 합니다. |
| `intent_resource_disruption_recovery` | `resource_disruption` | `resource_disruption` | `stable_swarm` | 아니오 | 손패/마나 꼬임 속에서 전선을 유지하게 합니다. |
| `intent_secondary_killzone` | `secondary_killzone` | `secondary_killzone` | `route_shift` | 아니오 | 주 킬존 밖 보조 방어선 설계를 요구합니다. |
| `intent_relocation_after_loss` | `relocation` | `structure_loss` | `route_shift` | 아니오 | 무너진 전방을 포기하고 후방으로 옮기게 합니다. |
| `intent_final_focus` | `final_focus` | `boss_or_elite` | `companion_wave` | 예 | 남은 자원과 화력을 한 대상에 집중하게 합니다. |

## ChapterIntentPlan 제작표

각 10일 챕터는 새로 강하게 묻는 의도와 다시 묻는 의도를 분리해서 기록합니다.

이 표는 난이도 배율표가 아니라, 플레이어가 어떤 판단을 반복 학습하고 어떤 판단을 보스에서 회수하는지 추적하는 제작표입니다.

| ID | 적용 일자 | 주 의도 | 재확인 의도 | 보스 회수 |
| --- | --- | --- | --- | --- |
| `chapter_intent_plan_001_010` | 1~10일 | `intent_route_read`, `intent_path_stretch`, `intent_swarm_compression`, `intent_planned_structure_break` | 없음 | 경로, 지연, 구조물 희생 |
| `chapter_intent_plan_011_020` | 11~20일 | `intent_priority_target`, `intent_resource_disruption_recovery` | `intent_planned_structure_break`, `intent_fast_response` | 11~19일 실패 태그 중 하나 |
| `chapter_intent_plan_021_030` | 21~30일 | `intent_secondary_killzone`, `intent_fast_response` | `intent_priority_target`, `intent_swarm_compression` | 활성 방향 분담, 예고 신뢰 |
| `chapter_intent_plan_031_040` | 31~40일 | `intent_fast_response`, `intent_swarm_compression` | `intent_path_stretch`, `intent_planned_structure_break` | 과열 자리 선택과 구조물 위험 |
| `chapter_intent_plan_041_050` | 41~50일 | `intent_relocation_after_loss` | `intent_planned_structure_break`, `intent_fast_response` | 무너지는 방어선과 관측자 예고 |
| `chapter_intent_plan_051_060` | 51~60일 | `intent_secondary_killzone` | `intent_route_read`, `intent_path_stretch`, `intent_relocation_after_loss` | 오라/수리 약화 속 재배치 |
| `chapter_intent_plan_061_070` | 61~70일 | `intent_priority_target`, `intent_resource_disruption_recovery` | `intent_secondary_killzone`, `intent_relocation_after_loss` | 부위, 정예, 방해형 우선순위 |
| `chapter_intent_plan_071_080` | 71~80일 | `intent_secondary_killzone` | `intent_path_stretch`, `intent_swarm_compression` | 후방 킬존 준비 |
| `chapter_intent_plan_081_090` | 81~90일 | `intent_relocation_after_loss`, `intent_final_focus` | `intent_secondary_killzone`, `intent_priority_target` | 마지막 재설계와 집중 대상 |
| `chapter_intent_plan_091_100` | 91~100일 | 없음 | 모든 핵심 `WaveIntent` | 새 학습 없이 최종 선택만 회수 |

## 30일 MVP 콘텐츠 잠금 제작표

30일 MVP는 수치가 바뀌어도 일자별 플레이 질문과 보스/상점 리듬이 유지되어야 합니다.

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `mvp30_day_contract_set` | 일자 계약 | 예 | 1~30일 각 일자의 질문, 웨이브, 회수 태그, 금지선을 묶음 |
| `mvp30_checkpoint_day_005_shop` | 체크포인트 | 예 | 첫 작은 상점에서 카드 추가와 골드 거절이 모두 정상 선택인지 확인 |
| `mvp30_checkpoint_day_010_boss` | 체크포인트 | 예 | 첫 보스에서 부위 집중과 지연 수단 사용을 확인 |
| `mvp30_checkpoint_day_015_shop` | 체크포인트 | 예 | 강점 강화와 약점 보완 중 하나를 선택하게 함 |
| `mvp30_checkpoint_day_020_variant` | 체크포인트 | 예 | 11~19일 실패 태그를 변형 보스 한 가지 질문으로 회수 |
| `mvp30_checkpoint_day_025_transition` | 체크포인트 | 예 | 봄 빌드 마무리와 여름 속도 예고를 연결 |
| `mvp30_checkpoint_day_030_observer` | 체크포인트 | 예 | 불완전 정보 속 활성 방향 분담과 재도전 의향 확인 |
| `active_direction_projection_mvp30` | 방향 투영 | 예 | 모든 1~30일 웨이브를 런 시작 활성 방향 안으로 투영 |
| `mvp30_no_new_role_final_029_030` | 금지선 | 예 | 29~30일에 새 일반 적 역할을 추가하지 않음 |

## 웨이브 데이터 제작표

웨이브 원본 데이터는 제작 의도만 담습니다.

실제 스폰 방향과 수량은 `RunState`와 스케일링 프로필을 적용한 `WaveSpawnPlan`에서 확정합니다.

| ID | 일자 | 선호 방향 | 방향 역할 | MVP | 핵심 검증 |
| --- | ---: | --- | --- | --- | --- |
| `wave_day_001_east_intro` | 1 | `east` | `short` | 예 | 동쪽 첫 진입과 기본 타워 학습 |
| `wave_day_002_path_stretch` | 2 | `north` | `slow` | 예 | 바리케이드로 경로 시간을 늘리는 학습 |
| `wave_day_003_runner_intro` | 3 | `west` | `fast` | 예 | 틈새 주자 첫 등장, 1~2인은 활성 방향 대체 |
| `wave_day_004_gather_and_answer` | 4 | `east` | `short` | 예 | 군집형과 돌파형을 구분 대응 |
| `wave_day_005_recovery_shop` | 5 | `east`, `north` | `any` | 예 | 쉬운 웨이브 후 첫 상점 판단 |
| `wave_day_006_destroyer_intro` | 6 | `east` | `short` | 예 | 균열 망치와 구조물 파괴 학습 |
| `wave_day_007_debris_tactics` | 7 | `east`, `north` | `any` | 예 | 구조물 파괴와 잔해 활용 |
| `wave_day_008_tempo_call` | 8 | `west`, `north`, `east`, `south` | `any` | 예 | 안정 웨이브와 웨이브 겹치기 자연 유도 |
| `wave_day_009_priority_intro` | 9 | `north`, `east` | `any` | 예 | 침묵 운반자 소량으로 우선 처치 학습 |
| `wave_day_010_silent_colossus` | 10 | `east` | `short` | 예 | 첫 보스와 구조물 파괴 대응 |
| `wave_day_011_glass_shell_intro` | 11 | `north` | `slow` | 예 | 유리 껍질 첫 등장, 광역 의존 견제 |
| `wave_day_012_growth_release` | 12 | `east`, `north` | `any` | 예 | 보스 보상과 아티팩트 성장 체감 |
| `wave_day_013_silence_return` | 13 | `east` | `short` | 예 | 침묵 운반자 재확인과 우선 처치 |
| `wave_day_014_runner_glass_mix` | 14 | `west` | `fast` | 예 | 빠른 적과 저항형 화력 배분 |
| `wave_day_015_cracked_storehouse` | 15 | `east`, `north` | `any` | 예 | 이벤트와 작은 상점 전 정비 |
| `wave_day_016_two_lane_resistance` | 16 | `north`, `east` | `any` | 예 | 2방향 저항 압박 |
| `wave_day_017_breaker_pressure` | 17 | `east` | `short` | 예 | 구조물 파괴 재검증 |
| `wave_day_018_stack_decision` | 18 | `west`, `north`, `east`, `south` | `any` | 예 | 웨이브 겹치기 안정 판단 |
| `wave_day_019_elite_warning` | 19 | `west`, `north` | `any` | 예 | 21일 이후 정예 압박 예고 |
| `wave_day_020_silent_colossus_variant` | 20 | `east` | `short` | 예 | 침묵의 거상 변형 |
| `wave_day_021_black_pack_intro` | 21 | `west` | `fast` | 예 | 검은 등짐 첫 등장과 처치 타이밍 |
| `wave_day_022_killzone_rebuild` | 22 | `south` | `killzone` | 예 | 킬존 재설계, 비활성 방향은 대체 |
| `wave_day_023_twisted_mark_intro` | 23 | `north` | `slow` | 예 | 뒤틀린 표식과 도발 의존 견제 |
| `wave_day_024_fast_lane_split` | 24 | `west`, `east` | `any` | 예 | 빠른 라인과 방해 라인 분담 |
| `wave_day_025_season_turning` | 25 | `east`, `north` | `any` | 예 | 계절 전환 전 정비 |
| `wave_day_026_summer_speed_preview` | 26 | `west` | `fast` | 예 | 여름 빠른 템포 예고 |
| `wave_day_027_silence_elite_mix` | 27 | `north`, `east` | `any` | 예 | 방해형과 정예형 우선순위 |
| `wave_day_028_three_stack_trial` | 28 | `west`, `north`, `east`, `south` | `any` | 예 | 기본 한도 3개 내 웨이브 겹치기 시험 |
| `wave_day_029_mvp_final_mix` | 29 | `west`, `north`, `east` | `any` | 예 | 30일 MVP 전투 총정리 |
| `wave_day_030_season_observer_preview` | 30 | `west`, `north`, `east`, `south` | `any` | 예 | 사계의 관측자 예고형 |
| `wave_day_031_overheat_tile_intro` | 31 | `east` | `short` | 아니오 | 과열 타일 첫 학습 |
| `wave_day_032_summer_sprinter_intro` | 32 | `west` | `fast` | 아니오 | 여름 질주자 첫 등장 |
| `wave_day_033_hot_killzone` | 33 | `south` | `killzone` | 아니오 | 과열 킬존과 구조물 보호 |
| `wave_day_034_ember_mason_intro` | 34 | `east` | `short` | 아니오 | 잿불 석공 첫 등장 |
| `wave_day_035_cooling_shop` | 35 | `east`, `north` | `any` | 아니오 | 냉각 상점 전 정비 |
| `wave_day_036_two_lane_heat` | 36 | `west`, `north` | `any` | 아니오 | 두 방향 과열 압박 |
| `wave_day_037_repair_under_heat` | 37 | `east`, `north` | `any` | 아니오 | 열 속의 수리와 파괴 판단 |
| `wave_day_038_stack_heat_risk` | 38 | `west`, `north`, `east`, `south` | `any` | 아니오 | 과열 상태의 웨이브 겹치기 위험 |
| `wave_day_039_overheated_mix` | 39 | `west`, `east` | `any` | 아니오 | 여름 1장 총정리 |
| `wave_day_040_overheated_colossus` | 40 | `east` | `short` | 아니오 | 과열된 거상 |
| `wave_day_041_post_boss_rebuild` | 41 | `east`, `north` | `any` | 아니오 | 보스 후 재건 압박 |
| `wave_day_042_heat_saw_intro` | 42 | `east` | `short` | 아니오 | 열톱니 첫 등장 |
| `wave_day_043_marked_barricade` | 43 | `north`, `east` | `any` | 아니오 | 표식된 바리케이드 판단 |
| `wave_day_044_fast_breaker_split` | 44 | `west`, `east` | `fast` | 아니오 | 빠른 적과 파괴형 분산 |
| `wave_day_045_heatbreak_market` | 45 | `east`, `north` | `any` | 아니오 | 열차단 상점 전 정비 |
| `wave_day_046_overheat_breach_rotation` | 46 | `north`, `east`, `west` | `any` | 아니오 | 과열 지점 회전 운영 |
| `wave_day_047_observer_echo` | 47 | `west`, `north`, `east`, `south` | `any` | 아니오 | 관측자 잔향과 후보 예고 |
| `wave_day_048_stack_break_warning` | 48 | `west`, `north`, `east`, `south` | `any` | 아니오 | 파괴형 표식 상태의 겹치기 위험 |
| `wave_day_049_summer_second_mix` | 49 | `west`, `north`, `east` | `any` | 아니오 | 여름 2장 총정리 |
| `wave_day_050_season_observer` | 50 | `west`, `north`, `east`, `south` | `any` | 아니오 | 사계의 관측자 강화형 |
| `wave_day_051_leaf_drift_intro` | 51 | `east`, `north` | `any` | 아니오 | 낙엽 타일 첫 학습 |
| `wave_day_052_autumn_mute_intro` | 52 | `north`, `east` | `any` | 아니오 | 가을의 묵자 첫 등장 |
| `wave_day_053_persistent_debris` | 53 | `east` | `short` | 아니오 | 오래 남는 잔해 활용 |
| `wave_day_054_leaf_reroute` | 54 | `west`, `north` | `any` | 아니오 | 낙엽 우회 경로 |
| `wave_day_055_fallen_path_market` | 55 | `east`, `north` | `any` | 아니오 | 무너진 길 상점 전 정비 |
| `wave_day_056_aura_spread_test` | 56 | `north`, `east` | `any` | 아니오 | 오라 분산 시험 |
| `wave_day_057_stack_reroute_risk` | 57 | `west`, `north`, `east`, `south` | `any` | 아니오 | 경로 변화 중 겹치기 위험 |
| `wave_day_058_debris_killzone_shift` | 58 | `south`, `east` | `killzone` | 아니오 | 이동하는 킬존 |
| `wave_day_059_autumn_first_mix` | 59 | `west`, `north`, `east` | `any` | 아니오 | 가을 1장 총정리 |
| `wave_day_060_fallen_belltower` | 60 | `west`, `north`, `east`, `south` | `any` | 아니오 | 무너진 종탑 |
| `wave_day_061_post_tower_realign` | 61 | `east`, `north` | `any` | 아니오 | 종탑 후 재배치 |
| `wave_day_062_mute_elite_priority` | 62 | `north`, `east` | `any` | 아니오 | 방해형과 정예 우선순위 |
| `wave_day_063_rear_elite_pressure` | 63 | `east` | `short` | 아니오 | 후미 정예 압박 |
| `wave_day_064_leaf_mute_crossfire` | 64 | `west`, `north` | `any` | 아니오 | 낙엽 변화와 자원 방해 |
| `wave_day_065_harvest_market` | 65 | `east`, `north` | `any` | 아니오 | 수확 상점 전 정비 |
| `wave_day_066_split_priority` | 66 | `north`, `east`, `west` | `any` | 아니오 | 분산 우선순위 |
| `wave_day_067_stack_under_silence` | 67 | `west`, `north`, `east`, `south` | `any` | 아니오 | 침묵 속 겹치기 위험 |
| `wave_day_068_elite_debris_lane` | 68 | `south`, `east` | `killzone` | 아니오 | 잔해 정예 라인 |
| `wave_day_069_autumn_second_mix` | 69 | `west`, `north`, `east` | `any` | 아니오 | 가을 2장 총정리 |
| `wave_day_070_fallen_belltower_variant` | 70 | `west`, `north`, `east`, `south` | `any` | 아니오 | 무너진 종탑 변형 |
| `wave_day_071_first_frost` | 71 | `east`, `north` | `any` | 아니오 | 첫 서리와 결빙 예고 |
| `wave_day_072_winter_husk_intro` | 72 | `east` | `short` | 아니오 | 겨울 껍질 첫 등장 |
| `wave_day_073_narrow_buildline` | 73 | `north`, `east` | `any` | 아니오 | 좁아진 방어선 |
| `wave_day_074_slow_pressure_lane` | 74 | `north` | `slow` | 아니오 | 느린 대형 적 압박 |
| `wave_day_075_season_turn_thaw_market` | 75 | `east`, `north` | `any` | 아니오 | 계절 전환 정비 |
| `wave_day_076_winter_rules_begin` | 76 | `east`, `north`, `west` | `any` | 아니오 | 겨울 규칙 본격화 |
| `wave_day_077_frozen_repair` | 77 | `east`, `north` | `any` | 아니오 | 얼어붙은 수리 |
| `wave_day_078_stack_space_risk` | 78 | `west`, `north`, `east`, `south` | `any` | 아니오 | 공간 축소 중 겹치기 위험 |
| `wave_day_079_winter_first_mix` | 79 | `west`, `north`, `east` | `any` | 아니오 | 겨울 1장 총정리 |
| `wave_day_080_winter_gate_preview` | 80 | `east` | `short` | 아니오 | 겨울의 문 예고형 |
| `wave_day_081_gate_after_rebuild` | 81 | `east`, `north` | `any` | 아니오 | 문 뒤의 재정비 |
| `wave_day_082_pressure_tile_intro` | 82 | `east` | `short` | 아니오 | 보스 압력 타일 첫 학습 |
| `wave_day_083_husk_under_pressure` | 83 | `north`, `east` | `any` | 아니오 | 압력 속 겨울 껍질 |
| `wave_day_084_centerline_squeeze` | 84 | `north` | `slow` | 아니오 | 좁아지는 중심선 |
| `wave_day_085_last_redesign_market` | 85 | `east`, `north` | `any` | 아니오 | 마지막 재설계 상점 |
| `wave_day_086_pressure_rotation` | 86 | `east`, `north`, `west` | `any` | 아니오 | 압력 회전 |
| `wave_day_087_stack_under_pressure` | 87 | `west`, `north`, `east`, `south` | `any` | 아니오 | 압력 중 겹치기 위험 |
| `wave_day_088_last_killzone_shift` | 88 | `south`, `east` | `killzone` | 아니오 | 마지막 킬존 이동 |
| `wave_day_089_winter_second_mix` | 89 | `west`, `north`, `east` | `any` | 아니오 | 겨울 2장 총정리 |
| `wave_day_090_winter_gate` | 90 | `east` | `short` | 아니오 | 겨울의 문 |
| `wave_day_091_last_line_check` | 91 | `east`, `north` | `any` | 아니오 | 마지막 방어선 점검 |
| `wave_day_092_final_fast_crack` | 92 | `west`, `east` | `fast` | 아니오 | 빠른 균열 |
| `wave_day_093_resource_silence` | 93 | `north`, `east` | `any` | 아니오 | 자원 침묵 |
| `wave_day_094_final_structure_break` | 94 | `east` | `short` | 아니오 | 핵심 구조물 압박 |
| `wave_day_095_last_market` | 95 | `east`, `north` | `any` | 아니오 | 마지막 상점 |
| `wave_day_096_elite_split_final` | 96 | `west`, `north`, `east` | `any` | 아니오 | 정예 분담 |
| `wave_day_097_final_pressure_warning` | 97 | `west`, `north`, `east`, `south` | `any` | 아니오 | 완전체 압력 예고 |
| `wave_day_098_last_stack_choice` | 98 | `west`, `north`, `east`, `south` | `any` | 아니오 | 마지막 겹치기 판단 |
| `wave_day_099_all_pressure_rehearsal` | 99 | `west`, `north`, `east` | `any` | 아니오 | 모든 압박 리허설 |
| `wave_day_100_winter_gate_final` | 100 | `east` | `short` | 아니오 | 겨울의 문 완전체 |

### 첫 10일 웨이브 제작표

첫 10일 웨이브는 아래 제작 흐름을 참고합니다.

이 표는 보상이나 난이도 보정이 아니라, 학습 압박의 순서를 고정하기 위한 제작 기준입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `first_wave_phase_001_route` | 1~2일 | 예 | 동쪽 경로, 타워, 바리케이드, 완전 길막 불가 확인 |
| `first_wave_phase_002_speed_split` | 3~4일 | 예 | 틈새 주자와 회색 행렬 대응 분리 |
| `first_wave_phase_003_recovery_shop` | 5일 | 예 | 쉬운 웨이브 뒤 카드 보상과 첫 상점 연결 |
| `first_wave_phase_004_planned_collapse` | 6~7일 | 예 | 균열 망치, 구조물 파괴, 잔해 가치 확인 |
| `first_wave_phase_005_tempo_priority` | 8~9일 | 예 | 겹치기 템포 판단과 침묵 운반자 우선 처치 |
| `first_wave_phase_006_first_boss` | 10일 | 예 | 침묵의 거상 지연, 부위 집중, 약한 동반 웨이브 |
| `first_wave_role_response_check` | 1~10일 | 예 | 각 일자에서 4직업 대응 태그를 관찰 |
| `first_wave_direction_cap_rule` | 1~10일 | 예 | 1인은 동쪽만, 10일 전 3방향 이상 압박 금지 |

### 11~20일 운영 제작표

11~20일은 첫 보스 후 보상과 아티팩트 선택을 검증하는 첫 운영 흐름입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `spring2_operation_flow_011_020` | 11~20일 | 예 | 첫 보상 체감, 우선순위, 작은 상점, 분담, 겹치기, 변형 보스 연결 |
| `spring2_phase_001_growth_check` | 11~12일 | 예 | 첫 보스 보상과 아티팩트 체감 확인 |
| `spring2_phase_002_priority_split` | 13~14일 | 예 | 방해형, 빠른 적, 저항형 우선순위 분리 |
| `spring2_phase_003_small_shop` | 15일 | 예 | 강점 강화와 약점 보완 중 하나를 고르는 작은 상점 |
| `spring2_phase_004_lane_role_split` | 16~17일 | 예 | 2방향 압박과 구조물 재검증 |
| `spring2_phase_005_stack_elite_forecast` | 18~19일 | 예 | 겹치기 안정 판단과 정예 예고 |
| `spring2_phase_006_variant_boss` | 20일 | 예 | 11~19일 실패 태그를 한 가지 되묻는 침묵의 거상 변형 |
| `spring2_direction_cap_rule` | 11~20일 | 예 | 1인은 동쪽만, 4인도 사방 동시 압박 금지 |
| `spring2_operation_choice_check` | 11~20일 | 아니오 | 15일 선택이 16~20일에서 실제로 검증되는지 기록 |

### 21~30일 MVP 협동 제작표

21~30일은 30일 MVP 런의 마지막 협동 시험입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `mvp30_coop_flow_021_030` | 21~30일 | 예 | 정예 타이밍, 방향 분담, 계절 전환, 여름 예고, 고밀도 리허설, 관측자 예고 연결 |
| `mvp30_phase_001_elite_timing` | 21일 | 예 | 검은 등짐 처치 타이밍 합의 |
| `mvp30_phase_002_lane_reassignment` | 22~24일 | 예 | 킬존 재설계, 도발 약화, 빠른 라인 분담 |
| `mvp30_phase_003_season_turn` | 25일 | 예 | 봄 마무리와 여름 대비 선택 |
| `mvp30_phase_004_summer_priority` | 26~27일 | 예 | 빠른 템포 속 정예/방해형 우선순위 |
| `mvp30_phase_005_density_rehearsal` | 28~29일 | 예 | 3웨이브 겹치기 위험 판단과 MVP 총정리 |
| `mvp30_phase_006_observer_preview` | 30일 | 예 | 활성 방향 안 후보 예고와 파티 분담 |
| `mvp30_direction_cap_rule` | 21~30일 | 예 | 1인은 동쪽만, 2인은 3방향 금지, 3인은 남쪽 금지, 4인은 사방 동시 금지 |
| `observer_preview_candidate_rule` | 30일 | 예 | 후보 방향은 반드시 활성 방향의 부분집합 |

### 31~40일 과열 운영 제작표

31~40일은 여름 규칙이 처음 본격화되는 구간입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `summer1_heat_flow_031_040` | 31~40일 | 아니오 | 과열 타일, 빠른 적, 냉각 정비, 과열 분담, 고열 리허설, 과열된 거상 연결 |
| `summer1_phase_001_hot_boost_intro` | 31~32일 | 아니오 | 과열 타일과 빠른 적 대응 학습 |
| `summer1_phase_002_hot_killzone` | 33~34일 | 아니오 | 뜨거운 킬존과 잿불 석공 달굼 판단 |
| `summer1_phase_003_cooling_shop` | 35일 | 아니오 | 수리, 체력, 빠른 대응 중 하나를 고르는 냉각 정비 |
| `summer1_phase_004_heat_split` | 36~37일 | 아니오 | 두 방향 과열 압박과 수리 효율 감소 |
| `summer1_phase_005_heat_stack_rehearsal` | 38~39일 | 아니오 | 과열 상태 겹치기 위험과 여름 1장 총정리 |
| `summer1_phase_006_overheated_colossus` | 40일 | 아니오 | 보스 열 자취와 구조물 붕괴 통제 |
| `summer1_direction_cap_rule` | 31~40일 | 아니오 | 1인은 동쪽만, 3인은 남쪽 금지, 4인도 사방 동시 압박 금지 |
| `overheat_tile_decision_check` | 31~40일 | 아니오 | 과열 타일 사용, 포기, 구조물 손실 이유 기록 |

### 41~50일 붕괴 운영 제작표

41~50일은 여름 2장의 구조물 손실 운영 구간입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `summer2_collapse_flow_041_050` | 41~50일 | 아니오 | 보스 후 재건, 표식 구조물, 보완 상점, 과열 회전, 붕괴 리허설, 관측자 강화형 연결 |
| `summer2_phase_001_rebuild_choice` | 41일 | 아니오 | 손상된 방어선 유지/철거 판단 |
| `summer2_phase_002_marked_collapse` | 42~43일 | 아니오 | 열톱니 표식 구조물 살림/버림 선택 |
| `summer2_phase_003_heatbreak_market` | 44~45일 | 아니오 | 빠른 적/파괴형 분산과 열차단 상점 보완 |
| `summer2_phase_004_rotation_forecast` | 46~47일 | 아니오 | 과열 지점 회전과 후보 방향 예고 분담 |
| `summer2_phase_005_break_stack_rehearsal` | 48~49일 | 아니오 | 파괴형 표식 상태의 겹치기 위험과 총정리 |
| `summer2_phase_006_observer_enhanced` | 50일 | 아니오 | 방향 후보, 과열 후보, 구조물 표식이 함께 있는 관측자 강화형 |
| `summer2_direction_cap_rule` | 41~50일 | 아니오 | 1인은 동쪽만, 2인은 서쪽 금지, 3인은 남쪽 금지, 4인은 사방 동시 금지 |
| `marked_structure_decision_check` | 42~50일 | 아니오 | 표식 구조물 저장/희생/후방 재건 판단 기록 |

### 51~60일 경로 재설계 제작표

51~60일은 가을 1장의 경로 변화 운영 구간입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `autumn1_path_flow_051_060` | 51~60일 | 아니오 | 낙엽 예고, 마나 방해, 오래 남는 잔해, 오라 분산, 무너진 종탑 연결 |
| `autumn1_phase_001_leaf_mute_intro` | 51~52일 | 아니오 | 낙엽 타일 경로 비용 변화와 가을의 묵자 우선순위 학습 |
| `autumn1_phase_002_debris_reroute` | 53~54일 | 아니오 | 오래 남는 잔해와 낙엽 우회에 맞춘 킬존 이동 |
| `autumn1_phase_003_fallen_path_market` | 55일 | 아니오 | 잔해 정리, 낙엽 예고, 수리 효율, 방해 저항 중 하나를 고르는 정비 |
| `autumn1_phase_004_aura_stack_risk` | 56~57일 | 아니오 | 오라 분산과 경로 변화 중 겹치기 위험 판단 |
| `autumn1_phase_005_mobile_killzone` | 58~59일 | 아니오 | 잔해와 낙엽으로 이동 킬존을 만들고 총정리 |
| `autumn1_phase_006_fallen_belltower` | 60일 | 아니오 | 무음 권역 속 오라/수리 약화와 분산/재집결 판단 |
| `autumn1_direction_cap_rule` | 51~60일 | 아니오 | 1인은 동쪽만, 2인은 북/동만, 3인은 남쪽 금지, 4인은 사방 동시 금지 |
| `leaf_path_decision_check` | 51~60일 | 아니오 | 낙엽 예고 확인, 킬존 이동/유지, 실패 이유 태그 기록 |

### 61~70일 우선순위 제작표

61~70일은 가을 2장의 방해형/정예 우선순위 운영 구간입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `autumn2_priority_flow_061_070` | 61~70일 | 아니오 | 종탑 후 재배치, 방해형/정예 우선순위, 수확 상점, 분산 판단, 종탑 변형 연결 |
| `autumn2_phase_001_post_tower_realign` | 61일 | 아니오 | 무음 권역 이후 방어선과 우선 처치 핑 위치 재정렬 |
| `autumn2_phase_002_mute_elite_timing` | 62~63일 | 아니오 | 가을의 묵자와 검은 등짐, 후미 정예 처치 타이밍 합의 |
| `autumn2_phase_003_leaf_harvest_market` | 64~65일 | 아니오 | 낙엽 교차 압박과 수확 상점 보완 |
| `autumn2_phase_004_split_stack_priority` | 66~67일 | 아니오 | 두 활성 방향의 서로 다른 위험 분담과 침묵 속 겹치기 판단 |
| `autumn2_phase_005_elite_debris_recap` | 68~69일 | 아니오 | 잔해 정예 라인과 가을 2장 총정리 |
| `autumn2_phase_006_belltower_variant` | 70일 | 아니오 | 무음 권역 중 약한 정예/방해형 동반 웨이브 우선순위 |
| `autumn2_direction_cap_rule` | 61~70일 | 아니오 | 1인은 동쪽만, 2인은 북/동만, 3인은 남쪽 금지, 4인은 사방 동시 금지 |
| `priority_target_decision_check` | 62~70일 | 아니오 | 방해형/정예/보스 부위 중 먼저 본 대상과 변경 이유 기록 |

### 71~80일 공간 압박 제작표

71~80일은 겨울 1장의 설치 공간 축소 운영 구간입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `winter1_space_flow_071_080` | 71~80일 | 아니오 | 첫 서리, 겨울 껍질, 해동/이전 정비, 결빙 증가, 공간 겹치기, 겨울의 문 예고형 연결 |
| `winter1_phase_001_first_frost_husk` | 71~72일 | 아니오 | 결빙 예고와 겨울 껍질 지속 화력 학습 |
| `winter1_phase_002_narrow_slow_lane` | 73~74일 | 아니오 | 좁아진 방어선과 느린 대형 적 처리 |
| `winter1_phase_003_thaw_relocation_market` | 75일 | 아니오 | 해동, 구조물 이전, 대형 적 대응 중 하나를 고르는 정비 |
| `winter1_phase_004_full_winter_repair` | 76~77일 | 아니오 | 결빙 증가와 얼어붙은 수리 효율 판단 |
| `winter1_phase_005_space_stack_recap` | 78~79일 | 아니오 | 설치 공간 부족 상태의 겹치기 위험과 겨울 1장 총정리 |
| `winter1_phase_006_winter_gate_preview` | 80일 | 아니오 | 겨울의 문 예고형으로 임시 결빙 권역과 후방 이전 학습 |
| `winter1_direction_cap_rule` | 71~80일 | 아니오 | 1인은 동쪽만, 2인은 북/동만, 3인은 남쪽 금지, 4인은 사방 동시 금지 |
| `frost_space_decision_check` | 71~80일 | 아니오 | 결빙 예고 확인, 구조물 이전/해동, 남은 설치 공간 기록 |

### 81~90일 최종 이전 제작표

81~90일은 겨울 2장의 보스 압력 타일과 마지막 킬존 이전 운영 구간입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `winter2_pressure_flow_081_090` | 81~90일 | 아니오 | 문 뒤 재정비, 압력 타일 학습, 재설계 상점, 압력 회전, 마지막 킬존, 겨울의 문 연결 |
| `winter2_phase_001_pressure_intro` | 81~82일 | 아니오 | 후방 킬존 준비와 보스 압력 타일 효율 감소 학습 |
| `winter2_phase_002_centerline_shift` | 83~84일 | 아니오 | 압력 속 대형 적 처리와 중후방 킬존 이전 |
| `winter2_phase_003_last_redesign_market` | 85일 | 아니오 | 구조물 이전, 압력 예고, 해동, 대형 적 대응 중 하나를 고르는 정비 |
| `winter2_phase_004_pressure_rotation_stack` | 86~87일 | 아니오 | 압력 회전과 압력 중 겹치기 위험 판단 |
| `winter2_phase_005_last_killzone_recap` | 88~89일 | 아니오 | 마지막 킬존 이동과 겨울 2장 총정리 |
| `winter2_phase_006_winter_gate` | 90일 | 아니오 | 이동하는 보스 압력 타일 속 방어선 이전 |
| `winter2_direction_cap_rule` | 81~90일 | 아니오 | 1인은 동쪽만, 2인은 북/동만, 3인은 남쪽 금지, 4인은 사방 동시 금지 |
| `pressure_tile_decision_check` | 82~90일 | 아니오 | 압력 예고 확인, 후방 킬존 이전, 남은 설치 공간 기록 |

### WaveSpawnPlan 규칙 제작표

| ID | MVP | 역할 |
| --- | --- | --- |
| `spawn_rule_filter_active_directions` | 예 | 원본 웨이브의 선호 방향을 런의 활성 방향으로 필터링 |
| `spawn_rule_replace_inactive_direction` | 예 | 비활성 선호 방향을 방향 역할 기준으로 대체 |
| `spawn_rule_apply_scaling_profile` | 예 | 인원수 스케일링 프로필로 위협 예산과 적 수량 조정 |
| `spawn_rule_reserve_next_plans` | 예 | 다음 웨이브 계획을 미리 확정해 예고 UI와 겹치기 UI에 제공 |
| `spawn_rule_stack_advance_only` | 예 | 웨이브 겹치기는 예약된 계획의 시작 시점만 앞당김 |

`WaveSpawnPlan` 규칙에는 보상 증가, 카드 선택지 증가, 카드 희귀도 증가, 비활성 방향 개방 필드를 만들지 않습니다.

### 첫 10일 스폰 패킷 제작표

첫 10일 스폰 패킷은 2인 기준 시작값입니다.

스케일링은 `RunState.playerCountAtStart`와 `activeDirections`를 적용한 `WaveSpawnPlan`에서 처리합니다.

| ID | 일자 | 적 | 2인 수량 | 첫 스폰 | 간격 | 방향 역할 | MVP | 검증 |
| --- | ---: | --- | ---: | ---: | ---: | --- | --- | --- |
| `spawn_packet_day_001_gray_intro` | 1 | 회색 행렬 | 6 | 8초 | 2.0초 | `short` | 예 | 경로와 사거리 학습 |
| `spawn_packet_day_002_gray_stretch` | 2 | 회색 행렬 | 8 | 8초 | 2.0초 | `slow` | 예 | 경로 연장 학습 |
| `spawn_packet_day_003_runner_intro` | 3 | 틈새 주자 | 2 | 6초 | 2.6초 | `fast` | 예 | 빠른 적 첫 인식 |
| `spawn_packet_day_003_gray_follow` | 3 | 회색 행렬 | 5 | 12초 | 1.8초 | `short` | 예 | 빠른 적 이후 기본 군집 |
| `spawn_packet_day_004_gray_cluster` | 4 | 회색 행렬 | 8 | 7초 | 1.6초 | `short` | 예 | 킬존 압축 |
| `spawn_packet_day_004_runner_split` | 4 | 틈새 주자 | 2 | 14초 | 3.0초 | `fast` | 예 | 군집 속 빠른 적 구분 |
| `spawn_packet_day_005_gray_shop_bridge` | 5 | 회색 행렬 | 10 | 9초 | 1.8초 | `any` | 예 | 첫 상점 전 점검 |
| `spawn_packet_day_006_gray_front` | 6 | 회색 행렬 | 9 | 8초 | 1.6초 | `short` | 예 | 파괴형 전 기본 전선 |
| `spawn_packet_day_006_crack_hammer_intro` | 6 | 균열 망치 | 1 | 18초 | 없음 | `short` | 예 | 파괴 표식 학습 |
| `spawn_packet_day_007_gray_debris` | 7 | 회색 행렬 | 10 | 7초 | 1.5초 | `any` | 예 | 잔해/폭발 가치 |
| `spawn_packet_day_007_crack_hammer_pair` | 7 | 균열 망치 | 2 | 16초 | 6.0초 | `any` | 예 | 살릴 구조물과 버릴 구조물 |
| `spawn_packet_day_008_gray_stack_prompt` | 8 | 회색 행렬 | 12 | 9초 | 1.5초 | `any` | 예 | 겹치기 판단 여유 |
| `spawn_packet_day_009_gray_priority_bg` | 9 | 회색 행렬 | 10 | 7초 | 1.5초 | `any` | 예 | 우선 처치 배경 압박 |
| `spawn_packet_day_009_silence_intro` | 9 | 침묵 운반자 | 1 | 18초 | 없음 | `any` | 예 | 방해형 우선 처치 |
| `spawn_packet_day_010_colossus_body` | 10 | 침묵의 거상 | 1 | 0초 | 없음 | `boss` | 예 | 보스 지연과 부위 판단 |
| `spawn_packet_day_010_optional_gray_companion` | 10 | 회색 행렬 | 6 | 45초 | 2.0초 | `short` | 예 | 필요 시 보스 동반 웨이브 |

`spawn_packet_day_010_optional_gray_companion`은 테스트에서 보스전이 너무 단조로울 때만 켭니다.

동반 패킷을 켜도 보상 팩은 추가하지 않습니다.

### 11~20일 스폰 패킷 제작표

11~20일 스폰 패킷은 첫 보스 후 성장 선택을 실제 전투에서 확인하기 위한 2인 기준 시작값입니다.

| ID | 일자 | 적 | 2인 수량 | 첫 스폰 | 간격 | 방향 역할 | MVP | 검증 |
| --- | ---: | --- | ---: | ---: | ---: | --- | --- | --- |
| `spawn_packet_day_011_gray_foundation` | 11 | 회색 행렬 | 8 | 8초 | 1.7초 | `slow` | 예 | 첫 아티팩트 기본 전선 체감 |
| `spawn_packet_day_011_glass_intro` | 11 | 유리 껍질 | 3 | 17초 | 7.0초 | `slow` | 예 | 광역 의존 견제 |
| `spawn_packet_day_012_gray_growth` | 12 | 회색 행렬 | 14 | 8초 | 1.4초 | `any` | 예 | 성장 체감 |
| `spawn_packet_day_013_gray_silence_bg` | 13 | 회색 행렬 | 10 | 7초 | 1.5초 | `short` | 예 | 방해형 배경 압박 |
| `spawn_packet_day_013_silence_pair` | 13 | 침묵 운반자 | 2 | 18초 | 10.0초 | `short` | 예 | 우선 처치 재확인 |
| `spawn_packet_day_013_gray_after_silence` | 13 | 회색 행렬 | 4 | 28초 | 1.4초 | `short` | 예 | 방해 방치 결과 확인 |
| `spawn_packet_day_014_runner_fast` | 14 | 틈새 주자 | 4 | 6초 | 2.4초 | `fast` | 예 | 빠른 적 누수 방지 |
| `spawn_packet_day_014_glass_hold` | 14 | 유리 껍질 | 4 | 13초 | 6.0초 | `fast` | 예 | 저항형 장기 처리 |
| `spawn_packet_day_014_gray_split` | 14 | 회색 행렬 | 4 | 20초 | 1.5초 | `fast` | 예 | 화력 배분 |
| `spawn_packet_day_015_gray_shop_diagnosis` | 15 | 회색 행렬 | 10 | 9초 | 1.7초 | `any` | 예 | 작은 상점 전 진단 |
| `spawn_packet_day_015_crack_shop_hook` | 15 | 균열 망치 | 2 | 20초 | 7.0초 | `any` | 예 | 구조물 약점과 상점 연결 |
| `spawn_packet_day_016_glass_north` | 16 | 유리 껍질 | 4 | 9초 | 6.0초 | `slow` | 예 | 북쪽 장기 압박 |
| `spawn_packet_day_016_gray_east` | 16 | 회색 행렬 | 10 | 7초 | 1.5초 | `short` | 예 | 동쪽 기본 전선 |
| `spawn_packet_day_016_gray_slow_follow` | 16 | 회색 행렬 | 4 | 20초 | 1.8초 | `slow` | 예 | 장기 압박 보조 |
| `spawn_packet_day_017_gray_break_bg` | 17 | 회색 행렬 | 12 | 7초 | 1.4초 | `short` | 예 | 구조물 압박 전 군집 |
| `spawn_packet_day_017_crack_triple` | 17 | 균열 망치 | 3 | 15초 | 7.0초 | `short` | 예 | 살릴/버릴 구조물 구분 |
| `spawn_packet_day_017_gray_rebuild_check` | 17 | 회색 행렬 | 4 | 31초 | 1.5초 | `short` | 예 | 붕괴 후 재건 확인 |
| `spawn_packet_day_018_gray_stack_decision` | 18 | 회색 행렬 | 14 | 8초 | 1.4초 | `any` | 예 | 겹치기 판단 가능한 밀도 |
| `spawn_packet_day_018_silence_hold_warning` | 18 | 침묵 운반자 | 1 | 23초 | 없음 | `any` | 예 | 방해형 잔존 중 호출 위험 |
| `spawn_packet_day_019_gray_elite_bg` | 19 | 회색 행렬 | 12 | 7초 | 1.4초 | `fast` | 예 | 정예 전 전선 압박 |
| `spawn_packet_day_019_glass_hold` | 19 | 유리 껍질 | 3 | 12초 | 6.0초 | `slow` | 예 | 오래 붙잡을 대상 |
| `spawn_packet_day_019_black_pack_preview` | 19 | 검은 등짐 | 1 | 22초 | 없음 | `fast` | 예 | 정예 처치 타이밍 예고 |
| `spawn_packet_day_020_variant_colossus` | 20 | 침묵의 거상 변형 | 1 | 0초 | 없음 | `boss` | 예 | 변형 보스 |
| `spawn_packet_day_020_optional_gray_companion` | 20 | 회색 행렬 | 8 | 50초 | 2.0초 | `short` | 예 | 선택적 약한 동반 웨이브 |

`spawn_packet_day_020_optional_gray_companion`은 변형 보스가 약한 동반 웨이브를 선택했을 때만 켭니다.

이 패킷은 보상 팩, 카드 후보, 보스 파편을 추가하지 않습니다.

### 21~30일 스폰 패킷 제작표

21~30일 스폰 패킷은 30일 MVP의 마지막 협동 시험을 실제 전투 리듬으로 고정하는 2인 기준 시작값입니다.

| ID | 일자 | 적 | 2인 수량 | 첫 스폰 | 간격 | 방향 역할 | MVP | 검증 |
| --- | ---: | --- | ---: | ---: | ---: | --- | --- | --- |
| `spawn_packet_day_021_gray_elite_screen` | 21 | 회색 행렬 | 14 | 6초 | 1.3초 | `fast` | 예 | 정예 전 빠른 전선 형성 |
| `spawn_packet_day_021_black_pack_timing` | 21 | 검은 등짐 | 1 | 18초 | 없음 | `fast` | 예 | 처치 타이밍 합의 |
| `spawn_packet_day_021_gray_after_boost` | 21 | 회색 행렬 | 6 | 26초 | 1.5초 | `fast` | 예 | 정예 사망 후 가속 위험 확인 |
| `spawn_packet_day_022_gray_killzone_rebuild` | 22 | 회색 행렬 | 12 | 8초 | 1.5초 | `killzone` | 예 | 기존 킬존 진단 |
| `spawn_packet_day_022_glass_killzone_hold` | 22 | 유리 껍질 | 4 | 16초 | 6.0초 | `killzone` | 예 | 광역 의존 견제 |
| `spawn_packet_day_022_gray_repath_check` | 22 | 회색 행렬 | 6 | 28초 | 1.6초 | `killzone` | 예 | 재배치 지연 결과 확인 |
| `spawn_packet_day_023_gray_taunt_baseline` | 23 | 회색 행렬 | 12 | 7초 | 1.6초 | `slow` | 예 | 도발 기준 전선 |
| `spawn_packet_day_023_twisted_mark_pair` | 23 | 뒤틀린 표식 | 2 | 17초 | 9.0초 | `slow` | 예 | 도발 의존 견제 |
| `spawn_packet_day_023_gray_after_mark` | 23 | 회색 행렬 | 6 | 27초 | 1.7초 | `slow` | 예 | 표식 방치 결과 확인 |
| `spawn_packet_day_024_runner_fast_lane` | 24 | 틈새 주자 | 6 | 5초 | 2.1초 | `fast` | 예 | 빠른 라인 담당 확인 |
| `spawn_packet_day_024_silence_short_lane` | 24 | 침묵 운반자 | 2 | 15초 | 10.0초 | `short` | 예 | 방해형 우선 처치 담당 확인 |
| `spawn_packet_day_024_gray_split_fill` | 24 | 회색 행렬 | 10 | 22초 | 1.4초 | `any` | 예 | 기본 압박 유지 |
| `spawn_packet_day_025_gray_season_review` | 25 | 회색 행렬 | 12 | 9초 | 1.6초 | `any` | 예 | 계절 전환 전 기본 전선 진단 |
| `spawn_packet_day_025_crack_repair_check` | 25 | 균열 망치 | 2 | 21초 | 7.0초 | `any` | 예 | 수리/제거 구매 필요 확인 |
| `spawn_packet_day_025_glass_focus_check` | 25 | 유리 껍질 | 2 | 30초 | 7.0초 | `any` | 예 | 단일 집중 화력 확인 |
| `spawn_packet_day_026_runner_summer_preview` | 26 | 틈새 주자 | 8 | 4초 | 1.9초 | `fast` | 예 | 여름 속도 예고 |
| `spawn_packet_day_026_gray_speed_bg` | 26 | 회색 행렬 | 10 | 13초 | 1.3초 | `fast` | 예 | 빠른 전선 뒤 군집 압박 |
| `spawn_packet_day_026_glass_hold_test` | 26 | 유리 껍질 | 2 | 25초 | 6.0초 | `fast` | 예 | 마무리 집중 대상 |
| `spawn_packet_day_027_gray_priority_bg` | 27 | 회색 행렬 | 12 | 7초 | 1.4초 | `any` | 예 | 우선순위 판단 전 기본 압박 |
| `spawn_packet_day_027_silence_pair` | 27 | 침묵 운반자 | 2 | 15초 | 9.0초 | `any` | 예 | 드로우 방해 확인 |
| `spawn_packet_day_027_black_pack_timing` | 27 | 검은 등짐 | 1 | 23초 | 없음 | `any` | 예 | 정예 처치 타이밍 재확인 |
| `spawn_packet_day_027_runner_pressure` | 27 | 틈새 주자 | 4 | 28초 | 2.2초 | `fast` | 예 | 우선순위 중 빠른 누수 |
| `spawn_packet_day_028_gray_density_trial` | 28 | 회색 행렬 | 16 | 7초 | 1.25초 | `any` | 예 | 겹쳐도 읽히는 군집 밀도 |
| `spawn_packet_day_028_crack_weak_breaker` | 28 | 균열 망치 | 3 | 18초 | 6.5초 | `any` | 예 | 안정 상태 흔들기 |
| `spawn_packet_day_028_runner_leak_check` | 28 | 틈새 주자 | 3 | 30초 | 2.3초 | `fast` | 예 | 겹치기 전 누수 위험 |
| `spawn_packet_day_029_gray_final_bg` | 29 | 회색 행렬 | 14 | 6초 | 1.25초 | `any` | 예 | MVP 총정리 기본 밀도 |
| `spawn_packet_day_029_glass_final_hold` | 29 | 유리 껍질 | 4 | 12초 | 5.5초 | `slow` | 예 | 오래 붙잡을 대상 |
| `spawn_packet_day_029_crack_final_break` | 29 | 균열 망치 | 3 | 19초 | 6.5초 | `short` | 예 | 구조물 선택 결과 확인 |
| `spawn_packet_day_029_silence_final_disrupt` | 29 | 침묵 운반자 | 2 | 29초 | 9.0초 | `any` | 예 | 마지막 방해형 대응 |
| `spawn_packet_day_030_observer_preview_body` | 30 | 사계의 관측자 예고형 | 1 | 0초 | 없음 | `boss` | 예 | 후보 방향과 실제 확정 시험 |
| `spawn_packet_day_030_optional_gray_echo` | 30 | 회색 행렬 | 10 | 48초 | 1.8초 | `short` | 예 | 선택적 약한 동반 압박 |

`spawn_packet_day_030_optional_gray_echo`는 30일 보스전이 비어 보일 때만 켭니다.

이 패킷은 보상 팩, 카드 후보, 보스 파편을 추가하지 않습니다.

28일 겹치기 시험은 예약된 27~29일 일반 웨이브의 시간 압축으로만 구성하며, 30일 보스 스폰 플랜을 앞당기지 않습니다.

### 26~30일 여름 예고 브리지 제작표

25일 계절 전환, 26~29일 전투 리포트, 30일 관측자 예고형을 같은 태그 체계로 연결합니다.

| ID | 종류 | MVP | 제작 내용 |
| --- | --- | --- | --- |
| `mvp_summer_preview_bridge_026_030` | 브리지 프로필 | 예 | 26~30일 압박 약속, 리포트 태그, 관측자 후보 참고 태그를 묶음 |
| `summer_preview_report_tags_026_029` | 리포트 태그 묶음 | 예 | 빠른 누수, 우선 타겟, 겹치기 위험, 최종 약점 태그 정의 |
| `observer_preview_candidate_from_recent_active_pressure` | 후보 선정 정책 | 예 | 26~29일 태그를 후보 방향 연출에만 반영하고 실제 방향은 후보 중 1개로 고정 |
| `solo_east_front_mid_rear_projection` | 솔로 투영 정책 | 예 | 동쪽 전방/중간/후방 구간과 스폰 타이밍으로 방향 차이를 대체 |
| `mvp_summer_bridge_forbidden_modifiers` | 금지 태그 묶음 | 예 | 보상, 희귀도, 카드 후보, 골드, 보스 파편, 비활성 방향 변경 금지 |

26~30일 브리지 제작 금지선:

- `season_preview_detail_unlocked`를 스폰 수량, 보상량, 카드 후보 수, 희귀도에 연결하지 않습니다.
- 28일 고밀도 리허설은 보상 효율 버튼이 아니라 기다림 단축과 위험 판단으로만 설명합니다.
- 30일 관측자는 후보 밖 기습 방향을 만들지 않습니다.
- 솔로는 동쪽 외 방향을 실제 방어 대상으로 표시하지 않습니다.

### 41~50일 확정 스폰 패킷 제작표

| ID | 일자 | 적 | 수량 | 첫 스폰 | 간격 | 방향 역할 | MVP | 역할 |
| --- | ---: | --- | ---: | ---: | ---: | --- | --- | --- |
| `spawn_packet_day_041_gray_rebuild_read` | 41 | 회색 행렬 | 14 | 8초 | 1.4초 | `any` | 아니오 | 보스 후 손상 전선 확인 |
| `spawn_packet_day_041_sprinter_rebuild_leak` | 41 | 여름 질주자 | 3 | 22초 | 2.4초 | `fast` | 아니오 | 후방 재건 전 빠른 누수 확인 |
| `spawn_packet_day_041_gray_rear_check` | 41 | 회색 행렬 | 8 | 33초 | 1.5초 | `any` | 아니오 | 후방 킬존 후보 확인 |
| `spawn_packet_day_042_heat_saw_intro` | 42 | 열톱니 | 1 | 12초 | 없음 | `short` | 아니오 | 첫 표식 예고 학습 |
| `spawn_packet_day_042_gray_mark_pressure` | 42 | 회색 행렬 | 14 | 18초 | 1.35초 | `short` | 아니오 | 표식 대상 주변 압박 |
| `spawn_packet_day_042_heat_saw_second_mark` | 42 | 열톱니 | 1 | 31초 | 없음 | `short` | 아니오 | 두 번째 표식 판단 |
| `spawn_packet_day_043_gray_sacrifice_setup` | 43 | 회색 행렬 | 12 | 7초 | 1.35초 | `any` | 아니오 | 버릴 바리케이드 후보 노출 |
| `spawn_packet_day_043_heat_saw_pair` | 43 | 열톱니 | 2 | 16초 | 8.0초 | `any` | 아니오 | 살림/희생 판단 |
| `spawn_packet_day_043_crack_hammer_follow` | 43 | 균열 망치 | 2 | 27초 | 7.0초 | `short` | 아니오 | 모든 구조물 수리 습관 흔들기 |
| `spawn_packet_day_043_gray_after_collapse` | 43 | 회색 행렬 | 6 | 39초 | 1.5초 | `any` | 아니오 | 붕괴 후 재건 확인 |
| `spawn_packet_day_044_sprinter_fast_split` | 44 | 여름 질주자 | 6 | 5초 | 2.0초 | `fast` | 아니오 | 빠른 적 우선순위 |
| `spawn_packet_day_044_heat_saw_structure_split` | 44 | 열톱니 | 2 | 15초 | 7.0초 | `short` | 아니오 | 속도 대응 중 구조물 보호 |
| `spawn_packet_day_044_gray_split_fill` | 44 | 회색 행렬 | 12 | 25초 | 1.35초 | `any` | 아니오 | 군집 처리와 파괴형 우선 처치 |
| `spawn_packet_day_044_sprinter_rear_leak` | 44 | 여름 질주자 | 3 | 37초 | 2.2초 | `fast` | 아니오 | 후방 킬존 빠른 적 커버 확인 |
| `spawn_packet_day_045_gray_market_diagnosis` | 45 | 회색 행렬 | 12 | 9초 | 1.5초 | `any` | 아니오 | 열차단 상점 전 진단 |
| `spawn_packet_day_045_heat_saw_shop_hook` | 45 | 열톱니 | 1 | 21초 | 없음 | `any` | 아니오 | 표식 예고 강화 구매 이유 |
| `spawn_packet_day_045_sprinter_shop_hook` | 45 | 여름 질주자 | 3 | 30초 | 2.4초 | `fast` | 아니오 | 빠른 대응 보완 이유 |
| `spawn_packet_day_046_ember_rotation` | 46 | 잿불 석공 | 2 | 10초 | 8.0초 | `any` | 아니오 | 과열 후보 회전 |
| `spawn_packet_day_046_heat_saw_old_structure` | 46 | 열톱니 | 2 | 19초 | 8.5초 | `any` | 아니오 | 오래 유지한 구조물 표식 |
| `spawn_packet_day_046_gray_heat_choice` | 46 | 회색 행렬 | 16 | 29초 | 1.25초 | `any` | 아니오 | 과열 지점 이동 판단 |
| `spawn_packet_day_046_crack_rebuild_window` | 46 | 균열 망치 | 2 | 40초 | 6.5초 | `short` | 아니오 | 후방 재건 창 확인 |
| `spawn_packet_day_047_gray_candidate_echo` | 47 | 회색 행렬 | 12 | 8초 | 1.45초 | `any` | 아니오 | 후보 방향 예고 학습 |
| `spawn_packet_day_047_sprinter_confirmed_lane` | 47 | 여름 질주자 | 4 | 18초 | 2.2초 | `fast` | 아니오 | 확정 방향 재집결 |
| `spawn_packet_day_047_gray_no_fake_spawn` | 47 | 회색 행렬 | 8 | 30초 | 1.5초 | `any` | 아니오 | 후보 밖 기습 없음 확인 |
| `spawn_packet_day_048_gray_stack_read` | 48 | 회색 행렬 | 16 | 7초 | 1.25초 | `any` | 아니오 | 겹치기 전 전선 읽기 |
| `spawn_packet_day_048_heat_saw_stack_warning` | 48 | 열톱니 | 3 | 15초 | 7.0초 | `any` | 아니오 | 표식 수 기반 겹치기 위험 |
| `spawn_packet_day_048_crack_stack_pressure` | 48 | 균열 망치 | 2 | 29초 | 6.5초 | `short` | 아니오 | 빠른 진행 시 붕괴 위험 |
| `spawn_packet_day_048_gray_after_break` | 48 | 회색 행렬 | 8 | 41초 | 1.35초 | `any` | 아니오 | 겹친 뒤 복구 여유 확인 |
| `spawn_packet_day_049_sprinter_final_fast` | 49 | 여름 질주자 | 6 | 5초 | 2.0초 | `fast` | 아니오 | 여름 2장 총정리 시작 |
| `spawn_packet_day_049_ember_final_heat` | 49 | 잿불 석공 | 2 | 14초 | 8.5초 | `any` | 아니오 | 과열 회전 재확인 |
| `spawn_packet_day_049_heat_saw_final_marks` | 49 | 열톱니 | 3 | 23초 | 7.5초 | `short` | 아니오 | 수리 우선순위와 희생 판단 |
| `spawn_packet_day_049_gray_final_density` | 49 | 회색 행렬 | 18 | 32초 | 1.2초 | `any` | 아니오 | 군집 처리와 후방 재건 |
| `spawn_packet_day_049_crack_final_exposure` | 49 | 균열 망치 | 2 | 44초 | 6.5초 | `any` | 아니오 | 50일 전 취약 구조물 노출 |
| `spawn_packet_day_050_observer_enhanced` | 50 | 사계의 관측자 강화형 | 1 | 0초 | 없음 | `boss` | 아니오 | 후보 방향 분담과 재집결 |
| `spawn_packet_day_050_optional_gray_companion` | 50 | 회색 행렬 | 8 | 48초 | 1.8초 | `short` | 아니오 | 선택적 약한 동반 웨이브 |
| `spawn_packet_day_050_optional_heat_saw_mark` | 50 | 열톱니 | 1 | 75초 | 없음 | `any` | 아니오 | 선택적 표식 압박 1회 |

50일의 선택적 동반 패킷은 보상 팩, 카드 후보, 보스 파편을 추가하지 않습니다.

48일 겹치기 시험은 47~49일 일반 웨이브의 시간 압축으로만 구성하며, 50일 보스 스폰 플랜을 앞당기지 않습니다.

### 51~60일 확정 스폰 패킷 제작표

51~60일 스폰 패킷은 가을 1장의 경로 재설계 리듬을 실제 전투 타이밍으로 고정하는 2인 기준 시작값입니다.

| ID | 일자 | 적 | 수량 | 첫 스폰 | 간격 | 방향 역할 | MVP | 역할 |
| --- | ---: | --- | ---: | ---: | ---: | --- | --- | --- |
| `spawn_packet_day_051_gray_leaf_intro` | 51 | 회색 행렬 | 14 | 8초 | 1.4초 | `any` | 아니오 | 낙엽 경로 비용 첫 읽기 |
| `spawn_packet_day_051_glass_leaf_hold` | 51 | 유리 껍질 | 3 | 21초 | 6.5초 | `slow` | 아니오 | 느린 길에서 오래 붙잡을 대상 |
| `spawn_packet_day_051_gray_after_leaf` | 51 | 회색 행렬 | 8 | 34초 | 1.5초 | `any` | 아니오 | 낙엽 변화 후 경로 확인 |
| `spawn_packet_day_052_gray_mute_setup` | 52 | 회색 행렬 | 12 | 8초 | 1.4초 | `any` | 아니오 | 묵자 전 기본 전선 |
| `spawn_packet_day_052_autumn_mute_intro` | 52 | 가을의 묵자 | 1 | 16초 | 없음 | `any` | 아니오 | 마나 방해형 첫 인식 |
| `spawn_packet_day_052_gray_under_mute` | 52 | 회색 행렬 | 10 | 24초 | 1.4초 | `any` | 아니오 | 묵자 방치 시 대응 지연 확인 |
| `spawn_packet_day_052_autumn_mute_second` | 52 | 가을의 묵자 | 1 | 38초 | 없음 | `any` | 아니오 | 두 번째 우선 처치 판단 |
| `spawn_packet_day_053_gray_debris_setup` | 53 | 회색 행렬 | 10 | 7초 | 1.4초 | `short` | 아니오 | 잔해 생성 전 기본 라인 |
| `spawn_packet_day_053_crack_long_debris` | 53 | 균열 망치 | 2 | 15초 | 7.0초 | `short` | 아니오 | 오래 남는 잔해 생성 |
| `spawn_packet_day_053_autumn_mute_repath` | 53 | 가을의 묵자 | 1 | 27초 | 없음 | `short` | 아니오 | 재배치 중 마나 압박 |
| `spawn_packet_day_053_gray_reopen_check` | 53 | 회색 행렬 | 8 | 36초 | 1.5초 | `short` | 아니오 | 밟힌 잔해 경로 재개방 확인 |
| `spawn_packet_day_054_gray_reroute_read` | 54 | 회색 행렬 | 14 | 7초 | 1.35초 | `any` | 아니오 | 낙엽 우회 전 경로 읽기 |
| `spawn_packet_day_054_sprinter_reroute_leak` | 54 | 여름 질주자 | 4 | 18초 | 2.2초 | `fast` | 아니오 | 이동 전 누수 위험 |
| `spawn_packet_day_054_gray_after_reroute` | 54 | 회색 행렬 | 10 | 30초 | 1.4초 | `any` | 아니오 | 변화 후 새 킬존 확인 |
| `spawn_packet_day_054_sprinter_late_check` | 54 | 여름 질주자 | 2 | 42초 | 2.4초 | `fast` | 아니오 | 후방 보조선 확인 |
| `spawn_packet_day_055_gray_market_route` | 55 | 회색 행렬 | 14 | 9초 | 1.5초 | `any` | 아니오 | 상점 전 기본 약점 진단 |
| `spawn_packet_day_055_autumn_mute_shop_hook` | 55 | 가을의 묵자 | 1 | 22초 | 없음 | `any` | 아니오 | 방해 저항 구매 이유 |
| `spawn_packet_day_055_glass_shop_hold` | 55 | 유리 껍질 | 2 | 32초 | 7.0초 | `slow` | 아니오 | 수리/지속 화력 구매 이유 |
| `spawn_packet_day_056_glass_split_hold` | 56 | 유리 껍질 | 4 | 9초 | 6.0초 | `slow` | 아니오 | 한곳 밀집 화력 의존 확인 |
| `spawn_packet_day_056_autumn_mute_aura` | 56 | 가을의 묵자 | 2 | 18초 | 10.0초 | `any` | 아니오 | 오라 주변 자원 압박 |
| `spawn_packet_day_056_gray_second_zone` | 56 | 회색 행렬 | 12 | 28초 | 1.4초 | `any` | 아니오 | 보조 킬존 필요성 확인 |
| `spawn_packet_day_056_glass_late_anchor` | 56 | 유리 껍질 | 2 | 44초 | 7.0초 | `slow` | 아니오 | 분산 후 오래 붙잡을 대상 |
| `spawn_packet_day_057_gray_stack_route` | 57 | 회색 행렬 | 16 | 7초 | 1.3초 | `any` | 아니오 | 겹치기 전 경로 상태 읽기 |
| `spawn_packet_day_057_silence_stack_warning` | 57 | 침묵 운반자 | 2 | 17초 | 9.0초 | `any` | 아니오 | 방해형 잔존 중 빠른 진행 위험 |
| `spawn_packet_day_057_crack_stack_route` | 57 | 균열 망치 | 2 | 29초 | 7.0초 | `short` | 아니오 | 잔해/파괴 압박 중 호출 위험 |
| `spawn_packet_day_057_gray_after_warning` | 57 | 회색 행렬 | 8 | 42초 | 1.4초 | `any` | 아니오 | 호출 후 복구 가능성 확인 |
| `spawn_packet_day_058_crack_mobile_front` | 58 | 균열 망치 | 3 | 8초 | 6.5초 | `killzone` | 아니오 | 이동 킬존 앞쪽 잔해 생성 |
| `spawn_packet_day_058_twisted_mark_shift` | 58 | 뒤틀린 표식 | 2 | 19초 | 9.0초 | `killzone` | 아니오 | 도발 의존 흔들기 |
| `spawn_packet_day_058_gray_mobile_fill` | 58 | 회색 행렬 | 14 | 29초 | 1.35초 | `killzone` | 아니오 | 새 굴곡에 화력 맞추기 |
| `spawn_packet_day_058_crack_rear_reopen` | 58 | 균열 망치 | 1 | 43초 | 없음 | `killzone` | 아니오 | 후방 잔해 재개방 확인 |
| `spawn_packet_day_059_gray_recap_density` | 59 | 회색 행렬 | 18 | 6초 | 1.25초 | `any` | 아니오 | 가을 1장 총정리 밀도 |
| `spawn_packet_day_059_autumn_mute_recap` | 59 | 가을의 묵자 | 2 | 16초 | 9.5초 | `any` | 아니오 | 마나 방해 우선순위 재확인 |
| `spawn_packet_day_059_twisted_mark_recap` | 59 | 뒤틀린 표식 | 2 | 27초 | 9.0초 | `any` | 아니오 | 도발 의존 재점검 |
| `spawn_packet_day_059_glass_recap_hold` | 59 | 유리 껍질 | 2 | 38초 | 7.0초 | `slow` | 아니오 | 분산 화력 유지 확인 |
| `spawn_packet_day_059_gray_final_bend` | 59 | 회색 행렬 | 8 | 48초 | 1.35초 | `any` | 아니오 | 보스 전 마지막 이동 킬존 확인 |
| `spawn_packet_day_060_fallen_belltower_body` | 60 | 무너진 종탑 | 1 | 0초 | 없음 | `boss` | 아니오 | 무음 권역과 재집결 판단 |
| `spawn_packet_day_060_optional_gray_companion` | 60 | 회색 행렬 | 8 | 46초 | 1.8초 | `short` | 아니오 | 선택적 약한 동반 웨이브 |
| `spawn_packet_day_060_optional_glass_companion` | 60 | 유리 껍질 | 2 | 78초 | 7.0초 | `slow` | 아니오 | 선택적 장기 압박 보조 |

57일 겹치기 시험은 57~59일 일반 웨이브의 시간 압축으로만 구성하며, 60일 보스 스폰 플랜을 앞당기지 않습니다.

60일의 선택적 동반 패킷은 보스전이 비어 보일 때만 사용하며, 보상 팩, 카드 후보, 보스 파편, 아티팩트 드롭 수를 추가하지 않습니다.

### 61~70일 확정 스폰 패킷 제작표

61~70일 스폰 패킷은 가을 2장의 방해형/정예 우선순위 리듬을 실제 전투 타이밍으로 고정하는 2인 기준 시작값입니다.

| ID | 일자 | 적 | 수량 | 첫 스폰 | 간격 | 방향 역할 | MVP | 역할 |
| --- | ---: | --- | ---: | ---: | ---: | --- | --- | --- |
| `spawn_packet_day_061_gray_realign_read` | 61 | 회색 행렬 | 14 | 8초 | 1.35초 | `any` | 아니오 | 종탑 후 기본 전선 재확인 |
| `spawn_packet_day_061_glass_realign_hold` | 61 | 유리 껍질 | 2 | 21초 | 7.0초 | `slow` | 아니오 | 오라 재배치 후 지속 화력 확인 |
| `spawn_packet_day_061_gray_ping_rebuild` | 61 | 회색 행렬 | 10 | 34초 | 1.45초 | `any` | 아니오 | 우선 처치 핑 위치 재정렬 |
| `spawn_packet_day_062_gray_priority_bg` | 62 | 회색 행렬 | 12 | 7초 | 1.35초 | `any` | 아니오 | 우선순위 판단 배경 압박 |
| `spawn_packet_day_062_autumn_mute_first` | 62 | 가을의 묵자 | 1 | 15초 | 없음 | `any` | 아니오 | 마나 방해형 먼저 끊기 |
| `spawn_packet_day_062_black_pack_choice` | 62 | 검은 등짐 | 1 | 24초 | 없음 | `any` | 아니오 | 정예 처치 타이밍 비교 |
| `spawn_packet_day_062_gray_after_choice` | 62 | 회색 행렬 | 10 | 32초 | 1.4초 | `any` | 아니오 | 첫 선택 결과 확인 |
| `spawn_packet_day_062_autumn_mute_second` | 62 | 가을의 묵자 | 1 | 44초 | 없음 | `any` | 아니오 | 두 번째 방해형 재판단 |
| `spawn_packet_day_063_gray_rear_screen` | 63 | 회색 행렬 | 16 | 7초 | 1.3초 | `short` | 아니오 | 후미 정예 전 일반 무리 |
| `spawn_packet_day_063_black_pack_rear_warned` | 63 | 검은 등짐 | 1 | 24초 | 없음 | `short` | 아니오 | 예고된 후미 정예 집중 |
| `spawn_packet_day_063_gray_after_elite` | 63 | 회색 행렬 | 8 | 34초 | 1.4초 | `short` | 아니오 | 정예 후 잔여 전선 |
| `spawn_packet_day_063_gray_late_cover` | 63 | 회색 행렬 | 6 | 45초 | 1.5초 | `short` | 아니오 | 늦은 집중 실패 확인 |
| `spawn_packet_day_064_gray_leaf_cross` | 64 | 회색 행렬 | 12 | 7초 | 1.35초 | `any` | 아니오 | 낙엽 교차 전 기본 전선 |
| `spawn_packet_day_064_autumn_mute_cross` | 64 | 가을의 묵자 | 1 | 16초 | 없음 | `any` | 아니오 | 경로 변화 중 자원 방해 |
| `spawn_packet_day_064_glass_cross_hold` | 64 | 유리 껍질 | 3 | 25초 | 6.5초 | `slow` | 아니오 | 바뀐 경로에서 오래 붙잡을 대상 |
| `spawn_packet_day_064_autumn_mute_late` | 64 | 가을의 묵자 | 1 | 39초 | 없음 | `any` | 아니오 | 두 번째 마나 방해 대응 |
| `spawn_packet_day_064_gray_after_leaf` | 64 | 회색 행렬 | 10 | 47초 | 1.4초 | `any` | 아니오 | 변화 후 복구 확인 |
| `spawn_packet_day_065_gray_harvest_diagnosis` | 65 | 회색 행렬 | 14 | 9초 | 1.5초 | `any` | 아니오 | 수확 상점 전 진단 |
| `spawn_packet_day_065_black_pack_preview` | 65 | 검은 등짐 | 1 | 24초 | 없음 | `any` | 아니오 | 정예 집중 보완 구매 이유 |
| `spawn_packet_day_065_autumn_mute_shop_hook` | 65 | 가을의 묵자 | 1 | 36초 | 없음 | `any` | 아니오 | 방해 저항 구매 이유 |
| `spawn_packet_day_065_gray_after_preview` | 65 | 회색 행렬 | 6 | 45초 | 1.5초 | `any` | 아니오 | 정비 전 마무리 확인 |
| `spawn_packet_day_066_gray_split_baseline` | 66 | 회색 행렬 | 12 | 7초 | 1.35초 | `any` | 아니오 | 두 방향 분담 전 기본 압박 |
| `spawn_packet_day_066_autumn_mute_lane` | 66 | 가을의 묵자 | 2 | 17초 | 10.0초 | `slow` | 아니오 | 한쪽 방향 자원 방해 담당 |
| `spawn_packet_day_066_black_pack_lane` | 66 | 검은 등짐 | 1 | 24초 | 없음 | `fast` | 아니오 | 다른 방향 정예 담당 |
| `spawn_packet_day_066_gray_help_decision` | 66 | 회색 행렬 | 12 | 35초 | 1.35초 | `any` | 아니오 | 서로 도울지 분담할지 확인 |
| `spawn_packet_day_067_gray_stack_bg` | 67 | 회색 행렬 | 16 | 7초 | 1.3초 | `any` | 아니오 | 겹치기 전 기본 밀도 |
| `spawn_packet_day_067_silence_carrier_stack` | 67 | 침묵 운반자 | 2 | 17초 | 9.0초 | `any` | 아니오 | 드로우 방해형 잔존 위험 |
| `spawn_packet_day_067_autumn_mute_stack` | 67 | 가을의 묵자 | 1 | 29초 | 없음 | `any` | 아니오 | 마나 방해형 잔존 위험 |
| `spawn_packet_day_067_gray_after_silence` | 67 | 회색 행렬 | 10 | 41초 | 1.4초 | `any` | 아니오 | 방해형 처리 후 복구 확인 |
| `spawn_packet_day_068_crack_debris_setup` | 68 | 균열 망치 | 2 | 8초 | 7.0초 | `killzone` | 아니오 | 잔해 정예 라인 생성 |
| `spawn_packet_day_068_heavy_pilgrim_lane` | 68 | 무거운 순례자 | 1 | 18초 | 없음 | `killzone` | 아니오 | 지속 화력 집중 대상 |
| `spawn_packet_day_068_gray_debris_fill` | 68 | 회색 행렬 | 14 | 29초 | 1.4초 | `killzone` | 아니오 | 잔해 둔화 중 군집 처리 |
| `spawn_packet_day_068_crack_late_reopen` | 68 | 균열 망치 | 1 | 43초 | 없음 | `killzone` | 아니오 | 늦은 잔해 재개방 확인 |
| `spawn_packet_day_069_gray_recap_bg` | 69 | 회색 행렬 | 18 | 6초 | 1.25초 | `any` | 아니오 | 가을 2장 총정리 밀도 |
| `spawn_packet_day_069_autumn_mute_recap` | 69 | 가을의 묵자 | 2 | 16초 | 9.0초 | `any` | 아니오 | 자원 방해 우선순위 재확인 |
| `spawn_packet_day_069_black_pack_recap` | 69 | 검은 등짐 | 1 | 25초 | 없음 | `any` | 아니오 | 정예 처치 타이밍 재확인 |
| `spawn_packet_day_069_twisted_mark_recap` | 69 | 뒤틀린 표식 | 2 | 34초 | 8.5초 | `any` | 아니오 | 도발 의존과 우선 처치 충돌 |
| `spawn_packet_day_069_gray_final_priority` | 69 | 회색 행렬 | 10 | 46초 | 1.35초 | `any` | 아니오 | 보스 전 마지막 우선순위 확인 |
| `spawn_packet_day_070_belltower_variant_body` | 70 | 무너진 종탑 변형 | 1 | 0초 | 없음 | `boss` | 아니오 | 무음 권역 중 우선순위 판단 |
| `spawn_packet_day_070_optional_black_pack_companion` | 70 | 검은 등짐 | 1 | 52초 | 없음 | `any` | 아니오 | 선택적 약한 정예 동반 |
| `spawn_packet_day_070_optional_gray_pressure` | 70 | 회색 행렬 | 8 | 65초 | 1.8초 | `short` | 아니오 | 선택적 약한 군집 동반 |
| `spawn_packet_day_070_optional_autumn_mute_companion` | 70 | 가을의 묵자 | 1 | 72초 | 없음 | `any` | 아니오 | 선택적 약한 방해형 동반 |

67일 겹치기 시험은 67~69일 일반 웨이브의 시간 압축으로만 구성하며, 70일 보스 스폰 플랜을 앞당기지 않습니다.

70일 동반 웨이브는 위 선택적 패킷 중 하나만 사용할 수 있습니다.

70일 선택적 동반 패킷은 보상 팩, 카드 후보, 보스 파편, 아티팩트 드롭 수를 추가하지 않습니다.

### 71~80일 확정 스폰 패킷 제작표

71~80일 스폰 패킷은 겨울 1장의 설치 공간 축소 리듬을 실제 전투 타이밍으로 고정하는 2인 기준 시작값입니다.

| ID | 일자 | 적 | 수량 | 첫 스폰 | 간격 | 방향 역할 | MVP | 역할 |
| --- | ---: | --- | ---: | ---: | ---: | --- | --- | --- |
| `spawn_packet_day_071_gray_first_frost` | 71 | 회색 행렬 | 16 | 8초 | 1.35초 | `any` | 아니오 | 첫 결빙 예고 후 기본 전선 확인 |
| `spawn_packet_day_071_gray_after_frost` | 71 | 회색 행렬 | 10 | 28초 | 1.45초 | `any` | 아니오 | 결빙 예정지 밖 설치 확인 |
| `spawn_packet_day_072_gray_husk_setup` | 72 | 회색 행렬 | 14 | 7초 | 1.35초 | `short` | 아니오 | 겨울 껍질 전 기본 라인 |
| `spawn_packet_day_072_winter_husk_intro` | 72 | 겨울 껍질 | 1 | 18초 | 없음 | `short` | 아니오 | 느린 저항형 첫 등장 |
| `spawn_packet_day_072_gray_after_husk` | 72 | 회색 행렬 | 8 | 36초 | 1.5초 | `short` | 아니오 | 지속 화력 유지 확인 |
| `spawn_packet_day_073_glass_narrow_hold` | 73 | 유리 껍질 | 4 | 8초 | 6.5초 | `slow` | 아니오 | 좁아진 설치 공간에서 장기 처리 |
| `spawn_packet_day_073_winter_husk_inner` | 73 | 겨울 껍질 | 1 | 20초 | 없음 | `any` | 아니오 | 안쪽 킬존 후보 확인 |
| `spawn_packet_day_073_gray_inner_fill` | 73 | 회색 행렬 | 12 | 34초 | 1.4초 | `any` | 아니오 | 후방 보조선 확인 |
| `spawn_packet_day_074_heavy_pilgrim_slow` | 74 | 무거운 순례자 | 1 | 10초 | 없음 | `slow` | 아니오 | 느린 압박 라인 시작 |
| `spawn_packet_day_074_winter_husk_pair` | 74 | 겨울 껍질 | 2 | 22초 | 10.0초 | `slow` | 아니오 | 둔화/도발/지속 화력 유지 |
| `spawn_packet_day_074_gray_slow_fill` | 74 | 회색 행렬 | 10 | 38초 | 1.45초 | `slow` | 아니오 | 대형 적 처리 중 기본 전선 |
| `spawn_packet_day_075_gray_thaw_diagnosis` | 75 | 회색 행렬 | 14 | 9초 | 1.5초 | `any` | 아니오 | 계절 전환 정비 전 진단 |
| `spawn_packet_day_075_winter_husk_shop_hook` | 75 | 겨울 껍질 | 1 | 25초 | 없음 | `any` | 아니오 | 대형 적 대응 구매 이유 |
| `spawn_packet_day_075_gray_after_shop_hook` | 75 | 회색 행렬 | 8 | 42초 | 1.5초 | `any` | 아니오 | 이전/해동 필요성 확인 |
| `spawn_packet_day_076_gray_full_winter` | 76 | 회색 행렬 | 18 | 7초 | 1.3초 | `any` | 아니오 | 겨울 본격화 기본 밀도 |
| `spawn_packet_day_076_winter_husk_double` | 76 | 겨울 껍질 | 2 | 19초 | 10.0초 | `any` | 아니오 | 활성 방향별 결빙 증가 대응 |
| `spawn_packet_day_076_gray_after_outer2` | 76 | 회색 행렬 | 10 | 39초 | 1.4초 | `any` | 아니오 | 외곽 2개 결빙 후 복구 |
| `spawn_packet_day_077_winter_husk_repair` | 77 | 겨울 껍질 | 2 | 8초 | 10.0초 | `any` | 아니오 | 얼어붙은 수리 우선순위 |
| `spawn_packet_day_077_crack_frozen_repair` | 77 | 균열 망치 | 2 | 24초 | 7.0초 | `any` | 아니오 | 결빙 구조물 살림/포기 선택 |
| `spawn_packet_day_077_gray_repair_fill` | 77 | 회색 행렬 | 12 | 36초 | 1.4초 | `any` | 아니오 | 수리 판단 중 기본 전선 |
| `spawn_packet_day_078_gray_stack_space` | 78 | 회색 행렬 | 18 | 7초 | 1.3초 | `any` | 아니오 | 겹치기 전 남은 공간 읽기 |
| `spawn_packet_day_078_winter_husk_stack` | 78 | 겨울 껍질 | 1 | 20초 | 없음 | `any` | 아니오 | 공간 부족 상태의 지속 화력 |
| `spawn_packet_day_078_gray_after_space` | 78 | 회색 행렬 | 12 | 39초 | 1.4초 | `any` | 아니오 | 빠른 진행 후 복구 확인 |
| `spawn_packet_day_079_gray_winter_recap` | 79 | 회색 행렬 | 16 | 6초 | 1.25초 | `any` | 아니오 | 겨울 1장 총정리 밀도 |
| `spawn_packet_day_079_winter_husk_recap` | 79 | 겨울 껍질 | 2 | 17초 | 9.5초 | `any` | 아니오 | 느린 저항형 처리 재확인 |
| `spawn_packet_day_079_heavy_pilgrim_recap` | 79 | 무거운 순례자 | 1 | 30초 | 없음 | `slow` | 아니오 | 대형 적 지속 화력 재확인 |
| `spawn_packet_day_079_twisted_mark_space` | 79 | 뒤틀린 표식 | 2 | 42초 | 8.5초 | `any` | 아니오 | 결빙 중 도발 의존 흔들기 |
| `spawn_packet_day_079_gray_final_space` | 79 | 회색 행렬 | 8 | 52초 | 1.35초 | `any` | 아니오 | 80일 전 후방 킬존 확인 |
| `spawn_packet_day_080_winter_gate_preview_body` | 80 | 겨울의 문 예고형 | 1 | 0초 | 없음 | `boss` | 아니오 | 임시 결빙 권역 예고 |
| `spawn_packet_day_080_optional_winter_husk_companion` | 80 | 겨울 껍질 | 1 | 70초 | 없음 | `slow` | 아니오 | 선택적 약한 대형 동반 |
| `spawn_packet_day_080_optional_gray_companion` | 80 | 회색 행렬 | 8 | 92초 | 1.8초 | `short` | 아니오 | 선택적 약한 일반 전선 |

78일 겹치기 시험은 78~79일 일반 웨이브의 시간 압축으로만 구성하며, 80일 보스 스폰 플랜을 앞당기지 않습니다.

80일 선택적 동반 패킷은 보스전이 비어 보일 때만 사용하며, 보상 팩, 카드 후보, 보스 파편, 아티팩트 드롭 수를 추가하지 않습니다.

80일 결빙은 임시 설치 권역 제한만 사용하며, 경로 타일 차단이나 장기 공간 봉쇄를 만들지 않습니다.

### 81~90일 확정 스폰 패킷 제작표

81~90일 스폰 패킷은 겨울 2장의 압력 권역과 마지막 킬존 이전 리듬을 실제 전투 타이밍으로 고정하는 2인 기준 시작값입니다.

| ID | 일자 | 적 | 수량 | 첫 등장 | 간격 | 방향 역할 | MVP | 역할 |
| --- | ---: | --- | ---: | ---: | ---: | --- | --- | --- |
| `spawn_packet_day_081_gray_rebuild_check` | 81 | 회색 행렬 | 16 | 8초 | 1.45초 | `any` | 아니오 | 80일 이후 후방 후보 재확인 |
| `spawn_packet_day_081_gray_rear_probe` | 81 | 회색 행렬 | 10 | 32초 | 1.65초 | `rear` | 아니오 | 압력 전 보조선 설치 확인 |
| `spawn_packet_day_082_gray_pressure_intro` | 82 | 회색 행렬 | 14 | 8초 | 1.5초 | `short` | 아니오 | 첫 압력 전 안전한 군집 |
| `spawn_packet_day_082_gray_after_pressure` | 82 | 회색 행렬 | 12 | 34초 | 1.6초 | `short` | 아니오 | 압력 밖 보조 화력 확인 |
| `spawn_packet_day_083_winter_husk_pressure` | 83 | 겨울 껍질 | 1 | 10초 | 없음 | `slow` | 아니오 | 압력 밖 대형 적 지연 |
| `spawn_packet_day_083_glass_under_pressure` | 83 | 유리 껍질 | 4 | 24초 | 3.2초 | `any` | 아니오 | 지속 화력 확인 |
| `spawn_packet_day_083_gray_pressure_fill` | 83 | 회색 행렬 | 14 | 40초 | 1.45초 | `any` | 아니오 | 보조 킬존 군집 처리 |
| `spawn_packet_day_084_heavy_centerline` | 84 | 무거운 순례자 | 1 | 10초 | 없음 | `slow` | 아니오 | 전방 포기와 중후방 지연 |
| `spawn_packet_day_084_winter_husk_centerline` | 84 | 겨울 껍질 | 1 | 26초 | 없음 | `slow` | 아니오 | 압력 중 대형 적 유지 |
| `spawn_packet_day_084_gray_centerline_fill` | 84 | 회색 행렬 | 12 | 42초 | 1.55초 | `any` | 아니오 | 이전 후 남은 화력 확인 |
| `spawn_packet_day_085_gray_market_ease` | 85 | 회색 행렬 | 18 | 8초 | 1.45초 | `any` | 아니오 | 마지막 재설계 전 부담 완화 |
| `spawn_packet_day_085_twisted_shop_hook` | 85 | 뒤틀린 표식 | 1 | 26초 | 없음 | `any` | 아니오 | 압력 예고/해동 선택 근거 |
| `spawn_packet_day_085_gray_after_choice` | 85 | 회색 행렬 | 8 | 42초 | 1.7초 | `any` | 아니오 | 상점 전 잔여 대응 확인 |
| `spawn_packet_day_086_gray_rotation_probe` | 86 | 회색 행렬 | 16 | 7초 | 1.4초 | `any` | 아니오 | 압력 회전 전 군집 |
| `spawn_packet_day_086_winter_husk_rotation` | 86 | 겨울 껍질 | 2 | 20초 | 9초 | `slow` | 아니오 | 이동 압력 중 대형 적 지연 |
| `spawn_packet_day_086_twisted_rotation` | 86 | 뒤틀린 표식 | 2 | 38초 | 8초 | `any` | 아니오 | 도발 의존 흔들기 |
| `spawn_packet_day_086_gray_after_rotation` | 86 | 회색 행렬 | 10 | 54초 | 1.5초 | `any` | 아니오 | 두 번째 화력 지점 확인 |
| `spawn_packet_day_087_gray_stack_pressure` | 87 | 회색 행렬 | 22 | 6초 | 1.35초 | `any` | 아니오 | 겹치기 전 남은 설치 공간 확인 |
| `spawn_packet_day_087_winter_husk_stack` | 87 | 겨울 껍질 | 1 | 19초 | 없음 | `slow` | 아니오 | 압력 중 대형 적 부담 |
| `spawn_packet_day_087_crack_stack_pressure` | 87 | 균열 망치 | 2 | 34초 | 6초 | `short` | 아니오 | 압력 안 핵심 구조물 위험 |
| `spawn_packet_day_087_gray_after_stack` | 87 | 회색 행렬 | 10 | 49초 | 1.45초 | `any` | 아니오 | 겹치기 승인/보류 결과 확인 |
| `spawn_packet_day_088_heavy_last_shift` | 88 | 무거운 순례자 | 1 | 9초 | 없음 | `slow` | 아니오 | 마지막 킬존 이전 압박 |
| `spawn_packet_day_088_crack_last_shift` | 88 | 균열 망치 | 2 | 24초 | 6.5초 | `short` | 아니오 | 버릴 구조물과 살릴 구조물 판단 |
| `spawn_packet_day_088_gray_last_shift` | 88 | 회색 행렬 | 14 | 39초 | 1.45초 | `killzone` | 아니오 | 후방 킬존 화력 확인 |
| `spawn_packet_day_089_gray_recap` | 89 | 회색 행렬 | 16 | 7초 | 1.35초 | `any` | 아니오 | 겨울 2장 총정리 시작 |
| `spawn_packet_day_089_winter_husk_recap` | 89 | 겨울 껍질 | 2 | 20초 | 9초 | `slow` | 아니오 | 압력 밖 지속 화력 재확인 |
| `spawn_packet_day_089_autumn_mute_recap` | 89 | 가을의 묵자 | 1 | 34초 | 없음 | `any` | 아니오 | 방해형 우선순위 회수 |
| `spawn_packet_day_089_heavy_recap` | 89 | 무거운 순례자 | 1 | 45초 | 없음 | `slow` | 아니오 | 최종 이전 전 대형 적 지연 |
| `spawn_packet_day_089_twisted_recap` | 89 | 뒤틀린 표식 | 2 | 57초 | 8초 | `any` | 아니오 | 도발/부위 우선순위 흔들기 |
| `spawn_packet_day_090_winter_gate_body` | 90 | 겨울의 문 | 1 | 0초 | 없음 | `boss` | 아니오 | 이동 압력 타일 보스 |
| `spawn_packet_day_090_optional_winter_husk_companion` | 90 | 겨울 껍질 | 1 | 85초 | 없음 | `slow` | 아니오 | 선택적 약한 대형 동반 |
| `spawn_packet_day_090_optional_gray_companion` | 90 | 회색 행렬 | 10 | 110초 | 1.7초 | `short` | 아니오 | 선택적 약한 일반 전선 |

### 81~90일 압력 계획 제작표

| ID | 일자 | 예고/지속 | 동시 권역 | 이동 | 역할 |
| --- | ---: | --- | ---: | --- | --- |
| `pressure_plan_day_081_rebuild_none` | 81 | 없음 | 0 | 없음 | 80일 이후 후방 후보만 표시 |
| `pressure_plan_day_082_front_intro` | 82 | 5초/8초 | 1 | 전방 1회 | 첫 보스 압력 타일 학습 |
| `pressure_plan_day_083_husk_anchor` | 83 | 5초/8초 | 1 | 전방에서 중간 후보 예고 | 대형 적을 압력 밖으로 끌기 |
| `pressure_plan_day_084_centerline_squeeze` | 84 | 5초/9초 | 1 | 중심선 1회 | 전방 킬존 포기 유도 |
| `pressure_plan_day_085_market_preview_static` | 85 | 예고만 | 0 | 다음 5일 후보 표시 | 마지막 재설계 상점 선택 근거 |
| `pressure_plan_day_086_rotation_two_step` | 86 | 5초/9초 | 1 | 전방 -> 중간 | 압력 이동 학습 |
| `pressure_plan_day_087_stack_pressure_warning` | 87 | 5초/9초 | 1 | 현재 압력 -> 다음 후보 | 겹치기 위험 판단 |
| `pressure_plan_day_088_last_killzone_shift` | 88 | 5초/10초 | 1 | 중간 -> 후방 후보 | 마지막 킬존 이전 |
| `pressure_plan_day_089_recap_rotation` | 89 | 5초/10초 | 1 | 전방 -> 중간 -> 후방 후보 예고 | 겨울 2장 총정리 |
| `pressure_plan_day_090_boss_moving_preview` | 90 | 5초/10초 | 1 | 보스 단계가 관리 | 100일급 장기 압력 금지 |

87일 겹치기 시험은 87~89일 일반 웨이브의 시간 압축으로만 구성하며, 90일 보스 스폰 플랜을 앞당기지 않습니다.

90일 선택적 동반 패킷은 보스전이 비어 보일 때만 사용하며, 보상 팩, 카드 후보, 보스 파편, 아티팩트 드롭 수를 추가하지 않습니다.

90일 압력 계획은 이동 압력 예고만 사용하며, 경로 타일 차단이나 100일급 장기 압력 권역을 만들지 않습니다.

### 91~99일 최종 리허설 스폰 패킷 제작표

91~99일 스폰 패킷은 마지막 방어선 점검, 약점 재확인, 마지막 이전, 보상 없는 겹치기 판단을 실제 전투 타이밍으로 고정하는 2인 기준 시작값입니다.

| ID | 일자 | 적 | 수량 | 첫 등장 | 간격 | 방향 역할 | MVP | 역할 |
| --- | ---: | --- | ---: | ---: | ---: | --- | --- | --- |
| `spawn_packet_day_091_gray_audit_line` | 91 | 회색 행렬 | 14 | 9초 | 1.6초 | `any` | 아니오 | 마지막 방어선 기본 화력 확인 |
| `spawn_packet_day_091_winter_husk_audit` | 91 | 겨울 껍질 | 1 | 28초 | 없음 | `slow` | 아니오 | 대형 적을 후방 킬존까지 늦출 수 있는지 확인 |
| `spawn_packet_day_091_gray_rear_probe` | 91 | 회색 행렬 | 8 | 44초 | 1.7초 | `rear` | 아니오 | 91일 점검에서 고른 후방 후보 확인 |
| `spawn_packet_day_092_sprinter_fast_check` | 92 | 여름 질주자 | 6 | 5초 | 2.0초 | `fast` | 아니오 | 빠른 라인 최종 점검 |
| `spawn_packet_day_092_gap_runner_follow` | 92 | 틈새 주자 | 8 | 15초 | 2.1초 | `fast` | 예 | 둔화/도발/넉백 타이밍 확인 |
| `spawn_packet_day_092_gray_after_fast` | 92 | 회색 행렬 | 12 | 30초 | 1.45초 | `any` | 아니오 | 빠른 적 처리 후 기본 전선 복구 |
| `spawn_packet_day_093_gray_silence_setup` | 93 | 회색 행렬 | 12 | 8초 | 1.45초 | `any` | 아니오 | 방해형 등장 전 기본 밀도 |
| `spawn_packet_day_093_silence_carrier_final` | 93 | 침묵 운반자 | 2 | 18초 | 9.0초 | `any` | 예 | 드로우 방해 우선 처치 확인 |
| `spawn_packet_day_093_autumn_mute_final` | 93 | 가을의 묵자 | 1 | 33초 | 없음 | `any` | 아니오 | 마나 방해와 드로우 방해 구분 |
| `spawn_packet_day_093_gray_after_mute` | 93 | 회색 행렬 | 8 | 45초 | 1.6초 | `any` | 아니오 | 방해형 처리 후 자원 흐름 회복 확인 |
| `spawn_packet_day_094_gray_structure_setup` | 94 | 회색 행렬 | 14 | 8초 | 1.45초 | `short` | 아니오 | 핵심 구조물 주변 기본 압박 |
| `spawn_packet_day_094_heat_saw_final` | 94 | 열톱니 | 2 | 19초 | 7.0초 | `short` | 아니오 | 약해진 구조물 표식 재확인 |
| `spawn_packet_day_094_crack_hammer_final` | 94 | 균열 망치 | 3 | 32초 | 6.5초 | `short` | 예 | 살릴 구조물과 버릴 구조물 선택 |
| `spawn_packet_day_094_gray_after_break` | 94 | 회색 행렬 | 8 | 50초 | 1.6초 | `any` | 아니오 | 파괴 후 후방 재건 확인 |
| `spawn_packet_day_095_gray_market_ease` | 95 | 회색 행렬 | 14 | 10초 | 1.7초 | `any` | 아니오 | 마지막 상점 전 쉬운 진단 |
| `spawn_packet_day_095_glass_market_hook` | 95 | 유리 껍질 | 2 | 30초 | 7.0초 | `slow` | 예 | 단일 집중/지속 화력 약점 확인 |
| `spawn_packet_day_095_gray_lock_summary` | 95 | 회색 행렬 | 6 | 46초 | 1.8초 | `any` | 아니오 | 상점 전 과도한 피로 없이 마무리 |
| `spawn_packet_day_096_gray_split_setup` | 96 | 회색 행렬 | 12 | 7초 | 1.4초 | `any` | 아니오 | 정예 분담 전 기본 전선 |
| `spawn_packet_day_096_black_pack_final` | 96 | 검은 등짐 | 1 | 18초 | 없음 | `fast` | 예 | 정예 처치 담당자 확정 |
| `spawn_packet_day_096_heavy_pilgrim_final` | 96 | 무거운 순례자 | 1 | 32초 | 없음 | `slow` | 아니오 | 다른 활성 전선의 장기 지연 담당 |
| `spawn_packet_day_096_twisted_mark_final` | 96 | 뒤틀린 표식 | 1 | 45초 | 없음 | `any` | 예 | 정예 처리 중 도발 의존 흔들기 |
| `spawn_packet_day_097_winter_husk_pressure_preview` | 97 | 겨울 껍질 | 2 | 10초 | 10.0초 | `slow` | 아니오 | 압력 예고 밖으로 대형 적을 끌기 |
| `spawn_packet_day_097_gray_pressure_fill` | 97 | 회색 행렬 | 14 | 28초 | 1.5초 | `any` | 아니오 | 장기 압력 예고 중 보조선 화력 확인 |
| `spawn_packet_day_097_heavy_last_anchor` | 97 | 무거운 순례자 | 1 | 46초 | 없음 | `slow` | 아니오 | 100일 전 마지막 대형 저지 확인 |
| `spawn_packet_day_098_gray_stack_readable` | 98 | 회색 행렬 | 18 | 7초 | 1.35초 | `any` | 아니오 | 마지막 겹치기 판단용 읽기 쉬운 밀도 |
| `spawn_packet_day_098_winter_husk_stack` | 98 | 겨울 껍질 | 1 | 22초 | 없음 | `slow` | 아니오 | 겹치기 중 지속 화력 부담 |
| `spawn_packet_day_098_crack_stack_warning` | 98 | 균열 망치 | 2 | 37초 | 6.5초 | `short` | 예 | 손상 구조물이 많을 때 호출 보류 유도 |
| `spawn_packet_day_098_gray_after_stack` | 98 | 회색 행렬 | 8 | 52초 | 1.55초 | `any` | 아니오 | 호출/보류 선택 이후 전선 복구 |
| `spawn_packet_day_099_gray_rehearsal_base` | 99 | 회색 행렬 | 16 | 7초 | 1.35초 | `any` | 아니오 | 새 규칙 없는 총정리 기본 밀도 |
| `spawn_packet_day_099_winter_husk_rehearsal` | 99 | 겨울 껍질 | 2 | 20초 | 9.5초 | `slow` | 아니오 | 대형 적과 후방 킬존 최종 확인 |
| `spawn_packet_day_099_autumn_mute_rehearsal` | 99 | 가을의 묵자 | 1 | 34초 | 없음 | `any` | 아니오 | 마나 방해 우선순위 회수 |
| `spawn_packet_day_099_black_pack_rehearsal` | 99 | 검은 등짐 | 1 | 44초 | 없음 | `any` | 예 | 정예 처치 창 마지막 확인 |
| `spawn_packet_day_099_twisted_mark_rehearsal` | 99 | 뒤틀린 표식 | 2 | 56초 | 8.5초 | `any` | 예 | 도발/표식/우선 처치 충돌 회수 |
| `spawn_packet_day_099_heavy_rehearsal_close` | 99 | 무거운 순례자 | 1 | 68초 | 없음 | `slow` | 아니오 | 100일 전 마지막 장기 저지 확인 |

### 91~99일 최종 압력 예고 제작표

| ID | 일자 | 예고 방식 | 실제 압력 적용 | 역할 |
| --- | ---: | --- | --- | --- |
| `final_pressure_preview_day_091_audit` | 91 | 후방 후보 타일 약한 윤곽 | 없음 | 90일 결과 태그로 마지막 킬존 후보 표시 |
| `final_pressure_preview_day_095_market_note` | 95 | 96~100일 위험 태그 요약 | 없음 | 마지막 상점 선택과 포기 약점 결정 |
| `final_pressure_preview_day_097_long_warning` | 97 | 6초 예고 연출 후 사라짐 | 없음 | 100일 장기 압력 권역의 시각 언어 예습 |
| `final_pressure_preview_day_099_boss_hint` | 99 | 최종 보스 첫 후보 권역 1개 표시 | 없음 | 100일 시작 전 마지막 위치 확정 |

98일 겹치기 시험은 98~99일 일반 웨이브의 시간 압축으로만 구성하며, 100일 보스 스폰 플랜을 앞당기지 않습니다.

97일과 99일 압력 예고는 설치 금지, 수리 효율 감소, 공격 속도 감소를 적용하지 않는 UI 예고입니다.

## 적 제작표

| ID | 이름 | 유형 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `enemy_gray_march` | 회색 행렬 | 군집형 | 예 | 광역과 킬존 검증 |
| `enemy_gap_runner` | 틈새 주자 | 돌파형 | 예 | 빠른 대응 요구 |
| `enemy_crack_hammer` | 균열 망치 | 파괴형 | 예 | 구조물 파괴 |
| `enemy_glass_shell` | 유리 껍질 | 저항형 | 예 | 광역 의존 견제 |
| `enemy_silence_carrier` | 침묵 운반자 | 방해형 | 예 | 드로우 방해 |
| `enemy_black_pack` | 검은 등짐 | 정예형 | 예 | 처치 타이밍 |
| `enemy_heavy_pilgrim` | 무거운 순례자 | 압박형 | 예 | 지속 화력 |
| `enemy_twisted_mark` | 뒤틀린 표식 | 지원형 | 예 | 도발 견제 |
| `enemy_summer_sprinter` | 여름 질주자 | 돌파형 | 아니오 | 여름 속도 압박 |
| `enemy_ember_mason` | 잿불 석공 | 파괴형 | 아니오 | 과열 타일 강화 |
| `enemy_autumn_mute` | 가을의 묵자 | 방해형 | 아니오 | 마나 템포 방해 |
| `enemy_winter_husk` | 겨울 껍질 | 저항형 | 아니오 | 후반 체력 압박 |

### EnemyRoleProfile 제작표

역할 프로필은 개별 적보다 먼저 작성합니다.

이 프로필이 있어야 적이 단순 수치 덩어리가 아니라, 특정 `WaveIntent`를 표현하는 압박 장치로 작동합니다.

| ID | 적 역할 | 연결 WaveIntent | 필수 예고 | 열려야 하는 대응 | 과부하 금지 |
| --- | --- | --- | --- | --- | --- |
| `enemy_role_profile_swarm` | 군집형 | `intent_swarm_compression`, `intent_path_stretch` | 경로, 도착 타이밍 | 광역, 도발 군집, 잔해, 오라 증폭 | 저항형 대량과 동시 체력전 |
| `enemy_role_profile_runner` | 돌파형 | `intent_fast_response`, `intent_route_read` | 빠른 적 아이콘, 짧은 경로 | 둔화, 넉백, 도발, 짧은 우회로 | 방해형/파괴형과 동시 최대 압박 |
| `enemy_role_profile_breaker` | 파괴형 | `intent_planned_structure_break`, `intent_relocation_after_loss` | 표식 구조물, 공격 전 지연 | 수리, 희생, 도발, 집중 화력, 후방 재건 | 예고 없는 구조물 삭제 |
| `enemy_role_profile_resistant` | 저항형 | `intent_path_stretch`, `intent_final_focus` | 저항 아이콘, 약화 변환 표시 | 긴 경로, 지속 화력, 약화된 CC, 오라 | 완전 면역으로 직업 무효화 |
| `enemy_role_profile_disruptor` | 방해형 | `intent_priority_target`, `intent_resource_disruption_recovery` | 영향 범위, 막히는 게이지 | 우선 처치, 격리 경로, 도발 분리, 전선 유지 | 손패/마나 완전 봉쇄 |
| `enemy_role_profile_support` | 지원형 | `intent_priority_target`, `intent_secondary_killzone` | 강화 연결선, 지원 범위 | 후열 타격, 경로 격리, 끌어당김, 전선 유지 | 지원 효과와 정예/돌파형 최대치 동시 사용 |
| `enemy_role_profile_pressure` | 압박형 | `intent_secondary_killzone`, `intent_relocation_after_loss` | 느린 진군선, 도달 예상 시간 | 경로 연장, 장기 수리, 둔화, 후방 킬존 | 길기만 한 체력전 |
| `enemy_role_profile_elite` | 정예형 | `intent_priority_target`, `intent_final_focus` | 처치 타이밍, 집중 핑 후보 | 공동 집중, 도발 고정, 수리 유지, 경로 격리 | 다방향 돌파형과 공동 타겟 흐림 |

### 적 역할 대응 제작표

적 역할 대응표는 적을 추가할 때 특정 직업 강제가 생기는지 먼저 확인하기 위한 표입니다.

| ID | 적 역할 | 주로 묻는 직업 판단 | 보조 대응 | 금지선 |
| --- | --- | --- | --- | --- |
| `enemy_role_response_swarm` | 군집형 | 원소술사 광역, 건축가 킬존 압축 | 수호자 도발 군집, 땜장이 오라 증폭 | 체력만 많은 반복 물량전 |
| `enemy_role_response_runner` | 돌파형 | 원소술사 빙결/넉백, 수호자 도발 타이밍 | 건축가 짧은 우회로, 땜장이 과부하 화력 | 예고 없는 빠른 기지 피해 |
| `enemy_role_response_breaker` | 파괴형 | 건축가 계획 붕괴, 땜장이 원격 수리 | 수호자 가시 탱킹, 원소술사 집중 화력 | 구조물 무작위 삭제 |
| `enemy_role_response_resistant` | 저항형 | 땜장이 지속 화력, 원소술사 속성 전환 | 수호자 지연, 건축가 긴 경로 | 특정 직업 핵심 기믹 완전 무효 |
| `enemy_role_response_disruptor` | 방해형 | 원소술사 우선 처치, 수호자 도발 분리 | 건축가 격리 경로, 땜장이 유지보수 | 보이지 않는 자원/손패 방해 |
| `enemy_role_response_support` | 지원형 | 원소술사 후열 타격, 건축가 경로 격리 | 수호자 끌어당김, 땜장이 전선 유지 | 지원 효과와 본체 위협 동시 과부하 |
| `enemy_role_response_pressure` | 압박형 | 건축가 경로 연장, 땜장이 장기 수리 | 수호자 장기 지연, 원소술사 둔화 | 길기만 하고 판단 없는 전투 |
| `enemy_role_response_elite` | 정예형 | 파티 공동 집중 화력 | 도발 고정, 수리 유지, 경로 격리, 부위 우선순위 | 체력 높은 일반 적 |

### 여름 전용 적 제작표

| ID | 이름 | 유형 | 등장 | MVP | 역할 |
| --- | --- | --- | ---: | --- | --- |
| `enemy_summer_sprinter` | 여름 질주자 | 돌파형 | 32일 | 아니오 | 빠른 템포와 서쪽 압박 |
| `enemy_ember_mason` | 잿불 석공 | 파괴형/지원형 | 34일 | 아니오 | 과열 타일 강화와 구조물 압박 |
| `enemy_heat_saw` | 열톱니 | 파괴형 | 42일 | 아니오 | 약해진 구조물 표식과 집중 파괴 |

### 가을 전용 적 제작표

| ID | 이름 | 유형 | 등장 | MVP | 역할 |
| --- | --- | --- | ---: | --- | --- |
| `enemy_autumn_mute` | 가을의 묵자 | 방해형 | 52일 | 아니오 | 주변 처치의 마나 게이지 충전량 감소 |

### 겨울 전용 적 제작표

| ID | 이름 | 유형 | 등장 | MVP | 역할 |
| --- | --- | --- | ---: | --- | --- |
| `enemy_winter_husk` | 겨울 껍질 | 저항형/압박형 | 72일 | 아니오 | 좁아진 공간에서 지속 화력과 둔화 유지 검증 |

## 계절 타일 제작표

| ID | 이름 | 등장 | MVP | 역할 |
| --- | --- | ---: | --- | --- |
| `tile_overheated_boost` | 과열 강화 지점 | 31일 | 아니오 | 공격 속도 증가, 구조물 피해 증가 |
| `tile_overheated_warning` | 과열 예고 표시 | 31일 | 아니오 | 전투 시작 전 위험 지점 표시 |
| `tile_temporary_heat` | 임시 과열 지점 | 34일 | 아니오 | 잿불 석공이 짧게 만드는 위험 강화 자리 |
| `tile_autumn_leaf_drift` | 낙엽 타일 | 51일 | 아니오 | 적 경로 비용 변화와 약한 둔화 |
| `tile_autumn_leaf_warning` | 낙엽 변화 예고 | 51일 | 아니오 | 웨이브 중 바뀔 낙엽 위치 표시 |
| `tile_persistent_debris` | 오래 남는 잔해 | 53일 | 아니오 | 가을 구간의 임시 경로 비용과 둔화 |
| `tile_frozen_outskirts` | 얼어붙은 외곽 | 71일 | 아니오 | 외곽 설치 구역 결빙과 새 구조물 설치 제한 |
| `tile_frost_warning` | 결빙 예고 | 71일 | 아니오 | 준비 항목 전에 얼 구역 표시 |
| `tile_temporary_frost` | 임시 결빙 권역 | 80일 | 아니오 | 겨울의 문 예고형이 짧게 얼리는 설치 권역 |
| `tile_boss_pressure` | 보스 압력 타일 | 82일 | 아니오 | 예고된 설치 권역의 새 설치 제한과 구조물 효율 감소 |
| `tile_pressure_warning` | 압력 권역 예고 | 82일 | 아니오 | 보스 압력 타일이 생길 위치와 지속 시간 표시 |
| `tile_long_pressure_zone` | 장기 압력 권역 | 97일 | 아니오 | 최종 보스 단계 동안 유지되는 강한 설치 권역 압박 |

### 과열 프로필 제작표

| ID | 등장 | MVP | 역할 |
| --- | ---: | --- | --- |
| `overheat_profile_intro_031` | 31일 | 아니오 | 고정 과열의 기본 이득과 위험 학습 |
| `overheat_profile_mason_temp_034` | 34일 | 아니오 | 잿불 석공이 만드는 짧은 임시 과열 |
| `overheat_profile_split_036` | 36일 | 아니오 | 두 활성 방향 중 하나를 살리는 과열 분담 |
| `overheat_profile_boss_wake_040` | 40일 | 아니오 | 과열된 거상이 남기는 열 자취 |

## 보스 제작표

| ID | 이름 | 시점 | MVP | 핵심 압박 |
| --- | --- | ---: | --- | --- |
| `boss_silent_colossus` | 침묵의 거상 | 10일 | 예 | 느린 접근, 구조물 파괴 |
| `boss_silent_colossus_variant` | 침묵의 거상 변형 | 20일 | 예 | 기존 부위 변형, 드로우/예고/동반 중 1개 |
| `boss_season_observer_preview` | 사계의 관측자 예고형 | 30일 | 예 | 활성 방향 안에서 웨이브 예고 교란 |
| `boss_season_observer` | 사계의 관측자 강화형 | 50일 | 아니오 | 활성 방향 안의 후보 예고 교란 |
| `boss_overheated_colossus` | 과열된 거상 | 40일 | 아니오 | 과열 타일과 파괴 |
| `boss_fallen_belltower` | 무너진 종탑 | 60일 | 아니오 | 오라와 수리 견제 |
| `boss_fallen_belltower_variant` | 무너진 종탑 변형 | 70일 | 아니오 | 무음 권역 중 정예 동반 웨이브 |
| `boss_winter_gate_preview` | 겨울의 문 예고형 | 80일 | 아니오 | 설치 공간 압박 |
| `boss_winter_gate` | 겨울의 문 | 90일 | 아니오 | 보스 압력 타일 |
| `boss_winter_gate_final` | 겨울의 문 완전체 | 100일 | 아니오 | 최종 공간 축소 |

### 침묵의 거상 하위 제작표

| ID | 분류 | 이름 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `boss_part_front` | 부위 | 전면부 | 예 | 구조물 짓누르기 패턴 담당 |
| `boss_part_legs` | 부위 | 다리부 | 예 | 이동 속도와 지연 전술 담당 |
| `boss_part_lantern` | 부위 | 등불부 | 예 | 드로우 방해와 부위 보상 담당 |
| `boss_pattern_silent_stride` | 패턴 | 무언의 발걸음 | 예 | 느린 접근 압박 |
| `boss_pattern_crushing_hand` | 패턴 | 짓누르기 | 예 | 구조물 파괴와 계획된 붕괴 검증 |
| `boss_pattern_lantern_gloom` | 패턴 | 침묵의 등불 | 예 | 우선 처치와 자원 템포 압박 |
| `boss_pattern_last_reach` | 패턴 | 마지막 접근 | 예 | 기지 도달 후 5초 최후 대응 |
| `boss_ui_target_priority` | UI | 부위 추천 타겟 표시 | 예 | 첫 보스에서 다리부를 먼저 읽게 함 |
| `boss_ui_reach_countdown` | UI | 기지 도달 카운트다운 | 예 | 즉시 패배 예고를 납득 가능하게 표시 |
| `boss_phase_plan_silent_colossus_010` | 전투 흐름 | 10일 첫 보스 흐름 | 예 | 입장, 다리부, 짓누르기, 등불부, 마지막 접근, 결과 연결 |
| `boss_phase_010_entry_warning` | 단계 | 입장 예고 | 예 | 보스 경로 폭과 추천 다리부 타겟 표시 |
| `boss_phase_010_legs_focus` | 단계 | 다리부 학습 | 예 | 보스를 죽이기 전에 늦추는 판단 학습 |
| `boss_phase_010_crush_choice` | 단계 | 짓누르기 선택 | 예 | 지킬 구조물과 버릴 구조물 선택 |
| `boss_phase_010_lantern_choice` | 단계 | 등불부 선택 | 예 | 드로우 약화 원인과 방해 부위 처리 |
| `boss_phase_010_last_reach` | 단계 | 마지막 접근 | 예 | 기지 도달 5초 최후 대응 |
| `boss_phase_010_result_bridge` | 단계 | 결과 연결 | 예 | 실패 원인, 아티팩트, 상점, 11일 예고 연결 |
| `boss_companion_policy_silent_colossus_010` | 동반 웨이브 규칙 | 첫 보스 약한 시야 테스트 | 예 | 활성 방향 안에서 최대 1~2개 약한 압박만 허용 |
| `boss_role_check_silent_colossus_010` | 역할 체크 | 첫 보스 직업별 대응 | 예 | 4직업이 각자 다른 방식으로 보스를 늦추는지 확인 |

### MVP 보스 수치 제작표

| ID | 분류 | 일자 | MVP | 제작 기준 |
| --- | --- | ---: | --- | --- |
| `boss_numeric_profile_silent_colossus_010` | 수치 프로필 | 10 | 예 | 본체 120, 전면부 35, 다리부 50, 등불부 25 |
| `boss_numeric_profile_silent_colossus_variant_020` | 수치 프로필 | 20 | 예 | 본체 150, 전면부 42, 다리부 58, 등불부 32 |
| `boss_numeric_profile_observer_preview_030` | 수치 프로필 | 30 | 예 | 본체 165, 관측핵 55 |
| `boss_variant_fast_lantern_020` | 변형 | 20 | 예 | 등불부 활성 조건 70% 이하에서 80% 이하로 변경 |
| `boss_variant_short_crush_warning_020` | 변형 | 20 | 예 | 짓누르기 예고 4초에서 3초로 감소 |
| `boss_variant_weak_companion_020` | 변형 | 20 | 예 | 회색 행렬 8기, 50초 시작, 2.0초 간격 |
| `boss_pattern_blurred_observation_timing_030` | 패턴 수치 | 30 | 예 | 관측핵 생존 시 후보 6초, 실제 확정 3초 전 |
| `boss_pattern_clear_observation_timing_030` | 패턴 수치 | 30 | 예 | 관측핵 파괴 후 후보 10초, 실제 확정 6초 전 |
| `boss_companion_policy_observer_preview_030` | 동반 웨이브 규칙 | 30 | 예 | 회색 행렬 10기, 48초 시작, 1.8초 간격, 필요 시만 사용 |

20일 변형은 위 변형 ID 중 하나만 선택합니다.

30일 관측핵 파괴는 정보 보상만 제공하며, 보상 팩, 카드 후보, 골드, 보스 파편을 추가하지 않습니다.

### 보스 시간 예산 제작표

보스 시간 예산은 보스전의 장엄함을 유지하되, 같은 질문이 반복되어 지루해지는 구간을 막기 위한 제작 단위입니다.

| ID | 일자 | 목표 시간 | 경고선 | 반복 제한 핵심 |
| --- | ---: | --- | --- | --- |
| `boss_budget_silent_colossus_010` | 10 | 2.0~3.5분 | 4분 | 짓누르기 4회, 최종 도달 압박 1회 |
| `boss_budget_silent_colossus_variant_020` | 20 | 2.5~3.8분 | 4.5분 | 변형 패턴 1종, 약한 동반 1회 |
| `boss_budget_observer_preview_030` | 30 | 3.0~4.5분 | 5분 | 흐린 관측 3회, 동반 1회 |
| `boss_budget_overheated_colossus_040` | 40 | 3.0~4.8분 | 5.5분 | 열 자취 3회, 화로 짓누르기 3회 |
| `boss_budget_observer_enhanced_050` | 50 | 3.5~5.0분 | 6분 | 이중 예고 3회, 표식 압박 2회 |
| `boss_budget_fallen_belltower_060` | 60 | 3.5~5.0분 | 6분 | 무음 권역 4회, 낙엽 종소리 2회 |
| `boss_budget_belltower_variant_070` | 70 | 3.5~5.2분 | 6분 | 동반 조합 1종, 권역 반복 4회 |
| `boss_budget_winter_gate_preview_080` | 80 | 4.0~5.5분 | 6.5분 | 결빙 권역 4회, 겨울 껍질 동반 1회 |
| `boss_budget_winter_gate_090` | 90 | 4.5~6.0분 | 7분 | 압력 회전 4회, 마지막 이전 압박 2회 |
| `boss_budget_winter_gate_final_100` | 100 | 5.0~7.0분 | 8분 | 6단계 고정, 같은 압박 무한 반복 금지 |

시간 예산 제작표는 보상 팩, 카드 후보 수, 희귀도, 골드, 보스 파편, 비활성 방향 스폰을 조정 항목으로 사용하지 않습니다.

### 사계의 관측자 예고형 하위 제작표

| ID | 분류 | 이름 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `boss_part_observation_core_preview` | 부위 | 관측핵 예고형 | 예 | 살아 있으면 다음 웨이브 예고가 짧게 흐려짐 |
| `boss_pattern_blurred_observation_preview` | 패턴 | 흐린 관측 | 예 | 활성 방향 안 후보 2개를 보여준 뒤 실제 방향 확정 |
| `boss_pattern_season_eye_preview` | 패턴 | 계절의 눈 예고형 | 예 | 26~29일 빠른 템포 웨이브를 약하게 동반 |
| `boss_ui_observer_candidate_direction` | UI | 후보 방향 예고 | 예 | 후보가 모두 활성 방향 안에 있음을 표시 |
| `boss_phase_plan_observer_preview_030` | 전투 흐름 | 30일 관측자 예고형 흐름 | 예 | 관측 예고, 관측핵, 첫 확정, 약한 동반, 두 번째 흐림, 결과 연결 |
| `boss_phase_030_candidate_warning` | 단계 | 관측 예고 | 예 | 후보 방향 2개와 담당 분담 유도 |
| `boss_phase_030_core_focus` | 단계 | 관측핵 집중 | 예 | 예고를 선명하게 만들 부위 집중 선택 |
| `boss_phase_030_first_reveal` | 단계 | 첫 확정 | 예 | 실제 방향 확정 후 재집결 |
| `boss_phase_030_season_eye` | 단계 | 약한 계절의 눈 | 예 | 빠른 템포 동반 웨이브와 보스 부위 분담 |
| `boss_phase_030_second_blur` | 단계 | 두 번째 흐림 | 예 | 이전 실패를 바탕으로 담당 재배치 |
| `boss_phase_030_result_bridge` | 단계 | 결과 연결 | 예 | 31~40일 속도/과열 대비 태그 연결 |

### 과열된 거상 하위 제작표

| ID | 분류 | 이름 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `boss_part_heat_core` | 부위 | 과열핵 | 아니오 | 살아 있으면 과열 타일이 더 오래 유지 |
| `boss_part_cooling_leg` | 부위 | 냉각 다리부 | 아니오 | 파괴 시 보스가 남기는 과열 지점 감소 |
| `boss_pattern_heat_wake` | 패턴 | 열의 자취 | 아니오 | 지나간 경로 주변을 임시 과열 지점으로 만듦 |
| `boss_pattern_furnace_crush` | 패턴 | 화로 짓누르기 | 아니오 | 예고된 구조물에 피해, 과열 위 구조물은 추가 피해 |
| `boss_ui_heat_path_preview` | UI | 과열 경로 예고 | 아니오 | 보스가 달굴 타일을 미리 표시 |
| `boss_phase_plan_overheated_colossus_040` | 전투 흐름 | 40일 과열된 거상 흐름 | 아니오 | 열 경로 예고, 첫 열 자취, 냉각 다리부, 화로 짓누르기, 과열핵, 결과 연결 |
| `boss_phase_040_heat_path_warning` | 단계 | 열 경로 예고 | 아니오 | 과열 후보와 보스 경로를 미리 표시 |
| `boss_phase_040_first_heat_wake` | 단계 | 첫 열 자취 | 아니오 | 보스가 남긴 임시 과열을 이용하거나 피하는 선택 |
| `boss_phase_040_cooling_leg_choice` | 단계 | 냉각 다리부 선택 | 아니오 | 열 자취 수를 줄일지 판단 |
| `boss_phase_040_furnace_crush` | 단계 | 화로 짓누르기 | 아니오 | 과열 위 구조물 추가 피해와 살림/버림 선택 |
| `boss_phase_040_heat_core_choice` | 단계 | 과열핵 선택 | 아니오 | 과열 지속 시간을 줄일지, 강한 자리를 더 쓸지 판단 |
| `boss_phase_040_result_bridge` | 단계 | 결과 연결 | 아니오 | 41~50일 구조물 손실 판단으로 연결 |

### 사계의 관측자 강화형 하위 제작표

| ID | 분류 | 이름 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `boss_part_observation_eye` | 부위 | 관측안 | 아니오 | 살아 있으면 다음 웨이브 방향 예고가 후보 2개로 표시 |
| `boss_part_summer_lens` | 부위 | 여름 렌즈 | 아니오 | 살아 있으면 과열 후보 지점이 더 오래 유지 |
| `boss_pattern_double_forecast` | 패턴 | 이중 예고 | 아니오 | 활성 방향 안의 후보 2개를 보여준 뒤 실제 방향 확정 |
| `boss_pattern_heat_reflection` | 패턴 | 열상 반사 | 아니오 | 과열 지점 주변 구조물 위험 증가 |
| `boss_ui_forecast_candidate` | UI | 후보 방향 예고 | 아니오 | 후보가 모두 활성 방향 안에 있음을 표시 |
| `boss_phase_plan_observer_enhanced_050` | 전투 흐름 | 50일 관측자 강화형 흐름 | 아니오 | 이중 예고, 관측안, 첫 확정, 여름 렌즈, 표식 압박, 결과 연결 |
| `boss_phase_050_double_forecast` | 단계 | 이중 예고 | 아니오 | 후보 방향 2개와 후보 과열 지점 표시 |
| `boss_phase_050_observation_eye` | 단계 | 관측안 선택 | 아니오 | 실제 방향 확정 시간을 앞당길지 판단 |
| `boss_phase_050_first_reveal` | 단계 | 첫 확정과 재집결 | 아니오 | 확정 방향으로 수리와 화력을 모음 |
| `boss_phase_050_summer_lens` | 단계 | 여름 렌즈 선택 | 아니오 | 과열 후보 지속 시간을 줄일지 판단 |
| `boss_phase_050_marked_pressure` | 단계 | 표식 압박 | 아니오 | 살릴 구조물과 버릴 구조물 선택 |
| `boss_phase_050_result_bridge` | 단계 | 결과 연결 | 아니오 | 51~60일 경로 변화 대비 태그 연결 |

### 무너진 종탑 하위 제작표

| ID | 분류 | 이름 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `boss_part_cracked_bell` | 부위 | 균열종 | 아니오 | 살아 있으면 오라 약화 권역 주기가 짧아짐 |
| `boss_part_fallen_clapper` | 부위 | 떨어진 추 | 아니오 | 살아 있으면 수리 약화 권역 지속 시간이 증가 |
| `boss_pattern_mute_peal` | 패턴 | 소리 없는 종울림 | 아니오 | 예고된 권역의 오라와 수리 효율 약화 |
| `boss_pattern_leaf_toll` | 패턴 | 낙엽 종소리 | 아니오 | 활성 방향 안의 낙엽 경로 비용 변화 |
| `boss_pattern_debris_resonance` | 패턴 | 잔해 공명 | 아니오 | 오래 남는 잔해를 딜타임 또는 우회 유도로 사용 |
| `boss_ui_suppression_zone` | UI | 무음 권역 예고 | 아니오 | 약화될 설치 구역과 지속 시간을 표시 |
| `boss_phase_plan_fallen_belltower_060` | 전투 흐름 | 60일 무너진 종탑 흐름 | 아니오 | 권역 예고, 균열종, 낙엽 종소리, 떨어진 추, 잔해 공명, 결과 연결 |
| `boss_phase_060_zone_warning` | 단계 | 권역 예고 | 아니오 | 첫 무음 권역과 낙엽/잔해 경로를 미리 표시 |
| `boss_phase_060_cracked_bell` | 단계 | 균열종 선택 | 아니오 | 무음 권역 주기를 줄일지 판단 |
| `boss_phase_060_leaf_toll` | 단계 | 낙엽 종소리 | 아니오 | 활성 방향 안의 경로 비용 변화에 맞춰 킬존 이동 |
| `boss_phase_060_fallen_clapper` | 단계 | 떨어진 추 선택 | 아니오 | 수리 약화 지속 시간을 줄일지 판단 |
| `boss_phase_060_debris_resonance` | 단계 | 잔해 공명 | 아니오 | 오래 남는 잔해를 딜타임 또는 우회 유도로 사용 |
| `boss_phase_060_result_bridge` | 단계 | 결과 연결 | 아니오 | 61~70일 방해형/정예 우선순위 대비 태그 연결 |

### 무너진 종탑 변형 하위 제작표

| ID | 분류 | 이름 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `boss_companion_elite_priority_wave` | 동반 웨이브 규칙 | 정예 우선순위 동반 웨이브 | 아니오 | 70일 보스의 유일한 추가점, 약한 정예/방해형 조합 |
| `boss_ui_elite_priority_warning` | UI | 정예 우선순위 경고 | 아니오 | 무음 권역 중 동반 정예 등장 시점을 표시 |
| `boss_phase_plan_belltower_variant_070` | 전투 흐름 | 70일 무너진 종탑 변형 흐름 | 아니오 | 변형 예고, 첫 무음 권역, 동반 조합, 권역 중 우선순위, 마지막 재집결, 결과 연결 |
| `boss_phase_070_variant_warning` | 단계 | 변형 예고 | 아니오 | 추가점이 동반 웨이브 조합뿐임을 표시 |
| `boss_phase_070_first_suppression` | 단계 | 첫 무음 권역 | 아니오 | 60일에서 배운 분산/재집결을 재확인 |
| `boss_phase_070_companion_choice` | 단계 | 동반 조합 선택 | 아니오 | 정예/방해형/압박형 중 1개 약한 조합만 사용 |
| `boss_phase_070_priority_under_zone` | 단계 | 권역 중 우선순위 | 아니오 | 부위, 방해형, 정예 중 먼저 볼 대상 결정 |
| `boss_phase_070_last_regroup` | 단계 | 마지막 재집결 | 아니오 | 권역 종료 후 화력과 수리를 다시 모음 |
| `boss_phase_070_result_bridge` | 단계 | 결과 연결 | 아니오 | 71~80일 공간 압박 대비 태그 연결 |

### 70일 무너진 종탑 변형 세부 제작표

| ID | 분류 | MVP | 제작 내용 |
| --- | --- | --- | --- |
| `belltower_variant_phase_plan_lock_070` | 데이터 잠금 | 아니오 | 60일 부위/패턴만 재사용하고, 70일 추가점은 동반 조합 1종으로 제한 |
| `belltower_variant_companion_black_pack` | 동반 조합 | 아니오 | 검은 등짐 1기, 52초 등장, 정예 처치 타이밍 실패 런에 사용 |
| `belltower_variant_companion_gray_pressure` | 동반 조합 | 아니오 | 회색 행렬 8기, 65초 등장, 보스만 보느라 전선 누수 런에 사용 |
| `belltower_variant_companion_autumn_mute` | 동반 조합 | 아니오 | 가을의 묵자 1기, 72초 등장, 방해형 방치 런에 사용 |
| `boss_ui_belltower_variant_summary` | UI | 아니오 | 전투 전 "새 부위/새 패턴 없음, 동반 조합 1종"을 표시 |
| `boss_ui_companion_priority_prompt` | UI | 아니오 | 동반 등장 8초 전에 방향, 적 역할, 추천 첫 대응 표시 |
| `boss_report_belltower_variant_priority` | 리포트 | 아니오 | 패배/승리 후 첫 대상, 대상 변경, 권역 후 재집결 여부 기록 |

70일 보스 단계 수치:

| 단계 | ID | 권장 시간 | 반복 상한 | 제작 주의 |
| ---: | --- | --- | --- | --- |
| 0 | `boss_phase_070_variant_warning` | 전투 전 | 1회 | 동반 조합이 무엇인지 미리 보여주고 기습으로 쓰지 않음 |
| 1 | `boss_phase_070_first_suppression` | 0~45초 | 1회 | 60일 무음 권역을 재사용하고 오라/수리 효율을 0으로 만들지 않음 |
| 2 | `boss_phase_070_companion_choice` | 45~90초 | 1회 | 선택 동반 조합은 하나만 등장 |
| 3 | `boss_phase_070_priority_under_zone` | 90~155초 | 1회 | 무음 권역과 동반 조합을 동시에 최대치로 겹치지 않음 |
| 4 | `boss_phase_070_last_regroup` | 155~230초 | 1회 | 권역 종료 후 재집결 시간을 남김 |
| 5 | `boss_phase_070_result_bridge` | 종료 | 1회 | 71~80일 공간 압박 대비 태그로 연결 |

### 겨울의 문 예고형 하위 제작표

| ID | 분류 | 이름 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `boss_part_gate_hinge` | 부위 | 문경첩 | 아니오 | 살아 있으면 임시 결빙 권역 지속 시간이 증가 |
| `boss_part_frost_chain` | 부위 | 서리 사슬 | 아니오 | 살아 있으면 다음 결빙 예고 시간이 짧아짐 |
| `boss_pattern_threshold_frost` | 패턴 | 문턱의 서리 | 아니오 | 예고된 설치 권역을 짧게 얼림 |
| `boss_pattern_slow_opening` | 패턴 | 느린 개문 | 아니오 | 보스가 천천히 접근하며 외곽 설치 공간을 압박 |
| `boss_ui_frost_zone_preview` | UI | 결빙 권역 예고 | 아니오 | 보스가 얼릴 설치 권역과 지속 시간을 표시 |
| `boss_phase_plan_winter_gate_preview_080` | 전투 흐름 | 80일 겨울의 문 예고형 흐름 | 아니오 | 서리 권역 예고, 느린 개문, 문경첩, 문턱의 서리, 서리 사슬, 결과 연결 |
| `boss_phase_080_frost_zone_warning` | 단계 | 서리 권역 예고 | 아니오 | 보스 경로와 첫 임시 결빙 권역 표시 |
| `boss_phase_080_slow_opening` | 단계 | 느린 개문 | 아니오 | 지속 화력과 둔화 유지 판단 |
| `boss_phase_080_gate_hinge` | 단계 | 문경첩 선택 | 아니오 | 임시 결빙 지속 시간을 줄일지 판단 |
| `boss_phase_080_threshold_frost` | 단계 | 문턱의 서리 | 아니오 | 예고된 설치 권역 결빙과 구조물 이전 판단 |
| `boss_phase_080_frost_chain` | 단계 | 서리 사슬 선택 | 아니오 | 다음 결빙 예고 시간을 늘릴지 판단 |
| `boss_phase_080_result_bridge` | 단계 | 결과 연결 | 아니오 | 81~90일 보스 압력 타일 대비 태그 연결 |

### 80일 겨울의 문 예고형 세부 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `winter_gate_preview_phase_lock_080` | 데이터 잠금 | 아니오 | 80일 보스가 6단계 흐름과 최대 4회 결빙 사이클을 벗어나지 않게 고정 |
| `frost_cycle_080_outer_warning` | 결빙 사이클 | 아니오 | 40초 전후 외곽 설치 구역 결빙, 경로 타일 차단 금지 |
| `frost_cycle_080_mid_relocation` | 결빙 사이클 | 아니오 | 100초 전후 전방/중간 설치 구역 결빙, 문경첩 상태에 따라 지속 시간 조정 |
| `frost_cycle_080_rear_rehearsal` | 결빙 사이클 | 아니오 | 155초 전후 중간/후방 설치 구역 결빙, 후방 킬존 개방 확인 |
| `frost_cycle_080_final_short` | 결빙 사이클 | 아니오 | 220초 전후 마지막 짧은 결빙, 서리 사슬 상태에 따라 예고 시간 조정 |
| `boss_part_exposure_gate_hinge_080` | 부위 노출 | 아니오 | 70~125초 문경첩 노출, 결빙 지속 시간 감소 선택 |
| `boss_part_exposure_frost_chain_080` | 부위 노출 | 아니오 | 185~250초 서리 사슬 노출, 마지막 결빙 예고 시간 증가 선택 |
| `companion_policy_080_single_optional` | 동반 정책 | 아니오 | 겨울 껍질 1기 또는 회색 행렬 8기 중 1종만 선택 |
| `direction_projection_080_active_only` | 방향 정책 | 아니오 | 결빙 후보와 동반 웨이브를 인원수별 활성 방향 안으로만 투영 |
| `boss_reward_policy_080_no_stack_bonus` | 보상 정책 | 아니오 | 80일 보스와 선택 동반이 웨이브 겹치기 보상 증가를 만들지 않게 고정 |
| `boss_result_tag_bridge_080` | 결과 연결 | 아니오 | 후방 킬존, 늦은 이전, 문경첩/서리 사슬 선택 결과를 81~90일 힌트로 연결 |

80일 단계 수치:

| 시간대 | 단계 ID | 핵심 수치 | 금지선 |
| ---: | --- | --- | --- |
| 0~15초 | `boss_phase_080_frost_zone_warning` | 첫 결빙 후보와 후방 후보 타일 표시 | 실제 결빙 즉시 적용 금지 |
| 15~70초 | `boss_phase_080_slow_opening` | 1번 결빙, 보스 느린 접근 | 선택 동반 웨이브 조기 투입 금지 |
| 70~125초 | `boss_phase_080_gate_hinge` | 문경첩 노출, 선택 동반 1종 허용 | 겨울 껍질과 회색 행렬 동시 선택 금지 |
| 125~185초 | `boss_phase_080_threshold_frost` | 2~3번 결빙, 구조물 이전 확인 | 경로 타일 결빙 금지 |
| 185~250초 | `boss_phase_080_frost_chain` | 서리 사슬 노출, 4번 결빙 예고 | 예고 4초 미만 금지 |
| 250~330초 | `boss_phase_080_result_bridge` | 본체 마무리, 결과 태그 기록 | 보상/희귀도/카드 후보 증가 금지 |

### 겨울의 문 하위 제작표

| ID | 분류 | 이름 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `boss_part_pressure_frame` | 부위 | 압력문틀 | 아니오 | 살아 있으면 보스 압력 권역 지속 시간이 증가 |
| `boss_part_frozen_threshold` | 부위 | 얼어붙은 문턱 | 아니오 | 살아 있으면 압력 권역 예고 시간이 짧아짐 |
| `boss_pattern_moving_pressure` | 패턴 | 이동하는 압력 | 아니오 | 보스 압력 타일이 활성 방향 안에서 순차 이동 |
| `boss_pattern_gate_breath` | 패턴 | 문의 숨 | 아니오 | 약한 겨울 껍질 동반 웨이브 |
| `boss_ui_pressure_path_preview` | UI | 압력 경로 예고 | 아니오 | 다음 압력 권역의 위치와 지속 시간을 표시 |
| `boss_phase_plan_winter_gate_090` | 전투 흐름 | 90일 겨울의 문 흐름 | 아니오 | 압력 경로 예고, 첫 이동 압력, 압력문틀, 문의 숨, 얼어붙은 문턱, 마지막 이전 |
| `boss_phase_090_pressure_path_warning` | 단계 | 압력 경로 예고 | 아니오 | 보스 경로와 첫 압력 권역 순서 표시 |
| `boss_phase_090_first_moving_pressure` | 단계 | 첫 이동 압력 | 아니오 | 전방 설치 구역 압력과 중간 화력 이전 판단 |
| `boss_phase_090_pressure_frame` | 단계 | 압력문틀 선택 | 아니오 | 압력 지속 시간을 줄일지 판단 |
| `boss_phase_090_gate_breath` | 단계 | 문의 숨 | 아니오 | 약한 겨울 껍질 동반 웨이브와 대형 적 지연 |
| `boss_phase_090_frozen_threshold` | 단계 | 얼어붙은 문턱 선택 | 아니오 | 압력 예고 시간을 늘릴지 판단 |
| `boss_phase_090_last_relocation` | 단계 | 마지막 이전 | 아니오 | 최종 리허설 전 마지막 방어선 후보 확정 |

### 90일 겨울의 문 세부 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `winter_gate_phase_lock_090` | 데이터 잠금 | 아니오 | 90일 보스가 6단계 흐름과 최대 4회 이동 압력 사이클을 벗어나지 않게 고정 |
| `pressure_cycle_090_front_warning` | 압력 사이클 | 아니오 | 35초 전후 전방 설치 구역 압력, 경로 타일 차단 금지 |
| `pressure_cycle_090_mid_relocation` | 압력 사이클 | 아니오 | 105초 전후 전방/중간 설치 구역 압력, 압력문틀 상태에 따라 지속 시간 조정 |
| `pressure_cycle_090_secondary_killzone` | 압력 사이클 | 아니오 | 180초 전후 중간/보조 킬존 후보 압력, 두 번째 화력 지점 확인 |
| `pressure_cycle_090_last_relocation` | 압력 사이클 | 아니오 | 255초 전후 후방/마지막 킬존 후보 압력, 얼어붙은 문턱 상태에 따라 예고 시간 조정 |
| `boss_part_exposure_pressure_frame_090` | 부위 노출 | 아니오 | 80~145초 압력문틀 노출, 압력 지속 시간 감소 선택 |
| `boss_part_exposure_frozen_threshold_090` | 부위 노출 | 아니오 | 210~285초 얼어붙은 문턱 노출, 마지막 압력 예고 시간 증가 선택 |
| `companion_policy_090_single_optional` | 동반 정책 | 아니오 | 겨울 껍질 1기 또는 회색 행렬 10기 중 1종만 선택 |
| `direction_projection_090_active_only` | 방향 정책 | 아니오 | 압력 후보와 동반 웨이브를 인원수별 활성 방향 안으로만 투영 |
| `boss_reward_policy_090_no_stack_bonus` | 보상 정책 | 아니오 | 90일 보스와 선택 동반이 웨이브 겹치기 보상 증가를 만들지 않게 고정 |
| `boss_result_tag_bridge_090` | 결과 연결 | 아니오 | 보조 킬존, 늦은 이전, 압력문틀/문턱 선택 결과를 91~100일 힌트로 연결 |

90일 단계 수치:

| 시간대 | 단계 ID | 핵심 수치 | 금지선 |
| ---: | --- | --- | --- |
| 0~18초 | `boss_phase_090_pressure_path_warning` | 첫/두 번째 압력 후보와 후방 후보 타일 표시 | 실제 압력 즉시 적용 금지 |
| 18~80초 | `boss_phase_090_first_moving_pressure` | 1번 압력, 지나간 권역 회복 | 구조물 즉시 삭제 금지 |
| 80~145초 | `boss_phase_090_pressure_frame` | 압력문틀 노출, 2번 압력 | 압력 지속 12초 초과 금지 |
| 145~210초 | `boss_phase_090_gate_breath` | 선택 동반 1종 허용, 3번 압력 후보 예고 | 겨울 껍질과 회색 행렬 동시 선택 금지 |
| 210~285초 | `boss_phase_090_frozen_threshold` | 얼어붙은 문턱 노출, 4번 압력 예고 | 예고 4초 미만 금지 |
| 285~360초 | `boss_phase_090_last_relocation` | 마지막 이전 압력, 결과 태그 기록 | 장기 압력, 보상/희귀도/카드 후보 증가 금지 |

### 겨울의 문 완전체 하위 제작표

| ID | 분류 | 이름 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `boss_part_final_core` | 부위 | 문의 핵 | 아니오 | 살아 있으면 장기 압력 권역이 더 오래 유지 |
| `boss_part_last_chain` | 부위 | 마지막 사슬 | 아니오 | 살아 있으면 동반 웨이브 예고 시간이 짧아짐 |
| `boss_part_threshold_heart` | 부위 | 문턱 심장 | 아니오 | 살아 있으면 마지막 이전 예고 시간이 짧아짐 |
| `boss_pattern_long_pressure` | 패턴 | 장기 압력 | 아니오 | 단계 종료까지 유지되는 압력 권역 생성 |
| `boss_pattern_final_breath` | 패턴 | 마지막 숨 | 아니오 | 약한 복합 동반 웨이브 |
| `boss_pattern_last_bastion` | 패턴 | 마지막 기지 | 아니오 | 남은 공간으로 최후 방어를 요구 |
| `boss_ui_final_phase_plan` | UI | 최종 단계 예고 | 아니오 | 각 단계의 압력 권역과 동반 웨이브를 미리 표시 |
| `boss_phase_plan_winter_gate_final_100` | 전투 흐름 | 100일 겨울의 문 완전체 흐름 | 아니오 | 입장 예고, 전방 장기 압력, 부위 집중, 약한 복합 동반, 마지막 이전, 마지막 기지 |
| `boss_phase_100_entry_warning` | 단계 | 입장 예고 | 아니오 | 첫 장기 압력 권역과 최종 방어선 후보 표시 |
| `boss_phase_100_front_long_pressure` | 단계 | 전방 장기 압력 | 아니오 | 전방 킬존 유지/포기 판단 |
| `boss_phase_100_part_focus` | 단계 | 부위 집중 | 아니오 | 문의 핵, 마지막 사슬 중 우선 대상 선택. 문턱 심장은 확장 부위 |
| `boss_phase_100_companion_priority` | 단계 | 약한 복합 동반 | 아니오 | 방해형/정예/대형 적 중 먼저 끊을 대상 합의 |
| `boss_phase_100_last_relocation` | 단계 | 마지막 이전 | 아니오 | 남은 설치 공간으로 최종 방어선 이전 |
| `boss_phase_100_last_bastion` | 단계 | 마지막 기지 | 아니오 | 남은 카드, 마나, 아티팩트 집중 사용 |
| `pressure_plan_100_entry_candidate_ui_only` | 압력 계획 | 입장 후보 예고 | 아니오 | 99일 힌트 권역을 다시 표시하되 실제 압력 미적용 |
| `pressure_plan_100_front_long_pressure` | 압력 계획 | 전방 장기 압력 | 아니오 | 전방 설치 권역 1곳을 단계 종료까지 압박 |
| `pressure_plan_100_core_hold` | 압력 계획 | 부위 집중 중 압력 유지 | 아니오 | 압력은 늘리지 않고 부위 선택 시간을 만듦 |
| `pressure_plan_100_maintain_one_zone` | 압력 계획 | 동반 분기 중 1권역 유지 | 아니오 | 동반 웨이브 중에도 장기 압력 1곳만 유지 |
| `pressure_plan_100_last_relocation` | 압력 계획 | 마지막 이전 압력 | 아니오 | 중후방 후보 권역을 예고하고 최종 방어선 이전 요구 |
| `pressure_plan_100_last_bastion_no_new_zone` | 압력 계획 | 마지막 기지 압력 고정 | 아니오 | 새 권역 추가 없이 남은 공간에서 결말 집중 |
| `companion_policy_100_readable_gray_line` | 동반 정책 | 읽기 쉬운 회색 행렬 | 아니오 | 전방 압력 중 기본 군집만 투입 |
| `companion_policy_100_single_husk_anchor` | 동반 정책 | 겨울 껍질 1기 | 아니오 | 부위 집중 중 대형 적 지연 확인 |
| `companion_policy_100_abandoned_weakness_one_branch` | 동반 정책 | 포기 약점 1분기 회수 | 아니오 | 침묵/정예/파괴 중 1개만 약하게 투입 |
| `companion_policy_100_single_large_anchor` | 동반 정책 | 마지막 대형 앵커 | 아니오 | 겨울 껍질 또는 무거운 순례자 1기 이하 |
| `companion_policy_100_readable_final_line` | 동반 정책 | 최종 군집 1회 | 아니오 | 마지막 자원 집중 타이밍 제공 |

### 100일 겨울의 문 완전체 세부 제작표

| 시간대 | 단계 ID | 제작 내용 | 실제 압력 | 동반/부위 | 금지선 |
| ---: | --- | --- | --- | --- | --- |
| 0~20초 | `boss_phase_100_entry_warning` | 첫 장기 압력 후보와 후방 킬존 후보 표시 | 없음 | 없음 | 설치 금지/수리 감소/공속 감소 적용 금지 |
| 20~95초 | `boss_phase_100_front_long_pressure` | 전방 설치 권역 1곳에 장기 압력 적용 | 1권역 | `companion_policy_100_readable_gray_line` | 경로 타일 차단, 비활성 방향 압력 금지 |
| 95~175초 | `boss_phase_100_part_focus` | 문의 핵과 마지막 사슬을 노출하고 부위 선택 요구 | 1권역 유지 | `boss_part_final_core`, `boss_part_last_chain`, 겨울 껍질 1기 이하 | 부위 파괴를 보상/파편/카드 후보와 연결 금지 |
| 175~255초 | `boss_phase_100_companion_priority` | 95일 포기 약점 태그 중 1개만 약한 동반 분기로 회수 | 1권역 유지 | 침묵/정예/파괴 분기 중 1개 | 포기 약점 2개 이상 동시 회수 금지 |
| 255~335초 | `boss_phase_100_last_relocation` | 중후방 후보 권역을 예고하고 마지막 이전 요구 | 1권역, 4인만 제한적 후보 2개 표시 가능 | 겨울 껍질 또는 무거운 순례자 1기 이하 | 사방 동시 압박, 1인 2권역 압박 금지 |
| 335~420초 | `boss_phase_100_last_bastion` | 새 권역 추가 없이 남은 카드/마나/아티팩트 집중 | 기존 1권역 유지 | 읽기 쉬운 최종 군집 1회 | 체력만 긴 반복, 예고 없는 즉시 패배 금지 |

100일 보스의 시간 초과 조정은 본체 체력보다 단계 길이, 동반 웨이브 수, 예고 시간, 압력 지속을 먼저 조정합니다.

단계 사이 2~4초 재배치 숨은 보상 화면이나 상점이 아니라 전투 안의 짧은 호흡입니다.

## 아티팩트 제작표

| ID | 이름 | MVP | 역할 |
| --- | --- | --- | --- |
| `artifact_cracked_bell` | 균열난 종 | 예 | 시드 마나 증가 |
| `artifact_old_observation_lens` | 낡은 관측 렌즈 | 예 | 웨이브 예고 강화 |
| `artifact_broken_crown` | 부서진 왕관 | 예 | 도발/가시 강화 |
| `artifact_whispering_nail` | 속삭이는 못 | 예 | 바리케이드 파괴 둔화 |
| `artifact_blue_capacitor` | 푸른 축전석 | 예 | 드로우와 마나 연결 |
| `artifact_overheated_amp_core` | 과열된 증폭 코어 | 예 | 오라 강화와 위험 |
| `artifact_black_anchor` | 검은 닻 | 예 | 보스 부위 파괴 효과 강화 |
| `artifact_unstable_clock` | 불안정한 시계 | 예 | 웨이브 겹치기 최대치 증가 |
| `artifact_silent_vault` | 침묵의 금고 | 아니오 | 아티팩트 슬롯 증가 |
| `artifact_last_lantern` | 마지막 등불 | 예 | 기지 위기 수리 |
| `artifact_reverse_hourglass` | 역류하는 모래시계 | 아니오 | 숙련자용 웨이브 겹치기 |
| `artifact_glass_seed` | 유리 종자 | 아니오 | 카드 후보 교체와 제거 비용 |
| `artifact_broken_sun` | 부서진 태양 | 아니오 | 폭발 빌드 |
| `artifact_silver_circuit` | 은빛 회로 | 아니오 | 과부하 빌드 |
| `artifact_closed_insignia` | 닫힌 문장 | 아니오 | 시작 손패 변경 |

중요:

웨이브 겹치기 최대치 증가 아티팩트는 보상 증가를 제공하지 않습니다.

### MVP 아티팩트 상세 제작표

| ID | 이름 | 기본 등장 | 운영 축 | 효과 | 대가/제한 | 금지 효과 |
| --- | --- | --- | --- | --- | --- | --- |
| `artifact_cracked_bell` | 균열난 종 | 10일 | `tempo` | 시드 마나 +1 | 하루 시작 손패 -1 | 시간 경과 마나 회복 |
| `artifact_old_observation_lens` | 낡은 관측 렌즈 | 10일 | `route` | 활성 방향 예고와 주요 적 역할을 더 일찍 표시 | 정답 배치 추천 없음 | 비활성 방향 정보 공개 |
| `artifact_broken_crown` | 부서진 왕관 | 10일 | `taunt` | 도발 중 구조물 가시 피해 증가 | 도발 구조물 수리 효율 감소 | 보스 패턴 취소 |
| `artifact_whispering_nail` | 속삭이는 못 | 10일 | `debris` | 바리케이드 파괴 시 주변 둔화 | 잔해 지속 상한 유지 | 완전 길막 |
| `artifact_blue_capacitor` | 푸른 축전석 | 10일 | `draw` | 드로우 게이지 충전 완료 시 전투 마나 소량 획득 | 웨이브당 발동 상한 | 무한 마나/드로우 루프 |
| `artifact_last_lantern` | 마지막 등불 | 10일 | `survival` | 기지 체력 낮을 때 수리 효과 증가 | 기지 체력 높으면 효과 없음 | 전투 중 기지 회복 |
| `artifact_overheated_amp_core` | 과열된 증폭 코어 | 20일 | `aura` | 오라 효과 증가 | 오라 구조물 최대 체력 감소 | 오라 무한 중첩 |
| `artifact_black_anchor` | 검은 닻 | 20일 | `boss` | 보스 부위 파괴 시 보스 이동 속도 잠시 감소 | 보스 본체 패턴 취소 없음 | 보스 장기 정지 |
| `artifact_unstable_clock` | 불안정한 시계 | 20일 이후 | `tempo` | 웨이브 겹치기 최대치 +1 | 겹친 전투 중 구조물 받는 피해 증가 | 골드/카드 후보/희귀도/파편 증가 |
| `artifact_silent_vault` | 침묵의 금고 | 30일 이후 확장 | `survival` | 아티팩트 슬롯 +1 | 상점 가격 상승, 슬롯 최대 4 | 슬롯 5개 이상 |

### 첫 보스 아티팩트 후보 풀

| ID | 이름 | 기본 10일 후보 | 이유 |
| --- | --- | --- | --- |
| `artifact_cracked_bell` | 균열난 종 | 예 | 11일 이후 첫 설치 안정성 |
| `artifact_old_observation_lens` | 낡은 관측 렌즈 | 예 | 활성 방향 예고 강화 |
| `artifact_broken_crown` | 부서진 왕관 | 예 | 도발/가시 방어선 강화 |
| `artifact_whispering_nail` | 속삭이는 못 | 예 | 바리케이드 파괴와 둔화 연계 |
| `artifact_blue_capacitor` | 푸른 축전석 | 예 | 드로우와 마나 연쇄 강화 |
| `artifact_last_lantern` | 마지막 등불 | 예 | 낮은 기지 체력 회복 운영 |
| `artifact_unstable_clock` | 불안정한 시계 | 아니오 | 웨이브 겹치기 최대치 증가는 20일 이후 후보 |

### 20일/30일 MVP 아티팩트 후보 풀

| 풀 ID | 시점 | 후보 | 제외 | 제작 의도 |
| --- | --- | --- | --- | --- |
| `artifact_pool_branch_020` | 20일 보스 후 | 10일 미장착 후보, 과열된 증폭 코어, 검은 닻, 불안정한 시계 | 침묵의 금고 | 11~19일에 확인한 약점을 보완하거나 빠른 진행 위험을 감수 |
| `artifact_pool_mvp_result_030` | 30일 MVP 후 | 모든 MVP 후보, 침묵의 금고 확장 후보 | 보상 증가형, 희귀도 보정형, 카드 후보 증가형 | 31일 이후 확장 런의 유지/교체 판단 예고 |

`artifact_pool_branch_020`에서 `artifact_unstable_clock`이 후보로 등장하면, 후보 카드에 `보상 증가 없음`과 `구조물 피해 증가`를 함께 표시합니다.

### 성장 단계별 아티팩트 풀

| ID | 구간 | 역할 | 금지선 |
| --- | --- | --- | --- |
| `artifact_pool_foundation_010` | 10일 | 첫 운영 방향 선택 | 웨이브 겹치기 최대치 증가 제외 |
| `artifact_pool_branch_020` | 20일 | 첫 빌드 보완과 위험한 전환 | 보상 증가형 아티팩트 제외 |
| `artifact_pool_branch_021_030` | 21~30일 | 빌드 방향 확정과 약점 보완 | 보상 증가형 아티팩트 제외 |
| `artifact_pool_pressure_040_050` | 40~50일 | 여름 속도, 과열, 구조물 손실 대응 | 순수 수치 상위호환 금지 |
| `artifact_pool_route_060_070` | 60~70일 | 경로 변화, 잔해, 방해형/정예 대응 | 비활성 방향 개방 금지 |
| `artifact_pool_winter_080_090` | 80~90일 | 결빙, 압력 타일, 후방 킬존 대응 | 새 아키타입 강제 금지 |
| `artifact_pool_final_095` | 95일 | 최종 보스 약점 보완 | 웨이브 겹치기 보상, 희귀도 보정 금지 |
| `artifact_pool_final_closure_095` | 95일 최종 상점 | `artifact_pool_final_095`에서 새 빌드 시작형과 슬롯/겹치기 신규 증가를 제외한 실제 후보 | 현재 유지 선택 항상 제공 |

### 아티팩트 선택/교체 제작 항목

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `artifact_choice_flow` | 흐름 | 예 | 보스 결과, 다음 압박, 후보, 슬롯, 투표, 상점 연결 |
| `artifact_candidate_diversity_rule` | 후보 규칙 | 예 | 후보 3개가 서로 다른 운영 축을 제안하게 함 |
| `artifact_replacement_hint_tags` | 교체 태그 | 아니오 | 현재 핵심, 다음 압박 적합, 죽은 효과, 대가 위험 표시 |
| `artifact_keep_current_rule` | 슬롯 규칙 | 예 | 슬롯이 가득 찼을 때 현재 유지 선택 제공 |
| `artifact_late_pool_lock_rule` | 후반 풀 규칙 | 아니오 | 91일 이후 새 빌드 시작형 후보 제외 |
| `artifact_slot_cap_rule` | 슬롯 규칙 | 예 | 슬롯 증가 효과가 있어도 최대 4개 유지 |
| `artifact_dormant_vault_rule` | 휴면 규칙 | 아니오 | 교체된 아티팩트를 효과가 꺼진 보관함으로 이동 |
| `artifact_reactivation_rule` | 재장착 규칙 | 아니오 | 보스 후 정비에서 비용과 투표로 휴면 아티팩트 재장착 |
| `artifact_reactivation_cost_profiles` | 비용 규칙 | 아니오 | 휴면 아티팩트 재장착 비용과 허용 위치 정의 |
| `artifact_side_effect_profiles` | 부작용 규칙 | 예 | 후보, 슬롯, HUD에서 같은 대가 태그를 표시 |

### 아티팩트 휴면/부작용 제작 기준

| 항목 | 제작 기준 | 금지선 |
| --- | --- | --- |
| 휴면 보관함 | 기본 2칸, 효과 꺼짐, 마지막 장착 구간 표시 | 휴면 효과 유지, 전투 중 즉시 교체 |
| 재장착 | 보스 후 선택/상점에서 보스 파편과 투표 요구 | 무료 재장착, 자동 추천 장착 |
| 방출 | 보관함 초과 시 1개 선택, 환급 없음 | 골드/파편 환급, 보상 증가 |
| 슬롯 감소 | 슬롯 증가 아티팩트를 내리면 초과 장착 해소 필요 | 슬롯 5개 이상, 초과 장착 유지 |
| 부작용 표시 | 후보 카드, 슬롯, HUD에서 같은 태그 사용 | 숨은 패널티, 전투 정보 가림 |
| 고위험 대가 | 20일 이후 위험 전환 후보부터 허용 | 10일 첫 후보에 `high` 대가 |

기본 부작용 프로필:

| ID | 태그 | 사용처 | 금지 효과 |
| --- | --- | --- | --- |
| `artifact_side_effect_start_hand_down` | `artifact_cost_start_hand_down` | 하루 시작 손패 감소 | 카드 후보 수 보정 |
| `artifact_side_effect_seed_mana_down` | `artifact_cost_seed_mana_down` | 시드 마나 감소 | 시간 경과 마나 회복 |
| `artifact_side_effect_structure_damage_up_stacked` | `artifact_cost_structure_damage_up` | 겹친 전투 구조물 피해 증가 | 겹치기 보상 증가 |
| `artifact_side_effect_repair_down` | `artifact_cost_repair_down` | 수리 효율 감소 | 전투 중 기지 회복 보상 |
| `artifact_side_effect_shop_surcharge` | `artifact_cost_shop_surcharge` | 상점 가격 상승 | 희귀도 보정 |
| `artifact_side_effect_trigger_cap` | `artifact_cost_trigger_cap` | 웨이브당 발동 상한 | 무한 발동 |
| `artifact_side_effect_conflict` | `artifact_cost_conflict` | 아티팩트 충돌 표시 | 정답 추천 |

재장착 비용 프로필:

| ID | 비용 | 허용 위치 | 금지선 |
| --- | --- | --- | --- |
| `artifact_reactivation_cost_boss_shard_1` | 보스 파편 1 | 보스 후 선택, 보스 후 상점 | 전투 중 재장착, 무료 재장착 |
| `artifact_reactivation_cost_final_replace_095` | 보스 파편 1 + 골드 35 | 95일 최종 상점 | 아티팩트 행동 2회 이상, 보상 증가 할인 |

## 보상과 상점 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `boss_reward_day_010_silent_colossus` | 보스 보상 | 예 | 골드 +35, 보스 파편 +1, 아티팩트 후보 3개 |
| `boss_reward_day_020_silent_colossus_variant` | 보스 보상 | 예 | 골드 +45, 보스 파편 +1, 아티팩트 후보 3개 |
| `boss_reward_day_030_season_observer_preview` | 보스 보상 | 예 | 골드 +50, 보스 파편 +1, 아티팩트 후보 3개 |
| `boss_settlement_scenario_010_foundation` | 보스 결산 | 예 | 첫 보스 리포트를 11~20일 운영 선택으로 연결 |
| `boss_settlement_scenario_020_branch` | 보스 결산 | 예 | 변형 보스 리포트를 21~30일 운영 보완으로 연결 |
| `boss_settlement_scenario_030_mvp_result` | 보스 결산 | 예 | 30일 결과를 유지/교체/계속하기 판단으로 연결 |
| `artifact_pool_foundation_010` | 아티팩트 풀 | 예 | 첫 보스 후 기본 운영 방향 후보 |
| `shop_session_day_005_first_shop` | 상점 세션 | 예 | 카드 제거, 강화, 기지 보강을 처음 보여줌 |
| `shop_session_after_day_010` | 상점 세션 | 예 | 보스 후 7~8개 항목, 파티 구매 최대 2회 |
| `shop_session_day_015_small_shop` | 상점 세션 | 예 | 11~14일 피해 진단을 강점 강화 또는 약점 보완으로 연결 |
| `shop_session_after_day_020` | 상점 세션 | 예 | 첫 빌드 방향 확인, 카드 제거 본격화 |
| `shop_session_after_day_050` | 상점 세션 | 아니오 | 중간 점검, 아티팩트 슬롯 재검토 |
| `shop_session_after_day_070` | 상점 세션 | 아니오 | 고급 제거, 정예/방해형 대응 압축 |
| `shop_session_after_day_090` | 상점 세션 | 아니오 | 최종 보스 대응 카드와 아티팩트 교체 |
| `shop_session_day_095_final_market` | 상점 세션 | 아니오 | 새 빌드 시작 없이 마지막 약점 보완 |
| `maintenance_flow` | 정비 흐름 | 예 | 전투 요약, 피해 진단, 개인 보상, 다음 압박, 파티 정비, 준비 확정 |
| `maintenance_diagnostic_tags` | 정비 태그 | 예 | 누수, 구조물 붕괴, 손패 막힘, 우선순위 실패 등을 상점 추천과 연결 |
| `shop_recommendation_rules_010` | 추천 규칙 | 예 | 11~14일 압박과 첫 보스 피해 진단을 연결 |
| `shop_timer_extension_rule` | 시간 규칙 | 예 | 연장 시 선택지 축소와 강제 구매 금지 |
| `shop_price_table_mvp_001_020` | 가격 규칙 | 예 | 5, 10, 15, 20일 상점 가격 기준 |
| `shop_session_matrix_005_020` | 상점 세션 | 예 | 5/10/15/20일 항목 수, 파티 구매 한도, 목표 시간 |
| `shop_price_table_mvp_001_030` | 가격 규칙 | 예 | 5, 10, 15, 20, 25, 30일 상점 가격 기준 |
| `shop_session_matrix_005_030` | 상점 세션 | 예 | 5/10/15/20/25/30일 항목 수, 파티 구매 한도, 목표 시간 |
| `shop_session_day_025_season_turn` | 상점 세션 | 예 | 봄 약점과 여름 속도 예고를 연결하는 작은 정비 |
| `shop_session_after_day_030_mvp_result` | 상점 세션 | 예 | MVP 종료 후 계속하기를 선택했을 때 31일 준비 |
| `shop_skip` | 상점 항목 | 예 | 구매하지 않고 골드를 남기는 선택 |
| `shop_intro_remove_card` | 상점 항목 | 예 | 5일 첫 저가 제거, 시작 카드 제거 불가 |
| `shop_first_stable_upgrade` | 상점 항목 | 예 | 5일 첫 안정 강화 학습 |
| `shop_restore_base_3` | 상점 항목 | 예 | 작은 상점용 기지 체력 3 회복 |
| `shop_diagnostic_recommendation` | 추천 항목 | 예 | 11~14일 피해 진단 기반 작은 상점 묶음 |
| `shop_remove_card` | 상점 항목 | 예 | 덱 압축 |
| `shop_remove_start_card` | 상점 항목 | 예 | 20일 이후 시작 카드 제거, 높은 비용 |
| `shop_upgrade_card` | 상점 항목 | 예 | 자주 쓰는 카드 강화 |
| `shop_upgrade_price_bands_mvp` | 가격 규칙 | 예 | 안정, 특화, 전환, 저주 안정화, 영웅 조율 가격 밴드 |
| `shop_upgrade_offer_rules_mvp` | 추천 규칙 | 예 | 피해 진단, 다음 압박, 최근 사용 카드로 강화 후보 생성 |
| `shop_upgrade_owner_rotation_rule` | 추천 규칙 | 예 | 최근 강화받지 못한 플레이어 후보를 약하게 보정 |
| `shop_upgrade_surcharge_rules_mvp` | 가격 규칙 | 예 | 반복 강화, 같은 상점 두 번째 강화, 같은 진단 반복 해결 할증 |
| `shop_restore_base_5` | 상점 항목 | 예 | 기지 체력 5 회복 |
| `shop_structure_hp_upgrade` | 상점 항목 | 예 | 다음 10일 구조물 안정성 |
| `shop_repair_efficiency_boost` | 상점 항목 | 예 | 15일 이후 수리 효율 보강 |
| `shop_one_shot_spell` | 상점 항목 | 예 | 위기 대응용 일회성 선택 |
| `shop_temporary_seed_mana` | 상점 항목 | 예 | 다음 1웨이브만 적용되는 시드 마나 임시 보강 |
| `temp_seed_mana_day_025_next_wave` | 배타 그룹 | 예 | 25일 이벤트/상점 임시 시드 마나 +1 중첩 방지 |
| `shop_common_card` | 상점 항목 | 예 | 덱 빈틈 보완 |
| `shop_class_card` | 상점 항목 | 예 | 10일 이후 직업 카드 구매 |
| `shop_heroic_tune` | 상점 항목 | 예 | 20일/30일 허용 세션에서 게이트 조건을 통과한 빌드 마무리 |
| `shop_boss_shard_extra_artifact_peek` | 보스 파편 항목 | 예 | 보스 파편 1개로 아티팩트 후보 1개 추가 확인 |
| `shop_season_turn_summary` | 추천 항목 | 예 | 25일 봄 약점과 여름 속도 예고 요약 |
| `shop_keep_current_build` | 결과 정비 항목 | 예 | 30일 MVP 후 현재 운영 유지 |
| `shop_artifact_replace` | 보스 파편 항목 | 예 | 30일 이후 아티팩트 교체 판단 |
| `shop_advanced_remove_card` | 보스 파편 항목 | 예 | 골드와 보스 파편을 함께 쓰는 고급 제거 |
| `shop_final_mvp_note` | 결과 정비 항목 | 예 | 30일 결과를 다음 런 또는 31일 준비 메모로 저장 |
| `shop_final_patch_upgrade` | 상점 항목 | 예 | 30일 이후 새 아키타입 없이 핵심 카드 보완 |
| `shop_artifact_replace_discount` | 보스 파편 항목 | 아니오 | 슬롯 압박 이후 아티팩트 교체 비용 완화 |
| `shop_late_deck_trim_bundle` | 상점 항목 | 아니오 | 61일 이후 핵심 덱 압축 지원 |
| `shop_final_weakness_patch` | 상점 항목 | 아니오 | 95일 최종 약점 보완, 새 아키타입 시작 금지 |
| `shop_final_market_note` | 무료 정보 항목 | 아니오 | 95일 이후 잠기는 유지 축과 포기한 약점 요약 |
| `shop_final_relocation_order` | 최종 상점 항목 | 아니오 | 핵심 구조물 1개 이전 또는 이전 비용 완화 |
| `shop_final_deck_trim` | 최종 상점 항목 | 아니오 | 방치 카드 1장 제거 또는 저효율 카드 1장 안정화 |
| `shop_final_core_tune` | 최종 상점 항목 | 아니오 | 최근 사용한 핵심 카드/구조물 축 1개 보완 |
| `shop_final_artifact_replace` | 최종 상점 항목 | 아니오 | 아티팩트 1개 교체, 행동 한도 1회 소모 |
| `shop_final_base_reinforce` | 최종 상점 항목 | 아니오 | 기지 회복 또는 마지막 방어선 내구 보강 |
| `shop_final_boss_part_lens` | 최종 상점 항목 | 아니오 | 100일 3단계 부위 노출과 첫 부위 집중 보조 |
| `shop_next_pressure_recommendation` | 추천 항목 | 예 | 11일 예고와 연결된 상점 추천 |
| `mvp_reward_shop_event_simulation_001_030` | 운영표 | 예 | 1~30일 카드 보상, 이벤트, 상점, 보스 결산 실행 순서 |

### 95일 최종 상점 실제 슬롯 제작표

| 세션 ID | 고정 슬롯 | 진단 슬롯 | 조건 슬롯 | 파티 구매 한도 | 목표 시간 |
| --- | --- | --- | --- | ---: | ---: |
| `shop_session_day_095_final_market` | `shop_final_market_note`, `shop_keep_current_build` | `shop_final_relocation_order`, `shop_final_deck_trim`, `shop_final_core_tune` 중 진단 상위 3개 | `shop_final_artifact_replace`, `shop_final_base_reinforce`, `shop_final_boss_part_lens` 중 자원/약점 조건 1~2개 | 2 | 120~150초 |

총 표시 항목은 7개를 넘기지 않습니다.

`shop_final_market_note`와 `shop_keep_current_build`는 파티 구매 한도를 소모하지 않습니다.

### 95일 최종 상점 가격 제작표

| 상품 ID | 기본 비용 | 구매 한도 | 추가 제한 | 금지 효과 |
| --- | ---: | ---: | --- | --- |
| `shop_final_market_note` | 무료 | 0 | 항상 표시 | 구매 유도 문구 |
| `shop_keep_current_build` | 무료 | 0 | 항상 표시 | 손해/실패 문구 |
| `shop_final_relocation_order` | 골드 60 | 1 | 구조물 1개 또는 이전 비용 1회 | 경로 차단, 구조물 복제 |
| `shop_final_deck_trim` | 골드 70 + 제거 누적값 | 1 | 카드 1장 제거 또는 1장 안정화 | 카드 2장 이상 제거, 대량 압축 |
| `shop_final_core_tune` | 골드 75 | 1 | 최근 사용한 카드/구조물 축만 | 새 카드 구매, 새 아키타입 시작 |
| `shop_final_artifact_replace` | 보스 파편 1 + 골드 35 | 1 | 아티팩트 행동 1회 소모 | 슬롯 증가, 겹치기 신규 증가 |
| `shop_final_base_reinforce` | 골드 65 | 1 | 기지 회복 또는 방어선 보강 중 하나 | 100일 보스 패턴 취소 |
| `shop_final_boss_part_lens` | 보스 파편 1 또는 골드 85 | 1 | 100일 3단계 부위 정보 보조 | 보스 부위 즉시 파괴, 보상 증가 |

95일 상점 종료 시 `chosenFocusTags` 1~2개와 `abandonedWeaknessTags` 1~2개를 기록합니다.

구매한 상품의 `cannotPatchWeaknessTags` 중 최소 1개는 남겨둔 위험 후보로 표시되어야 합니다.

### MVP 상점 실제 슬롯 제작표

| 세션 ID | 일자 | 고정 슬롯 | 선택 슬롯 | 파티 구매 한도 |
| --- | ---: | --- | --- | ---: |
| `shop_session_day_005_first_shop` | 5 | `shop_intro_remove_card`, `shop_first_stable_upgrade`, `shop_restore_base_3`, `shop_consumable_bracing_kit`, `shop_skip` | `shop_common_card` 또는 `shop_consumable_path_ruler` | 1 |
| `shop_session_after_day_010` | 10 | `shop_remove_card`, `shop_upgrade_card`, `shop_restore_base_5`, `shop_structure_hp_upgrade`, `shop_common_card`/`shop_class_card`, `shop_next_pressure_recommendation`, `shop_skip` | `shop_spell_signal_flare`, `shop_spell_crosswind`, `shop_boss_shard_extra_artifact_peek` 중 1개 | 2 |
| `shop_session_day_015_small_shop` | 15 | `shop_diagnostic_recommendation`, `shop_remove_card`, `shop_upgrade_card`, `shop_repair_efficiency_boost`, `shop_restore_base_3` | `shop_spell_emergency_bell`, `shop_consumable_spare_plating`, `shop_common_card`, `shop_skip` 중 1개 | 1 |
| `shop_session_after_day_020` | 20 | `shop_remove_card`, `shop_remove_start_card`, `shop_upgrade_card`, `shop_restore_base_5`, `shop_structure_hp_upgrade`, `shop_next_pressure_recommendation`, `shop_skip` | `shop_heroic_tune`, `shop_spell_part_lens`, `shop_spell_quiet_lantern` 중 조건 충족 1개 | 2 |
| `shop_session_day_025_season_turn` | 25 | `shop_season_turn_summary`, `shop_remove_card`, `shop_upgrade_card`, `shop_restore_base_3`, `shop_temporary_seed_mana` | `shop_spell_frost_line`, `shop_consumable_quick_scaffold`, `shop_skip` 중 1개 | 1 |
| `shop_session_after_day_030_mvp_result` | 30 | `shop_keep_current_build`, `shop_artifact_replace`, `shop_advanced_remove_card`, `shop_heroic_tune`, `shop_final_mvp_note` | `shop_restore_base_5` 또는 `shop_final_patch_upgrade` | 2 |

무료 정보 항목과 `shop_skip`은 파티 구매 한도를 소모하지 않습니다.

`shop_session_after_day_030_mvp_result`는 MVP 종료 후 계속하기를 선택했을 때만 31일 준비 화면으로 사용합니다.

### 20~30일 영웅 확정 조율 상점 제작표

`shop_heroic_tune`은 카드 후보 보상 UI가 아니라 파티 자원 상점 UI입니다.

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `shop_heroic_tune_offer` | 데이터 | 예 | `ShopHeroicTuneOffer`로 게이트, 카드, 가격, 투표, 결과를 묶음 |
| `shop_heroic_tune_flow_profile` | 데이터 | 예 | 후보 생성, 전면 제안 선정, 대상 확인, 파티 투표, 종료 상태를 정의 |
| `shop_heroic_tune_selection_policy` | 데이터 | 예 | 최근 리포트, 대상 중복 방지, 최근 증거, 고정 좌석 순서만 사용 |
| `ui_shop_heroic_tune_card` | 상점 UI | 예 | 대상 플레이어, 영웅 카드, 비용, 남는 대가, 증거 태그를 한 카드에 표시 |
| `ui_shop_heroic_tune_free_info` | 무료 정보 UI | 예 | 게이트 미통과 또는 파편 부족을 유료 구매 없이 조건 요약으로 표시 |
| `ui_shop_heroic_tune_locked_reason` | 잠금 UI | 예 | 파편 부족, 게이트 미통과, 세션 구매 완료, 대상 거절을 구매 버튼 없이 표시 |
| `ui_shop_heroic_tune_compare_drawer` | 비교 UI | 예 | 여러 게이트가 통과됐을 때 최대 2개 후보만 비교 표시 |
| `ui_shop_heroic_owner_accept` | 개인 확인 | 예 | 카드를 받을 플레이어가 먼저 수락하거나 거절 |
| `ui_shop_party_resource_vote` | 파티 투표 | 예 | 대상 수락 후 파티 골드와 보스 파편 사용을 과반수로 확인 |
| `ui_shop_heroic_no_purchase_result` | 보류 결과 | 예 | 시간 초과, 대상 거절, 파티 반대, 파편 부족을 구매 없음으로 회수 |
| `ui_shop_heroic_no_reoffer_hint` | 보류 안내 | 예 | 거절 뒤 같은 세션에서 다른 영웅 후보로 재설득하지 않음을 짧게 표시 |
| `ui_shop_heroic_alternatives` | 대체 선택 | 예 | 제거, 강화, 회복, 구조물 보강, 일회성 주문 중 경쟁 항목을 보여줌 |
| `telemetry_shop_heroic_tune_phase_changed` | 로그 | 예 | 조건 요약, 대상 확인, 파티 투표, 구매 없음, 구매 완료 전이를 기록 |

영웅 확정 조율 제작 금지선:

- 상점 항목은 1개만 차지하고, 비교 패널은 카드 후보 수나 상점 슬롯 수를 늘리지 않습니다.
- 보스 파편 1개가 없으면 대체 골드 결제를 제공하지 않습니다.
- 대상 플레이어가 거절하면 파티 투표를 열지 않습니다.
- 대상 플레이어가 거절하거나 시간이 초과되면 같은 세션에서 다른 영웅 후보로 갈아타며 다시 제안하지 않습니다.
- 멀티에서는 대상 수락과 파티 과반 동의가 모두 필요합니다.
- 솔로에서는 같은 규칙을 8초 확인으로 축약합니다.
- 구매 결과는 영웅 카드 1장 추가뿐이며, 카드 제거, 후보 수 증가, 희귀도 보정, 골드/보스 파편 보상 변화가 함께 붙지 않습니다.
- 추천 이유는 최근 사용 증거 태그로만 표시하고, 웨이브 겹치기 횟수, 처치 수, 클리어 시간, 비활성 방향 압박을 사용하지 않습니다.

### MVP 1~30일 보상/상점/이벤트 제작표

| 제작 ID | 일자 | 카드 보상 잠금 | 후속 제작물 | 확인할 감정 |
| --- | --- | --- | --- | --- |
| `mvp_day_reward_001` | 1 | `loot_lock_round_001_004` | 없음 | 첫 보상 카드가 직업 기본 행동을 보강함 |
| `mvp_day_reward_002_004` | 2~4 | `loot_lock_round_001_004` | 없음 | 3장 후보가 모두 같은 역할로 보이지 않음 |
| `mvp_day_reward_005` | 5 | `loot_lock_round_005_010` | `shop_session_day_005_first_shop` | 작은 상점 1회 구매만으로도 정비를 배움 |
| `mvp_day_reward_006_009` | 6~9 | `loot_lock_round_005_010` | 없음 | 첫 보스 준비 카드가 과한 정답처럼 보이지 않음 |
| `mvp_day_reward_010` | 10 | `loot_lock_boss_010` | `artifact_pool_foundation_010`, `shop_session_after_day_010` | 보스 결과가 카드, 아티팩트, 상점 중 다른 해법으로 이어짐 |
| `mvp_day_reward_011_014` | 11~14 | `loot_lock_round_011_020` | 없음 | 첫 아티팩트와 맞는 카드가 보이되 새 시스템을 강요하지 않음 |
| `mvp_day_reward_015` | 15 | `loot_lock_round_011_020` | `event_contract_lock_mvp_015`, `shop_session_day_015_small_shop` | 이벤트와 작은 상점이 90초 안에 끝남 |
| `mvp_day_reward_016_019` | 16~19 | `loot_lock_round_011_020` | 없음 | 15일 선택을 전투에서 다시 체감함 |
| `mvp_day_reward_020` | 20 | `loot_lock_boss_020` | `artifact_pool_branch_020`, `shop_session_after_day_020` | 영웅 확정 조율이 준비된 빌드만 마무리함 |
| `mvp_day_reward_021_024` | 21~24 | `loot_lock_round_021_030` | 없음 | 영웅 후보가 낮은 빈도와 게이트 조건으로만 보임 |
| `mvp_day_reward_025` | 25 | `loot_lock_round_021_030` | `event_contract_lock_mvp_025`, `shop_session_day_025_season_turn` | 계절 전환이 보스 보상처럼 느껴지지 않음 |
| `mvp_day_reward_026_029` | 26~29 | `loot_lock_round_021_030` | 없음 | 고밀도 겹치기가 보상 펌핑으로 읽히지 않음 |
| `mvp_day_reward_030` | 30 | `loot_lock_boss_030` | `artifact_pool_mvp_result_030`, `shop_session_after_day_030_mvp_result` | 현재 운영 유지와 정리 선택을 구분함 |

제작 검수자는 이 표를 기준으로 각 일자의 보상 UI, 정비 UI, 이벤트 UI가 같은 잠금 ID를 공유하는지 확인합니다.

### MVP 보스 결산 제작표

| 제작 ID | 일자 | 리포트 태그 후보 | 연결 제작물 | 확인할 감정 |
| --- | ---: | --- | --- | --- |
| `boss_settlement_scenario_010_foundation` | 10 | `boss_legs_ignored`, `boss_front_ignored`, `boss_lantern_ignored`, `structure_clustered`, `stack_overreach` | `loot_lock_boss_010`, `artifact_pool_foundation_010`, `shop_session_after_day_010` | 첫 보스에서 놓친 판단이 다음 10일 운영 선택으로 번역됨 |
| `boss_settlement_scenario_020_branch` | 20 | `draw_starved`, `structure_marked_missed`, `single_target_overfocus`, `lane_neglected`, `build_axis_confirmed` | `loot_lock_boss_020`, `artifact_pool_branch_020`, `shop_session_after_day_020` | 기존 운영을 유지, 보완, 위험 전환 중 하나로 읽음 |
| `boss_settlement_scenario_030_mvp_result` | 30 | `forecast_assignment_failed`, `observation_core_ignored`, `season_eye_leak`, `mvp_build_stable`, `deck_pressure_high` | `loot_lock_boss_030`, `artifact_pool_mvp_result_030`, `shop_session_after_day_030_mvp_result` | MVP 클리어 보너스가 아니라 유지/정리 판단으로 읽음 |

결산 태그는 추천 이유와 후보 설명을 바꾸지만, 보상 후보 수, 희귀도, 골드, 보스 파편을 바꾸지 않습니다.

## 상점 소모품 제작표

| ID | 이름 | 분류 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `shop_consumable_bracing_kit` | 임시 버팀목 | 구조물 보강 | 예 | 구조물 1개 임시 체력, 다음 웨이브 한정 |
| `shop_consumable_spare_plating` | 예비 판금 | 구조물 보강 | 예 | 구조물 1개 짧은 피해 감소 |
| `shop_consumable_path_ruler` | 경로 자 | 정보 도구 | 예 | 활성 방향 경로와 길막 위험 표시 강화 |
| `shop_consumable_quick_scaffold` | 급조 받침대 | 구조물 보강 | 예 | 낮은 체력 임시 바리케이드 |
| `shop_consumable_repair_chalk` | 수리 분필 | 구조물 보강 | 아니오 | 15일 이후 3x3 구역 수리 효율 보강 |
| `shop_consumable_anchor_spike` | 고정 말뚝 | 구조물 보강 | 아니오 | 구조물 1개 밀림/흔들림 저항 |
| `shop_spell_signal_flare` | 신호탄 | 일회성 주문 | 예 | 정예 또는 보스 부위 우선 대상 표시 |
| `shop_spell_crosswind` | 역풍 주문 | 일회성 주문 | 예 | 활성 방향 한 줄 짧은 넉백 |
| `shop_spell_emergency_bell` | 비상 종 | 일회성 주문 | 예 | 모든 플레이어 1장 드로우 후 1장 버림 |
| `shop_spell_smoke_curtain` | 연막 장막 | 일회성 주문 | 예 | 다음 기지 피해 1회 감소 |
| `shop_spell_frost_line` | 서리 선 | 일회성 주문 | 예 | 25일 계절 전환에서 빠른 라인 짧은 둔화 |
| `shop_spell_quiet_lantern` | 고요한 등불 | 일회성 주문 | 예 | 20일 이후 방해형 오라 일시 약화 |
| `shop_spell_part_lens` | 부위 조준 렌즈 | 일회성 주문 | 예 | 20일 이후 보스 부위 우선 핑과 타워 우선순위 보정 |
| `shop_spell_reserve_core` | 예비 축전핵 | 자원 도구 | 예 | 25일 계절 전환에서 선택 플레이어 다음 웨이브 시드 마나 +1 |

## 이벤트 제작표

| ID | 이름 | MVP | 선택 압박 |
| --- | --- | --- | --- |
| `event_cracked_storehouse` | 갈라진 저장고 | 예 | 골드와 기지 체력 교환 |
| `event_silent_pilgrim` | 침묵의 순례자 | 예 | 저주와 기존 아티팩트 후보 사전 확인 |
| `event_fallen_workshop` | 무너진 공방 | 예 | 구조물 강화 vs 카드 제거 |
| `event_season_sign_025` | 계절의 징표 | 예 | 골드와 다음 압박 상세 예고 교환 |
| `event_reserve_core_025` | 축전핵 위탁 | 예 | 다음 1웨이브 시드 마나와 손패 대가 |
| `event_quiet_contract_025` | 조용한 계약서 | 예 | 보유 저주 안정화/제거 할인 예약 |
| `event_frozen_road` | 얼어붙은 길 | 아니오 | 방향별 웨이브 변화 |
| `event_old_bell` | 오래된 종소리 | 아니오 | 보스 보상 vs 보스 위험 |
| `event_buried_map` | 묻힌 지도 | 아니오 | 예고 강화 vs 골드 소비 |
| `event_broken_market` | 부서진 시장 | 아니오 | 싼 카드와 저주 위험 |
| `event_last_caravan` | 마지막 행상 | 아니오 | 회복과 아티팩트 교체 |

### 이벤트 패턴 제작 항목

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `event_choice_flow` | 흐름 | 예 | 등장 이유, 선택 공개, 소유권, 확정, 결과, 다음 압박 연결 |
| `event_choice_guardrails` | 규칙 | 예 | 숨은 패널티, 강제 저주, 비활성 방향 개방 금지 |
| `event_trigger_diagnostic_hooks` | 등장 조건 | 예 | 피해 진단 태그와 이벤트 등장을 약하게 연결 |
| `event_timeout_default_rule` | 시간 규칙 | 예 | 시간 초과 시 상태 보존 선택 적용 |
| `event_active_direction_modifier_rule` | 방향 규칙 | 예 | 이벤트가 웨이브를 바꿔도 활성 방향 안에서만 처리 |
| `event_choice_owner_rule` | 투표 규칙 | 예 | 개인, 파티, 혼합 선택의 처리 기준 |
| `event_contract_lock_mvp_015` | 이벤트 잠금 | 예 | 15일 후보 이벤트 1개와 작은 상점 체류 시간 제한 |
| `event_contract_lock_mvp_025` | 이벤트 잠금 | 예 | 25일 계절 전환 이벤트와 후보 1개 제한 |
| `season_turn_transition_mvp_025` | 전환 프로필 | 예 | 계절의 징표, 조건부 후보, 작은 상점 브리지 태그를 제한 |
| `season_turn_bridge_tag_set_025` | 전환 태그 | 예 | 정보 상세 공개, 임시 시드 잠금, 저주 할인 예약, 지나가기 |
| `reward_choice_lock_flow` | 보상 UI | 예 | 카드 선택, 골드 거절, 임시 잠금, 되돌리기 처리 |
| `reward_to_maintenance_gate` | 정비 UI | 예 | 보상 완료 후 저주 확인, 정비 메모, 상점 첫 투표 진입 관리 |
| `deck_compression_candidate_badges` | 상점 UI | 예 | 낮은 사용률, 역할 중복, 저주 보유, 고비용 막힘 배지 |
| `curse_contract_confirm_flow` | 저주 확인 UI | 예 | 받을 카드, 즉시 이득, 장기 대가, 제거/안정화 시점 표시 |
| `curse_contract_card_guardian_heavy_vow` | 저주 계약 | 예 | 수호자 무거운 서약 계약 |
| `curse_contract_card_architect_overbuilt` | 저주 계약 | 예 | 건축가 무리한 증축 계약 |
| `curse_contract_card_elementalist_forbidden_lantern` | 저주 계약 | 예 | 원소술사 금지된 등불 계약 |
| `curse_contract_card_tinkerer_risky_mod` | 저주 계약 | 예 | 땜장이 위험한 개조 계약 |

### MVP 이벤트 계약 잠금표

| ID | 일자 | 후보 수 | 필수 이벤트 | 선택 후보 | 시간 목표 | 금지선 |
| --- | ---: | ---: | --- | --- | ---: | --- |
| `event_contract_lock_mvp_015` | 15 | 1 | 없음 | `event_cracked_storehouse`, `event_silent_pilgrim`, `event_fallen_workshop` 중 1개 | 30~60초 | 이벤트와 상점 합산 90초 초과 금지 |
| `event_contract_lock_mvp_025` | 25 | 1~2 | `event_season_sign_025` | `event_reserve_core_025`, `event_quiet_contract_025` 중 조건부 1개 | 60~90초 | 31일 이후 새 빌드 강제, 임시 시드 마나 중첩 금지 |

### MVP 저주 계약 제작표

| ID | 카드 | 직업 | 즉시 이득 태그 | 대가 태그 | 안정화/제거 연결 | 금지선 |
| --- | --- | --- | --- | --- | --- | --- |
| `curse_contract_card_guardian_heavy_vow` | 무거운 서약 | 수호자 | `taunt_anchor`, `resource_unjam` | `draw_loss`, `structure_hp_loss` | 저주 안정화, 카드 제거 | 다음 드로우 손실 삭제 금지 |
| `curse_contract_card_architect_overbuilt` | 무리한 증축 | 건축가 | `rear_rebuild`, `path_extension` | `fragile_structure`, `no_salvage_value` | 저주 안정화, 카드 제거 | 회수/파편 회수 가치 부여 금지 |
| `curse_contract_card_elementalist_forbidden_lantern` | 금지된 등불 | 원소술사 | `focus_fire_mark`, `priority_burst` | `kill_mana_loss` | 저주 안정화, 카드 제거 | 일반 처치 마나 대가 삭제 금지 |
| `curse_contract_card_tinkerer_risky_mod` | 위험한 개조 | 땜장이 | `priority_burst`, `aura_timing` | `self_damage`, `repair_efficiency_loss` | 저주 안정화, 카드 제거 | 자동 소화로 완전 무효화 금지 |

## 예고 UI와 리포트 제작표

예고 UI는 플레이어를 놀라게 하는 장식이 아니라, 협동 판단을 맞추는 정보 장치입니다.

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `ui_wave_preview_cards` | 하루 시작 예고 | 예 | 실제 스폰 방향, 적 역할, 대응 태그를 3장 이하로 표시 |
| `ui_wave_preview_question_card` | 예고 카드 | 예 | `WaveIntent`의 핵심 질문을 한 문장으로 표시 |
| `ui_wave_preview_lane_card` | 예고 카드 | 예 | 실제 `WaveSpawnPlan.directions`와 경로 성격 표시 |
| `ui_wave_preview_enemy_role_card` | 예고 카드 | 예 | 주 `EnemyRoleProfile` 1~2개와 필수 예고 표시 |
| `ui_wave_preview_response_card` | 예고 카드 | 예 | 열려 있는 `ResponseTag` 2~4개 표시 |
| `ui_wave_preview_tempo_card` | 예고 카드 | 예 | 겹치기 위험 이유를 보상 문구 없이 표시 |
| `ui_active_direction_frame` | 방향 표시 | 예 | 활성 방향과 비활성 방향을 명확히 구분 |
| `ui_enemy_role_icon_set` | 적 역할 아이콘 | 예 | 군집형, 돌파형, 파괴형, 방해형, 정예형을 빠르게 식별 |
| `ui_structure_mark_warning` | 구조물 위험 | 예 | 파괴 표식, 보스 짓누르기, 수리 우선순위를 표시 |
| `ui_stack_risk_reason` | 겹치기 투표 | 예 | 겹치기 위험 이유를 보상 문구 없이 표시 |
| `ui_hand_lock_warning` | 손패 경고 | 예 | 패 한도 초과와 드로우 손실을 하단 UI에서 표시 |
| `ui_post_wave_micro_report` | 웨이브 후 리포트 | 아니오 | 위험했던 방향과 사용한 대응을 1~2초로 요약 |
| `ui_post_wave_question_recall` | 회수 카드 | 아니오 | 방금 웨이브가 물었던 질문과 결과를 짧게 연결 |
| `ui_post_wave_response_summary` | 회수 카드 | 아니오 | 제시된 대응 태그와 실제 사용한 대응 태그 비교 |
| `ui_post_wave_next_link` | 회수 카드 | 아니오 | 다음 보상, 상점, 도감/훈련장 연결 후보 표시 |
| `ui_defeat_analysis_cards` | 패배 분석 | 예 | 원인 1개와 보조 원인 최대 2개를 카드로 표시 |
| `defeat_analysis_card_breached_direction` | 패배 카드 | 예 | 활성 방향 누수 반복과 기지 피해를 짧게 설명 |
| `defeat_analysis_card_structure_chain` | 패배 카드 | 예 | 핵심 구조물 연쇄 붕괴와 후방 재건 누락을 설명 |
| `defeat_analysis_card_unanswered_role` | 패배 카드 | 예 | 방해형, 돌파형, 파괴형 등 놓친 적 역할을 설명 |
| `defeat_analysis_card_resource_jam` | 패배 카드 | 예 | 손패 막힘, 드로우 손실, 버리기 미사용을 설명 |
| `defeat_analysis_card_stack_overreach` | 패배 카드 | 예 | 겹치기 후 위험 급증을 보상 문구 없이 설명 |
| `defeat_analysis_card_next_try` | 패배 카드 | 예 | 다음 런에서 시험할 대응 태그 1~3개 제안 |
| `next_run_suggestion_lane_plan` | 재도전 제안 | 예 | 첫 굴곡, 경로 연장, 둔화 같은 전선 운영 메모 |
| `next_run_suggestion_structure_policy` | 재도전 제안 | 예 | 지킬 구조물과 버릴 구조물을 나누는 운영 메모 |
| `next_run_suggestion_priority_target` | 재도전 제안 | 예 | 방해형/정예/보스 부위 우선순위 운영 메모 |
| `next_run_suggestion_tempo_hold` | 재도전 제안 | 예 | 치명 체력이나 구조물 붕괴 중 웨이브 호출 보류 메모 |
| `ui_boss_critical_countdown` | 보스 치명 경고 | 예 | 기지 도달 후 즉시 패배 예고를 중앙 상단에 표시 |

예고 카드와 회수 카드는 같은 태그 언어를 써야 합니다.

예고에서 `repair_window`, `sacrifice_value`, `rear_rebuild`를 보여줬다면, 리포트도 그중 무엇이 쓰였고 무엇이 남았는지 같은 태그로 회수합니다.

## 웨이브 겹치기 투표 제작표

웨이브 겹치기 UI는 보상 선택 UI가 아니라 전투 템포 확인 UI입니다.

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `wave_stack_vote_session` | 데이터 | 예 | `WaveStackVoteSession`으로 제안, 투표, 보류, 실행 상태 기록 |
| `ui_wave_stack_call_button` | 전투 UI | 예 | `다음 웨이브 당기기` 버튼과 현재 겹침 수 표시 |
| `ui_wave_stack_risk_preview` | 전투 UI | 예 | 후보 웨이브 방향, 적 역할, 위험 이유를 3장 이하로 표시 |
| `ui_wave_stack_vote_panel` | 투표 UI | 예 | 호출/보류, 남은 시간, 동의 조건, 기지 위험 상태 표시 |
| `ui_wave_stack_hold_reason` | 보류 UI | 예 | 보류 이유를 수리, 재배치, 손패, 보스 패턴 태그로 표시 |
| `ui_wave_stack_spawn_countdown` | 전투 UI | 예 | 호출 확정 후 실제 스폰 방향과 짧은 카운트다운 표시 |
| `ui_wave_stack_blocked_reason` | 전투 UI | 예 | 한도 도달, 후보 미확정, 보스일 제한 등 호출 불가 이유 표시 |
| `ui_wave_stack_no_reward_copy_guard` | 문구 검수 | 예 | 보상, 효율, 희귀도, 추가 선택지 문구 금지 |

투표 시간 초과의 기본 처리는 보류입니다.

보류는 실패가 아니라 전술 응답이므로, 리포트와 텔레메트리에서도 개인 책임으로 다루지 않습니다.

## 압축 정산 제작표

압축 정산은 보상을 늘리는 기능이 아니라, 겹친 전투 뒤 대기 시간을 줄이는 UI입니다.

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `settlement_batch` | 데이터 | 예 | 여러 `WaveRewardPacket`을 일자 순서로 묶어 정산 상태 기록 |
| `reward_packet_wave_basic` | 데이터 | 예 | 웨이브별 기본 카드 후보, 거절 골드, 획득 골드 기록 |
| `ui_settlement_batch_panel` | 보상 UI | 예 | 여러 정산 행을 한 화면에 표시 |
| `ui_settlement_gold_breakdown` | 보상 UI | 예 | 골드 총합과 웨이브별 세부 내역 제공 |
| `ui_settlement_card_row` | 보상 UI | 예 | 각 웨이브 보상 팩의 카드 3장과 골드 거절 버튼 표시 |
| `ui_settlement_temp_lock` | 보상 UI | 예 | 제한 시간 종료 시 미선택 행만 임시 선택 |
| `ui_settlement_no_bonus_copy_guard` | 문구 검수 | 예 | 3배 보상, 겹침 보너스, 희귀도 상승, 추가 선택지 문구 금지 |

정산 묶음은 카드 후보 수, 희귀도, 골드 총량을 바꾸지 않습니다.

선택 시간 단축은 화면 구조로 해결하고, 추가 보상으로 보상하지 않습니다.

## 접근성/연출 옵션 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `accessibility_presentation_options` | 흐름 | 예 | 가독성, 움직임, 사운드, 전술 정보, 협동 신호, 연출 안전선 확인 |
| `access_option_readability_check` | 접근성 옵션 | 예 | UI 배율, 카드 텍스트, 줄바꿈 미리보기 |
| `access_option_motion_adjust` | 접근성 옵션 | 예 | 화면 흔들림, 카메라 관성, 보스 접근 흔들림 조절 |
| `access_option_audio_adjust` | 접근성 옵션 | 예 | 저주파 보스음, 경고음, 핑 소리, 자막 조절 |
| `access_option_tactical_visibility` | 접근성 옵션 | 예 | 경로 상시 표시, 적 윤곽선, 보스 부위 강조 |
| `access_option_coop_signal_assist` | 접근성 옵션 | 예 | 핑 아이콘, 방향 라벨, 색각 보조, 자막 로그 |
| `access_option_safety_guardrail` | 접근성 옵션 | 예 | 유혈/고어/점프 스케어/UI 왜곡/정보 은폐 금지 확인 |
| `ui_accessibility_quick_setup` | 설정 UI | 예 | 첫 실행에서 핵심 3개 옵션만 짧게 확인 |
| `ui_accessibility_preview_panel` | 설정 UI | 예 | 카드, 보스 경고, 경로선, 핑을 한 화면에서 미리보기 |
| `ui_motion_intensity_slider` | 설정 UI | 예 | 화면 흔들림과 카메라 관성 강도 조절 |
| `ui_audio_pressure_mixer` | 설정 UI | 예 | 저주파 보스음, 경고음, 핑 소리 개별 조절 |
| `ui_tactical_visibility_toggles` | 설정 UI | 예 | 경로, 윤곽선, 부위 강조, 방향 라벨 표시 |

## 핑과 협동 콜 제작표

핑은 전투를 멈추는 토론이 아니라, 움직이면서 남기는 짧은 전술 메모입니다.

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `ping_repair_request` | 요청형 핑 | 예 | 표식된 구조물이나 낮은 체력 구조물 수리 요청 |
| `ping_focus_fire` | 요청형 핑 | 예 | 방해형, 정예, 보스 부위 우선 처치 요청 |
| `ping_path_check` | 전술 핑 | 예 | 경로 변경 후보와 설치 위치 제안 |
| `ping_taunt_shift` | 직업 핑 | 예 | 수호자 도발 위치 전환 요청 |
| `ping_control_request` | 직업/공용 핑 | 예 | 돌파형 진입 지점에 둔화, 빙결, 넉백 요청 |
| `ping_move_killzone` | 전술 핑 | 아니오 | 후방 킬존 이전과 장기 방어선 이동 제안 |
| `ping_boss_part_focus` | 보스 핑 | 예 | 파티가 같은 보스 부위를 보도록 표시 |
| `ping_wave_call_suggest` | 투표 전 핑 | 예 | 정식 웨이브 호출 투표 전 의사 확인 |
| `ping_hold` | 보류 핑 | 예 | 지금은 호출, 과부하, 위험 행동을 미루자는 신호 |
| `ping_claim_marker` | 맡음 표시 | 예 | 해당 핑에 누가 대응할지 최대 2명까지 표시 |
| `ping_warning_suggestion` | 경고 기반 후보 | 예 | 자동 경고를 눌렀을 때 가능한 핑 후보를 펼침 |
| `ping_source_badge` | 출처 표시 | 예 | 플레이어 직접 핑, 시스템 경고, 튜토리얼 힌트 구분 |
| `ping_auto_warning_source` | 자동 경고 출처 | 예 | 치명 경고가 만든 표식과 플레이어 핑을 구분 |
| `ping_quick_dismiss` | 정리 조작 | 예 | 해소됐거나 필요 없는 핑을 전투 흐름을 끊지 않고 접음 |
| `ui_warning_priority_stack` | 경고 UI | 예 | 큰 자동 경고는 동시에 2개까지만 표시 |
| `ui_warning_to_ping_bridge` | 경고 UI | 예 | 경고에서 수리, 집중 화력, 보류 같은 핑 후보로 연결 |
| `ui_ping_resolution_log` | 핑 로그 | 아니오 | 웨이브 후 어떤 핑이 실제 행동으로 이어졌는지 짧게 기록 |

## 텔레메트리 제작표

텔레메트리는 밸런스를 고치기 위한 기록입니다.

플레이어에게 직접 보상으로 환산하지 않습니다.

| ID | MVP | 기록 목적 |
| --- | --- | --- |
| `telemetry_run_started` | 예 | `playerCountAtStart`, `activeDirections`, `scalingProfileId` 확정 기록 |
| `telemetry_wave_plan_created` | 예 | 원본 웨이브가 실제 `WaveSpawnPlan`으로 바뀐 결과 기록 |
| `telemetry_wave_preview_shown` | 예 | 예고 카드, 경고 문구, 겹치기 위험 등 표시 정보 기록 |
| `telemetry_wave_started` | 예 | 실제 시작 일자, 방향, 스케일링 결과 기록 |
| `telemetry_wave_stack_vote_started` | 예 | 후보 웨이브, 위험 수준, 동의 조건, 출처 기록 |
| `telemetry_wave_stack_vote_resolved` | 예 | 호출, 보류, 만료, 취소 결과와 이유 태그 기록 |
| `telemetry_wave_stacked` | 예 | 투표 세션 ID, 겹친 웨이브 수, 시작 시점 변화 기록 |
| `telemetry_settlement_batch_opened` | 예 | 정산 묶음, 보상 팩 수, 골드 합산, 표시 방식 기록 |
| `telemetry_settlement_packet_choice_locked` | 예 | 플레이어별 보상 팩 선택, 거절, 임시 선택 기록 |
| `telemetry_settlement_batch_resolved` | 예 | 정산 소요 시간, 임시 선택 수, 되돌리기 수, 보너스 오해 감지 기록 |
| `telemetry_wave_completed` | 예 | 클리어 시간, 남은 기지 체력, 구조물 손실 기록 |
| `telemetry_base_damage_taken` | 예 | 방향, 피해량, 피해 전후 기지 체력, 치명 여부, 원인 태그 기록 |
| `telemetry_base_breach_warning_raised` | 예 | 방향, 경고 단계, 예상 도달 시간, 예상 피해, 제안 핑 후보 기록 |
| `telemetry_base_breach_warning_resolved` | 예 | 해소 이유, 해소 시점 도달 예상 시간, 확정된 핑 후보 기록 |
| `telemetry_base_recovery_purchased` | 아니오 | 회복량, 가격, 치명 할증, 회복 전후 기지 체력 기록 |
| `telemetry_combat_tuning_sampled` | 예 | 첫 접촉, 첫 파괴, 첫 기지 피해, 경로 연장, 마나/드로우 흐름 기록 |
| `telemetry_wave_learning_phase_resolved` | 아니오 | 첫 10일 학습 단계, 강한 질문, 실제 대응 태그 기록 |
| `telemetry_first_wave_role_check` | 아니오 | 첫 10일 일자별 직업 대응 체크 통과 여부 기록 |
| `telemetry_chapter_phase_resolved` | 아니오 | 10일 챕터 안 운영 단계, 질문 태그, 실제 대응 태그 기록 |
| `telemetry_mvp30_day_contract_resolved` | 예 | 1~30일 일자별 학습 약속, 잠금 태그, 조정 필드, 금지 태그 감지 기록 |
| `telemetry_spring2_operation_choice_resolved` | 아니오 | 15일 작은 상점/보상 선택이 16~20일에서 검증됐는지 기록 |
| `telemetry_mvp_summer_preview_bridge_resolved` | 아니오 | 25일 예고, 26~29일 리포트 태그, 30일 관측자 후보 방향 연결 여부 기록 |
| `telemetry_observer_preview_resolved` | 아니오 | 30일 관측자 예고형 후보 방향, 실제 방향, 재분담 행동 기록 |
| `telemetry_overheat_tile_decision_resolved` | 아니오 | 과열 타일 사용, 포기, 구조물 손실, 판단 이유 기록 |
| `telemetry_overheated_colossus_phase_started` | 아니오 | 40일 과열된 거상 단계, 열 원인, 활성 과열 타일, 경고 표시 기록 |
| `telemetry_marked_structure_decision_resolved` | 아니오 | 표식 구조물을 살렸는지, 희생했는지, 전술 가치가 있었는지 기록 |
| `telemetry_observer_enhanced_phase_started` | 아니오 | 50일 관측자 강화형 단계, 후보 방향, 후보 과열, 표식 구조물 기록 |
| `telemetry_leaf_path_decision_resolved` | 아니오 | 낙엽 예고 후 킬존 이동/유지 판단과 이유 기록 |
| `telemetry_debris_route_reopen_triggered` | 아니오 | 잔해/낙엽 완전 길막 방지를 위해 경로 재개방 규칙이 실행됐는지 기록 |
| `telemetry_fallen_belltower_phase_started` | 아니오 | 60일 무너진 종탑 단계, 무음 권역, 오라/수리 약화값, 표시 경고 기록 |
| `telemetry_priority_target_decision_resolved` | 아니오 | 방해형, 정예, 보스 부위 중 먼저 본 대상과 변경 이유 기록 |
| `telemetry_split_priority_assignment_resolved` | 아니오 | 두 활성 방향의 위험 분담, 재배치 행동, 미해결 위험 기록 |
| `telemetry_belltower_variant_companion_resolved` | 아니오 | 70일 종탑 변형의 동반 조합, 스폰 방향, 우선 처치 해소 여부 기록 |
| `telemetry_frost_zone_decision_resolved` | 아니오 | 결빙 예고 후 구조물 이전, 해동, 남은 설치 공간 기록 |
| `telemetry_large_enemy_hold_resolved` | 아니오 | 겨울 껍질/무거운 순례자 지연 시간, 누수, 대응 태그 기록 |
| `telemetry_winter_gate_preview_phase_started` | 아니오 | 80일 겨울의 문 예고형 단계, 결빙 권역, 남은 설치 공간, 경고 표시 기록 |
| `telemetry_winter_gate_preview_frost_cycle_resolved` | 아니오 | 80일 결빙 사이클별 예고 이해, 이전 행동, 남은 설치 공간, 경로 차단 여부 기록 |
| `telemetry_winter_gate_preview_part_choice_resolved` | 아니오 | 80일 문경첩/서리 사슬 선택, 파괴 여부, 선택 이유, 다음 결빙 완화 여부 기록 |
| `telemetry_pressure_tile_decision_resolved` | 아니오 | 압력 예고 후 구조물 이전/포기/수리 유지와 남은 설치 공간 기록 |
| `telemetry_rear_killzone_shift_resolved` | 아니오 | 주 킬존이 어느 권역에서 어디로 옮겨졌는지와 안정화 여부 기록 |
| `telemetry_pressure_rotation_resolved` | 아니오 | 86~89일 압력 이동 순서, 다음 후보 예측, 보조 킬존 준비 여부 기록 |
| `telemetry_winter_gate_phase_started` | 아니오 | 90일 겨울의 문 단계, 압력 후보 권역, 남은 설치 공간, 경고 표시 기록 |
| `telemetry_winter_gate_pressure_cycle_resolved` | 아니오 | 90일 이동 압력 사이클별 예고 이해, 이전 행동, 권역 회복 여부, 경로 차단 여부 기록 |
| `telemetry_winter_gate_part_choice_resolved` | 아니오 | 90일 압력문틀/얼어붙은 문턱 선택, 파괴 여부, 선택 이유, 다음 압력 완화 여부 기록 |
| `telemetry_boss_encounter_budget_sampled` | 아니오 | 보스별 목표 시간, 경고선, 현재 단계별 소요 시간 기록 |
| `telemetry_boss_pattern_loop_capped` | 아니오 | 같은 의미의 보스 패턴 루프가 반복 상한에 걸려 전환됐는지 기록 |
| `telemetry_boss_encounter_budget_exceeded` | 아니오 | 목표 시간을 넘긴 원인과 조정 후보가 금지 태그를 건드리지 않았는지 기록 |
| `telemetry_first_boss_phase_started` | 아니오 | 첫 보스 흐름 중 어느 단계에 진입했는지와 표시 힌트 기록 |
| `telemetry_first_boss_role_check` | 아니오 | 첫 보스에서 직업별 기대 대응과 실제 대응 태그 기록 |
| `telemetry_first_boss_failure_cause_resolved` | 아니오 | 첫 보스 승패 후 주 원인, 보조 원인, 파괴 부위, 동반 웨이브 사용 기록 |
| `telemetry_combat_warning_raised` | 아니오 | 경고 ID, 강도, 출처, 방향, 제안 핑 후보 기록 |
| `telemetry_defeat_analysis_card_presented` | 예 | 패배 카드 유형, 원인 태그, 활성 방향, 제안 대응 태그 기록 |
| `telemetry_defeat_replay_opened` | 아니오 | 패배 카드에서 짧은 전장 스냅샷을 열었는지 기록 |
| `telemetry_next_run_suggestion_presented` | 예 | 제안 유형, 원인 태그, 자동 적용 금지 상태 기록 |
| `telemetry_next_run_suggestion_carried` | 아니오 | 제안이 새 런 준비 메모나 훈련장으로 이어졌는지 기록 |
| `telemetry_combat_report_created` | 아니오 | 웨이브 후 리포트와 패배 분석 카드의 원인 태그 기록 |
| `telemetry_heroic_proof_tag_generated` | 아니오 | 증거 태그, 플레이어, 직업, 활성 방향, 위치, 출처 카드/구조물, 영향값 기록 |
| `telemetry_structure_lifecycle_summary` | 아니오 | 구조물 목적, 위험 태그, 파괴/생존/재건 결과 기록 |
| `telemetry_structure_rebuilt` | 아니오 | 같은 타일 재건, 후방 재건, 재건 정책 적용 기록 |
| `telemetry_ping_suggestion_opened` | 아니오 | 자동 경고에서 어떤 핑 후보를 펼쳤는지 기록 |
| `telemetry_ping_created` | 아니오 | 핑 유형, 출처 표시, 대상, 연결된 경고 ID와 태그 기록 |
| `telemetry_ping_acknowledged` | 아니오 | 동의와 맡음 표시가 얼마나 빨리 붙는지 기록 |
| `telemetry_ping_resolved` | 아니오 | 핑이 행동으로 해소됐는지, 만료됐는지, 해소까지 걸린 시간 기록 |
| `telemetry_tutorial_step_started` | 아니오 | 튜토리얼 장면, 학습 태그, 시작 시점 기록 |
| `telemetry_tutorial_step_completed` | 아니오 | 단계 완료 시간, 재시도 횟수, 도달 힌트 단계 기록 |
| `telemetry_onboarding_hint_shown` | 아니오 | 첫 10일 힌트 노출 횟수와 이유 기록 |
| `telemetry_first_session_checkpoint` | 아니오 | 1~10일 학습 체크포인트와 관찰 행동 기록 |
| `telemetry_first_session_day_contract_resolved` | 아니오 | 일자별 학습 약속, 허용 실수, 복구 신호, 회수 문장 성공 여부 기록 |
| `telemetry_status_effect_applied` | 아니오 | 상태이상 최종 배율, 대상 등급, 변환 효과 기록 |
| `telemetry_status_effect_resisted` | 아니오 | 저항 프로필과 UI 피드백 태그가 제대로 쓰였는지 기록 |
| `telemetry_structure_built` | 예 | 설치 위치와 라인별 미로 밀도 기록 |
| `telemetry_structure_destroyed` | 예 | 파괴 원인, 파괴 위치, 적 발묶기 시간 기록 |
| `telemetry_enemy_kill_summary` | 예 | 처치 기반 마나/드로우 펌핑량 기록 |
| `telemetry_run_failed` | 예 | 붕괴 방향, 실패 일자, 실패 직전 손패 상태 기록 |
| `telemetry_boss_part_destroyed` | 아니오 | 부위 파괴 타이밍과 보스 압박 완화량 기록 |
| `telemetry_rarity_exposure_band_applied` | 아니오 | 희귀도 노출 밴드, 연결 희귀도 프로필, 런타임 보정 금지 여부 기록 |
| `telemetry_card_pool_stage_applied` | 아니오 | 적용된 카드 풀 단계, 열린 라인, 미룬 라인, 차단 카드 종류 기록 |
| `telemetry_rarity_roll_resolved` | 아니오 | 추첨 희귀도, 최종 희귀도, 하향 이유, 후보 위치 기록 |
| `telemetry_card_reward_candidate_generated` | 아니오 | 보상 레일, 후보 카드, 대체 단계, 중복 축 검사, 골드 거절 이유 기록 |
| `telemetry_card_reward_duplicate_axis_rerolled` | 아니오 | 같은 축 후보 3장 반복으로 다시 뽑은 후보와 최종 후보 기록 |
| `telemetry_card_reward_fatigue_guard_applied` | 아니오 | 최근 보상 팩 검사 범위, 억제 수, 반복 허용 수, 후보 수/희귀도/골드 고정 여부 기록 |
| `telemetry_card_reward_candidate_suppressed_for_fatigue` | 아니오 | 반복 피로도로 밀린 원래 후보, 최종 후보, 피로 사유 태그 기록 |
| `telemetry_card_reward_repeat_allowed` | 아니오 | 반복 후보를 예외 허용한 카드, 후보 위치, 허용 사유 태그 기록 |
| `telemetry_card_reward_presented` | 아니오 | 보상 프로필, 전리품 풀, 후보 희귀도, 후보 역할 태그, 후보 아키타입, 제외 태그 기록 |
| `telemetry_card_reward_resolved` | 아니오 | 카드 선택, 거절, 후보 희귀도, 선택 소요 시간 기록 |
| `telemetry_card_effect_resolved` | 아니오 | 카드 스펙 프로필, 대상 유효성, 실제 효과값, 지속 시간, 보스 정책 적용 기록 |
| `telemetry_card_stat_budget_lock_checked` | 아니오 | 카드 스펙, 효과 예산 ID, 수치 잠금 ID, 통과 여부, 적용된 대가/정책 기록 |
| `telemetry_card_stat_budget_violation_detected` | 아니오 | 예산 위반 축, 빠진 대가 태그, 빠진 정책 ID, 빌드 차단 여부 기록 |
| `telemetry_card_archetype_signal_presented` | 아니오 | 보상 후보가 어떤 아키타입 신호로 읽혔는지 기록 |
| `telemetry_card_archetype_commit_resolved` | 아니오 | 확정 카드 선택/거절, 지원 카드 수, 선택 이유 기록 |
| `telemetry_heroic_equivalent_support_checked` | 아니오 | 실제 지원 카드 수, 동등 지원 태그, 적용 크레딧, 차단 상태, 런 중 선택 지원 충족 여부 기록 |
| `telemetry_heroic_gate_ui_presented` | 아니오 | 표시 표면, 영웅 후보 상태, 상점 조율 상태, 표시 상세 행 수, 잠금 이유, 금지 시각/문구 태그 감지 기록 |
| `telemetry_mvp_heroic_gate_checked` | 아니오 | 20~30일 영웅 후보의 지원 크레딧, 실제 카드 보유, 런 중 선택 지원, 최근 전투 증거, 하향 이유 기록 |
| `telemetry_mvp_heroic_card_spec_lock_checked` | 아니오 | 영웅 카드 효과 잠금, 스펙 프로필, 예산, 보스 정책, 상한 통과 여부 기록 |
| `telemetry_card_loot_choice_resolved` | 아니오 | 선택한 카드 희귀도, 선택 이유, 영웅 자동 선택 경고, 저주 동의 여부 기록 |
| `telemetry_card_variant_candidate_presented` | 아니오 | 변형 후보, 표시 프로필, UI 표면, 기준 카드, 등장 경로, 아티팩트 해금 여부, 후보 수 고정 여부 기록 |
| `telemetry_card_variant_chosen` | 아니오 | 선택한 변형 카드, 표시 프로필, 기준 카드, 선택 이유, 새 카드로 이해했는지 기록 |
| `telemetry_card_variant_upgrade_confusion_reported` | 아니오 | 변형 카드를 강화로 오해한 UI 표면과 원인 기록 |
| `telemetry_card_upgrade_presented` | 아니오 | 강화 후보, 대상 카드, 추천 태그, 현재 아키타입 카운트 기록 |
| `telemetry_card_upgrade_resolved` | 아니오 | 선택/거절한 강화, 지불 가격, 강화 유형, 선택 이유 기록 |
| `telemetry_early_deck_choice_resolved` | 아니오 | 1~10일 카드 선택이 직업 루프, 약점 보완, 골드 거절 중 어디에 속했는지 기록 |
| `telemetry_deck_growth_summary` | 아니오 | 10일 단위 덱 크기, 제거 수, 강화 수, 방치 카드 수 기록 |
| `telemetry_artifact_choice_presented` | 아니오 | 후보 풀, 운영 축 다양성, 장착 슬롯 상태 기록 |
| `telemetry_artifact_choice_resolved` | 아니오 | 후보 풀, 선택/교체 결과, 투표 시간, 교체 대상 기록 |
| `telemetry_artifact_replacement_resolved` | 아니오 | 현재 유지, 교체 대상, 교체 이유 태그 기록 |
| `telemetry_artifact_loadout_changed` | 아니오 | 장착/휴면/방출 상태와 현재 슬롯 한도 기록 |
| `telemetry_artifact_dormant_reactivated` | 아니오 | 휴면 아티팩트 재장착 비용, 교체 대상, 투표 시간 기록 |
| `telemetry_artifact_side_effect_triggered` | 아니오 | 아티팩트 부작용 발동 시점과 적용값 기록 |
| `telemetry_class_role_summary` | 아니오 | 직업별 구조물 설치, 카드 사용, 역할 수행 비율 기록 |
| `telemetry_synergy_triggered` | 아니오 | 도발 군집, 계획 붕괴, 보스 부위 집중 등 시너지 발생 기록 |
| `telemetry_enemy_role_pressure_summary` | 아니오 | 적 역할별 등장 횟수, 실패 방향, 대응 직업 분포 기록 |
| `telemetry_enemy_counter_used` | 아니오 | 특정 적 역할에 사용된 도발, 수리, 제어, 경로 변경, 집중 화력 기록 |
| `telemetry_party_role_gap` | 아니오 | 파티에 부족한 역할과 공용 카드/아티팩트 보완 기록 |
| `telemetry_shop_session_started` | 아니오 | 상점 세션 ID, 표시 항목, 파티 구매 한도 기록 |
| `telemetry_shop_purchase` | 아니오 | 구매 항목, 최종 가격, 보스 파편 사용, 투표 여부 기록 |
| `telemetry_shop_heroic_tune_offer_resolved` | 아니오 | 게이트 ID, 대상 플레이어, 대상 수락, 파티 투표 결과, 구매/보류 이유 기록 |
| `telemetry_shop_session_completed` | 아니오 | 상점 체류 시간, 확인한 항목 수, 시작된 투표 수 기록 |
| `telemetry_shop_recommendation_shown` | 아니오 | 피해 진단 태그, 다음 압박 태그, 추천 항목과 대안 확인 기록 |
| `telemetry_shop_consumable_used` | 아니오 | 소모품 사용 창, 대상, 방향, 실제 방지 피해/효과 기록 |
| `telemetry_event_choice_presented` | 아니오 | 등장 이유, 선택지 수, 시간 초과 기본 선택 기록 |
| `telemetry_event_choice_resolved` | 아니오 | 선택 소유권, 투표 여부, 결과 태그와 다음 압박 연결 기록 |
| `telemetry_event_contract_lock_resolved` | 아니오 | 이벤트 잠금 ID, 표시 이벤트, 시간 초과, 안전 선택 적용 여부 기록 |
| `telemetry_curse_contract_presented` | 아니오 | 저주 계약 카드, 즉시 이득, 장기 대가, 제안 대상 기록 |
| `telemetry_curse_contract_confirmed` | 아니오 | 저주 수령 플레이어, 확인 시간, 선택 이벤트 기록 |
| `telemetry_curse_contract_declined` | 아니오 | 거절 이유와 안전 선택 적용 여부 기록 |
| `telemetry_curse_discount_reserved` | 아니오 | 25일 조용한 계약서 할인 예약, 대상 저주, 만료 상점 기록 |
| `telemetry_curse_service_presented` | 아니오 | 저주 서비스 제안, 소유자, 가격, 할인, 가능 행동 기록 |
| `telemetry_curse_service_resolved` | 아니오 | 안정화/제거/보류 결과, 투표, 구매 한도 소모 여부 기록 |
| `telemetry_curse_stabilized` | 아니오 | 안정화 옵션, 남는 대가, 재안정화 잠금 기록 |
| `telemetry_curse_removed` | 아니오 | 제거 가격, 할인, 파티 제거 할증 증가 기록 |
| `telemetry_curse_service_deferred` | 아니오 | 보류, 시간 초과, 거절, 투표 실패 이유 기록 |
| `telemetry_playtest_dashboard_run_aggregated` | 아니오 | 런 단위 대시보드 패널, 파생 지표, 위험 신호 집계 기록 |
| `telemetry_playtest_dashboard_panel_flagged` | 아니오 | 특정 패널에서 발견된 위험 신호와 검토 태그 기록 |
| `telemetry_playtest_observer_note_attached` | 아니오 | 관찰자 메모를 패널과 원본 이벤트에 연결 |
| `telemetry_playtest_dashboard_action_queued` | 아니오 | 위험 신호를 다음 테스트 가설과 검토 작업으로 저장 |
| `telemetry_final_phase_started` | 아니오 | 최종 10일의 흐름 진입, 일자 범위, 핵심 압박 태그 기록 |
| `telemetry_final_loadout_audit_presented` | 아니오 | 91일 최종 점검에서 아티팩트, 방치 카드, 약점 태그가 표시됐는지 기록 |
| `telemetry_final_artifact_commitment_resolved` | 아니오 | 95일 아티팩트 교체/유지 판단, 행동 횟수, 이유 태그 기록 |
| `telemetry_final_market_lock_applied` | 아니오 | 95일 종료 후 유지 축, 포기한 약점, 큰 구매 횟수 잠금 기록 |
| `telemetry_final_rehearsal_phase_resolved` | 아니오 | 91~100일 각 단계의 해결 질문, 실패 질문, 새 시스템 금지 통과 여부 기록 |
| `telemetry_final_weakness_commitment_resolved` | 아니오 | 95일에 살린 축과 포기한 약점, 새 아키타입 차단 여부 기록 |
| `telemetry_winter_gate_final_phase_started` | 아니오 | 100일 겨울의 문 완전체 단계 시작, 압력 계획, 활성 방향, 금지 압력 태그 기록 |
| `telemetry_final_market_resolved` | 아니오 | 95일 마지막 상점의 선택 축과 포기한 약점 기록 |
| `telemetry_final_boss_phase_completed` | 아니오 | 최종 보스 단계별 압력 권역, 방어선 이전, 부위 파괴 기록 |
| `telemetry_final_boss_part_choice_resolved` | 아니오 | 최종 보스 부위 후보, 집중 대상, 파괴 결과, 보상 보정 차단 여부 기록 |
| `telemetry_final_boss_companion_branch_selected` | 아니오 | 95일 포기 약점 태그와 100일 4단계 동반 분기 선택 결과 기록 |
| `telemetry_final_result_reflection_started` | 아니오 | 최종 결과 회고 시작, 승패, 종료 일자, 플레이 시간, 활성 방향 기록 |
| `telemetry_final_result_panel_viewed` | 아니오 | 결과 회고 패널별 체류, 건너뛰기, 결과 상태 기록 |
| `telemetry_decisive_moment_card_presented` | 아니오 | 결과 화면의 결정적 장면 카드 유형, 일자, 방향, 위험 태그 기록 |
| `telemetry_final_result_suggestion_presented` | 아니오 | 결과 회고에서 표시한 다음 런 제안 유형과 자동 적용 금지 상태 기록 |
| `telemetry_party_chronicle_title_selected` | 아니오 | 연대기 제목 후보 선택, 직접 수정, 금지 문구 차단 기록 |
| `telemetry_party_chronicle_memory_tags_generated` | 아니오 | 연대기 기억 태그 후보, 선택 태그, 차단 태그, 묶음 분포 기록 |
| `telemetry_party_chronicle_saved` | 아니오 | 파티 조합, 아티팩트, 기억 태그, 다음 런 메모 저장 기록 |
| `telemetry_party_chronicle_viewed` | 아니오 | 기록장 또는 결과 화면에서 연대기 상세 열람 기록 |
| `telemetry_party_chronicle_filtered` | 아니오 | 기록장 정렬/필터 사용과 금지 비교 필터 부재 확인 |
| `telemetry_post_run_learning_packet_created` | 아니오 | 결과 회고에서 생성한 학습 패킷, 원천, 연결 해금 규칙 기록 |
| `telemetry_post_run_meta_progression_started` | 아니오 | 결과 회고 후 메타 진행 시작, 학습 태그, 도달 구간 기록 |
| `telemetry_post_run_meta_panel_viewed` | 아니오 | 메타 패널 체류, 건너뛰기, 크게 표시한 해금 카드 기록 |
| `telemetry_meta_unlock_resolved` | 아니오 | 해금 유형, 해금 이유, 파워 영향 여부 기록 |
| `telemetry_encyclopedia_entry_unlocked` | 아니오 | 적/보스 도감 항목과 공개된 정보 태그 기록 |
| `telemetry_training_scenario_unlocked` | 아니오 | 실패 태그와 연결된 훈련 장면 해금 기록 |
| `telemetry_next_run_prep_loaded` | 아니오 | 다음 런 제안, 관련 해금, 강제 직업/카드 여부 기록 |
| `telemetry_knowledge_revisit_offer_presented` | 아니오 | 재방문 제안 이유, 원천, 즉시 노출 여부, 훈련 연결 기록 |
| `telemetry_knowledge_revisit_started` | 아니오 | 도감/훈련장 재방문 시작 이유, 출처, 추천 항목 기록 |
| `telemetry_encyclopedia_entry_viewed` | 아니오 | 도감 항목 조회 시간, 항목 유형, 진입 출처 기록 |
| `telemetry_training_scenario_started` | 아니오 | 훈련 장면 시작, 연결 도감, 목표 학습 태그, 보상 비활성 여부 기록 |
| `telemetry_training_scenario_completed` | 아니오 | 훈련 시도 수, 사용 대응 태그, 제안 대응 태그 기록 |
| `telemetry_knowledge_revisit_to_run_linked` | 아니오 | 재방문 후 다음 런 제안 연결과 강제 빌드 적용 여부 기록 |
| `telemetry_new_run_setup_started` | 예 | 새 런 준비 출처, 다음 런 제안, 미리보기 인원수와 방향 기록 |
| `telemetry_setup_suggestion_slot_changed` | 아니오 | 참고 메모 고정/접기/삭제와 자동 적용 금지 여부 기록 |
| `telemetry_lobby_active_direction_previewed` | 예 | 로비 인원수별 활성 방향 미리보기와 비활성 방향 흐림 표시 기록 |
| `telemetry_lobby_run_mode_selected` | 예 | 런 길이 선택, 예상 시간 범위, 보상 모드 비노출 여부 기록 |
| `telemetry_class_selection_resolved` | 예 | 플레이어별 직업 선택, 역할 태그, 추천/강제 여부 기록 |
| `telemetry_lobby_role_gap_hint_viewed` | 아니오 | 역할 빈틈 힌트 조회와 필수 직업 표시 금지 여부 기록 |
| `telemetry_party_intent_confirmed` | 아니오 | 이번 런에서 시험할 운영 문장과 준비 완료 플레이어 기록 |
| `telemetry_run_state_locked` | 예 | 시작 시 확정된 `playerCountAtStart`, `activeDirections`, `scalingProfileId`, 시드 기록 |
| `telemetry_session_savepoint_created` | 예 | 안정 저장점 생성 시점, 일자, 페이즈 기록 |
| `telemetry_session_interrupt_detected` | 예 | 연결 끊김, 입력 없음, 호스트 지연의 발생 위치 기록 |
| `telemetry_player_role_reserved` | 예 | 보류된 직업, 개인 카드 잠금, AI 카드 사용 금지 여부 기록 |
| `telemetry_resume_snapshot_delivered` | 예 | 복귀 스냅샷과 진행 중 투표/방향 고정 상태 기록 |
| `telemetry_long_absence_resolved` | 예 | 2분 초과 이탈의 처리 방식과 저장점 기록 |
| `telemetry_session_resume_confirmed` | 예 | 같은 RunState와 같은 직업으로 복귀했는지 기록 |
| `telemetry_accessibility_readability_checked` | 예 | UI 배율, 카드 텍스트 크기, 줄바꿈 미리보기 선택 기록 |
| `telemetry_presentation_motion_adjusted` | 예 | 화면 흔들림과 카메라 관성 조절값 기록 |
| `telemetry_presentation_audio_adjusted` | 예 | 저주파 보스음, 경고음, 핑 소리 조절값 기록 |
| `telemetry_tactical_visibility_assist_enabled` | 예 | 경로 상시 표시, 적 윤곽선, 보스 부위 강조 사용 여부 기록 |
| `telemetry_coop_signal_assist_enabled` | 예 | 핑 아이콘, 방향 라벨, 색각 보조, 자막 로그 사용 여부 기록 |
| `telemetry_presentation_safety_guardrail_passed` | 예 | 정보 은폐, 점프 스케어, UI 왜곡 금지선 통과 여부 기록 |
| `telemetry_chapter_pacing_summary` | 아니오 | 10일 챕터별 소요 시간, 겹치기 횟수, 기지 피해 기록 |
| `telemetry_fatigue_check_recorded` | 아니오 | 30/60/90/100일 또는 상점 직후 주관 피로도 기록 |
| `telemetry_idle_time_summary` | 아니오 | 보상 정산, 상점, 웨이브 대기에서 발생한 비전투 시간 기록 |
| `telemetry_run_pacing_summary` | 아니오 | 풀런 총 시간, 가장 긴 챕터, 가장 긴 상점, 최종 피로도 기록 |

## 플레이테스트 대시보드 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `playtest_dashboard_layout_mvp` | 화면 레이아웃 | 예 | 상단 런 스트립, 패널 카드 그리드, 위험 신호 드릴다운, 다음 빌드 액션 큐 구성 |
| `dashboard_top_run_strip` | 대시보드 영역 | 예 | 빌드, 런 모드, 인원수, 활성 방향, 도달 일자, 총 시간, 기지 피해 표시 |
| `dashboard_panel_card_grid` | 대시보드 영역 | 예 | 8개 MVP 패널 상태와 핵심 수치 1~3개 표시 |
| `dashboard_red_flag_drilldown` | 대시보드 영역 | 예 | 위험 신호 조건, 원본 이벤트, 관찰자 메모, 가능한 의미 표시 |
| `dashboard_next_build_action_queue` | 대시보드 영역 | 예 | 위험 신호를 다음 테스트 가설과 검토 작업으로 저장 |
| `dashboard_same_condition_compare` | 비교 기능 | 아니오 | 같은 `runMode`, `playerCountAtStart`, `activeDirections` 런만 비교 |
| `dashboard_observer_note_linker` | 메모 연결 | 아니오 | 관찰자 메모를 패널과 원본 이벤트에 연결 |
| `dashboard_redflag_rule_set_mvp` | 규칙 데이터 | 예 | MVP 위험 신호 규칙과 금지 조정 태그 정의 |
| `dashboard_action_queue_status` | 상태 데이터 | 예 | 제안, 다음 빌드 반영, 보류, 해결 상태 관리 |

## 최종 10일 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `final_phase_flow` | 흐름 | 아니오 | 91~100일을 점검, 약점 확인, 마지막 상점, 이전, 리허설, 최종 보스로 구성 |
| `final_rehearsal_flow_091_100` | 흐름 | 아니오 | 최종 10일 전체를 리허설 데이터로 묶음 |
| `final_phase_001_last_line_check` | 단계 | 아니오 | 91일 남은 구조물, 손패, 아티팩트, 후방 킬존 후보 확인 |
| `final_phase_002_weakness_recheck` | 단계 | 아니오 | 92~94일 빠른 적, 자원 방해, 구조물 파괴 약점 재확인 |
| `final_phase_003_last_market` | 단계 | 아니오 | 95일 마지막 상점과 포기한 약점 기록 |
| `final_phase_004_final_relocation` | 단계 | 아니오 | 96~97일 장기 압력 예고와 최종 방어선 이전 |
| `final_phase_005_last_stack_rehearsal` | 단계 | 아니오 | 98~99일 보상 없는 겹치기 판단과 새 요소 없는 리허설 |
| `final_phase_006_winter_gate_final` | 단계 | 아니오 | 100일 겨울의 문 완전체와 최종 방어선 유지 |
| `final_market_day_095_rule` | 상점 규칙 | 아니오 | 마지막 상점에서 큰 파티 구매 최대 2회와 포기한 약점 기록 |
| `final_loadout_closure_091_100` | 장비 마감 규칙 | 아니오 | 91일 점검, 95일 최종 상점, 96일 이후 장비 잠금 |
| `artifact_pool_final_closure_095` | 아티팩트 후보 풀 | 아니오 | 새 빌드 시작 없이 기존 운영 마감형 후보만 제공 |
| `shop_session_day_095_final_market` | 상점 세션 | 아니오 | 현재 유지, 약점 보완, 덱 정리, 아티팩트 1회 행동, 포기 약점 기록 |
| `shop_final_market_note` | 무료 정보 항목 | 아니오 | 95일 선택이 96~100일에 어떻게 회수되는지 요약 |
| `ui_final_loadout_audit` | 최종 점검 UI | 아니오 | 91일 장착 아티팩트, 방치 카드, 약점 태그, 후방 킬존 후보 표시 |
| `ui_final_lock_summary` | 잠금 UI | 아니오 | 95일 종료 후 유지 축과 포기한 약점 1~2개 표시 |
| `final_weakness_commitment_check` | 검증 | 아니오 | 95일 구매 후에도 남는 약점이 기록되는지 확인 |
| `final_boss_phase_flow` | 보스 흐름 | 아니오 | 겨울의 문 완전체를 입장, 전방 압력, 부위 집중, 동반 웨이브, 마지막 이전, 최후 압박으로 운영 |
| `final_result_summary` | 결과 화면 | 아니오 | 마지막 킬존, 핵심 구조물, 최종 카드/아티팩트 역할 요약 |
| `final_result_reflection_flow` | 결과 흐름 | 아니오 | 결과 확정, 마지막 방어선, 선택 회수, 결정적 장면, 다음 런 제안, 파티 기록 저장 |
| `result_panel_outcome_lock` | 결과 패널 | 아니오 | 승리/패배/도달 일자/플레이 시간 확정 |
| `result_panel_last_bastion_summary` | 결과 패널 | 아니오 | 마지막 킬존, 방어선 이전 횟수, 오래 버틴 구조물 표시 |
| `result_panel_commitment_recall` | 결과 패널 | 아니오 | 95일 포기한 약점과 마지막 상점 선택 회수 |
| `result_panel_decisive_moments` | 결과 패널 | 아니오 | 결정적 장면 카드 최대 3장 표시 |
| `result_panel_next_run_suggestion` | 결과 패널 | 아니오 | 다음 런에서 바꿔볼 운영 1~2개 제안 |
| `result_panel_party_chronicle_save` | 결과 패널 | 아니오 | 파티 조합, 아티팩트, 마지막 방어선 태그 저장 |
| `ui_final_bastion_map` | 결과 UI | 아니오 | 마지막 방어선과 압력 권역을 미니맵으로 표시 |
| `ui_decisive_moment_cards` | 결과 UI | 아니오 | 개인 책임 없는 전장 사건 카드 표시 |
| `ui_next_run_suggestions` | 결과 UI | 아니오 | 정답 빌드가 아닌 운영 변화 제안 표시 |
| `party_chronicle_card` | 기록 | 아니오 | 파티의 최종 조합과 회고 태그 저장 |
| `party_chronicle_entry` | 기록 데이터 | 아니오 | 결과 회고를 파티 단위 기억 카드로 저장 |
| `party_chronicle_title_options` | 제목 후보 | 아니오 | 결정적 장면과 기억 태그 기반 자동 제목 최대 3개 |
| `party_chronicle_book_view` | 기록장 UI | 아니오 | 저장한 연대기 카드 목록, 펼침, 즐겨찾기, 허용 필터 제공 |
| `party_chronicle_filter_preset` | 기록장 필터 | 아니오 | 결과, 도달 구간, 인원수, 직업 조합, 보스, 기억 태그 필터 |
| `moment_last_relocation` | 결정적 장면 | 아니오 | 최종 보스 중 방어선 이전이 버틴 시간에 영향을 준 장면 |
| `moment_base_crisis` | 결정적 장면 | 아니오 | 기지 치명 체력 진입과 회복/저지/후퇴 판단 장면 |
| `moment_abandoned_weakness_branch` | 결정적 장면 | 아니오 | 95일에 남긴 약점이 100일 전장에 드러난 장면 |
| `moment_boss_part_choice` | 결정적 장면 | 아니오 | 보스 부위 우선순위가 패턴 약화나 잔여 위험에 영향을 준 장면 |
| `moment_held_structure` | 결정적 장면 | 아니오 | 핵심 구조물이 오라, 수리, 도발, 재건으로 오래 버틴 장면 |
| `moment_wave_stack_tempo` | 결정적 장면 | 아니오 | 웨이브 겹치기 후 압박이 변한 템포 판단 장면 |
| `moment_final_breach` | 결정적 장면 | 아니오 | 패배 시 마지막 누수의 반복 원인을 보여주는 장면 |
| `final_suggest_rear_killzone` | 다음 런 제안 | 아니오 | 후방 킬존 이전 후보를 먼저 잡아보는 운영 메모 |
| `final_suggest_save_or_break` | 다음 런 제안 | 아니오 | 살릴 구조물과 터뜨릴 구조물을 나누는 운영 메모 |
| `final_suggest_hand_unjam` | 다음 런 제안 | 아니오 | 치명 구간 전 버리기와 저코스트 카드 정리를 권하는 운영 메모 |
| `final_suggest_shop_commitment` | 다음 런 제안 | 아니오 | 마지막 상점에서 살린 축과 남긴 위험을 합의하는 운영 메모 |
| `final_suggest_boss_part_focus` | 다음 런 제안 | 아니오 | 보스 부위 1개를 먼저 정하고 잔여 위험을 받아들이는 운영 메모 |
| `final_suggest_stack_hold` | 다음 런 제안 | 아니오 | 치명 체력이나 이전 직전에는 웨이브 호출을 보류하는 운영 메모 |
| `final_no_new_system_rule` | 금지선 | 아니오 | 99~100일에 새 적/새 규칙/새 아키타입 시작 금지 |

### 100일 결과 회고 세부 제작표

결과 회고 콘텐츠는 큰 문장보다 짧은 근거를 잘 고르는 것이 중요합니다.

한 패널에 여러 판단을 섞지 않습니다.

| 제작물 | 수량 | 문구 기준 | 연결 데이터 |
| --- | ---: | --- | --- |
| 결과 확정 문구 | 결과별 2~3개 | 승리는 버틴 선택, 패배는 전장 원인, 중단은 검증한 지점 | `outcome`, `finalDay`, `activeDirections` |
| 마지막 방어선 지도 라벨 | 방향별 1세트 | 활성 방향만 라벨링하고 비활성 방향은 위험으로 표시하지 않음 | `finalKillzonePlanId`, `activeDirections` |
| 95일 선택 회수 문구 | 태그 조합별 1개 | 고친 축과 남긴 위험을 함께 말함 | `chosenFocusTags`, `abandonedWeaknessTags` |
| 결정적 장면 카드 | 유형별 3~5개 | 전장 사건, 구조물, 방향, 보스 단계 중심 | `DecisiveMomentCardProfile` |
| 다음 런 제안 문구 | 유형별 2~3개 | 대응 태그와 운영 습관으로 말함 | `FinalResultSuggestionRule` |
| 파티 연대기 문장 | 결과별 3~5개 | 점수보다 파티 조합, 아티팩트, 마지막 방어선 태그를 기억 | `partyChronicleId` |

파티 연대기 제작 기준:

| 제작물 | 수량 | 제작 기준 | 금지선 |
| --- | ---: | --- | --- |
| 연대기 제목 후보 | 장면 유형별 2~3개 | 결정적 장면, 마지막 방어선, 95일 선택을 한 문장으로 압축 | 캐리, 점수, 등급, 개인 비난 |
| 기억 태그 사전 | 40~60개 | 전장 사건, 운영, 보스 부위, 아티팩트 역할, 포기한 약점 중심 | 개인 성과 태그 |
| 카드 앞면 문구 | 결과별 3~5개 | 제목, 결과 줄, 파티 줄, 전장 줄이 5초 안에 읽힘 | 리더보드 문구 |
| 기록장 빈 상태 | 출처별 2~3개 | 아직 저장한 기록이 없을 때 부드럽게 안내 | 저장하지 않으면 손해라는 표현 |
| 필터 라벨 | 허용 필터별 1개 | 다시 보고 싶은 운영을 찾는 문구 | 승률/최고 점수/효율 필터 |

기억 태그 사전 묶음:

| 묶음 | 기본 수량 | 확장 상한 | 제작 기준 | 금지선 |
| --- | ---: | ---: | --- | --- |
| `lane_path` | 6 | 8 | 첫 굴곡, 후방 킬존, 마지막 이전처럼 방향에 투영 가능한 전선 판단 | 북/서/남 같은 비활성 방향 고정 태그 |
| `structure_maze` | 8 | 10 | 도발, 바리케이드, 잔해, 수리, 오라처럼 구조물 운영을 기억 | 파괴 구조물 실패 목록 |
| `resource_hand` | 6 | 8 | 시드 마나, 버리기, 드로우, 저비용 연쇄, 압축 선택 | 개인 손패 실수 |
| `enemy_response` | 6 | 8 | 돌파형, 파괴형, 방해형, 대형 적, 정예, 군집 대응 | 처치 수, 딜량 |
| `tempo_stack` | 5 | 6 | 겹치기 호출, 보류, 수습, 기다림 단축 | 보상 효율, 희귀도, 후보 수 |
| `boss_weakness` | 7 | 9 | 보스 부위, 동반 분기, 95일 남긴 위험, 마지막 상점 합의 | 부위 파괴 보상 |
| `artifact_role` | 6 | 8 | 아티팩트와 직업 역할이 만든 파티 운영 축 | 아티팩트 점수, 희귀도 점수 |
| `ending_memory` | 4 | 5 | 결말의 톤과 마지막 보루 기억 | 클리어 등급, 리더보드 |

기억 태그 라벨 작성 규칙:

- 라벨은 2~10자 정도의 짧은 명사구로 씁니다.
- 라벨에는 플레이어 이름, 개인 성과, 방향별 실패 낙인을 넣지 않습니다.
- `tempo_stack` 라벨은 보상 기대가 아니라 시간, 보류, 수습을 떠올리게 해야 합니다.
- `ending_memory` 라벨은 승리/패배를 평가하지 않고 기억의 톤만 정합니다.
- 같은 결과 카드에는 같은 묶음 태그가 3개 이상 보이면 안 됩니다.

연대기 제목 후보 기본 세트:

| ID | 연결 장면 | 문구 방향 |
| --- | --- | --- |
| `chronicle_title_last_relocation` | `moment_last_relocation` | 마지막 방어선 이전으로 버틴 파티 |
| `chronicle_title_held_structure` | `moment_held_structure` | 핵심 구조물을 끝까지 지킨 파티 |
| `chronicle_title_abandoned_weakness` | `moment_abandoned_weakness_branch` | 남겨둔 위험을 안고 버틴 파티 |
| `chronicle_title_boss_part_focus` | `moment_boss_part_choice` | 보스 부위를 먼저 본 파티 |
| `chronicle_title_final_breach` | `moment_final_breach` | 다음에 다시 막아볼 전선을 남긴 파티 |
| `chronicle_title_quiet_record` | 결과 공통 | 조용히 기록된 파티 |

기록장 허용 필터:

| 필터 ID | 용도 |
| --- | --- |
| `chronicle_filter_recent` | 최신 기록 보기 |
| `chronicle_filter_favorite` | 즐겨찾기 기록 보기 |
| `chronicle_filter_outcome` | 승리/패배/중단별 보기 |
| `chronicle_filter_day_band` | 도달 구간별 보기 |
| `chronicle_filter_player_count` | 시작 인원수별 보기 |
| `chronicle_filter_class_combo` | 직업 조합별 보기 |
| `chronicle_filter_boss_seen` | 본 보스별 보기 |
| `chronicle_filter_memory_tag` | 운영/전장 기억 태그별 보기 |

기록장에는 승률, 최고 점수, 평균 점수, 개인 기여도, 딜량, 처치 수, 웨이브 겹치기 효율 필터를 만들지 않습니다.

결정적 장면 카드 제작 기준:

| 유형 | 첫 줄 | 둘째 줄 | 버튼 |
| --- | --- | --- | --- |
| `moment_last_relocation` | 어느 권역으로 옮겼는지 | 그 이전이 몇 초를 벌었는지 | 짧은 스냅샷 |
| `moment_base_crisis` | 기지가 치명 구간에 들어간 시점 | 열린 대응 태그와 실제 대응 | 스냅샷 보기 |
| `moment_abandoned_weakness_branch` | 남긴 약점이 드러난 방향 | 그 약점을 어떻게 받아냈는지 | 95일 선택 보기 |
| `moment_boss_part_choice` | 먼저 본 보스 부위 | 약해진 패턴과 남은 위험 | 보스 도감 |
| `moment_held_structure` | 오래 버틴 구조물 | 연결된 오라/수리/도발/재건 태그 | 구조물 기록 |
| `moment_wave_stack_tempo` | 호출한 시점 | 이후 압박 변화와 보류 가능 태그 | 겹치기 도감 |
| `moment_final_breach` | 반복 누수가 생긴 활성 방향 | 다음에 시험할 대응 태그 | 다음 런 메모 |

다음 런 제안은 최대 2개만 표시합니다.

두 제안이 같은 `suggestionType`이면 더 설명력이 높은 하나만 남깁니다.

솔로 결과 회고에서는 동쪽 외 방향을 결정적 장면이나 다음 런 제안의 실제 방어 대상으로 만들지 않습니다.

## 런 이후 메타 진행 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `post_run_meta_flow` | 흐름 | 아니오 | 런 기록 수집, 학습 태그, 정보/훈련 해금, 선택지 해금, 다음 런 준비, 프로필 저장 |
| `post_run_learning_packet` | 연결 데이터 | 아니오 | 결과 회고, 패배 카드, 발견 기록을 메타 해금과 재방문 제안으로 연결 |
| `meta_unlock_rule_set` | 해금 규칙 | 아니오 | 도감, 훈련, 카드 풀, 아티팩트 풀, 외형 해금을 역할 태그 기준으로 처리 |
| `meta_panel_run_record_collect` | 메타 패널 | 아니오 | 도달 일자, 만난 적, 보스 부위, 마지막 방어선 태그 수집 |
| `meta_panel_learning_tag_summary` | 메타 패널 | 아니오 | 반복 실패 원인, 포기한 약점, 자주 쓴 대응 태그 정리 |
| `meta_panel_info_training_unlock` | 메타 패널 | 아니오 | 적 도감, 보스 기록, 훈련 장면 해금 |
| `meta_panel_choice_pool_unlock` | 메타 패널 | 아니오 | 새 카드/아티팩트/외형 후보 해금 |
| `meta_panel_next_run_prep` | 메타 패널 | 아니오 | 다음 런에서 시도할 운영 1~2개 연결 |
| `meta_panel_profile_save` | 메타 패널 | 아니오 | 프로필 해금 상태와 파티 연대기 저장 |
| `meta_ui_three_column_summary` | 메타 UI | 아니오 | 이번 런 기록, 새로 열린 것, 다음 판 메모 3단 구성 |
| `meta_recent_revisit_queue` | 저장 | 아니오 | 즉시 보여주지 않은 재방문 제안을 최대 3개 저장 |
| `profile_state_unlock_store` | 저장 | 아니오 | 카드 풀, 아티팩트 풀, 도감, 훈련, 외형 해금 저장 |
| `encyclopedia_entry_enemy_role` | 도감 | 아니오 | 적 역할, 저항, 대응 태그 정보 제공 |
| `encyclopedia_entry_boss_pattern` | 도감 | 아니오 | 보스 부위와 패턴 기록 제공 |
| `training_scenario_from_failure_tag` | 훈련 | 아니오 | 패배/회고 태그와 연결된 짧은 재방문 장면 |
| `cosmetic_unlock_non_power` | 외형 | 아니오 | 기지, 카드, 타워 외형처럼 밸런스에 영향 없는 보상 |

### 메타-재방문 연결 제작표

결과 직후 메타 화면은 많은 보상을 한꺼번에 보여주는 화면이 아니라, 다음 런으로 가져갈 기억을 정리하는 짧은 브릿지입니다.

| 제작물 | 수량 | 제작 기준 | 금지선 |
| --- | ---: | --- | --- |
| `PostRunLearningPacket` 기본 규칙 | 원천별 1개 이상 | 결과 장면, 패배 원인, 발견, 포기 약점, 강점 태그 연결 | 보상 계산, 난이도 보정 |
| `MetaUnlockRule` | 해금 유형별 1개 이상 | 도감/훈련/선택지/외형을 역할 태그와 도달 구간으로 연결 | 영구 스탯 증가 |
| 메타 화면 카드 문구 | 영역별 3~5개 | 기록, 새 정보, 다음 메모를 조용한 문장으로 표현 | 리워드 폭죽, 파워 상승 문구 |
| 재방문 제안 이유 문구 | 제안별 2~3개 | 방금 전장 사건과 한 문장으로 연결 | 숙제, 재교육, 꾸짖기 |
| 최근 추천 목록 문구 | 상태별 2~3개 | 나중에 볼 수 있음을 부드럽게 안내 | 닫으면 손해처럼 보이는 문구 |

메타 해금 기본 규칙:

| ID | 해금 유형 | 표시 | 제작 기준 |
| --- | --- | --- | --- |
| `meta_unlock_enemy_entry_first_seen` | 도감 | 큰 카드 가능 | 처음 본 적의 행동, 저항, 대응 태그 3줄 |
| `meta_unlock_boss_part_record` | 도감 | 큰 카드 가능 | 처음 본 보스 부위와 약화되는 패턴 |
| `meta_unlock_training_repeat_cause` | 훈련 | 큰 카드 가능 | 반복 원인 태그 1개와 30~60초 훈련 연결 |
| `meta_unlock_card_pool_role_tag` | 카드 풀 | 요약 카드 | 도달 구간과 역할 태그를 만족할 때 후보 풀만 확장 |
| `meta_unlock_artifact_pool_role_tag` | 아티팩트 풀 | 요약 카드 | 보스 조우와 역할 태그를 만족할 때 후보 풀만 확장 |
| `meta_unlock_chronicle_cosmetic` | 외형/기록 | 큰 카드 가능 | 파티 기록, 계절 완주, 보스 조우를 전투 수치 없이 저장 |

재방문 제안 기본 규칙:

| ID | 연결 대상 | 즉시 노출 조건 |
| --- | --- | --- |
| `revisit_offer_runner_slowdown` | `training_scenario_runner_slowdown` | 돌파형 누수나 짧은 경로 방치가 반복됨 |
| `revisit_offer_structure_mark` | `training_scenario_breaker_rebuild` | 핵심 구조물 또는 표식 구조물이 연쇄 붕괴 |
| `revisit_offer_disruptor_priority` | `training_scenario_disruptor_priority` | 방해형 생존 중 마나/드로우 손실 누적 |
| `revisit_offer_boss_part_focus` | `training_scenario_boss_part_focus` | 보스 부위 방치가 패턴 압박으로 연결 |
| `revisit_offer_wave_stack_tempo` | `encyclopedia_entry_wave_stack_tempo` | 겹치기 후 압박 급증 또는 보류 판단 필요 |
| `revisit_offer_final_relocation` | `encyclopedia_entry_structure_mark` | 마지막 방어선 이전이 늦거나 반복됨 |

## 도감/훈련장 재방문 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `knowledge_revisit_flow` | 흐름 | 아니오 | 재방문 이유, 대상 선택, 도감 카드, 훈련 장면, 대응 비교, 다음 런 연결 |
| `knowledge_revisit_offer_rule` | 제안 규칙 | 아니오 | 결과/패배/메타에서 재방문 후보를 1개 큰 카드와 최근 추천 목록으로 분리 |
| `knowledge_panel_reason_card` | 재방문 패널 | 아니오 | 패배 원인, 결과 회고, 메타 해금, 처음 만난 적 중 이유 1개 표시 |
| `knowledge_panel_target_select` | 재방문 패널 | 아니오 | 적, 보스 부위, 구조물, 상태이상, 겹치기, 직업 역할 중 대상 선택 |
| `knowledge_panel_compact_entry` | 재방문 패널 | 아니오 | 행동, 저항, 대응 태그, 피해야 할 오해를 3줄 요약 |
| `knowledge_panel_micro_training` | 재방문 패널 | 아니오 | 30~60초 안에 단일 학습 태그만 시험 |
| `knowledge_panel_entry_reason_bridge` | 재방문 패널 | 예 | 패배 분석 카드나 결과 회고에서 왜 이 항목을 보는지 1문장으로 연결 |
| `knowledge_panel_exit_options` | 재방문 패널 | 예 | 다시 시도, 도감 보기, 메모로 가져가기, 닫기 선택 제공 |
| `knowledge_panel_response_compare` | 재방문 패널 | 아니오 | 사용한 대응과 다른 가능성 최대 2개 비교 |
| `knowledge_panel_run_link` | 재방문 패널 | 아니오 | 새 런 준비, 즐겨찾기, 관련 도감 저장 연결 |
| `encyclopedia_entry_status_response` | 도감 | 아니오 | 상태이상 저항과 약화 변환 설명 |
| `encyclopedia_entry_enemy_role_runner` | 도감 | 예 | 빠른 적의 첫 굴곡 지연, 둔화/도발/넉백 대응 설명 |
| `encyclopedia_entry_enemy_role_breaker` | 도감 | 예 | 파괴형이 구조물을 두드리는 조건과 후방 재건 판단 설명 |
| `encyclopedia_entry_wave_stack_tempo` | 도감 | 예 | 웨이브 겹치기가 보상 없는 템포 선택임을 설명 |
| `encyclopedia_entry_shop_context` | 도감 | 예 | 첫 상점이 구매 강제가 아니라 방금 드러난 약점 정리임을 설명 |
| `encyclopedia_entry_structure_mark` | 도감 | 예 | 표식 구조물을 살릴지 버릴지 판단하는 기준 설명 |
| `encyclopedia_entry_enemy_role_disruptor` | 도감 | 예 | 방해형이 마나/드로우를 흔드는 방식과 우선 처치 대응 설명 |
| `encyclopedia_entry_boss_part_focus_basic` | 도감 | 예 | 보스 본체보다 부위 노출과 패턴 시간을 먼저 보는 기준 설명 |
| `training_scenario_runner_slowdown` | 훈련 | 예 | 빠른 적을 둔화/도발/넉백으로 늦추는 장면 |
| `training_scenario_breaker_rebuild` | 훈련 | 예 | 표식 구조물을 살리거나 버리고 후방 재건하는 장면 |
| `training_scenario_disruptor_priority` | 훈련 | 예 | 방해형 우선 처치와 핑 연결 장면 |
| `training_scenario_boss_part_focus` | 훈련 | 예 | 보스 부위를 먼저 보며 패턴을 약화하는 장면 |
| `training_hand_slow_or_taunt_basic` | 훈련 손패 | 예 | 빠른 적 지연용 고정 손패, 실제 덱 변경 없음 |
| `training_hand_repair_or_rebuild_basic` | 훈련 손패 | 예 | 표식 구조물 판단용 고정 손패, 실제 덱 변경 없음 |
| `training_hand_focus_ping_basic` | 훈련 손패 | 예 | 방해형 우선 처치와 집중 핑 연습용 고정 손패 |
| `training_hand_part_focus_basic` | 훈련 손패 | 예 | 보스 부위 1개를 먼저 정하는 고정 손패, 실제 보스 보상 변경 없음 |

MVP 도감/훈련장 샘플 제작 기준:

| 제작물 | 수량 | 작성 기준 | 금지선 |
| --- | ---: | --- | --- |
| 도감 카드 | 6개 | 빠른 적, 파괴형, 방해형, 표식 구조물, 겹치기 템포, 보스 부위 집중 | 정답 빌드, 필수 직업, 특정 카드 강요 |
| 도감 3줄 문구 | 항목당 3줄 | 행동, 위험/저항, 대응 순서로 작성 | 4줄 이상 기본 노출 |
| 훈련 장면 | 4개 | 30~60초, 단일 `targetLearningTag`, 고정 소형 전장 | 복합 튜토리얼, 보상 파밍 |
| 훈련 손패 | 4개 | 대응 태그를 시험하는 고정 카드 묶음 | 실제 덱, 상점, 아티팩트 수정 |
| 결과 비교 문구 | 훈련당 2~3개 | 사용한 대응과 다른 가능성을 점수 없이 비교 | 등급, 성공률, 개인 평가 |

MVP 도감 3줄 문구:

| 도감 ID | 1줄 행동 | 2줄 위험/저항 | 3줄 대응 |
| --- | --- | --- | --- |
| `encyclopedia_entry_enemy_role_runner` | 빠르게 첫 굴곡을 지나갑니다. | 짧은 경로를 열어두면 바로 기지에 닿습니다. | 둔화, 도발, 넉백으로 몇 초를 벌어둡니다. |
| `encyclopedia_entry_enemy_role_breaker` | 막힌 길이나 도발 구조물을 두드립니다. | 오래 맞은 바리케이드는 전선을 갑자기 열 수 있습니다. | 터질 위치와 후방 재건 위치를 먼저 정합니다. |
| `encyclopedia_entry_enemy_role_disruptor` | 마나와 드로우 흐름을 흔듭니다. | 오래 살면 손패가 가벼워도 굴러가지 않습니다. | 첫 핑으로 집중 화력을 찍고 두 번째 방해 전에 끊습니다. |
| `encyclopedia_entry_structure_mark` | 표식 구조물은 곧 압박받을 구조물입니다. | 모두 살리려 하면 수리와 카드가 흩어집니다. | 살릴 축과 버릴 축을 먼저 나눕니다. |
| `encyclopedia_entry_wave_stack_tempo` | 겹치기는 기다림을 줄이는 호출입니다. | 누르면 압박은 즉시 커지지만 보상은 늘지 않습니다. | 기지 치명 체력이나 전선 이전 직전에는 보류할 수 있습니다. |
| `encyclopedia_entry_boss_part_focus_basic` | 보스는 본체보다 부위 시간이 먼저 문제될 수 있습니다. | 남은 부위는 패턴 압박을 오래 끌고 갑니다. | 부위 1개를 먼저 정하고 파티 화력을 모읍니다. |

MVP 훈련 장면:

| 훈련 ID | `targetLearningTag` | 소요 | 전장/손패 | 통과 관찰 |
| --- | --- | ---: | --- | --- |
| `training_scenario_runner_slowdown` | `slow_fast_enemy_at_first_bend` | 45초 | 첫 굴곡, 빠른 적 3기, 둔화/도발/넉백 | 첫 굴곡 전에 지연 |
| `training_scenario_breaker_rebuild` | `split_save_and_abandon_marked_structure` | 50초 | 표식 바리케이드 2개, 수리/해체/후방 설치 | 살릴 것 1개와 버릴 것 1개 분리 |
| `training_scenario_disruptor_priority` | `focus_disruptor_before_second_cast` | 40초 | 군집 뒤 방해형 1기, 집중 핑/단일 화력 | 두 번째 방해 전 처치 |
| `training_scenario_boss_part_focus` | `choose_one_boss_part_before_body` | 60초 | 미니 보스, 부위 2개, 부위 표식 손패 | 먼저 정한 부위 1개 제거 |

## 튜토리얼/첫 세션 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `tutorial_flow` | 흐름 | 예 | 경로, 길막, 빠른 적, 파괴, 자원/겹치기, 보스 부위를 첫 10일과 연결 |
| `tutorial_step_001_path_tower` | 장면 | 예 | 경로 보기와 기본 타워 설치 |
| `tutorial_step_004_no_full_block` | 장면 | 예 | 완전 길막 불가와 대체 위치 피드백 |
| `tutorial_step_005_structure_break` | 장면 | 예 | 구조물 파괴, 잔해, 후방 재건 후보 학습 |
| `tutorial_step_007_wave_stack_tempo` | 장면 | 예 | 웨이브 겹치기가 보상 없는 템포 선택임을 학습 |
| `tutorial_step_008_mini_boss_part` | 장면 | 예 | 보스 부위 집중과 느리게 만드는 감각 학습 |
| `first_session_checkpoint_001_010` | 체크포인트 | 예 | 첫 10일 각 일자를 튜토리얼 흐름과 연결 |
| `first_session_day_contract_001_010` | 계약 데이터 | 예 | 일자별 학습 약속, 허용 실수, 복구 신호, 리포트 문장 연결 |
| `first_session_copy_training_bridge` | 연결 데이터 | 예 | 첫 10일 회수 문구, 튜토리얼 재방문, 훈련 장면, 도감 카드를 학습 태그로 연결 |
| `ui_first_session_copy_key_lock` | 문구 키 | 예 | `ui.first_session.*` 회수 문구를 임시 문자열 없이 관리 |
| `ui_revisit_button_key_lock` | 문구 키 | 예 | 짧게 연습, 3줄 보기, 메모로 가져가기, 닫기 버튼 문구 관리 |
| `first_session_revisit_offer_rule` | 제안 규칙 | 예 | 하루 1회 이하, 자동 열기 금지, 닫기 선택 필수 |
| `first_session_allowed_mistake_tags` | 태그 | 예 | 첫 세션에서 처벌보다 회수해야 할 실수 정의 |
| `first_session_recovery_signal_set` | UI/핑 | 예 | 경로선, 표식, 핑 후보, 회수 카드로 실수 원인을 읽게 함 |
| `first_session_day_recap_card` | 리포트 | 예 | 각 일자 종료 후 플레이어가 얻어야 할 한 문장 회수 |
| `first_shop_day_005_small` | 상점 | 예 | 첫 상점 5~6개 항목, 45~75초, 큰 파티 구매 1개 이하 |
| `onboarding_hint_escalation_rule` | 힌트 규칙 | 예 | 10/20/35/60초 힌트 단계와 자동 시연 제안 |
| `tutorial_revisit_from_defeat` | 패배 지원 | 아니오 | 첫 패배 후 관련 튜토리얼 장면으로 바로 이동 |

## 제작 검증 규칙

콘텐츠를 추가할 때 아래 규칙을 먼저 통과해야 합니다.

1. 활성 방향 프리셋은 1~4인용 4종을 반드시 유지합니다.
2. `scaling_players_1`부터 `scaling_players_4`까지는 활성 방향 프리셋과 1:1로 대응합니다.
3. 각 10일 챕터는 `ChapterIntentPlan`을 가져야 하며, 91~100일은 새 의도를 추가하지 않습니다.
4. `WaveData`는 `waveIntentId`, 질문 태그, 선호 방향, 방향 역할, 투영 규칙을 가질 수 있고, 실제 스폰 방향은 `WaveSpawnPlan`에서 확정합니다.
5. `WaveSpawnPlan.directions`는 항상 `activeDirections`의 부분집합이어야 합니다.
6. 웨이브 겹치기는 예약된 `WaveSpawnPlan`을 앞당길 뿐, 보상이나 방향을 추가하지 않습니다.
7. 시간 경과 마나 회복, 처치 막타 보너스, 웨이브 겹치기 보상 증가 필드는 만들지 않습니다.
8. 아티팩트는 웨이브 겹치기 최대치를 늘릴 수 있지만, 겹치기 보상을 늘릴 수는 없습니다.
9. 이벤트와 보스가 방향 압박을 만들 때도 비활성 방향을 강제로 열지 않습니다.
10. 91일 이후 카드와 아티팩트 풀은 새 아키타입 시작보다 기존 빌드 마무리를 우선합니다.
11. 카드 보상 거절은 실패 정산이 아니라 골드 선택으로 기록합니다.
12. 대응 태그 제작표에 없는 `responseTags`를 카드, 아티팩트, 훈련장에 붙이지 않습니다.
13. 카드의 `responseTags`는 적 역할 프로필의 최소 대응 태그와 연결되어야 합니다.
14. 카드 보상 프로필은 다음 웨이브 의도와 다음 적 역할 프로필을 함께 참조해야 합니다.
15. 모든 직업은 1~10일과 30일 MVP 카드 풀 계약을 가져야 합니다.
16. 모든 직업 전용 카드는 자기 직업의 카드 풀 라인 ID와 하나 이상의 카드 아키타입 ID를 가져야 합니다.
17. 직업별 30일 MVP 카드 풀은 시작 카드 6종과 보상 카드 8종을 합쳐 정확히 14종이어야 하며, 직업마다 3개 이상의 아키타입을 보여줘야 합니다.
18. 카드 풀 라인은 특정 방위 전용 콘텐츠가 아니라 `WaveIntent`와 `LaneProjection`으로 현재 압박 전선에 투영되어야 합니다.
19. 공용 카드는 직업 카드 풀 계약의 금지 대체 태그를 같은 강도로 해결하면 안 됩니다.
20. 모든 카드는 `archetypeIds`, `archetypeRole`, `commitmentLevel`, `decisionQuestionKo`, `timingWindows`, `tradeoffTags`, `comboHookTags`, `missCostTag` 제작 필드를 가져야 합니다.
21. 0비용, 영웅, 저주 카드는 대가나 선행 조건 없이 강한 효과를 가질 수 없습니다.
22. 카드 리워크 매트릭스는 직업별 14종, 공용 8종을 30일 MVP 기준으로 채워야 합니다.
23. 카드 효과 수치를 조정하기 전에 사용 타이밍, 대상 조건, 실패 손해를 먼저 점검합니다.

후반 카드 제작 추가 규칙:

- 100일 풀런 직업은 `full_100` 카드 풀 계약을 가져야 합니다.
- 직업별 후반 신규 카드 6종, 총 24종은 `FullRunCardCatalogEntry`로 등록합니다.
- 후반 신규 카드는 `class_late_patch` 또는 `class_late_payoff` 역할만 사용합니다.
- 91일 이후 후반 영웅 카드는 기존 아키타입 게이트 조건 없이 후보로 노출할 수 없습니다.
- 후반 카드의 `allowedDayRange`는 100일 결과를 포함하지 않습니다.
- 후반 0비용 카드는 조건부와 대가를 모두 가져야 하며, 조건 없는 드로우, 마나 순증가, 피해, 대량 수리를 만들 수 없습니다.
- 후반 이동/재배치 카드는 활성 전선 투영과 경로 검사를 반드시 통과해야 합니다.

카드 스펙 추가 규칙:

- 모든 카드는 `CardSpecProfile`을 참조해야 합니다.
- 카드의 비용, 대상, 범위, 지속, 예고, 반복 제한은 스펙 프로필과 충돌하면 안 됩니다.
- 0비용 카드는 조건 없는 순수 드로우, 마나 순증가, 광역 피해, 대량 수리를 가질 수 없습니다.
- 전장 전체 또는 원격 대상 카드는 낮은 수치, 대상 조건, 반복 제한 중 하나 이상을 가져야 합니다.
- hard CC 카드는 반복 저항과 보스 약화 변환 정책을 가져야 합니다.
- 보스 본체나 부위에 적용되는 카드 스펙은 보스 패턴을 취소할 수 없습니다.
- 경로 비용을 바꾸는 카드는 경로 미리보기와 완전 길막 검사를 반드시 통과해야 합니다.
- 자원 생성, 수리, 피격, 처치, 파괴 반복 발동 카드는 시전당 또는 웨이브당 상한을 가져야 합니다.

카드 강화 추가 규칙:

- 모든 카드의 강화 후보는 존재하는 `CardUpgradeOption`을 참조해야 합니다.
- MVP에서 카드 1장의 강화 후보는 최대 2개입니다.
- 강화는 비용, 범위, 지속, 대상 선택, 발동 조건, 실패 손해, 대가 중 보통 1개 축만 바꿉니다.
- 저주 안정화는 대가를 제거하지 않고 형태를 바꿔야 합니다.
- 영웅 확정 조율은 `MvpHeroicCommitGate` 조건과 실패 손해를 함께 가져야 합니다.
- 영웅 동등 지원 강화/아티팩트는 실제 지원 카드 1장과 최근 전투 증거를 대신할 수 없고, 한 게이트에서 최대 1크레딧만 제공합니다.

24. 모든 카드 보상 프로필은 하나 이상의 `CardLootPool`을 참조하고, 모든 `CardLootPool`은 하나의 `CardRarityProfile`과 포함 가능한 `CardArchetype` 목록을 가져야 합니다.
25. 일반 라운드 전리품 풀과 희귀도 프로필은 저주 가중치를 0으로 둡니다.
26. 보스 개인 카드 전리품은 보스 클리어 성과로 희귀도 가중치를 올리지 않습니다.
27. 상점과 이벤트는 별도 전리품 풀을 사용할 수 있지만, 저주와 영웅 카드는 명시적 선택과 대가를 가져야 합니다.
28. 웨이브 겹치기, 클리어 시간, 처치 수, 접근성 옵션, 재접속 상태는 전리품 풀이나 희귀도 프로필의 비율을 바꿀 수 없습니다.
전리품 희귀도 잠금 추가 검수:

- 모든 1~30일 MVP 전리품 경로는 하나의 `MvpLootRarityLock`을 가져야 합니다.
- 20~30일 상점 카드 슬롯은 영웅 카드를 랜덤 판매하지 않고, 조건부 `shop_heroic_tune` 상품으로만 처리합니다.
- 71~100일 후반 전리품 경로는 하나의 `FullRunLootRarityLock`을 가져야 합니다.
- 71~99일 후반 라운드와 보스 개인 카드 보상은 새 아키타입 진입 후보를 열 수 없습니다.
- 91~99일 영웅 후보는 기존 아키타입 게이트 조건이 있을 때만 노출하고, 조건 미충족 시 같은 대응 태그의 희귀 또는 일반 후보로 내려갑니다.
- 95일 최종 상점은 영웅 랜덤 판매, 신규 저주 계약, 웨이브 겹치기 보상 상품을 제공하지 않습니다.
- 100일 결과 화면은 카드 3장 보상, 희귀도 보정, 다음 런 후보 수 증가를 표시하지 않습니다.

29. 같은 카드 보상 후보 3장에 같은 대응 태그, 카드 풀 라인, 카드 아키타입만 반복해서 넣지 않습니다.

보상 반복 피로도 추가 검수:

- 모든 플레이어 보상 팩은 표시 후 개인 `RewardCandidateExposureMemory`를 남깁니다.
- 같은 카드가 최근 5팩 안에 2회 이상 노출되면 우선 억제하고, 허용 시 `allowedRepeatReasonTags`를 남깁니다.
- 기준 카드와 변형 카드는 같은 보상 화면에 함께 들어가지 않습니다.
- 같은 `poolLaneId`가 3팩 연속 핵심 후보가 되면 같은 레일 안에서 다른 후보를 먼저 찾습니다.
- 반복 거절된 카드는 5팩 동안 우선순위를 낮추되, 영구 제외나 새 카드 보장으로 표시하지 않습니다.
- 반복 피로도 규칙은 후보 수, 희귀도, 골드량, 변형 카드 확률을 바꾸지 않습니다.

카드 수치 예산 추가 검수:

- 모든 MVP `CardSpecProfile`은 `effectBudgetId`와 `statBudgetLockId`를 함께 가져야 합니다.
- `effectBudgetId`는 예산 ID와 잠금 ID 매핑표의 기본 `statBudgetLockId`로 검수합니다.
- `budget_cost1_aura_device`는 `stat_budget_flexible_1`과 `aura_policy_stack_cap`을 요구합니다.
- `budget_cost1_risky_focus`는 명시 계약/저주 카드에만 사용하고 `stat_budget_curse`로 검수합니다.
- 예산 상한 초과는 `exceededAxisTags`, `compensationTagsApplied`, `requiredPolicyIds`를 남겨야 합니다.
- 솔로 플레이, 웨이브 겹치기, 클리어 시간, 처치 수로 카드 예산을 완화하지 않습니다.

30. 직업 성장 데이터는 약점을 완전히 제거하는 효과를 만들지 않습니다.
31. 시너지 트리거는 한 직업 단독 해결이 아니라 최소 2개 역할의 시간/위치 상호작용으로 정의합니다.
32. 적 역할 대응 데이터는 최소 2개 이상의 유효 대응을 가져야 합니다.
33. 모든 적은 `EnemyRoleProfile`을 가져야 하며, 프로필은 연결 `WaveIntent`, 필수 예고, 최소 대응 태그를 포함해야 합니다.
34. `EnemyRoleProfile`의 최소 대응 태그는 특정 직업 하나로만 닫히면 안 됩니다.
35. 적 저항은 특정 직업의 핵심 역할을 완전히 무효화하지 않습니다.
36. 강한 적 역할 질문은 솔로 웨이브에서 1개, 일반 멀티 웨이브에서 2개를 넘기지 않습니다.
37. `WavePreviewCard`는 `WaveIntent`, `EnemyRoleProfile`, `ResponseTag`, `WaveSpawnPlan.directions` 중 최소 하나와 연결되어야 합니다.
38. 예고 UI는 실제 `WaveSpawnPlan.directions`와 다른 방향을 위험 방향으로 표시하지 않습니다.
39. 예고 카드와 회수 카드는 같은 대응 태그 언어를 사용해야 합니다.
40. 겹치기 위험 UI에는 보상, 효율, 보너스 표현을 쓰지 않습니다.
41. `WaveStackVoteSession`은 이미 확정된 `WaveSpawnPlan`만 후보로 참조해야 합니다.
42. 겹치기 투표 시간 초과는 호출이 아니라 보류로 처리합니다.
43. 겹치기 보류, 만료, 취소는 자원 페널티나 개인 책임 태그를 만들지 않습니다.
44. 겹치기 투표 UI는 호출/보류를 보여줄 수 있지만, 보상 기대 문구나 보상 증가 아이콘을 표시하지 않습니다.
45. 기지 체력 30% 이하 겹치기 투표는 전원 동의 조건으로 표시해야 합니다.

기지 체력 검수:

- 기지 최대 체력은 MVP에서 30이며, 회복으로 초과할 수 없습니다.
- 기지 체력 1~9는 치명 상태이며, 치명 경고와 회복 위험 문구를 우선 표시합니다.
- 0.75초 누수 묶음은 UI 표시만 묶고, 실제 기지 피해를 줄이지 않습니다.
- 일반 웨이브에서 기지 체력 0 도달 시 패배로 전환합니다.
- 첫 보스 기지 도달은 15 피해와 5초 카운트다운 정책을 사용합니다.
- 기지 회복은 같은 상점 세션에서 1회만 구매할 수 있고, 전투 중 즉시 회복은 MVP에서 제공하지 않습니다.
- 기지 회복 가격과 회복량은 웨이브 겹치기 횟수, 처치 수, 클리어 시간, 접근성 설정, 솔로 모드로 바뀌지 않습니다.
- 기지 도달 경고의 방향은 항상 실제 활성 방향이어야 하며, 비활성 방향을 위험 핑 후보로 표시하지 않습니다.
- 기지 도달 치명 경고는 자동 카드 사용, 자동 마나 소비, 자동 구조물 조작을 실행하지 않습니다.
- 기지 위험 핑 후보는 플레이어 확정 전까지 직접 핑으로 기록하지 않습니다.
- 솔로의 기지 위험 핑 후보는 파티 명령이 아니라 자기 리마인더 문구로 표시합니다.
- 기지 도달 경고와 위험 핑 문구에는 보상 증가, 특정 직업 필수, 개인 책임 표현을 쓰지 않습니다.
- 패배 분석은 마지막 피해를 준 적보다 반복 누수, 경로 연장 부족, 우선 처치 실패 같은 전장 원인을 우선합니다.

패배 분석 검수:

- 패배 분석 카드는 최대 3장이고, 첫 카드는 가장 설명력이 큰 전장 원인을 보여줘야 합니다.
- 패배 분석 카드의 방향은 해당 런의 실제 활성 방향 안에 있어야 합니다.
- 재도전 제안은 최대 2개이며, 직업, 카드, 아티팩트, 활성 방향을 자동 변경하지 않습니다.
- 재도전 제안은 대응 태그와 운영 습관으로 말하고, 특정 직업이나 특정 카드를 필수처럼 표시하지 않습니다.
- 패배 스냅샷은 5~10초로 제한하고, 실패 장면을 반복 질책하는 연출로 사용하지 않습니다.
- 겹치기 관련 패배 카드는 보상 효율이나 손해가 아니라 위험 급증과 보류 판단으로 설명합니다.

30일 MVP 콘텐츠 잠금 검수:

- 1~30일 모든 일자는 `Mvp30DayContract`를 가져야 합니다.
- 5일, 15일, 25일은 각각 첫 작은 상점, 작은 이벤트/상점, 계절 전환 이벤트 역할을 유지합니다.
- 10일, 20일, 30일은 각각 침묵의 거상, 침묵의 거상 변형, 사계의 관측자 예고형 역할을 유지합니다.
- 8일, 18일, 28일은 웨이브 겹치기를 기능 학습, 안정 판단, 고밀도 리허설로 다르게 사용합니다.
- 21일 전에는 강한 정예형을 본격 투입하지 않습니다.
- 29~30일에는 새 일반 적 역할을 추가하지 않습니다.
- 테스트 조정은 적 수, 체력, 속도, 스폰 간격, 위험도 예산, 보스 부위 체력, 상점 가격처럼 허용된 `tunableFields` 안에서 먼저 처리합니다.
- 30일 MVP 계약은 웨이브 겹치기 보상, 카드 후보 수, 희귀도, 활성 방향 목록을 변경하지 않습니다.

46. 압축 정산은 여러 `WaveRewardPacket`을 묶어 보여줄 수 있지만, 카드 후보 수, 희귀도, 골드 총량을 바꾸지 않습니다.
47. `SettlementBatch`의 골드 총합은 포함된 웨이브별 골드 합계와 일치해야 합니다.
48. 정산 제한 시간 종료 시 이미 선택한 보상 행을 임시 선택으로 덮어쓰지 않습니다.
49. 압축 정산 UI는 3배 보상, 겹침 보너스, 희귀도 상승, 추가 선택지 문구를 표시하지 않습니다.
50. 패배 분석 카드는 개인 책임이나 딜량 순위가 아니라 전장 원인과 다음 시도 제안을 보여줍니다.
51. 핑은 다른 플레이어의 카드 사용, 자원 사용, 구조물 조작을 자동 실행하지 않습니다.
52. 핑 텔레메트리는 개인 평가가 아니라 협동 요청의 읽힘과 해소 여부만 기록합니다.
53. 플레이어 직접 핑은 동시에 3개까지만 유지하고, 자동 경고 표식은 별도 출처로 표시합니다.
54. 자동 경고 큰 표시는 동시에 2개를 넘지 않아야 합니다.
55. 자동 경고는 핑 후보를 제안할 수 있지만, 플레이어가 확정하기 전에는 직접 핑으로 기록하지 않습니다.
56. 자동 경고와 플레이어 핑은 색상 하나가 아니라 아이콘, 이름표, 출처 배지로 함께 구분해야 합니다.
57. 핑 맡음 표시는 최대 2명까지만 크게 보이고, 나머지 동의는 로그나 작은 표시로 접습니다.
58. 핑을 무시하거나 해소하지 못한 기록을 개인 책임, 점수, 보상 조건으로 사용하지 않습니다.
59. 경고에서 제안하는 핑 후보는 존재하는 대응 태그와 연결되어야 하며, 특정 직업을 필수처럼 표시하지 않습니다.
60. 상태이상은 일반 적을 제외한 주요 적을 영구 정지시키지 않습니다.
61. 보스 상태이상 저항은 완전 면역보다 약화 변환을 기본으로 합니다.
62. 저항형 적도 모든 CC를 완전히 무효화하지 않고, 어떤 대응이 약하게라도 통하는지 UI로 보여줍니다.
63. 구조물 파괴와 재건은 완전 길막, 보스 경로 차단, 스폰 적 고립을 만들 수 없습니다.
64. 회수와 재건 효과는 같은 구조물을 반복 파괴하는 무한 자원 루프가 되면 안 됩니다.
65. 수리와 자동 복구는 파괴형 적과 보스 패턴을 완전히 무효화하지 않습니다.
66. 상점 추천은 정답 표시가 아니라 피해 진단과 다음 압박을 연결하는 정렬 기준입니다.
67. 상점 시간 종료 시 강제 구매하지 않고, 구매 없이 넘어가는 선택을 허용합니다.
68. 파티 자원 투표는 동시에 1개만 열고, 보스 후 상점의 큰 파티 구매는 최대 2회로 제한합니다.
69. 이벤트 선택지는 2~3개로 제한하고, 일반 이벤트는 30~60초 안에 끝나야 합니다.
70. 이벤트 시간 종료 시 무작위 위험 선택을 하지 않고, 상태 보존 선택을 기본값으로 둡니다.
71. 이벤트 저주는 플레이어가 선택한 결과로만 들어갑니다.
72. 이벤트가 다음 웨이브를 바꿔도 비활성 방향을 적 스폰이나 필수 방어 압박으로 열지 않습니다.
73. 이벤트는 웨이브 겹치기 보상, 카드 후보 수, 카드 희귀도를 증가시키지 않습니다.

MVP 이벤트 계약 추가 검수:

- 15일 이벤트는 후보 1개만 표시하고, 작은 상점과 합산 90초 목표를 넘지 않습니다.
- 25일 이벤트는 `event_season_sign_025`를 기본으로 하며 조건부 후보는 1개까지만 추가합니다.
- 저주 계약은 `CurseContractProfile`을 참조하고, 카드 수령 플레이어가 직접 확인해야 합니다.
- 지원자 없음, 시간 초과, 확인 취소는 안전 선택으로 처리합니다.
- 저주 계약 문구에는 희생 강요, 필수 선택, 공짜 보상, 보상 증가 표현을 쓰지 않습니다.

74. 아티팩트 후보 3개는 최소 2개 이상의 운영 축을 가져야 하며, 첫 보스 후보는 3개 축을 권장합니다.
75. 슬롯이 가득 찬 아티팩트 선택에서는 현재 유지 선택을 반드시 제공합니다.
76. 아티팩트 슬롯은 어떤 효과를 적용해도 4개를 넘지 않습니다.
77. 91일 이후 아티팩트 후보 풀은 새 아키타입 시작형보다 기존 빌드 마무리형을 우선합니다.
78. 아티팩트 교체 추천은 정답 표시가 아니라 다음 압박과 현재 빌드의 연결 태그로만 표시합니다.
79. 91~100일은 새 시스템 추가보다 기존 판단의 최종 리허설을 우선합니다.
80. 95일 마지막 상점은 모든 약점을 해결하는 만능 구매를 제공하지 않습니다.
81. 98일 마지막 겹치기 판단에는 보상, 희귀도, 추가 선택지 보너스를 붙이지 않습니다.
82. 99일은 새 적이나 새 타일 규칙 없이 최종 보스 전 리허설로 구성합니다.
83. 100일 보스의 장기 압력 권역은 경로 타일을 막거나 비활성 방향을 압박하지 않습니다.
84. 100일 보스는 모든 압박을 한 순간에 최대 강도로 겹치지 않습니다.
85. 튜토리얼은 한 장면에서 하나의 핵심 판단만 가르칩니다.
86. 첫 10일 세션의 새 정보는 튜토리얼 흐름과 연결되어야 합니다.
87. 첫 10일에서 웨이브 겹치기는 보상 없이 템포 선택으로만 보여줍니다.
88. 첫 10일 패배 피드백은 플레이어 책임보다 다시 볼 튜토리얼 장면을 제안합니다.
89. 첫 10일 카드 보상 프로필은 후보 수 3장과 골드 거절 선택을 바꾸지 않습니다.
90. 첫 10일 보상 화면에는 같은 역할 태그 카드가 3장 모두 나오면 안 됩니다.
91. 첫 10일 보상은 직업 약점을 완전히 지우는 공용 카드를 제공하지 않습니다.
92. 웨이브 겹치기 횟수, 클리어 시간, 처치 수로 카드 희귀도나 후보 수를 보정하지 않습니다.
93. 5일 첫 상점은 5~6개 항목만 보여주고, 큰 파티 구매는 1개 이하로 제한합니다.
94. 5일 첫 상점에는 영웅 카드, 아티팩트 교체, 보스 파편 사용, 웨이브 겹치기 강화 항목을 넣지 않습니다.

초반 상점 가격 검수:

- 5일 첫 상점의 첫 저가 제거는 시작 카드 제거를 허용하지 않습니다.
- 10일 보스 후 상점은 7~8개 항목, 파티 구매 최대 2회, 90~120초 목표를 넘지 않습니다.
- 15일 작은 상점은 5~6개 항목, 파티 구매 최대 1회, 60~90초 목표를 넘지 않습니다.
- 20일 변형 보스 후 상점은 7~8개 항목, 파티 구매 최대 2회, 90~120초 목표를 넘지 않습니다.
- 상점 가격은 웨이브 겹치기 횟수, 클리어 시간, 처치 수, 비활성 방향 압박으로 바뀌지 않습니다.
- MVP 1~30일에서는 20일/30일 허용 세션에만 영웅 확정 조율을 제공하며, 이후 구간의 영웅 확정 조율도 별도 후반 영웅 게이트 조건을 요구합니다.

상점 소모품 검수:

- 파티 소모품 슬롯은 MVP에서 2개를 넘지 않습니다.
- 소모품은 자동 사용되지 않으며, 전투 중 사용 시 1초 예고 핑을 남깁니다.
- 소모품 추천은 공개된 피해 진단 태그와 활성 방향 다음 압박만 사용합니다.
- 구조물 보강 소모품은 영구 최대 체력 증가, 완전 길막, 건축가 잔해 폭발 대체 효과를 제공하지 않습니다.
- 일회성 주문은 보스 본체 패턴 취소, 장기 정지, 보상 증가, 카드 후보 수 증가, 카드 희귀도 증가를 제공하지 않습니다.
- `비상 종`은 마나 회복이나 버리기 스택 증가를 제공하지 않습니다.
- `예비 축전핵`은 다음 1웨이브 시드 마나 보정만 제공하고, 시간 경과 마나 회복을 만들지 않습니다.

95. 첫 10일 웨이브는 하루에 강한 역할 질문을 1개만 던집니다.
96. 첫 10일의 새 적 등장일에는 강한 다방향 압박을 함께 쓰지 않습니다.
97. 1~4일은 모든 인원수에서 실제 스폰 방향을 1개로 제한합니다.
98. 1인은 1~10일 동안 동쪽 외 일반 웨이브를 만들지 않습니다.
99. 첫 10일 보스전은 3방향 이상 동시 압박을 사용하지 않습니다.
100. 첫 10일 웨이브 실패 리포트는 해당 일자의 `learningPhaseIndex`와 연결되어야 합니다.
101. 첫 10일 각 일자는 `FirstSessionDayContract`를 가져야 합니다.
102. 첫 10일 웨이브는 각 일자의 시간 봉투를 가져야 합니다.
103. `FirstSessionDayContract.allowedMistakeTags`는 난이도 보정이 아니라 리포트와 힌트 회수에만 사용합니다.
104. 첫 세션의 강한 힌트가 3회를 넘으면 플레이어 실패가 아니라 온보딩 실패로 기록합니다.
105. 첫 세션 리포트는 개인 딜량, 처치 수, 실수 소유자, 겹치기 점수를 표시하지 않습니다.
106. 첫 10일 회수 문구는 `FirstSessionCopyTrainingBridge`와 `ui.first_session.*` 키를 사용해야 합니다.
107. 첫 10일 재방문 제안은 하루 1회 이하이며 자동으로 훈련장을 열 수 없습니다.
108. 첫 10일 재방문 버튼에는 `닫기`가 반드시 있어야 하며, 닫아도 난이도나 보상이 바뀌지 않습니다.
109. 첫 10일 재방문 제안은 정답 카드, 필수 직업, 자동 빌드, 보상 증가 문구를 표시하지 않습니다.
110. 솔로 첫 10일 재방문은 동쪽 외 방향을 실제 방어 대상으로 표시하지 않습니다.
111. 첫 보스 단계 계획은 핵심 전투 흐름으로 시작해야 합니다.
112. 첫 보스의 추천 첫 부위는 다리부지만, 본체 공격을 금지하거나 실패 처리하지 않습니다.
113. 첫 보스 부위 파괴는 전투 중 이점만 주고 추가 보스 파편이나 보상 후보를 주지 않습니다.
114. 첫 보스 동반 웨이브는 새 적 학습을 담당하지 않습니다.
115. 첫 보스 동반 웨이브는 활성 방향 안에서만 만들고, 1인은 동쪽만 사용합니다.
116. 첫 보스에는 3방향 이상 동시 압박, 사방 동시 보스전, 웨이브 겹치기 보상 문구를 붙이지 않습니다.
117. 11~20일 WaveData는 `chapterFlowId: spring2_operation_flow_011_020`와 `chapterPhaseIndex`를 가져야 합니다.
118. 11~20일은 1인에서 동쪽 외 일반 웨이브를 만들지 않습니다.
119. 11~20일은 4인에서도 사방 동시 압박을 기본값으로 쓰지 않습니다.
120. 15일 작은 상점은 첫 보스 후 상점보다 작아야 하며, 파티 자원 구매는 최대 1회 권장입니다.
121. 18일 겹치기 판단에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
122. 20일 침묵의 거상 변형은 빠른 등불, 짧은 예고, 약한 동반 웨이브 중 하나만 선택합니다.
123. 20일 변형 보스는 11~19일 실패 태그를 되묻되, 추가 보상 계산에 사용하지 않습니다.
124. 21~30일 WaveData는 `chapterFlowId: mvp30_coop_flow_021_030`와 `chapterPhaseIndex`를 가져야 합니다.
125. 21~30일 정예는 처치 타이밍 질문을 가져야 하며, 단순 체력벽으로 만들지 않습니다.
126. 21~30일 1인은 동쪽 외 일반 웨이브를 만들지 않습니다.
127. 21~30일 2인은 3방향 이상 동시 압박을 만들지 않습니다.
128. 21~30일 3인은 남쪽 일반 웨이브를 만들지 않습니다.
129. 21~30일 4인은 30일 전까지 사방 동시 압박을 기본값으로 쓰지 않습니다.
130. 28일 3웨이브 겹치기 시험에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
131. 30일 관측자 예고형의 후보 방향은 항상 `activeDirections`의 부분집합이어야 합니다.
132. 30일 관측자 예고형은 예고와 무관한 기습 방향을 만들지 않습니다.
133. 31~40일 WaveData는 `chapterFlowId: summer1_heat_flow_031_040`와 `chapterPhaseIndex`를 가져야 합니다.
134. 과열 타일은 활성 방향 설치 구역 안에서만 생성합니다.
135. 과열 타일은 보상 배율, 골드 증가, 희귀도 증가, 카드 후보 증가를 만들 수 없습니다.
136. 과열 타일은 순수 피해 함정이 아니라 공격 속도 이득과 구조물 위험을 함께 가져야 합니다.
137. 잿불 석공과 과열된 거상은 과열 생성 전에 예고 표시를 줘야 합니다.
138. 38일 과열 상태 겹치기에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
139. 40일 과열된 거상은 과열 피해와 강한 동반 웨이브를 동시에 최대치로 사용하지 않습니다.
140. 40일 과열된 거상 부위는 2개부터 시작하고, 4개 이상으로 늘리지 않습니다.
141. 41~50일 WaveData는 `chapterFlowId: summer2_collapse_flow_041_050`와 `chapterPhaseIndex`를 가져야 합니다.
142. 열톱니와 파괴형 표식은 실제 공격 전에 예고 시간을 가져야 합니다.
143. 표식 구조물은 반드시 파괴되는 대상이 아니라 살림/희생/후방 재건 선택지를 가져야 합니다.
144. 41~50일 1인은 동쪽 외 일반 웨이브를 만들지 않습니다.
145. 41~50일 2인은 서쪽 일반 웨이브를 만들지 않습니다.
146. 41~50일 3인은 남쪽 일반 웨이브를 만들지 않습니다.
147. 47일과 50일 후보 방향 예고는 항상 `activeDirections`의 부분집합이어야 합니다.
148. 48일 파괴형 겹치기 경고에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
149. 50일 관측자 강화형은 후보 밖 기습 스폰을 만들지 않습니다.
150. 50일 관측자 강화형은 예고 교란과 강한 파괴형 동반 웨이브를 동시에 과하게 쓰지 않습니다.
151. 41~50일 `Summer2CollapseSpawnPacketLock`은 존재하는 `WaveSpawnPacket`만 참조해야 합니다.
152. 48일 겹치기 후보는 47~49일 일반 웨이브만 사용할 수 있으며, 50일 보스는 호출 대상이 아닙니다.
153. 50일 선택적 동반 패킷은 보상 팩, 카드 후보, 보스 파편을 추가하지 않습니다.
154. 51~60일 WaveData는 `chapterFlowId: autumn1_path_flow_051_060`와 `chapterPhaseIndex`를 가져야 합니다.
155. 낙엽 후보 타일은 항상 `activeDirections` 안에서만 생성해야 합니다.
156. 낙엽 변화는 전투 시작 전에 예고하고, 웨이브 중 변화는 최대 1회까지만 허용합니다.
157. 낙엽과 잔해가 모든 경로를 막을 수 있는 데이터에는 `routeReopenPolicyId`가 반드시 있어야 합니다.
158. 가을의 묵자는 마나 획득량을 낮출 수 있지만 마나 사용이나 획득을 완전히 봉쇄하지 않습니다.
159. 57일 경로 변화 중 겹치기 경고에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
160. 60일 무너진 종탑은 `boss_phase_plan_fallen_belltower_060`을 사용해야 합니다.
161. 60일 무음 권역은 예고 시간을 가지며, 오라와 수리 효율을 0으로 만들지 않습니다.
162. 60일 무너진 종탑은 비활성 방향에 무음 권역, 낙엽 변화, 동반 웨이브를 만들지 않습니다.
163. 60일 보스 클리어에 웨이브 겹치기 보상 증가를 붙이지 않습니다.
164. 51~60일 `Autumn1PathSpawnPacketLock`은 존재하는 `WaveSpawnPacket`만 참조해야 합니다.
165. 57일 겹치기 후보는 57~59일 일반 웨이브만 사용할 수 있으며, 60일 보스는 호출 대상이 아닙니다.
166. 60일 선택적 동반 패킷은 보상 팩, 카드 후보, 보스 파편, 아티팩트 드롭 수를 추가하지 않습니다.
167. 51~60일 2인은 서쪽/남쪽 낙엽 후보, 잔해 압박, 일반 웨이브를 만들지 않습니다.
168. 51~60일 3인은 남쪽 낙엽 후보, 잔해 압박, 무음 권역, 일반 웨이브를 만들지 않습니다.
169. 61~70일 WaveData는 `chapterFlowId: autumn2_priority_flow_061_070`와 `chapterPhaseIndex`를 가져야 합니다.
170. 61~70일은 신규 적을 많이 추가하지 않고 기존 방해형/정예/낙엽/잔해 조합으로 우선순위를 만들어야 합니다.
171. 후미 정예 스폰에는 전투 전 예고 또는 스폰 순서 경고가 있어야 합니다.
172. 방해형과 정예를 동시에 투입할 때는 `disruptorEliteMixPolicyId`로 동시 과부하를 제한해야 합니다.
173. 61~70일 1인은 동쪽 외 일반 웨이브나 두 방향 우선순위 판단을 만들지 않습니다.
174. 61~70일 3인은 남쪽 정예, 방해형, 동반 웨이브를 만들지 않습니다.
175. 67일 침묵 속 겹치기 경고에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
176. 70일 무너진 종탑 변형은 `boss_phase_plan_belltower_variant_070`을 사용해야 합니다.
177. 70일 보스 변형은 새 부위, 새 패턴, 강한 동반 웨이브를 동시에 추가하지 않습니다.
178. 70일 보스 클리어에 웨이브 겹치기 보상 증가를 붙이지 않습니다.
179. 61~70일 `Autumn2PrioritySpawnPacketLock`은 존재하는 `WaveSpawnPacket`만 참조해야 합니다.
180. 61~70일 `priorityThreatPairId`는 보상, 카드 후보, 희귀도, 골드 계산에 사용할 수 없습니다.
181. 63일 후미 정예는 전투 전 예고 또는 스폰 순서 경고를 가져야 합니다.
182. 67일 겹치기 후보는 67~69일 일반 웨이브만 사용할 수 있으며, 70일 보스는 호출 대상이 아닙니다.
183. 70일 선택적 동반 패킷은 한 번에 하나만 사용할 수 있으며 보상 팩, 카드 후보, 보스 파편, 아티팩트 드롭 수를 추가하지 않습니다.
184. 61~70일 2인은 서쪽/남쪽 정예, 방해형, 동반 웨이브를 만들지 않습니다.
185. 70일 `belltower_variant_phase_plan_lock_070`은 60일 무너진 종탑 부위와 패턴만 재사용해야 합니다.
186. 70일 `boss_ui_companion_priority_prompt`는 동반 조합 등장 8초 전까지 표시되어야 합니다.
187. 70일 무음 권역과 선택 동반 조합은 동시에 최대치로 겹칠 수 없습니다.
188. 70일 보스 결과 리포트는 첫 우선 대상, 대상 변경, 권역 후 재집결 여부를 기록해야 합니다.
189. 70일 무너진 종탑 변형 제작 항목은 새 부위, 새 보스 패턴, 강한 동반 웨이브, 사방 동시 압박, 보상 증가를 포함할 수 없습니다.
190. 71~80일 WaveData는 `chapterFlowId: winter1_space_flow_071_080`와 `chapterPhaseIndex`를 가져야 합니다.
191. 결빙 후보 타일은 항상 `activeDirections` 안의 설치 타일이어야 하며 경로 타일을 포함하지 않습니다.
192. 결빙은 준비 항목 또는 전투 중 예고 후 적용되어야 하며, 71~79일 일반 웨이브 중 추가 결빙은 최대 1회입니다.
193. 결빙은 구조물을 즉시 삭제하거나 보상 배율, 골드 증가, 카드 후보 증가를 만들 수 없습니다.
194. 겨울 껍질은 체력만 높은 적이 아니라 지속 화력, 둔화, 도발, 잔해 중 하나 이상의 대응 태그를 가져야 합니다.
195. 71~80일 1인은 동쪽 외 결빙, 대형 적, 동반 웨이브를 만들지 않습니다.
196. 71~80일 3인은 남쪽 결빙, 대형 적, 동반 웨이브를 만들지 않습니다.
197. 78일 공간 축소 중 겹치기 경고에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
198. 80일 겨울의 문 예고형은 `boss_phase_plan_winter_gate_preview_080`을 사용해야 합니다.
199. 80일 보스는 90일/100일급 장기 공간 봉쇄나 구조물 예고 없는 삭제를 사용하지 않습니다.
200. 71~80일 `Winter1SpaceSpawnPacketLock`은 존재하는 `WaveSpawnPacket`만 참조해야 합니다.
201. 71~80일 결빙 후보 타일은 실제 경로 타일을 포함할 수 없습니다.
202. 78일 겹치기 후보는 78~79일 일반 웨이브만 사용할 수 있으며, 80일 보스는 호출 대상이 아닙니다.
203. 80일 선택적 동반 패킷은 보상 팩, 카드 후보, 보스 파편, 아티팩트 드롭 수를 추가하지 않습니다.
204. 80일 보스 클리어에 웨이브 겹치기 보상 증가를 붙이지 않습니다.
205. 80일 결빙은 임시 설치 권역 제한만 사용할 수 있으며 경로 타일 차단이나 장기 공간 봉쇄를 만들 수 없습니다.
206. 80일 `winter_gate_preview_phase_lock_080`은 `boss_phase_plan_winter_gate_preview_080`의 6단계만 참조해야 합니다.
207. 80일 결빙 사이클은 `frost_cycle_080_*` 4개를 넘을 수 없습니다.
208. 80일 결빙 사이클은 동시에 1권역만 얼릴 수 있으며 경로 타일을 포함할 수 없습니다.
209. 80일 결빙 예고 시간은 4초 미만이 될 수 없고, 결빙 지속 시간은 9초를 넘을 수 없습니다.
210. 80일 `companion_policy_080_single_optional`은 겨울 껍질 1기 또는 회색 행렬 8기 중 1종만 허용합니다.
211. 80일 선택 동반 웨이브는 둘을 동시에 쓰거나 보상, 희귀도, 카드 후보, 골드 계산에 연결할 수 없습니다.
212. 80일 결과 연결 태그는 81~90일 힌트와 추천에만 사용하고, 보상 계산에는 사용할 수 없습니다.
213. 80일 보스 시간이 길어질 때는 결빙 지속 시간, 예고 시간, 선택 동반, 부위 체력 순서로 조정하며 보상 증가는 금지합니다.
214. 81~90일 WaveData는 `chapterFlowId: winter2_pressure_flow_081_090`와 `chapterPhaseIndex`를 가져야 합니다.
215. 보스 압력 후보 권역은 항상 `activeDirections` 안의 설치 권역이어야 하며 경로 타일을 포함하지 않습니다.
216. 보스 압력 타일은 예고 후 생성되어야 하며 구조물을 즉시 삭제하지 않습니다.
217. 보스 압력 타일은 보상 배율, 골드 증가, 카드 후보 증가, 카드 희귀도 증가를 만들 수 없습니다.
218. 81~90일 1인은 동쪽 외 압력 권역, 대형 적, 동반 웨이브를 만들지 않습니다.
219. 81~90일 3인은 남쪽 압력 권역, 대형 적, 동반 웨이브를 만들지 않습니다.
220. 87일 압력 중 겹치기 경고에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
221. 90일 겨울의 문은 `boss_phase_plan_winter_gate_090`을 사용해야 합니다.
222. 90일 보스는 100일 완전체처럼 지나간 권역을 장기 봉쇄하지 않습니다.
223. 90일 보스 클리어에 웨이브 겹치기 보상 증가를 붙이지 않습니다.
224. 81~90일 `Winter2PressureSpawnPacketLock`은 존재하는 `WaveSpawnPacket`만 참조해야 합니다.
225. 81~90일 `PressureTilePlanLock`은 존재하는 압력 계획 ID만 사용해야 합니다.
226. 81~90일 압력 후보 타일은 실제 경로 타일을 포함할 수 없습니다.
227. 81~90일 압력 권역은 동시에 1개를 넘을 수 없습니다.
228. 81~89일 일반 웨이브 중 압력 이동은 최대 2회입니다.
229. 81~90일 2인은 서쪽/남쪽 압력 후보, 대형 적, 동반 웨이브를 실제 방향으로 사용할 수 없습니다.
230. 87일 겹치기 후보는 87~89일 일반 웨이브만 사용할 수 있으며, 90일 보스는 호출 대상이 아닙니다.
231. 90일 선택적 동반 패킷은 보상 팩, 카드 후보, 보스 파편, 아티팩트 드롭 수를 추가하지 않습니다.
232. 90일 압력 계획은 경로 타일 차단, 장기 압력 권역, 구조물 즉시 삭제를 만들 수 없습니다.
233. 90일 보스 시간이 길어질 때는 압력 지속 시간, 예고 시간, 선택 동반, 부위 체력 순서로 조정하며 보상 증가는 금지합니다.
234. 90일 `winter_gate_phase_lock_090`은 `boss_phase_plan_winter_gate_090`의 6단계만 참조해야 합니다.
235. 90일 이동 압력 사이클은 `pressure_cycle_090_*` 4개를 넘을 수 없습니다.
236. 90일 이동 압력 사이클은 동시에 1권역만 누를 수 있으며 경로 타일을 포함할 수 없습니다.
237. 90일 이동 압력 예고 시간은 4초 미만이 될 수 없고, 압력 지속 시간은 12초를 넘을 수 없습니다.
238. 90일 이동 압력은 다음 사이클 전에 이전 권역을 회복해야 하며 장기 압력으로 남을 수 없습니다.
239. 90일 `companion_policy_090_single_optional`은 겨울 껍질 1기 또는 회색 행렬 10기 중 1종만 허용합니다.
240. 90일 선택 동반 웨이브는 둘을 동시에 쓰거나 보상, 희귀도, 카드 후보, 골드 계산에 연결할 수 없습니다.
241. 90일 결과 연결 태그는 91~100일 힌트와 추천에만 사용하고, 보상 계산에는 사용할 수 없습니다.
242. 91~100일 WaveData는 `chapterFlowId: final_rehearsal_flow_091_100`와 `chapterPhaseIndex`를 가져야 합니다.
243. 91~100일은 새 적, 새 타일, 새 상태이상, 새 카드 규칙 학습을 추가하지 않습니다.

최종 리허설 세부 검수:

- 91~99일 일반 웨이브는 `FinalRehearsalDayContract`와 `FinalRehearsalSpawnLock`을 가져야 합니다.
- 92~94일은 빠른 적, 자원 방해, 구조물 파괴 약점을 하루 하나씩 다시 묻고, 세 약점을 하루에 모두 최대 강도로 합치지 않습니다.
- 97일과 99일 압력 예고는 UI 예고이며 설치 금지, 수리 효율 감소, 공격 속도 감소를 실제 적용하지 않습니다.
- 98일 겹치기는 98~99일 일반 웨이브만 압축할 수 있고 100일 보스 스폰 플랜을 앞당길 수 없습니다.
- 99일은 새 적, 새 타일, 새 상태이상, 새 카드 규칙을 추가하지 않습니다.

244. 95일 마지막 상점은 모든 약점을 해결하지 않으며, 큰 파티 구매는 최대 2회까지만 허용합니다.
245. 95일 최종 상점은 아티팩트 교체 행동을 최대 1회까지만 허용합니다.
246. 95일 아티팩트 후보 풀은 새 아키타입 시작, 슬롯 증가, 웨이브 겹치기 최대치 신규 증가를 기본 후보로 제공하지 않습니다.
247. 95일 상점 종료 시 `abandonedWeaknessTags`와 `lockedBuildAxisTags`가 반드시 기록되어야 합니다.
   - 95일 상점 표시 항목은 6~7개여야 합니다.
   - `shop_final_market_note`와 `shop_keep_current_build`는 항상 표시하며 구매 한도를 소모하지 않습니다.
   - `shop_final_deck_trim`은 카드 1장 제거 또는 1장 안정화만 허용합니다.
   - `shop_final_core_tune`은 새 카드 구매나 새 아키타입 시작을 만들 수 없습니다.
   - `shop_final_boss_part_lens`는 보스 부위 즉시 파괴, 보상 증가, 파편 증가를 만들 수 없습니다.
   - 구매한 상품의 `cannotPatchWeaknessTags` 중 최소 1개는 남겨둔 위험 후보로 표시합니다.
248. 96일 이후에는 아티팩트 교체, 대형 카드 제거, 영웅 확정 조율 상점을 다시 열지 않습니다.
249. 98일 마지막 겹치기 판단에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
250. 99일은 새 규칙 튜토리얼 없이 최종 보스 전 리허설로 구성합니다.
251. 100일 겨울의 문 완전체는 `boss_phase_plan_winter_gate_final_100`을 사용해야 합니다.
252. 100일 장기 압력 권역은 `activeDirections` 안의 설치 권역에만 생성되며 경로 타일을 포함하지 않습니다.
253. 100일 보스는 모든 압박을 한 순간에 최대 강도로 겹치지 않습니다.
   - `boss_phase_plan_winter_gate_final_100`은 6단계 고정이며 단계 누락/중복을 허용하지 않습니다.
   - 1단계 `boss_phase_100_entry_warning`은 UI 예고 전용이며 실제 압력을 적용하지 않습니다.
   - 4단계 동반 분기는 침묵/정예/파괴 중 하나만 선택하고 두 분기를 동시에 실행하지 않습니다.
   - 100일 보스 부위 파괴는 보상, 파편, 카드 후보, 희귀도 보정을 만들지 않습니다.
   - 100일 보스는 98일 웨이브 겹치기 후보가 될 수 없습니다.
254. 100일 결과 요약은 마지막 킬존, 포기한 약점, 최종 방어선 이전 횟수를 포함해야 합니다.
255. 100일 결과 화면은 `final_result_reflection_flow`를 사용해야 합니다.
256. 결과 화면의 결정적 장면 카드는 최대 3장까지만 표시합니다.
257. 결과 화면에는 개인 딜량 순위, 처치 순위, 개인 실수 소유자 필드를 만들지 않습니다.
258. 웨이브 겹치기 사용량은 보상 효율, 추가 보상, 희귀도 효율로 표시하지 않습니다.
259. 플레이테스트 대시보드는 `playtest_dashboard_layout_mvp`를 사용해야 합니다.
260. 대시보드는 상단 런 스트립, 패널 카드 그리드, 위험 신호 드릴다운, 다음 빌드 액션 큐를 모두 가져야 합니다.
261. 상단 런 스트립에는 `buildId`, `runMode`, `playerCountAtStart`, `activeDirections`가 반드시 있어야 합니다.
262. 패널 카드는 핵심 수치 1~3개만 먼저 보여주고 원본 이벤트는 드릴다운에서만 펼칩니다.
263. 대시보드 액션 큐는 전투, 보상, 상점, 카드 후보 수, 희귀도, 활성 방향을 자동으로 바꿀 수 없습니다.
264. 승리와 패배는 같은 결과 회고 구조를 사용합니다.
265. 다음 런 제안은 최대 2개이며, 정답 빌드나 필수 직업처럼 표시하지 않습니다.
266. 95일에 포기한 약점이 있으면 결과 화면에 `abandonedWeaknessTags`를 표시합니다.
267. 결정적 장면 카드의 방향은 `activeDirections` 밖을 위험 방향으로 표시할 수 없습니다.
268. 파티 기록에는 점수 랭킹보다 파티 조합, 아티팩트, 마지막 방어선 태그를 우선합니다.
269. 결과 화면은 플레이 성과를 추가 골드, 카드 후보, 아티팩트 후보 보상으로 환산하지 않습니다.

100일 결과 회고 세부 검수:

- `result_panel_outcome_lock`, `result_panel_last_bastion_summary`, `result_panel_commitment_recall`, `result_panel_decisive_moments`, `result_panel_next_run_suggestion`, `result_panel_party_chronicle_save`가 순서대로 존재해야 합니다.
- 결정적 장면 카드는 `moment_last_relocation`, `moment_base_crisis`, `moment_abandoned_weakness_branch`, `moment_boss_part_choice`, `moment_held_structure`, `moment_wave_stack_tempo`, `moment_final_breach` 중에서만 생성합니다.
- 같은 `momentType`은 한 결과 화면에 1장만 표시합니다.
- 결정적 장면 스냅샷은 5~10초이며 자동 반복 재생하지 않습니다.
- `moment_wave_stack_tempo`는 호출 시점과 압박 변화만 표시하고 보상, 희귀도, 후보 수, 골드 효율을 표시하지 않습니다.
- 결과 화면의 다음 런 제안은 `final_suggest_*` 계열 최대 2개이며 `autoApply: false`여야 합니다.
- 솔로 결과 회고는 동쪽 외 방향을 위험 방향, 붕괴 방향, 다음 런 보강 방향으로 표시할 수 없습니다.

파티 연대기 세부 검수:

- `party_chronicle_entry`, `party_chronicle_title_options`, `party_chronicle_book_view`, `party_chronicle_filter_preset` 제작 항목이 모두 존재해야 합니다.
- 기억 태그 사전은 기본 48개를 포함하고, 확장 후에도 40~60개 범위를 유지해야 합니다.
- 기억 태그 묶음은 `lane_path`, `structure_maze`, `resource_hand`, `enemy_response`, `tempo_stack`, `boss_weakness`, `artifact_role`, `ending_memory`만 사용합니다.
- 제목 후보는 최대 3개이며, 클리어 등급, 최고 점수, 캐리, 개인 비난 표현을 사용할 수 없습니다.
- 기억 태그는 3~5개이며, 모두 파티 단위 전장 사건이나 운영 방식이어야 합니다.
- 같은 결과의 기억 태그는 같은 묶음에서 3개 이상 고를 수 없고, `ending_memory`는 최대 1개만 고릅니다.
- 다음 런 메모는 최대 2개이며, 직업, 카드, 아티팩트, 활성 방향을 자동 적용하지 않습니다.
- 연대기 저장을 건너뛰어도 해금, 메타 진행, 재방문 제안, 새 런 준비가 막히지 않습니다.
- 기록장 필터는 최근순, 즐겨찾기, 결과, 도달 구간, 인원수, 직업 조합, 보스, 기억 태그로 제한합니다.
- 기록장에는 승률, 최고 점수, 평균 점수, 개인 기여도, 딜량, 처치 수, 겹치기 효율, 보상 효율 필터가 없어야 합니다.
- 솔로 연대기는 동쪽 외 방향을 위험, 붕괴, 다음 런 보강 방향으로 표시할 수 없습니다.

270. 런 이후 메타 진행은 `post_run_meta_flow`를 사용해야 합니다.
271. 메타 진행은 공격력, 구조물 체력, 마나 회복량, 웨이브 보상 배율을 직접 올리지 않습니다.
272. 딜량, 처치 수, 웨이브 겹치기 횟수, 개인 실수 태그는 메타 해금량 증가 조건으로 쓰지 않습니다.
273. 메타 해금은 카드 풀, 아티팩트 풀, 도감, 훈련 장면, 외형처럼 선택지나 정보 중심이어야 합니다.
274. 새 카드/아티팩트 해금은 기존 풀을 난잡하게 만들지 않도록 역할 태그와 등장 구간을 가져야 합니다.
275. 다음 런 준비 제안은 최대 2개이며, 직업이나 카드를 강제하지 않습니다.
276. 도감 해금은 실제 만난 적/보스 또는 관련 실패 태그와 연결되어야 합니다.
277. 훈련 장면 해금은 패배/회고 태그와 연결되지만 필수 재교육처럼 강제하지 않습니다.
278. 외형 보상은 전투 수치나 보상 확률에 영향을 주지 않습니다.
279. 숙련 플레이어는 메타 해금 없이도 클리어 가능해야 합니다.

런 이후 메타 세부 검수:

- 결과 회고 뒤에는 `PostRunLearningPacket`을 만들고 `post_run_learning_packet_created`를 기록해야 합니다.
- 한 결과에서 생성하는 학습 패킷은 6개를 넘지 않습니다.
- 학습 패킷 하나의 `learningTags`와 `responseTags`는 각각 3개를 넘지 않습니다.
- 결과 직후 메타 화면은 이번 런 기록 1장, 새 정보/훈련 해금 최대 2장, 다음 런 메모 1장만 크게 표시합니다.
- 카드 풀/아티팩트 풀 해금은 후보 풀 확장만 허용하고, 후보 수나 희귀도를 올릴 수 없습니다.
- 즉시 재방문 제안은 1개만 표시하고, 나머지는 최근 추천 목록에 최대 3개까지 저장합니다.
- 같은 재방문 제안을 두 런 연속 닫으면 다음 런 종료까지 큰 카드로 다시 띄우지 않습니다.

280. 도감/훈련장 재방문은 `knowledge_revisit_flow`를 사용해야 합니다.
281. 재방문 제안은 패배 원인, 결과 회고, 메타 해금, 처음 만난 적 중 하나의 이유 태그를 가져야 합니다.
282. 훈련 장면은 하나의 `targetLearningTag`만 다루며, 여러 규칙을 한 번에 가르치지 않습니다.
283. 훈련 장면은 30~60초 안에 끝나야 하며 실패해도 바로 재시도하거나 나갈 수 있어야 합니다.
284. 훈련 장면은 실제 골드, 카드, 아티팩트, 메타 파워를 지급하지 않습니다.
285. 훈련 장면은 `activeDirections` 밖의 스폰이나 필수 방어 압박을 만들지 않습니다.
286. 도감 카드는 정답 빌드, 필수 직업, 강제 카드 추천을 표시하지 않습니다.
287. 대응 비교는 점수, 등급, 개인 평가가 아니라 대응 태그 차이만 보여줍니다.
288. 훈련 손패와 훈련 구조물은 실제 런 덱, 상점, 아티팩트, 구조물 기록을 변경하지 않습니다.
289. 재방문 이유 카드는 한 장만 표시하고, 플레이어를 꾸짖거나 숙제를 부여하는 문구를 쓰지 않습니다.
290. 훈련 결과는 성공/실패 점수가 아니라 사용한 대응 태그와 다른 가능성 비교로만 표시합니다.
291. 솔로 재방문 훈련은 동쪽 외 방향을 실제 방어 대상으로 표시하지 않습니다.
292. 재방문 후 다음 런 연결은 즐겨찾기와 제안만 제공하고 자동 빌드를 적용하지 않습니다.
293. 도감/훈련장 완료 여부는 런 시작, 난이도, 보상 확률, 카드 후보 수, 희귀도, 활성 방향을 잠그거나 보정하지 않습니다.

도감/훈련장 샘플 세부 검수:

- MVP 도감 카드 6개가 존재해야 합니다.
- 도감 카드는 `encyclopedia_entry_enemy_role_runner`, `encyclopedia_entry_enemy_role_breaker`, `encyclopedia_entry_enemy_role_disruptor`, `encyclopedia_entry_structure_mark`, `encyclopedia_entry_wave_stack_tempo`, `encyclopedia_entry_boss_part_focus_basic`을 포함해야 합니다.
- 각 도감 카드의 기본 요약은 정확히 3줄이며, 행동, 위험/저항, 대응 순서여야 합니다.
- MVP 훈련 장면 4개가 존재해야 합니다.
- 훈련 장면은 `training_scenario_runner_slowdown`, `training_scenario_breaker_rebuild`, `training_scenario_disruptor_priority`, `training_scenario_boss_part_focus`를 포함해야 합니다.
- 훈련 손패는 `training_hand_slow_or_taunt_basic`, `training_hand_repair_or_rebuild_basic`, `training_hand_focus_ping_basic`, `training_hand_part_focus_basic`을 포함해야 합니다.
- 모든 MVP 훈련 장면은 30~60초 목표 시간, 단일 `targetLearningTag`, `rewardDisabled: true`, `runStateMutationDisabled: true`를 가져야 합니다.
- `encyclopedia_entry_wave_stack_tempo`는 훈련 장면이 없어도 되며, 보상 증가가 아니라 보류/호출 판단만 다뤄야 합니다.
- `training_scenario_boss_part_focus`는 보스 보상, 보스 파편, 아티팩트 후보, 카드 후보 수를 바꿀 수 없습니다.
- 솔로용 도감/훈련 노출은 동쪽 외 방향을 실제 위험이나 방어 대상으로 표시할 수 없습니다.

294. 새 런 준비는 `new_run_setup_flow`를 사용해야 합니다.
295. 다음 런 제안은 최대 2개이며 직업, 카드, 아티팩트, 활성 방향을 자동으로 바꾸지 않습니다.
296. 로비 인원이 바뀌면 활성 방향 미리보기는 갱신할 수 있지만, 런 시작 후 `activeDirections`는 다시 계산하지 않습니다.
297. 런 설정 화면에는 웨이브 겹치기 보상 모드, 희귀도 증가 모드, 카드 후보 수 증가 모드를 만들지 않습니다.
298. 직업 선택 화면은 필수 직업, 정답 조합, 자동 빌드 문구를 표시하지 않습니다.
299. 직업 중복은 MVP 기본 협동 밸런스에서는 허용하지 않습니다.
300. 준비 합의 문장은 투표 결과나 보상 보정이 아니라 파티 의도 기록으로만 저장합니다.
301. `run_state_locked` 이후 `playerCountAtStart`, `activeDirections`, `scalingProfileId`, `seed`는 변경할 수 없습니다.
302. 로비 방향 미리보기는 인원수별 활성 방향 표와 일치해야 합니다.
303. 비활성 방향은 로비 미리보기에서 어둡게 표시하되 위험 방향이나 추천 방어 방향으로 표시하지 않습니다.

새 런 준비 세부 검수:

- `setup_suggestion_slot`은 최대 2개만 표시하며 `canAutoApply: false`여야 합니다.
- `lobby_direction_preset`은 1인 동쪽, 2인 북쪽/동쪽, 3인 서쪽/북쪽/동쪽, 4인 사방과 일치해야 합니다.
- 준비 완료 후 시작 전 인원이 바뀌면 `readyPlayerIds`를 다시 확인해야 합니다.
- `party_intent_note`는 비워도 시작 가능하며, 보상, 난이도, 활성 방향, 직업, 카드, 아티팩트를 바꿀 수 없습니다.
- `run_config_lock_snapshot`은 `playerCountAtStart`, `activeDirections`, `scalingProfileId`, `seed`, `selectedMode`, `classIdsByPlayer`를 포함해야 합니다.
- 역할 힌트는 대응 태그만 표시하고 필수 직업, 정답 조합, 특정 카드 강요 문구를 만들 수 없습니다.
- 런 길이 카드는 예상 시간과 완료 기준만 보여주며 보상 차이를 만들 수 없습니다.

304. 중단과 재개는 `session_resume_flow`를 사용해야 합니다.
305. 안정 저장점은 하루 시작, 보스 처치 후, 상점 진입, 아티팩트 선택 완료 중 하나여야 합니다.
306. 전투 중 완전 저장은 MVP 콘텐츠와 UI에 포함하지 않습니다.
307. 보류 모드 직업은 구조물을 유지하지만 개인 카드, 마나, 버리기 횟수를 자동 소비할 수 없습니다.
308. MVP에서 AI는 이탈 플레이어의 카드를 대신 사용하지 않습니다.
309. 재접속 또는 장기 이탈은 보상, 골드, 카드 후보 수, 희귀도, 웨이브 보상 배율을 바꾸지 않습니다.
310. 재개 중 현재 접속 인원으로 `playerCountAtStart`, `activeDirections`, `scalingProfileId`, `WaveSpawnPlan.directions`를 다시 계산하지 않습니다.
311. 복귀 플레이어는 같은 런, 같은 직업, 같은 저장 기준으로만 이어받습니다.
312. 진행 중 투표에 복귀한 플레이어는 새 투표를 만들지 않고 남은 시간으로 합류해야 합니다.
313. 재개 UI에서 비활성 방향은 위험 방향, 추천 방어 방향, 보상 방향으로 표시할 수 없습니다.
314. 접근성과 연출 옵션은 `accessibility_presentation_options`를 사용해야 합니다.
315. 접근성 옵션은 개인 화면/소리 표현만 바꾸며 `RunState`, `WaveSpawnPlan`, 보상, 카드 후보, 적 수, 활성 방향을 바꾸지 않습니다.
316. 접근성 옵션 문구에 쉬운 모드, 보상 증가, 희귀도 증가, 카드 후보 증가, 적 약화 표현을 쓰지 않습니다.
317. 화면 흔들림을 줄여도 보스 치명 예고, 경고 위치, 타이머, 타겟 하이라이트는 유지해야 합니다.
318. 저주파 보스음을 줄여도 자막, 시각 경고, 핑 로그로 같은 정보를 제공해야 합니다.
319. 경로 상시 표시, 적 윤곽선, 보스 부위 강조는 자동 타겟팅이나 추천 빌드처럼 표시하지 않습니다.
320. 위험, 방향, 소유권, 핑 종류는 색상 하나로만 구분할 수 없습니다.
321. 공포 연출은 경로, 타겟, 보스 패턴, 기지 위험 정보를 숨기거나 왜곡할 수 없습니다.
322. 접근성 미리보기는 카드, 경로, 보스 경고, 핑을 모두 포함해야 합니다.
323. 유혈, 고어, 점프 스케어, UI 판독성 고의 저하는 모든 연출 제작물에서 금지합니다.

## 제작 우선순위

MVP에서 반드시 먼저 제작할 콘텐츠:

324. `run_test_010`
325. 활성 방향 프리셋 4종
326. 인원수 스케일링 프로필 4종
327. `WaveSpawnPlan` 규칙 5종
328. 1~10일 웨이브 원본 데이터
329. 회색 행렬
330. 기본 공격 타워
331. 기본 바리케이드
332. 도발벽
333. 화염구
334. 원격 수리
335. 균열 망치
336. 웨이브 겹치기 UI
337. 침묵의 거상
338. 균열난 종

이 15개가 작동하면 인원수별 침공 방향, 미로 설계, 처치 기반 자원 펌핑, 첫 보스까지 한 번에 검증할 수 있습니다.
