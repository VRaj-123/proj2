###############################################
# Proj1_mergesort_swpipe.s
# Bottom-up mergesort for software-scheduled pipeline
#  - No hardware interlocks
#  - Data / control hazards avoided by scheduling
###############################################

    .text
    .globl _start

# 레지스터 매핑:
# s0 = arr base
# s1 = tmp base
# s2 = N
# s3 = width
# t0 = left
# t1 = mid
# t2 = right
# t3 = i
# t4 = j
# t5 = k
# t6 = addr calc
# x10, x11 = arr[i], arr[j]
# x12–x17 = scratch (dummy / 복사용)

_start:
    # 주소 로딩은 lasw 사용 (내부에 필요한 nop 포함)
    lasw  s0, arr          # s0 = &arr[0]
    lasw  s1, tmp          # s1 = &tmp[0]

    li    s2, 16           # N = 16
    li    s3, 1            # width = 1

    # 파이프라인 안정화용 약간의 여유
    nop
    nop
    nop

###############################
# merge_pass: while (width < N)
###############################
merge_pass:
    # s3 (width)는 바로 위에서 갱신될 수 있으니
    # 이전 루프에서 width *= 2 한 뒤 최소 3명령 지난 상태에서 비교됨.
    bge   s3, s2, done     # if (width >= N) goto done

    li    t0, 0            # left = 0

###############################
# merge_loop: one block [left, right)
###############################
merge_loop:
    ########################################
    # mid = left + width
    ########################################
    add   t1, t0, s3       # t1 = mid

    # t1 결과를 바로 branch에 쓰지 않도록
    # 다른 필요한 연산으로 간격 확보
    add   t2, t0, s3       # t2 = left + width (임시)
    add   t2, t2, s3       # t2 = left + 2*width (right 후보)
    nop                    # t1 -> bge 간 최소 3명령

    bge   t1, s2, end_loop # if (mid >= N)  goto end_loop (더 이상 정렬할 블록 없음)

    ########################################
    # right = min(left + 2*width, N)
    ########################################
    # t2 = left + 2*width 값은 이미 계산됨.
    # t2 값을 branch에 쓰기 전에 다른 작업으로 텀 확보.
    addi  t3, t0, 0        # i = left        (do_merge 준비)
    addi  t4, t1, 0        # j = mid
    addi  t5, t0, 0        # k = left

    bge   t2, s2, fix_r    # if (right > N) right = N
    j     do_merge_enter

fix_r:
    addi  t2, s2, 0        # right = N

do_merge_enter:
    # do_merge 진입 전 약간의 여유
    nop
    nop

################################
# do_merge: merge arr[left:mid), arr[mid:right)
################################
do_merge:
    # t3 = i, t4 = j, t5 = k 는 이미 설정됨
    # 바로 비교 루프로 진입
    j     merge_cmp

################################
# merge_cmp: main merge loop
################################
merge_cmp:
    # 인덱스 비교 (여기서 i,j는 이전 루프에서 충분히 떨어져 있음)
    bge   t3, t1, take_right    # i >= mid  → 오른쪽만 남음
    bge   t4, t2, take_left     # j >= right → 왼쪽만 남음

    ################################
    # arr[i] → x10 (load)
    ################################
    slli  t6, t3, 2             # t6 = i * 4
    add   t6, t6, s0            # &arr[i]
    lw    x10, 0(t6)            # x10 = arr[i]

    ################################
    # arr[j] → x11 (load)
    ################################
    slli  t6, t4, 2             # t6 = j * 4
    add   t6, t6, s0            # &arr[j]
    lw    x11, 0(t6)            # x11 = arr[j]

    # load-use hazard 피하기 위해
    # x10/x11을 쓰기 전에 3개의 독립 명령 실행
    addi  x12, t0, 0            # dummy: left 복사
    addi  x13, t1, 0            # dummy: mid 복사
    addi  x14, t2, 0            # dummy: right 복사

    # 이제 두 값 비교 가능
    ble   x10, x11, ml_left     # if arr[i] <= arr[j] → 왼쪽에서 가져오기

    ################################
    # arr[j] 를 tmp[k] 에 저장 (오른쪽 선택)
    ################################
    slli  t6, t5, 2             # t6 = k * 4
    add   t6, t6, s1            # &tmp[k]
    # 여기서 sw는 x11을 읽지만, lw 이후 이미 충분히 많은 명령이 지나감
    sw    x11, 0(t6)            # tmp[k] = arr[j]

    # 인덱스 갱신
    addi  t4, t4, 1             # j++
    addi  t5, t5, 1             # k++

    # i, mid, right는 안 건드렸으니 바로 다음 비교로
    j     merge_cmp

################################
# ml_left: arr[i] 를 선택
################################
ml_left:
    slli  t6, t5, 2             # t6 = k * 4
    add   t6, t6, s1            # &tmp[k]

    # x10은 위에서 lw 후 ble까지 3명령 이상 떨어져 있고,
    # 여기서도 주소 계산 두 개 지나고 사용하므로 load-use OK
    sw    x10, 0(t6)            # tmp[k] = arr[i]

    addi  t3, t3, 1             # i++
    addi  t5, t5, 1             # k++

    j     merge_cmp

################################
# take_left: 오른쪽 소진, 왼쪽만 flush
################################
take_left:
    bge   t3, t1, take_right_done   # while (i < mid)

    # arr[i] 로드
    slli  t6, t3, 2
    add   t6, t6, s0
    lw    x10, 0(t6)

    # load-use 간격 확보용 독립 명령
    addi  x12, t3, 0
    addi  x13, t5, 0
    addi  x14, x14, 0

    # tmp[k] = x10
    slli  t6, t5, 2
    add   t6, t6, s1
    sw    x10, 0(t6)

    addi  t3, t3, 1             # i++
    addi  t5, t5, 1             # k++

    j     take_left

################################
# take_right: 왼쪽 소진, 오른쪽만 flush
################################
take_right:
    bge   t4, t2, merge_copy    # while (j < right)

    # arr[j] 로드
    slli  t6, t4, 2
    add   t6, t6, s0
    lw    x10, 0(t6)

    # load-use 간격 확보
    addi  x12, t4, 0
    addi  x13, t5, 0
    addi  x14, x14, 0

    # tmp[k] = x10
    slli  t6, t5, 2
    add   t6, t6, s1
    sw    x10, 0(t6)

    addi  t4, t4, 1             # j++
    addi  t5, t5, 1             # k++

    j     take_right

take_right_done:
    j     merge_copy

################################
# merge_copy: tmp[left:right) → arr[left:right)
################################
merge_copy:
    addi  x12, t0, 0            # x12 = k = left

    # 루프 진입 전 여유
    nop
    nop

copy_loop:
    bge   x12, t2, end_merge    # while (k < right)

    # tmp[k] 로드
    slli  t6, x12, 2
    add   t6, t6, s1
    lw    x10, 0(t6)

    # load-use 간격 확보
    addi  x13, x12, 0
    addi  x14, t0, 0
    addi  x15, t1, 0

    # arr[k] = x10
    slli  t6, x12, 2
    add   t6, t6, s0
    sw    x10, 0(t6)

    addi  x12, x12, 1           # k++
    j     copy_loop

################################
# next block 또는 다음 width
################################
end_merge:
    addi  t0, t2, 0             # left = right

    # left 갱신 후 branch까지 간격
    addi  x16, t0, 0
    nop
    nop

    blt   t0, s2, merge_loop    # if (left < N) 더 블록 있음

################################
# width *= 2
################################
end_loop:
    slli  s3, s3, 1             # width <<= 1

    # 다음 merge_pass 의 bge(s3,s2)까지 간격 확보
    addi  x17, s3, 0
    nop
    nop

    j     merge_pass

################################
# done
################################
done:
    wfi

################################
# data
################################
    .data

arr:
    .word 9,1,8,2,7,3,6,4,0,-1,5,12,-3,10,11,-2

tmp:
    .space 64                   # 16 * 4 bytes