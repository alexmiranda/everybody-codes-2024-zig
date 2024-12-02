const std = @import("std");
const print = std.debug.print;
const panic = std.debug.panic;
const assert = std.debug.assert;
const testing = std.testing;
const expectEqual = std.testing.expectEqual;

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    defer bw.flush() catch {}; // don't forget to flush!

    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer if (gpa.deinit() == .leak) panic("Memory leak.", .{});
    var ally = gpa.allocator();

    const notes_p1 = std.fs.cwd().openFile("quest-01/notes-p1.txt", .{}) catch |err| {
        switch (err) {
            error.FileNotFound => panic("Notes file is missing", .{}),
            else => panic("Failed to open notes: {any}", .{err}),
        }
    };

    const data_p1 = try notes_p1.readToEndAlloc(ally, 1000);
    defer ally.free(data_p1);
    const answer_p1 = preparePotions(data_p1);

    const stdout = bw.writer();
    try stdout.print("Part 1: {d}\n", .{answer_p1});
}

fn preparePotions(s: []const u8) usize {
    var count: usize = 0;
    for (s) |c| count += switch (c) {
        'B' => 1,
        'C' => 3,
        else => 0,
    };
    return count;
}

test "part 1" {
    try expectEqual(5, preparePotions("ABBAC"));
}

test "part 2" {
    return error.SkipZigTest;
}

test "part 3" {
    return error.SkipZigTest;
}
