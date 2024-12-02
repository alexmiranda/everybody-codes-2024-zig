const std = @import("std");
const panic = std.debug.panic;
const expectEqual = std.testing.expectEqual;

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    defer bw.flush() catch {}; // don't forget to flush!
    const stdout = bw.writer();

    var buf: [9000]u8 = undefined;
    for (1..4) |i| {
        var path_buf: [21]u8 = undefined;
        const path = try std.fmt.bufPrint(&path_buf, "quest-01/notes-p{d}.txt", .{i});
        const notes = std.fs.cwd().openFile(path, .{}) catch |err| {
            switch (err) {
                error.FileNotFound => panic("Notes file is missing", .{}),
                else => panic("Failed to open notes: {any}", .{err}),
            }
        };
        defer notes.close();

        const read = try notes.readAll(&buf);
        const answer = preparePotions(buf[0..read], i);
        try stdout.print("Part {d}: {d}\n", .{ i, answer });
    }
}

fn preparePotions(s: []const u8, chunk: usize) usize {
    var count: usize = 0;
    var it = std.mem.window(u8, s, chunk, chunk);
    while (it.next()) |group| {
        const extra = chunk - std.mem.count(u8, group, "x") -| 1;
        for (group) |c| count += potionsNeeded(c, extra);
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
    try expectEqual(5, preparePotions("ABBAC", 1));
}

test "part 2" {
    try expectEqual(28, preparePotions("AxBCDDCAxD", 2));
}

test "part 3" {
    try expectEqual(30, preparePotions("xBxAAABCDxCC", 3));
}
