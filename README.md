# OpenCode Advisor (`oc-advisor`)

> **Stage-3 Architectural Authority & Definitive Gatekeeper Subagent for OpenCode**  
> Ported from the architectural gatekeeper mechanism of **OMP ([oh-my-pi](https://github.com/can1357/oh-my-pi))** and aligned with **AI Coding Constitution (v6.10, Art 17.1)**.  
> **Pinned Model:** `openai/gpt-5.6-sol`

---

## 🎯 Giới thiệu (Overview)

Trong các hệ thống đa agent (multi-agent coding systems), rủi ro lớn nhất là:
1. **Agent mò mẫm không định hướng:** Tự chế kế hoạch mà không nắm rõ hiện trạng mã nguồn, dẫn đến việc bị reject nhiều lần.
2. **Thiếu Test kịch bản nghiệp vụ:** Kế hoạch chỉ lo viết code mà bỏ quên luồng trải nghiệm người dùng (Epic Story) và các ca biên nghiệp vụ (Business Edge Cases).
3. **Nghiệm thu bằng mắt (Blind Approval):** Code xong tự nhận hoàn thành mà không có biên lai chạy test thực tế (Test Execution Receipt).
4. **Gãy vỡ liên kết ngầm (Unchecked Blast Radius):** Sửa code làm hỏng các module tầng trên mà không kiểm tra đồ thị phụ thuộc ngược.

**`oc-advisor`** giải quyết triệt để các vấn đề trên với mô hình kết hợp **"Tư vấn đi trước (Shift-Left) + Thẩm định chốt chặn (Gatekeeper)"**:
- **Cố định mô hình suy luận đỉnh cao (`openai/gpt-5.6-sol`):** Đảm bảo năng lực đánh giá logic, kiến trúc hệ thống và bảo mật sâu sắc nhất, không bị phụ thuộc vào model đang code.
- **Tư vấn định hướng trước khi lập plan (Pre-Planning Consultation):** Định hướng kiến trúc, chỉ rõ ranh giới file, liệt kê checklist edge cases bắt buộc.
- **Bắt buộc kịch bản nghiệp vụ người dùng & Edge Cases:** Blueprint phải có ma trận kiểm thử người dùng đầy đủ mới được duyệt qua Gate 1.
- **Quyền hạn thẩm định dứt khoát (1-Pass Gate):** Ra phán quyết một lần duy nhất (`APPROVED` hoặc `REJECTED`), tuyệt đối không lặp vòng review-fix ngầm.
- **Neo vào thực tế (Disk Reality & SOT-Graph):** Sử dụng bộ công cụ AST (`sot_search`, `sot_diff_impact`, `sot_usages`, `read`, `grep`, `glob`) để rà soát thực tế trên ổ đĩa.

---

## 🏛️ Hai chế độ làm việc (Two Operational Modes)

```
                       BƯỚC 0: TƯ VẤN ĐỊNH HƯỚNG (Consultation)
     [Main Agent] ──────────────────────────────────────────► [Advisor (gpt-5.6-sol)]
                  "Tôi muốn làm tính năng X,                 - Tra cứu SOT-Graph tìm modules liên quan
                   hãy định hướng kiến trúc, ranh giới file, - Vạch ra rủi ro tiềm ẩn
                   và các edge cases nghiệp vụ cần đưa vào?"  - Liệt kê Checklist Edge Cases bắt buộc
                  ◄──────────────────────────────────────────
                         Trả về: Architectural Guidance (Không ra verdict Approved/Reject)

                                       │
                                       ▼
                    BƯỚC 1: SOẠN VÀ DUYỆT PLAN (Gate 1: Blueprint Gate)
     [Main Agent] ──(Soạn Plan chuẩn theo Checklist)────────► [Advisor (gpt-5.6-sol)] ──► [VERDICT: APPROVED] (1-Pass)

                                       │
                                       ▼
                    BƯỚC 2: CODE, TEST & NGHIỆM THU (Gate 2: Delivery Gate)
     [Workers] ─────(Thực thi code + chạy test nghiệp vụ)────► [Advisor (gpt-5.6-sol)] ──► [VERDICT: APPROVED] (Release)
```

### 🔹 Chế độ 1: Tư vấn định hướng (Pre-Planning Consultation)
Kích hoạt trước khi soạn Plan khi Main Agent hoặc User cần định hướng:
- Tra cứu SOT-Graph để phân tích hiện trạng mã nguồn, các module sẵn có.
- Trả về:
  1. Kiến trúc đề xuất & Ranh giới sở hữu file (File Ownership) để tránh xung đột khi làm song song.
  2. Các ràng buộc kiến trúc & bảo mật cần bảo toàn (Invariants).
  3. **Ma trận Checklist Edge Cases nghiệp vụ bắt buộc** phải đưa vào Plan.
*(Lưu ý: Chế độ này đưa ra lời khuyên định hướng, KHÔNG trả về phán quyết Gatekeeper APPROVED/REJECTED).*

---

### 🔹 Chế độ 2: Thẩm định chốt chặn (Gatekeeper Authority - 2 Gates)

#### 1. Blueprint Approval Gate (Trước khi viết code)
Khi Main Agent lập xong Blueprint hoặc kế hoạch JIT Wave:
- **Xác minh kiến trúc & ranh giới:** Mục tiêu rõ ràng, không có bước mơ hồ, ranh giới file phân định rành mạch giữa các worker.
- **Bắt buộc Ma trận Kịch bản Test Nghiệp vụ (Business Test Matrix):**
  1. *Epic Story / User Journey:* Luồng nghiệp vụ người dùng từ đầu đến cuối (`Actor -> Trigger -> Business Logic Validation -> State Transition -> Audit/Event`).
  2. *Business Edge Cases (Edge cases nghiệp vụ):* Giá trị biên, trạng thái nghiệp vụ không hợp lệ (double submit, tài khoản âm tiền, token hết hạn), vi phạm phân quyền role/tenant, sự cố mạng/timeout retry.
  3. *Lệnh test mục tiêu:* CLI test commands cụ thể và fixtures kiểm thử.
- **Hard Rule:** Nếu Blueprint thiếu kịch bản test nghiệp vụ người dùng hoặc edge cases ➔ Advisor **REJECT ngay lập tức**.

#### 2. Delivery & Release Gate (Sau khi hoàn thành code)
Khi code đã viết xong, test đã chạy và Tier-1 Reviewer đã rà soát:
- **Kiểm chứng độc lập:** Rà soát đóng lỗi triệt để, bảo mật, tác dụng phụ đa file, tính nhất quán AST.
- **Quét bán kính tác động ngược (Reverse Blast Radius):** Dùng `sot_diff_impact` và `sot_usages` để bảo đảm không làm gãy vỡ upstream callers.
- **Bắt buộc Bằng chứng Chạy Test Thực tế (Empirical Test Receipt):**
  - Lệnh đã chạy thực tế (ví dụ `pytest ...`, `npm test ...`).
  - Exit code = 0, số lượng pass/fail/skip.
  - Bằng chứng đã chạy qua các Epic Story và Business Edge Cases đã cam kết trong Blueprint.
- **Hard Rule:** Nghiêm cấm nghiệm thu "bằng mắt" hoặc test giả lập mock sơ sài. Không có bằng chứng test chạy pass ➔ **REJECT**.

---

## 📋 Cấu trúc phản hồi chuẩn cho Gatekeeper (Mandatory Output Schema)

```markdown
### ADVISOR VERDICT: [APPROVED | REJECTED | NEEDS_REVISION]
**Executive Summary:** <1-3 câu tóm tắt điều hành đánh giá kiến trúc & bảo mật>

**Verified Invariants & Architecture:**
- <Invariant 1 được xác minh với thực tế filesystem/codebase>
- <Invariant 2 được xác minh với bán kính tác động ngược SOT-Graph>

**Verified Business Tests & Edge Cases:**
- **User / Epic Story Flows:** <Đánh giá độ bao phủ luồng nghiệp vụ người dùng>
- **Business Edge Cases:** <Các trường hợp biên, phân quyền, trạng thái lỗi nghiệp vụ>
- **Execution Evidence:** <Lệnh test, exit code, số lượng passed/failed> (cho Gate 2) hoặc <Kế hoạch test> (cho Gate 1)

**Residual Risks / Blockers:**
- <Danh sách rủi ro tồn dư được chấp nhận hoặc các Blocker chặn release>
```

---

## 🚀 Cài đặt (Installation)

```bash
cd ~/code/GitHub/oc-advisor
./install.sh
```

Hoặc copy thủ công:
```bash
cp agents/advisor.md ~/.config/opencode/agents/advisor.md
```

---

## 💻 Cách sử dụng trong OpenCode

### 1. Xin định hướng trước khi lập plan (Consultation Mode):
```json
{
  "description": "Consult advisor for plan direction and edge cases",
  "prompt": "Tôi muốn làm tính năng X. Trước khi lên plan, hãy tư vấn định hướng kiến trúc, ranh giới file, và danh sách các edge cases nghiệp vụ cần đưa vào kế hoạch.",
  "subagent_type": "advisor"
}
```

### 2. Duyệt Kế hoạch (Gate 1: Blueprint Gate):
```json
{
  "description": "Gatekeep architectural blueprint and business test scenarios",
  "prompt": "Evaluate this blueprint for architectural integrity, user business flows, and business edge cases:\n\n<nội dung blueprint>",
  "subagent_type": "advisor"
}
```

### 3. Nghiệm thu Release (Gate 2: Delivery Gate):
```json
{
  "description": "Final gatekeeper release verification",
  "prompt": "Evaluate production code readiness for the completed deliverable.\n\nDiff Target: HEAD~1\nAffected files: <danh sách files>\n\n### Test Execution Receipt:\nCOMMAND: pytest tests/test_payment.py\nEXIT: 0\nRESULT: pass — 12 passed, 0 failed\nCOVERED SCENARIOS: Epic story checkout, double payment edge case, expired card retry.\n\nPlease inspect reverse blast radius with sot_diff_impact / sot_usages and issue the final gatekeeper verdict.",
  "subagent_type": "advisor"
}
```

### 4. Chạy trực tiếp từ dòng lệnh (Standalone CLI):
```bash
opencode run --agent advisor "Tư vấn kiến trúc để thêm cơ chế multi-tenant vào hệ thống hiện tại"
```

---

## 🛡️ Quyền hạn & Công cụ (Permissions & Tools)

Advisor là **Read-only Agent**, chỉ quan sát và phân tích đồ thị AST, không sửa code:
- ✅ `read`, `grep`, `glob`: Đọc code và kiểm tra vị trí file.
- ✅ `sot-graph_sot_search`, `sot-graph_sot_map`, `sot-graph_sot_explore`, `sot-graph_sot_usages`, `sot-graph_sot_implementations`: Rà soát đồ thị gọi hàm AST và định danh symbol.
- ✅ `sot-graph_sot_diff_impact`, `sot-graph_sot_diff_impact_receipt`, `sot-graph_sot_scope_receipt`, `sot-graph_sot_verify_drift`: Đo lường bán kính rủi ro git diff.
- ✅ `context-mode_ctx_search`, `context-mode_ctx_execute_file`: Phân tích log/context dung lượng lớn.
- ❌ CẤM: `write`, `edit`, `bash` (không chỉnh sửa file vật lý hay chạy script tuỳ ý).

---

## 📂 Cấu trúc Repository

```text
oc-advisor/
├── README.md                          # Tài liệu hướng dẫn chi tiết
├── install.sh                         # Script cài đặt vào ~/.config/opencode
├── agents/
│   └── advisor.md                     # Agent definition chuẩn OpenCode (mode: all, model: openai/gpt-5.6-sol)
└── examples/
    ├── consultation_prompt.md         # Mẫu prompt xin định hướng trước khi lập plan
    ├── blueprint_approval_prompt.md   # Mẫu prompt duyệt blueprint kèm kịch bản test nghiệp vụ
    ├── delivery_approval_prompt.md    # Mẫu prompt nghiệm thu release kèm Test Receipt
    └── sample_verdicts.md             # Mẫu kết quả phán quyết Approved/Rejected
```

---

## 📜 Giấy phép (License)
MIT License. Tương thích hoàn toàn với hệ sinh thái OpenCode & OMP.
