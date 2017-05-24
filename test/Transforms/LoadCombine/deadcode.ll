; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -load-combine -S < %s | FileCheck %s

; It has been detected that dead loops like the one in this test case can be
; created by -jump-threading (it was detected by a csmith generated program).
;
; According to -verify this is valid input (even if it could be discussed if
; the dead loop really satisfies SSA form).
;
; The problem found was that the -load-combine pass ends up in an infinite loop
; when analysing the 'bb1' basic block.
define void @test1() {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    ret void
; CHECK:       bb1:
; CHECK-NEXT:    [[_TMP4:%.*]] = load i16, i16* [[_TMP10:%.*]], align 1
; CHECK-NEXT:    [[_TMP10]] = getelementptr i16, i16* [[_TMP10]], i16 1
; CHECK-NEXT:    br label [[BB1:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    [[_TMP7:%.*]] = load i16, i16* [[_TMP12:%.*]], align 1
; CHECK-NEXT:    [[_TMP12]] = getelementptr i16, i16* [[_TMP12]], i16 1
; CHECK-NEXT:    br label [[BB2:%.*]]
;
  ret void

bb1:
  %_tmp4 = load i16, i16* %_tmp10, align 1
  %_tmp10 = getelementptr i16, i16* %_tmp10, i16 1
  br label %bb1

; A second basic block. Running the test with -debug-pass=Executions shows
; that we only run the Dominator Tree Construction one time for each function,
; also when having multiple basic blocks in the function.
bb2:
  %_tmp7 = load i16, i16* %_tmp12, align 1
  %_tmp12 = getelementptr i16, i16* %_tmp12, i16 1
  br label %bb2

}