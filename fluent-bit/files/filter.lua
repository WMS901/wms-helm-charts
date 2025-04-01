function filter(tag, timestamp, record)
    print("=== DEBUG: RECORD DUMP ===")

    -- 전체 record 출력
    for k, v in pairs(record) do
        print(k .. ": " .. tostring(v))
    end

    -- log_message를 다양한 방식으로 시도
    local log_message = record["message"] or record["log"] or tostring(record)

    if log_message then
        print("Log message: " .. log_message)
    else
        print("No log message found")
    end

    local log_lower = string.lower(log_message)

    if string.find(log_lower, "error") or string.find(log_lower, "alert")
        or string.find(log_lower, "crit") or string.find(log_lower, "emerg") then
        print("✅ Filtered log: " .. log_message)
        return 0, record
    else
        print("❌ Log ignored: " .. log_message)
        return -1, record
    end
end

