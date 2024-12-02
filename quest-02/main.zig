const std = @import("std");
const print = std.debug.print;
const panic = std.debug.panic;
const testing = std.testing;
const expectEqual = std.testing.expectEqual;
const example1 = @embedFile("example1.txt");
const example2 = @embedFile("example2.txt");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    defer bw.flush() catch {}; // don't forget to flush!
    const stdout = bw.writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer if (gpa.deinit() == .leak) panic("Memory leak", .{});
    const ally = gpa.allocator();

    var buf: [21959]u8 = undefined;
    const answer_p1 = blk: {
        var notes = std.fs.cwd().openFile("quest-02/notes-p1.txt", .{}) catch |err| {
            switch (err) {
                error.FileNotFound => panic("Notes file is missing", .{}),
                else => panic("Failed to open notes: {any}", .{err}),
            }
        };
        defer notes.close();

        const read = try notes.readAll(&buf);
        break :blk try countRunicWords(ally, buf[0..read]);
    };
    try stdout.print("Part 1: {d}\n", .{answer_p1});

    const answer_p2 = blk: {
        var notes = std.fs.cwd().openFile("quest-02/notes-p2.txt", .{}) catch |err| {
            switch (err) {
                error.FileNotFound => panic("Notes file is missing", .{}),
                else => panic("Failed to open notes: {any}", .{err}),
            }
        };
        defer notes.close();

        const read = try notes.readAll(&buf);
        break :blk try countRunicSymbols(ally, buf[0..read]);
    };
    try stdout.print("Part 2: {d}\n", .{answer_p2});
}

fn countRunicWords(ally: std.mem.Allocator, data: []const u8) !usize {
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

fn countRunicSymbols(ally: std.mem.Allocator, buffer: []const u8) !usize {
    var lines = std.mem.tokenizeScalar(u8, buffer, '\n');
    const possible_words = try possibleWordsOwned(ally, lines.next().?[6..]);
    defer ally.free(possible_words);

    var symbols = try ally.alloc(u1, 0);
    defer ally.free(symbols);

    var count: usize = 0;
    while (lines.next()) |inscription| {
        symbols = try ally.realloc(symbols, inscription.len);
        @memset(symbols[0..inscription.len], 0);

        var needle = try ally.alloc(u8, 0);
        defer ally.free(needle);
        for (possible_words) |word| {
            needle = try ally.realloc(needle, word.len);
            std.mem.copyForwards(u8, needle, word);
            var repeat = true;
            while (repeat) {
                var start: usize = 0;
                while (std.mem.indexOfPos(u8, inscription, start, needle[0..word.len])) |index| {
                    @memset(symbols[index .. index + word.len], 1);
                    start = index + 1;
                }
                std.mem.reverse(u8, needle[0..word.len]);
                repeat = (repeat and !std.mem.eql(u8, needle, word));
            }
        }
        const found = std.mem.count(u1, symbols, &[_]u1{1});
        count += found;
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
    try expectEqual(4, countRunicWords(testing.allocator, example1));
}

test "part 2" {
    try expectEqual(42, countRunicSymbols(testing.allocator, example2));
}

test "part 3" {
    return error.SkipZigTest;
}
