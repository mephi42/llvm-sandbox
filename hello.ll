@.str = private unnamed_addr constant [11 x i8] c"hello world"

declare void @exit(i32) noreturn nounwind
declare i32 @puts(i8* nocapture) nounwind

define void @main() noreturn {
    %str = getelementptr [11 x i8], [11 x i8]* @.str, i64 0, i64 0
    call i32 @puts(i8* %str)
    call void @exit(i32 0) noreturn
    unreachable
}
