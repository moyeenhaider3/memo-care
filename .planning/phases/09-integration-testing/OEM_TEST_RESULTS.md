# OEM Test Results — MemoCare v1.0

> **Instructions:** Fill in this template while
> executing the tests from `OEM_TEST_CHECKLIST.md`.
> Record PASS, FAIL, or PARTIAL for each test.
> Take screenshots for any FAIL or PARTIAL result.

---

## Test Environment

| Device # | Manufacturer | Model | Android Ver | OEM UI Ver | Test Date |
| -------- | ------------ | ----- | ----------- | ---------- | --------- |
| 1        |              |       |             |            |           |
| 2        |              |       |             |            |           |
| 3        |              |       |             |            |           |

---

## Results Summary

| Category                | Xiaomi | Samsung | Huawei |
| ----------------------- | ------ | ------- | ------ |
| A. Alarm Reliability    |        |         |        |
| B. Boot Rescheduling    |        |         |        |
| C. Battery Optimization |        |         |        |
| D. Escalation Behavior  |        |         |        |
| E. Permission Flows     |        |         |        |
| F. Cross-Version        |        |         |        |

Fill each cell with: ALL PASS / X of Y PASS / BLOCKED

---

## Detailed Results

### Device 1: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

| Test ID | Result | Notes | Screenshot |
| ------- | ------ | ----- | ---------- |
| A-01    |        |       |            |
| A-02    |        |       |            |
| A-03    |        |       |            |
| A-04    |        |       |            |
| A-05    |        |       |            |
| B-01    |        |       |            |
| B-02    |        |       |            |
| C-01    |        |       |            |
| C-02    |        |       |            |
| C-03    |        |       |            |
| C-04    |        |       |            |
| C-05    |        |       |            |
| C-06    |        |       |            |
| C-07    |        |       |            |
| C-08    |        |       |            |
| C-09    |        |       |            |
| C-10    |        |       |            |
| D-01    |        |       |            |
| D-02    |        |       |            |
| D-03    |        |       |            |
| D-04    |        |       |            |
| E-01    |        |       |            |
| E-02    |        |       |            |
| E-03    |        |       |            |
| E-04    |        |       |            |
| E-05    |        |       |            |
| F-01    |        |       |            |
| F-02    |        |       |            |
| F-03    |        |       |            |
| F-04    |        |       |            |

> Note: Skip OEM-specific tests (C-01 to C-04 for
> Xiaomi only, C-05 to C-07 for Samsung only,
> C-08 to C-10 for Huawei only). Mark N/A for
> tests not applicable to the device's OEM.

---

### Device 2: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

| Test ID | Result | Notes | Screenshot |
| ------- | ------ | ----- | ---------- |
| A-01    |        |       |            |
| A-02    |        |       |            |
| A-03    |        |       |            |
| A-04    |        |       |            |
| A-05    |        |       |            |
| B-01    |        |       |            |
| B-02    |        |       |            |
| C-01    |        |       |            |
| C-02    |        |       |            |
| C-03    |        |       |            |
| C-04    |        |       |            |
| C-05    |        |       |            |
| C-06    |        |       |            |
| C-07    |        |       |            |
| C-08    |        |       |            |
| C-09    |        |       |            |
| C-10    |        |       |            |
| D-01    |        |       |            |
| D-02    |        |       |            |
| D-03    |        |       |            |
| D-04    |        |       |            |
| E-01    |        |       |            |
| E-02    |        |       |            |
| E-03    |        |       |            |
| E-04    |        |       |            |
| E-05    |        |       |            |
| F-01    |        |       |            |
| F-02    |        |       |            |
| F-03    |        |       |            |
| F-04    |        |       |            |

---

### Device 3: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

| Test ID | Result | Notes | Screenshot |
| ------- | ------ | ----- | ---------- |
| A-01    |        |       |            |
| A-02    |        |       |            |
| A-03    |        |       |            |
| A-04    |        |       |            |
| A-05    |        |       |            |
| B-01    |        |       |            |
| B-02    |        |       |            |
| C-01    |        |       |            |
| C-02    |        |       |            |
| C-03    |        |       |            |
| C-04    |        |       |            |
| C-05    |        |       |            |
| C-06    |        |       |            |
| C-07    |        |       |            |
| C-08    |        |       |            |
| C-09    |        |       |            |
| C-10    |        |       |            |
| D-01    |        |       |            |
| D-02    |        |       |            |
| D-03    |        |       |            |
| D-04    |        |       |            |
| E-01    |        |       |            |
| E-02    |        |       |            |
| E-03    |        |       |            |
| E-04    |        |       |            |
| E-05    |        |       |            |
| F-01    |        |       |            |
| F-02    |        |       |            |
| F-03    |        |       |            |
| F-04    |        |       |            |

---

## Issues Found

| Issue # | Test ID | Device | Severity | Description | Workaround | Status |
| ------- | ------- | ------ | -------- | ----------- | ---------- | ------ |
| 1       |         |        |          |             |            |        |
| 2       |         |        |          |             |            |        |
| 3       |         |        |          |             |            |        |

**Severity levels:**

- **P0:** Alarm does not fire at all — blocks release
- **P1:** Alarm delayed >2 min or escalation fails —
  requires fix with timeline
- **P2:** UI/guidance issue, minor timing variance —
  documented for v1.1

---

## Sign-Off

| Role         | Name | Date | Signature |
| ------------ | ---- | ---- | --------- |
| Tester       |      |      |           |
| Developer    |      |      |           |
| Project Lead |      |      |           |

---

## Notes

- Minimum 3 physical devices required (1 per OEM).
- Android versions covered should span at least
  API 31 (12) and API 34 (14).
- **P0 issues block Phase 09 completion.**
- P1 issues require a fix plan with timeline.
- P2 issues documented for v1.1.
- Run tests in order: E → C → A → B → D → F
  (permissions first, then battery, then alarms).
- Allow 2–3 hours per device for full execution.
