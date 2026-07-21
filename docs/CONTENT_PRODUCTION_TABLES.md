# Content Production Tables

이 문서는 실제 콘텐츠 제작을 위한 목록입니다.

각 항목은 데이터화할 때 사용할 ID, 역할, MVP 포함 여부를 함께 정리합니다.

## 콘텐츠 수량 목표

| 분류 | MVP | 100일 풀런 | 출시 후보 |
| --- | ---: | ---: | ---: |
| 직업 | 4 | 4 | 4~6 |
| 직업별 카드 | 14종 | 24종 | 30종 이상 |
| 공용 카드 | 8종 | 16종 | 24종 이상 |
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
| 상점 세션 데이터 | 2종 | 20종 이상 | 30종 이상 |
| 텔레메트리 이벤트 | 8종 이상 | 14종 이상 | 20종 이상 |

## 런 기반 데이터 제작표

카드, 적, 보스보다 먼저 고정해야 하는 기반 데이터입니다.

이 표가 있어야 모든 전투 콘텐츠가 인원수별 침공 방향과 같은 기준으로 작동합니다.

### 런 모드

| ID | 이름 | MVP | 역할 |
| --- | --- | --- | --- |
| `run_test_010` | 10일 테스트 런 | 예 | 핵심 전투, 첫 보스, 웨이브 겹치기 검증 |
| `run_mvp_030` | 30일 MVP 런 | 예 | 봄 시즌 완주와 초반 성장 검증 |
| `run_standard_100` | 100일 표준 런 | 아니오 | 정식 목표 구조 |

### 활성 방향 프리셋

| ID | 플레이어 수 | 활성 방향 | 기본 강조 | MVP | 역할 |
| --- | ---: | --- | --- | --- | --- |
| `active_directions_players_1` | 1 | `east` | `east` | 예 | 솔로 조작 부담을 줄이는 단일 라인 |
| `active_directions_players_2` | 2 | `north`, `east` | `east` | 예 | 짧은 라인과 느린 라인의 기본 분담 |
| `active_directions_players_3` | 3 | `west`, `north`, `east` | `west` | 예 | 빠른 돌파 라인과 순회 지원 추가 |
| `active_directions_players_4` | 4 | `west`, `north`, `east`, `south` | `west` | 예 | 사방 협동 방어 |

활성 방향은 런 시작 시 `RunState`에 저장하고, 런 도중 접속 인원이 바뀌어도 다시 계산하지 않습니다.

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
| `new_run_setup_loop_6step` | 흐름 | 예 | 다음 런 제안, 인원/방향, 런 길이, 직업, 준비 합의, RunState 확정 |
| `setup_step_001_suggestion_review` | 준비 단계 | 아니오 | 결과/메타/도감에서 온 다음 런 제안 최대 2개 표시 |
| `setup_step_002_player_direction_preview` | 준비 단계 | 예 | 로비 인원수에 따른 활성 침공 방향 미리보기 |
| `setup_step_003_run_mode_select` | 준비 단계 | 예 | 10일 테스트, 30일 MVP, 100일 표준 런 선택 |
| `setup_step_004_class_select` | 준비 단계 | 예 | 직업 역할, 시작 덱, 파티 역할 빈틈 표시 |
| `setup_step_005_party_intent_confirm` | 준비 단계 | 아니오 | 이번 런에서 시험할 운영 한 줄 확인 |
| `setup_step_006_run_state_lock` | 준비 단계 | 예 | `playerCountAtStart`, `activeDirections`, `scalingProfileId`, `seed` 확정 |
| `ui_lobby_direction_preview` | 로비 UI | 예 | 활성/비활성 방향을 맵 미리보기에서 구분 |
| `ui_party_role_gap_hint` | 로비 UI | 아니오 | 부족한 역할 태그를 정답 강요 없이 표시 |
| `ui_run_intent_note` | 로비 UI | 아니오 | 파티가 이번 런의 실험 목표를 한 줄로 남김 |

## 중단/재개 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `session_resume_loop_6step` | 흐름 | 예 | 저장점, 끊김 감지, 직업 보류, 복귀 스냅샷, 장기 이탈, 재개 확정 |
| `resume_step_001_savepoint_create` | 재개 단계 | 예 | 안정 저장점 생성과 저장 완료 배지 |
| `resume_step_002_interrupt_detect` | 재개 단계 | 예 | 연결 끊김, 입력 없음, 호스트 응답 지연 구분 |
| `resume_step_003_role_reserve` | 재개 단계 | 예 | 이탈 플레이어 직업 보류와 개인 카드/마나 잠금 |
| `resume_step_004_snapshot_deliver` | 재개 단계 | 예 | 현재 일자, 웨이브, 투표, 손패, 구조물 소유권 전달 |
| `resume_step_005_long_absence_hold` | 재개 단계 | 예 | 2분 초과 장기 이탈을 다음 안정 저장점까지 보류 |
| `resume_step_006_resume_confirm` | 재개 단계 | 예 | 같은 플레이어가 같은 직업을 이어받음 |
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
| `card_guardian_front_swap` | 전열 교대 | 희귀 | 1 | 아니오 | 도발 위치 조정 |
| `card_guardian_crack_shield` | 균열 방패 | 희귀 | 2 | 아니오 | 피해 시 둔화 |
| `card_guardian_last_guard` | 마지막 수호 | 희귀 | 2 | 아니오 | 기지 저체력 방어 |
| `card_guardian_thorn_throne` | 가시 왕좌 | 영웅 | 3 | 아니오 | 전체 가시 빌드 |
| `card_guardian_unbroken_gate` | 불굴의 성문 | 영웅 | 4 | 아니오 | 보스 저지 |
| `card_guardian_heavy_vow` | 무거운 서약 | 저주 | 0 | 아니오 | 위험한 마나 |

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
| `card_architect_delayed_charge` | 지연 폭약 | 희귀 | 1 | 아니오 | 능동 폭파 |
| `card_architect_slippery_debris` | 미끄러운 잔해 | 희귀 | 1 | 아니오 | 잔해 둔화 |
| `card_architect_reinforced_blueprint` | 보강 설계도 | 희귀 | 2 | 아니오 | 구조물 체력 |
| `card_architect_chain_collapse` | 연쇄 붕괴 | 영웅 | 3 | 아니오 | 폭발 연쇄 |
| `card_architect_inverted_path` | 뒤집힌 통로 | 영웅 | 3 | 아니오 | 경로 교란 |
| `card_architect_overbuilt` | 무리한 증축 | 저주 | 0 | 아니오 | 빠른 재건 |

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
| `card_elementalist_rewind_gust` | 되감는 돌풍 | 희귀 | 2 | 아니오 | 큰 넉백 |
| `card_elementalist_overcharged_bolt` | 과충전 번개 | 희귀 | 2 | 아니오 | 연쇄 처치 |
| `card_elementalist_elemental_rift` | 원소 균열 | 희귀 | 1 | 아니오 | 광역 취약 |
| `card_elementalist_eye_of_stillness` | 정지의 눈 | 영웅 | 3 | 아니오 | 대형 제어 |
| `card_elementalist_storm_ritual` | 낙뢰 의식 | 영웅 | 4 | 아니오 | 전장 피해 |
| `card_elementalist_forbidden_lantern` | 금지된 등불 | 저주 | 1 | 아니오 | 보스 특화 |

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
| `card_tinkerer_emergency_wiring` | 긴급 배선 | 희귀 | 0 | 아니오 | 오라 위험 강화 |
| `card_tinkerer_preheater` | 예열 장치 | 희귀 | 2 | 아니오 | 웨이브 초반 화력 |
| `card_tinkerer_auto_extinguisher` | 자동 소화 | 희귀 | 1 | 아니오 | 과부하 안정 |
| `card_tinkerer_resonance_amp` | 공명 증폭기 | 영웅 | 3 | 아니오 | 오라 공유 |
| `card_tinkerer_reassembly_machine` | 재조립 기계 | 영웅 | 4 | 아니오 | 구조물 복구 |
| `card_tinkerer_risky_mod` | 위험한 개조 | 저주 | 0 | 아니오 | 위험 화력 |

### 공용

| ID | 이름 | 희귀도 | 비용 | MVP | 역할 |
| --- | --- | --- | ---: | --- | --- |
| `card_common_reorganize` | 재정비 | 일반 | 0 | 예 | 손패 정리 |
| `card_common_focus_fire` | 집중 사격 | 일반 | 1 | 예 | 우선 처치 |
| `card_common_emergency_repair` | 긴급 보수 | 일반 | 1 | 예 | 최소 수리 |
| `card_common_battlefield_cleanup` | 전장 수습 | 일반 | 1 | 예 | 붕괴 후 둔화 |
| `card_common_mana_convert` | 마나 전환 | 일반 | 0 | 예 | 버리기 연계 |
| `card_common_quick_hands` | 빠른 손놀림 | 일반 | 0 | 아니오 | 드로우/버리기 |
| `card_common_tactical_map` | 전술 지도 | 일반 | 1 | 아니오 | 예고 강화 |
| `card_common_temporary_turret` | 임시 포탑 | 일반 | 1 | 아니오 | 빈틈 보완 |
| `card_common_pressure_signal` | 압박 신호 | 희귀 | 1 | 아니오 | 집중 공격 |
| `card_common_reposition_line` | 방어선 재배치 | 희귀 | 2 | 아니오 | 구조물 이동 |
| `card_common_emergency_battery` | 비상 축전 | 희귀 | 0 | 아니오 | 손패 부족 보정 |
| `card_common_joint_operation` | 공동 작전 | 영웅 | 2 | 아니오 | 파티 드로우 |
| `card_common_silent_call` | 무음 호출 | 저주 | 0 | 아니오 | 위험한 템포 |

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

### 첫 10일 웨이브 6단계 제작표

첫 10일 웨이브는 아래 6단계를 반드시 따릅니다.

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

### 11~20일 운영 6단계 제작표

11~20일은 첫 보스 후 보상과 아티팩트 선택을 검증하는 첫 운영 루프입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `spring2_operation_loop_011_020` | 11~20일 | 예 | 첫 보상 체감, 우선순위, 작은 상점, 분담, 겹치기, 변형 보스 연결 |
| `spring2_phase_001_growth_check` | 11~12일 | 예 | 첫 보스 보상과 아티팩트 체감 확인 |
| `spring2_phase_002_priority_split` | 13~14일 | 예 | 방해형, 빠른 적, 저항형 우선순위 분리 |
| `spring2_phase_003_small_shop` | 15일 | 예 | 강점 강화와 약점 보완 중 하나를 고르는 작은 상점 |
| `spring2_phase_004_lane_role_split` | 16~17일 | 예 | 2방향 압박과 구조물 재검증 |
| `spring2_phase_005_stack_elite_forecast` | 18~19일 | 예 | 겹치기 안정 판단과 정예 예고 |
| `spring2_phase_006_variant_boss` | 20일 | 예 | 11~19일 실패 태그를 한 가지 되묻는 침묵의 거상 변형 |
| `spring2_direction_cap_rule` | 11~20일 | 예 | 1인은 동쪽만, 4인도 사방 동시 압박 금지 |
| `spring2_operation_choice_check` | 11~20일 | 아니오 | 15일 선택이 16~20일에서 실제로 검증되는지 기록 |

### 21~30일 MVP 협동 6단계 제작표

21~30일은 30일 MVP 런의 마지막 협동 시험입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `mvp30_coop_loop_021_030` | 21~30일 | 예 | 정예 타이밍, 방향 분담, 계절 전환, 여름 예고, 고밀도 리허설, 관측자 예고 연결 |
| `mvp30_phase_001_elite_timing` | 21일 | 예 | 검은 등짐 처치 타이밍 합의 |
| `mvp30_phase_002_lane_reassignment` | 22~24일 | 예 | 킬존 재설계, 도발 약화, 빠른 라인 분담 |
| `mvp30_phase_003_season_turn` | 25일 | 예 | 봄 마무리와 여름 대비 선택 |
| `mvp30_phase_004_summer_priority` | 26~27일 | 예 | 빠른 템포 속 정예/방해형 우선순위 |
| `mvp30_phase_005_density_rehearsal` | 28~29일 | 예 | 3웨이브 겹치기 위험 판단과 MVP 총정리 |
| `mvp30_phase_006_observer_preview` | 30일 | 예 | 활성 방향 안 후보 예고와 파티 분담 |
| `mvp30_direction_cap_rule` | 21~30일 | 예 | 1인은 동쪽만, 2인은 3방향 금지, 3인은 남쪽 금지, 4인은 사방 동시 금지 |
| `observer_preview_candidate_rule` | 30일 | 예 | 후보 방향은 반드시 활성 방향의 부분집합 |

### 31~40일 과열 운영 6단계 제작표

31~40일은 여름 규칙이 처음 본격화되는 구간입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `summer1_heat_loop_031_040` | 31~40일 | 아니오 | 과열 타일, 빠른 적, 냉각 정비, 과열 분담, 고열 리허설, 과열된 거상 연결 |
| `summer1_phase_001_hot_boost_intro` | 31~32일 | 아니오 | 과열 타일과 빠른 적 대응 학습 |
| `summer1_phase_002_hot_killzone` | 33~34일 | 아니오 | 뜨거운 킬존과 잿불 석공 달굼 판단 |
| `summer1_phase_003_cooling_shop` | 35일 | 아니오 | 수리, 체력, 빠른 대응 중 하나를 고르는 냉각 정비 |
| `summer1_phase_004_heat_split` | 36~37일 | 아니오 | 두 방향 과열 압박과 수리 효율 감소 |
| `summer1_phase_005_heat_stack_rehearsal` | 38~39일 | 아니오 | 과열 상태 겹치기 위험과 여름 1장 총정리 |
| `summer1_phase_006_overheated_colossus` | 40일 | 아니오 | 보스 열 자취와 구조물 붕괴 통제 |
| `summer1_direction_cap_rule` | 31~40일 | 아니오 | 1인은 동쪽만, 3인은 남쪽 금지, 4인도 사방 동시 압박 금지 |
| `overheat_tile_decision_check` | 31~40일 | 아니오 | 과열 타일 사용, 포기, 구조물 손실 이유 기록 |

### 41~50일 붕괴 운영 6단계 제작표

41~50일은 여름 2장의 구조물 손실 운영 구간입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `summer2_collapse_loop_041_050` | 41~50일 | 아니오 | 보스 후 재건, 표식 구조물, 보완 상점, 과열 회전, 붕괴 리허설, 관측자 강화형 연결 |
| `summer2_phase_001_rebuild_choice` | 41일 | 아니오 | 손상된 방어선 유지/철거 판단 |
| `summer2_phase_002_marked_collapse` | 42~43일 | 아니오 | 열톱니 표식 구조물 살림/버림 선택 |
| `summer2_phase_003_heatbreak_market` | 44~45일 | 아니오 | 빠른 적/파괴형 분산과 열차단 상점 보완 |
| `summer2_phase_004_rotation_forecast` | 46~47일 | 아니오 | 과열 지점 회전과 후보 방향 예고 분담 |
| `summer2_phase_005_break_stack_rehearsal` | 48~49일 | 아니오 | 파괴형 표식 상태의 겹치기 위험과 총정리 |
| `summer2_phase_006_observer_enhanced` | 50일 | 아니오 | 방향 후보, 과열 후보, 구조물 표식이 함께 있는 관측자 강화형 |
| `summer2_direction_cap_rule` | 41~50일 | 아니오 | 1인은 동쪽만, 2인은 서쪽 금지, 3인은 남쪽 금지, 4인은 사방 동시 금지 |
| `marked_structure_decision_check` | 42~50일 | 아니오 | 표식 구조물 저장/희생/후방 재건 판단 기록 |

### 51~60일 경로 재설계 6단계 제작표

51~60일은 가을 1장의 경로 변화 운영 구간입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `autumn1_path_loop_051_060` | 51~60일 | 아니오 | 낙엽 예고, 마나 방해, 오래 남는 잔해, 오라 분산, 무너진 종탑 연결 |
| `autumn1_phase_001_leaf_mute_intro` | 51~52일 | 아니오 | 낙엽 타일 경로 비용 변화와 가을의 묵자 우선순위 학습 |
| `autumn1_phase_002_debris_reroute` | 53~54일 | 아니오 | 오래 남는 잔해와 낙엽 우회에 맞춘 킬존 이동 |
| `autumn1_phase_003_fallen_path_market` | 55일 | 아니오 | 잔해 정리, 낙엽 예고, 수리 효율, 방해 저항 중 하나를 고르는 정비 |
| `autumn1_phase_004_aura_stack_risk` | 56~57일 | 아니오 | 오라 분산과 경로 변화 중 겹치기 위험 판단 |
| `autumn1_phase_005_mobile_killzone` | 58~59일 | 아니오 | 잔해와 낙엽으로 이동 킬존을 만들고 총정리 |
| `autumn1_phase_006_fallen_belltower` | 60일 | 아니오 | 무음 권역 속 오라/수리 약화와 분산/재집결 판단 |
| `autumn1_direction_cap_rule` | 51~60일 | 아니오 | 1인은 동쪽만, 2인은 북/동만, 3인은 남쪽 금지, 4인은 사방 동시 금지 |
| `leaf_path_decision_check` | 51~60일 | 아니오 | 낙엽 예고 확인, 킬존 이동/유지, 실패 이유 태그 기록 |

### 61~70일 우선순위 6단계 제작표

61~70일은 가을 2장의 방해형/정예 우선순위 운영 구간입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `autumn2_priority_loop_061_070` | 61~70일 | 아니오 | 종탑 후 재배치, 방해형/정예 우선순위, 수확 상점, 분산 판단, 종탑 변형 연결 |
| `autumn2_phase_001_post_tower_realign` | 61일 | 아니오 | 무음 권역 이후 방어선과 우선 처치 핑 위치 재정렬 |
| `autumn2_phase_002_mute_elite_timing` | 62~63일 | 아니오 | 가을의 묵자와 검은 등짐, 후미 정예 처치 타이밍 합의 |
| `autumn2_phase_003_leaf_harvest_market` | 64~65일 | 아니오 | 낙엽 교차 압박과 수확 상점 보완 |
| `autumn2_phase_004_split_stack_priority` | 66~67일 | 아니오 | 두 활성 방향의 서로 다른 위험 분담과 침묵 속 겹치기 판단 |
| `autumn2_phase_005_elite_debris_recap` | 68~69일 | 아니오 | 잔해 정예 라인과 가을 2장 총정리 |
| `autumn2_phase_006_belltower_variant` | 70일 | 아니오 | 무음 권역 중 약한 정예/방해형 동반 웨이브 우선순위 |
| `autumn2_direction_cap_rule` | 61~70일 | 아니오 | 1인은 동쪽만, 2인은 북/동만, 3인은 남쪽 금지, 4인은 사방 동시 금지 |
| `priority_target_decision_check` | 62~70일 | 아니오 | 방해형/정예/보스 부위 중 먼저 본 대상과 변경 이유 기록 |

### 71~80일 공간 압박 6단계 제작표

71~80일은 겨울 1장의 설치 공간 축소 운영 구간입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `winter1_space_loop_071_080` | 71~80일 | 아니오 | 첫 서리, 겨울 껍질, 해동/이전 정비, 결빙 증가, 공간 겹치기, 겨울의 문 예고형 연결 |
| `winter1_phase_001_first_frost_husk` | 71~72일 | 아니오 | 결빙 예고와 겨울 껍질 지속 화력 학습 |
| `winter1_phase_002_narrow_slow_lane` | 73~74일 | 아니오 | 좁아진 방어선과 느린 대형 적 처리 |
| `winter1_phase_003_thaw_relocation_market` | 75일 | 아니오 | 해동, 구조물 이전, 대형 적 대응 중 하나를 고르는 정비 |
| `winter1_phase_004_full_winter_repair` | 76~77일 | 아니오 | 결빙 증가와 얼어붙은 수리 효율 판단 |
| `winter1_phase_005_space_stack_recap` | 78~79일 | 아니오 | 설치 공간 부족 상태의 겹치기 위험과 겨울 1장 총정리 |
| `winter1_phase_006_winter_gate_preview` | 80일 | 아니오 | 겨울의 문 예고형으로 임시 결빙 권역과 후방 이전 학습 |
| `winter1_direction_cap_rule` | 71~80일 | 아니오 | 1인은 동쪽만, 2인은 북/동만, 3인은 남쪽 금지, 4인은 사방 동시 금지 |
| `frost_space_decision_check` | 71~80일 | 아니오 | 결빙 예고 확인, 구조물 이전/해동, 남은 설치 공간 기록 |

### 81~90일 최종 이전 6단계 제작표

81~90일은 겨울 2장의 보스 압력 타일과 마지막 킬존 이전 운영 구간입니다.

| ID | 적용 일자 | MVP | 역할 |
| --- | --- | --- | --- |
| `winter2_pressure_loop_081_090` | 81~90일 | 아니오 | 문 뒤 재정비, 압력 타일 학습, 재설계 상점, 압력 회전, 마지막 킬존, 겨울의 문 연결 |
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
| `tile_frost_warning` | 결빙 예고 | 71일 | 아니오 | 준비 단계 전에 얼 구역 표시 |
| `tile_temporary_frost` | 임시 결빙 권역 | 80일 | 아니오 | 겨울의 문 예고형이 짧게 얼리는 설치 권역 |
| `tile_boss_pressure` | 보스 압력 타일 | 82일 | 아니오 | 예고된 설치 권역의 새 설치 제한과 구조물 효율 감소 |
| `tile_pressure_warning` | 압력 권역 예고 | 82일 | 아니오 | 보스 압력 타일이 생길 위치와 지속 시간 표시 |
| `tile_long_pressure_zone` | 장기 압력 권역 | 97일 | 아니오 | 최종 보스 단계 동안 유지되는 강한 설치 권역 압박 |

## 보스 제작표

| ID | 이름 | 시점 | MVP | 핵심 압박 |
| --- | --- | ---: | --- | --- |
| `boss_silent_colossus` | 침묵의 거상 | 10일 | 예 | 느린 접근, 구조물 파괴 |
| `boss_silent_colossus_variant` | 침묵의 거상 변형 | 20일 | 예 | 부위 추가, 드로우 방해 |
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
| `boss_phase_plan_silent_colossus_010` | 전투 흐름 | 10일 첫 보스 6단계 | 예 | 입장, 다리부, 짓누르기, 등불부, 마지막 접근, 결과 연결 |
| `boss_phase_010_entry_warning` | 단계 | 입장 예고 | 예 | 보스 경로 폭과 추천 다리부 타겟 표시 |
| `boss_phase_010_legs_focus` | 단계 | 다리부 학습 | 예 | 보스를 죽이기 전에 늦추는 판단 학습 |
| `boss_phase_010_crush_choice` | 단계 | 짓누르기 선택 | 예 | 지킬 구조물과 버릴 구조물 선택 |
| `boss_phase_010_lantern_choice` | 단계 | 등불부 선택 | 예 | 드로우 약화 원인과 방해 부위 처리 |
| `boss_phase_010_last_reach` | 단계 | 마지막 접근 | 예 | 기지 도달 5초 최후 대응 |
| `boss_phase_010_result_bridge` | 단계 | 결과 연결 | 예 | 실패 원인, 아티팩트, 상점, 11일 예고 연결 |
| `boss_companion_policy_silent_colossus_010` | 동반 웨이브 규칙 | 첫 보스 약한 시야 테스트 | 예 | 활성 방향 안에서 최대 1~2개 약한 압박만 허용 |
| `boss_role_check_silent_colossus_010` | 역할 체크 | 첫 보스 직업별 대응 | 예 | 4직업이 각자 다른 방식으로 보스를 늦추는지 확인 |

### 사계의 관측자 예고형 하위 제작표

| ID | 분류 | 이름 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `boss_part_observation_core_preview` | 부위 | 관측핵 예고형 | 예 | 살아 있으면 다음 웨이브 예고가 짧게 흐려짐 |
| `boss_pattern_blurred_observation_preview` | 패턴 | 흐린 관측 | 예 | 활성 방향 안 후보 2개를 보여준 뒤 실제 방향 확정 |
| `boss_pattern_season_eye_preview` | 패턴 | 계절의 눈 예고형 | 예 | 26~29일 빠른 템포 웨이브를 약하게 동반 |
| `boss_ui_observer_candidate_direction` | UI | 후보 방향 예고 | 예 | 후보가 모두 활성 방향 안에 있음을 표시 |
| `boss_phase_plan_observer_preview_030` | 전투 흐름 | 30일 관측자 예고형 6단계 | 예 | 관측 예고, 관측핵, 첫 확정, 약한 동반, 두 번째 흐림, 결과 연결 |
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
| `boss_phase_plan_overheated_colossus_040` | 전투 흐름 | 40일 과열된 거상 6단계 | 아니오 | 열 경로 예고, 첫 열 자취, 냉각 다리부, 화로 짓누르기, 과열핵, 결과 연결 |
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
| `boss_phase_plan_observer_enhanced_050` | 전투 흐름 | 50일 관측자 강화형 6단계 | 아니오 | 이중 예고, 관측안, 첫 확정, 여름 렌즈, 표식 압박, 결과 연결 |
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
| `boss_ui_suppression_zone` | UI | 무음 권역 예고 | 아니오 | 약화될 설치 구역과 지속 시간을 표시 |
| `boss_phase_plan_fallen_belltower_060` | 전투 흐름 | 60일 무너진 종탑 6단계 | 아니오 | 권역 예고, 균열종, 낙엽 종소리, 떨어진 추, 잔해 공명, 결과 연결 |
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
| `boss_phase_plan_belltower_variant_070` | 전투 흐름 | 70일 무너진 종탑 변형 6단계 | 아니오 | 변형 예고, 첫 무음 권역, 동반 조합, 권역 중 우선순위, 마지막 재집결, 결과 연결 |
| `boss_phase_070_variant_warning` | 단계 | 변형 예고 | 아니오 | 추가점이 동반 웨이브 조합뿐임을 표시 |
| `boss_phase_070_first_suppression` | 단계 | 첫 무음 권역 | 아니오 | 60일에서 배운 분산/재집결을 재확인 |
| `boss_phase_070_companion_choice` | 단계 | 동반 조합 선택 | 아니오 | 정예/방해형/압박형 중 1개 약한 조합만 사용 |
| `boss_phase_070_priority_under_zone` | 단계 | 권역 중 우선순위 | 아니오 | 부위, 방해형, 정예 중 먼저 볼 대상 결정 |
| `boss_phase_070_last_regroup` | 단계 | 마지막 재집결 | 아니오 | 권역 종료 후 화력과 수리를 다시 모음 |
| `boss_phase_070_result_bridge` | 단계 | 결과 연결 | 아니오 | 71~80일 공간 압박 대비 태그 연결 |

### 겨울의 문 예고형 하위 제작표

| ID | 분류 | 이름 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `boss_part_gate_hinge` | 부위 | 문경첩 | 아니오 | 살아 있으면 임시 결빙 권역 지속 시간이 증가 |
| `boss_part_frost_chain` | 부위 | 서리 사슬 | 아니오 | 살아 있으면 다음 결빙 예고 시간이 짧아짐 |
| `boss_pattern_threshold_frost` | 패턴 | 문턱의 서리 | 아니오 | 예고된 설치 권역을 짧게 얼림 |
| `boss_pattern_slow_opening` | 패턴 | 느린 개문 | 아니오 | 보스가 천천히 접근하며 외곽 설치 공간을 압박 |
| `boss_ui_frost_zone_preview` | UI | 결빙 권역 예고 | 아니오 | 보스가 얼릴 설치 권역과 지속 시간을 표시 |
| `boss_phase_plan_winter_gate_preview_080` | 전투 흐름 | 80일 겨울의 문 예고형 6단계 | 아니오 | 서리 권역 예고, 느린 개문, 문경첩, 문턱의 서리, 서리 사슬, 결과 연결 |
| `boss_phase_080_frost_zone_warning` | 단계 | 서리 권역 예고 | 아니오 | 보스 경로와 첫 임시 결빙 권역 표시 |
| `boss_phase_080_slow_opening` | 단계 | 느린 개문 | 아니오 | 지속 화력과 둔화 유지 판단 |
| `boss_phase_080_gate_hinge` | 단계 | 문경첩 선택 | 아니오 | 임시 결빙 지속 시간을 줄일지 판단 |
| `boss_phase_080_threshold_frost` | 단계 | 문턱의 서리 | 아니오 | 예고된 설치 권역 결빙과 구조물 이전 판단 |
| `boss_phase_080_frost_chain` | 단계 | 서리 사슬 선택 | 아니오 | 다음 결빙 예고 시간을 늘릴지 판단 |
| `boss_phase_080_result_bridge` | 단계 | 결과 연결 | 아니오 | 81~90일 보스 압력 타일 대비 태그 연결 |

### 겨울의 문 하위 제작표

| ID | 분류 | 이름 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `boss_part_pressure_frame` | 부위 | 압력문틀 | 아니오 | 살아 있으면 보스 압력 권역 지속 시간이 증가 |
| `boss_part_frozen_threshold` | 부위 | 얼어붙은 문턱 | 아니오 | 살아 있으면 압력 권역 예고 시간이 짧아짐 |
| `boss_pattern_moving_pressure` | 패턴 | 이동하는 압력 | 아니오 | 보스 압력 타일이 활성 방향 안에서 순차 이동 |
| `boss_pattern_gate_breath` | 패턴 | 문의 숨 | 아니오 | 약한 겨울 껍질 동반 웨이브 |
| `boss_ui_pressure_path_preview` | UI | 압력 경로 예고 | 아니오 | 다음 압력 권역의 위치와 지속 시간을 표시 |
| `boss_phase_plan_winter_gate_090` | 전투 흐름 | 90일 겨울의 문 6단계 | 아니오 | 압력 경로 예고, 첫 이동 압력, 압력문틀, 문의 숨, 얼어붙은 문턱, 마지막 이전 |
| `boss_phase_090_pressure_path_warning` | 단계 | 압력 경로 예고 | 아니오 | 보스 경로와 첫 압력 권역 순서 표시 |
| `boss_phase_090_first_moving_pressure` | 단계 | 첫 이동 압력 | 아니오 | 전방 설치 구역 압력과 중간 화력 이전 판단 |
| `boss_phase_090_pressure_frame` | 단계 | 압력문틀 선택 | 아니오 | 압력 지속 시간을 줄일지 판단 |
| `boss_phase_090_gate_breath` | 단계 | 문의 숨 | 아니오 | 약한 겨울 껍질 동반 웨이브와 대형 적 지연 |
| `boss_phase_090_frozen_threshold` | 단계 | 얼어붙은 문턱 선택 | 아니오 | 압력 예고 시간을 늘릴지 판단 |
| `boss_phase_090_last_relocation` | 단계 | 마지막 이전 | 아니오 | 최종 리허설 전 마지막 방어선 후보 확정 |

### 겨울의 문 완전체 하위 제작표

| ID | 분류 | 이름 | MVP | 역할 |
| --- | --- | --- | --- | --- |
| `boss_part_final_core` | 부위 | 문의 핵 | 아니오 | 살아 있으면 장기 압력 권역이 더 오래 유지 |
| `boss_part_last_chain` | 부위 | 마지막 사슬 | 아니오 | 살아 있으면 동반 웨이브 예고 시간이 짧아짐 |
| `boss_part_threshold_heart` | 부위 | 문턱 심장 | 아니오 | 살아 있으면 최종 단계 압력 권역 수 증가 |
| `boss_pattern_long_pressure` | 패턴 | 장기 압력 | 아니오 | 단계 종료까지 유지되는 압력 권역 생성 |
| `boss_pattern_final_breath` | 패턴 | 마지막 숨 | 아니오 | 약한 복합 동반 웨이브 |
| `boss_pattern_last_bastion` | 패턴 | 마지막 기지 | 아니오 | 남은 공간으로 최후 방어를 요구 |
| `boss_ui_final_phase_plan` | UI | 최종 단계 예고 | 아니오 | 각 단계의 압력 권역과 동반 웨이브를 미리 표시 |
| `boss_phase_plan_winter_gate_final_100` | 전투 흐름 | 100일 겨울의 문 완전체 6단계 | 아니오 | 입장 예고, 전방 장기 압력, 부위 집중, 약한 복합 동반, 마지막 이전, 마지막 기지 |
| `boss_phase_100_entry_warning` | 단계 | 입장 예고 | 아니오 | 첫 장기 압력 권역과 최종 방어선 후보 표시 |
| `boss_phase_100_front_long_pressure` | 단계 | 전방 장기 압력 | 아니오 | 전방 킬존 유지/포기 판단 |
| `boss_phase_100_part_focus` | 단계 | 부위 집중 | 아니오 | 문의 핵, 마지막 사슬, 문턱 심장 중 우선 대상 선택 |
| `boss_phase_100_companion_priority` | 단계 | 약한 복합 동반 | 아니오 | 방해형/정예/대형 적 중 먼저 끊을 대상 합의 |
| `boss_phase_100_last_relocation` | 단계 | 마지막 이전 | 아니오 | 남은 설치 공간으로 최종 방어선 이전 |
| `boss_phase_100_last_bastion` | 단계 | 마지막 기지 | 아니오 | 남은 카드, 마나, 아티팩트 집중 사용 |

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

### 성장 단계별 아티팩트 풀

| ID | 구간 | 역할 | 금지선 |
| --- | --- | --- | --- |
| `artifact_pool_foundation_010` | 10일 | 첫 운영 방향 선택 | 웨이브 겹치기 최대치 증가 제외 |
| `artifact_pool_branch_020_030` | 20~30일 | 빌드 방향 확정과 약점 보완 | 보상 증가형 아티팩트 제외 |
| `artifact_pool_pressure_040_050` | 40~50일 | 여름 속도, 과열, 구조물 손실 대응 | 순수 수치 상위호환 금지 |
| `artifact_pool_route_060_070` | 60~70일 | 경로 변화, 잔해, 방해형/정예 대응 | 비활성 방향 개방 금지 |
| `artifact_pool_winter_080_090` | 80~90일 | 결빙, 압력 타일, 후방 킬존 대응 | 새 아키타입 강제 금지 |
| `artifact_pool_final_095` | 95일 | 최종 보스 약점 보완 | 웨이브 겹치기 보상, 희귀도 보정 금지 |

### 아티팩트 선택/교체 제작 항목

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `artifact_choice_flow_6step` | 흐름 | 예 | 보스 결과, 다음 압박, 후보, 슬롯, 투표, 상점 연결 |
| `artifact_candidate_diversity_rule` | 후보 규칙 | 예 | 후보 3개가 서로 다른 운영 축을 제안하게 함 |
| `artifact_replacement_hint_tags` | 교체 태그 | 아니오 | 현재 핵심, 다음 압박 적합, 죽은 효과, 대가 위험 표시 |
| `artifact_keep_current_rule` | 슬롯 규칙 | 예 | 슬롯이 가득 찼을 때 현재 유지 선택 제공 |
| `artifact_late_pool_lock_rule` | 후반 풀 규칙 | 아니오 | 91일 이후 새 빌드 시작형 후보 제외 |
| `artifact_slot_cap_rule` | 슬롯 규칙 | 예 | 슬롯 증가 효과가 있어도 최대 4개 유지 |

## 보상과 상점 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `boss_reward_day_010_silent_colossus` | 보스 보상 | 예 | 골드 +35, 보스 파편 +1, 아티팩트 후보 3개 |
| `artifact_pool_first_boss` | 아티팩트 풀 | 예 | 첫 보스 후 기본 운영 방향 후보 |
| `shop_session_day_005_first_shop` | 상점 세션 | 예 | 카드 제거, 강화, 기지 보강을 처음 보여줌 |
| `shop_session_after_day_010` | 상점 세션 | 예 | 보스 후 7~8개 항목, 파티 구매 최대 2회 |
| `shop_session_after_day_020` | 상점 세션 | 아니오 | 첫 빌드 방향 확인, 카드 제거 본격화 |
| `shop_session_after_day_030` | 상점 세션 | 아니오 | MVP 덱 방향 확정과 여름 대비 |
| `shop_session_after_day_050` | 상점 세션 | 아니오 | 중간 점검, 아티팩트 슬롯 재검토 |
| `shop_session_after_day_070` | 상점 세션 | 아니오 | 고급 제거, 정예/방해형 대응 압축 |
| `shop_session_after_day_090` | 상점 세션 | 아니오 | 최종 보스 대응 카드와 아티팩트 교체 |
| `shop_session_day_095_final_market` | 상점 세션 | 아니오 | 새 빌드 시작 없이 마지막 약점 보완 |
| `maintenance_flow_6step` | 정비 흐름 | 예 | 전투 요약, 피해 진단, 개인 보상, 다음 압박, 파티 정비, 준비 확정 |
| `maintenance_diagnostic_tags` | 정비 태그 | 예 | 누수, 구조물 붕괴, 손패 막힘, 우선순위 실패 등을 상점 추천과 연결 |
| `shop_recommendation_rules_010` | 추천 규칙 | 예 | 11~14일 압박과 첫 보스 피해 진단을 연결 |
| `shop_timer_extension_rule` | 시간 규칙 | 예 | 연장 시 선택지 축소와 강제 구매 금지 |
| `shop_remove_card` | 상점 항목 | 예 | 덱 압축 |
| `shop_upgrade_card` | 상점 항목 | 예 | 자주 쓰는 카드 강화 |
| `shop_restore_base_5` | 상점 항목 | 예 | 기지 체력 5 회복 |
| `shop_structure_hp_upgrade` | 상점 항목 | 예 | 다음 10일 구조물 안정성 |
| `shop_one_shot_spell` | 상점 항목 | 예 | 위기 대응용 일회성 선택 |
| `shop_common_card` | 상점 항목 | 예 | 덱 빈틈 보완 |
| `shop_boss_shard_extra_artifact_peek` | 보스 파편 항목 | 예 | 보스 파편 1개로 아티팩트 후보 1개 추가 확인 |
| `shop_artifact_replace_discount` | 보스 파편 항목 | 아니오 | 슬롯 압박 이후 아티팩트 교체 비용 완화 |
| `shop_late_deck_trim_bundle` | 상점 항목 | 아니오 | 61일 이후 핵심 덱 압축 지원 |
| `shop_final_weakness_patch` | 상점 항목 | 아니오 | 95일 최종 약점 보완, 새 아키타입 시작 금지 |
| `shop_next_pressure_recommendation` | 추천 항목 | 예 | 11일 예고와 연결된 상점 추천 |

## 이벤트 제작표

| ID | 이름 | MVP | 선택 압박 |
| --- | --- | --- | --- |
| `event_cracked_storehouse` | 갈라진 저장고 | 예 | 골드와 기지 체력 교환 |
| `event_silent_pilgrim` | 침묵의 순례자 | 예 | 저주와 아티팩트 후보 |
| `event_fallen_workshop` | 무너진 공방 | 예 | 구조물 강화 vs 카드 제거 |
| `event_frozen_road` | 얼어붙은 길 | 아니오 | 방향별 웨이브 변화 |
| `event_old_bell` | 오래된 종소리 | 아니오 | 보스 보상 vs 보스 위험 |
| `event_buried_map` | 묻힌 지도 | 아니오 | 예고 강화 vs 골드 소비 |
| `event_broken_market` | 부서진 시장 | 아니오 | 싼 카드와 저주 위험 |
| `event_last_caravan` | 마지막 행상 | 아니오 | 회복과 아티팩트 교체 |

### 이벤트 패턴 제작 항목

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `event_flow_6step` | 흐름 | 예 | 등장 이유, 선택 공개, 소유권, 확정, 결과, 다음 압박 연결 |
| `event_choice_guardrails` | 규칙 | 예 | 숨은 패널티, 강제 저주, 비활성 방향 개방 금지 |
| `event_trigger_diagnostic_hooks` | 등장 조건 | 예 | 피해 진단 태그와 이벤트 등장을 약하게 연결 |
| `event_timeout_default_rule` | 시간 규칙 | 예 | 시간 초과 시 상태 보존 선택 적용 |
| `event_active_direction_modifier_rule` | 방향 규칙 | 예 | 이벤트가 웨이브를 바꿔도 활성 방향 안에서만 처리 |
| `event_choice_owner_rule` | 투표 규칙 | 예 | 개인, 파티, 혼합 선택의 처리 기준 |

## 예고 UI와 리포트 제작표

예고 UI는 플레이어를 놀라게 하는 장식이 아니라, 협동 판단을 맞추는 정보 장치입니다.

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `ui_wave_preview_cards` | 하루 시작 예고 | 예 | 실제 스폰 방향, 적 역할, 대응 태그를 3장 이하로 표시 |
| `ui_active_direction_frame` | 방향 표시 | 예 | 활성 방향과 비활성 방향을 명확히 구분 |
| `ui_enemy_role_icon_set` | 적 역할 아이콘 | 예 | 군집형, 돌파형, 파괴형, 방해형, 정예형을 빠르게 식별 |
| `ui_structure_mark_warning` | 구조물 위험 | 예 | 파괴 표식, 보스 짓누르기, 수리 우선순위를 표시 |
| `ui_stack_risk_reason` | 겹치기 투표 | 예 | 겹치기 위험 이유를 보상 문구 없이 표시 |
| `ui_hand_lock_warning` | 손패 경고 | 예 | 패 한도 초과와 드로우 손실을 하단 UI에서 표시 |
| `ui_post_wave_micro_report` | 웨이브 후 리포트 | 아니오 | 위험했던 방향과 사용한 대응을 1~2초로 요약 |
| `ui_defeat_analysis_cards` | 패배 분석 | 예 | 원인 1개와 보조 원인 최대 2개를 카드로 표시 |
| `ui_boss_critical_countdown` | 보스 치명 경고 | 예 | 기지 도달 후 즉시 패배 예고를 중앙 상단에 표시 |

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
| `ping_auto_warning_source` | 자동 핑 | 아니오 | 치명 경고가 만든 핑과 플레이어 핑을 구분 |

## 텔레메트리 제작표

텔레메트리는 밸런스를 고치기 위한 기록입니다.

플레이어에게 직접 보상으로 환산하지 않습니다.

| ID | MVP | 기록 목적 |
| --- | --- | --- |
| `telemetry_run_started` | 예 | `playerCountAtStart`, `activeDirections`, `scalingProfileId` 확정 기록 |
| `telemetry_wave_plan_created` | 예 | 원본 웨이브가 실제 `WaveSpawnPlan`으로 바뀐 결과 기록 |
| `telemetry_wave_preview_shown` | 예 | 예고 카드, 경고 문구, 겹치기 위험 등 표시 정보 기록 |
| `telemetry_wave_started` | 예 | 실제 시작 일자, 방향, 스케일링 결과 기록 |
| `telemetry_wave_stacked` | 예 | 겹친 웨이브 수와 시작 시점 변화 기록 |
| `telemetry_wave_completed` | 예 | 클리어 시간, 남은 기지 체력, 구조물 손실 기록 |
| `telemetry_wave_learning_phase_resolved` | 아니오 | 첫 10일 학습 단계, 강한 질문, 실제 대응 태그 기록 |
| `telemetry_first_wave_role_check` | 아니오 | 첫 10일 일자별 직업 대응 체크 통과 여부 기록 |
| `telemetry_chapter_phase_resolved` | 아니오 | 10일 챕터 안 운영 단계, 질문 태그, 실제 대응 태그 기록 |
| `telemetry_spring2_operation_choice_resolved` | 아니오 | 15일 작은 상점/보상 선택이 16~20일에서 검증됐는지 기록 |
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
| `telemetry_pressure_tile_decision_resolved` | 아니오 | 압력 예고 후 구조물 이전/포기/수리 유지와 남은 설치 공간 기록 |
| `telemetry_rear_killzone_shift_resolved` | 아니오 | 주 킬존이 어느 권역에서 어디로 옮겨졌는지와 안정화 여부 기록 |
| `telemetry_winter_gate_phase_started` | 아니오 | 90일 겨울의 문 단계, 압력 후보 권역, 남은 설치 공간, 경고 표시 기록 |
| `telemetry_first_boss_phase_started` | 아니오 | 첫 보스 6단계 중 어느 단계에 진입했는지와 표시 힌트 기록 |
| `telemetry_first_boss_role_check` | 아니오 | 첫 보스에서 직업별 기대 대응과 실제 대응 태그 기록 |
| `telemetry_first_boss_failure_cause_resolved` | 아니오 | 첫 보스 승패 후 주 원인, 보조 원인, 파괴 부위, 동반 웨이브 사용 기록 |
| `telemetry_combat_warning_raised` | 아니오 | 치명 경고, 구조물 표식, 손패 막힘 경고가 뜬 시점 기록 |
| `telemetry_combat_report_created` | 아니오 | 웨이브 후 리포트와 패배 분석 카드의 원인 태그 기록 |
| `telemetry_structure_lifecycle_summary` | 아니오 | 구조물 목적, 위험 태그, 파괴/생존/재건 결과 기록 |
| `telemetry_structure_rebuilt` | 아니오 | 같은 타일 재건, 후방 재건, 재건 정책 적용 기록 |
| `telemetry_ping_created` | 아니오 | 핑 유형, 출처, 대상, 연결된 경고 태그 기록 |
| `telemetry_ping_acknowledged` | 아니오 | 동의와 맡음 표시가 얼마나 빨리 붙는지 기록 |
| `telemetry_ping_resolved` | 아니오 | 핑이 행동으로 해소됐는지, 만료됐는지 기록 |
| `telemetry_tutorial_step_started` | 아니오 | 튜토리얼 단계, 학습 태그, 시작 시점 기록 |
| `telemetry_tutorial_step_completed` | 아니오 | 단계 완료 시간, 재시도 횟수, 도달 힌트 단계 기록 |
| `telemetry_onboarding_hint_shown` | 아니오 | 첫 10일 힌트 노출 횟수와 이유 기록 |
| `telemetry_first_session_checkpoint` | 아니오 | 1~10일 학습 체크포인트와 관찰 행동 기록 |
| `telemetry_status_effect_applied` | 아니오 | 상태이상 최종 배율, 대상 등급, 변환 효과 기록 |
| `telemetry_status_effect_resisted` | 아니오 | 저항 프로필과 UI 피드백 태그가 제대로 쓰였는지 기록 |
| `telemetry_structure_built` | 예 | 설치 위치와 라인별 미로 밀도 기록 |
| `telemetry_structure_destroyed` | 예 | 파괴 원인, 파괴 위치, 적 발묶기 시간 기록 |
| `telemetry_enemy_kill_summary` | 예 | 처치 기반 마나/드로우 펌핑량 기록 |
| `telemetry_run_failed` | 예 | 붕괴 방향, 실패 일자, 실패 직전 손패 상태 기록 |
| `telemetry_boss_part_destroyed` | 아니오 | 부위 파괴 타이밍과 보스 압박 완화량 기록 |
| `telemetry_card_reward_presented` | 아니오 | 첫 10일 보상 프로필, 후보 역할 태그, 제외 태그 기록 |
| `telemetry_card_reward_resolved` | 아니오 | 카드 선택, 거절, 후보 희귀도, 선택 소요 시간 기록 |
| `telemetry_early_deck_choice_resolved` | 아니오 | 1~10일 카드 선택이 직업 루프, 약점 보완, 골드 거절 중 어디에 속했는지 기록 |
| `telemetry_deck_growth_summary` | 아니오 | 10일 단위 덱 크기, 제거 수, 강화 수, 방치 카드 수 기록 |
| `telemetry_artifact_choice_presented` | 아니오 | 후보 풀, 운영 축 다양성, 장착 슬롯 상태 기록 |
| `telemetry_artifact_choice_resolved` | 아니오 | 후보 풀, 선택/교체 결과, 투표 시간, 교체 대상 기록 |
| `telemetry_artifact_replacement_resolved` | 아니오 | 현재 유지, 교체 대상, 교체 이유 태그 기록 |
| `telemetry_class_role_summary` | 아니오 | 직업별 구조물 설치, 카드 사용, 역할 수행 비율 기록 |
| `telemetry_synergy_triggered` | 아니오 | 도발 군집, 계획 붕괴, 보스 부위 집중 등 시너지 발생 기록 |
| `telemetry_enemy_role_pressure_summary` | 아니오 | 적 역할별 등장 횟수, 실패 방향, 대응 직업 분포 기록 |
| `telemetry_enemy_counter_used` | 아니오 | 특정 적 역할에 사용된 도발, 수리, 제어, 경로 변경, 집중 화력 기록 |
| `telemetry_party_role_gap` | 아니오 | 파티에 부족한 역할과 공용 카드/아티팩트 보완 기록 |
| `telemetry_shop_session_completed` | 아니오 | 상점 체류 시간, 확인한 항목 수, 시작된 투표 수 기록 |
| `telemetry_shop_recommendation_shown` | 아니오 | 피해 진단 태그, 다음 압박 태그, 추천 항목과 대안 확인 기록 |
| `telemetry_event_choice_presented` | 아니오 | 등장 이유, 선택지 수, 시간 초과 기본 선택 기록 |
| `telemetry_event_choice_resolved` | 아니오 | 선택 소유권, 투표 여부, 결과 태그와 다음 압박 연결 기록 |
| `telemetry_final_phase_started` | 아니오 | 최종 10일의 6단계 진입, 일자 범위, 핵심 압박 태그 기록 |
| `telemetry_final_rehearsal_phase_resolved` | 아니오 | 91~100일 각 단계의 해결 질문, 실패 질문, 새 시스템 금지 통과 여부 기록 |
| `telemetry_final_weakness_commitment_resolved` | 아니오 | 95일에 살린 축과 포기한 약점, 새 아키타입 차단 여부 기록 |
| `telemetry_winter_gate_final_phase_started` | 아니오 | 100일 겨울의 문 완전체 단계 시작, 압력 계획, 활성 방향, 금지 압력 태그 기록 |
| `telemetry_final_market_resolved` | 아니오 | 95일 마지막 상점의 선택 축과 포기한 약점 기록 |
| `telemetry_final_boss_phase_completed` | 아니오 | 최종 보스 단계별 압력 권역, 방어선 이전, 부위 파괴 기록 |
| `telemetry_final_result_reflection_started` | 아니오 | 최종 결과 회고 시작, 승패, 종료 일자, 플레이 시간, 활성 방향 기록 |
| `telemetry_decisive_moment_card_presented` | 아니오 | 결과 화면의 결정적 장면 카드 유형, 일자, 방향, 위험 태그 기록 |
| `telemetry_party_chronicle_saved` | 아니오 | 파티 기록 저장, 최종 방어선 태그, 다음 런 제안 기록 |
| `telemetry_post_run_meta_progression_started` | 아니오 | 결과 회고 후 메타 진행 시작, 학습 태그, 도달 구간 기록 |
| `telemetry_meta_unlock_resolved` | 아니오 | 해금 유형, 해금 이유, 파워 영향 여부 기록 |
| `telemetry_encyclopedia_entry_unlocked` | 아니오 | 적/보스 도감 항목과 공개된 정보 태그 기록 |
| `telemetry_training_scenario_unlocked` | 아니오 | 실패 태그와 연결된 훈련 장면 해금 기록 |
| `telemetry_next_run_prep_loaded` | 아니오 | 다음 런 제안, 관련 해금, 강제 직업/카드 여부 기록 |
| `telemetry_knowledge_revisit_started` | 아니오 | 도감/훈련장 재방문 시작 이유, 출처, 추천 항목 기록 |
| `telemetry_encyclopedia_entry_viewed` | 아니오 | 도감 항목 조회 시간, 항목 유형, 진입 출처 기록 |
| `telemetry_training_scenario_started` | 아니오 | 훈련 장면 시작, 연결 도감, 목표 학습 태그, 보상 비활성 여부 기록 |
| `telemetry_training_scenario_completed` | 아니오 | 훈련 시도 수, 사용 대응 태그, 제안 대응 태그 기록 |
| `telemetry_knowledge_revisit_to_run_linked` | 아니오 | 재방문 후 다음 런 제안 연결과 강제 빌드 적용 여부 기록 |
| `telemetry_new_run_setup_started` | 예 | 새 런 준비 출처, 다음 런 제안, 미리보기 인원수와 방향 기록 |
| `telemetry_lobby_active_direction_previewed` | 예 | 로비 인원수별 활성 방향 미리보기와 비활성 방향 흐림 표시 기록 |
| `telemetry_class_selection_resolved` | 예 | 플레이어별 직업 선택, 역할 태그, 추천/강제 여부 기록 |
| `telemetry_party_intent_confirmed` | 아니오 | 이번 런에서 시험할 운영 문장과 준비 완료 플레이어 기록 |
| `telemetry_run_state_locked` | 예 | 시작 시 확정된 `playerCountAtStart`, `activeDirections`, `scalingProfileId`, 시드 기록 |
| `telemetry_session_savepoint_created` | 예 | 안정 저장점 생성 시점, 일자, 페이즈 기록 |
| `telemetry_session_interrupt_detected` | 예 | 연결 끊김, 입력 없음, 호스트 지연의 발생 위치 기록 |
| `telemetry_player_role_reserved` | 예 | 보류된 직업, 개인 카드 잠금, AI 카드 사용 금지 여부 기록 |
| `telemetry_resume_snapshot_delivered` | 예 | 복귀 스냅샷과 진행 중 투표/방향 고정 상태 기록 |
| `telemetry_long_absence_resolved` | 예 | 2분 초과 이탈의 처리 방식과 저장점 기록 |
| `telemetry_session_resume_confirmed` | 예 | 같은 RunState와 같은 직업으로 복귀했는지 기록 |
| `telemetry_chapter_pacing_summary` | 아니오 | 10일 챕터별 소요 시간, 겹치기 횟수, 기지 피해 기록 |
| `telemetry_fatigue_check_recorded` | 아니오 | 30/60/90/100일 또는 상점 직후 주관 피로도 기록 |
| `telemetry_idle_time_summary` | 아니오 | 보상 정산, 상점, 웨이브 대기에서 발생한 비전투 시간 기록 |
| `telemetry_run_pacing_summary` | 아니오 | 풀런 총 시간, 가장 긴 챕터, 가장 긴 상점, 최종 피로도 기록 |

## 최종 10일 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `final_phase_loop_6step` | 흐름 | 아니오 | 91~100일을 점검, 약점 확인, 마지막 상점, 이전, 리허설, 최종 보스로 구성 |
| `final_rehearsal_loop_091_100` | 흐름 | 아니오 | 최종 10일 전체를 6단계 리허설 데이터로 묶음 |
| `final_phase_001_last_line_check` | 단계 | 아니오 | 91일 남은 구조물, 손패, 아티팩트, 후방 킬존 후보 확인 |
| `final_phase_002_weakness_recheck` | 단계 | 아니오 | 92~94일 빠른 적, 자원 방해, 구조물 파괴 약점 재확인 |
| `final_phase_003_last_market` | 단계 | 아니오 | 95일 마지막 상점과 포기한 약점 기록 |
| `final_phase_004_final_relocation` | 단계 | 아니오 | 96~97일 장기 압력 예고와 최종 방어선 이전 |
| `final_phase_005_last_stack_rehearsal` | 단계 | 아니오 | 98~99일 보상 없는 겹치기 판단과 새 요소 없는 리허설 |
| `final_phase_006_winter_gate_final` | 단계 | 아니오 | 100일 겨울의 문 완전체와 최종 방어선 유지 |
| `final_market_day_095_rule` | 상점 규칙 | 아니오 | 마지막 상점에서 큰 파티 구매 최대 2회와 포기한 약점 기록 |
| `final_weakness_commitment_check` | 검증 | 아니오 | 95일 구매 후에도 남는 약점이 기록되는지 확인 |
| `final_boss_phase_loop` | 보스 흐름 | 아니오 | 겨울의 문 완전체를 입장, 전방 압력, 부위 집중, 동반 웨이브, 마지막 이전, 최후 압박으로 운영 |
| `final_result_summary` | 결과 화면 | 아니오 | 마지막 킬존, 핵심 구조물, 최종 카드/아티팩트 역할 요약 |
| `final_result_reflection_loop_6step` | 결과 흐름 | 아니오 | 결과 확정, 마지막 방어선, 선택 회수, 결정적 장면, 다음 런 제안, 파티 기록 저장 |
| `result_step_001_outcome_lock` | 결과 단계 | 아니오 | 승리/패배/도달 일자/플레이 시간 확정 |
| `result_step_002_last_bastion_summary` | 결과 단계 | 아니오 | 마지막 킬존, 방어선 이전 횟수, 오래 버틴 구조물 표시 |
| `result_step_003_commitment_recall` | 결과 단계 | 아니오 | 95일 포기한 약점과 마지막 상점 선택 회수 |
| `result_step_004_decisive_moments` | 결과 단계 | 아니오 | 결정적 장면 카드 최대 3장 표시 |
| `result_step_005_next_run_suggestion` | 결과 단계 | 아니오 | 다음 런에서 바꿔볼 운영 1~2개 제안 |
| `result_step_006_party_chronicle_save` | 결과 단계 | 아니오 | 파티 조합, 아티팩트, 마지막 방어선 태그 저장 |
| `ui_final_bastion_map` | 결과 UI | 아니오 | 마지막 방어선과 압력 권역을 미니맵으로 표시 |
| `ui_decisive_moment_cards` | 결과 UI | 아니오 | 개인 책임 없는 전장 사건 카드 표시 |
| `ui_next_run_suggestions` | 결과 UI | 아니오 | 정답 빌드가 아닌 운영 변화 제안 표시 |
| `party_chronicle_card` | 기록 | 아니오 | 파티의 최종 조합과 회고 태그 저장 |
| `final_no_new_system_rule` | 금지선 | 아니오 | 99~100일에 새 적/새 규칙/새 아키타입 시작 금지 |

## 런 이후 메타 진행 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `post_run_meta_loop_6step` | 흐름 | 아니오 | 런 기록 수집, 학습 태그, 정보/훈련 해금, 선택지 해금, 다음 런 준비, 프로필 저장 |
| `meta_step_001_run_record_collect` | 메타 단계 | 아니오 | 도달 일자, 만난 적, 보스 부위, 마지막 방어선 태그 수집 |
| `meta_step_002_learning_tag_summary` | 메타 단계 | 아니오 | 반복 실패 원인, 포기한 약점, 자주 쓴 대응 태그 정리 |
| `meta_step_003_info_training_unlock` | 메타 단계 | 아니오 | 적 도감, 보스 기록, 훈련 장면 해금 |
| `meta_step_004_choice_pool_unlock` | 메타 단계 | 아니오 | 새 카드/아티팩트/외형 후보 해금 |
| `meta_step_005_next_run_prep` | 메타 단계 | 아니오 | 다음 런에서 시도할 운영 1~2개 연결 |
| `meta_step_006_profile_save` | 메타 단계 | 아니오 | 프로필 해금 상태와 파티 연대기 저장 |
| `profile_state_unlock_store` | 저장 | 아니오 | 카드 풀, 아티팩트 풀, 도감, 훈련, 외형 해금 저장 |
| `encyclopedia_entry_enemy_role` | 도감 | 아니오 | 적 역할, 저항, 대응 태그 정보 제공 |
| `encyclopedia_entry_boss_pattern` | 도감 | 아니오 | 보스 부위와 패턴 기록 제공 |
| `training_scenario_from_failure_tag` | 훈련 | 아니오 | 패배/회고 태그와 연결된 짧은 재방문 장면 |
| `cosmetic_unlock_non_power` | 외형 | 아니오 | 기지, 카드, 타워 외형처럼 밸런스에 영향 없는 보상 |

## 도감/훈련장 재방문 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `knowledge_revisit_loop_6step` | 흐름 | 아니오 | 재방문 이유, 대상 선택, 도감 카드, 훈련 장면, 대응 비교, 다음 런 연결 |
| `knowledge_step_001_reason_card` | 재방문 단계 | 아니오 | 패배 원인, 결과 회고, 메타 해금, 처음 만난 적 중 이유 1개 표시 |
| `knowledge_step_002_target_select` | 재방문 단계 | 아니오 | 적, 보스 부위, 구조물, 상태이상, 겹치기, 직업 역할 중 대상 선택 |
| `knowledge_step_003_compact_entry` | 재방문 단계 | 아니오 | 행동, 저항, 대응 태그, 피해야 할 오해를 3줄 요약 |
| `knowledge_step_004_micro_training` | 재방문 단계 | 아니오 | 30~60초 안에 단일 학습 태그만 시험 |
| `knowledge_step_005_response_compare` | 재방문 단계 | 아니오 | 사용한 대응과 다른 가능성 최대 2개 비교 |
| `knowledge_step_006_run_link` | 재방문 단계 | 아니오 | 새 런 준비, 즐겨찾기, 관련 도감 저장 연결 |
| `encyclopedia_entry_status_response` | 도감 | 아니오 | 상태이상 저항과 약화 변환 설명 |
| `encyclopedia_entry_wave_stack_tempo` | 도감 | 예 | 웨이브 겹치기가 보상 없는 템포 선택임을 설명 |
| `training_scenario_runner_slowdown` | 훈련 | 예 | 빠른 적을 둔화/도발/넉백으로 늦추는 장면 |
| `training_scenario_breaker_rebuild` | 훈련 | 예 | 표식 구조물을 살리거나 버리고 후방 재건하는 장면 |
| `training_scenario_disruptor_priority` | 훈련 | 아니오 | 방해형 우선 처치와 핑 연결 장면 |
| `training_scenario_boss_part_focus` | 훈련 | 예 | 보스 부위를 먼저 보며 패턴을 약화하는 장면 |

## 튜토리얼/첫 세션 제작표

| ID | 분류 | MVP | 역할 |
| --- | --- | --- | --- |
| `tutorial_flow_6step` | 흐름 | 예 | 경로, 길막, 빠른 적, 파괴, 자원/겹치기, 보스 부위를 첫 10일과 연결 |
| `tutorial_step_001_path_tower` | 장면 | 예 | 경로 보기와 기본 타워 설치 |
| `tutorial_step_004_no_full_block` | 장면 | 예 | 완전 길막 불가와 대체 위치 피드백 |
| `tutorial_step_005_structure_break` | 장면 | 예 | 구조물 파괴, 잔해, 후방 재건 후보 학습 |
| `tutorial_step_007_wave_stack_tempo` | 장면 | 예 | 웨이브 겹치기가 보상 없는 템포 선택임을 학습 |
| `tutorial_step_008_mini_boss_part` | 장면 | 예 | 보스 부위 집중과 느리게 만드는 감각 학습 |
| `first_session_checkpoint_001_010` | 체크포인트 | 예 | 첫 10일 각 일자를 튜토리얼 6단계와 연결 |
| `onboarding_hint_escalation_rule` | 힌트 규칙 | 예 | 10/20/35/60초 힌트 단계와 자동 시연 제안 |
| `tutorial_revisit_from_defeat` | 패배 지원 | 아니오 | 첫 패배 후 관련 튜토리얼 장면으로 바로 이동 |

## 제작 검증 규칙

콘텐츠를 추가할 때 아래 규칙을 먼저 통과해야 합니다.

1. 활성 방향 프리셋은 1~4인용 4종을 반드시 유지합니다.
2. `scaling_players_1`부터 `scaling_players_4`까지는 활성 방향 프리셋과 1:1로 대응합니다.
3. `WaveData`는 `preferredDirections`와 `directionRole`만 가질 수 있고, 실제 스폰 방향은 `WaveSpawnPlan`에서 확정합니다.
4. `WaveSpawnPlan.directions`는 항상 `activeDirections`의 부분집합이어야 합니다.
5. 웨이브 겹치기는 예약된 `WaveSpawnPlan`을 앞당길 뿐, 보상이나 방향을 추가하지 않습니다.
6. 시간 경과 마나 회복, 처치 막타 보너스, 웨이브 겹치기 보상 증가 필드는 만들지 않습니다.
7. 아티팩트는 웨이브 겹치기 최대치를 늘릴 수 있지만, 겹치기 보상을 늘릴 수는 없습니다.
8. 이벤트와 보스가 방향 압박을 만들 때도 비활성 방향을 강제로 열지 않습니다.
9. 91일 이후 카드와 아티팩트 풀은 새 아키타입 시작보다 기존 빌드 마무리를 우선합니다.
10. 카드 보상 거절은 실패 정산이 아니라 골드 선택으로 기록합니다.
11. 직업 성장 데이터는 약점을 완전히 제거하는 효과를 만들지 않습니다.
12. 시너지 트리거는 한 직업 단독 해결이 아니라 최소 2개 역할의 시간/위치 상호작용으로 정의합니다.
13. 적 역할 대응 데이터는 최소 2개 이상의 유효 대응을 가져야 합니다.
14. 적 저항은 특정 직업의 핵심 역할을 완전히 무효화하지 않습니다.
15. 강한 적 역할 질문은 솔로 웨이브에서 1개, 일반 멀티 웨이브에서 2개를 넘기지 않습니다.
16. 예고 UI는 실제 `WaveSpawnPlan.directions`와 다른 방향을 위험 방향으로 표시하지 않습니다.
17. 겹치기 위험 UI에는 보상, 효율, 보너스 표현을 쓰지 않습니다.
18. 패배 분석 카드는 개인 책임이나 딜량 순위가 아니라 전장 원인과 다음 시도 제안을 보여줍니다.
19. 핑은 다른 플레이어의 카드 사용, 자원 사용, 구조물 조작을 자동 실행하지 않습니다.
20. 핑 텔레메트리는 개인 평가가 아니라 협동 요청의 읽힘과 해소 여부만 기록합니다.
21. 플레이어 직접 핑은 동시에 3개까지만 유지하고, 자동 경고 핑은 별도 출처로 표시합니다.
22. 상태이상은 일반 적을 제외한 주요 적을 영구 정지시키지 않습니다.
23. 보스 상태이상 저항은 완전 면역보다 약화 변환을 기본으로 합니다.
24. 저항형 적도 모든 CC를 완전히 무효화하지 않고, 어떤 대응이 약하게라도 통하는지 UI로 보여줍니다.
25. 구조물 파괴와 재건은 완전 길막, 보스 경로 차단, 스폰 적 고립을 만들 수 없습니다.
26. 회수와 재건 효과는 같은 구조물을 반복 파괴하는 무한 자원 루프가 되면 안 됩니다.
27. 수리와 자동 복구는 파괴형 적과 보스 패턴을 완전히 무효화하지 않습니다.
28. 상점 추천은 정답 표시가 아니라 피해 진단과 다음 압박을 연결하는 정렬 기준입니다.
29. 상점 시간 종료 시 강제 구매하지 않고, 구매 없이 넘어가는 선택을 허용합니다.
30. 파티 자원 투표는 동시에 1개만 열고, 보스 후 상점의 큰 파티 구매는 최대 2회로 제한합니다.
31. 이벤트 선택지는 2~3개로 제한하고, 일반 이벤트는 30~60초 안에 끝나야 합니다.
32. 이벤트 시간 종료 시 무작위 위험 선택을 하지 않고, 상태 보존 선택을 기본값으로 둡니다.
33. 이벤트 저주는 플레이어가 선택한 결과로만 들어갑니다.
34. 이벤트가 다음 웨이브를 바꿔도 비활성 방향을 적 스폰이나 필수 방어 압박으로 열지 않습니다.
35. 이벤트는 웨이브 겹치기 보상, 카드 후보 수, 카드 희귀도를 증가시키지 않습니다.
36. 아티팩트 후보 3개는 최소 2개 이상의 운영 축을 가져야 하며, 첫 보스 후보는 3개 축을 권장합니다.
37. 슬롯이 가득 찬 아티팩트 선택에서는 현재 유지 선택을 반드시 제공합니다.
38. 아티팩트 슬롯은 어떤 효과를 적용해도 4개를 넘지 않습니다.
39. 91일 이후 아티팩트 후보 풀은 새 아키타입 시작형보다 기존 빌드 마무리형을 우선합니다.
40. 아티팩트 교체 추천은 정답 표시가 아니라 다음 압박과 현재 빌드의 연결 태그로만 표시합니다.
41. 91~100일은 새 시스템 추가보다 기존 판단의 최종 리허설을 우선합니다.
42. 95일 마지막 상점은 모든 약점을 해결하는 만능 구매를 제공하지 않습니다.
43. 98일 마지막 겹치기 판단에는 보상, 희귀도, 추가 선택지 보너스를 붙이지 않습니다.
44. 99일은 새 적이나 새 타일 규칙 없이 최종 보스 전 리허설로 구성합니다.
45. 100일 보스의 장기 압력 권역은 경로 타일을 막거나 비활성 방향을 압박하지 않습니다.
46. 100일 보스는 모든 압박을 한 순간에 최대 강도로 겹치지 않습니다.
47. 튜토리얼은 한 장면에서 하나의 핵심 판단만 가르칩니다.
48. 첫 10일 세션의 새 정보는 튜토리얼 6단계 루프와 연결되어야 합니다.
49. 첫 10일에서 웨이브 겹치기는 보상 없이 템포 선택으로만 보여줍니다.
50. 첫 10일 패배 피드백은 플레이어 책임보다 다시 볼 튜토리얼 장면을 제안합니다.
51. 첫 10일 카드 보상 프로필은 후보 수 3장과 골드 거절 선택을 바꾸지 않습니다.
52. 첫 10일 보상 화면에는 같은 역할 태그 카드가 3장 모두 나오면 안 됩니다.
53. 첫 10일 보상은 직업 약점을 완전히 지우는 공용 카드를 제공하지 않습니다.
54. 웨이브 겹치기 횟수, 클리어 시간, 처치 수로 카드 희귀도나 후보 수를 보정하지 않습니다.
55. 첫 10일 웨이브는 하루에 강한 역할 질문을 1개만 던집니다.
56. 첫 10일의 새 적 등장일에는 강한 다방향 압박을 함께 쓰지 않습니다.
57. 1~4일은 모든 인원수에서 실제 스폰 방향을 1개로 제한합니다.
58. 1인은 1~10일 동안 동쪽 외 일반 웨이브를 만들지 않습니다.
59. 첫 10일 보스전은 3방향 이상 동시 압박을 사용하지 않습니다.
60. 첫 10일 웨이브 실패 리포트는 해당 일자의 `learningPhaseIndex`와 연결되어야 합니다.
61. 첫 보스 단계 계획은 정확히 6단계로 시작해야 합니다.
62. 첫 보스의 추천 첫 부위는 다리부지만, 본체 공격을 금지하거나 실패 처리하지 않습니다.
63. 첫 보스 부위 파괴는 전투 중 이점만 주고 추가 보스 파편이나 보상 후보를 주지 않습니다.
64. 첫 보스 동반 웨이브는 새 적 학습을 담당하지 않습니다.
65. 첫 보스 동반 웨이브는 활성 방향 안에서만 만들고, 1인은 동쪽만 사용합니다.
66. 첫 보스에는 3방향 이상 동시 압박, 사방 동시 보스전, 웨이브 겹치기 보상 문구를 붙이지 않습니다.
67. 11~20일 WaveData는 `chapterLoopId: spring2_operation_loop_011_020`와 `chapterPhaseIndex`를 가져야 합니다.
68. 11~20일은 1인에서 동쪽 외 일반 웨이브를 만들지 않습니다.
69. 11~20일은 4인에서도 사방 동시 압박을 기본값으로 쓰지 않습니다.
70. 15일 작은 상점은 첫 보스 후 상점보다 작아야 하며, 파티 자원 구매는 최대 1회 권장입니다.
71. 18일 겹치기 판단에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
72. 20일 침묵의 거상 변형은 빠른 등불, 짧은 예고, 약한 동반 웨이브 중 하나만 선택합니다.
73. 20일 변형 보스는 11~19일 실패 태그를 되묻되, 추가 보상 계산에 사용하지 않습니다.
74. 21~30일 WaveData는 `chapterLoopId: mvp30_coop_loop_021_030`와 `chapterPhaseIndex`를 가져야 합니다.
75. 21~30일 정예는 처치 타이밍 질문을 가져야 하며, 단순 체력벽으로 만들지 않습니다.
76. 21~30일 1인은 동쪽 외 일반 웨이브를 만들지 않습니다.
77. 21~30일 2인은 3방향 이상 동시 압박을 만들지 않습니다.
78. 21~30일 3인은 남쪽 일반 웨이브를 만들지 않습니다.
79. 21~30일 4인은 30일 전까지 사방 동시 압박을 기본값으로 쓰지 않습니다.
80. 28일 3웨이브 겹치기 시험에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
81. 30일 관측자 예고형의 후보 방향은 항상 `activeDirections`의 부분집합이어야 합니다.
82. 30일 관측자 예고형은 예고와 무관한 기습 방향을 만들지 않습니다.
83. 31~40일 WaveData는 `chapterLoopId: summer1_heat_loop_031_040`와 `chapterPhaseIndex`를 가져야 합니다.
84. 과열 타일은 활성 방향 설치 구역 안에서만 생성합니다.
85. 과열 타일은 보상 배율, 골드 증가, 희귀도 증가, 카드 후보 증가를 만들 수 없습니다.
86. 과열 타일은 순수 피해 함정이 아니라 공격 속도 이득과 구조물 위험을 함께 가져야 합니다.
87. 잿불 석공과 과열된 거상은 과열 생성 전에 예고 표시를 줘야 합니다.
88. 38일 과열 상태 겹치기에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
89. 40일 과열된 거상은 과열 피해와 강한 동반 웨이브를 동시에 최대치로 사용하지 않습니다.
90. 40일 과열된 거상 부위는 2개부터 시작하고, 4개 이상으로 늘리지 않습니다.
91. 41~50일 WaveData는 `chapterLoopId: summer2_collapse_loop_041_050`와 `chapterPhaseIndex`를 가져야 합니다.
92. 열톱니와 파괴형 표식은 실제 공격 전에 예고 시간을 가져야 합니다.
93. 표식 구조물은 반드시 파괴되는 대상이 아니라 살림/희생/후방 재건 선택지를 가져야 합니다.
94. 41~50일 1인은 동쪽 외 일반 웨이브를 만들지 않습니다.
95. 41~50일 2인은 서쪽 일반 웨이브를 만들지 않습니다.
96. 41~50일 3인은 남쪽 일반 웨이브를 만들지 않습니다.
97. 47일과 50일 후보 방향 예고는 항상 `activeDirections`의 부분집합이어야 합니다.
98. 48일 파괴형 겹치기 경고에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
99. 50일 관측자 강화형은 후보 밖 기습 스폰을 만들지 않습니다.
100. 50일 관측자 강화형은 예고 교란과 강한 파괴형 동반 웨이브를 동시에 과하게 쓰지 않습니다.
101. 51~60일 WaveData는 `chapterLoopId: autumn1_path_loop_051_060`와 `chapterPhaseIndex`를 가져야 합니다.
102. 낙엽 후보 타일은 항상 `activeDirections` 안에서만 생성해야 합니다.
103. 낙엽 변화는 전투 시작 전에 예고하고, 웨이브 중 변화는 최대 1회까지만 허용합니다.
104. 낙엽과 잔해가 모든 경로를 막을 수 있는 데이터에는 `routeReopenPolicyId`가 반드시 있어야 합니다.
105. 가을의 묵자는 마나 획득량을 낮출 수 있지만 마나 사용이나 획득을 완전히 봉쇄하지 않습니다.
106. 57일 경로 변화 중 겹치기 경고에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
107. 60일 무너진 종탑은 `boss_phase_plan_fallen_belltower_060`을 사용해야 합니다.
108. 60일 무음 권역은 예고 시간을 가지며, 오라와 수리 효율을 0으로 만들지 않습니다.
109. 60일 무너진 종탑은 비활성 방향에 무음 권역, 낙엽 변화, 동반 웨이브를 만들지 않습니다.
110. 60일 보스 클리어에 웨이브 겹치기 보상 증가를 붙이지 않습니다.
111. 61~70일 WaveData는 `chapterLoopId: autumn2_priority_loop_061_070`와 `chapterPhaseIndex`를 가져야 합니다.
112. 61~70일은 신규 적을 많이 추가하지 않고 기존 방해형/정예/낙엽/잔해 조합으로 우선순위를 만들어야 합니다.
113. 후미 정예 스폰에는 전투 전 예고 또는 스폰 순서 경고가 있어야 합니다.
114. 방해형과 정예를 동시에 투입할 때는 `disruptorEliteMixPolicyId`로 동시 과부하를 제한해야 합니다.
115. 61~70일 1인은 동쪽 외 일반 웨이브나 두 방향 우선순위 판단을 만들지 않습니다.
116. 61~70일 3인은 남쪽 정예, 방해형, 동반 웨이브를 만들지 않습니다.
117. 67일 침묵 속 겹치기 경고에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
118. 70일 무너진 종탑 변형은 `boss_phase_plan_belltower_variant_070`을 사용해야 합니다.
119. 70일 보스 변형은 새 부위, 새 패턴, 강한 동반 웨이브를 동시에 추가하지 않습니다.
120. 70일 보스 클리어에 웨이브 겹치기 보상 증가를 붙이지 않습니다.
121. 71~80일 WaveData는 `chapterLoopId: winter1_space_loop_071_080`와 `chapterPhaseIndex`를 가져야 합니다.
122. 결빙 후보 타일은 항상 `activeDirections` 안의 설치 타일이어야 하며 경로 타일을 포함하지 않습니다.
123. 결빙은 준비 단계 또는 전투 중 예고 후 적용되어야 하며, 웨이브 중 추가 결빙은 최대 1회입니다.
124. 결빙은 구조물을 즉시 삭제하거나 보상 배율, 골드 증가, 카드 후보 증가를 만들 수 없습니다.
125. 겨울 껍질은 체력만 높은 적이 아니라 지속 화력, 둔화, 도발, 잔해 중 하나 이상의 대응 태그를 가져야 합니다.
126. 71~80일 1인은 동쪽 외 결빙, 대형 적, 동반 웨이브를 만들지 않습니다.
127. 71~80일 3인은 남쪽 결빙, 대형 적, 동반 웨이브를 만들지 않습니다.
128. 78일 공간 축소 중 겹치기 경고에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
129. 80일 겨울의 문 예고형은 `boss_phase_plan_winter_gate_preview_080`을 사용해야 합니다.
130. 80일 보스는 90일/100일급 장기 공간 봉쇄나 구조물 예고 없는 삭제를 사용하지 않습니다.
131. 81~90일 WaveData는 `chapterLoopId: winter2_pressure_loop_081_090`와 `chapterPhaseIndex`를 가져야 합니다.
132. 보스 압력 후보 권역은 항상 `activeDirections` 안의 설치 권역이어야 하며 경로 타일을 포함하지 않습니다.
133. 보스 압력 타일은 예고 후 생성되어야 하며 구조물을 즉시 삭제하지 않습니다.
134. 보스 압력 타일은 보상 배율, 골드 증가, 카드 후보 증가, 카드 희귀도 증가를 만들 수 없습니다.
135. 81~90일 1인은 동쪽 외 압력 권역, 대형 적, 동반 웨이브를 만들지 않습니다.
136. 81~90일 3인은 남쪽 압력 권역, 대형 적, 동반 웨이브를 만들지 않습니다.
137. 87일 압력 중 겹치기 경고에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
138. 90일 겨울의 문은 `boss_phase_plan_winter_gate_090`을 사용해야 합니다.
139. 90일 보스는 100일 완전체처럼 지나간 권역을 장기 봉쇄하지 않습니다.
140. 90일 보스 클리어에 웨이브 겹치기 보상 증가를 붙이지 않습니다.
141. 91~100일 WaveData는 `chapterLoopId: final_rehearsal_loop_091_100`와 `chapterPhaseIndex`를 가져야 합니다.
142. 91~100일은 새 적, 새 타일, 새 상태이상, 새 카드 규칙 학습을 추가하지 않습니다.
143. 95일 마지막 상점은 모든 약점을 해결하지 않으며, 큰 파티 구매는 최대 2회까지만 허용합니다.
144. 95일 상점 종료 시 `abandonedWeaknessTags`가 반드시 기록되어야 합니다.
145. 98일 마지막 겹치기 판단에는 보상, 희귀도, 카드 후보 증가 문구를 붙이지 않습니다.
146. 99일은 새 규칙 튜토리얼 없이 최종 보스 전 리허설로 구성합니다.
147. 100일 겨울의 문 완전체는 `boss_phase_plan_winter_gate_final_100`을 사용해야 합니다.
148. 100일 장기 압력 권역은 `activeDirections` 안의 설치 권역에만 생성되며 경로 타일을 포함하지 않습니다.
149. 100일 보스는 모든 압박을 한 순간에 최대 강도로 겹치지 않습니다.
150. 100일 결과 요약은 마지막 킬존, 포기한 약점, 최종 방어선 이전 횟수를 포함해야 합니다.
151. 100일 결과 화면은 `final_result_reflection_loop_6step`을 사용해야 합니다.
152. 결과 화면의 결정적 장면 카드는 최대 3장까지만 표시합니다.
153. 결과 화면에는 개인 딜량 순위, 처치 순위, 개인 실수 소유자 필드를 만들지 않습니다.
154. 웨이브 겹치기 사용량은 보상 효율, 추가 보상, 희귀도 효율로 표시하지 않습니다.
155. 승리와 패배는 같은 결과 회고 구조를 사용합니다.
156. 다음 런 제안은 최대 2개이며, 정답 빌드나 필수 직업처럼 표시하지 않습니다.
157. 95일에 포기한 약점이 있으면 결과 화면에 `abandonedWeaknessTags`를 표시합니다.
158. 결정적 장면 카드의 방향은 `activeDirections` 밖을 위험 방향으로 표시할 수 없습니다.
159. 파티 기록에는 점수 랭킹보다 파티 조합, 아티팩트, 마지막 방어선 태그를 우선합니다.
160. 결과 화면은 플레이 성과를 추가 골드, 카드 후보, 아티팩트 후보 보상으로 환산하지 않습니다.
161. 런 이후 메타 진행은 `post_run_meta_loop_6step`을 사용해야 합니다.
162. 메타 진행은 공격력, 구조물 체력, 마나 회복량, 웨이브 보상 배율을 직접 올리지 않습니다.
163. 딜량, 처치 수, 웨이브 겹치기 횟수, 개인 실수 태그는 메타 해금량 증가 조건으로 쓰지 않습니다.
164. 메타 해금은 카드 풀, 아티팩트 풀, 도감, 훈련 장면, 외형처럼 선택지나 정보 중심이어야 합니다.
165. 새 카드/아티팩트 해금은 기존 풀을 난잡하게 만들지 않도록 역할 태그와 등장 구간을 가져야 합니다.
166. 다음 런 준비 제안은 최대 2개이며, 직업이나 카드를 강제하지 않습니다.
167. 도감 해금은 실제 만난 적/보스 또는 관련 실패 태그와 연결되어야 합니다.
168. 훈련 장면 해금은 패배/회고 태그와 연결되지만 필수 재교육처럼 강제하지 않습니다.
169. 외형 보상은 전투 수치나 보상 확률에 영향을 주지 않습니다.
170. 숙련 플레이어는 메타 해금 없이도 클리어 가능해야 합니다.
171. 도감/훈련장 재방문은 `knowledge_revisit_loop_6step`을 사용해야 합니다.
172. 재방문 제안은 패배 원인, 결과 회고, 메타 해금, 처음 만난 적 중 하나의 이유 태그를 가져야 합니다.
173. 훈련 장면은 하나의 `targetLearningTag`만 다루며, 여러 규칙을 한 번에 가르치지 않습니다.
174. 훈련 장면은 30~60초 안에 끝나야 하며 실패해도 바로 재시도하거나 나갈 수 있어야 합니다.
175. 훈련 장면은 실제 골드, 카드, 아티팩트, 메타 파워를 지급하지 않습니다.
176. 훈련 장면은 `activeDirections` 밖의 스폰이나 필수 방어 압박을 만들지 않습니다.
177. 도감 카드는 정답 빌드, 필수 직업, 강제 카드 추천을 표시하지 않습니다.
178. 대응 비교는 점수, 등급, 개인 평가가 아니라 대응 태그 차이만 보여줍니다.
179. 재방문 후 다음 런 연결은 즐겨찾기와 제안만 제공하고 자동 빌드를 적용하지 않습니다.
180. 도감/훈련장 완료 여부는 런 시작, 난이도, 보상 확률을 잠그거나 보정하지 않습니다.
181. 새 런 준비는 `new_run_setup_loop_6step`을 사용해야 합니다.
182. 다음 런 제안은 최대 2개이며 직업, 카드, 아티팩트, 활성 방향을 자동으로 바꾸지 않습니다.
183. 로비 인원이 바뀌면 활성 방향 미리보기는 갱신할 수 있지만, 런 시작 후 `activeDirections`는 다시 계산하지 않습니다.
184. 런 설정 화면에는 웨이브 겹치기 보상 모드, 희귀도 증가 모드, 카드 후보 수 증가 모드를 만들지 않습니다.
185. 직업 선택 화면은 필수 직업, 정답 조합, 자동 빌드 문구를 표시하지 않습니다.
186. 직업 중복은 MVP 기본 협동 밸런스에서는 허용하지 않습니다.
187. 준비 합의 문장은 투표 결과나 보상 보정이 아니라 파티 의도 기록으로만 저장합니다.
188. `run_state_locked` 이후 `playerCountAtStart`, `activeDirections`, `scalingProfileId`, `seed`는 변경할 수 없습니다.
189. 로비 방향 미리보기는 인원수별 활성 방향 표와 일치해야 합니다.
190. 비활성 방향은 로비 미리보기에서 어둡게 표시하되 위험 방향이나 추천 방어 방향으로 표시하지 않습니다.
191. 중단과 재개는 `session_resume_loop_6step`을 사용해야 합니다.
192. 안정 저장점은 하루 시작, 보스 처치 후, 상점 진입, 아티팩트 선택 완료 중 하나여야 합니다.
193. 전투 중 완전 저장은 MVP 콘텐츠와 UI에 포함하지 않습니다.
194. 보류 모드 직업은 구조물을 유지하지만 개인 카드, 마나, 버리기 횟수를 자동 소비할 수 없습니다.
195. MVP에서 AI는 이탈 플레이어의 카드를 대신 사용하지 않습니다.
196. 재접속 또는 장기 이탈은 보상, 골드, 카드 후보 수, 희귀도, 웨이브 보상 배율을 바꾸지 않습니다.
197. 재개 중 현재 접속 인원으로 `playerCountAtStart`, `activeDirections`, `scalingProfileId`, `WaveSpawnPlan.directions`를 다시 계산하지 않습니다.
198. 복귀 플레이어는 같은 런, 같은 직업, 같은 저장 기준으로만 이어받습니다.
199. 진행 중 투표에 복귀한 플레이어는 새 투표를 만들지 않고 남은 시간으로 합류해야 합니다.
200. 재개 UI에서 비활성 방향은 위험 방향, 추천 방어 방향, 보상 방향으로 표시할 수 없습니다.

## 제작 우선순위

MVP에서 반드시 먼저 제작할 콘텐츠:

1. `run_test_010`
2. 활성 방향 프리셋 4종
3. 인원수 스케일링 프로필 4종
4. `WaveSpawnPlan` 규칙 5종
5. 1~10일 웨이브 원본 데이터
6. 회색 행렬
7. 기본 공격 타워
8. 기본 바리케이드
9. 도발벽
10. 화염구
11. 원격 수리
12. 균열 망치
13. 웨이브 겹치기 UI
14. 침묵의 거상
15. 균열난 종

이 15개가 작동하면 인원수별 침공 방향, 미로 설계, 처치 기반 자원 펌핑, 첫 보스까지 한 번에 검증할 수 있습니다.
