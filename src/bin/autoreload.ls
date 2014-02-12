require! fs

[root = \., port = 8080] = process.argv.slice 2

(require '../lib/autoreload') do
    root: root
    port: port is /^\d+$/ and parse-int port or 8080


