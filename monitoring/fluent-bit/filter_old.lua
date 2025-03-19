function filter(tag, timestamp, record)
   -- 로그 메시지에서 타임스탬프 추출
   local timestamp_str = record["log"]

   if timestamp_str then
     -- 날짜 부분 추출 (예: "2025-03-05")
     local date_str = timestamp_str:match("(%d%d%d%d-%d%d-%d%d)")

     if date_str then
       -- 년, 월, 일 파싱
       local year, month, day = date_str:match("(%d%d%d%d)-(%d%d)-(%d%d)")
       year = tonumber(year)
       month = tonumber(month)
       day = tonumber(day)

       if year and month and day then
         local log_date = os.time({year = year, month = month, day = day})
         local cutoff_date = os.time({year = 2025, month = 3, day = 6})

         -- 디버깅 출력 (확인용)
         print(string.format("Log date: %d (%s), Cutoff date: %d", log_date, date_str, cutoff_date))

         if log_date < cutoff_date then
           -- 기준일 이전의 로그만 전달 (1 = keep)
           return 2, timestamp, record
         else
           -- 기준일 이후는 삭제 (0 = drop)
           return 0, timestamp, record
         end
       end
     end
   end

   -- 타임스탬프가 파싱 안 되면 삭제
   return 0, timestamp, record
end

