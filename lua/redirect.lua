local var=ngx.var

if var.h == "jd" then
    ngx.redirect("http://jd.com", 302);
elseif var.h == "tb" then
    ngx.redirect("http://taobao.com", 302);
else
    return ngx.exit(403);
end
