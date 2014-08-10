Headers(referer = ""){
	global Cookie
	Headers =
	( LTRIM
	Referer: %referer%
	Accept: application/json, text/javascript, */*; q=0.01
	Content-Type: application/x-www-form-urlencoded; charset=UTF-8
	User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko
	Cookie: %cookie%
	)
	return Headers
}