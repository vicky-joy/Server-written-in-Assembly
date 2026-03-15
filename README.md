# Server Written in Assembly (x86_64 Linux)

A tiny **HTTP-like server written at the lowest level** — pure **x86_64 Linux assembly**.
![](https://private-user-images.githubusercontent.com/74038190/242390692-0b335028-1d3d-4ee5-b5b3-a373d499be7e.gif?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NzM1MzM4ODYsIm5iZiI6MTc3MzUzMzU4NiwicGF0aCI6Ii83NDAzODE5MC8yNDIzOTA2OTItMGIzMzUwMjgtMWQzZC00ZWU1LWI1YjMtYTM3M2Q0OTliZTdlLmdpZj9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNjAzMTUlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjYwMzE1VDAwMTMwNlomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTVhZmEwNTJkMWU2NTc2NTI2MmI2MGMxZTk1ZjA1MmE2M2YzMzg2NTFkMjcwMzdkZTI4MDIyYjRiZTY1ZjQwZGYmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.vv3L_JG-yP-69iMx7Z-CJmcvW3yny9YZWaoWv6ehgro)

Most of us can build a server in **C / Rust / JavaScript** in minutes.
I wrote this one in Assembly because I wanted to *really* understand what happens **under the hood**: syscalls, sockets, file descriptors, request parsing, and the raw mechanics behind “web servers”.

> Next stop: diving even deeper into the **Linux kernel networking stack**.

## What it does

### ✅ GET
 ![](https://media.giphy.com/media/l0HlBO7eyXzSZkJri/giphy.gif)
- Reads the requested path from the request line
- Opens that file
- Sends back:
  - `HTTP/1.0 200 OK`
  - content of the file upto 512 bytes. Easly changable by changing single line
  - the file contents (**up to 512 bytes**)

> Caution: this is intentionally low-level and minimal — it can serve *any* file path the request asks for.

### ✅ POST
![](https://media.giphy.com/media/26ufdipQqU2lhNA4g/giphy.gif)

- Parses the requested path
- Creates/opens a file (write-only + create)
- Extracts content length from the request headers (simple parsing)
- Writes the request body into the file
- Replies with `HTTP/1.0 200 OK`

> Current implementation expects a fixed/simple POST layout with mandatory headers.

---

## How to use

### Option A — x86_64
If you’re on an **x86_64** machine, you can download the built binary (`server`) and run it.

### Option B — build from `server.s`
If you’re on another CPU architecture, you can use the `server.s` logic as a reference and re-assemble for your target.

---

## Notes / Limitations

- Minimal parsing, minimal validation (this is for learning)
- Very small buffers (512 bytes for request + 512 bytes for file reads)
- No security hardening (path traversal is possible if you don’t sandbox it)
- Handles connections using `fork()` (simple model, not tuned for performance)

---

## Customization / Secure version
If you want a **customized** and/or **secure** version (routing, limits, safer parsing, proper headers, etc.), I can build that for your needs.
