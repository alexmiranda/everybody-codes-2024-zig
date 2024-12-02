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
    const stdout = bw.writer();

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
    try stdout.print("Part 1: {d}\n", .{answer_p1});

    const notes_p2 = std.fs.cwd().openFile("quest-01/notes-p2.txt", .{}) catch |err| {
        switch (err) {
            error.FileNotFound => panic("Notes file is missing", .{}),
            else => panic("Failed to open notes: {any}", .{err}),
        }
    };

    const data_p2 = try notes_p2.readToEndAlloc(ally, 2000);
    print("{s} ({d})\n", .{ data_p2, data_p2.len });
    defer ally.free(data_p2);
    const answer_p2 = preparePotionsPairs(data_p2);
    try stdout.print("Part 2: {d}\n", .{answer_p2});
}

fn preparePotions(s: []const u8) usize {
    var count: usize = 0;
    for (s) |c| count += potionsNeeded(c, 0);
    return count;
}

fn preparePotionsPairs(s: []const u8) usize {
    var count: usize = 0;
    var it = std.mem.window(u8, s, 2, 2);
    while (it.next()) |pair| {
        const alone = (pair[0] == 'x' or pair[1] == 'x');
        count += potionsNeeded(pair[0], if (alone) 0 else 1);
        count += potionsNeeded(pair[1], if (alone) 0 else 1);
    }
    return count;
}

fn potionsNeeded(creature: u8, extra: usize) usize {
    return switch (creature) {
        'A' => 0 + extra,
        'B' => 1 + extra,
        'C' => 3 + extra,
        'D' => 5 + extra,
        else => 0,
    };
}

test "part 1" {
    try expectEqual(5, preparePotions("ABBAC"));
}

test "part 2" {
    try expectEqual(28, preparePotionsPairs("AxBCDDCAxD"));
}

test "part 3" {
    return error.SkipZigTest;
}
