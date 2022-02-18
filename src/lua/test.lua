
--http://tassi.web.cs.unibo.it/lua/

local curl = require "curl"

function build_w_cb(t)
	return function(s,l)
		-- stores the received data in the table t
		table.insert(t,s)
		-- return number_of_byte_served, error_message
		-- number_of_byte_served ~= l is an error
		return l,"error message"
	end
end

-- GET test --------------------------------------------------------------------
gl_b = {}
gl_h = {}

c = curl.easy_init() 
--c:setopt(curl.OPT_VERBOSE,1)
c:setopt(curl.OPT_URL,'https://jsonplaceholder.typicode.com/todos/1')
c:setopt(curl.OPT_WRITEFUNCTION,build_w_cb(gl_b))
c:setopt(curl.OPT_HEADERFUNCTION,build_w_cb(gl_h))
--c:setopt(curl.OPT_PROXY,"localhost:3000")
--c:setopt(curl.OPT_PROXYUSERPWD,"ciccio:ciccio")
c:setopt(curl.OPT_HTTPHEADER,{"User-Agent: curl (;;lua;;) luacurl"})
print("\n\t$$ performing... returns code,error $$\n")
print(c:perform())
print("\n\t$$ here you see the header, line per line $$\n")
table.foreach(gl_h,function(i,s) print(i.."= "..string.gsub(s,"\n","")) end)
print("\n\t$$ and here you see the data, after concatenation of "..
	table.getn(gl_b).." chunks $$\n")
print(table.concat(gl_b))


-- POST FORM -------------------------------------------------------------------
--c = curl.easy_init()
--c:setopt(curl.OPT_URL,'http://localhost:3000/')
--c:setopt(curl.OPT_HTTPPOST,{
--
--	{curl.FORM_COPYNAME,"name1",
--	 curl.FORM_COPYCONTENTS,"data1",
--	 curl.FORM_CONTENTTYPE,"Content-type: text/plain",
--	 curl.FORM_END }
--	,
--	{curl.FORM_COPYNAME,"name2",
--	 curl.FORM_COPYCONTENTS,"data2",
--	 curl.FORM_CONTENTTYPE,"Content-type: text/plain",
--	 curl.FORM_END}
--})
--
--print(c:perform())
--

-- EXPLORE THE CURL TABLE ------------------------------------------------------
--table.foreach(curl,print)

-- MISC TEST -------------------------------------------------------------------
print(curl.escape("ciccio=peir!paol$%&ff£()f]fEND"))
print(curl.version())
table.foreach(curl.version_info(),print)
table.foreach(curl.version_info().protocols,print)

-- eof