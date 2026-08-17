# Tóm tắt kết quả (bản dễ đọc)

> File này chỉ để đọc nhanh. File chấm điểm thật vẫn là `benchmark.json`, `benchmark_no_memory.json`, `golden_benchmark.json` (không sửa tay các file đó).

## 1. Bộ test luyện tập (E01-E11)

- Kết quả: **11/11 PASS** (100%)
- So với bắt buộc của lab: **9/11 (80%)** → đã vượt

| Layer | Case | Việc kiểm tra |
|---|---|---|
| short_term | E01, E10 | Nhớ đúng thông tin trong hội thoại hiện tại, kể cả sau khi bị nén (compaction) |
| long_term | E02, E03, E08, E09 | Nhớ sở thích/qua nhiều thread, nhớ đúng cái mới nhất khi có mâu thuẫn, không lẫn giữa 2 user |
| episodic | E04, E05 | Nhớ lại "lần trước đã thử gì, cái gì work" |
| semantic | E06, E11 | Tra đúng luật/tài liệu chung, không phải chuyện riêng của user |
| mixed | E07 | Ghép đúng 2 layer cùng lúc (long_term + semantic) |

## 2. So sánh có trí nhớ vs không có trí nhớ

| | Có trí nhớ | Không trí nhớ |
|---|---:|---:|
| Tỷ lệ đúng | 100% | 18.2% (2/11) |
| Case đúng | 11/11 | 2/11 |

**Hiểu đơn giản:** không có trí nhớ thì agent chỉ trả lời đúng vài câu hỏi trong hội thoại hiện tại (short-term), còn lại 9 câu cần nhớ chuyện cũ/qua thread khác đều sai. "Không có trí nhớ" tưởng nhẹ (token thấp) nhưng sai nhiều — nhẹ mà sai thì vô nghĩa.

## 3. Bộ test ẩn (Golden G01-G20)

- Kết quả: **20/20 PASS** (100%) → cộng **+10 điểm**
- Đặc điểm: câu hỏi dài, có nhiều thông tin gây nhiễu (chuyện đồng nghiệp, dự án khác) để thử xem agent có bị lừa không

**Case chậm nhất (không phải case sai, chỉ là tốn thời gian tra cứu):**

| Case | Layer | Thời gian | Vì sao chậm |
|---|---|---:|---|
| G20, G16 | mixed | ~2.5-2.8s | Phải tra 2-3 layer cùng lúc rồi ghép lại |
| G05, G09, G08 | long_term | ~2-2.4s | Mỗi case gọi Zep 2 lần (context + facts), câu hỏi dài nhiều đoạn nhiễu |

**Case nhanh nhất:** semantic (G12-G15, ~250-300ms) và episodic (G10-G11, ~260ms) — chỉ cần 1 lần gọi tra cứu.

**Cái khó thật sự của bộ Golden:** phân biệt đúng "đây là chuyện của tôi hay của đồng nghiệp" (case G09, G19 hỏi về Lan nhưng có nhắc tới người khác) và ghép đúng nhiều layer mà không lẫn cá nhân/công ty (case G16-G20). Code hiện tại xử lý đúng hết vì mọi lệnh tra cứu đều khóa theo `user_id` riêng của từng người.

## 4. Test khóa của starter kit

- `pytest -q`: **12/12 pass** — không có gì bị sửa nhầm ngoài `memory_student.py`.

## 5. Việc còn thiếu (chưa liên quan code, code đã xong)

| Việc | Trạng thái |
|---|---|
| `README_submission.md` (3 câu bắt buộc + 4 câu phân tích) | Đã viết |
| Privacy drill (`src.forget` xóa `minh-lab17` rồi verify) | Đã chạy — delete + verify đều `True` |
| UI demo (`src/demo_ui.py`) | Đã xong, chạy được tại `localhost:8501` |
| 4 ảnh chụp màn hình (long_term, episodic, semantic, privacy) | Cần tự chụp tay (Claude không chụp được UI thật) |
| `git add` các file report | Report đang ở trạng thái untracked, cần add trước khi commit |

## 6. Lưu ý kỹ thuật phát hiện được khi hoàn thiện

Zep Cloud xóa user (`forget`) có độ trễ bất đồng bộ: verify ngay sau khi xóa báo `True`, nhưng vài chục phút sau nếu seed lại user cùng `user_id` thì bản xóa trễ có thể "đuổi kịp" và xóa mất user vừa tạo lại (gặp đúng trường hợp này khi benchmark báo `user not found` dù đã seed). Cách né: sau khi `forget`, **seed lại và chạy benchmark ngay**, đừng để cách xa nhau nhiều phút.
