@msg = constant [12 x i8] c"hello world\00"

declare void @exit(i32) noreturn
declare i32 @puts(i8*)

define void @main() noreturn {
  %msg = getelementptr [12 x i8], [12 x i8]* @msg, i1 0, i1 0
  call i32 @puts(i8* %msg)
  call void @exit(i32 0) noreturn
  unreachable
}
