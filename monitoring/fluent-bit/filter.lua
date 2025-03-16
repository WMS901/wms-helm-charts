function filter(tag, timestamp, record)
    print("=== DEBUG: RECORD DUMP ===")

    -- record가 테이블인지 확인
    if type(record) == "table" then
        -- 테이블 내 모든 키와 값 출력
        for k, v in pairs(record) do
            print(k .. ": " .. tostring(v))
        end
    else
        print("Record is not a table: " .. tostring(record))
    end

    -- 'message' 또는 'log' 필드를 가져옴
    local log_message = record["message"] or record["log"]

    if log_message then
        print("Log message: " .. log_message)
    else
        print("No log message found")
    end

    -- "error", "alert", "crit", "emerg"가 포함되면 필터링하여 전달
    if log_message and (string.find(log_message, "error") or string.find(log_message, "alert") or.find(log_message, "emerg")) then
        print("Filtered log: " .. log_message)
        return 1, record  -- 로그를 전달
    else
        print("Log ignored: " .. log_message)
        return 0, record  -- 로그를 무시
    end
end

