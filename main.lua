WIDTH = 800
HEIGHT = 600
BGCOLOR = {0,0,0}

CAMX = 0
CAMY = 0
CAMZ = 0
camspeed = 1
FOV = 70
ASPECT = 16/9
zNEAR = 0.01
zFAR = 1000
SLIDER = 0
SLIDERSPEED = math.pi/24

LIGHTDIR = {0,-1,0}

--Model Class
modelClass = {}
modelClass.__index = modelClass
setmetatable(modelClass, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function modelClass.new(x,y,z,modelpath)
	--Setup stuff
	local self = setmetatable({},modelClass)
	
	--Set up variables
	self.mp = "models/" .. modelpath
	
	self.rotX = 0
	self.rotY = 0
	self.rotZ = 0
	
	self.x = x
	self.y = y
	self.z = z
	
	self.modeldata = {}
	self.vertices = {}
	self.vnormals = {}
	self.faces = {}
	
	--Return self (always has to be done last)
	return self
end

function modelClass:load()
	self.modeldata = lines_from(self.mp)
	for _,i in ipairs(self.modeldata) do
		--print('line['.._..']',i)
		local line = i
		if string.sub(line,1,2) == "v " then
			local vline = splitstring(line:sub(3)," ")
			
			local xyz = toWorldSpace(self.x,self.y,self.z,vline[1],vline[2],vline[3])
			xyz = toCamSpace(xyz[1],xyz[2],xyz[3])
	
			local DTC = math.sqrt(xyz[1]*xyz[1] + xyz[2]*xyz[2] + xyz[3]*xyz[3])
			
			table.insert(self.vertices,{vline[1],vline[2],vline[3],DTC})
		elseif string.sub(line,1,2) == "f " then
			local vline = splitstring(line:sub(3)," ")
			table.insert(self.faces,{vline[1],vline[2],vline[3]})
			--print("F: "..vline[1].."; "..vline[2].."; "..vline[3])
		elseif string.sub(line,1,2) == "vn " then
			local vline = splitstring(line:sub(3)," ")
			table.insert(self.vnormals,{vline[1],vline[2],vline[3]})
		end
	end
	
	table.sort(self.vertices,cDistToCam)
	--for _,v in ipairs(self.vertices) do
		--print(v[4])
	--end
	--return self.modeldata
end

function modelClass:drawFaces()
	for _,f in ipairs(self.faces) do
		local v1 = tonumber(splitstring(f[1],"//")[1])
		local v2 = tonumber(splitstring(f[2],"//")[1])
		local v3 = tonumber(splitstring(f[3],"//")[1])
		
		local x1 = self.vertices[v1][1]*50
		local y1 = self.vertices[v1][2]*50
		local z1 = self.vertices[v1][3]/2
		
		x1 = rotateY(x1,z1,self.rotY)[1]
		z1 = rotateY(x1,z1,self.rotY)[2]
		
		local xyz1 = toWorldSpace(self.x,self.y,self.z,x1,y1,z1)
		xyz1 = toCamSpace(xyz1[1],xyz1[2],xyz1[3])
		x1 = xyz1[1]
		y1 = xyz1[2]
		z1 = xyz1[3]
		
		local sx1 = x1/z1 + WIDTH/2
		local sy1 = y1/z1 + HEIGHT/2
		
		local x2 = self.vertices[v2][1]*50
		local y2 = self.vertices[v2][2]*50
		local z2 = self.vertices[v2][3]/2
		
		x2 = rotateY(x2,z2,self.rotY)[1]
		z2 = rotateY(x2,z2,self.rotY)[2]
		
		local xyz2 = toWorldSpace(self.x,self.y,self.z,x2,y2,z2)
		xyz2 = toCamSpace(xyz2[1],xyz2[2],xyz2[3])
		x2 = xyz2[1]
		y2 = xyz2[2]
		z2 = xyz2[3]
		
		local sx2 = x2/z2 + WIDTH/2
		local sy2 = y2/z2 + HEIGHT/2
		
		local x3 = self.vertices[v3][1]*50
		local y3 = self.vertices[v3][2]*50
		local z3 = self.vertices[v3][3]/2
		
		x3 = rotateY(x3,z3,self.rotY)[1]
		z3 = rotateY(x3,z3,self.rotY)[2]
		
		local xyz3 = toWorldSpace(self.x,self.y,self.z,x3,y3,z3)
		xyz3 = toCamSpace(xyz3[1],xyz3[2],xyz3[3])
		x3 = xyz3[1]
		y3 = xyz3[2]
		z3 = xyz3[3]
		
		local sx3 = x3/z3 + WIDTH/2
		local sy3 = y3/z3 + HEIGHT/2
		
		love.graphics.setColor(255,0,0)
		love.graphics.polygon("fill",sx1,sy1,sx2,sy2,sx3,sy3)
	end
end

--Functions
function cDistToCam(a,b)
	return a[4] > b[4]
end

function splitstring(inputstr, sep)
        if sep == nil then
            sep = "%s"
        end
        local t = {}
		local i = 1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
			--print(str)
        end
        return t
end

function file_exists(file)
	--local f = io.open(file, "rb")
	--if f then f:close() end
	--return f ~= nil
	return love.filesystem.isFile(file)
end

function lines_from(file)
	if not file_exists(file) then
		print("File ['" .. file .. "'] does not exist")
		return {}
	end
	local flines = {}
	for line in love.filesystem.lines(file) do
		flines[#flines + 1] = line
	end
	--print("flines:")
	--print(flines)
	return flines
end

function toWorldSpace(x,y,z,vx,vy,vz)
	local rx = x + vx
	local ry = y + vy
	local rz = z + vz
	return {rx,ry,rz}
end

function toCamSpace(vx,vy,vz)
	return {vx-CAMX,vy-CAMY,vz-CAMZ}
end

function rotateX(y,z,r)
	local sy = y/50
	local sz = z*2
	local ry = (sy*math.cos(r) - sz*math.sin(r))*50
	local rz = (sz*math.cos(r) - sy*math.sin(r))/2
	return {ry,rz}
end

function rotateY(x,z,r)
	local sx = x/50
	local sz = z*2
	local rx = (sx*math.cos(r) - sz*math.sin(r))*50
	local rz = (sz*math.cos(r) - sx*math.sin(r))/2
	return {rx,rz}
end

function rotateZ(x,y,r)
	local sx = x/50
	local sy = y/50
	local rx = (sx*math.cos(r) - sy*math.sin(r))*50
	local ry = (sy*math.cos(r) - sx*math.sin(r))/2
	return {rx,ry}
end

--Love2D functions (plus some more, like loading some models and such)
local modeltest = modelClass.new(0,0,5,"cube.obj")

function love.load()
	modeltest:load()
	--modeltest:drawFaces()
end

function love.update(dt)
	
end

function love.draw()
	modeltest:drawFaces()
end