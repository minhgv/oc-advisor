# OpenCode Advisor (`oc-advisor`)

> **Stage-3 Final Gatekeeper & Architectural Authority Subagent for OpenCode**  
> Ported from the architectural gatekeeper mechanism of **OMP ([oh-my-pi](https://github.com/can1357/oh-my-pi))** and aligned with **AI Coding Constitution (v6.10, Art 17.1)**.

---

## 🎯 Giới thiệu (Overview)

Trong các hệ thống đa agent (multi-agent coding systems), rủi ro lớn nhất là:
1. **Spec Drift / Halucination:** Agent tự ý code khi kế hoạch (blueprint) còn mơ hồ, lủng củng hoặc chưa kiểm chứng thực tế mã nguồn.
2. **Review Ping-Pong:** Agent sửa đi sửa lại vòng tròn (infinite fix-review loops) mà không có trọng tài chốt hạ.
3. **Unchecked Blast Radius:** Thay đổi code làm gãy vỡ các caller ở tầng trên mà không được kiểm tra tác động ngược.

**`oc-advisor`** giải quyết triệt để các vấn đề trên bằng cách thiết lập vị trí **Stage-3 Definitive Gatekeeper** trong OpenCode:
- **Độc lập & Khách quan:** Hoạt động như một subagent riêng biệt, không bị cuốn vào thiên kiến của agent đang trực tiếp viết code.
- **Quyền hạn tối cao 1 lần (1-Pass Gate):** Được kích hoạt đúng 1 lần cho mỗi cổng kiểm soát (Blueprint Gate hoặc Delivery Gate). Tuyệt đối không lặp vòng review-fix.
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
│  - Kiểm chứng Invariants & Single Source of Truth           │
│  - Thẩm định Release & Bán kính tác động (Post-Imp)          │
└─────────────────────────────────────────────────────────────┘
```

### 1. Blueprint Approval Gate (Trước khi viết code)
Khi Main Agent lập xong Blueprint hoặc kế hoạch JIT Wave:
- **Xác minh tính khả thi:** Mục tiêu rõ ràng, không có bước mơ hồ, ranh giới sửa đổi (file ownership) phân định rành mạch.
- **Bảo toàn giao ước (Invariants):** Không tự chế thêm thư viện/dependency suy đoán, tuân thủ chặt chẽ quy ước dự án.
- **Ra phán quyết ngay:** `APPROVED` hoặc `REJECTED` (nêu rõ các ràng buộc bị thiếu).

### 2. Delivery & Release Gate (Sau khi hoàn thành code)
Khi code đã viết xong, test đã chạy và Tier-1 Reviewer đã rà soát:
- **Kiểm chứng độc lập:** Rà soát đóng lỗi triệt để, bảo mật, tác dụng phụ đa file, tính nhất quán AST.
- **Quét bán kính tác động ngược (Reverse Blast Radius):** Dùng `sot_diff_impact` và `sot_usages` để bảo đảm không làm gãy vỡ upstream callers.
- **Ra phán quyết chung khảo:** `APPROVED`, `REJECTED`, hoặc `NEEDS_REVISION`.

---

## 📋 Cấu trúc phản hồi chuẩn (Mandatory Output Schema)

Advisor luôn trả về báo cáo cấu trúc chuẩn xác:

```markdown
### ADVISOR VERDICT: [APPROVED | REJECTED | NEEDS_REVISION]
**Executive Summary:** <1-3 câu tóm tắt điều hành đánh giá kiến trúc & bảo mật>
**Verified Invariants:**
- <Invariant 1 được xác minh với thực tế filesystem/codebase>
- <Invariant 2 được xác minh với bán kính tác động SOT-Graph>
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

### Gọi từ Main Agent qua công cụ `task`

Khi Main Agent cần thẩm định kế hoạch hoặc nghiệm thu sản phẩm, gọi công cụ `task` với `subagent_type: "advisor"`:

#### 1. Duyệt Kế hoạch (Blueprint Approval):
```json
{
  "description": "Gatekeep architectural blueprint",
  "prompt": "Evaluate this blueprint for architectural integrity and security risks:\n\n<nội dung blueprint>",
  "subagent_type": "advisor"
}
```

#### 2. Nghiệm thu Release (Delivery Gate):
```json
{
  "description": "Final gatekeeper release verification",
  "prompt": "Evaluate production code readiness for the completed deliverable.\n\nDiff Target: HEAD~1\nAffected files: <danh sách files>\nVerification Evidence: <kết quả test>\n\nPlease inspect reverse blast radius with sot_diff_impact / sot_usages and issue the final gatekeeper verdict.",
  "subagent_type": "advisor"
}
```

---

## 🛡️ Quyền hạn & Công cụ (Permissions & Tools)

Theo nguyên tắc an toàn, Advisor là **Read-only Agent**, không được phép sửa code trực tiếp:
- ✅ `read`, `grep`, `glob`: Đọc code và kiểm tra vị trí file.
- ✅ `sot-graph_sot_search`, `sot-graph_sot_explore`, `sot-graph_sot_usages`: Rà soát đồ thị gọi hàm AST và định danh symbol.
- ✅ `sot-graph_sot_diff_impact`, `sot-graph_sot_verify_drift`: Đo lường bán kính rủi ro git diff.
- ❌ CẤM: `write`, `edit`, `bash` (không chỉnh sửa file vật lý hay chạy script tuỳ ý).

---

## 📂 Cấu trúc Repository

```text
oc-advisor/
├── README.md                          # Tài liệu hướng dẫn chi tiết
├── install.sh                         # Script cài đặt vào ~/.config/opencode
├── agents/
│   └── advisor.md                     # Agent definition chuẩn OpenCode
└── examples/
    ├── blueprint_approval_prompt.md   # Mẫu prompt duyệt blueprint
    ├── delivery_approval_prompt.md    # Mẫu prompt nghiệm thu release
    └── sample_verdicts.md             # Mẫu kết quả phán quyết Approved/Rejected
```

---

## 📜 Giấy phép (License)
MIT License. Tương thích hoàn toàn với hệ sinh thái OpenCode & OMP.
