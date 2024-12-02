const std = @import("std");
const print = std.debug.print;
const panic = std.debug.panic;
const testing = std.testing;
const expectEqual = std.testing.expectEqual;
const example = @embedFile("example.txt");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    defer bw.flush() catch {}; // don't forget to flush!
    const stdout = bw.writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer if (gpa.deinit() == .leak) panic("Memory leak", .{});
    const ally = gpa.allocator();

    var notes = std.fs.cwd().openFile("quest-02/notes-p1.txt", .{}) catch |err| {
        switch (err) {
            error.FileNotFound => panic("Notes file is missing", .{}),
            else => panic("Failed to open notes: {any}", .{err}),
        }
    };
    defer notes.close();

    const answer = try countRunicWords(ally, notes.reader(), 474);
    try stdout.print("Part 1: {d}\n", .{answer});
}

fn countRunicWords(ally: std.mem.Allocator, reader: anytype, max_size: usize) !usize {
    const data = try reader.readAllAlloc(ally, max_size);
    defer ally.free(data);

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    const possible_words = try possibleWordsOwned(ally, lines.next().?[6..]);
    defer ally.free(possible_words);

    const inscription = lines.next().?;
    var count: usize = 0;
    for (possible_words) |word| {
        count += std.mem.count(u8, inscription, word);
    }

    return count;
}

fn possibleWordsOwned(ally: std.mem.Allocator, buffer: []const u8) ![][]const u8 {
    var list = try std.ArrayList([]const u8).initCapacity(ally, 5);
    defer list.deinit();

    var it = std.mem.tokenizeScalar(u8, buffer, ',');
    while (it.next()) |word| try list.append(word);
    return list.toOwnedSlice();
}

test "part 1" {
    var fbs = std.io.fixedBufferStream(example);
    try expectEqual(4, countRunicWords(testing.allocator, fbs.reader(), 79));
}

test "part 2" {
    return error.SkipZigTest;
}

test "part 3" {
    return error.SkipZigTest;
}
