local xForwardFor =  ngx.var.http_x_forwarded_for;
if xForwardFor then
  local ips={}
  string.gsub(xForwardFor,'[^,]+',function(w) table.insert(ips, w) end )
  if string.find(ngx.var.http_host,"api%-dc",1) == 1 then
    if #ips >= 2 then
      realIp=ips[#ips-1]
    elseif #ips<=1 then
      realIp=ips[1]
    end
  else
   realIp=ips[#ips]
  end
end  

-- if not exist, then setup remote_addr
if realIp == nil then
  realIp = ngx.var.remote_addr;
end

return realIp;
