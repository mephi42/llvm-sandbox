declare void @exit(i32) noreturn
declare void @llvm.memset.p0i8.i32(i8*, i8, i32, i32, i1)
declare float @llvm.sqrt.f32(float)
declare i32 @printf(i8*, ...)
@msg = constant [4 x i8] c"%d\0A\00"
@max = constant i32 28123

define i32 @sum_divisors(i32 %n, i32 %end) {
enter:
  br label %loop
loop:
  %s = phi i32 [ 1, %enter ], [ %s_next, %increment_i ]
  %i = phi i32 [ 2, %enter ], [ %i_next, %increment_i ]
  %should_proceed = icmp slt i32 %i, %end
  br i1 %should_proceed, label %rem_check, label %loop_exit
rem_check:
  %n_rem_i = srem i32 %n, %i
  %is_n_divisible_by_i = icmp eq i32 %n_rem_i, 0
  br i1 %is_n_divisible_by_i, label %increment_s, label %increment_i
increment_s:
  %n_div_i = sdiv i32 %n, %i
  %increment = add i32 %i, %n_div_i
  %incremented_s = add i32 %s, %increment
  br label %increment_i
increment_i:
  %s_next = phi i32 [ %s, %rem_check ], [ %incremented_s, %increment_s ]
  %i_next = add i32 %i, 1
  br label %loop
loop_exit:
  ret i32 %s
}

define i1 @is_abundant(i32 %n) {
  %n_float = sitofp i32 %n to float
  %max_i_float = call float @llvm.sqrt.f32(float %n_float)
  %max_i = fptosi float %max_i_float to i32
  %max_i_sq = mul i32 %max_i, %max_i
  %is_n_sq = icmp eq i32 %n, %max_i_sq
  br i1 %is_n_sq, label %handle_n_sq, label %handle_n_non_sq
handle_n_sq:
  %s0_sq = call i32 @sum_divisors(i32 %n, i32 %max_i)
  %s_sq = add i32 %s0_sq, %max_i
  br label %done
handle_n_non_sq:
  %max_i_plus_1 = add i32 %max_i, 1
  %s_non_sq = call i32 @sum_divisors(i32 %n, i32 %max_i_plus_1)
  br label %done
done:
  %s = phi i32 [ %s_sq, %handle_n_sq ], [ %s_non_sq, %handle_n_non_sq ]
  %ret = icmp sgt i32 %s, %n
  ret i1 %ret
}

define i32 @collect_abundant(i32* %p, i32 %n) {
enter:
  br label %loop
loop:
  %j = phi i32 [ 0, %enter ], [ %j_next, %loop_next ]
  %i = phi i32 [ 2, %enter ], [ %i_next, %loop_next ]
  %should_proceed = icmp slt i32 %i, %n
  br i1 %should_proceed, label %abundant_check, label %loop_exit
abundant_check:
  %is_abundant = call i1 @is_abundant(i32 %i)
  br i1 %is_abundant, label %save_abundant, label %loop_next
save_abundant:
  %pj = getelementptr i32, i32* %p, i32 %j
  store i32 %i, i32* %pj
  %j_incremented = add i32 %j, 1
  br label %loop_next
loop_next:
  %j_next = phi i32 [ %j, %abundant_check ], [ %j_incremented, %save_abundant ]
  %i_next = add i32 %i, 1
  br label %loop
loop_exit:
  ret i32 %j
}

define void @collect_pairwise_sums(i8* %p, i32 %n, i32* %px, i32 %nx) {
enter:
  call void @llvm.memset.p0i8.i32(i8* %p, i8 0, i32 %n, i32 1, i1 0)
  br label %loop1
loop1:
  %i = phi i32 [ 0, %enter ], [ %i_next, %loop2_exit ]
  %should_proceed1 = icmp slt i32 %i, %nx
  br i1 %should_proceed1, label %loop1_body, label %loop1_exit
loop1_body:
  %pxi = getelementptr i32, i32* %px, i32 %i
  %xi = load i32, i32* %pxi
  br label %loop2
loop2:
  %j = phi i32 [ 0, %loop1_body ], [ %j_next, %loop2_next ]
  %should_proceed2 = icmp sle i32 %j, %i
  br i1 %should_proceed2, label %loop2_body, label %loop2_exit
loop2_body:
  %pxj = getelementptr i32, i32* %px, i32 %j
  %xj = load i32, i32* %pxj
  %s = add i32 %xi, %xj
  %does_s_fit = icmp slt i32 %s, %n
  br i1 %does_s_fit, label %save_s, label %loop2_next
save_s:
  %ps = getelementptr i8, i8* %p, i32 %s
  store i8 1, i8* %ps
  br label %loop2_next
loop2_next:
  %j_next = add i32 %j, 1
  br label %loop2
loop2_exit:
  %i_next = add i32 %i, 1
  br label %loop1
loop1_exit:
  ret void
}

define i32 @sum_indices(i8* %p, i32 %n) {
enter:
  br label %loop
loop:
  %s = phi i32 [ 0, %enter ], [ %s_next, %loop_next ]
  %i = phi i32 [ 0, %enter ], [ %i_next, %loop_next ]
  %should_proceed = icmp slt i32 %i, %n
  br i1 %should_proceed, label %loop_body, label %loop_exit
loop_body:
  %pi = getelementptr i8, i8* %p, i32 %i
  %xi = load i8, i8* %pi
  %should_increment_s = icmp eq i8 %xi, 0
  br i1 %should_increment_s, label %increment_s, label %loop_next
increment_s:
  %incremented_s = add i32 %s, %i
  br label %loop_next
loop_next:
  %s_next = phi i32 [ %s, %loop_body ], [ %incremented_s, %increment_s ]
  %i_next = add i32 %i, 1
  br label %loop
loop_exit:
  ret i32 %s
}

define void @main() noreturn {
  %max = load i32, i32* @max
  %abundant_numbers = alloca i32, i32 %max
  %p_abundant = getelementptr i32, i32* %abundant_numbers, i1 0
  %n_abundant = call i32 @collect_abundant(i32* %p_abundant, i32 %max)
  %are_sums = alloca i8, i32 %max
  %p_are_sums = getelementptr i8, i8* %are_sums, i1 0
  call void @collect_pairwise_sums(
    i8* %p_are_sums, i32 %max, i32* %p_abundant, i32 %n_abundant)
  %result = call i32 @sum_indices(i8* %p_are_sums, i32 %max)
  %msg = getelementptr [4 x i8], [4 x i8]* @msg, i1 0, i1 0
  call i32 (i8*, ...) @printf(i8* %msg, i32 %result)
  call void @exit(i32 0) noreturn
  unreachable
}
