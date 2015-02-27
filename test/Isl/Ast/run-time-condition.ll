; RUN: opt %loadPolly -polly-detect-unprofitable -basicaa -polly-ast -analyze -polly-no-early-exit < %s | FileCheck %s

; for (i = 0; i < 1024; i++)
;   A[i] = B[i];

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define void @run-time-condition(i16* noalias %A, i16* noalias %B) {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.body, %entry
  %indvar = phi i64 [ 0, %entry ], [ %inc, %for.body ]
  %cmp = icmp slt i64 %indvar, 1024
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %arrayidx = getelementptr inbounds i16, i16* %B, i64 0
  %load = load i16* %arrayidx
  %add10 = add nsw i16 %load, 1
  %arrayidx13 = getelementptr inbounds i16, i16* %A, i64 %indvar
  store i16 %add10, i16* %arrayidx13, align 2
  %inc = add nsw i64 %indvar, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret void
}

; CHECK: if (1)
; CHECK:     for (int c0 = 0; c0 <= 1023; c0 += 1)
; CHECK:       Stmt_for_body(c0);
; CHECK: else
; CHECK:     {  /* original code */ }

