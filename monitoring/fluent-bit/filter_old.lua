apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
  namespace: amazon-cloudwatch
data:
  filter.lua: |
    function filter(tag, timestamp, record)
      print("=== DEBUG: RECORD DUMP ===")

      -- record가 테이블인지 확인
      if type(record) == "table" then
        -- 테이블 내 모든 키와 값 출력
        for k, v in pairs(record) do
          print(k .. ": " .. tostring(v))
        end
      else
        print("Record is not a table:" .. tostring(record))
      end

      -- 'message' 또는 'log' 필드를 가져옴
      local log_message = record["message"] or record["log"]

      if log_message then
        print("Log message:" .. log_message)
      else
        print("No log message found")
      end

      -- "error", "alert", "crit", "emerg"가 포함되면 필터링하여 전달
      if log_message and (string.find(log_message, "error") or string.find(log_message, "alert") or string.find(log_message, "crit") or string.find(log_message, "emerg")) then
        print("Filtered log:" .. log_message)
        return 0, record  -- 로그를 전달
      else
        print("Log ignored:" .. log_message)
        return 1, record  -- 로그를 무시
      end
    end

  filter_old.lua: |
    function filter(timestamp, record)
      local log_message = record["log"]
      if not log_message then
        return 0, record -- 로그 메시지가 없으면 무시
      end

      -- 로그 메시지에서 날짜 부분만 추출 (예: 2025-03-10T09:40:38)
      local date_str = string.match(log_message, "^(%d%d%d%d-%d%d-%dT%d%d:%d%d:%d%d)")
      if not date_str then
        return 0, record -- 날짜 형식이 없는 경우 무시
      end

      -- 날짜를 os.time에 적합한 형식으로 변환
      local year, month, day, hour, min, sec = string.match(date_str, "(%d%d%d%d)-(%d%d)-(%d%d)T(%d%d):(%d%d):(%d%d)")
      if not year then
        return 0, record -- 날짜 형식이 잘못된 경우 무시
      end

      -- 날짜를 비교하기 위한 기준 날짜 (2025-03-12)
      local filter_date = "2025-03-12T00:00:00"

      -- 기준 날짜를 os.time에 적합한 형식으로 변환
      local filter_year, filter_month, filter_day = string.match(filter_date, "(%d%d%d%d)-(%d%d)-(%d%d)")
      local filter_timestamp = os.time({year = tonumber(filter_year), month = tonumber(filter_month), day = tonumber(filter_day), hour = 0, min = 0, sec = 0})

      -- 로그의 날짜를 timestamp로 변환
      local log_timestamp = os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = tonumber(hour), min = tonumber(min), sec = tonumber(sec)})

      -- 2025-03-12 이전의 로그를 전달
      if log_timestamp < filter_timestamp then
        return 1, record -- 로그를 전달
      else
        return 0, record -- 로그를 무시
      end
    end

