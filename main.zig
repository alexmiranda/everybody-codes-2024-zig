pub const quest01 = @import("quest-01/main.zig");
pub const quest02 = @import("quest-02/main.zig");
pub const quest03 = @import("quest-03/main.zig");
pub const quest04 = @import("quest-04/main.zig");
pub const quest05 = @import("quest-05/main.zig");
pub const quest06 = @import("quest-06/main.zig");
pub const quest07 = @import("quest-07/main.zig");
pub const quest08 = @import("quest-08/main.zig");
pub const quest09 = @import("quest-09/main.zig");
pub const quest10 = @import("quest-10/main.zig");
pub const quest11 = @import("quest-11/main.zig");
pub const quest12 = @import("quest-12/main.zig");
pub const quest13 = @import("quest-13/main.zig");
pub const quest14 = @import("quest-14/main.zig");
pub const quest15 = @import("quest-15/main.zig");
pub const quest16 = @import("quest-16/main.zig");
pub const quest17 = @import("quest-17/main.zig");
pub const quest18 = @import("quest-18/main.zig");
pub const quest19 = @import("quest-19/main.zig");
pub const quest20 = @import("quest-20/main.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
