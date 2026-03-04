local M = {}

function M:peek(job)
    local start = os.clock()
    local cache = ya.file_cache(job)
    if not cache then return end

    local ok, err = self:preload(job)
    if not ok or err then
        return ya.preview_widget(job, err)
    end

    ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))
    local _, err2 = ya.image_show(cache, job.area)
    ya.preview_widget(job, err2)
end

function M:seek(_) end

function M:preload(job)
    local cache = ya.file_cache(job)
    if not cache or fs.cha(cache) then
        return true
    end

    local script = [[
in="$1"
out="$2"
w="$3"
h="$4"

dir="$(dirname "$out")"
mkdir -p "$dir"

# 用更大的边作为缩略图尺寸
if [ "$w" -gt "$h" ]; then s="$w"; else s="$h"; fi

# 生成缩略图（输出到 dir，文件名通常为 原文件名 + .png）
qlmanage -t -s "$s" -o "$dir" "$in" >/dev/null 2>&1 || exit 2

gen="$dir/$(basename "$in").png"
if [ ! -f "$gen" ]; then
  gen="$(ls -t "$dir"/*.png 2>/dev/null | head -n 1 || true)"
fi

[ -f "$gen" ] || exit 3
mv -f "$gen" "$out"
]]

    local status, err = Command("bash")
    :arg({ "-lc", script, "--", tostring(job.file.url), tostring(cache),
           tostring(rt.preview.max_width), tostring(rt.preview.max_height) })
    :status()

    if not status then
        return true, Err("Failed to start `bash`, error: %s", err)
    elseif not status.success then
        return false, Err("`qlmanage` pipeline exited with code: %s", status.code)
    else
        return true
    end
end

return M
