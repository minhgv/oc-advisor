# OpenCode Advisor (`oc-advisor`)

> **Stage-3 Final Gatekeeper & Architectural Authority Subagent for OpenCode**  
> Ported from the architectural gatekeeper mechanism of **OMP ([oh-my-pi](https://github.com/can1357/oh-my-pi))** and aligned with **AI Coding Constitution (v6.10, Art 17.1)**.

---

## 🎯 Giới thiệu (Overview)

Trong các hệ thống đa agent (multi-agent coding systems), rủi ro lớn nhất là:
1. **Spec Drift & Thiếu Test nghiệp vụ:** Agent tự ý viết code khi kế hoạch (blueprint) chưa hề vạch ra các kịch bản test nghiệp vụ người dùng hoặc bỏ quên các edge cases nghiêm trọng.
2. **Nghiệm thu bằng mắt (Blind Approval):** Agent code xong tự nhận là "đã hoàn thành" mà không hề thực sự chạy test kiểm chứng với lệnh thực thi cụ thể.
3. **Review Ping-Pong:** Agent sửa đi sửa lại vòng tròn (infinite fix-review loops) mà không có trọng tài chốt hạ dứt khoát.
4. **Unchecked Blast Radius:** Thay đổi code làm gãy vỡ các caller ở tầng trên mà không được kiểm tra tác động ngược.

**`oc-advisor`** giải quyết triệt để các vấn đề trên bằng cách thiết lập vị trí **Stage-3 Definitive Gatekeeper** trong OpenCode:
- **Độc lập & Khách quan:** Hoạt động như một subagent/primary riêng biệt, không bị cuốn vào thiên kiến của agent đang trực tiếp viết code.
- **Bắt buộc kịch bản test nghiệp vụ (Business Test & Edge Cases Enforcement):** Bắt buộc Blueprint phải có ma trận kiểm thử bao quát toàn bộ Epic Story của người dùng và các Edge Cases nghiệp vụ phức tạp trước khi code.
- **Quyền hạn tối cao 1 lần (1-Pass Gate):** Được kích hoạt đúng 1 lần cho mỗi cổng kiểm soát (Blueprint Gate hoặc Delivery Gate). Tuyệt đối không lặp vòng review-fix ngầm.
- **Neo vào thực tế (Disk Reality & SOT-Graph):** Được cấp quyền truy cập các công cụ AST kiến trúc (`sot-graph_sot_search`, `sot-graph_sot_diff_impact`, `sot-graph_sot_usages`, `read`, `grep`, `glob`) để rà soát bán kính ảnh hưởng thực tế.

---

## 🏛️ Hai cổng kiểm soát cốt lõi (Two Core Gates)

```
┌─────────────────────────────────────────────────────────────┐
│                 MAIN AGENT / ORCHESTRATOR                   │
└──────────────┬───────────────────────────────▲──────────────┘
               │                               │
    [Gate 1: Blueprint Request]     [Gate 1 Verdict: Approved/Rejected]
               ▼                               │
┌──────────────────────────────────────────────┴──────────────┐
│                    STAGE-3 ADVISOR AGENT                    │
│  - Phê duyệt Blueprint kiến trúc (Pre-Implementation)        │
│  - Bắt buộc Kịch bản Nghiệp vụ Người dùng & Edge Cases      │
│  - Thẩm định Bằng chứng Chạy Test & Blast Radius (Post-Imp)  │
└─────────────────────────────────────────────────────────────┘
```

### 1. Blueprint Approval Gate (Trước khi viết code)
Khi Main Agent lập xong Blueprint hoặc kế hoạch JIT Wave:
- **Xác minh kiến trúc & ranh giới:** Mục tiêu rõ ràng, không có bước mơ hồ, ranh giới file (file ownership) phân định rành mạch giữa các worker.
- **Bắt buộc Ma trận Kịch bản Test Nghiệp vụ (Business Test Matrix):**
  1. *Epic Story / User Journey:* Luồng nghiệp vụ người dùng từ đầu đến cuối (Actor -> Trigger -> Business Logic Validation -> State Transition -> Audit/Event).
  2. *Business Edge Cases (Edge cases nghiệp vụ):* Giá trị biên, trạng thái nghiệp vụ không hợp lệ (double submit, tài khoản âm tiền, token hết hạn), vi phạm phân quyền role/tenant, sự cố mạng/timeout retry.
  3. *Lệnh test mục tiêu:* CLI test commands cụ thể và fixtures kiểm thử.
- **Hard Rule:** Nếu Blueprint thiếu kịch bản test nghiệp vụ người dùng hoặc edge cases ➔ Advisor **REJECT ngay lập tức**.

### 2. Delivery & Release Gate (Sau khi hoàn thành code)
Khi code đã viết xong, test đã chạy và Tier-1 Reviewer đã rà soát:
- **Kiểm chứng độc lập:** Rà soát đóng lỗi triệt để, bảo mật, tác dụng phụ đa file, tính nhất quán AST.
- **Quét bán kính tác động ngược (Reverse Blast Radius):** Dùng `sot_diff_impact` và `sot_usages` để bảo đảm không làm gãy vỡ upstream callers.
- **Bắt buộc Bằng chứng Chạy Test Thực tế (Empirical Test Receipt):**
  - Lệnh đã chạy thực tế (ví dụ `pytest ...`, `npm test ...`).
  - Exit code = 0, số lượng pass/fail/skip.
  - Bằng chứng đã chạy qua các Epic Story và Business Edge Cases đã cam kết trong Blueprint.
- **Hard Rule:** Nghiêm cấm nghiệm thu "bằng mắt" hoặc test giả lập mock sơ sài. Không có bằng chứng test chạy pass ➔ **REJECT**.

---

## 📋 Cấu trúc phản hồi chuẩn (Mandatory Output Schema)

Advisor luôn trả về báo cáo cấu trúc chuẩn xác:

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

Chạy script cài đặt nhanh để đưa subagent vào OpenCode:

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

### 1. Gọi từ Main Agent qua công cụ `task`

Khi Main Agent cần thẩm định kế hoạch hoặc nghiệm thu sản phẩm, gọi công cụ `task` với `subagent_type: "advisor"`:

#### A. Duyệt Kế hoạch (Blueprint Approval):
```json
{
  "description": "Gatekeep architectural blueprint and business test scenarios",
  "prompt": "Evaluate this blueprint for architectural integrity, user business flows, and business edge cases:\n\n<nội dung blueprint>",
  "subagent_type": "advisor"
}
```

#### B. Nghiệm thu Release (Delivery Gate):
```json
{
  "description": "Final gatekeeper release verification",
  "prompt": "Evaluate production code readiness for the completed deliverable.\n\nDiff Target: HEAD~1\nAffected files: <danh sách files>\n\n### Test Execution Receipt:\nCOMMAND: pytest tests/test_payment.py\nEXIT: 0\nRESULT: pass — 12 passed, 0 failed\nCOVERED SCENARIOS: Epic story checkout, double payment edge case, expired card retry.\n\nPlease inspect reverse blast radius with sot_diff_impact / sot_usages and issue the final gatekeeper verdict.",
  "subagent_type": "advisor"
}
```

### 2. Chạy trực tiếp từ dòng lệnh (Standalone CLI)
```bash
opencode run --agent advisor "Thẩm định git diff HEAD~1 và xác minh kết quả test"
```

---

## 🛡️ Quyền hạn & Công cụ (Permissions & Tools)

Theo nguyên tắc an toàn, Advisor là **Read-only Agent**, không được phép sửa code trực tiếp:
- ✅ `read`, `grep`, `glob`: Đọc code và kiểm tra vị trí file.
- ✅ `sot-graph_sot_search`, `sot-graph_sot_map`, `sot-graph_sot_explore`, `sot-graph_sot_usages`, `sot-graph_sot_implementations`: Rà soát đồ thị gọi hàm AST và định danh symbol.
- ✅ `sot-graph_sot_diff_impact`, `sot-graph_sot_diff_impact_receipt`, `sot-graph_sot_scope_receipt`, `sot-graph_sot_verify_drift`: Đo lường bán kính rủi ro git diff.
- ✅ `context-mode_ctx_search`, `context-mode_ctx_execute_file`: Phân tích log/context dung lượng lớn mà không làm tràn context.
- ❌ CẤM: `write`, `edit`, `bash` (không chỉnh sửa file vật lý hay chạy script tuỳ ý).

---

## 📂 Cấu trúc Repository

```text
oc-advisor/
├── README.md                          # Tài liệu hướng dẫn chi tiết
├── install.sh                         # Script cài đặt vào ~/.config/opencode
├── agents/
│   └── advisor.md                     # Agent definition chuẩn OpenCode (mode: all)
└── examples/
    ├── blueprint_approval_prompt.md   # Mẫu prompt duyệt blueprint kèm kịch bản test nghiệp vụ
    ├── delivery_approval_prompt.md    # Mẫu prompt nghiệm thu release kèm Test Receipt
    └── sample_verdicts.md             # Mẫu kết quả phán quyết Approved/Rejected
```

---

## 📜 Giấy phép (License)
MIT License. Tương thích hoàn toàn với hệ sinh thái OpenCode & OMP.
