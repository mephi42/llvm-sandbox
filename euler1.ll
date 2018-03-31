declare void @exit(i32) noreturn
declare i32 @printf(i8*, ...)
@fmt = constant [4 x i8] c"%d\0A\00"

define void @main() noreturn {
loop_enter:
  br label %loop
loop:
  %s = phi i32 [ 0, %loop_enter ], [ %next_s, %increment_i ]
  %i = phi i32 [ 3, %loop_enter ], [ %next_i, %increment_i ]
  %loop_cond = icmp slt i32 %i, 1000
  br i1 %loop_cond, label %check_rem_3, label %loop_exit
check_rem_3:
  %i_rem_3 = srem i32 %i, 3
  %is_i_divisible_by_3 = icmp eq i32 %i_rem_3, 0
  br i1 %is_i_divisible_by_3, label %add_to_s, label %check_rem_5
check_rem_5:
  %i_rem_5 = srem i32 %i, 5
  %is_i_divisible_by_5 = icmp eq i32 %i_rem_5, 0
  br i1 %is_i_divisible_by_5, label %add_to_s, label %increment_i
add_to_s:
  %increased_s = add i32 %s, %i
  br label %increment_i
increment_i:
  %next_s = phi i32 [ %s, %check_rem_5 ], [ %increased_s, %add_to_s ]
  %next_i = add i32 %i, 1
  br label %loop
loop_exit:
  %fmt = getelementptr [4 x i8], [4 x i8]* @fmt, i1 0, i1 0
  call i32 (i8*, ...) @printf(i8* %fmt, i32 %s)
  call void (i32) @exit(i32 0) noreturn
  unreachable
}
