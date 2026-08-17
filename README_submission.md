# README Submission — Lab 17 Multi-Memory Agent

## Kết quả

Practice E01-E11 **11/11 (100%)**, no-memory baseline **2/11 (18.2%)**, golden G01-G20 **20/20** (+10). UI demo: `src/demo_ui.py` (Streamlit) — chọn case, xem retrieval từng layer, chat tiếp cùng user/thread.

## 3 câu bắt buộc

**1. Layer quan trọng nhất?** `long_term` — nhiều case nhất (E02/E03/E08/E09), nặng logic nhất: E08 phải chọn fact **mới nhất** khi mâu thuẫn (`BLUEBIRD-42` → TypeScript/NestJS, hết Python), E09 phải cách ly đúng user (trả lời `lan-lab17`, không lộ `ORCHID-27` của `minh-lab17`). Sai layer này là sai cả conflict-handling lẫn bảo mật đa user.

**2. Trade-off Context Block (Zep) vs Redis+Qdrant?** Zep tự trích fact, xếp hạng, tóm tắt — khỏi tự xây index/hợp nhất, đổi lại là blackbox: 200ms-2s latency, khó audit vì sao một fact được giữ. Redis+Qdrant toàn quyền schema/TTL/similarity, latency <5ms, nhưng phải tự làm hết phần Zep có sẵn: trích fact, xử lý mâu thuẫn, xử lý recency.

**3. Guardrail chống memory poisoning?** Bắt buộc `memory_opt_in` trước khi ingest; `minimize_pii` redact email/SĐT trước khi lưu; semantic graph (KB chung) tách hoàn toàn khỏi user graph — query semantic chỉ dùng `graph_id`, không trộn `user_id`, nên user không tiêm được fact giả vào KB chung; `heartbeat.py` chỉ dedupe/đánh dấu stale, **không** tự thêm instruction mới vào durable memory.

## 4 câu phân tích benchmark

1. **Layer hit rate thấp nhất:** memory bật thì cả 4 layer 100%. Baseline no-memory lộ rõ: `short_term` vẫn 2/2 (evidence nằm ngay trong hội thoại), `long_term`/`episodic`/`semantic`/`mixed` đều **0%** — chỉ sống nhờ bộ nhớ persistent.
2. **Query tốn token nhất:** case `long_term` (E02/E03/E08, ~1450-1480 token) — vì `get_user_context` trả cả `USER_SUMMARY` lẫn full fact list (`scope="edges"`, limit 20), nặng hơn episodic/semantic.
3. **E07 (mixed):** cần `long_term` (Python preference của Minh) + `semantic` (`Idempotency-Key`); thiếu một là fail.
4. **Token reduction:** memory-enabled giảm ~14%, vẫn đủ evidence. No-memory giảm ~82% nhưng hit rate 18.2% — giảm vì **không retrieve gì**, không phải nén thông minh; reduction chỉ có ý nghĩa khi đi kèm hit rate cao.

## Ghi chú thêm

- **E08 (recency):** fact mới mâu thuẫn fact cũ, `get_user_context` ưu tiên bản mới trong `USER_SUMMARY`; fact cũ còn trong `graph.search(scope="edges")` kèm `valid_at`/`invalid_at` để truy vết.
- **E10 (compaction):** giảm `max_recent_messages` 6→4, sliding window vẫn giữ `REVIEW-DEADLINE-1600` nhờ `extract_durable_notes` đẩy constraint vào `DURABLE_NOTES` trước khi bị evict.
