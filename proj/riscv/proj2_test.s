#############################################
# proj2_simple_full_test.s
# - 5-stage SW-scheduled pipeline용 small/simple 통합 테스트
# - 커버 명령어:
#   add, addi, and, andi, lui, lw, xor, xori, or, ori,
#   slt, slti, sltiu, sll, srl, sra, sw, sub,
#   beq, bne, blt, bge, bltu, bgeu,
#   jal, jalr,
#   lb, lh, lbu, lhu,
#   slli, srli, srai,
#   auipc, wfi
# - 제약: hazard logic 없음 → RAW / load-use / control hazard 방지를 위해
#         producer → consumer 사이에 최소 3개의
#         addi x0,x0,0 (진짜 NOP) 또는 독립 명령어로 bubble 확보.
#############################################

    .text
    .globl _start

_start:
########################################
# 0. 주소 셋업 (lui + addi)  & 기본 메모리 테스트
########################################
    # x10 = base_src (buf_src)
    lui   x10, %hi(buf_src)      # 상위 20비트
    addi  x0,  x0, 0             # bubble 1
    addi  x0,  x0, 0             # bubble 2
    addi  x0,  x0, 0             # bubble 3
    addi  x10, x10, %lo(buf_src) # x10 = &buf_src
    addi  x0,  x0, 0             # bubble (다음 load까지 여유)

    # x11 = base_dst (buf_dst)
    lui   x11, %hi(buf_dst)
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x11, x11, %lo(buf_dst)
    addi  x0,  x0, 0

    ####################################
    # lw / sw 테스트 (word copy 2개)
    ####################################
    lw    x12, 0(x10)            # x12 = 0x11223344
    addi  x0,  x0, 0             # load-use bubble 1
    addi  x0,  x0, 0             # bubble 2
    addi  x0,  x0, 0             # bubble 3
    sw    x12, 0(x11)

    lw    x13, 4(x10)            # x13 = 0xAABBCCDD
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    sw    x13, 4(x11)

    ####################################
    # lb / lbu / lh / lhu 테스트
    # (buf_src의 0x11223344, 0xAABBCCDD 사용)
    ####################################
    lb    x14, 0(x10)            # sign-extend 0x44
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    lbu   x15, 1(x10)            # zero-extend 0x33
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    lh    x16, 0(x10)            # sign-extend 0x3344
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    lhu   x17, 2(x10)            # zero-extend 0x1122
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

########################################
# 1. ALU 기본 연산 (add/sub/and/or/xor 및 즉시형)
########################################
    addi  x1,  x0, 5             # x1 = 5
    addi  x2,  x0, 10            # x2 = 10
    addi  x3,  x0, -3            # x3 = -3
    addi  x4,  x0, 0x0F          # x4 = 0x0F

    addi  x0,  x0, 0             # WB 안정화
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    add   x5,  x1, x2            # x5 = 15
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    sub   x6,  x2, x1            # x6 = 5
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    and   x7,  x4, x1            # x7 = 0x05
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    or    x8,  x4, x1            # x8 = 0x0F | 0x05 = 0x0F
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    xor   x9,  x4, x1            # x9 = 0x0F ^ 0x05 = 0x0A
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    andi  x5,  x5, 0x0F          # andi test
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    ori   x6,  x6, 0x10          # ori test
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    xori  x7,  x7, 0x03          # xori test
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

########################################
# 2. 비교 / set-less-than 계열
########################################
    slt   x18, x1, x2            # 5 < 10 → x18 = 1
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    slti  x19, x1, 5             # 5 < 5 ? → 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    sltiu x20, x3, 1             # unsigned 비교 (-3 vs 1)
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

########################################
# 3. 쉬프트 연산 (reg & imm)
########################################
    addi  x21, x0, 1             # 0b0001
    addi  x22, x0, -8            # 음수 (sra/srai 확인용)
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    sll   x23, x21, x1           # x23 = 1 << 5 = 32
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    srl   x24, x23, x1           # x24 = 32 >> 5 = 1 (logical)
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    sra   x25, x22, x1           # arithmetic right shift of negative
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    slli  x26, x21, 3            # 1 << 3 = 8
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    srli  x27, x26, 2            # 8 >> 2 = 2
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    srai  x28, x22, 1            # arithmetic immediate shift
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

########################################
# 4. 분기 명령어 (beq/bne/blt/bge/bltu/bgeu)
########################################
    # 비교용 세트
    addi  x30, x0, 10
    addi  x31, x0, 10
    addi  x29, x0, 5
    addi  x18, x0, -1            # 0xFFFF_FFFF
    addi  x19, x0, 1
    addi  x20, x0, 0             # branch 결과 누적용

    addi  x0,  x0, 0             # WB 안정화
    addi  x0,  x0, 0
    addi  x0,  x0, 0

# BEQ taken
beq_test:
    beq   x30, x31, beq_ok
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
beq_ok:
    addi  x20, x20, 1            # x20 += 1
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

# BNE taken
bne_test:
    bne   x30, x29, bne_ok
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
bne_ok:
    addi  x20, x20, 2            # x20 += 2 → 3
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

# BLT / BGE (signed)
blt_test:
    blt   x29, x30, blt_ok       # 5 < 10
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
blt_ok:
    addi  x20, x20, 4            # +=4
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

bge_test:
    bge   x30, x29, bge_ok       # 10 >= 5
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
bge_ok:
    addi  x20, x20, 8            # +=8  (최종 15 기대)
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

# BLTU / BGEU (unsigned)
bltu_test:
    bltu  x19, x18, bltu_ok      # 1 < 0xFFFF_FFFF
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
bltu_ok:
    addi  x20, x20, 16
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

bgeu_test:
    bgeu  x18, x19, bgeu_ok      # 0xFFFF_FFFF >= 1
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
bgeu_ok:
    addi  x20, x20, 32           # 최종 x20 = 63 (0x3F)
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

########################################
# 5. auipc 테스트
########################################
    auipc x5, 0                  # x5 = 현재 PC
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    # auipc 결과는 그냥 waveform에서만 확인해도 됨

########################################
# 6. JAL / JALR 테스트 (LUI+ADDI로 jalr 타겟 구성)
########################################
    addi  x23, x0, 0             # jal 결과 마커
    addi  x25, x0, 0             # jalr 결과 마커
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

# JAL
jal_test:
    jal   x23, jal_target

jal_target:
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x23, x23, 1            # x23 += 1

    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

# JALR: 타겟 주소 = jalr_target 의 절대 주소
    lui   x24, %hi(jalr_target)
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x24, x24, %lo(jalr_target)
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    jalr  x25, 0(x24)

jalr_target:
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x25, x25, 1            # x25 += 1

########################################
# 7. 종료 (WFI / HALT)
########################################
end_prog:
    wfi                           # skeleton에서 opcode=0 → HALT로 처리

########################################
# 데이터 섹션 (메모리 테스트용)
########################################
    .data

buf_src:
    .word 0x11223344, 0xAABBCCDD   # load/store, lb/lbu/lh/lhu용 데이터

buf_dst:
    .space 8                       # 복사 대상