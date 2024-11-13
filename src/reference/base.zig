const std = @import("std");
const http = std.http;
const net = std.net;
const log = std.log;

// pub const std_options = .{
//     .log_level = .info,
// };

pub fn main() !void {
    // implementation leveraging std lib
    const addr = try net.Address.parseIp("127.0.0.1", 8008);
    var srv = try net.Address.listen(addr, .{});
    defer srv.deinit();
    log.info("initialized server on port={s}", .{"8008"});

    var conn: net.Server.Connection = undefined;
    while (true) {
        log.debug("waiting for new connection", .{});
        conn = try srv.accept();
        log.debug("new connection accepted", .{});
        defer conn.stream.close();

        var buf = [_]u8{0} ** 1024;
        var httpServer = http.Server.init(conn, &buf);
        var request = httpServer.receiveHead() catch continue;
        var reader = try request.reader();
        var body = [_]u8{0} ** 1024;
        _ = try reader.readAll(&body);
        log.debug("read: {s}", .{body});

        try request.respond("2314", .{ .status = http.Status.ok });
        log.debug("done responding", .{});
    }
}
