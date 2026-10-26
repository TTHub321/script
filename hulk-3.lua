--[[
	HULKBUSTER V10
	V10.13c: THAO GIAP (Tool 1 x2) LUC GIAP DANG NAN HO DEN -> 2 canh tay chinh bay toi nang qua cau len, dung luc nem sang huong khac, qua cau bay that xa roi bien mat
	V10.13b: THAO GIAP (Tool 1 bam 2 lan) TRONG KHONG GIAN KY AO = giu nguyen khong gian (dem nguoc / sup do tiep tuc), khong con bi dua ve cho cu | cac phan cua khong gian lay vi tri tu nhan vat khi khong co giap
	V10.13: TU CUU KHI KHONG GIAN SUP DO MA DUOI KHONG CO DAT (CFG.Rescue): dang mac giap -> tu bay luon | giap tach roi o xa (>= RescueNear) -> 2 cong dich chuyen 0.5s, giap chui qua cong, bay toi chu, mac 0.5s, vao bay | giap gan -> bay sieu nhanh toi, hop the lien | chua mac / chua co giap -> cac bo phan tu vu tru bay vao ~1s, tu vao bay
	V10.12: trong khong gian ky ao Tool1 x4 = hien CHI DUONG toi ho den + DEM NGUOC 180s (khong thoat truc tiep) | het gio chua thoat: khong gian vo vun, bau troi toi vo ra tra ve nhu cu, ho den/ho trang tan bien, chi duong ve cho cu truoc khi bi hut, ve toi noi thi tu tat
	V10.11: cham ho den -> hut vao nhanh (0.8s), ho den DICH CHUYEN THEO vao khong gian ky ao va nam tren troi (NX.RLM.HoleSky) | bay/nhay len cham ho den -> thoat ra tu HO TRANG (NX.whiteHole), ho trang tan dan roi bien mat
	V10.10: khong gian ky ao GAN lai nguyen khoi: dat ngay tren dau nguoi choi (NX.RLM.Lift = 250 stud) thay vi toa do co dinh 0,7000,0 o xa (NX.placeRealm)
	V10.9: khong gian ky ao gan lai (NX.RLM: LoadR 1700, Fog 300-1400, NearR 600) | bom nguyen tu: nho gon (NukeRadius 60), dep + chan that hon (chop sang, tia sang, may ngung tu, than nam thon dan co lac) | XA BOM (>350 stud, CFG.NukeFeelRange) = khong tieng, khong rung, khong chop/doi mau man hinh; doi mau chi lan tu tam no ra vung gan
	V10.8: cot sap xep ngau nhien, khong thanh hang (NX.RLM: Jitter 1.0, Rot 0.5 xoay moi cot, kich thuoc cot 54-96 stud tung cai mot)
	V10.7: cot gan hon nua (NX.RLM: Cell 120, WMin/WMax 0.55-0.75, cot van nho ~66-90 stud, khe ~30-54 stud) | V10.6: cot gan lai + nho di (NX.RLM: Cell 160, WMin/WMax 0.4-0.55, Skip 0) | V10.5: cot cach xa (Cell 260) -> qua thua
	V10.4: cot day dac, khong con o trong (cot chom nhe len nhau, Skip = 0) | san chinh phu den deu (9 den diu, vua du) | cot quanh xit sat cot chinh (khoang ho 10 stud) | sua logic bam tool (chong ket busy, chong dem doi, thoat khong gian ky ao luon duoc)
	V10.3: cot chinh/san 192 stud, cot khac x3, cot quanh be cao ngang/hon san, pham vi + suong mu x2.4 (NX.RLM)
	V10.2: bo bac thang tren cot | ho den: cau sat x5, gom that nhieu sat, nen cham thanh ho den tim to (chinh trong NX.HOLE)
	V10.1: khong gian ky ao x3 pham vi, vo tan (sinh cot theo nguoi choi), cot thua + to, bo den neon, toi nhu anh (chinh trong NX.RLM)
	V10: BAM 4 LAN (dung khi mac giap / giap tach roi): Tool1 = ho den sat vun -> khong gian ky ao (x4 lai de ve) | Tool2 = chan phai dap -> cau nano -> balo sat bay vu tru | Tool3 = 2 tay phu tao cap cong dich chuyen
	BusterArmor : 1 = bien hinh (nano) / dam lao toi | 2 = thao giap | 3 = bat/tat man hinh quet + ESP
	BusterFly   : 1 = canh + bay 120 | dang bay: 1 = phao ten lua | 2 = thao canh, ha canh an toan
	BusterAttack: 1 = trieu hoi 2 tay phu | tiep = 4 tay dam lien hoan | 2 = thao | 3 = bom nguyen tu
	Bay: WASD / joystick theo camera, Space len, LeftCtrl xuong
	V9: nhay/dap = co che bay v3 (khong mat mau) | giam anh sang | bien hinh: bo phan tu khong gian + nano |
	    tach giap: bay tan vao vu tru | BusterFly bam 3 = ra/vao giap, giap tu di theo, tu bay khi chay nhanh
	V9.2: Tool 1 mac giap kieu hop the: chan bay lai -> ong chan nang nguoi -> lung -> 2 hong -> bung -> than/tay/dau -> cua dong lai
	V9.1: bo godmode ao | trong luc luc nhay = 60% goc | mat truoc giap mo that (cua ban le) |
	      hop the: chan + thruster bay toi truoc, nang nguoi len lo lung, cac bo phan ghep dung cho roi cua dong lai
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local StatsService = game:GetService("Stats")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

pcall(function()
	if getgenv then
		if getgenv().BusterCleanup then getgenv().BusterCleanup() end
		if getgenv().HulkbusterCleanup then getgenv().HulkbusterCleanup() end
	end
end)

------------------------------------------------------------------
-- CAU HINH
------------------------------------------------------------------
local CFG = {
	Scale = 0.9,
	WalkMult = 2.0, JumpMult = 1.5,
	FlySpeed = 120, SafeLandSpeed = 80,
	LeapPower = 75, StompSpeed = 95,       -- LeapPower: van toc bat nhay (giam tu 75) | StompSpeed: dap chan khi roi tu cao
	JumpGravity = 0.7,                      -- trong luc khi nhay = 70% goc
	LeapLandSpeed = 80,                     -- toc do ha xuong toi da khi nhay (CFrame, khong mat mau)
	LandTouchSpeed = 6,                     -- toc do luc cham dat (giam dan khi gan mat dat)
	AutoLandSpeed = 22,                     -- roi nhanh hon muc nay => chuyen sang ha canh CFrame (truoc: 46)
	SoftWalls = true,                       -- giam toc truoc khi dam tuong khi di bo
	HoverRise = 2.6,                        -- do cao lo lung them khi hop the (stud)
	Rescue = true,          -- V10.13: tu cuu khi khong gian sup do ma ben duoi khong con dat
	RescueNear = 60,        -- giap tach roi gan hon muc nay = bay sieu nhanh toi + hop the lien (xa hon = qua cong dich chuyen)
	RescueFallTime = 0.25,  -- phai het dat duoi chan lien tuc ngan nay moi kich hoat (giay)
	RescueRay = 15,         -- tia do mat dat phia duoi (stud): khong trung gi = khong co dat
	DroneFlySpeed = 260, DroneAutoFlySpeed = 60,  -- giap roi tu bay khi chu chay > 60 st/s
	GravityMult = 0.8,      -- trong luc giam 20% khi mac giap
	FallSlow = 0.4,         -- toc do roi giam 40%
	MaxFallSpeed = 55,
	ClickWindow = 0.42,
	MissilesPerClick = 4, MissileSpeed = 260, MissileRadius = 26,
	PunchLunge = 75,
	NukeCharge = 4.2, NukeBall = 7.5, NukeSpeed = 190,
	NukeRadius = 60,         -- V10.9: bom nho gon (truoc 150)
	NukeFullRange = 80,      -- V10.9: dung trong ban kinh nay = tieng/rung/chop sang het co
	NukeFeelRange = 350,     -- V10.9: xa hon muc nay = KHONG tieng, KHONG rung, KHONG chop man hinh, KHONG doi mau (giam dan tu FullRange toi FeelRange)
	ScanOverlayTransparency = 0.8,
	ScanColor = Color3.fromRGB(0, 90, 170),
}

local COL = {
	Red = Color3.fromRGB(152, 14, 18), DarkRed = Color3.fromRGB(98, 9, 14), DeepRed = Color3.fromRGB(66, 7, 10),
	Gold = Color3.fromRGB(228, 178, 42), DarkGold = Color3.fromRGB(168, 122, 22),
	Glow = Color3.fromRGB(150, 240, 255), White = Color3.fromRGB(238, 250, 255),
	Metal = Color3.fromRGB(72, 76, 84), MetalDark = Color3.fromRGB(36, 38, 44), Black = Color3.fromRGB(16, 16, 18),
	Fire = Color3.fromRGB(255, 150, 40), WingGlow = Color3.fromRGB(90, 185, 215),
}

local NEON, METAL, SMOOTH = Enum.Material.Neon, Enum.Material.Metal, Enum.Material.SmoothPlastic
local BALL, CYL = Enum.PartType.Ball, Enum.PartType.Cylinder
local SC = CFG.Scale
local LB = 6.6 * SC
local KK = 1
local I = CFrame.new()

------------------------------------------------------------------
-- TRANG THAI
------------------------------------------------------------------
local function newState()
	return {
		on = false, assembling = false, flying = false, ctrl = nil, mode = "idle", nuking = false,
		t = 0, wC = 0, flyW = 0, thrW = 0, recoil = 0, chargeA = 0, stW = 0, twS = 0,
		phase = 0, walkW = 0, airW = 0, upW = 0, land = 0, stepIdx = 0, tiltW = 0, fix = 0,
		fpos = Vector3.zero, fvel = Vector3.zero, frot = CFrame.new(),
		rootY = 0, stuckT = 0, lastVy = 0, burstUntil = 0, noColUntil = 0, colOn = false,
		idle = {next = 2.5}, strikes = {}, kick = 0,
		parts = {}, arms = {}, drive = {}, flames = {}, conns = {}, hidden = {},
		sh = {mag = 0, t0 = 0, dur = 0.01},
		owner = {}, drone = false, dmode = "walk", dvel = Vector3.zero, dhold = false, busy = false, openW = 0, openGoal = 0,
		ospd = 0, dflyUntil = 0, dstuck = 0, dair = false, stomp = false,
		cavity = false, hoverFeet = false, hoverBack = false,
	}
end
local S = newState()

-- V10: trang thai 3 chieu bam 4 lan (code o khoi V10 phia duoi)
local NX = {
	upW = 0, upGoal = 0, dropV = 0,
	stompT0 = nil, stompDur = 1, stompEvt = false,
	hole = nil, realm = false, sucking = false, tpCd = 0,
	plist = {}, portals = {}, bridges = {},
}
NX.cleanup = function() end

local FX = Instance.new("Folder")
FX.Name = "HB_FX"
FX.Parent = Workspace

------------------------------------------------------------------
-- TIEN ICH
------------------------------------------------------------------
local function fr(a, b) return a + (b - a) * math.random() end
local function lerp(a, b, t) return a + (b - a) * t end
local function ease(c, g, rate, dt) return c + (g - c) * math.min(1, dt * rate) end
local function tw(obj, t, props, style, dir)
	local x = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	x:Play()
	return x
end

local function getChar()
	local c = player.Character
	if not c then return end
	local hrp = c:FindFirstChild("HumanoidRootPart")
	local hum = c:FindFirstChildOfClass("Humanoid")
	if hrp and hum and hum.Health > 0 then return c, hrp, hum end
end

local function v3(x, y, z)
	local k = SC * KK
	return Vector3.new(math.max(0.05, x * k), math.max(0.05, y * k), math.max(0.05, z * k))
end
local function cf(x, y, z, rx, ry, rz)
	return CFrame.new(x * SC * KK, y * SC * KK, z * SC * KK) * CFrame.Angles(rx or 0, ry or 0, rz or 0)
end

local function rayParams()
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	local list = {FX}
	if S.char then table.insert(list, S.char) end
	rp.FilterDescendantsInstances = list
	return rp
end

local function groundPos()
	local hp = S.hrp and S.hrp.Position or Vector3.zero
	local res = Workspace:Raycast(hp, Vector3.new(0, -120, 0), rayParams())
	return res and res.Position or (hp - Vector3.new(0, 4, 0))
end

local function shake(mag, dur)
	local el = os.clock() - S.sh.t0
	local cur = S.sh.mag * math.max(0, 1 - el / S.sh.dur)
	if mag >= cur then S.sh.mag, S.sh.t0, S.sh.dur = mag, os.clock(), dur end
end

local function mk(name, size, color, mat, shape)
	local p = Instance.new("Part")
	p.Name = "B_" .. name
	p.Size = size
	p.Color = color
	local refl = 0
	if mat == nil then
		if color == COL.Red or color == COL.DarkRed or color == COL.DeepRed then mat, refl = SMOOTH, 0.16
		elseif color == COL.Gold or color == COL.DarkGold then mat, refl = METAL, 0.28
		else mat, refl = METAL, 0.08 end
	elseif mat == METAL then refl = 0.1 end
	p.Material = mat
	p.Reflectance = refl
	if shape then p.Shape = shape end
	p.Anchored = false
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.CastShadow = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if S.hrp then p.CFrame = S.hrp.CFrame end
	return p
end

local function put(p)
	p.Parent = S.armor
	if S.collect then table.insert(S.collect, p) end
	return p
end

local function D(par, name, sz, off, color, mat, shape)
	local p = put(mk(name, v3(sz[1], sz[2], sz[3]), color, mat, shape))
	local w = Instance.new("Weld")
	w.Part0 = par
	w.Part1 = p
	w.C0 = off
	w.Parent = p
	S.owner[p] = S.owner[par] or par
	return p
end
local function cylV(par, name, len, diam, off, color, mat)
	return D(par, name, {len, diam, diam}, off * CFrame.Angles(0, 0, math.pi / 2), color, mat, CYL)
end
local function cylZ(par, name, len, diam, off, color, mat)
	return D(par, name, {len, diam, diam}, off * CFrame.Angles(0, math.pi / 2, 0), color, mat, CYL)
end
local function rivets(par, pts, sz, col)
	for _, p in ipairs(pts) do D(par, "Rv", {sz, sz, sz}, cf(p[1], p[2], p[3]), col or COL.DarkGold, METAL, BALL) end
end

local function mkJoint(name, p0, p1, a0, a1)
	local m = Instance.new("Motor6D")
	m.Name = "B_" .. name
	m.Part0 = p0
	m.Part1 = p1
	m.C0 = CFrame.new(a0 * (SC * KK))
	m.C1 = CFrame.new(a1 * (SC * KK))
	m.Parent = p1
	return {m = m, key = name, c0 = m.C0}
end

local function fxPart(name, size, color, mat, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = mat or NEON
	if shape then p.Shape = shape end
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Parent = FX
	return p
end
-- ellipsoid that can be resized non-uniformly
local function fxSphere(name, size, color, mat)
	local p = fxPart(name, size, color, mat, nil)
	local m = Instance.new("SpecialMesh")
	m.MeshType = Enum.MeshType.Sphere
	m.Parent = p
	return p
end

local function playSound(id, vol, speed)
	pcall(function()
		local s = Instance.new("Sound")
		s.SoundId = id
		s.Volume = vol or 1
		s.PlaybackSpeed = speed or 1
		s.Parent = FX
		s:Play()
		Debris:AddItem(s, 10)
	end)
end
local SND_BOOM = "rbxasset://sounds/impact_explosion_03.mp3"
local SND_ROCKET = "rbxasset://sounds/Rocket shot.wav"

------------------------------------------------------------------
-- HIEU UNG CHUNG
------------------------------------------------------------------
local SMOKE_TEX = "rbxasset://textures/particles/smoke_main.dds"
local FIRE_TEX = "rbxasset://textures/particles/fire_main.dds"

local function mkEmitter(parent, o)
	local e = Instance.new("ParticleEmitter")
	e.Texture = o.tex or SMOKE_TEX
	e.Color = o.color
	e.LightEmission = o.light or 0
	e.Size = o.size
	e.Transparency = o.transp or NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})
	e.Lifetime = o.life
	e.Speed = o.speed
	e.Rate = o.rate or 0
	e.Rotation = NumberRange.new(0, 360)
	e.RotSpeed = NumberRange.new(-40, 40)
	e.SpreadAngle = o.spread or Vector2.new(180, 180)
	e.Drag = o.drag or 0
	e.Acceleration = o.acc or Vector3.zero
	e.LockedToPart = false
	e.Parent = parent
	if o.shape then
		pcall(function()
			e.Shape = o.shape
			e.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
			e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
		end)
	end
	return e
end

local function ringFx(pos, radius, color, dur)
	dur = dur or 0.6
	local r = fxPart("Ring", Vector3.new(0.4, 2, 2), color or COL.Glow, NEON, CYL)
	r.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2)
	r.Transparency = 0.45
	tw(r, dur, {Size = Vector3.new(0.4, radius * 2, radius * 2), Transparency = 1})
	Debris:AddItem(r, dur + 0.1)
end

local function sparks(pos, n, color, dist, life)
	for _ = 1, n do
		local d = Vector3.new(fr(-1, 1), fr(0, 1), fr(-1, 1))
		if d.Magnitude < 0.05 then d = Vector3.yAxis end
		d = d.Unit
		local p = fxPart("Spark", Vector3.new(0.25, 0.25, 0.9), color, NEON)
		p.CFrame = CFrame.lookAt(pos, pos + d)
		local e = pos + d * dist * fr(0.5, 1.2)
		tw(p, life, {CFrame = CFrame.lookAt(e, e + d), Transparency = 1, Size = Vector3.new(0.08, 0.08, 0.3)})
		Debris:AddItem(p, life + 0.1)
	end
end

local function dustBurst(pos, size, n, color, life)
	local p = fxPart("DustEm", Vector3.one, COL.Black, NEON)
	p.Transparency = 1
	p.CFrame = CFrame.new(pos)
	local e = mkEmitter(p, {
		life = NumberRange.new(life * 0.6, life), speed = NumberRange.new(size * 0.6, size * 1.8), drag = 3,
		acc = Vector3.new(0, 3, 0), spread = Vector2.new(85, 85),
		color = ColorSequence.new(color or Color3.fromRGB(150, 130, 105)),
		size = NumberSequence.new({NumberSequenceKeypoint.new(0, size * 0.25), NumberSequenceKeypoint.new(1, size * 0.9)}),
		transp = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1)}),
	})
	e:Emit(n)
	Debris:AddItem(p, life + 1)
end

local function debrisChunks(pos, n, speed, big)
	for _ = 1, n do
		local sz = fr(0.4, big and 3 or 1.4)
		local p = Instance.new("Part")
		p.Size = Vector3.new(sz, sz * fr(0.6, 1), sz)
		p.Color = Color3.fromRGB(math.random(70, 110), math.random(60, 90), math.random(50, 70))
		p.Material = Enum.Material.Slate
		p.CanTouch = false
		p.CanQuery = false
		p.CFrame = CFrame.new(pos + Vector3.new(fr(-2, 2), 1, fr(-2, 2))) * CFrame.Angles(fr(0, 6), fr(0, 6), 0)
		p.Parent = FX
		p.AssemblyLinearVelocity = Vector3.new(fr(-speed, speed), fr(speed * 0.6, speed * 1.6), fr(-speed, speed))
		p.AssemblyAngularVelocity = Vector3.new(fr(-8, 8), fr(-8, 8), fr(-8, 8))
		Debris:AddItem(p, 5)
	end
end

local function bolt(p0, p1, color, thick)
	local dir = p1 - p0
	local len = dir.Magnitude
	if len < 0.5 then return end
	local u = dir.Unit
	local rv = u:Cross(Vector3.yAxis)
	if rv.Magnitude < 0.1 then rv = u:Cross(Vector3.xAxis) end
	rv = rv.Unit
	local uv = u:Cross(rv)
	local pts = {p0}
	local n = 7
	for i = 1, n - 1 do
		local f = i / n
		local amp = math.sin(f * math.pi) * len * 0.12
		pts[#pts + 1] = p0 + dir * f + rv * fr(-amp, amp) + uv * fr(-amp, amp)
	end
	pts[#pts + 1] = p1
	for i = 1, #pts - 1 do
		local a, b = pts[i], pts[i + 1]
		local seg = fxPart("Bolt", Vector3.new(thick, thick, math.max(0.1, (b - a).Magnitude)), color, NEON)
		seg.CFrame = CFrame.lookAt((a + b) / 2, b)
		Debris:AddItem(seg, 0.09)
	end
end

-- Dap dat / nhay
local function slamFx(power)
	if not S.hrp then return end
	power = math.clamp(power, 0.15, 1)
	local pos = groundPos() + Vector3.new(0, 0.15, 0)
	shake(0.45 + 1.1 * power, 0.22 + 0.35 * power)
	ringFx(pos, 9 + 24 * power, Color3.fromRGB(235, 215, 185), 0.55)
	ringFx(pos, 5 + 12 * power, COL.WingGlow, 0.4)
	dustBurst(pos, 8 + 14 * power, 14 + math.floor(30 * power), nil, 1.8)
	if power > 0.3 then
		local n = 6 + math.floor(9 * power)
		for i = 1, n do
			local a = (i / n) * math.pi * 2 + fr(-0.2, 0.2)
			local dirv = Vector3.new(math.cos(a), 0, math.sin(a))
			local len = fr(5, 11) * (0.5 + power)
			local c = fxPart("Crack", Vector3.new(0.3, 0.1, len), Color3.fromRGB(255, 130, 40), NEON)
			c.CFrame = CFrame.lookAt(pos + dirv * (len / 2 + 1.5), pos + dirv * (len + 3)) + Vector3.new(0, 0.05, 0)
			tw(c, 1.6, {Transparency = 1, Color = Color3.fromRGB(40, 20, 10)}, Enum.EasingStyle.Linear)
			Debris:AddItem(c, 1.7)
		end
		debrisChunks(pos, 6 + math.floor(16 * power), 18 + 22 * power, false)
	end
end

local function jumpFx()
	if not S.hrp then return end
	local pos = groundPos() + Vector3.new(0, 0.15, 0)
	S.burstUntil = os.clock() + 0.4
	ringFx(pos, 12, Color3.fromRGB(230, 215, 190), 0.45)
	dustBurst(pos, 9, 20, nil, 1.4)
	shake(0.4, 0.2)
end

------------------------------------------------------------------
-- TAY / NGON TAY
------------------------------------------------------------------
local SEG = {1.0, 1.0, 0.7}
local function applyFingers(A, c, t, wig)
	local s = A.side
	for i, f in ipairs(A.fingers) do
		local ci = math.max(0, c + wig * math.sin(t * 1.3 + i * 1.1 + s * 0.7))
		for k, j in ipairs(f.j) do
			j.m.C0 = j.c0 * CFrame.Angles(0, 0, -s * ci * f.m * SEG[k])
		end
	end
end

local function addFlame(par, off, foot)
	local em = D(par, "ThrEm", {0.3, 0.3, 0.3}, off, COL.Black)
	em.Transparency = 1
	local at = Instance.new("Attachment")
	at.Parent = em
	local e = Instance.new("ParticleEmitter")
	e.Color = ColorSequence.new(Color3.fromRGB(255, 225, 160), Color3.fromRGB(255, 90, 30))
	e.LightEmission = 0.5
	e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.1 * SC), NumberSequenceKeypoint.new(1, 0)})
	e.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 1)})
	e.Lifetime = NumberRange.new(0.25, 0.45)
	e.Speed = NumberRange.new(18, 28)
	e.Rate = 110
	e.EmissionDirection = Enum.NormalId.Bottom
	e.Enabled = false
	e.Parent = at
	local l = Instance.new("PointLight")
	l.Color = Color3.fromRGB(255, 160, 80)
	l.Range = 9
	l.Brightness = 0
	l.Parent = em
	table.insert(S.flames, {e = e, l = l, foot = foot})
end

local function buildArm(parent, s, anchor, k, opts)
	opts = opts or {}
	local main = opts.main
	local sk = s == 1 and "R" or "L"
	KK = k
	local A = {side = s, fingers = {}}
	local P = S.parts
	local R_, DR, G, DG, M, MD, BK, GL, WH = COL.Red, COL.DarkRed, COL.Gold, COL.DarkGold, COL.Metal, COL.MetalDark, COL.Black, COL.Glow, COL.White

	-- canh tay tren
	local upper = put(mk("UArm" .. sk, v3(2.0, 2.8, 2.0), R_))
	local sj = mkJoint(main and (sk .. "Shoulder") or ("XSh" .. sk), parent, upper, anchor, Vector3.new(0, 1.1, 0))
	if main then table.insert(S.drive, sj) end
	A.sh = sj
	D(upper, "ShCap", {2.35, 0.9, 2.35}, cf(0, 1.15, 0), DR)
	D(upper, "ShCapG", {2.45, 0.2, 2.45}, cf(0, 0.68, 0), G)
	D(upper, "Band1", {2.15, 0.34, 2.15}, cf(0, 0.2, 0), G)
	D(upper, "Band2", {2.12, 0.28, 2.12}, cf(0, -0.85, 0), DG)
	D(upper, "Bicep", {1.6, 1.3, 0.45}, cf(0, 0.0, -1.1), DR)
	D(upper, "ChevA", {1.0, 0.14, 0.5}, cf(-0.4, 0.3, -1.15, 0, 0, 0.3), G)
	D(upper, "ChevB", {1.0, 0.14, 0.5}, cf(0.4, 0.3, -1.15, 0, 0, -0.3), G)
	D(upper, "Tricep", {1.7, 1.5, 0.4}, cf(0, -0.1, 1.1), M)
	D(upper, "USide", {0.4, 1.6, 1.4}, cf(s * 1.05, -0.2, 0), R_)
	D(upper, "USideG", {0.45, 0.2, 1.5}, cf(s * 1.05, 0.55, 0), G)
	cylV(upper, "UPist", 2.2, 0.36, cf(-s * 0.7, -0.1, 1.2), M)
	cylV(upper, "UPistR", 1.1, 0.2, cf(-s * 0.7, 0.9, 1.2), WH)
	D(upper, "EBall", {1.95, 1.95, 1.95}, cf(0, -1.4, 0), MD, METAL, BALL)
	D(upper, "EGuard", {1.8, 0.5, 0.9}, cf(0, -1.45, 0.95), G)
	rivets(upper, {{-0.7, 0.2, -1.1}, {0.7, 0.2, -1.1}, {-0.7, -0.85, -1.1}, {0.7, -0.85, -1.1}}, 0.16)
	if opts.energy then
		local sock = D(upper, "Sock", {1.1, 1.1, 1.1}, cf(0, 1.4, 0), GL, NEON, BALL)
		local pl = Instance.new("PointLight")
		pl.Color = GL
		pl.Range = 10
		pl.Brightness = 1.5
		pl.Parent = sock
		cylV(upper, "Halo", 0.18, 3.0, cf(0, 1.65, 0), GL, NEON).Transparency = 0.4
		cylV(upper, "Halo2", 0.12, 2.5, cf(0, 1.95, 0), WH, NEON).Transparency = 0.5
		local pe = Instance.new("ParticleEmitter")
		pe.Color = ColorSequence.new(GL)
		pe.LightEmission = 0.8
		pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0)})
		pe.Lifetime = NumberRange.new(0.5, 0.9)
		pe.Speed = NumberRange.new(2, 5)
		pe.Rate = 16
		pe.SpreadAngle = Vector2.new(180, 180)
		pe.Parent = sock
		-- hover thruster
		cylV(upper, "HoverN", 0.5, 1.2, cf(0, 2.1, 0), MD, METAL)
	end

	-- cang tay
	local fore = put(mk("FArm" .. sk, v3(2.4, 3.0, 2.4), DR))
	local ej = mkJoint(main and (sk .. "Elbow") or ("XEl" .. sk), upper, fore, Vector3.new(0, -1.4, 0), Vector3.new(0, 1.3, 0))
	if main then table.insert(S.drive, ej) end
	A.el = ej
	D(fore, "EPlate", {2.55, 0.45, 2.55}, cf(0, 1.3, 0), G)
	D(fore, "FPlate", {2.1, 2.2, 0.5}, cf(0, -0.15, -1.3), R_)
	D(fore, "FPlateG", {1.7, 0.28, 0.55}, cf(0, 0.95, -1.3), G)
	D(fore, "FPlateS", {1.2, 0.12, 0.55}, cf(0, 0.1, -1.32), DG)
	D(fore, "FShield", {0.4, 2.8, 2.3}, cf(s * 1.3, -0.1, 0), G)
	D(fore, "FShieldR", {0.46, 1.9, 1.5}, cf(s * 1.3, -0.1, 0), DG)
	D(fore, "FShieldE", {0.5, 0.2, 2.35}, cf(s * 1.3, -1.45, 0), DR)
	D(fore, "FInner", {0.3, 2.0, 1.6}, cf(-s * 1.25, -0.2, 0), M)
	D(fore, "FVent", {1.8, 1.6, 0.35}, cf(0, -0.1, 1.25), M)
	for i = 1, 4 do D(fore, "FSlit", {1.5, 0.1, 0.4}, cf(0, -0.7 + i * 0.3, 1.45), BK) end
	D(fore, "FNeonA", {0.1, 1.6, 0.1}, cf(-0.6, -0.15, -1.58), GL, NEON).Transparency = 0.25
	D(fore, "FNeonB", {0.1, 1.6, 0.1}, cf(0.6, -0.15, -1.58), GL, NEON).Transparency = 0.25
	D(fore, "FBand", {2.55, 0.4, 2.55}, cf(0, -1.2, 0), G)
	cylV(fore, "FPist", 2.4, 0.35, cf(-s * 0.5, 0, 1.45), MD)
	rivets(fore, {{-0.8, 0.95, -1.58}, {0.8, 0.95, -1.58}, {-0.8, -1.2, -1.3}, {0.8, -1.2, -1.3}}, 0.18)

	-- ban tay
	local hand = put(mk("Hand" .. sk, v3(2.1, 1.4, 2.2), R_))
	local wj = mkJoint(main and (sk .. "Wrist") or ("XWr" .. sk), fore, hand, Vector3.new(0, -1.5, 0), Vector3.new(0, 0.6, 0))
	if main then table.insert(S.drive, wj) end
	A.wr = wj
	D(hand, "HBack", {0.4, 1.2, 1.9}, cf(s * 1.05, 0, 0), R_)
	D(hand, "HKnuck", {2.0, 0.35, 2.1}, cf(0, 0.55, 0), G)
	D(hand, "HWrist", {2.2, 0.3, 2.3}, cf(0, 0.75, 0), DG)
	D(hand, "Repulsor", {0.2, 1.0, 1.0}, cf(-s * 1.08, 0, 0), GL, NEON, CYL).Transparency = 0.2
	D(hand, "RepRing", {0.25, 1.25, 1.25}, cf(-s * 1.05, 0, 0), G, METAL, CYL)

	-- ngon tay 3 khop, moi ngon co nhip rieng
	for i = 1, 4 do
		local z = -0.75 + (i - 1) * 0.5
		local p1 = put(mk("F1", v3(0.5, 0.8, 0.5), R_))
		local j1 = mkJoint("XF1", hand, p1, Vector3.new(-s * 0.15, -0.7, z), Vector3.new(0, 0.4, 0))
		D(p1, "FCap", {0.54, 0.14, 0.54}, cf(0, 0.36, 0), G)
		local p2 = put(mk("F2", v3(0.46, 0.7, 0.46), DR))
		local j2 = mkJoint("XF2", p1, p2, Vector3.new(0, -0.4, 0), Vector3.new(0, 0.35, 0))
		local p3 = put(mk("F3", v3(0.42, 0.6, 0.42), G))
		local j3 = mkJoint("XF3", p2, p3, Vector3.new(0, -0.36, 0), Vector3.new(0, 0.3, 0))
		D(p3, "Tip", {0.2, 0.1, 0.2}, cf(0, -0.3, 0), GL, NEON, BALL)
		table.insert(A.fingers, {j = {j1, j2, j3}, m = 1})
	end
	do
		local p1 = put(mk("T1", v3(0.58, 0.8, 0.58), R_))
		local j1 = mkJoint("XT1", hand, p1, Vector3.new(-s * 0.3, -0.1, -1.18), Vector3.new(0, 0.4, 0))
		local p2 = put(mk("T2", v3(0.5, 0.7, 0.5), G))
		local j2 = mkJoint("XT2", p1, p2, Vector3.new(0, -0.4, 0), Vector3.new(0, 0.35, 0))
		table.insert(A.fingers, {j = {j1, j2}, m = 0.8})
	end

	if main then P["UArm" .. sk], P["FArm" .. sk], P["Hand" .. sk] = upper, fore, hand end
	KK = 1
	return A
end

------------------------------------------------------------------
-- XAY GIAP
------------------------------------------------------------------
local COLL = {"Pelvis", "Torso", "Head", "UArmR", "UArmL", "FArmR", "FArmL", "HandR", "HandL"}

local function buildArmor()
	local char, hrp = S.char, S.hrp
	local armor = Instance.new("Model")
	armor.Name = "HB_Armor"
	armor.Parent = char
	S.armor = armor
	local P = S.parts
	local R_, DR, G, DG, M, MD, BK, GL, WH = COL.Red, COL.DarkRed, COL.Gold, COL.DarkGold, COL.Metal, COL.MetalDark, COL.Black, COL.Glow, COL.White

	-- ===== CHAU =====
	local pelvis = put(mk("Pelvis", v3(3.8, 1.6, 2.5), DR))
	S.rootMotor = mkJoint("Root", hrp, pelvis, Vector3.zero, Vector3.zero).m
	P.Pelvis = pelvis
	D(pelvis, "Belt", {4.0, 0.5, 2.7}, cf(0, 0.6, 0), G)
	D(pelvis, "BeltLow", {4.05, 0.14, 2.75}, cf(0, 0.3, 0), DG)
	cylZ(pelvis, "Buckle", 0.3, 1.1, cf(0, 0.6, -1.4), G, METAL)
	cylZ(pelvis, "BuckleC", 0.2, 0.7, cf(0, 0.6, -1.5), GL, NEON).Transparency = 0.2
	for i = -1, 1 do
		D(pelvis, "Fauld", {1.1, 1.2, 0.35}, cf(i * 1.2, -0.75, -1.3, 0.18, 0, 0), i == 0 and G or R_)
		D(pelvis, "FauldT", {1.15, 0.12, 0.4}, cf(i * 1.2, -1.3, -1.38, 0.18, 0, 0), DG)
	end
	D(pelvis, "Cod", {1.5, 1.0, 0.45}, cf(0, -0.35, -1.45), DR)
	D(pelvis, "BackP", {3.2, 1.4, 0.5}, cf(0, -0.1, 1.4), DR)
	for i = 1, 3 do D(pelvis, "BSlit", {2.2, 0.08, 0.2}, cf(0, -0.4 + i * 0.25, 1.68), BK) end
	for _, s in ipairs({1, -1}) do
		D(pelvis, "HipP", {0.5, 1.4, 1.8}, cf(s * 2.0, -0.1, 0), G)
		D(pelvis, "HipPR", {0.55, 0.9, 1.2}, cf(s * 2.0, -0.1, 0), R_)
		D(pelvis, "HipBall", {1.8, 1.8, 1.8}, cf(s * 1.2, -0.6, 0), MD, METAL, BALL)
	end
	rivets(pelvis, {{-1.8, 0.6, -1.36}, {-1.2, 0.6, -1.36}, {1.2, 0.6, -1.36}, {1.8, 0.6, -1.36}}, 0.18)

	-- ===== THAN TREN =====
	local torso = put(mk("Torso", v3(4.6, 3.3, 3.0), R_))
	P.Torso = torso
	table.insert(S.drive, mkJoint("Waist", pelvis, torso, Vector3.new(0, 0.8, 0), Vector3.new(0, -1.55, 0)))

	-- khoang ben trong (chi nhin thay khi cua truoc mo va Torso trong suot)
	D(torso, "InBack", {3.7, 2.9, 0.2}, cf(0, 0, 1.35), MD)
	D(torso, "InL", {0.2, 2.9, 2.6}, cf(-2.15, 0, 0), MD)
	D(torso, "InR", {0.2, 2.9, 2.6}, cf(2.15, 0, 0), MD)
	D(torso, "InFloor", {3.9, 0.2, 2.6}, cf(0, -1.5, 0), MD)
	D(torso, "InStripL", {0.1, 2.2, 0.1}, cf(-2.02, 0, -0.9), GL, NEON).Transparency = 0.45
	D(torso, "InStripR", {0.1, 2.2, 0.1}, cf(2.02, 0, -0.9), GL, NEON).Transparency = 0.45
	D(torso, "InStripB", {2.8, 0.1, 0.1}, cf(0, 1.0, 1.22), GL, NEON).Transparency = 0.45

	-- CUA TRUOC THAT: ban le ben trai, mo ra phia truoc. Moi tam ngan/bung/lo phan ung gan vao cua
	local door = put(mk("FDoor", v3(0.4, 0.4, 0.4), M))
	door.Transparency = 1
	P.Door = door
	table.insert(S.drive, mkJoint("FDoor", torso, door, Vector3.new(-2.25, 0, -1.4), Vector3.zero))
	local H = cf(-2.25, 0, -1.4):Inverse()
	D(door, "ChestSlab", {4.0, 1.9, 0.5}, H * cf(0, 0.55, -1.65), DR)
	for _, s in ipairs({1, -1}) do
		D(door, "Pec", {2.0, 1.6, 0.8}, H * cf(s * 1.1, 0.7, -1.75, 0.15, 0, 0), R_)
		D(door, "PecTrim", {2.05, 0.16, 0.85}, H * cf(s * 1.1, -0.05, -1.82, 0.15, 0, 0), G)
		D(door, "PecTop", {2.0, 0.14, 0.8}, H * cf(s * 1.1, 1.45, -1.55, 0.15, 0, 0), DG)
		D(door, "YBar", {0.3, 1.5, 0.4}, H * cf(s * 0.8, 1.0, -2.0, 0, 0, s * 0.5), DG)
	end
	D(door, "Stern", {0.9, 2.0, 0.45}, H * cf(0, 0.55, -1.9), G)
	D(door, "ChestLow", {3.6, 0.8, 0.6}, H * cf(0, -0.3, -1.65), DR)
	D(door, "ChestLowG", {3.7, 0.12, 0.65}, H * cf(0, 0.1, -1.68), G)
	for i = 1, 3 do D(door, "Abs", {3.0, 0.24, 0.5}, H * cf(0, -0.8 - i * 0.22, -1.6), (i % 2 == 0) and G or MD) end
	-- lo phan ung
	cylZ(door, "ReactOut", 0.3, 2.3, H * cf(0, 0.45, -2.05), DG, METAL)
	cylZ(door, "ReactRing", 0.35, 1.9, H * cf(0, 0.45, -2.1), G, METAL)
	cylZ(door, "ReactIn", 0.4, 1.5, H * cf(0, 0.45, -2.15), MD, METAL)
	local core = cylZ(door, "ReactCore", 0.3, 1.1, H * cf(0, 0.45, -2.25), WH, NEON)
	local pl = Instance.new("PointLight")
	pl.Color = GL
	pl.Range = 22
	pl.Brightness = 2
	pl.Parent = core
	P.CoreLight = pl
	for i = 0, 7 do
		local a = i * math.pi / 4
		D(door, "ReactSeg", {0.22, 0.22, 0.3}, H * cf(math.cos(a) * 0.78, 0.45 + math.sin(a) * 0.78, -2.2), GL, NEON, BALL)
		D(door, "ReactBolt", {0.18, 0.18, 0.18}, H * cf(math.cos(a + 0.4) * 1.1, 0.45 + math.sin(a + 0.4) * 1.1, -2.05), DG, METAL, BALL)
	end

	for _, s in ipairs({1, -1}) do
		D(torso, "SideRib", {0.45, 2.4, 1.6}, cf(s * 2.4, -0.1, -0.2), R_)
		D(torso, "SideRibG", {0.5, 0.16, 1.7}, cf(s * 2.4, 1.0, -0.2), G)
		for i = 1, 4 do D(torso, "Slit", {0.5, 0.1, 1.0}, cf(s * 2.6, -0.8 + i * 0.35, -0.2), BK) end
		D(torso, "Trap", {1.2, 0.9, 1.9}, cf(s * 1.3, 1.95, 0.2, 0, 0, -s * 0.3), R_)
		D(torso, "TrapG", {1.25, 0.14, 1.95}, cf(s * 1.3, 2.4, 0.2, 0, 0, -s * 0.3), G)
	end
	D(torso, "Yoke", {4.8, 0.6, 2.6}, cf(0, 1.55, 0.1), DR)
	D(torso, "Collar", {3.4, 0.4, 1.0}, cf(0, 1.75, -1.1), G)
	-- lung
	D(torso, "Back", {3.8, 3.0, 1.2}, cf(0, 0.3, 2.1), M)
	D(torso, "BackArmor", {4.3, 2.4, 0.5}, cf(0, 0.6, 1.65), DR)
	D(torso, "BackFrame", {4.0, 0.2, 1.3}, cf(0, 1.8, 2.1), G)
	for i = -1, 1 do D(torso, "BackVent", {0.22, 1.6, 0.2}, cf(i * 0.9, 0.7, 2.75), COL.WingGlow, NEON).Transparency = 0.35 end
	for _, s in ipairs({1, -1}) do
		cylV(torso, "Thr", 2.2, 1.2, cf(s * 1.2, -0.4, 2.7), MD, METAL)
		cylV(torso, "ThrB", 0.2, 1.4, cf(s * 1.2, 0.5, 2.7), G, METAL)
		cylV(torso, "ThrN", 0.4, 0.95, cf(s * 1.2, -1.65, 2.7), G, METAL)
		addFlame(torso, cf(s * 1.2, -1.95, 2.7), false)
	end
	D(torso, "NeckBase", {1.7, 0.9, 1.7}, cf(0, 1.95, 0), MD)

	-- vai + bang ten lua
	for _, s in ipairs({1, -1}) do
		local sk = s == 1 and "R" or "L"
		D(torso, "ShBall", {2.4, 2.4, 2.4}, cf(s * 3.1, 0.5, 0), MD, METAL, BALL)
		local paul = D(torso, "Pauld", {3.0, 2.1, 3.2}, cf(s * 3.4, 1.4, 0, 0, 0, -s * 0.2), R_)
		D(paul, "PaulTop", {3.1, 0.45, 3.3}, cf(0, 1.1, 0), G)
		D(paul, "PaulBot", {3.05, 0.2, 3.25}, cf(0, -1.05, 0), DG)
		D(paul, "PaulSide", {0.4, 2.2, 2.8}, cf(s * 1.6, -0.1, 0), G)
		D(paul, "PaulBand1", {0.3, 1.8, 0.35}, cf(s * 0.6, 0, -1.65), G)
		D(paul, "PaulBand2", {0.3, 1.8, 0.35}, cf(-s * 0.6, 0, -1.65), G)
		D(paul, "PaulFront", {2.2, 1.4, 0.4}, cf(0, 0, -1.7), DR)
		D(paul, "PaulRear", {2.4, 1.5, 0.4}, cf(0, 0, 1.7), DR)
		D(paul, "PaulVent", {1.2, 0.8, 0.2}, cf(0, 0, -1.95), BK)
		for i = 1, 4 do D(paul, "PaulSlit", {1.1, 0.07, 0.25}, cf(0, -0.25 + i * 0.13, -1.98), M) end
		rivets(paul, {{-1.1, 0.8, -1.62}, {1.1, 0.8, -1.62}, {-1.1, -0.8, -1.62}, {1.1, -0.8, -1.62}}, 0.2)
		local pod = D(paul, "Pod", {1.6, 0.8, 2.1}, cf(0, 1.65, 0), M)
		D(pod, "PodLid", {1.7, 0.14, 2.2}, cf(0, 0.45, 0), DG)
		for _, tx in ipairs({-0.4, 0.4}) do
			cylZ(pod, "Tube", 1.2, 0.5, cf(tx, 0, -1.0), MD, METAL)
			cylZ(pod, "TubeCap", 0.2, 0.42, cf(tx, 0, -1.55), COL.Red, nil)
		end
		P["Pod" .. sk] = pod
	end

	-- ===== DAU =====
	local head = put(mk("Head", v3(2.2, 2.3, 2.3), R_))
	P.Head = head
	table.insert(S.drive, mkJoint("Neck", torso, head, Vector3.new(0, 1.65, 0), Vector3.new(0, -0.9, 0)))
	D(head, "Face", {1.75, 1.7, 0.35}, cf(0, -0.15, -1.2), G)
	D(head, "Brow", {1.8, 0.28, 0.45}, cf(0, 0.38, -1.25), DR)
	D(head, "Forehead", {1.5, 0.4, 0.3}, cf(0, 0.75, -1.2), G)
	D(head, "Nose", {0.28, 0.9, 0.22}, cf(0, -0.1, -1.42), DG)
	D(head, "Crown", {2.4, 0.7, 2.5}, cf(0, 0.95, 0), R_)
	D(head, "Crest", {0.35, 0.5, 2.0}, cf(0, 1.4, 0), G)
	D(head, "CrestS", {0.2, 0.3, 1.4}, cf(0, 1.7, 0.1), DG)
	D(head, "Chin", {1.4, 0.5, 0.6}, cf(0, -1.0, -0.85), R_)
	D(head, "Jaw", {1.6, 0.35, 1.0}, cf(0, -1.1, -0.4), DR)
	D(head, "HBack", {2.3, 1.7, 0.5}, cf(0, 0, 1.2), DR)
	D(head, "HBackG", {1.6, 0.2, 0.55}, cf(0, 0.3, 1.2), G)
	for k2 = 1, 4 do D(head, "Mouth", {0.9, 0.06, 0.08}, cf(0, -0.4 - k2 * 0.1, -1.4), BK) end
	D(head, "MouthBar", {0.08, 0.5, 0.08}, cf(0, -0.65, -1.4), BK)
	for _, s in ipairs({1, -1}) do
		D(head, "EyeGlow", {0.65, 0.26, 0.1}, cf(s * 0.5, 0.15, -1.38, 0, 0, -s * 0.14), GL, NEON).Transparency = 0.45
		D(head, "Eye", {0.5, 0.14, 0.12}, cf(s * 0.5, 0.15, -1.42, 0, 0, -s * 0.14), WH, NEON)
		D(head, "Cheek", {0.45, 1.4, 1.7}, cf(s * 1.2, -0.3, -0.1), R_)
		D(head, "CheekG", {0.5, 0.9, 0.8}, cf(s * 1.22, -0.3, -0.7), G)
		D(head, "Ear", {0.3, 0.9, 0.9}, cf(s * 1.45, 0, 0), G, METAL, CYL)
		D(head, "EarDot", {0.12, 0.4, 0.4}, cf(s * 1.6, 0, 0), GL, NEON, CYL)
	end

	-- ===== TAY CHINH =====
	S.arms.R = buildArm(torso, 1, Vector3.new(3.1, 0.7, 0), 1, {main = true})
	S.arms.L = buildArm(torso, -1, Vector3.new(-3.1, 0.7, 0), 1, {main = true})

	-- ===== CHAN =====
	for _, s in ipairs({1, -1}) do
		local sk = s == 1 and "R" or "L"
		local thigh = put(mk("Thigh" .. sk, v3(2.3, 2.6, 2.5), R_))
		table.insert(S.drive, mkJoint(sk .. "Hip", pelvis, thigh, Vector3.new(s * 1.2, -0.6, 0), Vector3.new(0, 1.1, 0)))
		D(thigh, "TBand", {2.45, 0.45, 2.65}, cf(0, 0.95, 0), G)
		D(thigh, "TBand2", {2.4, 0.2, 2.6}, cf(0, -0.95, 0), DG)
		D(thigh, "TFront", {1.8, 1.7, 0.5}, cf(0, 0.1, -1.35), DR)
		D(thigh, "TChevA", {1.0, 0.14, 0.55}, cf(-0.4, 0.2, -1.4, 0, 0, 0.3), G)
		D(thigh, "TChevB", {1.0, 0.14, 0.55}, cf(0.4, 0.2, -1.4, 0, 0, -0.3), G)
		D(thigh, "TSide", {0.35, 1.9, 1.7}, cf(s * 1.25, 0, 0), G)
		D(thigh, "TSideR", {0.4, 1.2, 1.1}, cf(s * 1.27, 0, 0), R_)
		D(thigh, "TInner", {0.3, 1.5, 1.4}, cf(-s * 1.2, 0, 0), M)
		cylV(thigh, "TPist", 2.0, 0.4, cf(-s * 0.55, 0, 1.4), M)
		cylV(thigh, "TPist2", 2.0, 0.4, cf(s * 0.55, 0, 1.4), M)
		cylV(thigh, "TPistR", 1.0, 0.22, cf(-s * 0.55, 0.9, 1.4), WH)
		D(thigh, "KBall", {1.9, 1.9, 1.9}, cf(0, -1.3, 0), MD, METAL, BALL)
		rivets(thigh, {{-0.8, 0.95, -1.35}, {0.8, 0.95, -1.35}}, 0.18)

		local shin = put(mk("Shin" .. sk, v3(2.4, 2.8, 2.6), DR))
		table.insert(S.drive, mkJoint(sk .. "Knee", thigh, shin, Vector3.new(0, -1.3, 0), Vector3.new(0, 1.2, 0)))
		D(shin, "KCap", {2.1, 1.5, 0.8}, cf(0, 0.85, -1.35), R_)
		D(shin, "KRim", {2.3, 0.35, 0.9}, cf(0, 1.5, -1.35), G)
		cylZ(shin, "KLightHousing", 0.3, 1.35, cf(0, 0.85, -1.75), G, METAL)
		cylZ(shin, "KLight", 0.25, 1.0, cf(0, 0.85, -1.9), WH, NEON)
		D(shin, "SFront", {1.9, 1.5, 0.5}, cf(0, -0.5, -1.4), R_)
		D(shin, "SStripe", {2.0, 0.26, 0.55}, cf(0, -0.95, -1.42), G)
		D(shin, "SStripe2", {2.0, 0.16, 0.55}, cf(0, -1.25, -1.42), DG)
		D(shin, "Calf", {2.0, 2.0, 0.9}, cf(0, 0, 1.5), DR)
		for i = 1, 4 do D(shin, "CalfSlit", {1.5, 0.08, 0.3}, cf(0, -0.6 + i * 0.3, 1.97), BK) end
		D(shin, "SSide", {0.35, 2.0, 1.8}, cf(s * 1.3, -0.1, 0), G)
		D(shin, "SSideR", {0.4, 1.3, 1.1}, cf(s * 1.32, -0.1, 0), R_)
		cylV(shin, "SPist", 2.2, 0.35, cf(-s * 0.9, 0, 1.0), M)
		D(shin, "AnkleBall", {1.7, 1.7, 1.7}, cf(0, -1.4, 0), MD, METAL, BALL)

		local foot = put(mk("Foot" .. sk, v3(2.5, 1.0, 3.6), R_))
		table.insert(S.drive, mkJoint(sk .. "Ankle", shin, foot, Vector3.new(0, -1.4, 0), Vector3.new(0, 0.5, 0.5)))
		D(foot, "Toe", {2.4, 0.6, 1.1}, cf(0, 0, -1.4), DR)
		D(foot, "ToeG", {2.3, 0.14, 1.0}, cf(0, 0.35, -1.45), G)
		D(foot, "FTop", {2.1, 0.5, 2.0}, cf(0, 0.6, -0.4), R_)
		D(foot, "Heel", {2.3, 0.6, 0.8}, cf(0, 0.1, 1.3), G)
		D(foot, "HeelPort", {1.2, 0.4, 0.2}, cf(0, 0.1, 1.75), MD)
		D(foot, "FSide", {0.3, 0.7, 2.6}, cf(s * 1.2, 0.15, 0), G)
		D(foot, "Sole", {2.55, 0.15, 3.65}, cf(0, -0.5, 0), BK)
		cylV(foot, "FPist", 1.2, 0.3, cf(-s * 0.7, 0.9, 0.8), M)
		addFlame(foot, cf(0, -0.65, 0.3), true)

		P["Thigh" .. sk], P["Shin" .. sk], P["Foot" .. sk] = thigh, shin, foot
	end
end

------------------------------------------------------------------
-- CANH
------------------------------------------------------------------
local function destroyWings()
	local W = S.wings
	if not W then return end
	for _, p in ipairs(W.parts) do pcall(function() p:Destroy() end) end
	S.wings = nil
end

local function buildWings()
	if S.wings then S.wings.target = 1 return end
	local torso = S.parts.Torso
	local W = {blades = {}, hinges = {}, parts = {}, open = 0, target = 1}
	S.wings = W
	S.collect = W.parts
	for _, s in ipairs({1, -1}) do
		local hinge = mk("WHinge", v3(0.4, 0.4, 0.4), COL.Metal)
		hinge.Transparency = 1
		hinge.Parent = S.armor
		table.insert(W.parts, hinge)
		local hj = mkJoint("WH", torso, hinge, Vector3.new(s * 1.7, 1.1, 2.5), Vector3.zero)
		hj.s = s
		table.insert(W.hinges, hj)
		D(hinge, "WMount", {1.0, 1.6, 0.9}, cf(s * 0.3, 0, 0), COL.Gold)
		for i = 1, 6 do
			local L = 3.4 + i * 0.95
			local b = put(mk("Blade", v3(L, 0.16, 1.05), (i % 2 == 0) and COL.Gold or COL.Red))
			local bj = mkJoint("WB", hinge, b, Vector3.zero, Vector3.new(-s * L / 2, 0, 0))
			D(b, "Edge", {L, 0.1, 0.2}, cf(0, 0.1, -0.4), COL.WingGlow, NEON).Transparency = 0.4
			D(b, "Edge2", {L, 0.1, 0.14}, cf(0, 0.1, 0.4), COL.WingGlow, NEON).Transparency = 0.4
			table.insert(W.blades, {j = bj, s = s, tilt = math.rad(5 + i * 9), sweep = math.rad(8 + i * 6)})
			if i >= 5 then
				local a0 = Instance.new("Attachment")
				a0.Position = Vector3.new(s * L / 2 * SC, 0, 0.45 * SC)
				a0.Parent = b
				local a1 = Instance.new("Attachment")
				a1.Position = Vector3.new(s * L / 2 * SC, 0, -0.45 * SC)
				a1.Parent = b
				local tr = Instance.new("Trail")
				tr.Attachment0 = a0
				tr.Attachment1 = a1
				tr.Lifetime = 0.45
				tr.LightEmission = 0.35
				tr.Color = ColorSequence.new(COL.WingGlow, COL.Gold)
				tr.Transparency = NumberSequence.new(0.5, 1)
				tr.Parent = b
			end
		end
	end
	S.collect = nil
end

local function updateWings(dt, t)
	local W = S.wings
	if not W then return end
	W.open = ease(W.open, W.target, 7, dt)
	if W.target == 0 and W.open < 0.03 then destroyWings() return end
	local o = W.open
	local flap = (S.ctrl or S.flying) and math.sin(t * 4.5) * 0.1 * o or 0
	for _, hj in ipairs(W.hinges) do hj.m.C0 = hj.c0 * CFrame.Angles(0, 0, hj.s * flap) end
	for _, b in ipairs(W.blades) do
		b.j.m.C0 = CFrame.Angles(0, -b.s * lerp(0.1, b.sweep, o), b.s * lerp(1.45, b.tilt, o))
	end
end

------------------------------------------------------------------
-- TAY PHU LO LUNG
------------------------------------------------------------------
local function destroyExtras()
	local X = S.extras
	if not X then return end
	for _, p in ipairs(X.parts) do pcall(function() p:Destroy() end) end
	for _, p in ipairs(X.bases) do pcall(function() p:Destroy() end) end
	for _, p in ipairs(X.objs) do pcall(function() p:Destroy() end) end
	S.extras = nil
end

local function summonExtras()
	if S.extras or not S.on then return end
	local X = {arms = {}, parts = {}, bases = {}, objs = {}, beams = {}, xs = 0, goal = 1, lastXs = -1}
	S.extras = X
	S.collect = X.parts
	for _, s in ipairs({1, -1}) do
		local base = mk("XBase", v3(0.4, 0.4, 0.4), COL.Metal)
		base.Transparency = 1
		base.Parent = S.armor
		table.insert(X.bases, base)
		local bj = mkJoint("XBase", S.parts.Torso, base, Vector3.new(0, 0.6, 2.6), Vector3.zero)
		local A = buildArm(base, s, Vector3.zero, 0.85, {energy = true})
		A.base = bj
		table.insert(X.arms, A)
		-- day nang luong noi voi than giap
		local a0 = Instance.new("Attachment")
		a0.Position = Vector3.new(s * 2.3 * SC, 0.6 * SC, 1.6 * SC)
		a0.Parent = S.parts.Torso
		local a1 = Instance.new("Attachment")
		a1.Parent = base
		local bm = Instance.new("Beam")
		bm.Attachment0 = a0
		bm.Attachment1 = a1
		bm.Width0 = 0.22
		bm.Width1 = 0.12
		bm.Color = ColorSequence.new(COL.Glow)
		bm.LightEmission = 0.7
		bm.Segments = 14
		bm.CurveSize0 = 2
		bm.CurveSize1 = -2
		bm.FaceCamera = true
		bm.Transparency = NumberSequence.new(1)
		bm.Parent = base
		table.insert(X.objs, a0)
		table.insert(X.beams, bm)
	end
	S.collect = nil
	for _, p in ipairs(X.parts) do p.Transparency = 1 end
	local bp = S.parts.Torso.Position
	ringFx(bp, 8, COL.Glow, 0.6)
	sparks(bp, 16, COL.Glow, 8, 0.6)
	shake(0.5, 0.3)
end

local function dismissExtras()
	if S.extras then S.extras.goal = 0 end
end

local function updateExtras(dt, t, wC, armE)
	local X = S.extras
	if not X then return end
	X.xs = ease(X.xs, X.goal, 5, dt)
	if X.goal == 0 and X.xs < 0.04 then destroyExtras() return end
	-- V10: tay phu bay toi diem chi dinh (cong dich chuyen)
	if X.cst then X.cstLast = X.cst end
	X.cw = ease(X.cw or 0, X.cst and 1 or 0, (X.cstLast and X.cstLast.rate) or 8, dt)
	if X.cw < 0.004 and not X.cst then X.cstLast = nil X.cw = 0 end
	local ct, cw = X.cstLast, X.cw
	for _, A in ipairs(X.arms) do
		local s = A.side
		local E = armE[s == 1 and "XR" or "XL"]
		local hover = Vector3.new(s * 8.0, 2.6 + math.sin(t * 1.8 + s) * 0.4, 2.0 + math.sin(t * 1.3 + s * 2) * 0.25)
		local pos = Vector3.new(0, 0.6, 2.6):Lerp(hover, math.min(1, X.xs))
		pos = pos:Lerp(Vector3.new(s * 3.8, 2.9, 0.2), wC)
		local sx = 0.3 + 0.18 * math.sin(t * 2 + s)
		local ex = 0.8 + 0.25 * math.sin(t * 2.4 + s)
		local sz = s * (0.34 + 0.12 * math.sin(t * 1.6))
		local curl = 0.7 + 0.4 * math.sin(t * 1.1 + s)
		if E then
			local Ec = math.clamp(E, -0.35, 1.12)
			local pe = math.max(Ec, 0)
			pos = pos + Vector3.new(-s * 1.2 * pe, 0.4 * pe, -5.0 * pe)
			sx = -0.25 + 1.8 * Ec
			ex = math.clamp(0.05 + 1.45 * (1 - Ec), 0.05, 2.1)
			sz = s * 0.05
			curl = lerp(0.8, 1.5, pe)
		end
		sx, ex, sz, curl = lerp(sx, 1.45, wC), lerp(ex, 0.15, wC), lerp(sz, 0, wC), lerp(curl, 0.12, wC)
		local rotC = CFrame.Angles(0, 0, math.sin(t * 1.2 + s) * 0.06 * (1 - wC))
		if ct and cw > 0.004 and S.parts.Torso then
			local tp = ct.pos[s]
			if tp then
				local tc = S.parts.Torso.CFrame
				pos = pos:Lerp(tc:PointToObjectSpace(tp) / SC, cw)
				local fv = tc:VectorToObjectSpace(ct.face - tp)
				if fv.Magnitude > 0.1 then rotC = rotC:Lerp(CFrame.lookAt(Vector3.zero, fv.Unit), cw) end
				sx = lerp(sx, 1.5, cw)
				ex = lerp(ex, 0.12, cw)
				sz = lerp(sz, 0, cw)
				curl = lerp(curl, 0.1 + 0.12 * math.sin(t * 6 + s), cw)
			end
		end
		A.base.m.C0 = CFrame.new(pos * SC) * rotC
		A.sh.m.C0 = A.sh.c0 * CFrame.Angles(0, s * 0.25 * wC, 0) * CFrame.Angles(sx, 0, sz)
		A.el.m.C0 = A.el.c0 * CFrame.Angles(ex, 0, 0)
		A.wr.m.C0 = A.wr.c0 * CFrame.Angles(math.sin(t * 3 + s) * 0.1 * (1 - wC), 0, 0)
		applyFingers(A, curl, t, 0.22 * (1 - wC))
	end
	if math.abs(X.xs - X.lastXs) > 0.003 then
		X.lastXs = X.xs
		local tr = 1 - math.min(1, X.xs * 1.05)
		for _, p in ipairs(X.parts) do p.Transparency = tr end
		for _, b in ipairs(X.beams) do b.Transparency = NumberSequence.new(1 - X.xs * 0.55) end
	end
end

------------------------------------------------------------------
-- NO (ten lua)
------------------------------------------------------------------
local function blastFX(pos, R, normal)
	normal = normal or Vector3.yAxis
	local w = fxPart("BoomW", Vector3.one * R * 0.3, COL.White, NEON, BALL)
	w.CFrame = CFrame.new(pos)
	tw(w, 0.25, {Size = Vector3.one * R * 1.3, Transparency = 1})
	Debris:AddItem(w, 0.3)
	local layers = {{Color3.fromRGB(255, 225, 140), 1.6, 0.4}, {Color3.fromRGB(255, 130, 40), 2.2, 0.6}, {Color3.fromRGB(150, 45, 20), 2.7, 0.8}}
	for _, L in ipairs(layers) do
		local b = fxPart("Boom", Vector3.one * R * 0.4, L[1], NEON, BALL)
		b.CFrame = CFrame.new(pos)
		b.Transparency = 0.15
		tw(b, L[3], {Size = Vector3.one * R * L[2], Transparency = 1})
		Debris:AddItem(b, L[3] + 0.1)
	end
	local lp = fxPart("BoomL", Vector3.one, COL.Black, NEON, BALL)
	lp.Transparency = 1
	lp.CFrame = CFrame.new(pos)
	local l = Instance.new("PointLight")
	l.Color = Color3.fromRGB(255, 170, 90)
	l.Range = 50
	l.Brightness = 7
	l.Parent = lp
	tw(l, 0.6, {Brightness = 0})
	Debris:AddItem(lp, 0.8)
	local em = fxPart("BoomE", Vector3.one * R * 0.5, COL.Black, NEON, BALL)
	em.Transparency = 1
	em.CFrame = CFrame.new(pos)
	local fe = mkEmitter(em, {
		tex = FIRE_TEX, light = 0.7, life = NumberRange.new(0.6, 1.2), speed = NumberRange.new(R * 0.8, R * 2), drag = 2,
		shape = Enum.ParticleEmitterShape.Sphere,
		color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 235, 170)), ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 50, 20))}),
		size = NumberSequence.new({NumberSequenceKeypoint.new(0, R * 0.3), NumberSequenceKeypoint.new(1, R * 0.7)}),
	})
	fe:Emit(30)
	local se = mkEmitter(em, {
		life = NumberRange.new(2.5, 4), speed = NumberRange.new(R * 0.2, R * 0.8), drag = 1.5, acc = Vector3.new(0, 5, 0),
		shape = Enum.ParticleEmitterShape.Sphere,
		color = ColorSequence.new(Color3.fromRGB(85, 72, 66), Color3.fromRGB(50, 48, 46)),
		size = NumberSequence.new({NumberSequenceKeypoint.new(0, R * 0.3), NumberSequenceKeypoint.new(1, R * 0.9)}),
		transp = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)}),
	})
	se:Emit(24)
	Debris:AddItem(em, 5)
	local ring = fxPart("Ring", Vector3.new(0.4, 2, 2), Color3.fromRGB(255, 200, 130), NEON, CYL)
	ring.CFrame = CFrame.lookAt(pos, pos + normal) * CFrame.Angles(0, math.pi / 2, 0)
	ring.Transparency = 0.3
	tw(ring, 0.6, {Size = Vector3.new(0.4, R * 5, R * 5), Transparency = 1})
	Debris:AddItem(ring, 0.7)
	sparks(pos, 28, Color3.fromRGB(255, 200, 110), R * 2.2, 0.8)
	debrisChunks(pos, 12, R * 1.4, false)
	if normal.Y > 0.5 then
		for i = 1, 14 do
			local a = (i / 14) * math.pi * 2
			local p = fxSphere("Dust", Vector3.new(R * 0.2, R * 0.12, R * 0.2), Color3.fromRGB(120, 100, 82), SMOOTH)
			p.Transparency = 0.25
			p.CFrame = CFrame.new(pos)
			tw(p, 1.4, {CFrame = CFrame.new(pos + Vector3.new(math.cos(a), 0.1, math.sin(a)) * R * 2), Size = Vector3.new(R * 0.7, R * 0.4, R * 0.7), Transparency = 1})
			Debris:AddItem(p, 1.5)
		end
	end
	playSound(SND_BOOM, 0.8, fr(0.9, 1.15))
	if S.hrp then
		local dist = (S.hrp.Position - pos).Magnitude
		shake(math.clamp(1.5 - dist / 80, 0.05, 1.3), 0.45)
	end
end

local function launchRocket(pod, side, target, idx, total)
	local rp = rayParams()
	local start = (pod.CFrame * CFrame.new(0, 0.9 * SC, -0.6 * SC)).Position
	local back = pod.CFrame:VectorToWorldSpace(Vector3.new(0, 0, 1))
	-- phat hoa + khoi sau pod
	local fl = fxPart("Muzzle", Vector3.one * 2.4, COL.Fire, NEON, BALL)
	fl.CFrame = CFrame.new(start)
	tw(fl, 0.22, {Size = Vector3.one * 0.3, Transparency = 1})
	Debris:AddItem(fl, 0.3)
	dustBurst(start + back * 1.5, 5, 10, Color3.fromRGB(200, 200, 200), 1.6)
	sparks(start, 8, Color3.fromRGB(255, 210, 120), 5, 0.4)
	playSound(SND_ROCKET, 0.5, fr(0.95, 1.2))
	S.kick = 1

	local parts = {}
	local function mp(name, size, col, mat, off, shape, sphere)
		local p = sphere and fxSphere(name, size, col, mat) or fxPart(name, size, col, mat, shape)
		table.insert(parts, {p, off})
		return p
	end
	local rot = CFrame.Angles(0, math.pi / 2, 0)
	local body = mp("Body", Vector3.new(3.2, 0.75, 0.75), COL.Gold, METAL, rot, CYL)
	mp("Band", Vector3.new(0.4, 0.8, 0.8), COL.Red, METAL, CFrame.new(0, 0, -0.5) * rot, CYL)
	mp("Band2", Vector3.new(0.3, 0.8, 0.8), COL.Red, METAL, CFrame.new(0, 0, 0.7) * rot, CYL)
	mp("Nose", Vector3.new(0.75, 0.75, 1.5), COL.Red, METAL, CFrame.new(0, 0, -2.05), nil, true)
	mp("NozzleR", Vector3.new(0.6, 0.62, 0.62), COL.MetalDark, METAL, CFrame.new(0, 0, 1.75) * rot, CYL)
	mp("FinA", Vector3.new(1.7, 0.08, 0.8), COL.MetalDark, METAL, CFrame.new(0, 0, 1.1))
	mp("FinB", Vector3.new(0.08, 1.7, 0.8), COL.MetalDark, METAL, CFrame.new(0, 0, 1.1))
	local tail = mp("Tail", Vector3.new(0.5, 0.5, 0.5), COL.Fire, NEON, CFrame.new(0, 0, 1.95), nil, true)
	local at = Instance.new("Attachment")
	at.Position = Vector3.new(0, 0, 2.0)
	at.Parent = body
	local fire = mkEmitter(at, {
		tex = FIRE_TEX, light = 0.6, life = NumberRange.new(0.15, 0.3), speed = NumberRange.new(14, 24), rate = 160,
		spread = Vector2.new(8, 8),
		color = ColorSequence.new(Color3.fromRGB(255, 240, 180), Color3.fromRGB(255, 90, 30)),
		size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.3), NumberSequenceKeypoint.new(1, 0)}),
	})
	fire.EmissionDirection = Enum.NormalId.Back
	local smoke = mkEmitter(at, {
		life = NumberRange.new(2.2, 3.2), speed = NumberRange.new(1, 4), rate = 70, spread = Vector2.new(12, 12),
		color = ColorSequence.new(Color3.fromRGB(235, 235, 235), Color3.fromRGB(110, 110, 110)),
		size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 4.5)}),
		transp = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1)}),
	})
	smoke.EmissionDirection = Enum.NormalId.Back
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, 0.25, 2)
	a0.Parent = body
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -0.25, 2)
	a1.Parent = body
	local tr = Instance.new("Trail")
	tr.Attachment0 = a0
	tr.Attachment1 = a1
	tr.Lifetime = 0.5
	tr.LightEmission = 0.6
	tr.Color = ColorSequence.new(Color3.fromRGB(255, 200, 120), Color3.fromRGB(120, 120, 120))
	tr.Transparency = NumberSequence.new(0.2, 1)
	tr.Parent = body
	local lt = Instance.new("PointLight")
	lt.Color = COL.Fire
	lt.Range = 12
	lt.Brightness = 1.8
	lt.Parent = tail

	local spread = (idx - (total + 1) / 2) * 3 + fr(-3, 3)
	local tgt = target + Vector3.new(fr(-1, 1), 0, fr(-1, 1)) * (2 + math.abs(spread))
	local dist = (tgt - start).Magnitude
	local dirv = (tgt - start).Unit
	local outward = pod.CFrame:VectorToWorldSpace(Vector3.new(side, 0, 0))
	local P1 = start + outward * fr(6, 12) + Vector3.new(0, fr(14, 26), 0) + dirv * dist * 0.25
	local dur = math.clamp(dist / CFG.MissileSpeed + 0.7, 1, 5)
	local t, last = 0, start
	local conn
	local function finish(at2, nrm)
		conn:Disconnect()
		for _, e in ipairs(parts) do e[1]:Destroy() end
		blastFX(at2, CFG.MissileRadius, nrm)
	end
	conn = RunService.Heartbeat:Connect(function(dt)
		t += dt
		local u = math.clamp(t / dur, 0, 1) ^ 1.3
		local pos = (1 - u) ^ 2 * start + 2 * (1 - u) * u * P1 + u ^ 2 * tgt
		local v = pos - last
		if v.Magnitude < 0.001 then return end
		local fwd = v.Unit
		local rgt = fwd:Cross(Vector3.yAxis)
		if rgt.Magnitude > 0.01 then
			rgt = rgt.Unit
			pos += (rgt * math.cos(t * 16 + idx) + rgt:Cross(fwd) * math.sin(t * 16 + idx)) * 0.45 * (1 - u)
		end
		local res = Workspace:Raycast(last, pos - last, rp)
		if res then finish(res.Position, res.Normal) return end
		local base = CFrame.lookAt(pos, pos + fwd)
		for _, e in ipairs(parts) do e[1].CFrame = base * e[2] end
		last = pos
		if t >= dur then finish(pos, Vector3.yAxis) end
	end)
end

local function fireSalvo()
	local target = mouse.Hit.Position
	local total = CFG.MissilesPerClick
	for i = 1, total do
		task.delay((i - 1) * 0.09, function()
			if not S.on then return end
			local s = (i % 2 == 1) and 1 or -1
			local pod = S.parts[s == 1 and "PodR" or "PodL"]
			if pod then launchRocket(pod, s, target, i, total) end
		end)
	end
end

------------------------------------------------------------------
-- DAM TOAN THAN
------------------------------------------------------------------
local function lunge()
	if S.ctrl or S.drone or not S.hrp then return end
	local look = S.hrp.CFrame.LookVector
	local v = S.hrp.AssemblyLinearVelocity
	S.hrp.AssemblyLinearVelocity = Vector3.new(look.X * CFG.PunchLunge, v.Y, look.Z * CFG.PunchLunge)
end

local function impactForward(reach, power)
	local origin = S.parts.Torso.Position
	local look = S.hrp.CFrame.LookVector
	local res = Workspace:Raycast(origin, look * reach, rayParams())
	local p = res and res.Position or (origin + look * reach * 0.7)
	blastFX(p, 5 * power, res and res.Normal or Vector3.yAxis)
	ringFx(p, 7 * power, COL.Glow, 0.35)
	shake(0.5 * power, 0.25)
end

local function strikeCurve(p)
	if p < 0.28 then return -0.35 * math.sin(p / 0.28 * math.pi / 2)
	elseif p < 0.42 then return lerp(-0.35, 1, ((p - 0.28) / 0.14) ^ 0.55)
	elseif p < 0.55 then return 1
	else
		local x = (p - 0.55) / 0.45
		return 1 - x * x * (3 - 2 * x)
	end
end

local function strikeHit(st)
	if not S.on then return end
	local power = st.big and 1.7 or (st.arm:sub(1, 1) == "X" and 0.8 or 1.1)
	impactForward(18, power)
	if st.lunge then lunge() end
end

local function barrage()
	if #S.strikes > 0 or S.nuking then return end
	local order = S.extras and {"R", "XL", "L", "XR", "R", "XL", "L", "XR", "R", "L"} or {"R", "L", "R", "L", "R", "L", "R", "L"}
	local t0 = os.clock()
	for i, arm in ipairs(order) do
		table.insert(S.strikes, {arm = arm, t0 = t0 + (i - 1) * 0.19, dur = 0.52, big = (i == #order), lunge = (i % 3 == 1)})
	end
end

local function dashPunch()
	if #S.strikes > 0 or S.nuking then return end
	table.insert(S.strikes, {arm = "R", t0 = os.clock(), dur = 0.6, big = true, lunge = true})
end

------------------------------------------------------------------
-- BOM NGUYEN TU
------------------------------------------------------------------
local ENV = {active = false, token = 0, T = 22}

-- V10.9: do manh cua bom theo khoang cach (camera -> tam no): 1 = ngay sat, giam dan, 0 = qua xa
-- (qua xa thi KHONG tieng, KHONG rung, KHONG chop man hinh, KHONG doi mau) -- chinh trong CFG.NukeFullRange / NukeFeelRange
ENV.prox = function(d)
	local full, feel = CFG.NukeFullRange, CFG.NukeFeelRange
	if d >= feel then return 0 end
	if d <= full then return 1 end
	local x = (d - full) / (feel - full)
	return 1 - x * x * (3 - 2 * x)
end

-- tra anh sang ve nhu cu (neu dang bi doi mau)
ENV.revert = function()
	if not ENV.applied then return end
	ENV.applied = false
	pcall(function()
		Lighting.Ambient, Lighting.OutdoorAmbient = ENV.amb, ENV.out
		Lighting.Brightness, Lighting.ExposureCompensation = ENV.br, ENV.exp
		local atm = ENV.atm
		if atm and atm.Parent then
			if ENV.atmCreated then
				atm:Destroy()
				ENV.atm = nil
			else
				for k, v in pairs(ENV.atmOrig) do atm[k] = v end
			end
		end
	end)
end

local function envRestoreNow()
	if not ENV.active then return end
	if ENV.conn then
		ENV.conn:Disconnect()
		ENV.conn = nil
	end
	ENV.revert()
	pcall(function() if ENV.cc then ENV.cc:Destroy() end end)
	ENV.cc, ENV.atm, ENV.applied = nil, nil, false
	ENV.active = false
end

-- V10.9: doi mau CUC BO: mep song nong lan tu tam no ra (~170 stud/s), chi nguoi dung trong vung anh huong moi thay
-- doi mau, cang gan cang dam, ra xa thi tra ve binh thuong -- khong con doi mau toan ban do
local function nukeEnv(pos)
	envRestoreNow()
	ENV.active = true
	ENV.applied = false
	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "HB_NukeTint"
	cc.Parent = Lighting
	ENV.cc = cc
	local t0 = os.clock()
	local T = ENV.T
	local warmA, warmO = Color3.fromRGB(130, 70, 40), Color3.fromRGB(150, 80, 45)
	local atmC, atmD = Color3.fromRGB(210, 130, 80), Color3.fromRGB(120, 60, 40)
	local tint = Color3.fromRGB(255, 190, 140)
	ENV.conn = RunService.Heartbeat:Connect(function()
		local t = os.clock() - t0
		if t >= T then envRestoreNow() return end
		local cam = Workspace.CurrentCamera
		local vp = cam and cam.CFrame.Position or (S.hrp and S.hrp.Position)
		local k = 0
		if vp then
			local d = (vp - pos).Magnitude
			local front = CFG.NukeRadius * 0.7 + t * 170
			local edge = math.clamp((front - d) / 60, 0, 1)
			edge = edge * edge * (3 - 2 * edge)
			local env
			if t < 1.5 then env = t / 1.5
			elseif t < 9 then env = 1
			else env = 1 - (t - 9) / (T - 9) end
			env = env * env * (3 - 2 * env)
			k = ENV.prox(d) * edge * env
		end
		if k > 0.01 then
			if not ENV.applied then
				ENV.amb, ENV.out, ENV.br, ENV.exp = Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.Brightness, Lighting.ExposureCompensation
				local atm = Lighting:FindFirstChildOfClass("Atmosphere")
				ENV.atmCreated = atm == nil
				if not atm then
					atm = Instance.new("Atmosphere")
					atm.Density, atm.Haze, atm.Glare = 0, 0, 0
					atm.Parent = Lighting
				end
				ENV.atm = atm
				ENV.atmOrig = {Density = atm.Density, Color = atm.Color, Decay = atm.Decay, Glare = atm.Glare, Haze = atm.Haze}
				ENV.applied = true
			end
			Lighting.Ambient = ENV.amb:Lerp(warmA, k)
			Lighting.OutdoorAmbient = ENV.out:Lerp(warmO, k)
			Lighting.Brightness = lerp(ENV.br, math.max(0.5, ENV.br * 0.6), k)
			Lighting.ExposureCompensation = lerp(ENV.exp, ENV.exp - 0.4, k)
			local o, atm = ENV.atmOrig, ENV.atm
			if atm and atm.Parent then
				atm.Density = lerp(o.Density, 0.4, k)
				atm.Haze = lerp(o.Haze, 3, k)
				atm.Glare = lerp(o.Glare, 0.6, k)
				atm.Color = o.Color:Lerp(atmC, k)
				atm.Decay = o.Decay:Lerp(atmD, k)
			end
			cc.TintColor = Color3.new(1, 1, 1):Lerp(tint, k)
			cc.Saturation = -0.2 * k
			cc.Contrast = 0.1 * k
		elseif ENV.applied then
			ENV.revert()
			cc.TintColor = Color3.new(1, 1, 1)
			cc.Saturation = 0
			cc.Contrast = 0
		end
	end)
end

-- V10.9: bom nho gon (CFG.NukeRadius) nhung chan that hon: chop sang + tia sang, qua cau lua nhieu lop, song xung kich + may ngung tu (Wilson),
-- bui cuon mat dat, than nam thon dan co lac nhe, mu nam xoay vong cuon (torus) co nhieu cuc khoi
local function nukeBoom(pos, fovBase)
	local R = CFG.NukeRadius
	local rnd = math.random
	local KP, NSK = NumberSequenceKeypoint.new, NumberSequence.new
	local gres = Workspace:Raycast(pos + Vector3.new(0, 10, 0), Vector3.new(0, -1200, 0), rayParams())
	local gp = gres and gres.Position or Vector3.new(pos.X, pos.Y - 4, pos.Z)
	local gx, gy, gz = gp.X, gp.Y, gp.Z
	local c0 = Vector3.new(gx, gy + R * 0.28, gz)

	-- ===== khoang cach tu camera toi tam no: xa qua thi KHONG tieng / rung / chop / doi mau =====
	local cam = Workspace.CurrentCamera
	local vpos = cam and cam.CFrame.Position or (S.hrp and S.hrp.Position) or pos
	local dist = (vpos - c0).Magnitude
	local prox = ENV.prox(dist)
	local lag = math.min(dist / 450, 0.8)      -- am thanh / song rung toi tre hon anh sang mot chut

	local function snd(delay, vol, spd)
		local v = vol * prox
		if v < 0.04 then return end
		task.delay(lag + delay, function() playSound(SND_BOOM, v, spd) end)
	end
	local function sk(delay, mag, dur)
		local m = mag * prox
		if m < 0.05 then return end
		task.delay(lag + delay, function() shake(m, dur) end)
	end
	snd(0, 1.7, 0.5)
	snd(0.3, 1.4, 0.32)
	snd(1.1, 1.0, 0.62)
	sk(0, 3.4, 5)
	sk(1.6, 1.8, 3.5)
	sk(4, 0.8, 3)

	if prox > 0.03 then
		local cc = Instance.new("ColorCorrectionEffect")
		cc.Brightness = 1.7 * prox
		cc.Contrast = 0.25 * prox
		cc.TintColor = Color3.new(1, 1, 1):Lerp(Color3.fromRGB(255, 238, 205), prox)
		cc.Parent = Lighting
		tw(cc, 3, {Brightness = 0, Contrast = 0, TintColor = Color3.new(1, 1, 1)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		Debris:AddItem(cc, 3.4)
		local bl = Instance.new("BloomEffect")
		bl.Intensity = 3 * prox
		bl.Size = 40
		bl.Threshold = 0.8
		bl.Parent = Lighting
		tw(bl, 5, {Intensity = 0})
		Debris:AddItem(bl, 5.5)
		if cam then
			local fov = fovBase or cam.FieldOfView
			cam.FieldOfView = fov + 18 * prox
			tw(cam, 3, {FieldOfView = fov}, Enum.EasingStyle.Quad)
		end
	end
	nukeEnv(c0)

	-- ===== chop sang tai cho + tia sang toa ra =====
	local flash = fxPart("NFlash", Vector3.one * 8, COL.White, NEON, BALL)
	flash.CFrame = CFrame.new(c0)
	tw(flash, 0.7, {Size = Vector3.one * R * 2.8, Transparency = 1}, Enum.EasingStyle.Quad)
	Debris:AddItem(flash, 0.8)
	for _ = 1, 16 do
		local d = Vector3.new(fr(-1, 1), fr(-0.2, 1), fr(-1, 1))
		if d.Magnitude < 0.1 then d = Vector3.yAxis end
		d = d.Unit
		local len = R * fr(2.2, 3.6)
		local ray = fxPart("NRay", Vector3.new(R * 0.05, R * 0.05, 4), Color3.fromRGB(255, 240, 200), NEON)
		ray.CFrame = CFrame.lookAt(c0, c0 + d)
		ray.Transparency = 0.1
		tw(ray, 0.55, {Size = Vector3.new(0.3, 0.3, len), CFrame = CFrame.lookAt(c0 + d * len / 2, c0 + d * len), Transparency = 1}, Enum.EasingStyle.Quad)
		Debris:AddItem(ray, 0.65)
	end

	-- ===== qua cau lua nhieu lop (noi len nhe khi no) =====
	local layers = {
		{Color3.fromRGB(255, 255, 240), R * 0.95, 0.55, 1.3, 0},
		{Color3.fromRGB(255, 220, 115), R * 1.45, 0.85, 2.6, 0.1},
		{Color3.fromRGB(255, 125, 35), R * 1.95, 1.2, 4.0, 0.3},
		{Color3.fromRGB(185, 52, 22), R * 2.45, 1.7, 5.2, 0.55},
	}
	for _, L in ipairs(layers) do
		local b = fxPart("Fireball", Vector3.one * 6, L[1], NEON, BALL)
		b.CFrame = CFrame.new(c0)
		b.Transparency = L[5]
		tw(b, L[3], {Size = Vector3.one * L[2], CFrame = CFrame.new(c0 + Vector3.new(0, R * 0.25, 0))}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		task.delay(L[3] * 0.6, function() tw(b, L[4], {Transparency = 1}, Enum.EasingStyle.Linear) end)
		Debris:AddItem(b, L[3] * 0.6 + L[4] + 0.5)
	end
	for _ = 1, 18 do
		local d = Vector3.new(fr(-1, 1), fr(0.1, 1), fr(-1, 1)).Unit
		local b = fxPart("Lump", Vector3.one * 5, Color3.fromRGB(255, fr(120, 220), fr(40, 90)), NEON, BALL)
		b.CFrame = CFrame.new(c0)
		b.Transparency = 0.1
		local dur = fr(1.1, 1.9)
		tw(b, dur, {CFrame = CFrame.new(c0 + d * R * fr(0.35, 0.8)), Size = Vector3.one * R * fr(0.4, 0.8)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		task.delay(dur * 0.5, function() tw(b, fr(2.5, 4.5), {Transparency = 1}, Enum.EasingStyle.Linear) end)
		Debris:AddItem(b, dur + 6)
	end
	local lp = fxPart("NLight", Vector3.one, COL.Black, NEON, BALL)
	lp.Transparency = 1
	lp.CFrame = CFrame.new(c0)
	local pl = Instance.new("PointLight")
	pl.Range = 60
	pl.Brightness = 16
	pl.Color = Color3.fromRGB(255, 170, 80)
	pl.Parent = lp
	tw(pl, 7, {Brightness = 0}, Enum.EasingStyle.Linear)
	Debris:AddItem(lp, 8)

	-- lua + khoi bung ra
	local emP = fxPart("Em", Vector3.one * R * 0.5, COL.Black, NEON, BALL)
	emP.Transparency = 1
	emP.CFrame = CFrame.new(c0)
	Debris:AddItem(emP, 14)
	local fireE = mkEmitter(emP, {
		tex = FIRE_TEX, light = 0.8, life = NumberRange.new(2, 3.6), speed = NumberRange.new(R * 0.35, R * 0.9), drag = 1.6,
		shape = Enum.ParticleEmitterShape.Sphere,
		color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 180)), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 120, 30)), ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 40, 30))}),
		size = NSK({KP(0, R * 0.1), KP(0.4, R * 0.3), KP(1, R * 0.42)}),
	})
	fireE:Emit(150)
	task.delay(0.5, function()
		local sm = mkEmitter(emP, {
			life = NumberRange.new(6, 9), speed = NumberRange.new(R * 0.15, R * 0.5), drag = 1, acc = Vector3.new(0, 5, 0),
			shape = Enum.ParticleEmitterShape.Sphere,
			color = ColorSequence.new(Color3.fromRGB(90, 70, 60), Color3.fromRGB(50, 48, 46)),
			size = NSK({KP(0, R * 0.2), KP(1, R * 0.65)}),
			transp = NSK({KP(0, 0.3), KP(0.7, 0.6), KP(1, 1)}),
		})
		sm:Emit(110)
	end)

	-- ===== song xung kich + may ngung tu (Wilson) + bui cuon mat dat =====
	local dome = fxPart("Dome", Vector3.one * 8, Color3.fromRGB(255, 235, 200), NEON, BALL)
	dome.Transparency = 0.55
	dome.CFrame = CFrame.new(gx, gy, gz)
	tw(dome, 2.4, {Size = Vector3.one * R * 7, Transparency = 1})
	Debris:AddItem(dome, 2.6)
	local vapor = fxPart("Vapor", Vector3.one * 8, Color3.new(1, 1, 1), SMOOTH, BALL)
	vapor.Transparency = 0.8
	vapor.CFrame = CFrame.new(gx, gy + R * 0.2, gz)
	tw(vapor, 2.2, {Size = Vector3.one * R * 4, Transparency = 1})
	Debris:AddItem(vapor, 2.4)
	local wil = fxSphere("Wilson", Vector3.new(R * 1.5, R * 0.35, R * 1.5), Color3.fromRGB(235, 242, 255), SMOOTH)
	wil.Transparency = 0.7
	wil.CFrame = CFrame.new(gx, gy + R * 0.9, gz)
	tw(wil, 1.7, {Size = Vector3.new(R * 6, R * 0.5, R * 6), Transparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	Debris:AddItem(wil, 1.9)
	for i = 1, 3 do
		task.delay((i - 1) * 0.22, function()
			ringFx(Vector3.new(gx, gy + 0.6, gz), R * (2.4 + 0.9 * i), i % 2 == 0 and COL.Gold or Color3.fromRGB(255, 190, 110), 2.4)
		end)
	end
	for ring = 1, 2 do
		for i = 1, 36 do
			local a = (i / 36) * math.pi * 2 + rnd() * 0.18
			local p = fxSphere("Dust", Vector3.new(R * 0.3, R * 0.18, R * 0.3), Color3.fromRGB(118, 98, 80), SMOOTH)
			p.Transparency = 0.25
			p.CFrame = CFrame.new(gx, gy + R * 0.06, gz)
			local rd = R * (1.5 + ring * 0.75) * fr(0.85, 1.15)
			local dur = 2.6 + ring * 0.7
			tw(p, dur, {CFrame = CFrame.new(gx + math.cos(a) * rd, gy + R * 0.18, gz + math.sin(a) * rd), Size = Vector3.new(R * 0.7, R * 0.42, R * 0.7), Transparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			Debris:AddItem(p, dur + 0.2)
		end
	end
	local scorch = fxPart("Scorch", Vector3.new(0.5, R * 2.6, R * 2.6), Color3.fromRGB(255, 110, 30), NEON, CYL)
	scorch.CFrame = CFrame.new(gx, gy + 0.3, gz) * CFrame.Angles(0, 0, math.pi / 2)
	scorch.Transparency = 0.3
	tw(scorch, 12, {Transparency = 1, Color = Color3.fromRGB(60, 25, 15)}, Enum.EasingStyle.Linear)
	Debris:AddItem(scorch, 12.5)
	local crater = fxPart("Crater", Vector3.new(0.4, R * 1.1, R * 1.1), Color3.fromRGB(15, 10, 8), SMOOTH, CYL)
	crater.CFrame = CFrame.new(gx, gy + 0.35, gz) * CFrame.Angles(0, 0, math.pi / 2)
	crater.Transparency = 0.15
	task.delay(16, function() tw(crater, 5, {Transparency = 1}, Enum.EasingStyle.Linear) end)
	Debris:AddItem(crater, 22)

	-- ===== dam may hinh nam: mu = vong xoay (torus) cuon len, than = nhieu doan thon dan =====
	local balls = {}
	local function addBall(o)
		o.p = fxPart("Cloud", Vector3.one * R * 0.3, Color3.fromRGB(255, 150, 50), NEON, BALL)
		o.p.CFrame = CFrame.new(c0)
		o.sh = fr(0.85, 1.15)
		o.ph = fr(0, 6.28)
		balls[#balls + 1] = o
	end
	for ia = 1, 28 do
		for ib = 0, 2 do
			addBall({kind = "ring", a = (ia / 28) * math.pi * 2 + fr(-0.06, 0.06), b0 = ib * math.pi * 2 / 3 + fr(-0.3, 0.3), k = fr(0.8, 1.15)})
		end
	end
	for _ = 1, 16 do addBall({kind = "dome", a = fr(0, 6.28), rf = fr(0.05, 0.62), dy = fr(0, 0.55), k = fr(0.8, 1.1)}) end
	for _ = 1, 20 do addBall({kind = "stem", a = fr(0, 6.28), f = fr(0.04, 0.96), k = fr(0.75, 1.1)}) end

	local NS = 7
	local segs = {}
	for i = 1, NS do segs[i] = fxPart("Stem", Vector3.new(10, 10, 10), Color3.fromRGB(255, 140, 50), NEON, CYL) end
	local base = fxSphere("Base", Vector3.new(R * 1.6, R * 0.4, R * 1.6), Color3.fromRGB(110, 90, 75), SMOOTH)
	base.CFrame = CFrame.new(gx, gy + R * 0.1, gz)
	local pyro = fxSphere("Pyro", Vector3.new(R * 0.8, R * 0.15, R * 0.8), Color3.fromRGB(240, 244, 255), SMOOTH)
	pyro.Transparency = 1
	local glow = fxPart("CGlow", Vector3.one * R * 0.8, Color3.fromRGB(255, 150, 50), NEON, BALL)
	glow.Transparency = 0.35
	local gl = Instance.new("PointLight")
	gl.Range = 60
	gl.Brightness = 8
	gl.Color = Color3.fromRGB(255, 160, 70)
	gl.Parent = glow
	local capEm = fxPart("CapEm", Vector3.new(R * 0.8, R * 0.4, R * 0.8), COL.Black, NEON)
	capEm.Transparency = 1
	local stemEm = fxPart("StemEm", Vector3.new(R * 0.3, R, R * 0.3), COL.Black, NEON)
	stemEm.Transparency = 1
	local function smokeO()
		return {
			life = NumberRange.new(5, 8), speed = NumberRange.new(R * 0.05, R * 0.2), drag = 1, acc = Vector3.new(0, 4, 0),
			shape = Enum.ParticleEmitterShape.Box,
			color = ColorSequence.new(Color3.fromRGB(95, 75, 65), Color3.fromRGB(55, 52, 50)),
			size = NSK({KP(0, R * 0.2), KP(1, R * 0.55)}),
			transp = NSK({KP(0, 0.35), KP(0.7, 0.65), KP(1, 1)}),
		}
	end
	local capSmoke = mkEmitter(capEm, smokeO())
	local stemSmoke = mkEmitter(stemEm, smokeO())
	local all = {base, pyro, glow, capEm, stemEm}
	for _, s in ipairs(segs) do all[#all + 1] = s end
	for _, b in ipairs(balls) do all[#all + 1] = b.p end

	local T, t0 = 22, os.clock()
	local hot, cold, lightTop = Color3.fromRGB(255, 150, 55), Color3.fromRGB(80, 70, 64), Color3.fromRGB(150, 140, 130)
	local conn
	local function sway(f, t, wd) return math.sin(t * 0.6 + f * 2.4) * wd * 0.2 end
	conn = RunService.Heartbeat:Connect(function()
		local t = os.clock() - t0
		if t >= T then
			conn:Disconnect()
			for _, p in ipairs(all) do p:Destroy() end
			return
		end
		local grow = 1 - math.exp(-t / 4.4)
		local h = gy + R * 0.45 + R * 3.0 * grow
		local Rm = R * (0.32 + 1.0 * (1 - math.exp(-t / 3.4)))
		local rm = R * (0.2 + 0.36 * (1 - math.exp(-t / 3.4)))
		local cool = math.clamp(t / 8, 0, 1)
		local fade = math.clamp((t - (T - 6)) / 6, 0, 1)
		local len = math.max(2, (h - rm * 0.4) - gy)
		local wd = R * (0.26 - 0.1 * math.clamp(t / 10, 0, 1))
		local sz0 = math.min(1, t / 2.2)
		local swap = t > 1.8

		for _, c in ipairs(balls) do
			local p = c.p
			local x, y, z, size, heat = 0, 0, 0, 0, 0
			if c.kind == "ring" then
				local b = c.b0 + t * 1.0
				local rr = Rm + rm * math.cos(b)
				local ang = c.a + t * 0.05
				x, y, z = math.cos(ang) * rr, h + rm * math.sin(b) * 0.8, math.sin(ang) * rr
				size = rm * 0.95 * c.k
				heat = math.max(0, -math.sin(b)) * 0.8 + 0.2
				local wob = rm * 0.12 * math.sin(t * 1.7 + c.ph)
				x, z = x + wob, z + wob * math.cos(c.ph)
			elseif c.kind == "dome" then
				local ang = c.a + t * 0.04
				local rr = Rm * c.rf
				x, y, z = math.cos(ang) * rr, h + rm * (0.6 + c.dy), math.sin(ang) * rr
				size = rm * 1.0 * c.k
				heat = 0.3
			else
				local ang = c.a + t * 1.2 + c.f * 3
				local fw = 0.8 + 0.75 * (1 - c.f) ^ 3 + 0.25 * c.f ^ 4
				x = math.cos(ang) * wd * 0.85 * fw + sway(c.f, t, wd)
				z = math.sin(ang) * wd * 0.85 * fw
				y = gy + len * c.f
				size = wd * fw * c.k
				heat = (1 - c.f) * 0.6
			end
			p.CFrame = CFrame.new(gx + x, y, gz + z)
			p.Size = Vector3.one * math.max(0.5, size * (0.35 + 0.65 * sz0))
			local col = cold:Lerp(hot, heat * (1 - cool))
			if c.kind == "dome" then col = col:Lerp(lightTop, 0.25 * cool) end
			p.Color = Color3.new(math.min(1, col.R * c.sh), math.min(1, col.G * c.sh), math.min(1, col.B * c.sh))
			p.Transparency = fade
			if swap and p.Material == NEON then p.Material = SMOOTH end
		end

		for i, sg in ipairs(segs) do
			local fm = (i - 0.5) / NS
			local fw = 0.8 + 0.75 * (1 - fm) ^ 3 + 0.25 * fm ^ 4
			local w = wd * fw
			sg.Size = Vector3.new(len / NS * 1.2, w, w)
			sg.CFrame = CFrame.new(gx + sway(fm, t, wd), gy + len * fm, gz) * CFrame.Angles(0, 0, math.pi / 2)
			sg.Color = hot:Lerp(cold, math.clamp(cool + fm * 0.15, 0, 1))
			sg.Transparency = math.max(0.12, fade)
			if swap and sg.Material == NEON then sg.Material = SMOOTH end
		end

		local gw = R * (1.5 + 0.9 * grow)
		base.Size = Vector3.new(gw, R * 0.4, gw)
		base.Transparency = 0.25 + 0.75 * fade
		pyro.CFrame = CFrame.new(gx, h - rm * 0.55, gz)
		pyro.Size = Vector3.new(Rm * 2.1, rm * 0.3, Rm * 2.1)
		pyro.Transparency = 1 - 0.22 * math.clamp((t - 1) / 1.5, 0, 1) * (1 - fade)
		glow.CFrame = CFrame.new(gx, h - R * 0.05, gz)
		glow.Size = Vector3.one * (R * 0.8 * (1 - cool) + 1)
		glow.Transparency = 0.35 + 0.65 * cool
		gl.Brightness = (10 + math.sin(t * 9) * 1.5) * (1 - cool)
		capEm.CFrame = CFrame.new(gx, h, gz)
		capEm.Size = Vector3.new(Rm * 1.2, rm * 0.8, Rm * 1.2)
		stemEm.CFrame = CFrame.new(gx, gy + len / 2, gz)
		stemEm.Size = Vector3.new(wd, len, wd)
		local on = t < 13
		capSmoke.Rate = on and 80 or 0
		stemSmoke.Rate = on and 60 or 0
	end)

	-- manh vun + than cung (nho gon hon)
	debrisChunks(Vector3.new(gx, gy + 2, gz), 70, 80, true)
	for _ = 1, 60 do
		local p = Instance.new("Part")
		p.Size = Vector3.one * fr(0.5, 1.3)
		p.Color = Color3.fromRGB(255, 130, 40)
		p.Material = NEON
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.Position = Vector3.new(gx, gy + 4, gz)
		p.Parent = FX
		p.AssemblyLinearVelocity = Vector3.new(fr(-110, 110), fr(50, 160), fr(-110, 110))
		tw(p, 4, {Transparency = 1}, Enum.EasingStyle.Linear)
		Debris:AddItem(p, 4.2)
	end
	local e = Instance.new("Explosion")
	e.Position = pos
	e.BlastRadius = R * 0.9
	e.BlastPressure = 0
	e.DestroyJointRadiusPercent = 0
	e.Visible = false
	e.Parent = Workspace
end

local function nuke()
	if S.nuking or not S.on then return end
	S.nuking = true
	S.strikes = {}
	if not S.extras then summonExtras() end
	S.mode = "charge"
	local my = S
	local hrp, pel, hum = S.hrp, S.parts.Pelvis, S.hum
	local aimPoint = mouse.Hit.Position          -- khoa huong ban ngay luc bam
	local prevWalk = hum.WalkSpeed
	hum.WalkSpeed = prevWalk * 0.6

	local core = fxPart("NCore", Vector3.one, COL.White, NEON, BALL)
	local plasma = fxPart("NPlasma", Vector3.one, Color3.fromRGB(90, 200, 255), NEON, BALL)
	plasma.Transparency = 0.35
	local shell = fxPart("NShell", Vector3.one, COL.Glow, NEON, BALL)
	shell.Transparency = 0.8
	local rings = {
		fxPart("NRingA", Vector3.new(0.25, 2, 2), COL.Glow, NEON, CYL),
		fxPart("NRingB", Vector3.new(0.25, 2, 2), COL.Gold, NEON, CYL),
		fxPart("NRingC", Vector3.new(0.2, 2, 2), COL.White, NEON, CYL),
	}
	local sats = {}
	for i = 1, 8 do sats[i] = fxPart("NSat", Vector3.one * 0.6, i % 2 == 0 and COL.Glow or COL.Gold, NEON, BALL) end
	local aimLine = fxPart("NAim", Vector3.new(0.12, 0.12, 1), COL.Glow, NEON)
	aimLine.Transparency = 0.7
	local aimDot = fxPart("NAimDot", Vector3.one, COL.Glow, NEON, BALL)
	aimDot.Transparency = 0.4
	local lt = Instance.new("PointLight")
	lt.Range = 40
	lt.Brightness = 3
	lt.Color = COL.Glow
	lt.Parent = core
	local sp = Instance.new("ParticleEmitter")
	sp.Color = ColorSequence.new(COL.Glow, COL.White)
	sp.LightEmission = 1
	sp.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.4), NumberSequenceKeypoint.new(1, 0)})
	sp.Lifetime = NumberRange.new(0.4, 0.9)
	sp.Speed = NumberRange.new(6, 18)
	sp.Rate = 140
	sp.SpreadAngle = Vector2.new(180, 180)
	sp.LockedToPart = false
	sp.Parent = core
	local hl = Instance.new("Highlight")
	hl.Adornee = S.armor
	hl.FillTransparency = 1
	hl.OutlineColor = COL.Glow
	hl.OutlineTransparency = 1
	hl.DepthMode = Enum.HighlightDepthMode.Occluded
	hl.Parent = FX
	tw(hl, 1.5, {OutlineTransparency = 0.35})
	local cam = Workspace.CurrentCamera
	local fov0 = cam.FieldOfView
	tw(cam, CFG.NukeCharge, {FieldOfView = fov0 - 8}, Enum.EasingStyle.Quad)

	local rp = rayParams()
	local t0 = os.clock()
	local phase, pos, dir, holdT = "charge", pel.Position, nil, 0
	local life, acc, ringT, arcT, pebT, trailT = 0, 0, 0, 0, 0, 0
	local conn

	local function finish(explode, at)
		if conn then conn:Disconnect() end
		for _, p in ipairs({core, plasma, shell, aimLine, aimDot}) do p:Destroy() end
		for _, p in ipairs(rings) do p:Destroy() end
		for _, p in ipairs(sats) do p:Destroy() end
		tw(hl, 0.6, {OutlineTransparency = 1})
		Debris:AddItem(hl, 0.7)
		pcall(function() tw(cam, 1.2, {FieldOfView = fov0}) end)
		if S == my then
			S.nuking = false
			S.chargeA = 0
			if S.mode == "charge" then S.mode = "idle" end
			pcall(function() hum.WalkSpeed = prevWalk end)
		end
		if explode then nukeBoom(at, fov0) end
	end

	conn = RunService.RenderStepped:Connect(function(dt)
		if S ~= my or not S.on or not S.nuking or not pel.Parent then finish(false) return end
		local el = os.clock() - t0
		local r

		if phase == "charge" or phase == "hold" then
			local a = math.clamp(el / CFG.NukeCharge, 0, 1)
			S.chargeA = a
			r = 0.5 + (CFG.NukeBall - 0.5) * a ^ 1.4
			pos = (pel.CFrame * CFrame.new(0, 3.0 * SC, -(7 * SC + r * 0.9))).Position
			shake(0.1 + 0.55 * a, 0.12)

			-- tia nang luong hoi tu
			acc += dt * 130 * (0.4 + a)
			while acc >= 1 do
				acc -= 1
				local d = Vector3.new(fr(-1, 1), fr(-1, 1), fr(-1, 1))
				if d.Magnitude > 0.05 then
					d = d.Unit * (r + 10 + math.random() * 16)
					local s2 = fxPart("Conv", Vector3.new(0.3, 0.3, 1.8), (math.random() < 0.5) and COL.Glow or COL.White, NEON)
					s2.CFrame = CFrame.lookAt(pos + d, pos)
					tw(s2, 0.4, {CFrame = CFrame.lookAt(pos, pos - d), Transparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
					Debris:AddItem(s2, 0.5)
				end
			end
			-- dien phong tu qua cau
			arcT += dt
			if arcT > 0.06 then
				arcT = 0
				for _ = 1, 2 + math.floor(a * 2) do
					local d = Vector3.new(fr(-1, 1), fr(-1, 1), fr(-1, 1))
					if d.Magnitude > 0.05 then
						d = d.Unit
						local p0 = pos + d * r
						local p1
						local pick = math.random()
						local hnd = S.parts[pick < 0.5 and "HandR" or "HandL"]
						if pick < 0.6 and hnd then p1 = hnd.Position
						elseif pick < 0.8 then p1 = groundPos() + Vector3.new(fr(-8, 8), 0.2, fr(-8, 8))
						else p1 = pos + d * (r * 2.4 + fr(2, 8)) end
						bolt(p0, p1, math.random() < 0.5 and COL.Glow or COL.White, 0.14 + 0.1 * a)
					end
				end
			end
			-- vong nang luong + da bay len duoi chan
			ringT += dt
			if ringT > 0.4 then
				ringT = 0
				local gpos = groundPos() + Vector3.new(0, 0.3, 0)
				ringFx(gpos, 8 + 16 * a, COL.WingGlow, 0.8)
				ringFx(gpos, 18 + 20 * a, Color3.fromRGB(200, 190, 170), 1.0)
			end
			pebT += dt
			if pebT > 0.05 then
				pebT = 0
				local gpos = groundPos()
				local off = Vector3.new(fr(-12, 12), 0.3, fr(-12, 12))
				local pb = fxPart("Pebble", Vector3.one * fr(0.3, 1.1), Color3.fromRGB(110, 95, 80), SMOOTH)
				pb.CFrame = CFrame.new(gpos + off) * CFrame.Angles(fr(0, 6), fr(0, 6), 0)
				local dest = gpos + off * 0.4 + Vector3.new(0, fr(6, 18), 0)
				tw(pb, 1.2, {CFrame = CFrame.new(dest) * CFrame.Angles(fr(0, 6), fr(0, 6), 0), Transparency = 1}, Enum.EasingStyle.Quad)
				Debris:AddItem(pb, 1.3)
			end
			-- laser huong ban khoa
			local toAim = aimPoint - pos
			local dl = math.min(toAim.Magnitude, 500)
			if toAim.Magnitude > 1 then
				local ad = toAim.Unit
				aimLine.Size = Vector3.new(0.12, 0.12, dl)
				aimLine.CFrame = CFrame.lookAt(pos + ad * dl / 2, pos + ad * dl)
				aimDot.Position = pos + ad * dl
				aimDot.Size = Vector3.one * (1.2 + math.sin(el * 8) * 0.3)
			end

			if a >= 1 and phase == "charge" then phase = "hold"; holdT = os.clock() end
			if phase == "hold" and os.clock() - holdT > 0.4 then
				phase = "fly"
				S.mode = "release"
				S.recoil = 1
				S.chargeA = 0
				local d = aimPoint - pos
				dir = d.Magnitude > 6 and d.Unit or hrp.CFrame.LookVector
				aimLine:Destroy()
				aimDot:Destroy()
				sp.Rate = 260
				shake(1.6, 0.7)
				ringFx(pos, 26, COL.Glow, 0.5)
				ringFx(pos, 40, Color3.fromRGB(255, 255, 255), 0.7)
				task.delay(0.9, function() if S == my and S.mode == "release" then S.mode = "idle" end end)
			end
		else
			r = CFG.NukeBall
			life += dt
			local step = dir * CFG.NukeSpeed * dt
			local res = Workspace:Raycast(pos, step + dir * r, rp)
			if res or life > 5 then
				finish(true, res and res.Position or (pos + step))
				return
			end
			pos += step
			trailT += dt
			if trailT > 0.025 then
				trailT = 0
				local gh = fxPart("Ghost", Vector3.one * r * 1.7, COL.Glow, NEON, BALL)
				gh.Transparency = 0.55
				gh.CFrame = CFrame.new(pos)
				tw(gh, 0.4, {Size = Vector3.one * r * 0.4, Transparency = 1})
				Debris:AddItem(gh, 0.45)
			end
		end

		local c = CFrame.new(pos)
		local pulse = 1 + math.sin(el * 14) * 0.04
		core.Size = Vector3.one * r * 0.9 * pulse
		plasma.Size = Vector3.one * r * 1.5
		shell.Size = Vector3.one * r * 2.2
		core.CFrame, plasma.CFrame, shell.CFrame = c, c, c
		local radii = {2.9, 3.5, 4.1}
		for i, rg in ipairs(rings) do
			rg.Size = Vector3.new(0.25, r * radii[i], r * radii[i])
			rg.CFrame = c * CFrame.Angles(el * (2.5 + i), el * (1.4 - i * 0.5), el * (i * 0.9))
		end
		for i, st in ipairs(sats) do
			local ang = el * (2 + i * 0.3) + i * 0.8
			st.CFrame = c * CFrame.Angles(i * 0.6, 0, i * 0.4) * CFrame.new(math.cos(ang) * r * 1.7, math.sin(ang * 1.3) * r * 0.5, math.sin(ang) * r * 1.7)
			st.Size = Vector3.one * math.max(0.3, r * 0.14)
		end
		lt.Range = math.min(60, 20 + r * 5)
		lt.Brightness = 3 + r * 0.4
	end)
end

------------------------------------------------------------------
-- BAY (kieu fly3, khong bi shift-lock ghi de)
------------------------------------------------------------------
local function noclipOn()
	S.ccSaved = {}
	S.ctSaved = {}
	for _, p in ipairs(S.char:GetDescendants()) do
		if p:IsA("BasePart") then
			S.ccSaved[p] = p.CanCollide
			S.ctSaved[p] = p.CanTouch
			p.CanTouch = false -- khong kich hoat Touched cua game (bay xuyen vat the)
		end
	end
end
local function noclipOff()
	if S.ctSaved then
		for p, v in pairs(S.ctSaved) do if p.Parent then p.CanTouch = v end end
		S.ctSaved = nil
	end
	if S.ccSaved then
		for p, v in pairs(S.ccSaved) do if p.Parent then p.CanCollide = v end end
		S.ccSaved = nil
	end
end

local function beginAirControl()
	local hrp, hum = S.hrp, S.hum
	noclipOn()
	pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
	hum.PlatformStand = true
	hum.AutoRotate = false
	S.fpos = hrp.Position
	S.frot = hrp.CFrame.Rotation
end

local function startFly()
	if not S.on or S.drone or S.busy or S.ctrl == "fly" then return end
	if not S.ctrl then
		beginAirControl()
		S.fvel = Vector3.new(0, 30, 0)
	end
	S.ctrl = "fly"
	S.stomp = false
	S.flying = true
	buildWings()
	ringFx(groundPos() + Vector3.new(0, 0.4, 0), 14, COL.Fire, 0.6)
	shake(0.8, 0.4)
end

local function stopFly()
	if S.ctrl ~= "fly" then return end
	S.ctrl = "land"
	S.stomp = false
	S.flying = false
	if S.wings then S.wings.target = 0 end
end

-- NHAY: dung co che bay v3 (Humanoid khong tu roi => khong bi mat mau khi dap dat)
local function startLeap()
	if not S.on or S.drone or S.busy or S.assembling or S.ctrl then return end
	local v = S.hrp.AssemblyLinearVelocity
	beginAirControl()
	S.fvel = Vector3.new(v.X, CFG.LeapPower, v.Z)
	S.leapPeak = S.fpos.Y
	S.ctrl = "leap"
	jumpFx()
end

-- ROI TU CAO: tu dong chuyen sang ha canh an toan (dap chan xuong dat)
local function startLand()
	if not S.on or S.drone or S.busy or S.assembling or S.ctrl then return end
	local v = S.hrp.AssemblyLinearVelocity
	beginAirControl()
	S.leapPeak = math.max(S.airTop or S.fpos.Y, S.fpos.Y)
	S.fvel = Vector3.new(v.X * 0.5, math.max(v.Y, -CFG.MaxFallSpeed), v.Z * 0.5)
	S.ctrl = "land"
	S.stomp = true
end

local function releaseControl()
	local hrp, hum = S.hrp, S.hum
	local look = S.frot.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	if flat.Magnitude < 0.01 then flat = Vector3.new(0, 0, -1) end
	-- chong xuyen dat: dat lai dung do cao tren mat dat
	local pos = S.fpos
	local minH = math.max(hum.HipHeight + hrp.Size.Y / 2, 3)
	local res = Workspace:Raycast(pos + Vector3.new(0, 6, 0), Vector3.new(0, -80, 0), S.rp)
	if res and pos.Y < res.Position.Y + minH then
		pos = Vector3.new(pos.X, res.Position.Y + minH, pos.Z)
	end
	local drop = math.max(0, (S.leapPeak or pos.Y) - pos.Y)
	local power = S.stomp and math.clamp(0.35 + drop / 50, 0.35, 1) or 0.7
	hrp.CFrame = CFrame.lookAt(pos, pos + flat.Unit)
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
	S.ctrl = nil
	S.flying = false
	S.stomp = false
	S.leapPeak = nil
	noclipOff()
	hum.PlatformStand = false
	hum.AutoRotate = true
	pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
	S.land = 0.5 + 0.4 * power
	S.noColUntil = os.clock() + 0.4
	slamFx(power)
end

local function blockWalls(dt)
	local h = Vector3.new(S.fvel.X, 0, S.fvel.Z)
	if h.Magnitude > 1 then
		local res = Workspace:Raycast(S.fpos, h.Unit * (3.2 + h.Magnitude * dt), S.rp)
		if res then S.fvel = Vector3.new(0, S.fvel.Y, 0) end
	end
end

local function ctrlStep(dt)
	local hrp, hum = S.hrp, S.hum
	local cam = Workspace.CurrentCamera
	local cl = cam.CFrame
	local look = cl.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	flat = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, -1)
	local mv = hum.MoveDirection

	-- LO LUNG (hop the): nhan vat duoc thruster nang len, giu CFrame co dinh
	if S.ctrl == "hover" then
		S.hoverY = ease(S.hoverY, S.hoverGoal, S.hoverRate or 2.4, dt)
		S.fpos = Vector3.new(S.hoverXZ.X, S.hoverY, S.hoverXZ.Z)
		if S.hoverFeet then
			S.hoverFxT = (S.hoverFxT or 0) - dt
			if S.hoverFxT <= 0 then
				S.hoverFxT = 0.32
				local gp = Vector3.new(S.fpos.X, (S.hoverGy or S.fpos.Y - 8) + 0.2, S.fpos.Z)
				local h = math.clamp((S.fpos.Y - gp.Y) / 14, 0.3, 1)
				ringFx(gp, 9 + 8 * h, COL.WingGlow, 0.6)
				dustBurst(gp, 6, 8, nil, 1.3)
				shake(0.15 + 0.15 * h, 0.15)
			end
		end
		local bob = S.hoverFeet and math.sin(S.t * 2.2) * 0.1 or 0
		S.tiltW = ease(S.tiltW, 0, 8, dt)
		hrp.CFrame = CFrame.new(S.fpos + Vector3.new(0, bob, 0)) * S.frot
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
		return
	end

	if S.ctrl == "leap" then
		local ws = (S.orig and S.orig.Walk or 16) * CFG.WalkMult
		local hv = Vector3.new(S.fvel.X, 0, S.fvel.Z):Lerp(Vector3.new(mv.X * ws, 0, mv.Z * ws), 1 - math.exp(-dt * 3))
		-- trong luc khi nhay = 70% trong luc goc; toc do ha xuong bi gioi han + giam dan khi gan dat
		local vy = S.fvel.Y - (S.orig and S.orig.Grav or Workspace.Gravity) * CFG.JumpGravity * dt
		if vy < -CFG.LeapLandSpeed then vy = -CFG.LeapLandSpeed end
		local thr = math.max(hum.HipHeight + hrp.Size.Y / 2, 3) + 1.0
		local gap
		if vy < 0 then
			local gr = Workspace:Raycast(S.fpos, Vector3.new(0, -300, 0), S.rp)
			if gr then
				gap = S.fpos.Y - gr.Position.Y
				local cap = CFG.LandTouchSpeed + math.max(0, gap - thr) * 5
				if vy < -cap then vy = -cap end
			end
		end
		if vy > 0 and Workspace:Raycast(S.fpos, Vector3.new(0, 7, 0), S.rp) then vy = 0 end
		S.fvel = Vector3.new(hv.X, vy, hv.Z)
		blockWalls(dt)
		S.fpos = S.fpos + S.fvel * dt
		S.leapPeak = math.max(S.leapPeak or S.fpos.Y, S.fpos.Y)
		-- cham dat khi dang roi: tra quyen dieu khien (toc do luc nay chi con ~LandTouchSpeed)
		if gap and gap + vy * dt <= thr then
			S.stomp = true -- power hieu ung tinh theo do cao that => nhe khi nhay thap
			releaseControl()
			return
		end
	else
		local targetVel = Vector3.zero
		local landCap
		if S.ctrl == "fly" then
			if mv.Magnitude > 0.05 then
				local ld = cl:VectorToObjectSpace(mv)
				local d = cl.RightVector * ld.X + cl.LookVector * (-ld.Z)
				if d.Magnitude > 0.01 then targetVel = d.Unit * CFG.FlySpeed end
			end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then targetVel += Vector3.new(0, CFG.FlySpeed * 0.8, 0) end
			if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then targetVel -= Vector3.new(0, CFG.FlySpeed * 0.8, 0) end
			if targetVel.Magnitude > CFG.FlySpeed then targetVel = targetVel.Unit * CFG.FlySpeed end
		else
			local ls = S.stomp and CFG.StompSpeed or CFG.SafeLandSpeed
			targetVel = Vector3.new(mv.X * 28, -ls, mv.Z * 28)
			local res = Workspace:Raycast(S.fpos, Vector3.new(0, -300, 0), S.rp)
			if res then
				local d = S.fpos.Y - res.Position.Y
				local thr = math.max(hum.HipHeight + hrp.Size.Y / 2, 3) + 1.0
				if d <= thr then
					releaseControl()
					return
				end
				landCap = CFG.LandTouchSpeed + (d - thr) * 5 -- giam toc dan truoc khi cham dat
			end
		end
		S.fvel = S.fvel:Lerp(targetVel, 1 - math.exp(-dt * 7))
		if landCap and S.fvel.Y < -landCap then S.fvel = Vector3.new(S.fvel.X, -landCap, S.fvel.Z) end
		if S.ctrl == "land" then blockWalls(dt) end
		S.fpos = S.fpos + S.fvel * dt
	end

	local sp = S.fvel.Magnitude
	local faceDir = flat
	if S.ctrl ~= "fly" then
		local h = Vector3.new(S.fvel.X, 0, S.fvel.Z)
		if h.Magnitude > 3 then
			faceDir = h.Unit
		else
			local cur = S.frot.LookVector
			local c2 = Vector3.new(cur.X, 0, cur.Z)
			if c2.Magnitude > 0.01 then faceDir = c2.Unit end
		end
	end
	local hoverRot = CFrame.lookAt(Vector3.zero, faceDir)
	local rot = hoverRot
	local tiltW = 0
	if S.ctrl == "fly" and sp > 6 then
		local fwd = S.fvel.Unit
		if math.abs(fwd.Y) > 0.995 then fwd = (fwd + flat * 0.05).Unit end
		local flyRot = CFrame.lookAt(Vector3.zero, fwd) * CFrame.Angles(-math.pi / 2, 0, 0)
		tiltW = math.clamp(sp / (CFG.FlySpeed * 0.4), 0, 1)
		rot = hoverRot:Lerp(flyRot, tiltW)
	end
	S.tiltW = ease(S.tiltW, tiltW, 8, dt)
	S.frot = S.frot:Lerp(rot, 1 - math.exp(-dt * 9))
	hrp.CFrame = CFrame.new(S.fpos) * S.frot
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
end

------------------------------------------------------------------
-- GIAP ROI TU DI THEO CHU (sau khi nhan vat buoc ra khoi giap)
------------------------------------------------------------------
local function droneStep(dt)
	local shell, fake = S.hrp, S.hum
	local owner = S.phrp
	if not (owner and owner.Parent) then return end
	local op = owner.Position
	local ol = owner.CFrame
	local lookF = Vector3.new(ol.LookVector.X, 0, ol.LookVector.Z)
	lookF = lookF.Magnitude > 0.01 and lookF.Unit or Vector3.new(0, 0, -1)
	local rightF = lookF:Cross(Vector3.yAxis)

	-- toc do cua chu: do theo vi tri (bay v3 dat CFrame nen velocity = 0)
	local inst = S.olast and (op - S.olast).Magnitude / math.max(dt, 0.001) or 0
	S.olast = op
	S.ospd = lerp(S.ospd, math.min(inst, 500), math.min(1, dt * 6))

	local pos = S.fpos
	if S.dhold then
		S.dvel = S.dvel:Lerp(Vector3.zero, 1 - math.exp(-dt * 10))
		fake.FloorMaterial = Enum.Material.Plastic
		S.tiltW = ease(S.tiltW, 0, 8, dt)
		if S.dfaceOwner then
			local to = Vector3.new(op.X - pos.X, 0, op.Z - pos.Z)
			if to.Magnitude > 0.5 then
				S.frot = S.frot:Lerp(CFrame.lookAt(Vector3.zero, to.Unit), 1 - math.exp(-dt * 6))
			end
		end
		shell.CFrame = CFrame.new(S.fpos) * S.frot
		return
	end

	local dist = (op - pos).Magnitude
	local gres = Workspace:Raycast(op + Vector3.new(0, 2, 0), Vector3.new(0, -60, 0), S.rp)
	local ownerAir = gres and (op.Y - gres.Position.Y) or 99

	-- chon che do: di bo / bay (tu dong bay khi chu chay hoac bay qua nhanh)
	local mode = S.dmode
	if S.dforce then
		mode = S.dforce
	elseif os.clock() < S.dflyUntil then
		mode = "fly"
	elseif mode == "walk" and (S.ospd > CFG.DroneAutoFlySpeed or dist > 90 or ownerAir > 22) then
		mode = "fly"
	elseif mode == "fly" and S.ospd < 28 and dist < 30 and ownerAir < 14 then
		mode = "walk"
	end
	S.dmode = mode
	if S.dlast ~= mode then
		S.dlast = mode
		if mode == "fly" then
			buildWings()
			ringFx(groundPos() + Vector3.new(0, 0.4, 0), 14, COL.Fire, 0.6)
		elseif S.wings then
			S.wings.target = 0
		end
	end

	local tgt
	if S.denter then tgt = op + lookF * 5 else tgt = op - lookF * 9 + rightF * 5 end

	if mode == "walk" then
		local to = Vector3.new(tgt.X - pos.X, 0, tgt.Z - pos.Z)
		local d = to.Magnitude
		local maxSp = math.clamp(S.ospd * 1.25 + 14, 22, 75)
		local want = Vector3.zero
		if d > 1.5 then want = to.Unit * math.min(maxSp, (d - 1.5) * 3.5) end
		local hv = Vector3.new(S.dvel.X, 0, S.dvel.Z):Lerp(want, 1 - math.exp(-dt * 6))
		-- gap tuong: dung lai, ket lau thi bay qua
		if hv.Magnitude > 4 then
			local wall = Workspace:Raycast(pos - Vector3.new(0, LB * 0.4, 0), hv.Unit * 3.8, S.rp)
			if wall then
				hv = Vector3.zero
				S.dstuck += dt
				if S.dstuck > 1.2 then
					S.dstuck = 0
					S.dflyUntil = os.clock() + 3
				end
			else
				S.dstuck = 0
			end
		else
			S.dstuck = 0
		end
		-- bam mat dat; dang o tren cao thi ha xuong va dap chan
		local res = Workspace:Raycast(Vector3.new(pos.X, pos.Y + 8, pos.Z), Vector3.new(0, -90, 0), S.rp)
		local gy = res and (res.Position.Y + LB) or pos.Y
		local ny
		local vy = 0
		if pos.Y > gy + 0.35 then
			local fall = math.min(90, (pos.Y - gy) * 6 + 12)
			ny = math.max(gy, pos.Y - fall * dt)
			vy = -fall
			S.dair = true
		else
			ny = pos.Y + (gy - pos.Y) * (1 - math.exp(-dt * 12))
			if S.dair then
				S.dair = false
				slamFx(0.45)
			end
		end
		S.dvel = Vector3.new(hv.X, vy, hv.Z)
		S.fpos = Vector3.new(pos.X + hv.X * dt, ny, pos.Z + hv.Z * dt)
		fake.FloorMaterial = S.dair and Enum.Material.Air or Enum.Material.Plastic
		local faceDir = lookF
		if hv.Magnitude > 3 then faceDir = hv.Unit end
		if S.denter then
			local f = Vector3.new(op.X - pos.X, 0, op.Z - pos.Z)
			if f.Magnitude > 0.5 then faceDir = f.Unit end
		end
		S.tiltW = ease(S.tiltW, 0, 8, dt)
		S.frot = S.frot:Lerp(CFrame.lookAt(Vector3.zero, faceDir), 1 - math.exp(-dt * 7))
	else
		local to = (tgt + Vector3.new(0, 4, 0)) - pos
		local d = to.Magnitude
		local maxSp = math.clamp(S.ospd * 1.6 + 50, 80, CFG.DroneFlySpeed)
		local want = Vector3.zero
		if d > 2 then want = to.Unit * math.min(maxSp, d * 4) end
		S.dvel = S.dvel:Lerp(want, 1 - math.exp(-dt * 5))
		local np = pos + S.dvel * dt
		local res = Workspace:Raycast(Vector3.new(np.X, np.Y + 4, np.Z), Vector3.new(0, -60, 0), S.rp)
		if res and np.Y < res.Position.Y + LB then
			np = Vector3.new(np.X, res.Position.Y + LB, np.Z)
		end
		S.fpos = np
		S.dair = false
		fake.FloorMaterial = Enum.Material.Air
		local sp = S.dvel.Magnitude
		local hoverRot = CFrame.lookAt(Vector3.zero, lookF)
		local rot = hoverRot
		local tiltW = 0
		if sp > 6 then
			local fwd = S.dvel.Unit
			if math.abs(fwd.Y) > 0.995 then fwd = (fwd + lookF * 0.05).Unit end
			local flyRot = CFrame.lookAt(Vector3.zero, fwd) * CFrame.Angles(-math.pi / 2, 0, 0)
			tiltW = math.clamp(sp / (CFG.FlySpeed * 0.4), 0, 1)
			rot = hoverRot:Lerp(flyRot, tiltW)
		end
		S.tiltW = ease(S.tiltW, tiltW, 8, dt)
		S.frot = S.frot:Lerp(rot, 1 - math.exp(-dt * 9))
	end
	shell.CFrame = CFrame.new(S.fpos) * S.frot
end

------------------------------------------------------------------
-- GIAM ANH SANG GIAP
------------------------------------------------------------------
local function tone(root)
	if not root then return end
	for _, d in ipairs(root:GetDescendants()) do
		if not d:GetAttribute("HBt") then
			if d:IsA("BasePart") then
				if d.Material == NEON and d.Transparency < 0.85 then
					d.Transparency = d.Transparency + (1 - d.Transparency) * 0.3
				end
				d:SetAttribute("HBt", true)
			elseif d:IsA("PointLight") then
				d.Brightness = d.Brightness * 0.4
				d.Range = d.Range * 0.8
				d:SetAttribute("HBt", true)
			elseif d:IsA("ParticleEmitter") or d:IsA("Trail") then
				d.LightEmission = d.LightEmission * 0.5
				d:SetAttribute("HBt", true)
			end
		end
	end
end

------------------------------------------------------------------
-- UPDATE (animation thu cong, chay SAU camera/shift-lock)
------------------------------------------------------------------
local function setArmorCollide(on)
	for _, n in ipairs(COLL) do
		if S.parts[n] then S.parts[n].CanCollide = on end
	end
	S.colOn = on
end

local function update(dt)
	if not S.on then return end
	local hrp, hum = S.hrp, S.hum
	if not (S.armor and S.armor.Parent and hrp and hrp.Parent) then return end
	S.t += dt
	local t = S.t

	S.openW = ease(S.openW, S.openGoal, 5, dt)
	S.legCloseW = ease(S.legCloseW or 0, S.legClose and 1 or 0, 7, dt)
	S.armCloseW = ease(S.armCloseW or 0, S.armClose and 1 or 0, 7, dt)
	-- khoang than: Torso trong suot khi cua truoc mo de thay ben trong
	local cav = S.openW > 0.04
	if cav ~= S.cavity and S.parts.Torso then
		S.cavity = cav
		S.parts.Torso.Transparency = cav and 1 or 0
	end
	S.toneT = (S.toneT or 0) - dt
	if S.toneT <= 0 then
		S.toneT = 0.5
		tone(S.armor)
	end
	if S.drone then droneStep(dt) elseif S.ctrl then ctrlStep(dt) end
	if not S.on then return end

	local droneFlyOn = S.drone and S.dmode == "fly"
	S.flying = S.ctrl == "fly" or droneFlyOn
	local flyOn = (S.ctrl ~= nil and S.ctrl ~= "hover") or droneFlyOn
	S.flyW = ease(S.flyW, flyOn and 1 or 0, 6, dt)
	S.thrW = ease(S.thrW, flyOn and 1 or 0, 8, dt)
	S.wC = ease(S.wC, S.mode == "charge" and 1 or 0, 4, dt)
	S.recoil = math.max(0, S.recoil - dt * 1.4)
	S.land = math.max(0, S.land - dt * 2.2)
	S.kick = math.max(0, S.kick - dt * 4)

	local vel = S.drone and S.dvel or hrp.AssemblyLinearVelocity
	local sp = Vector3.new(vel.X, 0, vel.Z).Magnitude
	local grounded = (hum.FloorMaterial ~= Enum.Material.Air) and not S.ctrl

	-- theo doi do cao roi + tu dong ha canh an toan khi roi cao
	if grounded then
		S.airTop = hrp.Position.Y
	else
		S.airTop = math.max(S.airTop or hrp.Position.Y, hrp.Position.Y)
	end
	if not S.ctrl and not S.drone and not S.assembling and not S.busy and vel.Y < -CFG.AutoLandSpeed and hum.FloorMaterial == Enum.Material.Air then
		startLand()
	end

	-- trong luc nhe: roi cham hon
	if not S.ctrl and not S.drone and vel.Y < -2 then
		local nv = vel.Y + Workspace.Gravity * CFG.FallSlow * dt
		if nv < -CFG.MaxFallSpeed then nv = -CFG.MaxFallSpeed end
		hrp.AssemblyLinearVelocity = Vector3.new(vel.X, nv, vel.Z)
		vel = hrp.AssemblyLinearVelocity
	end
	-- giam toc truoc khi dam tuong (di bo toc do cao) de khong bi tinh sat thuong va cham
	if CFG.SoftWalls and grounded and not S.ctrl and not S.drone and not S.assembling then
		local hv = Vector3.new(vel.X, 0, vel.Z)
		if hv.Magnitude > 6 then
			local reach = 2.8 + hv.Magnitude * 0.14
			local wr = Workspace:Raycast(hrp.Position, hv.Unit * reach, S.rp)
			if wr and math.abs(wr.Normal.Y) < 0.5 then
				local k = math.clamp((wr.Distance - 2.6) / (reach - 2.6), 0, 1)
				hrp.AssemblyLinearVelocity = Vector3.new(vel.X * k, vel.Y, vel.Z * k)
				vel = hrp.AssemblyLinearVelocity
			end
		end
	end
	if vel.Y < S.lastVy then S.lastVy = vel.Y end

	-- do mat dat (chi khi dung vung)
	if S.ctrl then
		S.rootY = ease(S.rootY, 0, 6, dt)
	elseif grounded and math.abs(vel.Y) < 25 then
		local res = Workspace:Raycast(hrp.Position, Vector3.new(0, -25, 0), S.rp)
		if res then
			local d = hrp.Position.Y - res.Position.Y
			S.rootY = ease(S.rootY, math.clamp(LB - d, -0.6, 4), 10, dt)
		end
	end
	-- chong chan giap lun xuong dat
	if grounded and S.parts.FootR then
		local pen = -9
		for _, fp in ipairs({S.parts.FootR, S.parts.FootL}) do
			local res = Workspace:Raycast(fp.Position + Vector3.new(0, 3, 0), Vector3.new(0, -8, 0), S.rp)
			if res then pen = math.max(pen, res.Position.Y - (fp.Position.Y - 0.5 * SC)) end
		end
		if pen < -8 then pen = -S.fix end
		-- do lun that = do do duoc + phan da nang len (S.fix) => on dinh, khong dao dong len/xuong
		local need = pen + S.fix
		if need < 0.12 then need = 0 end
		S.fix = ease(S.fix, math.min(1.5, need), need > S.fix and 12 or 3, dt)
	else
		S.fix = ease(S.fix, 0, 3, dt)
	end

	-- chong ket: khong di chuyen duoc thi tat va cham + nang len
	local blocked = false
	if grounded and not S.assembling and not S.drone and hum.MoveDirection.Magnitude > 0.1 and sp < 1.5
		and (hum.WalkSpeed or 0) > 4 and os.clock() > (S.stuckCd or 0) then
		local wr = Workspace:Raycast(hrp.Position, hum.MoveDirection.Unit * 4.5, S.rp)
		blocked = wr ~= nil and math.abs(wr.Normal.Y) < 0.6
	end
	if blocked then S.stuckT += dt else S.stuckT = 0 end
	if S.stuckT > 0.9 then
		S.stuckT = 0
		S.stuckCd = os.clock() + 3
		S.noColUntil = os.clock() + 1.2
		hrp.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
		hrp.AssemblyLinearVelocity = Vector3.zero
	end
	local wantCol = (not S.ctrl) and (not S.drone) and os.clock() > S.noColUntil and not S.assembling
	if wantCol ~= S.colOn and not S.ctrl then setArmorCollide(wantCol) end

	-- chu ky di bo
	S.walkW = ease(S.walkW, grounded and math.clamp(sp / 18, 0, 1.15) or 0, 8, dt)
	if grounded then S.phase += dt * sp / 13 * math.pi * 2 end
	S.airW = ease(S.airW, (not grounded and not S.ctrl) and 1 or 0, 9, dt)
	S.upW = ease(S.upW, vel.Y > 2 and 1 or 0, 10, dt)

	local pose = {}
	local function add(k, c) pose[k] = (pose[k] or I) * c end
	local w = math.min(S.walkW, 1.15)
	local ph = S.phase
	local aw, up, lnd = S.airW, S.upW, S.land
	local f, wC, rc = S.flyW, S.wC, S.recoil

	-- ===== DAM TOAN THAN =====
	local armE, tw_, stanceR, stanceL, anyStrike = {}, 0, 0, 0, false
	for i = #S.strikes, 1, -1 do
		local st = S.strikes[i]
		local p = (os.clock() - st.t0) / st.dur
		if p >= 1 then
			table.remove(S.strikes, i)
		elseif p >= 0 then
			anyStrike = true
			local E = strikeCurve(p) * (st.big and 1.12 or 1)
			if (armE[st.arm] or -9) < E then armE[st.arm] = E end
			if p >= 0.42 and not st.hit then
				st.hit = true
				strikeHit(st)
			end
		end
	end
	S.stW = ease(S.stW, anyStrike and 1 or 0, 14, dt)

	local iw = (1 - math.min(w, 1)) * (1 - aw) * (1 - f) * (1 - S.stW) * (1 - wC) * (1 - lnd)
	local fistBoost = {R = 0, L = 0}

	for _, sk in ipairs({"R", "L"}) do
		local E = armE[sk]
		if E then
			local sg = sk == "R" and 1 or -1
			local Ec = math.clamp(E, -0.35, 1.12)
			local pe = math.max(Ec, 0)
			add(sk .. "Shoulder", CFrame.Angles(-0.25 + 1.8 * Ec, 0, -sg * 0.12 * pe))
			add(sk .. "Elbow", CFrame.Angles(math.clamp(0.05 + 1.45 * (1 - Ec), 0.05, 2.1), 0, 0))
			add(sk .. "Wrist", CFrame.Angles(0.5 * (1 - math.clamp(Ec, 0, 1)) - 0.1 * pe, 0, 0))
			tw_ += sg * 0.55 * Ec
			if sk == "R" then stanceR = math.max(stanceR, pe) else stanceL = math.max(stanceL, pe) end
			fistBoost[sk] = 1
		end
	end
	S.twS = ease(S.twS, tw_, 16, dt)
	local rootYaw = 0
	if S.stW > 0.01 then
		local tws = S.twS
		rootYaw = tws * 0.2
		add("Waist", CFrame.Angles(-0.2 * math.max(stanceR, stanceL), tws * 0.8, 0))
		add("Neck", CFrame.Angles(0, -tws * 0.5, 0))
		add("RHip", CFrame.Angles(0.4 * stanceL - 0.2 * stanceR, -rootYaw, 0))
		add("LHip", CFrame.Angles(0.4 * stanceR - 0.2 * stanceL, -rootYaw, 0))
		add("RKnee", CFrame.Angles(-0.45 * stanceL - 0.25 * stanceR, 0, 0))
		add("LKnee", CFrame.Angles(-0.45 * stanceR - 0.25 * stanceL, 0, 0))
		add("RAnkle", CFrame.Angles(0.35 * stanceL + 0.2 * stanceR, 0, 0))
		add("LAnkle", CFrame.Angles(0.35 * stanceR + 0.2 * stanceL, 0, 0))
	end
	local strikeDrop = 0.22 * SC * math.max(stanceR, stanceL)

	-- ===== DI BO / CHAY =====
	if w > 0.02 then
		local amp = 0.6 * (sp > 26 and 1.15 or 1)
		for _, sk in ipairs({"R", "L"}) do
			local sg = sk == "R" and 1 or -1
			local s1, c1 = sg * math.sin(ph), sg * math.cos(ph)
			local hipA = s1 * amp * w
			local knee = -(0.12 + 0.85 * math.max(0, c1)) * w
			add(sk .. "Hip", CFrame.Angles(hipA, 0, sg * 0.1 * w))
			add(sk .. "Knee", CFrame.Angles(knee, 0, 0))
			add(sk .. "Ankle", CFrame.Angles(-(hipA + knee) * 0.7, 0, -sg * 0.1 * w))
			if not armE[sk] then
				add(sk .. "Shoulder", CFrame.Angles(-s1 * 0.5 * w, 0, sg * (0.1 + 0.05 * w)))
				add(sk .. "Elbow", CFrame.Angles((0.3 + 0.25 * math.max(0, -s1)) * w, 0, 0))
			end
		end
		add("Waist", CFrame.Angles(-0.07 * w, math.sin(ph) * 0.14 * w, math.sin(ph) * 0.02 * w))
		add("Neck", CFrame.Angles(0, -math.sin(ph) * 0.1 * w, 0))
		local idx = math.floor(ph / math.pi)
		if idx ~= S.stepIdx then
			S.stepIdx = idx
			if w > 0.5 and grounded then
				shake(0.08 + 0.06 * w, 0.12)
				if w > 0.9 then dustBurst(groundPos() + Vector3.new(0, 0.2, 0), 4, 4, nil, 1) end
			end
		end
	end

	-- ===== DUNG YEN: tu the san sang, nhit tay/chan, thoi nhip tho =====
	if iw > 0.01 then
		local br = math.sin(t * 1.6)
		local sw = math.sin(t * 0.45)
		for _, sk in ipairs({"R", "L"}) do
			local sg = sk == "R" and 1 or -1
			local ph2 = sg * 1.7
			local drift = 0.5 + 0.5 * math.sin(t * 0.8 + ph2)
			add(sk .. "Hip", CFrame.Angles(0.02, 0, (sg * 0.13 + 0.02 * sw) * iw))
			add(sk .. "Knee", CFrame.Angles((-0.09 - 0.02 * br) * iw, 0, 0))
			add(sk .. "Ankle", CFrame.Angles(0.1 * iw, 0, -sg * 0.13 * iw))
			add(sk .. "Shoulder", CFrame.Angles((0.05 + 0.04 * math.sin(t * 0.9 + ph2)) * iw, 0, (sg * (0.24 + 0.08 * drift) + 0.015 * br) * iw))
			add(sk .. "Elbow", CFrame.Angles((0.38 + 0.1 * math.sin(t * 1.1 + ph2)) * iw, 0, 0))
			add(sk .. "Wrist", CFrame.Angles(0.06 * math.sin(t * 1.4 + ph2) * iw, 0, -sg * 0.08 * iw))
		end
		add("Waist", CFrame.Angles(br * 0.02 * iw, math.sin(t * 0.4) * 0.05 * iw, sw * 0.02 * iw))
		add("Neck", CFrame.Angles(0.03 * br * iw, math.sin(t * 0.35) * 0.18 * iw, 0))

		-- su kien nhan roi
		local id = S.idle
		if not id.ev and iw > 0.8 and t >= id.next then
			local kinds = {"flex", "roll", "shift", "look", "stomp"}
			id.ev = {k = kinds[math.random(#kinds)], t0 = t, dur = fr(2, 3.2), side = math.random() < 0.5 and 1 or -1}
		end
		if id.ev then
			local ev = id.ev
			local p = (t - ev.t0) / ev.dur
			if p >= 1 then
				id.ev = nil
				id.next = t + fr(3.5, 7)
			else
				local env = math.sin(p * math.pi) * iw
				local sk = ev.side == 1 and "R" or "L"
				if ev.k == "flex" then
					add(sk .. "Shoulder", CFrame.Angles(1.0 * env, 0, -ev.side * 0.15 * env))
					add(sk .. "Elbow", CFrame.Angles(1.4 * env, 0, 0))
					add(sk .. "Wrist", CFrame.Angles(0.4 * env, 0, 0))
					fistBoost[sk] = env * env
				elseif ev.k == "roll" then
					for _, sk2 in ipairs({"R", "L"}) do
						local sg = sk2 == "R" and 1 or -1
						add(sk2 .. "Shoulder", CFrame.Angles(-0.4 * env * math.sin(p * math.pi * 2), 0, sg * 0.25 * env))
					end
					add("Waist", CFrame.Angles(-0.05 * env, 0, 0))
				elseif ev.k == "shift" then
					add("RHip", CFrame.Angles(0, 0, ev.side * 0.08 * env))
					add("LHip", CFrame.Angles(0, 0, ev.side * 0.08 * env))
					add("Waist", CFrame.Angles(0, 0, -ev.side * 0.06 * env))
				elseif ev.k == "look" then
					add("Neck", CFrame.Angles(0, ev.side * 0.8 * env, 0))
					add("Waist", CFrame.Angles(0, ev.side * 0.15 * env, 0))
				elseif ev.k == "stomp" then
					local ang = p < 0.5 and 0.6 * math.sin(p / 0.5 * math.pi / 2) or 0.6 * (1 - math.clamp((p - 0.5) / 0.12, 0, 1))
					add(sk .. "Hip", CFrame.Angles(ang * iw, 0, 0))
					add(sk .. "Knee", CFrame.Angles(-ang * 1.4 * iw, 0, 0))
					if p >= 0.62 and not ev.done then
						ev.done = true
						shake(0.5, 0.22)
						ringFx(groundPos() + Vector3.new(0, 0.2, 0), 8, Color3.fromRGB(220, 205, 180), 0.4)
						dustBurst(groundPos() + Vector3.new(0, 0.2, 0), 6, 10, nil, 1.2)
					end
				end
			end
		end
	else
		if S.idle.ev and iw < 0.2 then S.idle.ev = nil; S.idle.next = t + 3 end
	end

	-- ===== TREN KHONG =====
	if aw > 0.01 then
		for _, sk in ipairs({"R", "L"}) do
			local sg = sk == "R" and 1 or -1
			add(sk .. "Hip", CFrame.Angles(lerp(0.25, 0.55, up) * aw, 0, sg * 0.18 * aw))
			add(sk .. "Knee", CFrame.Angles(-lerp(0.35, 0.9, up) * aw, 0, 0))
			add(sk .. "Ankle", CFrame.Angles(0.3 * aw, 0, 0))
			if not armE[sk] then
				add(sk .. "Shoulder", CFrame.Angles(-0.2 * aw, 0, sg * 0.55 * aw))
				add(sk .. "Elbow", CFrame.Angles(0.35 * aw, 0, 0))
			end
		end
		add("Waist", CFrame.Angles(-0.05 * aw, 0, 0))
	end

	-- ===== DAP DAT =====
	if lnd > 0.01 then
		for _, sk in ipairs({"R", "L"}) do
			local sg = sk == "R" and 1 or -1
			add(sk .. "Hip", CFrame.Angles(0.5 * lnd, 0, sg * 0.1 * lnd))
			add(sk .. "Knee", CFrame.Angles(-0.9 * lnd, 0, 0))
			add(sk .. "Ankle", CFrame.Angles(0.4 * lnd, 0, 0))
			if not armE[sk] then add(sk .. "Shoulder", CFrame.Angles(0.3 * lnd, 0, sg * 0.2 * lnd)) end
		end
		add("Waist", CFrame.Angles(-0.18 * lnd, 0, 0))
	end

	-- ===== BAY: dau + 2 tay huong ve phia truoc =====
	if f > 0.01 then
		local hov = 1 - S.tiltW
		local tilt = S.tiltW
		for _, sk in ipairs({"R", "L"}) do
			local sg = sk == "R" and 1 or -1
			add(sk .. "Hip", CFrame.Angles((0.25 * hov - 0.05) * f, 0, sg * 0.1 * f))
			add(sk .. "Knee", CFrame.Angles(-(0.15 + 0.35 * hov) * f, 0, 0))
			add(sk .. "Ankle", CFrame.Angles(0.2 * hov * f, 0, 0))
			-- tay duoi thang ve truoc (superman) khi bay nhanh, rong ra khi treo
			add(sk .. "Shoulder", CFrame.Angles((math.pi - 0.25) * tilt * f, 0, sg * (0.2 + 0.25 * hov - 0.1 * tilt) * f))
			add(sk .. "Elbow", CFrame.Angles(0.15 * f * (1 - tilt * 0.6), 0, 0))
			add(sk .. "Wrist", CFrame.Angles(-0.1 * tilt * f, 0, 0))
		end
		add("Neck", CFrame.Angles((math.pi / 2 - 0.12) * tilt * f, 0, 0))
		add("Waist", CFrame.Angles(0.1 * tilt * f, 0, 0))
	end

	-- ===== GONG / TICH LUC =====
	if wC > 0.01 then
		local pulse = math.sin(t * 9) * 0.02
		add("Waist", CFrame.Angles(-0.12 * wC + pulse, 0, 0))
		add("Neck", CFrame.Angles(0.08 * wC, 0, 0))
		for _, sk in ipairs({"R", "L"}) do
			local sg = sk == "R" and 1 or -1
			add(sk .. "Hip", CFrame.Angles(0.45 * wC, 0, sg * 0.32 * wC))
			add(sk .. "Knee", CFrame.Angles(-0.85 * wC, 0, 0))
			add(sk .. "Ankle", CFrame.Angles(0.4 * wC, 0, 0))
			add(sk .. "Shoulder", CFrame.Angles(0, sg * 0.38 * wC, 0) * CFrame.Angles(1.5 * wC, 0, 0))
			add(sk .. "Elbow", CFrame.Angles(0.15 * wC, 0, 0))
		end
	end

	-- ===== GIAT LUC / TEN LUA =====
	if rc > 0.01 then
		add("Waist", CFrame.Angles(0.28 * rc, 0, 0))
		add("RShoulder", CFrame.Angles(0.4 * rc, 0, 0.3 * rc))
		add("LShoulder", CFrame.Angles(0.4 * rc, 0, -0.3 * rc))
	end
	if S.kick > 0.01 then
		add("Waist", CFrame.Angles(0.04 * S.kick, 0, 0))
		add("RShoulder", CFrame.Angles(0.1 * S.kick, 0, 0))
		add("LShoulder", CFrame.Angles(0.1 * S.kick, 0, 0))
	end

	-- ===== DAU NHIN THEO CAMERA =====
	do
		local cam = Workspace.CurrentCamera
		local lookWorld = cam.CFrame.LookVector
		if S.drone and S.phrp and S.phrp.Parent then
			local tv = S.phrp.Position - hrp.Position
			if tv.Magnitude > 0.5 then lookWorld = tv.Unit end
		end
		local lv = hrp.CFrame:VectorToObjectSpace(lookWorld)
		local yaw = math.clamp(math.atan2(-lv.X, -lv.Z), -0.9, 0.9)
		local pit = math.clamp(math.asin(math.clamp(lv.Y, -1, 1)), -0.5, 0.5)
		local lw = (1 - f) * (1 - S.stW * 0.6)
		add("Neck", CFrame.Angles(pit * 0.5 * lw, yaw * 0.7 * lw, 0))
	end

	-- ===== MO MAT TRUOC GIAP (cua ban le that + tay dang ra) =====
	if S.openW > 0.01 then
		local op = S.openW
		for _, sk in ipairs({"R", "L"}) do
			local sg = sk == "R" and 1 or -1
			local aw = 1 - (S.armCloseW or 0)
			add(sk .. "Shoulder", CFrame.Angles(-0.1 * op * aw, 0, sg * (0.8 * op * aw - 0.04 * (1 - aw))))
			add(sk .. "Elbow", CFrame.Angles(0.25 * op * aw, 0, 0))
			local cw = S.legCloseW or 0
			local legA = 0.16 * op * (1 - cw) - 0.13 * cw
			add(sk .. "Hip", CFrame.Angles(0, 0, sg * legA))
			add(sk .. "Ankle", CFrame.Angles(0, 0, -sg * legA))
		end
		add("FDoor", CFrame.Angles(0, 1.95 * op, 0))
		add("Waist", CFrame.Angles(-0.08 * op, 0, 0))
		add("Neck", CFrame.Angles(-0.2 * op, 0, 0))
	end

	-- ===== V10: 2 tay chinh gio cao (ho den) | chan phai dap (cau nano) =====
	NX.upW = ease(NX.upW, NX.upGoal, 7, dt)
	local nxDrop = 0
	if NX.upW > 0.01 then
		local u = NX.upW
		for _, sk in ipairs({"R", "L"}) do
			local sg = sk == "R" and 1 or -1
			pose[sk .. "Shoulder"] = (pose[sk .. "Shoulder"] or I):Lerp(CFrame.Angles(2.85 + math.sin(t * 7) * 0.03, 0, sg * 0.28), u)
			pose[sk .. "Elbow"] = (pose[sk .. "Elbow"] or I):Lerp(CFrame.Angles(0.1, 0, 0), u)
			pose[sk .. "Wrist"] = (pose[sk .. "Wrist"] or I):Lerp(CFrame.Angles(0.15, 0, 0), u)
		end
		pose.Waist = (pose.Waist or I):Lerp(CFrame.Angles(-0.08, 0, 0), u)
	end
	if NX.stompT0 then
		local p = (os.clock() - NX.stompT0) / NX.stompDur
		if p >= 1 then
			NX.stompT0 = nil
		else
			local env = math.clamp(p / 0.12, 0, 1) * (1 - math.clamp((p - 0.88) / 0.12, 0, 1))
			local lift
			if p < 0.5 then lift = math.sin(p / 0.5 * math.pi / 2) else lift = 1 - math.clamp((p - 0.5) / 0.09, 0, 1) end
			local press = (p >= 0.59) and (1 - math.clamp((p - 0.59) / 0.3, 0, 1)) or 0
			if p >= 0.58 and not NX.stompEvt then NX.stompEvt = true end
			local hold = math.max(lift, press)
			pose.RHip = (pose.RHip or I):Lerp(CFrame.Angles(1.2 * lift + 0.25 * press, 0, 0.06), env)
			pose.RKnee = (pose.RKnee or I):Lerp(CFrame.Angles(-1.55 * lift - 0.25 * press, 0, 0), env)
			pose.RAnkle = (pose.RAnkle or I):Lerp(CFrame.Angles(0.5 * lift, 0, 0), env)
			pose.LHip = (pose.LHip or I):Lerp(CFrame.Angles(0.15 * hold, 0, 0), env)
			pose.LKnee = (pose.LKnee or I):Lerp(CFrame.Angles(-0.35 * hold, 0, 0), env)
			pose.RShoulder = (pose.RShoulder or I):Lerp(CFrame.Angles(-0.5 * lift, 0, 0.3 * lift), env)
			pose.LShoulder = (pose.LShoulder or I):Lerp(CFrame.Angles(0.4 * lift, 0, -0.3 * lift), env)
			nxDrop = 0.55 * SC * math.max(press, 0.35 * lift) * env
		end
	end
	NX.dropV = nxDrop

	for _, j in ipairs(S.drive) do j.m.C0 = j.c0 * (pose[j.key] or I) end

	-- ===== NGON TAY: moi ngon mot nhip =====
	for sk, A in pairs(S.arms) do
		local base = 0.95 + 0.4 * math.sin(t * 0.55 + (sk == "R" and 0 or 2))
		base = lerp(base, 0.12, wC)
		base = lerp(base, 0.3, NX.upW)
		base = lerp(base, 1.55, math.max(fistBoost[sk], 0))
		applyFingers(A, base, t, 0.2 * (1 - wC) * (1 - fistBoost[sk] * 0.7))
	end

	-- ===== GOC GIAP =====
	local jit = Vector3.zero
	if S.chargeA > 0 then
		local m = 0.1 * SC * S.chargeA
		jit = Vector3.new(fr(-0.5, 0.5) * m, fr(-0.5, 0.5) * m * 0.5, fr(-0.5, 0.5) * m)
	end
	local sway = math.sin(t * 0.45) * 0.15 * SC * iw
	local bob = -math.abs(math.sin(ph)) * 0.2 * SC * w + math.sin(t * 1.6) * 0.02 * SC * iw
	local drop = 0.8 * SC * wC + 0.45 * SC * lnd + strikeDrop + NX.dropV
	S.rootMotor.C0 = CFrame.new(sway, S.rootY + S.fix - drop + bob, rc * 1.2 * SC) * CFrame.new(jit)
		* CFrame.Angles(0, rootYaw, math.sin(ph) * 0.03 * w + math.sin(t * 0.45) * 0.025 * iw)

	-- ===== DEN / LUA (da giam sang) =====
	if S.parts.CoreLight then S.parts.CoreLight.Brightness = 0.8 + math.sin(t * 3) * 0.2 + 1.8 * wC end
	local burst = os.clock() < S.burstUntil
	for _, fl in ipairs(S.flames) do
		-- thruster hop the: chan phun khi chan da ghep, lung phun khi than da ghep
		local hv = (S.hoverFeet and fl.foot) or (S.hoverBack and not fl.foot)
		local on = flyOn or hv or (burst and fl.foot)
		if fl.e.Enabled ~= on then fl.e.Enabled = on end
		fl.l.Brightness = on and (flyOn and 0.35 * S.thrW or 0.35) or 0
	end

	updateWings(dt, t)
	updateExtras(dt, t, wC, armE)

	-- camera dat ngang dau giap + rung
	local camY = (S.rootY + 2.4) * (1 - f)
	S.camY = ease(S.camY or camY, camY, 9, dt)
	local off = Vector3.new(0, S.camY, 0)
	local sh = S.sh
	local el = os.clock() - sh.t0
	if el < sh.dur then
		local m = sh.mag * (1 - el / sh.dur)
		off += Vector3.new(fr(-1, 1) * m, fr(-1, 1) * m, 0)
	end
	hum.CameraOffset = off
	if S.post then S.post(dt) end
end

------------------------------------------------------------------
-- MAN HINH QUET + ESP
------------------------------------------------------------------
local HUD = {}
local function destroyHUD()
	if HUD.conn then HUD.conn:Disconnect() end
	if HUD.gui then HUD.gui:Destroy() end
	for _, o in pairs(HUD.esp or {}) do
		pcall(function() o.hl:Destroy() end)
		pcall(function() o.bb:Destroy() end)
	end
	HUD = {}
end

local function buildHUD()
	local pg = player:WaitForChild("PlayerGui")
	local gui = Instance.new("ScreenGui")
	gui.Name = "HB_HUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 50
	gui.Parent = pg
	HUD.gui, HUD.esp = gui, {}

	local ov = Instance.new("Frame")
	ov.Size = UDim2.fromScale(1, 1)
	ov.BackgroundColor3 = CFG.ScanColor
	ov.BackgroundTransparency = CFG.ScanOverlayTransparency
	ov.BorderSizePixel = 0
	ov.Parent = gui

	local line = Instance.new("Frame")
	line.Size = UDim2.new(1, 0, 0, 3)
	line.BackgroundColor3 = Color3.fromRGB(120, 230, 255)
	line.BackgroundTransparency = 0.5
	line.BorderSizePixel = 0
	line.Parent = gui
	TweenService:Create(line, TweenInfo.new(2.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {Position = UDim2.fromScale(0, 1)}):Play()

	local function corner(ax, ay)
		for _, horiz in ipairs({true, false}) do
			local fr2 = Instance.new("Frame")
			fr2.BackgroundColor3 = Color3.fromRGB(150, 240, 255)
			fr2.BorderSizePixel = 0
			fr2.Size = horiz and UDim2.new(0, 46, 0, 3) or UDim2.new(0, 3, 0, 46)
			fr2.AnchorPoint = Vector2.new(ax, ay)
			fr2.Position = UDim2.new(ax, ax == 0 and 16 or -16, ay, ay == 0 and 16 or -16)
			fr2.Parent = gui
		end
	end
	corner(0, 0) corner(1, 0) corner(0, 1) corner(1, 1)

	local cross = Instance.new("TextLabel")
	cross.BackgroundTransparency = 1
	cross.AnchorPoint = Vector2.new(0.5, 0.5)
	cross.Position = UDim2.fromScale(0.5, 0.5)
	cross.Size = UDim2.fromOffset(60, 60)
	cross.Text = "[ + ]"
	cross.Font = Enum.Font.Code
	cross.TextSize = 22
	cross.TextColor3 = Color3.fromRGB(160, 240, 255)
	cross.Parent = gui

	local function panel(anchorX)
		local l = Instance.new("TextLabel")
		l.BackgroundColor3 = Color3.fromRGB(0, 30, 60)
		l.BackgroundTransparency = 0.45
		l.BorderSizePixel = 0
		l.AnchorPoint = Vector2.new(anchorX, 0)
		l.Position = UDim2.new(anchorX, anchorX == 0 and 24 or -24, 0, 70)
		l.Size = UDim2.fromOffset(250, 210)
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.TextYAlignment = Enum.TextYAlignment.Top
		l.RichText = true
		l.Font = Enum.Font.Code
		l.TextSize = 14
		l.TextColor3 = Color3.fromRGB(150, 235, 255)
		l.Text = ""
		l.Parent = gui
		return l
	end
	local left, right = panel(0), panel(1)

	local acc = 0
	HUD.conn = RunService.Heartbeat:Connect(function(dt)
		acc += dt
		if acc < 0.1 then return end
		acc = 0
		if not S.on or not S.hrp then return end
		local hrp, hum = S.phrp or S.hrp, S.phum or S.hum
		local spd = S.ctrl and S.fvel.Magnitude or hrp.AssemblyLinearVelocity.Magnitude
		local gp = Workspace:Raycast(hrp.Position, Vector3.new(0, -2000, 0), S.rp)
		local alt = gp and (hrp.Position.Y - gp.Position.Y) or hrp.Position.Y
		local ping = 0
		pcall(function() ping = StatsService.Network.ServerStatsItem["Data Ping"]:GetValue() end)
		local mode = S.nuking and "NUKE" or S.ctrl == "fly" and "FLIGHT" or S.ctrl == "hover" and "HOVER" or (S.ctrl == "land" or S.ctrl == "leap") and "DESCENT" or (S.walkW > 0.3 and "MOVE" or "IDLE")
		left.Text = string.format(
			" <b>H.U.L.K.B.U.S.T.E.R  OS</b>\n ARMOR   : ONLINE\n MODE    : %s\n HP      : %d / %d\n SPEED   : %d st/s\n ALT     : %d st\n GRAVITY : %.0f (80%%)\n FLY MAX : %d\n FPS/PING: %d / %dms",
			mode, math.floor(hum.Health), math.floor(hum.MaxHealth), math.floor(spd), math.floor(alt), Workspace.Gravity, CFG.FlySpeed,
			math.floor(1 / math.max(dt, 0.001)), math.floor(ping))

		local list = {}
		local alive = {}
		for _, pl in ipairs(Players:GetPlayers()) do
			if pl ~= player then
				local ch = pl.Character
				local hd = ch and ch:FindFirstChild("Head")
				local h2 = ch and ch:FindFirstChildOfClass("Humanoid")
				local rt = ch and ch:FindFirstChild("HumanoidRootPart")
				if ch and hd and h2 and rt then
					alive[pl] = true
					local dist = (rt.Position - hrp.Position).Magnitude
					table.insert(list, {pl, dist, h2})
					local rec = HUD.esp[pl]
					if not rec or rec.ch ~= ch then
						if rec then pcall(function() rec.hl:Destroy() rec.bb:Destroy() end) end
						local hl = Instance.new("Highlight")
						hl.Adornee = ch
						hl.FillColor = Color3.fromRGB(0, 190, 255)
						hl.FillTransparency = 0.75
						hl.OutlineColor = Color3.new(1, 1, 1)
						hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						hl.Parent = FX
						local bb = Instance.new("BillboardGui")
						bb.Adornee = hd
						bb.AlwaysOnTop = true
						bb.Size = UDim2.fromOffset(180, 46)
						bb.StudsOffset = Vector3.new(0, 3.2, 0)
						bb.Parent = pg
						local tl = Instance.new("TextLabel")
						tl.Name = "T"
						tl.BackgroundTransparency = 1
						tl.Size = UDim2.fromScale(1, 1)
						tl.Font = Enum.Font.Code
						tl.TextSize = 14
						tl.TextColor3 = Color3.fromRGB(160, 240, 255)
						tl.TextStrokeTransparency = 0.4
						tl.RichText = true
						tl.Parent = bb
						rec = {hl = hl, bb = bb, ch = ch}
						HUD.esp[pl] = rec
					end
					rec.bb.T.Text = string.format("<b>%s</b> (@%s)\nHP %d | %d st", pl.DisplayName, pl.Name, math.floor(h2.Health), math.floor(dist))
				end
			end
		end
		for pl, rec in pairs(HUD.esp) do
			if not alive[pl] then
				pcall(function() rec.hl:Destroy() rec.bb:Destroy() end)
				HUD.esp[pl] = nil
			end
		end
		table.sort(list, function(a, b) return a[2] < b[2] end)
		local lines = {" <b>TARGETS IN SERVER</b> (" .. #list .. ")"}
		for i = 1, math.min(8, #list) do
			lines[#lines + 1] = string.format(" %-14s %4dst  HP %d", list[i][1].DisplayName:sub(1, 14), math.floor(list[i][2]), math.floor(list[i][3].Health))
		end
		right.Text = table.concat(lines, "\n")
	end)
end

local function toggleScan()
	if S.drone then return end
	if HUD.gui then destroyHUD() else buildHUD() end
end

------------------------------------------------------------------
-- BIEN HINH NANO
------------------------------------------------------------------
local function hideChar()
	for _, d in ipairs(S.char:GetDescendants()) do
		if (d:IsA("BasePart") or d:IsA("Decal")) and d.Name ~= "HumanoidRootPart" and not d:IsDescendantOf(S.armor) then
			if S.hidden[d] == nil then S.hidden[d] = d.Transparency end
			d.Transparency = 1
		end
	end
end

-- khop chinh cua giap (goc + cac khop trong S.drive), sap theo do sau cay cha-con
local function mainJoints()
	local list, byPart, allJ = {}, {}, {}
	for _, d in ipairs(S.armor:GetDescendants()) do
		if d:IsA("Motor6D") and d.Part1 then allJ[d.Part1] = d end
	end
	local function reg(m)
		if not (m and m.Part1 and m.Part1.Parent) then return end
		local e = {m = m, part = m.Part1}
		table.insert(list, e)
		byPart[m.Part1] = e
	end
	reg(S.rootMotor)
	for _, j in ipairs(S.drive) do reg(j.m) end
	for _, e in ipairs(list) do
		local q = e.m.Part0
		local guard = 0
		while q and guard < 60 do
			if byPart[q] then
				e.parent = byPart[q]
				break
			end
			local mj = allJ[q]
			q = mj and mj.Part0 or nil
			guard += 1
		end
	end
	for _, e in ipairs(list) do
		local dp, q = 0, e.parent
		while q do
			dp += 1
			q = q.parent
		end
		e.depth = dp
	end
	table.sort(list, function(a, b) return a.depth < b.depth end)
	return list, byPart, allJ
end

local function addTrail(part, color)
	local sz = part.Size
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, sz.Y / 2, 0)
	a0.Parent = part
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -sz.Y / 2, 0)
	a1.Parent = part
	local tr = Instance.new("Trail")
	tr.Attachment0, tr.Attachment1 = a0, a1
	tr.Lifetime = 0.35
	tr.LightEmission = 0.4
	tr.Color = ColorSequence.new(color)
	tr.Transparency = NumberSequence.new(0.4, 1)
	tr.Parent = part
	return {a0, a1, tr}
end

local function destroyAll(list)
	for _, t in ipairs(list) do
		for _, o in ipairs(t) do pcall(function() o:Destroy() end) end
	end
end

-- MAC GIAP (Tool 1): nguoi van dung duoi dat. Ban chan giap bay lai -> ong chan nang nguoi len ->
-- lung -> 2 ben hong -> bung -> dua nguoi vao dung vi tri -> than, tay, dau, cua truoc dong lai -> ha xuong dat
local function assemble()
	local my = S
	local hrp, hum = S.hrp, S.hum
	-- V10.13: tuy chon mac nhanh tren khong (tu cuu): k = he so thoi gian, air = khong ha xuong dat, vao thang che do bay
	local Q = NX.asmOpts
	NX.asmOpts = nil
	local K = Q and Q.k or 1
	local AIR = Q and Q.air or false
	local DM = Q and Q.distMul or 1
	local list, rec = {}, {}
	for _, d in ipairs(S.armor:GetDescendants()) do
		if d:IsA("BasePart") then
			table.insert(list, d)
			rec[d] = {c = d.Color, m = d.Material, r = d.Reflectance, t = d.Transparency}
			d.Transparency = 1
		end
	end
	if S.parts.CoreLight then S.parts.CoreLight.Enabled = false end
	task.wait(AIR and 0.03 or 0.15)
	if S ~= my or not S.on then return end

	-- huong / do cao
	local look = hrp.CFrame.LookVector
	local fwd = Vector3.new(look.X, 0, look.Z)
	fwd = fwd.Magnitude > 0.01 and fwd.Unit or Vector3.new(0, 0, -1)
	local right = fwd:Cross(Vector3.yAxis)
	local up = Vector3.yAxis
	local gres = Workspace:Raycast(hrp.Position + Vector3.new(0, 3, 0), Vector3.new(0, -200, 0), S.rp)
	local gy = gres and gres.Position.Y or (hrp.Position.Y - 3)
	local standY = gy + LB
	local hoverTop = standY + CFG.HoverRise
	local y0 = hrp.Position.Y
	local function lift(r) S.hoverGoal = y0 + (standY - y0) * r end

	-- nguoi choi dung yen tai chỗ, che do lo lung (thruster se nang len)
	beginAirControl()
	S.frot = CFrame.lookAt(Vector3.zero, fwd)
	S.fvel = Vector3.zero
	S.hoverXZ = hrp.Position
	S.hoverY = y0
	S.hoverGoal = y0
	S.hoverGy = gy
	S.hoverRate = 6
	S.hoverFeet, S.hoverBack = false, false
	S.ctrl = "hover"
	S.openGoal = 1 -- cua truoc mo san de nguoi o trong khoang
	S.legClose = true -- 2 chan giap khep lai de chan nguoi khong lo ra ngoai
	S.armClose = true -- 2 tay giap khep lai de tay nguoi khong lo ra ngoai

	local joints, byPart = mainJoints()
	local pel = S.parts.Pelvis
	local trails = {}

	-- ke hoach bay: delay, thoi gian, huong xuat phat, khoang cach, co xoay khong
	local function planFor(name)
		local sd = right * (name:sub(-1) == "R" and 1 or -1)
		if name:find("^B_Foot") then return 0.25, 0.70, sd * 0.7 + fwd * 0.7 + up * 0.15, 60, true
		elseif name:find("^B_Shin") then return 1.15, 0.55, sd * 0.8 + fwd * 0.4 + up * 0.3, 55, false
		elseif name:find("^B_Thigh") then return 1.55, 0.55, sd * 0.8 - fwd * 0.3 + up * 0.5, 55, false
		elseif name == "B_Pelvis" then return 2.00, 0.60, -fwd * 0.9 + up * 0.4, 60, false -- lung
		elseif name == "B_Torso" then return 3.10, 0.65, -fwd * 0.6 + up * 0.9, 70, false
		elseif name:find("^B_UArm") then return 3.40, 0.55, sd + up * 0.8, 60, false
		elseif name:find("^B_FArm") then return 3.55, 0.55, sd + up * 0.6 + fwd * 0.3, 60, false
		elseif name:find("^B_Hand") then return 3.70, 0.55, sd + fwd * 0.5 + up * 0.4, 60, true
		elseif name == "B_Head" then return 3.90, 0.55, up + fwd * 0.2, 70, true
		elseif name == "B_FDoor" then return 4.10, 0.50, fwd * 0.9 + up * 0.4, 55, true
		end
		return 4.0, 0.55, up, 60, false
	end

	for _, e in ipairs(joints) do
		local dl, du, dir, dist, spin = planFor(e.part.Name)
		e.delay, e.dur, e.dir, e.dist = (dl + fr(0, 0.08)) * K, du * K, dir.Unit, dist * DM
		e.spin = spin and Vector3.new(fr(-3, 3), fr(-3, 3), fr(-3, 3)) or nil
		e.D = Vector3.zero
		e.group = {}
		e.started, e.done = false, false
	end

	-- cac chi tiet cua chau bay rieng: lung (cung chau) -> 2 hong -> bung
	local HIPS = {B_HipP = true, B_HipPR = true, B_HipBall = true}
	local BELLY = {B_Belt = true, B_BeltLow = true, B_Buckle = true, B_BuckleC = true, B_Fauld = true, B_FauldT = true, B_Cod = true, B_Rv = true}
	local subs, subOf = {}, {}
	local stageLeft = {hips = 0, belly = 0}
	if pel then
		for _, p in ipairs(list) do
			if S.owner[p] == pel then
				local stage = HIPS[p.Name] and "hips" or BELLY[p.Name] and "belly" or nil
				local w = p:FindFirstChildOfClass("Weld")
				if stage and w and w.Part0 == pel then
					local sd = w.C0.X >= 0 and 1 or -1
					local s = {p = p, w = w, w0 = w.C0, stage = stage, t = rec[p].t, started = false, done = false}
					if stage == "hips" then
						s.delay = ((sd == 1 and 2.45 or 2.6) + fr(0, 0.1)) * K
						s.dur = 0.5 * K
						s.dir = (right * sd + up * 0.2).Unit
						s.dist = 45
					else
						s.delay = (2.8 + fr(0, 0.15)) * K
						s.dur = 0.5 * K
						s.dir = (fwd + up * 0.3).Unit
						s.dist = 45
					end
					stageLeft[stage] += 1
					table.insert(subs, s)
					subOf[p] = s
				end
			end
		end
	end

	-- gan moi manh cho cum khop cua no
	local function resolveE(p)
		local q, guard = p, 0
		while q and guard < 80 do
			if byPart[q] then return byPart[q] end
			local o = S.owner[q]
			if o and o ~= q then
				q = o
			else
				local j = q:FindFirstChildWhichIsA("JointInstance")
				q = j and j.Part0 or nil
			end
			guard += 1
		end
		return byPart[pel] or joints[1]
	end
	for _, p in ipairs(list) do
		if not subOf[p] then table.insert(resolveE(p).group, p) end
	end

	local function reveal(p)
		if not p.Parent then return end
		local t = rec[p].t
		if p == S.parts.Torso and S.cavity then t = 1 end
		p.Transparency = t
	end

	-- hieu ung mo dau: vong nang luong duoi chan
	local center = hrp.Position
	local gp = Vector3.new(center.X, gy + 0.3, center.Z)
	ringFx(gp, 22, COL.Glow, 0.8)
	ringFx(gp, 12, COL.Gold, 0.6)
	playSound("rbxasset://sounds/electronicpingshort.wav", 0.6, 0.6)

	local t0 = os.clock()
	local hold = 1
	local finished = false

	local function onStart(e)
		e.started = true
		for _, p in ipairs(e.group) do reveal(p) end
		table.insert(trails, addTrail(e.part, (e.depth % 2 == 0) and COL.Glow or COL.Gold))
		if e.part.Name == "B_Torso" then S.hoverBack = true end
	end
	local function onArrive(e)
		e.done = true
		local nm = e.part.Name
		sparks(e.part.Position, 8, COL.Glow, 6, 0.4)
		if nm:find("^B_Foot") then
			if not S.hoverFeet then
				S.hoverFeet = true
				playSound(SND_ROCKET, 0.35, 0.7)
			end
			sparks(e.part.Position - Vector3.new(0, 0.5, 0), 10, COL.Gold, 6, 0.4)
		elseif nm:find("^B_Shin") then shake(0.3, 0.2)
		end
	end
	local stageDone = {
		hips = function() end,
		belly = function() shake(0.5, 0.3) end,
	}

	S.post = function()
		local el = os.clock() - t0
		local V = (hold > 0 and not AIR) and Vector3.new(0, standY - S.hrp.Position.Y, 0) or Vector3.zero
		local all = true
		local legSum, legN = 0, 0
		for _, e in ipairs(joints) do
			local u = math.clamp((el - e.delay) / e.dur, 0, 1)
			if e.part.Name:find("^B_Shin") or e.part.Name:find("^B_Thigh") then
				legSum += u * u * (3 - 2 * u)
				legN += 1
			end
			local rem = (1 - u) ^ 3
			e.D = e.dir * e.dist * rem + V
			local own = e.D - (e.parent and e.parent.D or Vector3.zero)
			local p0 = e.m.Part0
			if p0 and (own.Magnitude > 1e-3 or rem > 1e-3) then
				local c0 = CFrame.new(p0.CFrame:VectorToObjectSpace(own)) * e.m.C0
				if e.spin then
					local sp = e.spin * rem
					c0 = c0 * CFrame.Angles(sp.X, sp.Y, sp.Z)
				end
				e.m.C0 = c0
			end
			if u > 0 and not e.started then onStart(e) end
			if u >= 1 then
				if not e.done then onArrive(e) end
			else
				all = false
			end
		end
		-- nguoi chi duoc nang len theo dung tien do ong chan + dui bay vao (khong len truoc)
		if hold > 0 and legN > 0 and not AIR then
			S.hoverRate = 12
			lift(legSum / legN)
		end
		for _, s in ipairs(subs) do
			local u = math.clamp((el - s.delay) / s.dur, 0, 1)
			if u > 0 and not s.started then
				s.started = true
				reveal(s.p)
			end
			if u >= 1 then
				if not s.done then
					s.done = true
					s.w.C0 = s.w0
					stageLeft[s.stage] -= 1
					if stageLeft[s.stage] == 0 then stageDone[s.stage]() end
				end
			else
				all = false
				if s.started and pel then
					local off = s.dir * s.dist * (1 - u) ^ 3
					s.w.C0 = CFrame.new(pel.CFrame:VectorToObjectSpace(off)) * s.w0
				end
			end
		end
		if all then finished = true end
	end

	-- cho tat ca bo phan ghep xong
	local w0 = os.clock()
	while not finished and S == my and S.on and os.clock() - w0 < 10 do task.wait(0.03) end
	if S ~= my or not S.on then return end

	-- nguoi da o dung vi tri trong giap -> ca bo giap bay len lo lung
	local w1 = os.clock()
	while S == my and S.on and not AIR and math.abs(S.hoverY - standY) > 0.12 and os.clock() - w1 < 2 do task.wait(0.03) end
	if S ~= my or not S.on then return end
	hold = 0
	if not AIR then
		S.hoverBack = true
		S.hoverGoal = hoverTop
		S.hoverRate = 2.4
	end
	local w1b = os.clock()
	while S == my and S.on and not AIR and (hoverTop - S.hoverY) > 0.15 and os.clock() - w1b < 2 do task.wait(0.03) end
	if S ~= my or not S.on then return end
	S.post = nil
	destroyAll(trails)

	-- khop xong: loe sang, cua truoc dong lai tren nguoi chu
	local cp = S.hrp.Position
	local fl = fxPart("Flash", Vector3.one * 3, COL.White, NEON, BALL)
	fl.CFrame = CFrame.new(cp)
	fl.Transparency = 0.3
	tw(fl, 0.45, {Size = Vector3.one * 18, Transparency = 1})
	Debris:AddItem(fl, 0.5)
	sparks(cp, 40, COL.Glow, 14, 0.8)
	sparks(cp, 24, COL.Gold, 12, 0.7)
	shake(0.9, 0.45)
	task.wait(AIR and 0.05 or 0.4)
	if S ~= my or not S.on then return end
	S.openGoal = 0
	S.legClose, S.armClose = false, false
	local hid = false
	local w2 = os.clock()
	while S == my and S.on and S.openW > 0.04 and os.clock() - w2 < 2 do
		if not hid and S.openW < 0.4 then
			hid = true
			hideChar()
		end
		if AIR and hid then break end
		task.wait(0.03)
	end
	if S ~= my or not S.on then return end
	if not hid then hideChar() end
	if S.parts.CoreLight then S.parts.CoreLight.Enabled = true end
	ringFx(Vector3.new(cp.X, gy + 0.3, cp.Z), 22, COL.Glow, 0.7)
	if AIR then
		-- V10.13: tu cuu tren khong -> vao thang che do bay, khong ha xuong dat
		hum.HipHeight = S.rig15 and math.max(0, LB - hrp.Size.Y / 2) or math.max(0, LB - 3)
		S.hoverFeet, S.hoverBack = false, false
		S.fvel = Vector3.zero
		S.ctrl = "fly"
		S.stomp = false
		S.flying = true
		buildWings()
		shake(0.8, 0.4)
		return
	end

	-- thruster giam luc dan, ha nhe xuong mat dat
	S.hoverGoal = standY
	S.hoverRate = 3.0
	local w3 = os.clock()
	while S == my and S.on and (S.hoverY - standY) > 0.25 and os.clock() - w3 < 3 do task.wait(0.03) end
	if S ~= my or not S.on then return end
	S.hoverFeet, S.hoverBack = false, false
	S.hoverGoal = standY
	S.hoverY = standY
	S.leapPeak = hoverTop
	S.stomp = true
	hum.HipHeight = S.rig15 and math.max(0, LB - hrp.Size.Y / 2) or math.max(0, LB - 3)
	S.noColUntil = os.clock() + 1.0
	releaseControl()
	task.wait(0.4)
end

-- TACH GIAP: moi cum bo phan + manh nano bay tan vao vu tru
local function disperseArmor(old)
	local armor = old.armor
	if not armor then return end
	local parts, joints = {}, {}
	for _, d in ipairs(armor:GetDescendants()) do
		if d:IsA("BasePart") then
			table.insert(parts, d)
		elseif d:IsA("Motor6D") or d:IsA("Weld") then
			table.insert(joints, d)
		elseif d:IsA("ParticleEmitter") then
			d.Enabled = false
		elseif d:IsA("PointLight") then
			d.Enabled = false
		end
	end
	if #parts == 0 then
		armor:Destroy()
		return
	end
	local cfs = {}
	local center = Vector3.zero
	for _, p in ipairs(parts) do
		cfs[p] = p.CFrame
		center += p.Position
	end
	center /= #parts
	for _, j in ipairs(joints) do pcall(function() j:Destroy() end) end
	armor.Parent = FX

	local owner = old.owner or {}
	local clusters, pieces = {}, {}
	for _, p in ipairs(parts) do
		local o = owner[p] or p
		if not cfs[o] then o = p end
		local c = clusters[o]
		if not c then
			local away = cfs[o].Position - center
			local dir = away.Magnitude > 0.5 and away.Unit or Vector3.yAxis
			dir = (dir + Vector3.new(fr(-0.5, 0.5), fr(0.35, 1.0), fr(-0.5, 0.5))).Unit
			c = {dir = dir, speed = fr(60, 150), spin = Vector3.new(fr(-2, 2), fr(-2, 2), fr(-2, 2)), cf0 = cfs[o]}
			clusters[o] = c
		end
		p.Anchored = true
		p.CanCollide = false
		table.insert(pieces, {p = p, c = c, rel = c.cf0:ToObjectSpace(cfs[p]), tr0 = p.Transparency})
	end

	-- (da bo hieu ung manh nano bay ra)
	local nanos = {}
	playSound("rbxasset://sounds/electronicpingshort.wav", 0.5, 0.45)

	local t0 = os.clock()
	local DUR = 2.6
	local conn
	conn = RunService.Heartbeat:Connect(function()
		local el = os.clock() - t0
		if el >= DUR then
			conn:Disconnect()
			for _, n in ipairs(nanos) do pcall(function() n.p:Destroy() end) end
			pcall(function() armor:Destroy() end)
			return
		end
		for _, c in pairs(clusters) do
			local mv = c.dir * c.speed * el * (1 + el * 1.2)
			local rot = CFrame.Angles(c.spin.X * el, c.spin.Y * el, c.spin.Z * el)
			c.cur = CFrame.new(c.cf0.Position + mv) * rot * c.cf0.Rotation
		end
		local ps, cs = {}, {}
		for i, pc in ipairs(pieces) do
			ps[i] = pc.p
			cs[i] = pc.c.cur * pc.rel
		end
		local ok = pcall(function() Workspace:BulkMoveTo(ps, cs, Enum.BulkMoveMode.FireCFrameChanged) end)
		if not ok then
			for i, p in ipairs(ps) do pcall(function() p.CFrame = cs[i] end) end
		end
		local u = el / DUR
		if u > 0.65 then
			local f = (u - 0.65) / 0.35
			for _, pc in ipairs(pieces) do pc.p.Transparency = lerp(pc.tr0, 1, f) end
		end
		for _, n in ipairs(nanos) do
			local te = math.max(0, el - n.d)
			local pos = n.s + n.dir * n.speed * te * (1 + te)
			n.p.CFrame = CFrame.lookAt(pos, pos + n.dir)
			n.p.Transparency = math.clamp((el - 1.4) / 1.2, 0, 1)
		end
	end)
end

------------------------------------------------------------------
-- MAC / THAO
------------------------------------------------------------------
local unwear
local UPDATE_NAME = "HB_Update"
local SPEED_LOCK_NAME = "HB_SpeedLock"

-- Giữ tốc độ chạy của nhân vật khi đang mặc giáp.
-- Một số game/giáp có thể liên tục ghi đè Humanoid.WalkSpeed;
-- vì vậy tốc độ được áp lại ở mỗi frame khi đang đi bộ.
local function lockArmorWalkSpeed()
	if not S.on or S.assembling or S.ctrl or S.drone then return end
	local hum = S.phum or S.hum
	if not hum or not hum.Parent then return end

	local base = (S.orig and S.orig.Walk) or 16
	local target = base * CFG.WalkMult

	if hum.WalkSpeed ~= target then
		hum.WalkSpeed = target
	end
end

local function wear()
	if S.on then return end
	local char, hrp, hum = getChar()
	if not char then return end
	S.char, S.hrp, S.hum = char, hrp, hum
	S.phrp, S.phum = hrp, hum
	S.rig15 = hum.RigType == Enum.HumanoidRigType.R15
	S.orig = {
		Walk = (hum.WalkSpeed >= 8) and hum.WalkSpeed or 16, Jump = hum.JumpPower, UseJP = hum.UseJumpPower, Hip = hum.HipHeight,
		Zoom = player.CameraMaxZoomDistance, ZoomMin = player.CameraMinZoomDistance,
		Grav = Workspace.Gravity, AutoRot = true, -- khong luu AutoRotate cu (co the dang false do shift-lock/game) => tranh bi ket 1 huong
	}
	S.rp = rayParams()
	S.on = true
	S.assembling = true
	local my = S

	local ok, err = pcall(buildArmor)
	if not ok then
		warn("[Hulkbuster] Loi xay giap:", err)
		unwear()
		return
	end

	pcall(tone, S.armor)
	hum.UseJumpPower = true
	hum.WalkSpeed = 0
	hum.JumpPower = 0
	Workspace.Gravity = S.orig.Grav * CFG.GravityMult
	player.CameraMaxZoomDistance = math.max(S.orig.Zoom, 100)
	player.CameraMinZoomDistance = math.max(S.orig.ZoomMin, 16)

	RunService:BindToRenderStep(UPDATE_NAME, Enum.RenderPriority.Camera.Value + 1, update)
	RunService:BindToRenderStep(SPEED_LOCK_NAME, Enum.RenderPriority.Character.Value + 1, lockArmorWalkSpeed)
	table.insert(S.conns, RunService.Stepped:Connect(function()
		if not S.on or not S.ctrl then return end
		pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
		hum.PlatformStand = true
		hum.AutoRotate = false
		if S.ccSaved then
			for p in pairs(S.ccSaved) do if p.Parent then p.CanCollide = false p.CanTouch = false end end
		end
		-- xoa van toc truoc moi buoc vat ly (trong luc khong tich luy => khong co "toc do va cham")
		if S.hrp and S.hrp.Parent then
			S.hrp.AssemblyLinearVelocity = Vector3.zero
			S.hrp.AssemblyAngularVelocity = Vector3.zero
		end
	end))
	table.insert(S.conns, hum.StateChanged:Connect(function(_, new)
		if not S.on or S.ctrl or S.drone or S.assembling or S.busy then return end
		if new == Enum.HumanoidStateType.Landed then
			local power = math.clamp(-S.lastVy / 55, 0, 1)
			S.lastVy = 0
			S.land = math.max(S.land, 0.4 + 0.6 * power)
			S.noColUntil = os.clock() + 0.35
			slamFx(power)
		elseif new == Enum.HumanoidStateType.Jumping then
			startLeap()
		end
	end))
	table.insert(S.conns, hum.Died:Connect(function() task.defer(unwear) end))

	local okA, errA = pcall(assemble)
	if not okA then
		warn("[Hulkbuster] Loi mac giap:", errA)
		if S == my then unwear() end
		return
	end
	if S ~= my or not S.on then return end

	S.assembling = false
	hum.WalkSpeed = S.orig.Walk * CFG.WalkMult
	hum.JumpPower = S.orig.Jump * CFG.JumpMult
	if S.parts.CoreLight then S.parts.CoreLight.Enabled = true end
	print("[Hulkbuster V9] Da bien hinh")
end

unwear = function(keepRealm)
	-- V10.13c: thao giap bang Tool 1 luc giap dang nan ho den -> tach ho den ra de 2 canh tay nang len va nem di
	local throw = nil
	if keepRealm and S.on and S.armor then
		local hh = S.phum or S.hum
		if hh and hh.Health > 0 then
			local okT, T = pcall(NX.prepThrow, S)
			if okT then throw = T end
		end
	end
	-- V10.13b: thao giap trong khong gian ky ao (Tool 1 x2) -> giu nguyen khong gian, chi don cac chieu gan voi giap
	local keep = keepRealm and NX.realm and not NX.exiting
	if keep then
		local hh = S.phum or S.hum
		if not (hh and hh.Parent and hh.Health > 0) then keep = false end
	end
	if keep then
		pcall(NX.cleanupKeepRealm)
	else
		pcall(NX.cleanup, false)
	end
	local old = S
	if not old.on and not old.armor then return end
	old.on = false
	old.nuking = false
	pcall(function() RunService:UnbindFromRenderStep(UPDATE_NAME) end)
	pcall(function() RunService:UnbindFromRenderStep(SPEED_LOCK_NAME) end)
	for _, c in ipairs(old.conns) do pcall(function() c:Disconnect() end) end
	pcall(function()
		if old.ctSaved then
			for p, v in pairs(old.ctSaved) do if p.Parent then p.CanTouch = v end end
		end
		if old.ccSaved then
			for p, v in pairs(old.ccSaved) do if p.Parent then p.CanCollide = v end end
		end
		if old.hum and old.hum.Parent then
			old.hum.PlatformStand = false
			old.hum.CameraOffset = Vector3.zero
			if old.orig then
				old.hum.UseJumpPower = old.orig.UseJP
				old.hum.WalkSpeed = old.orig.Walk
				old.hum.JumpPower = old.orig.Jump
				old.hum.HipHeight = old.orig.Hip
				old.hum.AutoRotate = true
			end
			if old.ctrl and old.hrp then
				old.hrp.AssemblyLinearVelocity = Vector3.zero
				pcall(function() old.hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
			end
		end
		for d, tr in pairs(old.hidden) do if d.Parent then d.Transparency = tr end end
		if old.armor and old.hrp then
			local cp = old.hrp.Position
			sparks(cp, 40, COL.Glow, 16, 0.9)
			ringFx(cp - Vector3.new(0, 3, 0), 20, COL.Glow, 0.8)
		end
		if old.armor then
			if throw then pcall(NX.takeArms, throw, old) end
			local okd = pcall(disperseArmor, old)
			if not okd then pcall(function() old.armor:Destroy() end) end
		end
		if old.orig then
			player.CameraMaxZoomDistance = old.orig.Zoom
			player.CameraMinZoomDistance = old.orig.ZoomMin
			Workspace.Gravity = old.orig.Grav
		end
	end)
	destroyHUD()
	if throw then task.spawn(NX.runThrow, throw) end
	S = newState()
end

------------------------------------------------------------------
-- RA / VAO GIAP (Tool 2 bam 3 lan)
------------------------------------------------------------------
local function restorePlayerStats(hum)
	local o = S.orig
	hum.UseJumpPower = o.UseJP
	hum.WalkSpeed = o.Walk
	hum.JumpPower = o.Jump
	hum.HipHeight = o.Hip
	hum.AutoRotate = true
	hum.PlatformStand = false
	hum.CameraOffset = Vector3.zero
	task.delay(0.2, function() if hum.Parent and not S.ctrl then hum.AutoRotate = true end end)
	player.CameraMaxZoomDistance = o.Zoom
	player.CameraMinZoomDistance = o.ZoomMin
	Workspace.Gravity = o.Grav
end

local function applyArmorStats(hum, hrp)
	local o = S.orig
	hum.UseJumpPower = true
	hum.WalkSpeed = o.Walk * CFG.WalkMult
	hum.JumpPower = o.Jump * CFG.JumpMult
	hum.HipHeight = S.rig15 and math.max(0, LB - hrp.Size.Y / 2) or math.max(0, LB - 3)
	Workspace.Gravity = o.Grav * CFG.GravityMult
	player.CameraMaxZoomDistance = math.max(o.Zoom, 100)
	player.CameraMinZoomDistance = math.max(o.ZoomMin, 16)
end

-- NHAN VAT RA KHOI GIAP: mat truoc giap mo that, nhan vat hien ra trong khoang roi buoc ra, cua dong lai
local function exitArmor()
	if not S.on or S.drone or S.busy or S.assembling or S.nuking then return end
	local my = S
	S.busy = true
	if S.ctrl == "fly" then stopFly() end
	local w0 = os.clock()
	while S == my and S.on and S.ctrl and os.clock() - w0 < 6 do task.wait(0.05) end
	if S ~= my or not S.on then return end
	S.strikes = {}
	dismissExtras()
	if S.wings then S.wings.target = 0 end
	local phrp, phum = S.phrp, S.phum

	-- ra khoi giap: tu dong tat man hinh quet + ESP
	if HUD.gui then destroyHUD() end

	-- 1) cua truoc mo that (ban le ben trai), than giap trong suot de lo khoang trong
	S.openGoal = 1
	playSound("rbxasset://sounds/electronicpingshort.wav", 0.5, 0.7)
	local w1 = os.clock()
	while S == my and S.on and S.openW < 0.9 and os.clock() - w1 < 2 do task.wait(0.03) end
	if S ~= my or not S.on then return end

	-- 2) giap tach khoi nhan vat: vo giap (shell) lam goc moi cho bo khung
	local armorCF = phrp.CFrame
	local shell = Instance.new("Part")
	shell.Name = "HB_Shell"
	shell.Size = Vector3.new(2, 2, 1)
	shell.Transparency = 1
	shell.Anchored = true
	shell.CanCollide = false
	shell.CanQuery = false
	shell.CanTouch = false
	shell.Massless = true
	shell.CFrame = armorCF
	shell.Parent = S.armor
	S.shell = shell
	S.rootMotor.Part0 = shell
	local fake = {
		MoveDirection = Vector3.zero, FloorMaterial = Enum.Material.Plastic, HipHeight = 0, CameraOffset = Vector3.zero,
		Health = phum.MaxHealth, MaxHealth = phum.MaxHealth, WalkSpeed = 40, JumpPower = 0,
	}
	S.hrp, S.hum = shell, fake
	S.fpos = armorCF.Position
	S.frot = armorCF.Rotation
	S.dvel = Vector3.zero
	S.olast = nil
	S.dmode, S.dlast, S.dforce, S.dflyUntil = "walk", "walk", nil, 0
	S.dhold = true
	S.drone = true
	setArmorCollide(false)

	-- 3) nhan vat hien ra trong khoang giap, roi buoc ra phia truoc
	for d, tr in pairs(S.hidden) do
		if d.Parent then d.Transparency = tr end
	end
	S.hidden = {}
	restorePlayerStats(phum)
	local look = armorCF.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	flat = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, -1)
	local inPos = armorCF.Position + Vector3.new(0, 1.2, 0) + flat * 0.3
	local inCF = CFrame.lookAt(inPos, inPos + flat)
	local hold = RunService.Heartbeat:Connect(function()
		phrp.CFrame = inCF
		phrp.AssemblyLinearVelocity = Vector3.zero
		phrp.AssemblyAngularVelocity = Vector3.zero
	end)
	task.wait(0.5)
	hold:Disconnect()
	if S ~= my or not S.on then return end
	phrp.AssemblyLinearVelocity = flat * 15 + Vector3.new(0, 10, 0)

	-- 4) doi nhan vat ra khoi khoang roi cua dong lai
	local w3 = os.clock()
	while S == my and S.on and os.clock() - w3 < 1.2 do
		local dd = Vector3.new(phrp.Position.X - armorCF.Position.X, 0, phrp.Position.Z - armorCF.Position.Z).Magnitude
		if dd > 4.5 then break end
		task.wait(0.05)
	end
	S.openGoal = 0
	local w4 = os.clock()
	while S == my and S.on and S.openW > 0.05 and os.clock() - w4 < 1.5 do task.wait(0.03) end
	if S ~= my or not S.on then return end
	S.dhold = false
	S.busy = false
end

-- HOP THE: giap bay lai, chan + thruster ghep truoc va nang nguoi len lo lung,
-- cac bo phan con lai bay vao DUNG vi tri, cua truoc dong lai, ha xuong mat dat
local ENTER_ORDER = {
	B_FootR = 0.15, B_FootL = 0.15, B_ShinR = 0.35, B_ShinL = 0.35, B_ThighR = 0.5, B_ThighL = 0.5,
	B_Pelvis = 0.65, B_Torso = 0.8, B_UArmR = 1.0, B_UArmL = 1.0, B_FArmR = 1.1, B_FArmL = 1.1,
	B_HandR = 1.2, B_HandL = 1.2, B_Head = 1.3, B_FDoor = 1.4,
}

local function enterArmor()
	if not S.on or not S.drone or S.busy or S.nuking then return end
	local my = S
	local owner, phum = S.phrp, S.phum
	if not (owner and owner.Parent) then return end
	S.busy = true
	S.strikes = {}
	dismissExtras()

	-- 1) giap tien lai gan chu
	S.denter = true
	S.dhold = false
	local w0 = os.clock()
	while S == my and S.on and os.clock() - w0 < 4 do
		if (S.hrp.Position - owner.Position).Magnitude < 9 then break end
		task.wait(0.05)
	end
	if S ~= my or not S.on then return end
	if (S.hrp.Position - owner.Position).Magnitude > 12 then
		local l = owner.CFrame.LookVector
		l = Vector3.new(l.X, 0, l.Z)
		l = l.Magnitude > 0.01 and l.Unit or Vector3.new(0, 0, -1)
		S.fpos = Vector3.new(owner.Position.X, S.fpos.Y, owner.Position.Z) + l * 6
	end
	S.dhold = true
	S.denter = false
	S.dfaceOwner = true
	if S.wings then S.wings.target = 0 end
	task.wait(0.45)
	if S ~= my or not S.on then return end

	-- 2) du lieu: vi tri giap luc dung yen, mat dat duoi chan chu
	local shell = S.shell
	local shellPos = S.fpos
	local look = S.frot.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	flat = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, -1)
	local gres = Workspace:Raycast(owner.Position + Vector3.new(0, 3, 0), Vector3.new(0, -200, 0), S.rp)
	local gy = gres and gres.Position.Y or (owner.Position.Y - 3)
	local standY = gy + LB
	local hoverTop = standY + CFG.HoverRise

	-- 3) cac cum bo phan: moi cum co thoi diem bay vao rieng (chan truoc, dau + cua sau cung)
	local list = mainJoints()
	local trails = {}
	local finished = false
	local t0 = os.clock()
	for _, e in ipairs(list) do
		e.delay = (ENTER_ORDER[e.part.Name] or 1.0) + fr(0, 0.12)
		e.dur = fr(0.5, 0.7)
		e.scatter = Vector3.new(fr(-7, 7), fr(2, 9), fr(-7, 7))
		e.D = Vector3.zero
		e.started, e.done = false, false
		table.insert(trails, addTrail(e.part, (e.depth % 2 == 0) and COL.Glow or COL.Gold))
	end
	S.post = function()
		local el = os.clock() - t0
		-- giap con dung o cho cu cho den luc cum bay di: V bu lai chuyen dong cua chu
		local V = shellPos - S.hrp.Position
		local all = true
		for _, e in ipairs(list) do
			local u = math.clamp((el - e.delay) / e.dur, 0, 1)
			local k = u * u * (3 - 2 * u)
			e.D = V * (1 - k) + e.scatter * math.sin(math.pi * k)
			local own = e.D - (e.parent and e.parent.D or Vector3.zero)
			local p0 = e.m.Part0
			if p0 and own.Magnitude > 1e-3 then
				e.m.C0 = CFrame.new(p0.CFrame:VectorToObjectSpace(own)) * e.m.C0
			end
			if u > 0 and not e.started then
				e.started = true
				local nm = e.part.Name
				if nm == "B_FootR" then
					-- chan bat dau bay vao: thruster chan phun lua, chu duoc nang len
					S.hoverFeet = true
					S.hoverGoal = hoverTop
					S.hoverRate = 2.4
					playSound(SND_ROCKET, 0.35, 0.7)
				elseif nm == "B_Torso" then
					S.hoverBack = true
				end
			end
			if u >= 1 then
				if not e.done then
					e.done = true
					sparks(e.part.Position, 6, COL.Glow, 5, 0.4)
				end
			else
				all = false
			end
		end
		if all then finished = true end
	end

	-- 4) chuyen goc giap sang chu (giap van o nguyen cho nho V), chu vao che do lo lung
	S.rootMotor.Part0 = owner
	S.hrp, S.hum = owner, phum
	S.drone = false
	S.dhold = false
	S.denter = false
	S.dfaceOwner = false
	S.dvel = Vector3.zero
	S.dmode, S.dlast, S.dforce, S.dflyUntil = "walk", nil, nil, 0
	S.dair = false
	S.tiltW = 0
	S.shell = nil
	if shell then shell:Destroy() end
	beginAirControl()
	S.frot = CFrame.lookAt(Vector3.zero, flat)
	S.fvel = Vector3.zero
	S.hoverXZ = owner.Position
	S.hoverY = owner.Position.Y
	S.hoverGoal = S.hoverY
	S.hoverGy = gy
	S.hoverRate = 2.4
	S.hoverFeet, S.hoverBack = false, false
	S.ctrl = "hover"
	S.openGoal = 1
	S.legClose, S.armClose = true, true -- chan + tay giap khep lai khi hop the
	playSound("rbxasset://sounds/electronicpingshort.wav", 0.5, 0.7)

	local w1 = os.clock()
	while not finished and S == my and S.on and os.clock() - w1 < 5 do task.wait(0.03) end
	if S ~= my or not S.on then return end
	S.post = nil
	destroyAll(trails)

	-- 5) khop xong: loe sang, cua truoc dong lai tren nguoi chu
	local cp = S.hrp.Position
	local fl = fxPart("Flash", Vector3.one * 3, COL.White, NEON, BALL)
	fl.CFrame = CFrame.new(cp)
	fl.Transparency = 0.3
	tw(fl, 0.45, {Size = Vector3.one * 18, Transparency = 1})
	Debris:AddItem(fl, 0.5)
	sparks(cp, 40, COL.Glow, 14, 0.8)
	sparks(cp, 24, COL.Gold, 12, 0.7)
	shake(0.9, 0.45)
	task.wait(0.4)
	if S ~= my or not S.on then return end
	S.openGoal = 0
	S.legClose, S.armClose = false, false
	local hid = false
	local w2 = os.clock()
	while S == my and S.on and S.openW > 0.04 and os.clock() - w2 < 2 do
		if not hid and S.openW < 0.4 then
			hid = true
			hideChar()
		end
		task.wait(0.03)
	end
	if S ~= my or not S.on then return end
	if not hid then hideChar() end
	ringFx(Vector3.new(cp.X, gy + 0.3, cp.Z), 22, COL.Glow, 0.7)

	-- 6) thruster giam luc dan, ha nhe xuong mat dat
	S.hoverGoal = standY
	S.hoverRate = 3.0
	local w3 = os.clock()
	while S == my and S.on and (S.hoverY - standY) > 0.25 and os.clock() - w3 < 3 do task.wait(0.03) end
	if S ~= my or not S.on then return end
	S.hoverFeet, S.hoverBack = false, false
	S.hoverGoal = standY
	S.hoverY = standY
	S.leapPeak = hoverTop
	S.stomp = true
	destroyWings()
	applyArmorStats(phum, owner)
	S.noColUntil = os.clock() + 1.0
	releaseControl()
	task.wait(0.4)
	if S ~= my then return end
	S.busy = false
end

-- V10.13: HOP THE NHANH TREN KHONG (tu cuu): giap da sat chu -> cac bo phan ghep trong `dur` giay -> vao thang che do bay (khong ha xuong dat)
function NX.quickEnter(dur)
	if not S.on or not S.drone then return false end
	local my = S
	local owner, phum = S.phrp, S.phum
	if not (owner and owner.Parent) then return false end
	S.strikes = {}
	dismissExtras()
	local shell = S.shell
	local shellPos = S.fpos
	local look = S.frot.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	flat = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, -1)

	local list = mainJoints()
	local trails = {}
	local finished = false
	local t0 = os.clock()
	local k = math.max(0.08, dur) / 2.25
	for _, e in ipairs(list) do
		e.delay = ((ENTER_ORDER[e.part.Name] or 1.0) + fr(0, 0.12)) * k
		e.dur = fr(0.5, 0.7) * k
		e.scatter = Vector3.new(fr(-7, 7), fr(2, 9), fr(-7, 7))
		e.D = Vector3.zero
		e.started, e.done = false, false
		table.insert(trails, addTrail(e.part, (e.depth % 2 == 0) and COL.Glow or COL.Gold))
	end
	S.post = function()
		local el = os.clock() - t0
		local V = shellPos - S.hrp.Position
		local all = true
		for _, e in ipairs(list) do
			local u = math.clamp((el - e.delay) / e.dur, 0, 1)
			local kk = u * u * (3 - 2 * u)
			e.D = V * (1 - kk) + e.scatter * math.sin(math.pi * kk)
			local own = e.D - (e.parent and e.parent.D or Vector3.zero)
			local p0 = e.m.Part0
			if p0 and own.Magnitude > 1e-3 then
				e.m.C0 = CFrame.new(p0.CFrame:VectorToObjectSpace(own)) * e.m.C0
			end
			if u >= 1 then
				if not e.done then
					e.done = true
					sparks(e.part.Position, 5, COL.Glow, 5, 0.3)
				end
			else
				all = false
			end
		end
		if all then finished = true end
	end

	-- chuyen goc giap sang chu, chu giu yen tren khong (che do lo lung)
	S.rootMotor.Part0 = owner
	S.hrp, S.hum = owner, phum
	S.drone = false
	S.dhold = false
	S.denter = false
	S.dfaceOwner = false
	S.dvel = Vector3.zero
	S.dmode, S.dlast, S.dforce, S.dflyUntil = "walk", nil, nil, 0
	S.dair = false
	S.tiltW = 0
	S.shell = nil
	if shell then shell:Destroy() end
	beginAirControl()
	S.frot = CFrame.lookAt(Vector3.zero, flat)
	S.fvel = Vector3.zero
	S.hoverXZ = owner.Position
	S.hoverY = owner.Position.Y
	S.hoverGoal = S.hoverY
	S.hoverRate = 6
	S.hoverFeet, S.hoverBack = false, false
	S.ctrl = "hover"
	S.openGoal = 1
	S.legClose, S.armClose = true, true
	playSound("rbxasset://sounds/electronicpingshort.wav", 0.5, 1.2)

	local w1 = os.clock()
	while not finished and S == my and S.on and os.clock() - w1 < dur + 1.5 do task.wait() end
	if S ~= my or not S.on then return false end
	S.post = nil
	destroyAll(trails)

	-- khop xong: loe sang, cua truoc dong lai, vao thang che do bay
	local cp = S.hrp.Position
	local fl = fxPart("Flash", Vector3.one * 3, COL.White, NEON, BALL)
	fl.CFrame = CFrame.new(cp)
	fl.Transparency = 0.3
	tw(fl, 0.4, {Size = Vector3.one * 16, Transparency = 1})
	Debris:AddItem(fl, 0.5)
	sparks(cp, 30, COL.Glow, 14, 0.7)
	sparks(cp, 18, COL.Gold, 12, 0.6)
	S.openGoal = 0
	S.legClose, S.armClose = false, false
	local hid = false
	local w2 = os.clock()
	while S == my and S.on and os.clock() - w2 < 0.8 do
		if S.openW < 0.4 then
			hid = true
			hideChar()
			break
		end
		task.wait()
	end
	if S ~= my or not S.on then return false end
	if not hid then hideChar() end
	if S.parts.CoreLight then S.parts.CoreLight.Enabled = true end
	applyArmorStats(phum, owner)
	S.hoverFeet, S.hoverBack = false, false
	S.fvel = Vector3.zero
	S.ctrl = "fly"
	S.stomp = false
	S.flying = true
	buildWings()
	ringFx(owner.Position - Vector3.new(0, 3, 0), 16, COL.Fire, 0.6)
	shake(0.8, 0.4)
	S.busy = false
	return true
end

local function toggleExit()
	if S.drone then enterArmor() else exitArmor() end
end

-- khi giap dang tach roi: Tool 2 bam 1 = bay / ban ten lua, bam 2 = ha xuong di bo
local function droneFly()
	if S.dmode == "fly" then
		fireSalvo()
	else
		S.dforce = "fly"
	end
end

local function droneWalk()
	S.dforce = nil
	S.dmode = "walk"
	S.dflyUntil = 0
end

------------------------------------------------------------------
-- DEM SO LAN BAM
------------------------------------------------------------------
------------------------------------------------------------------
-- V10: 3 CHIEU BAM 4 LAN
--   BusterArmor  x4 : ho den (gom sat vun -> nen -> bay) / dang o khong gian ky ao: x4 de ve
--   BusterFly    x4 : chan phai dap -> cau sat nano -> an mon -> balo sat bay len vu tru
--   BusterAttack x4 : 2 tay phu bay toi nhanh, tao cap cong dich chuyen (an mon nano dan)
-- Dung duoc khi dang mac giap (hoac giap tach roi / drone)
------------------------------------------------------------------
local NX_REALM = Vector3.new(0, 7000, 0)
local HOLE_PULL = 170   -- ban kinh hut (cu: 52) theo ho den to hon
local HOLE_SPEED = 130
local HOLE_LIFE = 80
local BRIDGE_LIFE = 28
local PORTAL_R = 9
local PORTAL_LIFE = 30
local SND_PING = "rbxasset://sounds/electronicpingshort.wav"
local SCRAP_COLS = {
	Color3.fromRGB(86, 80, 76), Color3.fromRGB(112, 70, 48), Color3.fromRGB(64, 68, 76),
	Color3.fromRGB(140, 34, 30), Color3.fromRGB(150, 128, 70), Color3.fromRGB(48, 50, 56),
}
local NANO_COLS = {
	Color3.fromRGB(150, 240, 255), Color3.fromRGB(228, 178, 42), Color3.fromRGB(255, 90, 60), Color3.fromRGB(238, 250, 255),
}
local NX_FOLDER, NX_SOLID

local function nxFolder()
	if not (NX_FOLDER and NX_FOLDER.Parent) then
		NX_FOLDER = Instance.new("Folder")
		NX_FOLDER.Name = "NX_FX"
		NX_FOLDER.Parent = FX
	end
	return NX_FOLDER
end

-- phan co va cham (cau, khong gian ky ao) nam ngoai FX de tia ray cua giap thay duoc mat dat
local function nxSolid()
	if not (NX_SOLID and NX_SOLID.Parent) then
		NX_SOLID = Instance.new("Folder")
		NX_SOLID.Name = "NX_Solid"
		NX_SOLID.Parent = Workspace
	end
	return NX_SOLID
end

local function nxPart(name, size, color, mat, shape, collide)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = mat or NEON
	if shape then p.Shape = shape end
	p.Anchored = true
	p.CanCollide = collide and true or false
	p.CanQuery = collide and true or false
	p.CanTouch = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = collide and nxSolid() or nxFolder()
	return p
end

local function alive(my)
	return S == my and S.on and S.hrp ~= nil and S.hrp.Parent ~= nil
end

local function ownerRoot()
	if S.drone and S.phrp and S.phrp.Parent then return S.phrp end
	if S.hrp then return S.hrp end
	-- V10.13b: khong mac giap (da thao trong khong gian ky ao) -> lay nhan vat
	local ch = player.Character
	return ch and ch:FindFirstChild("HumanoidRootPart") or nil
end

local function ownerHum()
	if S.drone and S.phum then return S.phum end
	if S.hum then return S.hum end
	local ch = player.Character
	return ch and ch:FindFirstChildOfClass("Humanoid") or nil
end

local function nxFlat(v)
	local f = Vector3.new(v.X, 0, v.Z)
	if f.Magnitude < 0.01 then return nil end
	return f.Unit
end

local function nxAim(from, maxD)
	local p
	pcall(function() p = mouse.Hit.Position end)
	if not p then p = from + Vector3.new(0, 0, -60) end
	local d = p - from
	if d.Magnitude > maxD then p = from + d.Unit * maxD end
	return p
end

local function nxGround(p)
	local res = Workspace:Raycast(p + Vector3.new(0, 4, 0), Vector3.new(0, -160, 0), rayParams())
	if res then return res.Position end
	return p
end

local function nxFace(dir)
	if not dir or not S.hrp then return end
	local rot = CFrame.lookAt(Vector3.zero, dir).Rotation
	if S.drone then
		S.frot = rot
	else
		if S.ctrl then S.frot = rot end
		S.hrp.CFrame = CFrame.lookAt(S.hrp.Position, S.hrp.Position + dir)
	end
end

-- dat nguoi choi (va vo giap neu dang tach roi) toi vi tri moi
local function nxPlace(pos, rotCF)
	local root = ownerRoot()
	if not (root and root.Parent) then return end
	local old = root.Position
	rotCF = rotCF or root.CFrame.Rotation
	root.CFrame = CFrame.new(pos) * rotCF
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	if S.drone and S.hrp and S.hrp ~= root then
		local off = S.fpos - old
		S.fpos = pos + off
		S.hrp.CFrame = CFrame.new(S.fpos) * S.frot
		S.dvel = Vector3.zero
	elseif S.ctrl then
		S.fpos = pos
		S.fvel = Vector3.zero
		S.frot = rotCF
	end
end

local function nxFlash(color, alpha, dur)
	pcall(function()
		local pg = player:FindFirstChildOfClass("PlayerGui")
		if not pg then return end
		local g = Instance.new("ScreenGui")
		g.Name = "NX_Flash"
		g.IgnoreGuiInset = true
		g.ResetOnSpawn = false
		g.DisplayOrder = 900
		local f = Instance.new("Frame")
		f.Size = UDim2.fromScale(1, 1)
		f.BackgroundColor3 = color
		f.BorderSizePixel = 0
		f.BackgroundTransparency = 1
		f.Parent = g
		g.Parent = pg
		tw(f, 0.12, {BackgroundTransparency = 1 - alpha})
		task.delay(0.16, function() tw(f, dur, {BackgroundTransparency = 1}) end)
		Debris:AddItem(g, dur + 0.6)
	end)
end

-- hat nano: cac khoi lap phuong nho bay (toPos: bay ve 1 diem)
local function nanoCubes(pos, n, spread, life, toPos)
	for _ = 1, n do
		local s = fr(0.25, 0.7)
		local c = nxPart("Nano", Vector3.new(s, s, s), NANO_COLS[math.random(#NANO_COLS)], NEON)
		local a = pos + Vector3.new(fr(-spread, spread), fr(-spread, spread) * 0.6, fr(-spread, spread))
		c.CFrame = CFrame.new(a) * CFrame.Angles(fr(0, 6), fr(0, 6), 0)
		local dest
		if toPos then
			dest = toPos + Vector3.new(fr(-1.5, 1.5), fr(-1.5, 1.5), fr(-1.5, 1.5))
		else
			dest = a + Vector3.new(fr(-6, 6), fr(3, 12), fr(-6, 6))
		end
		tw(c, life, {CFrame = CFrame.new(dest) * CFrame.Angles(fr(0, 6), fr(0, 6), fr(0, 6)), Transparency = 1, Size = Vector3.new(0.05, 0.05, 0.05)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		Debris:AddItem(c, life + 0.1)
	end
end

------------------------------------------------------------------
-- HO DEN
------------------------------------------------------------------
-- V10.1: cau hinh ho den (sua so o day de chinh) -- khong tao local moi (tranh vuot gioi han 200 local)
NX.HOLE = {
	BallMul = 5,            -- qua cau sat to gap 5 lan (ban kinh toi da 24 -> 120)
	Scraps = 280,           -- so manh sat gom vao (cu: 72)
	GatherTime = 6.5,       -- giay gom sat (cu: 3.4)
	ScrapNear = 70, ScrapFar = 460, -- sat bay tu khoang cach nay toi (cu: 24-130)
	SuckTime = 0.8,         -- V10.11: giay bi hut vao ho den khi cham vao (truoc 2.5) -> vao khong gian ky ao gan nhu ngay lap tuc
	CompressTime = 6.0,     -- giay nen cham thanh ho den (cu: 1.7)
	FinalR = 30,            -- ban kinh chan troi su kien (cu: 8-9.8)
	Rise = 1.8,             -- tam ho cao hon nguoi = FinalR x Rise
	MaxChunks = 80,         -- so manh sat bam/quay quanh cau
	IronCol = Color3.fromRGB(78, 80, 88),
	HoleCol = Color3.fromRGB(10, 10, 26),
	HeatCol = Color3.fromRGB(255, 130, 50),
	GlowCol = Color3.fromRGB(150, 100, 255),
	StreakCols = {Color3.fromRGB(235, 220, 255), Color3.fromRGB(170, 120, 255), Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 200, 120)},
	-- dia sang mem (luon quay mat ve camera), r = x ban kinh ho, z = lui ra sau
	Layers = {
		{r = 3.3,  col = Color3.fromRGB(122, 66, 232),  tr = 0.90, z = 0.30},
		{r = 2.6,  col = Color3.fromRGB(150, 96, 245),  tr = 0.84, z = 0.24},
		{r = 2.0,  col = Color3.fromRGB(178, 130, 255), tr = 0.76, z = 0.18},
		{r = 1.55, col = Color3.fromRGB(206, 172, 255), tr = 0.60, z = 0.12},
		{r = 1.28, col = Color3.fromRGB(236, 224, 255), tr = 0.30, z = 0.07},
		{r = 1.12, col = Color3.fromRGB(255, 252, 255), tr = 0.08, z = 0.03},
	},
	-- cac vong nhan (chia doan): vien tim ngoai, vien vang, cung anh sang, vong photon
	Rings = {
		{r = 3.3,  n = 64, th = 0.05,  col = Color3.fromRGB(165, 95, 255),  tr = 0.12, z = 0.30, spin = 0.05, var = 0.10},
		{r = 2.5,  n = 56, arc = 0.62, a0 = 3.4, th = 0.04, col = Color3.fromRGB(255, 205, 120), col2 = Color3.fromRGB(255, 140, 60), tr = 0.20, z = 0.20, spin = 0.12, var = 0.25},
		{r = 2.0,  n = 48, arc = 0.40, a0 = 0.6, th = 0.022, col = Color3.fromRGB(240, 228, 255), tr = 0.35, z = 0.14, spin = -0.30, var = 0.30},
		{r = 1.65, n = 40, arc = 0.30, a0 = 2.2, th = 0.018, col = Color3.fromRGB(255, 255, 255), tr = 0.40, z = 0.10, spin = 0.45, var = 0.30},
		{r = 1.18, n = 48, th = 0.028, col = Color3.fromRGB(255, 250, 255), tr = 0.05, z = 0.04, spin = 0, var = 0.05},
	},
}

local function newHole(pos)
	local HC = NX.HOLE
	local H = {pos = pos, r = 3, heat = 0, discA = 0, orbit = 0, chunkT = 0, chunkK = 1, t = 0, mode = "gather",
		chunks = {}, layers = {}, segs = {}, segList = {}, segCF = {}, lastA = -1, lastS = 0, emS = 0}
	local core = nxPart("HoleCore", Vector3.new(6, 6, 6), HC.IronCol, METAL, BALL)
	core.Reflectance = 0.12
	H.core = core
	local glow = nxPart("HoleGlow", Vector3.new(7, 7, 7), HC.HeatCol, NEON, BALL)
	glow.Transparency = 0.82
	H.glow = glow
	-- dia sang mem
	for i, ly in ipairs(HC.Layers) do
		local d = nxPart("HoleDisc", Vector3.new(0.2, 4, 4), ly.col, NEON, CYL)
		d.Transparency = 1
		H.layers[i] = d
	end
	-- vong nhan (doan nho neon xep thanh vong)
	for ri, rg in ipairs(HC.Rings) do
		local list = {}
		local cnt = math.max(2, math.floor(rg.n * (rg.arc or 1) + 0.5))
		for si = 1, cnt do
			local ang = (rg.a0 or 0) + (si - 1) / rg.n * math.pi * 2
			local p = nxPart("HoleSeg", Vector3.new(1, 0.3, 0.3), rg.col:Lerp(rg.col2 or rg.col, si / cnt), NEON)
			p.Transparency = 1
			list[si] = {p = p, c = math.cos(ang), s = math.sin(ang), tv = math.random() * (rg.var or 0.1)}
			H.segList[#H.segList + 1] = p
		end
		H.segs[ri] = list
	end
	local lt = Instance.new("PointLight")
	lt.Color = HC.HeatCol
	lt.Range = 40
	lt.Brightness = 3
	lt.Shadows = false
	lt.Parent = core
	H.light = lt
	-- bui sang bi hut vao ho (hat roi vao chan troi su kien)
	local aura = nxPart("HoleAura", Vector3.new(10, 10, 10), HC.GlowCol, NEON, BALL)
	aura.Transparency = 1
	H.aura = aura
	local okE, em = pcall(mkEmitter, aura, {
		life = NumberRange.new(0.9, 1.5), speed = NumberRange.new(-30, -16), rate = 25, spread = Vector2.new(30, 30),
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 190, 110)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(205, 160, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 70, 230)),
		}), light = 1,
		transp = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.45), NumberSequenceKeypoint.new(1, 1)}),
		size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 0)}),
		shape = Enum.ParticleEmitterShape.Sphere,
	})
	if okE then
		pcall(function() em.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface end)
		H.em = em
	end
	return H
end

local function holeAddChunk(H)
	if #H.chunks >= NX.HOLE.MaxChunks then return end
	local d = Vector3.new(fr(-1, 1), fr(-0.6, 1), fr(-1, 1))
	if d.Magnitude < 0.1 then d = Vector3.yAxis end
	local sz = fr(0.8, 3.2)
	local base = Vector3.new(sz, sz * fr(0.5, 1), sz * fr(0.6, 1.3))
	local p = nxPart("Scrap", base, SCRAP_COLS[math.random(#SCRAP_COLS)], METAL)
	H.chunks[#H.chunks + 1] = {p = p, dir = d.Unit, k = math.random(), base = base,
		rot = CFrame.Angles(fr(0, 6), fr(0, 6), fr(0, 6)), spd = fr(0.3, 1.1), ang = fr(0, 6)}
end

local function holeStep(H, dt)
	local HC = NX.HOLE
	H.t = H.t + dt
	local t = H.t
	local s = math.max(H.r, 0.06)
	local c = CFrame.new(H.pos)
	H.core.Size = Vector3.new(1, 1, 1) * (2 * s * 0.96)
	H.core.CFrame = c * CFrame.Angles(t * 0.3, t * 0.5, 0)
	H.core.Color = HC.IronCol:Lerp(HC.HoleCol, H.heat)
	local mat = (H.heat > 0.6) and SMOOTH or METAL
	if H.core.Material ~= mat then H.core.Material = mat end
	local hc = HC.HeatCol:Lerp(HC.GlowCol, H.heat)
	H.glow.Size = Vector3.new(1, 1, 1) * (2 * s * (1.07 + 0.03 * math.sin(t * 6)))
	H.glow.CFrame = c
	H.glow.Transparency = 0.8 + 0.12 * H.heat
	H.glow.Color = hc
	H.light.Range = math.clamp(s * 1.5, 10, 60)
	H.light.Brightness = math.clamp(2 + s * 0.04, 2, 6)
	H.light.Color = hc
	-- bui sang roi vao
	H.aura.Size = Vector3.new(1, 1, 1) * (2 * s * 2.0)
	H.aura.CFrame = c
	local em = H.em
	if em then
		em.Rate = 25 + 110 * H.heat
		if math.abs(s - H.emS) > H.emS * 0.06 then
			H.emS = s
			em.Speed = NumberRange.new(-s * 1.5, -s * 0.8)
			em.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, math.max(0.3, s * 0.1)), NumberSequenceKeypoint.new(1, 0)})
		end
	end
	-- dia + vong luon quay mat ve camera (nhin tu dau cung ra mat ho den nhu trong anh)
	local a = H.discA
	if a < 0.02 then
		if H.lastA >= 0.02 or H.lastA < 0 then
			for _, d in ipairs(H.layers) do d.Transparency = 1 end
			for _, p in ipairs(H.segList) do p.Transparency = 1 end
		end
		H.lastA = a
	else
		local cam = Workspace.CurrentCamera
		local camPos = cam and cam.CFrame.Position or (H.pos + Vector3.new(0, 0, 100))
		if (camPos - H.pos).Magnitude < 1 then camPos = H.pos + Vector3.new(0, 0, 1) end
		local F = CFrame.lookAt(H.pos, camPos)
		local look, right, up = F.LookVector, F.RightVector, F.UpVector
		local dk = 0.3 + 0.7 * (a ^ 0.7)
		local sk = s * dk
		local alphaChanged = math.abs(a - H.lastA) > 0.003
		local sizeChanged = math.abs(sk - H.lastS) > H.lastS * 0.004
		local face = CFrame.Angles(0, math.pi / 2, 0)
		for i, d in ipairs(H.layers) do
			local ly = HC.Layers[i]
			local rr = sk * ly.r
			d.Size = Vector3.new(0.2, rr * 2, rr * 2)
			d.CFrame = CFrame.lookAt(H.pos - look * (sk * ly.z), camPos - look * (sk * ly.z)) * face
			if alphaChanged then d.Transparency = 1 - (1 - ly.tr) * a end
		end
		local cfs = H.segCF
		local k = 0
		for ri, rg in ipairs(HC.Rings) do
			local R0 = sk * rg.r
			local th = sk * rg.th
			local len = (2 * math.pi * R0 / rg.n) * 1.25
			local sp = t * rg.spin
			local cs0, sn0 = math.cos(sp), math.sin(sp)
			local zoff = look * (-sk * rg.z)
			for _, sg in ipairs(H.segs[ri]) do
				local ca = sg.c * cs0 - sg.s * sn0
				local sa = sg.s * cs0 + sg.c * sn0
				k = k + 1
				cfs[k] = CFrame.fromMatrix(H.pos + (right * ca + up * sa) * R0 + zoff, up * ca - right * sa, look)
				if sizeChanged then sg.p.Size = Vector3.new(len, th, th) end
				if alphaChanged then sg.p.Transparency = math.clamp(1 - (1 - rg.tr - sg.tv) * a, 0, 1) end
			end
		end
		local okB = pcall(Workspace.BulkMoveTo, Workspace, H.segList, cfs, Enum.BulkMoveMode.FireCFrameChanged)
		if not okB then
			for i, p in ipairs(H.segList) do p.CFrame = cfs[i] end
		end
		H.lastA = a
		H.lastS = sk
	end
	local sc = math.clamp(s / 9, 0.5, 14) * H.chunkK
	for _, ch in ipairs(H.chunks) do
		ch.ang = ch.ang + dt * ch.spd * (0.15 + 1.6 * H.orbit)
		local rad = s * (1.0 + H.orbit * (0.5 + 1.1 * ch.k))
		local dir = CFrame.Angles(0, ch.ang, 0):VectorToWorldSpace(ch.dir)
		local k = (H.orbit > 0.05) and 1 or 0.985
		ch.p.CFrame = CFrame.new(H.pos + dir * rad * k) * ch.rot * CFrame.Angles(t * 0.8, 0, 0)
		ch.p.Size = ch.base * sc
		ch.p.Transparency = H.chunkT
	end
end

local function holeDestroy(H)
	pcall(function() H.core:Destroy() end)
	pcall(function() H.glow:Destroy() end)
	pcall(function() H.aura:Destroy() end)
	for _, d in ipairs(H.layers) do pcall(function() d:Destroy() end) end
	for _, p in ipairs(H.segList) do pcall(function() p:Destroy() end) end
	for _, ch in ipairs(H.chunks) do pcall(function() ch.p:Destroy() end) end
end

function NX.killHole(anim)
	local H = NX.hole
	if not H then return end
	NX.hole = nil
	H.dying = true
	if anim then
		task.spawn(function()
			local t0 = os.clock()
			local r0 = H.r
			while os.clock() - t0 < 1.1 do
				H.r = r0 * (1 - (os.clock() - t0) / 1.1)
				pcall(holeStep, H, 0.016)
				RunService.Heartbeat:Wait()
			end
			holeDestroy(H)
		end)
	else
		holeDestroy(H)
	end
end

------------------------------------------------------------------
-- V10.13c: THAO GIAP LUC DANG NAN HO DEN: 2 canh tay chinh bay toi nang qua cau len roi nem di xa, qua cau bien mat
------------------------------------------------------------------
-- tach ho den ra khoi NX (de NX.cleanup khong pha), tra ve goi T de animate
function NX.prepThrow(old)
	local H = NX.hole
	if not (H and not H.dying and NX.busyHole and not NX.realm and old.on and old.armor) then return nil end
	local folder = Instance.new("Folder")
	folder.Name = "HB_Throw"
	folder.Parent = FX
	local function mv(p) if p and p.Parent then p.Parent = folder end end
	mv(H.core) mv(H.glow) mv(H.aura)
	for _, d in ipairs(H.layers) do mv(d) end
	for _, p in ipairs(H.segList) do mv(p) end
	for _, ch in ipairs(H.chunks) do mv(ch.p) end
	NX.hole = nil
	H.mode = "thrown"
	local root = ownerRoot()
	return {H = H, folder = folder, from = root and root.Position or H.pos, groups = {}}
end

-- lay 2 canh tay chinh (vai/cang/ban tay + ngon) ra khoi giap truoc khi giap tan di
function NX.takeArms(T, old)
	local armor = old.armor
	if not (armor and old.rootMotor) then return end
	local list, byPart = mainJoints()
	local owner = old.owner or {}
	local function resolve(p)
		local q, guard = p, 0
		while q and guard < 80 do
			if byPart[q] then return byPart[q] end
			local o = owner[q]
			if o and o ~= q then
				q = o
			else
				local j = q:FindFirstChildWhichIsA("JointInstance")
				q = j and j.Part0 or nil
			end
			guard += 1
		end
		return nil
	end
	local groups, armSet = {}, {}
	for _, d in ipairs(armor:GetDescendants()) do
		if d:IsA("BasePart") then
			local e = resolve(d)
			local nm = e and e.part.Name
			local rank = nm and ((nm:find("^B_Hand") and 3) or (nm:find("^B_FArm") and 2) or (nm:find("^B_UArm") and 1)) or nil
			if rank then
				local side = (nm:sub(-1) == "L") and "L" or "R"
				local g = groups[side]
				if not g then
					g = {parts = {}, rank = 0}
					groups[side] = g
				end
				table.insert(g.parts, d)
				armSet[d] = true
				if rank > g.rank then g.rank = rank g.ref = e.part end
			end
		end
	end
	-- bo moi khop noi voi canh tay (de tach duoc ra khoi giap)
	for _, d in ipairs(armor:GetDescendants()) do
		if (d:IsA("Motor6D") or d:IsA("Weld") or d:IsA("WeldConstraint")) and (armSet[d.Part0] or armSet[d.Part1]) then
			pcall(function() d:Destroy() end)
		end
	end
	for side, g in pairs(groups) do
		if g.ref then
			g.cf0 = g.ref.CFrame
			g.rel, g.tr0 = {}, {}
			for _, p in ipairs(g.parts) do
				g.rel[p] = g.cf0:ToObjectSpace(p.CFrame)
				g.tr0[p] = p.Transparency
			end
			for _, p in ipairs(g.parts) do
				p.Anchored = true
				p.CanCollide = false
				p.CanTouch = false
				p.CanQuery = false
				p.Parent = T.folder
			end
		else
			groups[side] = nil
		end
	end
	T.groups = groups
	-- cum bo phan (nhu luc giap tan): moi manh di theo bo phan chu cua no
	local cl = {}
	for _, g in pairs(groups) do
		for _, p in ipairs(g.parts) do
			local o = owner[p]
			if not (o and armSet[o]) then o = p end
			cl[p] = o
		end
	end
	T.cluster = cl
end

function NX.runThrow(T)
	local H = T.H
	local HC = NX.HOLE
	local ok, err = pcall(function()
		local groups = T.groups
		local base = H.pos
		local r0 = math.max(H.r, 4)
		local from = T.from
		local out = Vector3.new(base.X - from.X, 0, base.Z - from.Z)
		if out.Magnitude < 1 then
			local cam = Workspace.CurrentCamera
			local lv = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
			out = Vector3.new(lv.X, 0, lv.Z)
			if out.Magnitude < 0.1 then out = Vector3.new(0, 0, -1) end
		end
		out = out.Unit
		local sideV = Vector3.new(-out.Z, 0, out.X)
		-- huong nem: lech 70-110 do so voi huong tu nguoi toi qua cau (sang huong khac), hoi chech len
		local ang = math.rad(fr(70, 110)) * ((math.random() < 0.5) and 1 or -1)
		local ca, sa = math.cos(ang), math.sin(ang)
		local dir = (Vector3.new(out.X * ca - out.Z * sa, 0, out.X * sa + out.Z * ca) + Vector3.new(0, 0.28, 0)).Unit
		local lift = math.clamp(r0 * 1.3, 38, 140)
		local armOff = r0 * 0.9 + 3
		local wind = math.min(r0 * 0.4, 24)
		local TA, TB, TC, TBALL = 0.5, 0.7, 0.25, 2.0

		local function tgtOf(side)
			return base + sideV * ((side == "R") and 1 or -1) * armOff + Vector3.new(0, -r0 * 0.5, 0)
		end
		local lastCF = {}
		local function poseArms(posOf, fade)
			local ps, cs = {}, {}
			for side, g in pairs(groups) do
				local gcf = CFrame.new(posOf(side, g)) * g.cf0.Rotation
				for _, p in ipairs(g.parts) do
					if p.Parent then
						ps[#ps + 1] = p
						cs[#cs + 1] = gcf * g.rel[p]
						lastCF[p] = cs[#cs]
						if fade then p.Transparency = math.max(g.tr0[p] or 0, fade) end
					end
				end
			end
			if #ps > 0 then
				local okb = pcall(Workspace.BulkMoveTo, Workspace, ps, cs, Enum.BulkMoveMode.FireCFrameChanged)
				if not okb then for i, p in ipairs(ps) do pcall(function() p.CFrame = cs[i] end) end end
			end
		end
		local function ease3(x) x = math.clamp(x, 0, 1) return x * x * (3 - 2 * x) end

		playSound(SND_ROCKET, 0.6, 1.2)
		playSound(SND_PING, 0.8, 0.7)
		local dt = 0.016
		local t0 = os.clock()

		-- A) 2 canh tay bay toi 2 ben qua cau
		while true do
			local el = os.clock() - t0
			local u = ease3(el / TA)
			H.pos = base
			poseArms(function(side, g) return g.cf0.Position:Lerp(tgtOf(side), u) end)
			pcall(holeStep, H, dt)
			if el >= TA then break end
			dt = RunService.Heartbeat:Wait()
		end
		-- B) nang qua cau len cao + gong nguoc ra sau de lay da nem
		t0 = os.clock()
		local lastFx = 0
		while true do
			local el = os.clock() - t0
			local u = ease3(el / TB)
			local off = Vector3.new(0, lift * u, 0) - dir * wind * u
			H.pos = base + off
			poseArms(function(side) return tgtOf(side) + off end)
			pcall(holeStep, H, dt)
			shake(0.3 + 0.5 * u, 0.12)
			if el - lastFx > 0.12 then
				lastFx = el
				sparks(H.pos - Vector3.new(0, r0 * 0.5, 0), 4, COL.Gold, 10, 0.4)
			end
			if el >= TB then break end
			dt = RunService.Heartbeat:Wait()
		end
		-- C) dung luc nem: tay thuc manh ra, qua cau bay vut di that xa roi bien mat
		local L0 = H.pos
		local armBase = L0
		ringFx(L0, math.clamp(r0 * 3, 60, 260), HC.GlowCol, 0.9)
		ringFx(L0, math.clamp(r0 * 2, 40, 180), COL.White, 0.6)
		sparks(L0, 70, HC.StreakCols[2], 90, 0.9)
		shake(2.2, 0.8)
		playSound(SND_BOOM, 1, 0.6)
		playSound(SND_ROCKET, 0.8, 0.8)
		nxFlash(Color3.fromRGB(225, 210, 255), 0.3, 0.4)
		t0 = os.clock()
		local rStart = H.r
		local ghostT = 0
		local ballDead = false
		local pieces, clusters
		local DURA = 2.6                 -- 2 tay tach ra bay vao vu tru: thoi gian bay + mo dan
		local TEND = TC + DURA
		while true do
			local el = os.clock() - t0
			if el >= TEND then break end
			-- qua cau: tang toc cuc manh theo huong nem, thu nho roi bien mat
			if not ballDead then
				if el >= TBALL then
					ballDead = true
					pcall(holeDestroy, H)
				else
					H.pos = L0 + dir * (150 * el + 1100 * el * el)
					if el > TBALL - 0.35 then H.r = math.max(0.1, rStart * (1 - (el - (TBALL - 0.35)) / 0.35)) end
					pcall(holeStep, H, dt)
					ghostT += dt
					if ghostT > 0.04 and el < 1.2 then
						ghostT = 0
						local gh = nxPart("Ghost", Vector3.new(1, 1, 1) * math.max(1, H.r) * 1.8, HC.GlowCol, NEON, BALL)
						gh.Transparency = 0.75
						gh.CFrame = CFrame.new(H.pos)
						tw(gh, 0.45, {Size = Vector3.new(1, 1, 1) * math.max(1, H.r) * 0.3, Transparency = 1})
						Debris:AddItem(gh, 0.5)
					end
				end
			end
			-- 2 tay: thuc manh ra de nem, xong thi tach thanh tung manh bay vao vu tru
			if el < TC then
				local ua = el / TC
				local thrust = (armOff * 0.3 + 18) * (1 - (1 - ua) ^ 3)
				poseArms(function(side) return tgtOf(side) + (armBase - base) + dir * thrust end)
			else
				if not pieces then
					pieces, clusters = {}, {}
					local center, n = Vector3.zero, 0
					for _, g in pairs(groups) do
						for _, p in ipairs(g.parts) do
							local cf = lastCF[p]
							if cf and p.Parent then
								center += cf.Position
								n += 1
							end
						end
					end
					center = (n > 0) and (center / n) or L0
					for _, g in pairs(groups) do
						for _, p in ipairs(g.parts) do
							local cf = lastCF[p]
							if cf and p.Parent then
								local key = (T.cluster and T.cluster[p]) or p
								local c = clusters[key]
								if not c then
									local cfk = lastCF[key] or cf
									local away = cfk.Position - center
									local d0 = away.Magnitude > 0.5 and away.Unit or Vector3.yAxis
									c = {
										dir = (d0 + Vector3.new(fr(-0.6, 0.6), fr(0.2, 1.0), fr(-0.6, 0.6))).Unit,
										speed = fr(90, 220),
										spin = Vector3.new(fr(-3, 3), fr(-3, 3), fr(-3, 3)),
										cf0 = cfk,
									}
									clusters[key] = c
								end
								pieces[#pieces + 1] = {p = p, c = c, rel = c.cf0:ToObjectSpace(cf), tr0 = p.Transparency}
							end
						end
					end
					playSound("rbxasset://sounds/electronicpingshort.wav", 0.6, 0.45)
				end
				local te = el - TC
				for _, c in pairs(clusters) do
					local mv = c.dir * c.speed * te * (1 + te * 1.2)
					c.cur = CFrame.new(c.cf0.Position + mv) * CFrame.Angles(c.spin.X * te, c.spin.Y * te, c.spin.Z * te) * c.cf0.Rotation
				end
				local ps, cs = {}, {}
				for i, pc in ipairs(pieces) do
					ps[i] = pc.p
					cs[i] = pc.c.cur * pc.rel
				end
				if #ps > 0 then
					local okb = pcall(Workspace.BulkMoveTo, Workspace, ps, cs, Enum.BulkMoveMode.FireCFrameChanged)
					if not okb then for i, p in ipairs(ps) do pcall(function() p.CFrame = cs[i] end) end end
				end
				local u = te / DURA
				if u > 0.65 then
					local f = (u - 0.65) / 0.35
					for _, pc in ipairs(pieces) do pc.p.Transparency = lerp(pc.tr0, 1, f) end
				end
			end
			dt = RunService.Heartbeat:Wait()
		end
	end)
	if not ok then warn("[Hulkbuster] Nem ho den loi:", err) end
	pcall(holeDestroy, H)
	pcall(function() T.folder:Destroy() end)
end

function NX.runHole(my)
	local root, torso = S.hrp, S.parts.Torso
	if not (root and torso) then return end
	NX.killHole(false)
	local HC = NX.HOLE
	local K = HC.BallMul
	local aim = nxAim(torso.Position, 420)
	nxFace(nxFlat(aim - root.Position))
	NX.upGoal = 1
	playSound(SND_PING, 0.7, 0.5)
	local w0 = os.clock()
	while NX.upW < 0.8 and os.clock() - w0 < 1.2 and alive(my) do RunService.Heartbeat:Wait() end
	if not alive(my) then NX.upGoal = 0 return end

	local H = newHole(torso.Position + Vector3.new(0, 11, 0))
	NX.hole = H
	H.r = 2
	H.born = os.clock()

	-- ===== 1) GOM THAT NHIEU SAT -> QUA CAU SAT KHONG LO =====
	local N = HC.Scraps
	local DUR = HC.GatherTime
	local scraps = {}
	for i = 1, N do
		local ang = math.random() * math.pi * 2
		local dist = fr(HC.ScrapNear, HC.ScrapFar)
		scraps[i] = {
			a = root.Position + Vector3.new(math.cos(ang) * dist, fr(-3, 70), math.sin(ang) * dist),
			d = (i / N) * DUR * 0.8, tt = fr(1.5, 2.8), rs = fr(1, 5), sz = fr(2, 13), pr = fr(-70, 70), up = fr(20, 110),
		}
	end
	local absorbed, lastBolt, lastRing = 0, 0, 0
	local t0 = os.clock()
	local dt = 0.016
	while NX.hole == H and alive(my) do
		local el = os.clock() - t0
		local frac = math.clamp(absorbed / N, 0, 1)
		H.r = H.r + (K * (3 + 21 * frac ^ 0.85) - H.r) * math.min(1, dt * 4)
		local c = torso.Position + Vector3.new(0, 8.5 + H.r, 0)
		H.pos = c
		for i = 1, N do
			local s = scraps[i]
			if not s.done and el >= s.d then
				if not s.p then
					s.p = nxPart("Scrap", Vector3.new(s.sz, s.sz * fr(0.5, 1), s.sz * fr(0.6, 1.4)), SCRAP_COLS[math.random(#SCRAP_COLS)], METAL)
					local dv = c - s.a
					local perp = Vector3.new(-dv.Z, 0, dv.X)
					if perp.Magnitude < 0.1 then perp = Vector3.xAxis end
					s.m = (s.a + c) * 0.5 + Vector3.new(0, s.up, 0) + perp.Unit * s.pr
				end
				local x = math.min(1, (el - s.d) / s.tt)
				local e = x * x
				local pos = s.a * ((1 - e) * (1 - e)) + s.m * (2 * (1 - e) * e) + c * (e * e)
				s.p.CFrame = CFrame.new(pos) * CFrame.Angles(el * s.rs, el * s.rs * 0.7, 0)
				if x >= 1 or (pos - c).Magnitude <= H.r * 0.95 then
					s.done = true
					s.p:Destroy()
					absorbed = absorbed + 1
					if absorbed % 2 == 0 then holeAddChunk(H) end
					if absorbed % 3 == 0 then
						local d = Vector3.new(fr(-1, 1), fr(-1, 1), fr(-1, 1))
						if d.Magnitude > 0.05 then sparks(pos, 5, COL.Gold, 14, 0.5) end
					end
				end
			end
		end
		if el - lastBolt > 0.1 then
			lastBolt = el
			local hnd = S.parts[(math.random() < 0.5) and "HandR" or "HandL"]
			local d = Vector3.new(fr(-1, 1), fr(-1, 0.4), fr(-1, 1))
			if hnd and d.Magnitude > 0.1 then
				bolt(c + d.Unit * H.r, hnd.Position + Vector3.new(0, 1, 0), (math.random() < 0.5) and COL.Gold or COL.White, (0.15 + 0.15 * frac) * 2.5)
			end
		end
		shake(0.15 + 0.6 * frac, 0.12)
		if el - lastRing > 0.55 then
			lastRing = el
			local gp = groundPos() + Vector3.new(0, 0.3, 0)
			ringFx(gp, (10 + 18 * frac) * 3, COL.Gold, 0.9)
			dustBurst(gp, 14, 10, nil, 1.6)
		end
		if absorbed >= N or el > DUR + 4 then break end
		dt = RunService.Heartbeat:Wait()
	end
	for i = 1, N do
		if scraps[i].p then pcall(function() scraps[i].p:Destroy() end) end
	end
	if NX.hole ~= H or not alive(my) then NX.upGoal = 0 return end

	-- ===== 2) NEN CHAM THANH HO DEN =====
	H.mode = "compress"
	playSound(SND_BOOM, 0.7, 0.5)
	local c0 = os.clock()
	local D2 = HC.CompressTime
	local R2 = HC.FinalR
	local r0 = H.r
	local lastConv = 0
	while NX.hole == H and alive(my) do
		local x = math.min(1, (os.clock() - c0) / D2)
		local e = x * x * (3 - 2 * x)
		H.r = r0 + (R2 - r0) * e
		H.heat = e
		H.discA = math.max(0, (x - 0.4) / 0.6)
		H.chunkT = 0.12 * e
		H.chunkK = 1 - 0.65 * e
		H.pos = torso.Position + Vector3.new(0, 8.5 + lerp(r0, R2 * HC.Rise, e), 0)
		shake(0.25 + 1.2 * x, 0.15)
		lastConv = lastConv + dt
		if lastConv > 0.025 then
			lastConv = 0
			local d = Vector3.new(fr(-1, 1), fr(-1, 1), fr(-1, 1))
			if d.Magnitude > 0.05 then
				d = d.Unit * (H.r + fr(40, 120))
				local st = nxPart("Conv", Vector3.new(0.7, 0.7, 7), HC.StreakCols[math.random(#HC.StreakCols)], NEON)
				st.CFrame = CFrame.lookAt(H.pos + d, H.pos)
				tw(st, 0.45, {CFrame = CFrame.lookAt(H.pos, H.pos - d), Transparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				Debris:AddItem(st, 0.5)
			end
		end
		if x >= 1 then break end
		dt = RunService.Heartbeat:Wait()
	end
	if NX.hole ~= H then NX.upGoal = 0 return end
	ringFx(H.pos, 260, HC.GlowCol, 1.2)
	ringFx(H.pos, 160, COL.White, 0.8)
	sparks(H.pos, 80, HC.StreakCols[2], 90, 1.0)
	shake(2.2, 1.0)
	nxFlash(Color3.fromRGB(225, 210, 255), 0.5, 0.6)
	playSound(SND_BOOM, 1, 0.4)

	-- ===== 3) BAY TOI CHO BAM =====
	H.mode = "fly"
	NX.upGoal = 0
	local target = aim + Vector3.new(0, 17 + R2 * HC.Rise, 0)
	local from = H.pos
	local dist = (target - from).Magnitude
	local dur = math.clamp(dist / HOLE_SPEED, 0.7, 4)
	local t2 = os.clock()
	local ghostT = 0
	while NX.hole == H do
		local x = (os.clock() - t2) / dur
		if x >= 1 then break end
		local e = x * x * (3 - 2 * x)
		H.pos = from:Lerp(target, e) + Vector3.new(0, math.sin(x * math.pi) * math.min(dist * 0.12, 26), 0)
		H.r = R2 * (1 + 0.2 * e)
		H.orbit = math.min(1, H.orbit + dt * 1.2)
		H.chunkT = 0.1
		ghostT = ghostT + dt
		if ghostT > 0.05 then
			ghostT = 0
			local gh = nxPart("Ghost", Vector3.new(1, 1, 1) * H.r * 1.8, HC.GlowCol, NEON, BALL)
			gh.Transparency = 0.75
			gh.CFrame = CFrame.new(H.pos)
			tw(gh, 0.45, {Size = Vector3.new(1, 1, 1) * H.r * 0.3, Transparency = 1})
			Debris:AddItem(gh, 0.5)
		end
		dt = RunService.Heartbeat:Wait()
	end
	if NX.hole ~= H then return end
	H.pos = target
	H.r = R2 * 1.2
	H.orbit = 1
	ringFx(target, 200, HC.GlowCol, 1.0)
	ringFx(target, 120, COL.White, 0.7)
	H.mode = "idle"
end

function NX.castHole()
	if NX.realm then NX.guideStart() return end      -- V10.12: x4 trong khong gian = hien chi duong + dem nguoc (khong thoat)
	if NX.busyHole or NX.sucking or S.nuking then return end
	NX.busyHole = true
	local my = S
	task.spawn(function()
		local ok, err = pcall(NX.runHole, my)
		if not ok then warn("[Hulkbuster] Ho den loi:", err) end
		NX.busyHole = false
		NX.upGoal = 0
	end)
end

------------------------------------------------------------------
-- KHONG GIAN KY AO
------------------------------------------------------------------
-- V10.1: cau hinh khong gian ky ao (sua so o day de chinh) -- khong tao local moi (tranh vuot gioi han 200 local)
NX.RLM = {
	Cell = 120,             -- khoang cach giua cac cot (V10.7: 120, truoc 160 van con xa; V10.5: 260 qua thua; V10.4: 144; V10.3: x3, truoc 48)
	ChunkCells = 5,         -- moi chunk = 5x5 o
	WMin = 0.45, WMax = 0.8,  -- be rong cot = Cell x (WMin..WMax) => ~54-96 stud, moi cot mot kich thuoc khac nhau (V10.8: truoc 0.55-0.75)
	Skip = 0,               -- ti le o bo trong: 0 = khong bo o nao (V10.6; V10.5: 0.1)
	Jitter = 1.0,           -- do lech vi tri cot trong o: 1 = lech toi da ca o => cot sap xep ngau nhien, khong thanh hang thang (V10.8: truoc 0.1)
	Rot = 0.5,              -- goc xoay ngau nhien moi cot (rad, +-0.5 ~ 29 do) => khong con canh thang hang; chi ap dung cho cot xa cot chinh (V10.8)
	MinDepth = 140,         -- cot thap nhat cao toi thieu bay nhieu stud tren nen => khong con vung cot thap phang nhin nhu o trong (V10.4: truoc 36)
	MainW = 192,            -- cot chinh = san chinh: rong 192 stud (truoc 64)
	NearR = 600,            -- trong ban kinh nay cot quanh be cao ngang hoac hon san
	NearBlend = 600,        -- vung chuyen tiep sang dia hinh doi nui
	NearLo = 0, NearHi = 150,   -- do cao cot quanh be so voi mat san (>= 0: ngang hoac cao hon san)
	MainGap = 10, MainGapJit = 8, -- khoang ho giua cot chinh va cot quanh (stud) + lech nhe de khong trung mat
	LampGrid = 3,           -- so den diu tren san = LampGrid x LampGrid (phu deu ca san)
	LampRange = 70, LampBright = 0.4, LampH = 16, -- tam den / do sang (thap = vua du) / do cao tren san
	LoadR = 1700,           -- ban kinh sinh cot quanh nguoi choi (x3 truoc 1100) -> vo tan, cot sinh/xoa theo ban
	UnloadR = 2000,         -- xa hon muc nay thi xoa chunk
	InitR = 1200,           -- ban kinh dung san truoc khi hut vao
	Lift = 250,             -- V10.10: khong gian ky ao nam NGAY TREN DAU nguoi choi, cao hon vi tri hien tai bay nhieu stud (truoc: co dinh o toa do 0,7000,0 rat xa); co tran/vat can phia tren thi tu nang them
	HoleSky = 125,          -- V10.11: ho den dich chuyen vao khong gian ky ao va nam tren troi, cao hon be bay nhieu stud (bay/nhay len cham vao la thoat)
	HoleR = 22,             -- ban kinh ho den tren troi
	CollapseTime = 180,     -- V10.12: giay dem nguoc (tinh tu luc bam x4 hien chi duong); het gio ma chua thoat thi khong gian sup do
	TouchPad = 8,           -- cham vao ho den = trong khoang (ban kinh ho + so nay)
	Floor = -300,           -- do sau day vuc so voi san chinh
	Budget = 2,             -- so chunk dung toi da moi frame
	FogStart = 300,         -- bat dau mo dan (nhin ro cot gan va trung binh)
	FogEnd = 1400,          -- chim han vao bong toi
	FogColor = Color3.fromRGB(4, 6, 12),
	Ambient = Color3.fromRGB(68, 76, 100),
	OutdoorAmbient = Color3.fromRGB(62, 72, 98),
	Brightness = 1.2,
	Exposure = 0.3,
	BlackSky = true,        -- tro troi den (sao nhe), khong mat troi/mat trang
}

function NX.spaceEnv(on)
	local R = NX.RLM
	if on then
		if NX.envSaved then return end
		pcall(envRestoreNow)
		local atm = Lighting:FindFirstChildOfClass("Atmosphere")
		NX.envSaved = {
			amb = Lighting.Ambient, out = Lighting.OutdoorAmbient, br = Lighting.Brightness, exp = Lighting.ExposureCompensation,
			fe = Lighting.FogEnd, fs = Lighting.FogStart, fc = Lighting.FogColor, clock = Lighting.ClockTime,
			atm = atm, ad = atm and atm.Density or 0, ah = atm and atm.Haze or 0,
			skies = {},
		}
		pcall(function()
			Lighting.ClockTime = 0
			Lighting.FogColor = R.FogColor
			Lighting.FogStart = R.FogStart
			Lighting.FogEnd = R.FogEnd
			if atm then
				atm.Density = 0
				atm.Haze = 0
			end
			NX.envTw = tw(Lighting, 1.2, {Ambient = R.Ambient, OutdoorAmbient = R.OutdoorAmbient, Brightness = R.Brightness, ExposureCompensation = R.Exposure})
		end)
		-- loc mau lanh, it bao hoa, tuong phan nhe (giong anh)
		pcall(function()
			if NX.realmCC then NX.realmCC:Destroy() end
			local cc = Instance.new("ColorCorrectionEffect")
			cc.Name = "NX_RealmCC"
			cc.Brightness = 0
			cc.Contrast = 0.14
			cc.Saturation = -0.32
			cc.TintColor = Color3.fromRGB(200, 220, 255)
			cc.Parent = Lighting
			NX.realmCC = cc
		end)
		-- troi den tuyen (tam cat bo sky cu cua map, tra lai khi thoat)
		if R.BlackSky then
			pcall(function()
				for _, s in ipairs(Lighting:GetChildren()) do
					if s:IsA("Sky") then
						NX.envSaved.skies[#NX.envSaved.skies + 1] = s
						s.Parent = nil
					end
				end
				local sky = Instance.new("Sky")
				sky.Name = "NX_RealmSky"
				sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt = "", "", ""
				sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = "", "", ""
				sky.CelestialBodiesShown = false
				sky.StarCount = 500
				sky.Parent = Lighting
				NX.realmSky = sky
			end)
		end
	else
		pcall(function() if NX.realmCC then NX.realmCC:Destroy() end NX.realmCC = nil end)
		pcall(function() if NX.realmSky then NX.realmSky:Destroy() end NX.realmSky = nil end)
		local sv = NX.envSaved
		if not sv then return end
		NX.envSaved = nil
		pcall(function() if NX.envTw then NX.envTw:Cancel() end end)
		pcall(function()
			Lighting.Ambient, Lighting.OutdoorAmbient = sv.amb, sv.out
			Lighting.Brightness, Lighting.ExposureCompensation = sv.br, sv.exp
			Lighting.FogEnd, Lighting.FogStart, Lighting.FogColor = sv.fe, sv.fs, sv.fc
			Lighting.ClockTime = sv.clock
			if sv.atm and sv.atm.Parent then
				sv.atm.Density = sv.ad
				sv.atm.Haze = sv.ah
			end
		end)
		for _, s in ipairs(sv.skies or {}) do
			pcall(function() s.Parent = Lighting end)
		end
	end
end

-- tao 1 part cho khong gian ky ao
function NX.realmMk(parent, name, size, cf, color, mat, collide)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = mat
	p.Anchored = true
	p.CanCollide = collide
	p.CanQuery = collide
	p.CanTouch = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

-- sinh 1 chunk rung cot (co dinh theo seed: quay lai van y nguyen)
function NX.realmBuildChunk(cx, cz)
	local chunks = NX.realmChunks
	local parent = NX.realmFolder
	if not (chunks and parent) then return end
	local key = cx .. ":" .. cz
	if chunks[key] then return end
	local R = NX.RLM
	local RC = NX_REALM
	local N = R.ChunkCells
	local cs = R.Cell * N
	local half = (N - 1) / 2
	local seed = NX.realmSeed
	local rng = Random.new((cx * 73856093 + cz * 19349663 + seed * 83492791) % 2147483647)
	local ch = Instance.new("Folder")
	ch.Name = "C" .. key
	local bottomY = RC.Y + R.Floor
	local CONC, SLATE = Enum.Material.Concrete, Enum.Material.Slate
	for i = -half, half do
		for j = -half, half do
			local gx = cx * N + i
			local gz = cz * N + j
			local d = math.sqrt((gx * R.Cell) ^ 2 + (gz * R.Cell) ^ 2)
			-- V10.4: khong bo o nao (Skip = 0) => cot phu kin, khong con cho trong
			local skipP = R.Skip
			if rng:NextNumber() > skipP and not (gx == 0 and gz == 0) then
				local wx = R.Cell * rng:NextNumber(R.WMin, R.WMax)
				local wz = R.Cell * rng:NextNumber(R.WMin, R.WMax)
				local px = RC.X + gx * R.Cell + (R.Cell - wx) * R.Jitter * rng:NextNumber(-1, 1)
				local pz = RC.Z + gz * R.Cell + (R.Cell - wz) * R.Jitter * rng:NextNumber(-1, 1)
				-- khong de cot nao de len cot chinh: cot lan vao vung cam thi DAY RA (khong xoa) cho mep cach be MainGap stud
				do
					local halfM = R.MainW / 2
					local ddx, ddz = px - RC.X, pz - RC.Z
					local gapX = math.abs(ddx) - wx / 2 - halfM
					local gapZ = math.abs(ddz) - wz / 2 - halfM
					if gapX < R.MainGap and gapZ < R.MainGap then
						local gg = R.MainGap + rng:NextNumber(0, R.MainGapJit)
						if gapX >= gapZ then
							px = RC.X + (ddx >= 0 and 1 or -1) * (halfM + gg + wx / 2)
						else
							pz = RC.Z + (ddz >= 0 and 1 or -1) * (halfM + gg + wz / 2)
						end
					end
				end
				do
					-- do cao: quanh cot chinh cao ngang/hon san, xa hon la doi nui mem (noise)
					local macro = math.clamp(math.noise(gx * 0.09 + 0.37, gz * 0.09 + 0.61, seed * 0.0137 + 0.5) * 1.6 + 0.5, 0, 1)
					local t = math.clamp((d - R.NearR) / R.NearBlend, 0, 1)
					t = t * t * (3 - 2 * t)
					local nearTop = RC.Y + rng:NextNumber(R.NearLo, R.NearHi)
					local farTop = RC.Y - 180 + macro * 400 + rng:NextNumber(-90, 90) -- V10.4: cot cao hon + chenh lech tung cot lon => duong chan troi rang cua, khong con mat phang thap
					local topY = math.max(nearTop + (farTop - nearTop) * t, bottomY + R.MinDepth)
					local depth = topY - bottomY
					local v = rng:NextInteger(0, 22)
					local r0, g0, b0 = 62 + v, 74 + v, 90 + v + rng:NextInteger(-4, 6)
					local mat = (rng:NextNumber() < 0.72) and CONC or SLATE
					-- V10.8: xoay ngau nhien (chi cot xa cot chinh, de khong dam vao khe MainGap)
					local rot = 0
					if d > R.MainW + R.Cell * 2 then rot = rng:NextNumber(-R.Rot, R.Rot) end
					NX.realmMk(ch, "Pillar", Vector3.new(wx, depth, wz), CFrame.new(px, topY - depth / 2, pz) * CFrame.Angles(0, rot, 0), Color3.fromRGB(r0, g0, b0), mat, true)
					-- mat tren sang hon + vien nho ra (giong cot trong anh)
					NX.realmMk(ch, "Top", Vector3.new(wx + 4, 3.6, wz + 4), CFrame.new(px, topY + 1.8, pz) * CFrame.Angles(0, rot, 0),
						Color3.fromRGB(math.min(255, r0 + 46), math.min(255, g0 + 50), math.min(255, b0 + 54)), CONC, true)
				end
			end
		end
	end
	-- manh khoi troi lo lung (xoay cham), khong phat sang
	if rng:NextNumber() < 0.25 then
		local sz = rng:NextNumber(18, 54)
		local fx = RC.X + cx * cs + rng:NextNumber(-cs / 2, cs / 2)
		local fz = RC.Z + cz * cs + rng:NextNumber(-cs / 2, cs / 2)
		local fp = NX.realmMk(ch, "Float", Vector3.new(sz, sz * rng:NextNumber(0.4, 1), sz * rng:NextNumber(0.6, 1.2)),
			CFrame.new(fx, RC.Y + rng:NextNumber(170, 460), fz) * CFrame.Angles(rng:NextNumber(0, 6), rng:NextNumber(0, 6), 0),
			Color3.fromRGB(70 + rng:NextInteger(0, 20), 80 + rng:NextInteger(0, 20), 96 + rng:NextInteger(0, 20)), SLATE, false)
		if NX.realmSpin then NX.realmSpin[#NX.realmSpin + 1] = fp end
	end
	chunks[key] = {folder = ch, x = RC.X + cx * cs, z = RC.Z + cz * cs}
	ch.Parent = parent
end

function NX.buildRealm()
	if NX.realmFolder then return end
	local R = NX.RLM
	local RC = NX_REALM
	local folder = Instance.new("Folder")
	folder.Name = "NX_Realm"
	folder.Parent = nxSolid()
	NX.realmFolder = folder
	NX.realmReady = false
	NX.realmSpin = {}
	NX.realmChunks = {}
	NX.realmQueue = {}
	NX.realmSeed = math.random(1, 99999)
	NX.realmT = 0
	local bottomY = RC.Y + R.Floor
	-- nen toi chong roi vo tan: luoi 3x3 tam 2048 di theo nguoi choi
	NX.realmBases = {}
	for bi = -1, 1 do
		for bj = -1, 1 do
			NX.realmBases[#NX.realmBases + 1] = NX.realmMk(folder, "Base", Vector3.new(2048, 4, 2048),
				CFrame.new(RC.X + bi * 2048, bottomY - 2, RC.Z + bj * 2048), Color3.fromRGB(8, 10, 16), Enum.Material.Slate, true)
		end
	end
	NX.realmBX, NX.realmBZ = nil, nil
	-- cot chinh + san chinh: cung kich thuoc (MainW x MainW), san khit tren dinh cot
	local MW = R.MainW
	NX.realmMk(folder, "Plat", Vector3.new(MW, (RC.Y - 4) - bottomY, MW), CFrame.new(RC.X, (RC.Y - 4 + bottomY) / 2, RC.Z),
		Color3.fromRGB(104, 118, 136), Enum.Material.Concrete, true)
	NX.realmMk(folder, "PlatTop", Vector3.new(MW, 4, MW), CFrame.new(RC.X, RC.Y - 2, RC.Z),
		Color3.fromRGB(176, 192, 210), Enum.Material.Concrete, true)
	-- den diu phia tren san: luoi LampGrid x LampGrid, moi den sang nhe => phu deu CA san (ke ca goc/mep), khong chay mat
	local LG = R.LampGrid
	for li = 1, LG do
		for lj = 1, LG do
			local ox = ((li - 0.5) / LG - 0.5) * MW
			local oz = ((lj - 0.5) / LG - 0.5) * MW
			local lamp = NX.realmMk(folder, "PlatLight", Vector3.new(1, 1, 1), CFrame.new(RC.X + ox, RC.Y + R.LampH, RC.Z + oz),
				Color3.fromRGB(190, 210, 255), Enum.Material.SmoothPlastic, false)
			lamp.Transparency = 1
			local pl = Instance.new("PointLight")
			pl.Color = Color3.fromRGB(190, 212, 255)
			pl.Range = R.LampRange
			pl.Brightness = R.LampBright
			pl.Shadows = false
			pl.Parent = lamp
		end
	end
	-- dung san vung quanh be (tu gan ra xa), phan con lai sinh dan khi bay
	local cs = R.Cell * R.ChunkCells
	local rN = math.ceil(R.InitR / cs) + 1
	local list = {}
	for cx = -rN, rN do
		for cz = -rN, rN do
			local dd = math.sqrt(cx * cx + cz * cz) * cs
			if dd <= R.InitR then list[#list + 1] = {cx, cz, dd} end
		end
	end
	table.sort(list, function(a, b) return a[3] < b[3] end)
	for n, c in ipairs(list) do
		if NX.realmFolder ~= folder then return end
		NX.realmBuildChunk(c[1], c[2])
		if n % 3 == 0 then RunService.Heartbeat:Wait() end
	end
	if NX.realmFolder ~= folder then return end
	NX.realmReady = true
end

-- sinh / xoa chunk theo vi tri nguoi choi => khong gian vo tan (goi moi frame trong NX.step)
function NX.realmStream(dt)
	if not (NX.realm and NX.realmReady and NX.realmFolder and NX.realmChunks) then return end
	local root = ownerRoot()
	if not (root and root.Parent) then return end
	local R = NX.RLM
	local RC = NX_REALM
	local pos = root.Position
	-- nen 3x3 di theo nguoi choi (nhay theo luoi 512)
	local bases = NX.realmBases
	if bases then
		local bx = math.floor(pos.X / 512 + 0.5) * 512
		local bz = math.floor(pos.Z / 512 + 0.5) * 512
		if bx ~= NX.realmBX or bz ~= NX.realmBZ then
			NX.realmBX, NX.realmBZ = bx, bz
			local k = 0
			for bi = -1, 1 do
				for bj = -1, 1 do
					k = k + 1
					local b = bases[k]
					if b and b.Parent then b.CFrame = CFrame.new(bx + bi * 2048, b.Position.Y, bz + bj * 2048) end
				end
			end
		end
	end
	-- dung vai chunk trong hang doi moi frame
	local q = NX.realmQueue
	local built = 0
	while q and built < R.Budget and #q > 0 do
		local c = table.remove(q, 1)
		NX.realmBuildChunk(c[1], c[2])
		built = built + 1
	end
	-- 5 lan/giay: lap lai hang doi + don chunk xa
	NX.realmT = (NX.realmT or 0) + dt
	if NX.realmT < 0.2 then return end
	NX.realmT = 0
	local cs = R.Cell * R.ChunkCells
	local pcx = math.floor((pos.X - RC.X) / cs + 0.5)
	local pcz = math.floor((pos.Z - RC.Z) / cs + 0.5)
	local rN = math.ceil(R.LoadR / cs)
	local nq = {}
	for cx = pcx - rN, pcx + rN do
		for cz = pcz - rN, pcz + rN do
			local dx = RC.X + cx * cs - pos.X
			local dz = RC.Z + cz * cs - pos.Z
			local dd = math.sqrt(dx * dx + dz * dz)
			if dd <= R.LoadR and not NX.realmChunks[cx .. ":" .. cz] then
				nq[#nq + 1] = {cx, cz, dd}
			end
		end
	end
	table.sort(nq, function(a, b) return a[3] < b[3] end)
	NX.realmQueue = nq
	local removed = false
	for key, ch in pairs(NX.realmChunks) do
		local dx = ch.x - pos.X
		local dz = ch.z - pos.Z
		if math.sqrt(dx * dx + dz * dz) > R.UnloadR then
			pcall(function() ch.folder:Destroy() end)
			NX.realmChunks[key] = nil
			removed = true
		end
	end
	if removed and NX.realmSpin then
		local ns = {}
		for _, p in ipairs(NX.realmSpin) do
			if p:IsDescendantOf(NX.realmFolder) then ns[#ns + 1] = p end
		end
		NX.realmSpin = ns
	end
end

function NX.destroyRealm()
	if NX.realmFolder then
		pcall(function() NX.realmFolder:Destroy() end)
		NX.realmFolder = nil
	end
	NX.realmReady = false
	NX.realmSpin = nil
	NX.realmChunks = nil
	NX.realmQueue = nil
	NX.realmBases = nil
	NX.realmBX, NX.realmBZ = nil, nil
end

-- V10.10: dat tam khong gian ky ao ngay tren dau nguoi choi (goi truoc khi dung realm)
function NX.placeRealm(p)
	local lift = NX.RLM.Lift
	pcall(function()
		local res = Workspace:Raycast(p, Vector3.new(0, 4000, 0), rayParams())
		if res then lift = math.max(lift, (res.Position.Y - p.Y) + 380) end   -- co tran/nha cao phia tren: nang len de day realm khong cam vao
	end)
	NX_REALM = Vector3.new(p.X, p.Y + lift, p.Z)
end

-- V10.11: HO TRANG - noi nguoi choi thoat ra khoi khong gian ky ao: no bung to, phun anh sang, roi tan dan va bien mat
function NX.whiteHole(pos)
	task.spawn(function()
		local R0 = 11
		local gen = NX.whiteGen or 0
		local W = Color3.new(1, 1, 1)
		local core = nxPart("WhiteCore", Vector3.one * 2, W, NEON, BALL)
		local sh1 = nxPart("WhiteShell", Vector3.one * 3, Color3.fromRGB(205, 235, 255), NEON, BALL)
		sh1.Transparency = 0.55
		local sh2 = nxPart("WhiteShell2", Vector3.one * 4, Color3.fromRGB(150, 205, 255), NEON, BALL)
		sh2.Transparency = 0.8
		local disc = nxPart("WhiteDisc", Vector3.new(0.2, 4, 4), Color3.fromRGB(235, 248, 255), NEON, CYL)
		disc.Transparency = 0.5
		local em = nxPart("WhiteEm", Vector3.one * 2, W, NEON, BALL)
		em.Transparency = 1
		local lt = Instance.new("PointLight")
		lt.Color = Color3.fromRGB(225, 240, 255)
		lt.Range = 60
		lt.Brightness = 8
		lt.Shadows = false
		lt.Parent = core
		local okE, pe = pcall(mkEmitter, em, {
			light = 1, life = NumberRange.new(0.6, 1.2), speed = NumberRange.new(26, 55), rate = 0,
			color = ColorSequence.new({ColorSequenceKeypoint.new(0, W), ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 200, 255))}),
			size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2.2), NumberSequenceKeypoint.new(1, 0)}),
			transp = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1)}),
			shape = Enum.ParticleEmitterShape.Sphere,
		})
		pcall(playSound, SND_PING, 0.8, 1.5)
		if okE then pe:Emit(45) end
		ringFx(pos, 70, W, 0.8)
		ringFx(pos, 110, Color3.fromRGB(170, 215, 255), 1.1)

		local T_IN, T_HOLD, T_OUT = 0.45, 2.2, 5.5      -- bung ra / giu nguyen / tan dan roi bien mat
		local t0 = os.clock()
		local nextRing, nextStreak = 0.5, 0
		pcall(function()
			while core.Parent and (NX.whiteGen or 0) == gen do
				local t = os.clock() - t0
				if t >= T_IN + T_HOLD + T_OUT then break end
				local k, u = 1, 0
				if t < T_IN then
					local x = t / T_IN
					k = 1 - (1 - x) ^ 3
				elseif t < T_IN + T_HOLD then
					k = 1
				else
					u = (t - T_IN - T_HOLD) / T_OUT
					k = (1 - u) ^ 1.6
				end
				local r = R0 * k * (1 + 0.05 * math.sin(t * 9))
				core.Size = Vector3.one * math.max(0.2, r * 0.9)
				sh1.Size = Vector3.one * math.max(0.3, r * 1.25)
				sh2.Size = Vector3.one * math.max(0.4, r * 1.9)
				sh1.Transparency = 0.55 + 0.45 * u
				sh2.Transparency = 0.8 + 0.2 * u
				local cf = CFrame.new(pos)
				core.CFrame, sh1.CFrame, sh2.CFrame, em.CFrame = cf, cf, cf, cf
				local cam = Workspace.CurrentCamera
				local cp = cam and cam.CFrame.Position or (pos + Vector3.new(0, 0, 50))
				if (cp - pos).Magnitude < 1 then cp = pos + Vector3.new(0, 0, 1) end
				disc.Size = Vector3.new(0.2, math.max(0.4, r * 3.2), math.max(0.4, r * 3.2))
				disc.CFrame = CFrame.lookAt(pos, cp) * CFrame.Angles(0, math.pi / 2, 0)
				disc.Transparency = 0.5 + 0.5 * u
				lt.Brightness = 8 * k
				lt.Range = 20 + 40 * k
				if okE then pe.Rate = (t < T_IN + T_HOLD) and 60 * k or 40 * (1 - u) end
				if t >= nextRing and u < 0.7 then
					nextRing = t + 0.55
					ringFx(pos, r * 5, t % 1.1 < 0.55 and W or Color3.fromRGB(170, 215, 255), 0.8)
				end
				if t >= nextStreak and k > 0.05 then
					nextStreak = t + 0.05
					local a = Vector3.new(fr(-1, 1), fr(-1, 1), fr(-1, 1))
					if a.Magnitude < 0.1 then a = Vector3.yAxis end
					a = a.Unit
					local p0 = pos + a * r * 1.1
					local p1 = pos + a * (r * 1.1 + fr(14, 34))
					local st = nxPart("WPush", Vector3.new(0.2, 0.2, 3), math.random() < 0.5 and W or Color3.fromRGB(190, 225, 255), NEON)
					st.CFrame = CFrame.lookAt(p0, p0 + a)
					tw(st, 0.5, {CFrame = CFrame.lookAt(p1, p1 + a), Transparency = 1, Size = Vector3.new(0.05, 0.05, 0.5)}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					Debris:AddItem(st, 0.6)
				end
				RunService.Heartbeat:Wait()
			end
		end)
		-- bien mat: no mot dot hat sang cuoi roi xoa
		if okE then
			pcall(function()
				pe.Rate = 0
				pe:Emit(40)
			end)
		end
		pcall(function() core.Transparency, sh1.Transparency, sh2.Transparency, disc.Transparency = 1, 1, 1, 1 end)
		for _, p in ipairs({core, sh1, sh2, disc, em}) do Debris:AddItem(p, 1.5) end
	end)
end

function NX.enterRealmNow(H)
	pcall(NX.guideStop)
	NX.collapsing = false
	NX.spaceEnv(true)
	NX.realm = true
	NX.realmT0 = os.clock()
	nxPlace(NX_REALM + Vector3.new(0, 7, 0), CFrame.Angles(0, math.rad(math.random(0, 359)), 0))
	-- V10.11: ho den dich chuyen THEO vao khong gian ky ao va nam tren troi; cham vao ho den = thoat ra qua ho trang
	if H and NX.hole == H and not H.dying then
		local RL = NX.RLM
		H.pos = NX_REALM + Vector3.new(0, RL.HoleSky, 0)
		H.r = RL.HoleR
		H.orbit = 1
		H.mode = "idle"
		ringFx(H.pos, 160, NX.HOLE.GlowCol, 1.2)
		ringFx(H.pos, 90, COL.White, 0.8)
	end
end

function NX.exitRealm()
	if not NX.realm or NX.exiting or NX.collapsing then return end
	NX.exiting = true
	pcall(NX.guideStop)
	task.spawn(function()
		pcall(function()
			nxFlash(Color3.fromRGB(235, 245, 255), 1, 0.9)
			task.wait(0.35)
			local rp = NX.returnPos
			NX.realm = false
			NX.spaceEnv(false)
			NX.destroyRealm()
			NX.killHole(true)
			if rp then
				-- thoat ra tu HO TRANG ngay cho luc truoc (hut vao), bi phun ra phia truoc
				local rot = NX.returnRot or CFrame.new()
				local C = rp + Vector3.new(0, 8, 0)
				nxPlace(C, rot)
				NX.whiteHole(C)
				if not S.drone then
					local v = rot.LookVector * 42 + Vector3.new(0, 10, 0)
					if S.ctrl then
						S.fvel = v
					else
						local r2 = ownerRoot()
						if r2 then r2.AssemblyLinearVelocity = v end
					end
				end
			end
		end)
		NX.realm = false
		NX.exiting = false
	end)
end

------------------------------------------------------------------
-- V10.12: CHI DUONG THOAT + DEM NGUOC 180s + KHONG GIAN SUP DO
------------------------------------------------------------------
function NX.guideStop()
	local G = NX.guide
	NX.guide = nil
	if not G then return end
	pcall(function() if G.gui then G.gui:Destroy() end end)
	for _, p in ipairs(G.dots or {}) do pcall(function() p:Destroy() end) end
end

-- bam Tool1 x4 trong khong gian ky ao: KHONG thoat, ma hien chi duong toi ho den + dem nguoc
function NX.guideStart()
	if not NX.realm or NX.exiting or NX.collapsing then return end
	if NX.guide then
		pcall(playSound, SND_PING, 0.5, 1.2)
		return
	end
	local pg = player:FindFirstChildOfClass("PlayerGui")
	if not pg then return end
	local G = {mode = "exit", t0 = os.clock(), dots = {}}
	NX.guide = G
	local gui = Instance.new("ScreenGui")
	gui.Name = "NX_Guide"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 800
	local function lab(parent, y, h, size, col, txt)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Size = UDim2.new(1, 0, 0, h)
		l.Position = UDim2.new(0, 0, 0, y)
		l.Font = Enum.Font.SourceSansBold
		l.TextSize = size
		l.TextColor3 = col
		l.Text = txt
		l.Parent = parent
		return l
	end
	local box = Instance.new("Frame")
	box.AnchorPoint = Vector2.new(0.5, 0)
	box.Position = UDim2.new(0.5, 0, 0, 14)
	box.Size = UDim2.fromOffset(300, 98)
	box.BackgroundColor3 = Color3.fromRGB(8, 12, 26)
	box.BackgroundTransparency = 0.2
	box.BorderSizePixel = 0
	box.Parent = gui
	local uc = Instance.new("UICorner")
	uc.CornerRadius = UDim.new(0, 12)
	uc.Parent = box
	local us = Instance.new("UIStroke")
	us.Color = Color3.fromRGB(120, 190, 255)
	us.Thickness = 2
	us.Transparency = 0.25
	us.Parent = box
	G.stroke = us
	G.title = lab(box, 6, 22, 19, Color3.fromRGB(170, 215, 255), "KHÔNG GIAN SỤP ĐỔ SAU")
	G.time = lab(box, 28, 42, 42, Color3.new(1, 1, 1), "03:00")
	G.info = lab(box, 74, 20, 17, Color3.fromRGB(200, 225, 255), "Bay lên chạm hố đen để thoát")
	-- dau chi huong + khoang cach tren man hinh
	local mk = Instance.new("TextLabel")
	mk.AnchorPoint = Vector2.new(0.5, 0.5)
	mk.Size = UDim2.fromOffset(44, 44)
	mk.BackgroundTransparency = 1
	mk.Font = Enum.Font.SourceSansBold
	mk.TextSize = 34
	mk.TextColor3 = Color3.fromRGB(120, 230, 255)
	mk.TextStrokeTransparency = 0.4
	mk.Text = "◆"
	mk.Parent = gui
	local md = Instance.new("TextLabel")
	md.AnchorPoint = Vector2.new(0.5, 0.5)
	md.Size = UDim2.fromOffset(120, 20)
	md.BackgroundTransparency = 1
	md.Font = Enum.Font.SourceSansBold
	md.TextSize = 18
	md.TextColor3 = Color3.fromRGB(200, 240, 255)
	md.TextStrokeTransparency = 0.4
	md.Text = ""
	md.Parent = gui
	G.gui, G.mk, G.md = gui, mk, md
	gui.Parent = pg
	-- duong cham sang chay ve phia dich (chi duong 3D)
	for i = 1, 14 do
		local d = nxPart("GuideDot", Vector3.new(0.9, 0.9, 2.4), Color3.fromRGB(120, 230, 255), NEON)
		d.Transparency = 1
		G.dots[i] = d
	end
	pcall(playSound, SND_PING, 0.7, 0.9)
end

function NX.guideStep(dt)
	local G = NX.guide
	if not G then return end
	local now = os.clock()
	if G.done then
		if now - G.done > 1.6 then NX.guideStop() end
		return
	end
	local root = ownerRoot()
	if not (root and root.Parent) then return end
	local from = root.Position
	-- muc tieu: ho den tren troi (luc con khong gian) / cho cu truoc khi bi hut (luc khong gian da sup)
	local target
	if G.mode == "exit" then
		local H = NX.hole
		target = (H and not H.dying) and H.pos or (NX_REALM + Vector3.new(0, NX.RLM.HoleSky, 0))
	else
		target = NX.returnPos
	end
	if not target then NX.guideStop() return end
	local v = target - from
	local dist = v.Magnitude

	if G.mode == "exit" then
		local remain = NX.RLM.CollapseTime - (now - G.t0)
		if remain <= 0 then
			NX.collapseRealm()
			return
		end
		local m = math.ceil(remain)
		G.time.Text = string.format("%02d:%02d", m // 60, m % 60)
		local danger = remain < 30
		G.time.TextColor3 = danger and Color3.fromRGB(255, 100, 100) or Color3.new(1, 1, 1)
		G.stroke.Color = danger and Color3.fromRGB(255, 110, 110) or Color3.fromRGB(120, 190, 255)
		if danger then G.time.TextTransparency = 0.15 + 0.15 * math.sin(now * 8) end
	else
		G.title.Text = NX.collapsing and "KHÔNG GIAN ĐANG SỤP ĐỔ!" or "QUAY VỀ CHỖ CŨ"
		G.time.TextSize = 34
		G.time.TextTransparency = 0
		G.time.Text = math.floor(dist) .. " stud"
		G.time.TextColor3 = Color3.fromRGB(255, 220, 140)
		G.info.Text = NX.collapsing and "Hố đen đã biến mất — chạy theo dấu về chỗ cũ" or "Đi theo dấu để về chỗ trước khi bị hút"
		G.stroke.Color = Color3.fromRGB(255, 200, 120)
		if not NX.collapsing and dist < 14 then
			-- ve toi noi: tu tat chi duong
			G.done = now
			G.title.Text = "ĐÃ VỀ ĐÚNG CHỖ"
			G.time.Text = "✔"
			G.time.TextTransparency = 0
			G.info.Text = "Chỉ đường đã tắt"
			G.mk.Visible, G.md.Visible = false, false
			for _, d in ipairs(G.dots) do d.Transparency = 1 end
			pcall(playSound, SND_PING, 0.8, 1.4)
			return
		end
	end

	-- dau chi huong tren man hinh
	local cam = Workspace.CurrentCamera
	if cam then
		local vp = cam.ViewportSize
		local sp, onScr = cam:WorldToViewportPoint(target)
		local mk, md = G.mk, G.md
		local px, py
		if onScr and sp.Z > 0 and sp.X > 30 and sp.X < vp.X - 30 and sp.Y > 120 and sp.Y < vp.Y - 30 then
			mk.Text = "◆"
			mk.Rotation = 0
			px, py = sp.X, sp.Y
		else
			local rel = cam.CFrame:PointToObjectSpace(target)
			local d2 = Vector2.new(rel.X, -rel.Y)
			if d2.Magnitude < 0.001 then d2 = Vector2.new(0, 1) end
			d2 = d2.Unit
			local mx, my = vp.X / 2 - 50, vp.Y / 2 - 90
			local sc = math.min(mx / math.max(math.abs(d2.X), 1e-4), my / math.max(math.abs(d2.Y), 1e-4))
			mk.Text = "▶"
			mk.Rotation = math.deg(math.atan2(d2.Y, d2.X))
			px, py = vp.X / 2 + d2.X * sc, vp.Y / 2 + d2.Y * sc
		end
		mk.Position = UDim2.fromOffset(px, py)
		mk.TextTransparency = 0.05 + 0.25 * (0.5 + 0.5 * math.sin(now * 6))
		md.Position = UDim2.fromOffset(px, py + 28)
		md.Text = math.floor(dist) .. " stud"
	end

	-- duong cham sang 3D: tu nguoi choi chay ve phia dich
	local N = #G.dots
	if dist > 8 then
		local dir = v.Unit
		local reach = math.min(dist - 3, 130)
		local phase = (now * 0.9) % 1
		for i = 1, N do
			local f = ((i - 1) + phase) / N
			local pp = from + dir * (6 + f * (reach - 6))
			local d = G.dots[i]
			d.CFrame = CFrame.lookAt(pp, pp + dir)
			d.Transparency = 0.1 + 0.8 * f * f
			local sz = 0.7 + 0.5 * math.sin(f * math.pi)
			d.Size = Vector3.new(sz, sz, 2.4)
		end
	else
		for i = 1, N do G.dots[i].Transparency = 1 end
	end
end

-- vet nut sang tren bau troi toi (truoc luc bau troi vo)
function NX.skyCrack(cp)
	local d = Vector3.new(fr(-1, 1), fr(0.1, 1), fr(-1, 1))
	if d.Magnitude < 0.1 then d = Vector3.yAxis end
	d = d.Unit
	local side = d:Cross(Vector3.yAxis)
	if side.Magnitude < 0.1 then side = Vector3.xAxis end
	side = side.Unit
	local dirv = CFrame.fromAxisAngle(d, fr(0, 6.28)):VectorToWorldSpace(side)
	local pos = cp + d * 700
	local len = fr(140, 380)
	local col = Color3.fromRGB(215, 235, 255)
	local function seg(p, dv, l, w)
		local s = nxPart("SkyCrack", Vector3.new(w, w, l), col, NEON)
		s.CFrame = CFrame.lookAt(p, p + dv)
		tw(s, 1.1, {Transparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		Debris:AddItem(s, 1.2)
	end
	seg(pos, dirv, len, 2.4)
	for _ = 1, 2 do
		local sgn = math.random() < 0.5 and -1 or 1
		local tip = pos + dirv * (len * 0.5 * fr(0.2, 1))
		local bd = CFrame.fromAxisAngle(d, sgn * fr(0.5, 1.0)):VectorToWorldSpace(dirv)
		local bl = len * fr(0.25, 0.5)
		seg(tip + bd * (bl / 2), bd, bl, 1.4)
	end
end

-- het gio: khong gian vo vun, bau troi toi vo ra tra ve nhu cu, ho den/ho trang tan bien, chi duong ve cho cu
function NX.collapseRealm()
	if NX.collapsing or not NX.realm or NX.exiting then return end
	NX.collapsing = true
	local G = NX.guide
	if G then G.mode = "return" end
	task.spawn(function()
		local ok, err = pcall(NX.collapseRun)
		if not ok then warn("[Hulkbuster] Sup do loi:", err) end
		if NX.collapsing then
			NX.realm = false
			pcall(NX.spaceEnv, false)
			pcall(NX.destroyRealm)
		end
		NX.collapsing = false
	end)
end

function NX.collapseRun()
	local folder = NX.realmFolder
	if not folder then return end
	local RC = NX_REALM
	local CT0, CT1, TOTAL, SHATTER = 0.8, 9.5, 11.5, 2.8
	NX.killHole(true)
	NX.whiteGen = (NX.whiteGen or 0) + 1      -- ho trang (neu con) cung tan bien
	pcall(playSound, SND_BOOM, 0.9, 0.35)
	shake(1.2, 2)

	-- gom cac manh cua khong gian, xep thu tu vo: xa be vo truoc, san chinh vo cuoi cung
	local list, dmax = {}, 1
	for _, p in ipairs(folder:GetDescendants()) do
		if p:IsA("BasePart") then
			local dd = Vector2.new(p.Position.X - RC.X, p.Position.Z - RC.Z).Magnitude
			list[#list + 1] = {p = p, dd = dd}
			if dd > dmax and p.Name ~= "Base" then dmax = dd end
		end
	end
	for _, e in ipairs(list) do
		local n = e.p.Name
		local f, rs = 0, 1
		e.life = fr(0.7, 1.3)
		if n == "Plat" or n == "PlatTop" or n == "PlatLight" then
			f = 1
			e.life = 1.5
			rs = 0.3
		elseif n == "Base" then
			f = 0.45 + 0.2 * math.random()
			e.life = 2.2
			rs = 0.12
		else
			f = 0.65 * (1 - math.min(1, e.dd / dmax)) + 0.35 * math.random()
		end
		e.ct = CT0 + (CT1 - CT0) * f
		e.cf = e.p.CFrame
		e.p0 = e.p.Transparency
		e.rx, e.ry, e.rz = fr(-1.2, 1.2) * rs, fr(-1.2, 1.2) * rs, fr(-1.2, 1.2) * rs
		e.big = e.p.Size.Magnitude > 30
		e.fallD = (n == "Base") and 160 or 70
	end
	table.sort(list, function(a, b) return a.ct < b.ct end)

	-- bui do vo (vai emitter dung chung, khong tao hang tram hat)
	local pool, pi = {}, 0
	for i = 1, 6 do
		local hp = nxPart("CrumbleEm", Vector3.one, Color3.fromRGB(120, 120, 130), NEON, BALL)
		hp.Transparency = 1
		local okp, em = pcall(mkEmitter, hp, {
			life = NumberRange.new(1.2, 2.2), speed = NumberRange.new(10, 40), rate = 0, drag = 1.5,
			color = ColorSequence.new(Color3.fromRGB(150, 160, 180), Color3.fromRGB(60, 64, 76)),
			size = NumberSequence.new({NumberSequenceKeypoint.new(0, 6), NumberSequenceKeypoint.new(1, 18)}),
			transp = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1)}),
			shape = Enum.ParticleEmitterShape.Sphere,
		})
		pool[i] = {hp = hp, em = okp and em or nil}
	end

	local t0 = os.clock()
	local nxt, active, shards = 1, {}, {}
	local nextCrack, nextShake, shattered = 0, 0, false
	local nextRay, noGroundT0 = 0, nil
	while NX.collapsing do
		local t = os.clock() - t0
		if t >= TOTAL then break end
		local cam = Workspace.CurrentCamera
		local cp = cam and cam.CFrame.Position or RC

		-- V10.13: khong gian dang vo ma duoi chan khong con dat -> giap tu cuu
		if CFG.Rescue and not NX.rescuing and t >= nextRay then
			nextRay = t + 0.08
			local ch = player.Character
			local ro = ownerRoot() or (ch and ch:FindFirstChild("HumanoidRootPart"))
			if ro and ro.Parent and not (S.on and not S.drone and S.ctrl == "fly") then
				local rp2 = RaycastParams.new()
				rp2.FilterType = Enum.RaycastFilterType.Exclude
				local fl2 = {FX}
				if ch then fl2[#fl2 + 1] = ch end
				if S.char then fl2[#fl2 + 1] = S.char end
				if S.armor then fl2[#fl2 + 1] = S.armor end
				rp2.FilterDescendantsInstances = fl2
				if Workspace:Raycast(ro.Position, Vector3.new(0, -CFG.RescueRay, 0), rp2) then
					noGroundT0 = nil
				else
					noGroundT0 = noGroundT0 or t
					if t - noGroundT0 >= CFG.RescueFallTime then
						noGroundT0 = nil
						task.spawn(NX.rescueFall)
					end
				end
			else
				noGroundT0 = nil
			end
		end
		-- rung tang dan
		if t >= nextShake then
			nextShake = t + 0.25
			shake(0.5 + 1.8 * math.min(1, t / CT1), 0.3)
		end
		-- vet nut sang tren bau troi + chop man hinh
		if not shattered and t >= nextCrack then
			nextCrack = t + math.max(0.12, 0.4 - 0.1 * t)
			NX.skyCrack(cp)
			local cc = NX.realmCC
			if cc then
				cc.Brightness = 0.15
				task.delay(0.06, function() if NX.realmCC == cc then cc.Brightness = 0 end end)
			end
		end
		-- bau troi toi VO RA, anh sang tra ve nhu cu
		if not shattered and t >= SHATTER then
			shattered = true
			for i = 1, 72 do
				local d = Vector3.new(fr(-1, 1), fr(-0.05, 1), fr(-1, 1))
				if d.Magnitude < 0.1 then d = Vector3.yAxis end
				d = d.Unit
				local sz = fr(190, 320)
				local sp = nxPart("SkyShard", Vector3.new(sz, sz * fr(0.7, 1.2), 3), Color3.fromRGB(4, 5, 12), SMOOTH)
				local cf = CFrame.lookAt(cp + d * 820, cp) * CFrame.Angles(0, 0, fr(0, 6.28))
				sp.CFrame = cf
				shards[i] = {p = sp, d = d, cf = cf, delay = fr(0, 0.9), dur = fr(2.2, 3.4), rx = fr(-1.5, 1.5), ry = fr(-1.5, 1.5)}
			end
			NX.spaceEnv(false)
			nxFlash(Color3.fromRGB(235, 245, 255), 0.7, 0.8)
			pcall(playSound, SND_BOOM, 1.2, 0.7)
			shake(3, 1.2)
		end
		if shattered then
			for i = #shards, 1, -1 do
				local s = shards[i]
				local u = (t - SHATTER - s.delay) / s.dur
				if u >= 1 then
					pcall(function() s.p:Destroy() end)
					table.remove(shards, i)
				elseif u > 0 then
					s.p.CFrame = CFrame.new(s.d * (u * 80) + Vector3.new(0, -u * u * 600, 0)) * s.cf * CFrame.Angles(u * s.rx, u * s.ry, 0)
					s.p.Transparency = u * u
				end
			end
		end

		-- cac manh khong gian lan luot vo
		local emits = 0
		while nxt <= #list and list[nxt].ct <= t do
			local e = list[nxt]
			nxt += 1
			if e.p.Parent then
				e.p.CanCollide = false
				e.p.CanQuery = false
				active[#active + 1] = e
				if e.big and emits < 2 and (e.p.Position - cp).Magnitude < 500 then
					emits += 1
					pi = pi % #pool + 1
					local pe = pool[pi]
					pe.hp.CFrame = CFrame.new(e.p.Position)
					if pe.em then pe.em:Emit(6) end
				end
			end
		end
		for i = #active, 1, -1 do
			local e = active[i]
			local u = (t - e.ct) / e.life
			if u >= 1 or not e.p.Parent then
				pcall(function() e.p:Destroy() end)
				table.remove(active, i)
			else
				e.p.CFrame = CFrame.new(0, -u * u * e.fallD, 0) * e.cf * CFrame.Angles(u * e.rx, u * e.ry, u * e.rz)
				e.p.Transparency = math.max(e.p0, u ^ 1.6)
			end
		end
		RunService.Heartbeat:Wait()
	end

	for _, s in ipairs(shards) do pcall(function() s.p:Destroy() end) end
	for _, e in ipairs(active) do pcall(function() e.p:Destroy() end) end
	if not NX.collapsing then return end       -- bi cleanup giua chung
	NX.realm = false
	NX.spaceEnv(false)
	NX.destroyRealm()
	-- an toan: neu ben duoi khong co dat (realm o ngoai ria map) thi dua ve cho cu cho khoi roi xuong vuc
	local root = ownerRoot()
	if root and NX.returnPos then
		local res = Workspace:Raycast(root.Position, Vector3.new(0, -3000, 0), rayParams())
		if not res and not NX.rescuing and not (S.on and not S.drone and S.ctrl == "fly") then
			nxFlash(Color3.fromRGB(235, 245, 255), 1, 0.9)
			nxPlace(NX.returnPos + Vector3.new(0, 3, 0), NX.returnRot)
			NX.guideStop()
		end
	end
end

function NX.suck(H)
	if NX.sucking then return end
	NX.sucking = true
	local my = S
	task.spawn(function()
		local hum = ownerHum()
		local prevPS = hum and hum.PlatformStand
		local ok, err = pcall(function()
			local root = ownerRoot()
			if not root then return end
			NX.returnPos = root.Position
			if not NX.realmFolder and not NX.realm then NX.placeRealm(root.Position) end
			local fl = nxFlat(root.CFrame.LookVector) or Vector3.new(0, 0, -1)
			NX.returnRot = CFrame.lookAt(Vector3.zero, fl).Rotation
			if hum then hum.PlatformStand = true end
			task.spawn(function()
				local okb, eb = pcall(NX.buildRealm)
				if not okb then warn("[Hulkbuster] Realm loi:", eb) NX.realmReady = true end
			end)
			playSound(SND_BOOM, 0.8, 0.4)
			local t0 = os.clock()
			local spin = 0
			local DUR = NX.HOLE.SuckTime
			while os.clock() - t0 < DUR do
				local r2 = ownerRoot()
				if not (r2 and r2.Parent) or H.dying or NX.hole ~= H or S ~= my then break end
				local x = (os.clock() - t0) / DUR
				local pos = r2.Position:Lerp(H.pos, math.min(1, x * x * 0.35 + 0.03 + x * 0.06))
				spin = spin + 0.35 + x * 1.4
				nxPlace(pos, CFrame.Angles(spin * 0.7, spin, spin * 0.4))
				shake(0.25 + x * 0.7, 0.1)
				if (pos - H.pos).Magnitude < 5 then break end
				RunService.Heartbeat:Wait()
			end
			if S ~= my or NX.hole ~= H then return end
			nxFlash(Color3.fromRGB(8, 8, 16), 1, 1.0)
			task.wait(0.3)
			local w0 = os.clock()
			while not NX.realmReady and os.clock() - w0 < 12 do task.wait(0.05) end
			if S ~= my or not S.on then return end
			NX.enterRealmNow(H)
			task.wait(0.2)
		end)
		if not ok then warn("[Hulkbuster] Hut ho den loi:", err) end
		pcall(function() if hum then hum.PlatformStand = prevPS and true or false end end)
		NX.sucking = false
	end)
end

------------------------------------------------------------------
-- CAU NANO
------------------------------------------------------------------
function NX.backpack(pos)
	local list = {}
	local function bp(name, size, rel, color, mat, shape)
		local p = nxPart(name, size, color, mat, shape)
		p.Transparency = 1
		list[#list + 1] = {p = p, rel = rel, size = size}
		return p
	end
	bp("BpBody", Vector3.new(5, 6.5, 2.4), CFrame.new(0, 0, 0), Color3.fromRGB(70, 74, 84), METAL)
	bp("BpTop", Vector3.new(5.2, 1.3, 2.6), CFrame.new(0, 3.4, 0), COL.Red, SMOOTH)
	bp("BpTrim", Vector3.new(5.3, 0.3, 2.7), CFrame.new(0, 2.7, 0), COL.Gold, METAL)
	bp("BpPocket", Vector3.new(3.6, 2.4, 0.9), CFrame.new(0, -1.3, 1.5), COL.DarkRed, SMOOTH)
	bp("BpStrapL", Vector3.new(0.7, 6.4, 0.45), CFrame.new(-1.7, 0, -1.4), Color3.fromRGB(30, 30, 34), METAL)
	bp("BpStrapR", Vector3.new(0.7, 6.4, 0.45), CFrame.new(1.7, 0, -1.4), Color3.fromRGB(30, 30, 34), METAL)
	bp("BpCore", Vector3.new(1.7, 1.7, 0.3), CFrame.new(0, 0.7, 1.35), COL.Glow, NEON)
	for _, sd in ipairs({-1, 1}) do
		bp("BpThr", Vector3.new(1.4, 1.8, 1.8), CFrame.new(sd * 1.4, -4.0, 0) * CFrame.Angles(0, 0, math.pi / 2), Color3.fromRGB(40, 42, 50), METAL, CYL)
		bp("BpNoz", Vector3.new(0.25, 1.5, 1.5), CFrame.new(sd * 1.4, -4.9, 0) * CFrame.Angles(0, 0, math.pi / 2), Color3.fromRGB(255, 140, 40), NEON, CYL)
	end
	local function place(s, pc, yawA)
		local b = CFrame.new(pc) * CFrame.Angles(0, yawA, 0)
		for _, it in ipairs(list) do
			it.p.Size = it.size * math.max(s, 0.02)
			it.p.CFrame = b * (CFrame.new(it.rel.Position * s) * it.rel.Rotation)
		end
	end
	-- 1) cac hat nano ghep lai thanh balo
	local t0 = os.clock()
	while os.clock() - t0 < 0.6 do
		local x = (os.clock() - t0) / 0.6
		for _, it in ipairs(list) do it.p.Transparency = math.max(0, 1 - x * 2) end
		place(x * x * (3 - 2 * x), pos, x * 6)
		RunService.Heartbeat:Wait()
	end
	ringFx(pos, 20, COL.Glow, 0.6)
	sparks(pos, 20, COL.Gold, 10, 0.6)
	playSound(SND_PING, 0.8, 0.8)
	-- 2) lo lung xoay
	local t1 = os.clock()
	while os.clock() - t1 < 1.0 do
		local el = os.clock() - t1
		place(1, pos + Vector3.new(0, math.sin(el * 4) * 0.4, 0), 6 + el * 1.5)
		RunService.Heartbeat:Wait()
	end
	-- 3) phun lua bay len vu tru
	local flames = {}
	for _, sd in ipairs({-1, 1}) do
		local fa = nxPart("BpFlame", Vector3.new(0.5, 0.5, 0.5), COL.Glow, NEON)
		fa.Transparency = 1
		local okE, em = pcall(mkEmitter, fa, {
			tex = FIRE_TEX, light = 1, rate = 120, spread = Vector2.new(6, 6),
			color = ColorSequence.new(Color3.fromRGB(180, 245, 255), Color3.fromRGB(255, 140, 40)),
			size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2.2), NumberSequenceKeypoint.new(1, 0)}),
			life = NumberRange.new(0.3, 0.6), speed = NumberRange.new(14, 24),
			transp = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}),
		})
		if okE then em.EmissionDirection = Enum.NormalId.Bottom end
		flames[#flames + 1] = {a = fa, sd = sd}
	end
	local fl = Instance.new("PointLight")
	fl.Color = Color3.fromRGB(150, 220, 255)
	fl.Range = 40
	fl.Brightness = 3
	fl.Parent = flames[1].a
	local cur = pos
	local t2 = os.clock()
	local DURF = 3.6
	local dt = 0.016
	while os.clock() - t2 < DURF do
		local el = os.clock() - t2
		local x = el / DURF
		cur = cur + Vector3.new(math.sin(el * 2) * 2 * dt, (14 + 400 * x * x) * dt, 0)
		local yawA = 7.5 + el * (1.5 + x * 3)
		place(1, cur, yawA)
		for _, f in ipairs(flames) do
			f.a.CFrame = CFrame.new(cur) * CFrame.Angles(0, yawA, 0) * CFrame.new(f.sd * 1.4, -4.9, 0)
		end
		if x > 0.75 then
			for _, it in ipairs(list) do it.p.Transparency = (x - 0.75) / 0.25 end
		end
		dt = RunService.Heartbeat:Wait()
	end
	for _, it in ipairs(list) do pcall(function() it.p:Destroy() end) end
	for _, f in ipairs(flames) do pcall(function() f.a:Destroy() end) end
end

function NX.dissolveBridge(B)
	if B.dissolving or B.dead then return end
	B.dissolving = true
	task.spawn(function()
		pcall(function()
			-- canh bao: dai den nhap nhay do
			local w0 = os.clock()
			while os.clock() - w0 < 2.4 and not B.dead do
				local on = math.floor((os.clock() - w0) * 7) % 2 == 0
				for _, sg in ipairs(B.segs) do
					for _, st in ipairs(sg.strips) do
						if st.Parent then st.Color = on and Color3.fromRGB(255, 70, 50) or COL.Glow end
					end
				end
				task.wait(0.05)
			end
			if B.dead then return end
			local hub = B.start + Vector3.new(0, 11, 0)
			-- nano an mon tu dau xa nhat ve gan, hat bay ve diem tap trung
			for i = #B.segs, 1, -1 do
				if B.dead then return end
				local sg = B.segs[i]
				nanoCubes(sg.pos + Vector3.new(0, 1.5, 0), 5, 7, fr(0.7, 1.1), hub)
				for _, p in ipairs(sg.parts) do
					if p.Parent then
						p.CanCollide = false
						tw(p, 0.35, {Size = p.Size * 0.15, Transparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
						Debris:AddItem(p, 0.45)
					end
				end
				task.wait(0.045)
			end
			task.wait(0.8)
			if B.dead then return end
			NX.backpack(hub)
		end)
		B.dead = true
	end)
end

function NX.runBridge(my)
	local root, foot = S.hrp, S.parts.FootR
	if not (root and foot) then return end
	local aim = nxAim(root.Position, 440)
	local dirF = nxFlat(aim - root.Position)
	if not dirF then return end
	nxFace(dirF)
	NX.stompEvt = false
	NX.stompDur = 1.0
	NX.stompT0 = os.clock()
	playSound(SND_PING, 0.6, 0.6)
	local w0 = os.clock()
	while not NX.stompEvt and os.clock() - w0 < 1.8 do RunService.Heartbeat:Wait() end
	if not alive(my) or not NX.stompEvt then return end

	local fp = S.parts.FootR.Position
	local gr = Workspace:Raycast(fp + Vector3.new(0, 3, 0), Vector3.new(0, -16, 0), rayParams())
	local startP = gr and gr.Position or (fp - Vector3.new(0, 0.7, 0))
	-- hieu ung dap chan nano
	shake(1.5, 0.6)
	playSound(SND_BOOM, 0.9, 0.8)
	ringFx(startP + Vector3.new(0, 0.3, 0), 26, COL.Glow, 0.7)
	ringFx(startP + Vector3.new(0, 0.3, 0), 16, COL.Gold, 0.5)
	dustBurst(startP, 10, 22, nil, 1.6)
	nanoCubes(startP + Vector3.new(0, 1.5, 0), 26, 4, 1.0)
	sparks(startP + Vector3.new(0, 0.5, 0), 30, COL.Gold, 14, 0.7)
	debrisChunks(startP, 10, 22, false)

	local tv = aim - startP
	local hl = Vector3.new(tv.X, 0, tv.Z).Magnitude
	if hl < 10 then return end
	local dy = math.clamp(tv.Y, -hl * 0.6, hl * 0.6)
	tv = Vector3.new(tv.X, dy, tv.Z)
	if tv.Magnitude > 420 then tv = tv.Unit * 420 end
	local dir = tv.Unit
	local total = tv.Magnitude
	local LEN = 8
	local nseg = math.floor(total / LEN) + 1
	local B = {segs = {}, start = startP, dir = dir, born = os.clock()}
	NX.bridges[#NX.bridges + 1] = B
	for i = 0, nseg - 1 do
		if B.dead then return end
		local p0 = startP + dir * (i * LEN)
		local c = p0 + dir * (LEN / 2) - Vector3.new(0, 0.8, 0)
		local cfs = CFrame.lookAt(c, c + dir)
		local sg = {parts = {}, strips = {}, pos = c}
		local L = LEN + 0.6
		local function add(name, size, rel, color, mat, collide, tr)
			local p = nxPart(name, size, color, mat, nil, collide)
			local fin = cfs * rel
			p.CFrame = fin * CFrame.new(0, -5, 0)
			p.Transparency = 0.92
			tw(p, 0.4, {CFrame = fin, Transparency = tr}, Enum.EasingStyle.Back)
			sg.parts[#sg.parts + 1] = p
			return p
		end
		add("BDeck", Vector3.new(14, 1.6, L), CFrame.new(0, 0, 0), Color3.fromRGB(58, 62, 72), Enum.Material.DiamondPlate, true, 0)
		for sd = -1, 1, 2 do
			add("BEdge", Vector3.new(0.6, 0.35, L), CFrame.new(sd * 6.7, 0.9, 0), COL.Gold, METAL, false, 0)
			add("BRail", Vector3.new(0.6, 1.8, L), CFrame.new(sd * 7.2, 1.7, 0), COL.Red, SMOOTH, true, 0.05)
			sg.strips[#sg.strips + 1] = add("BGlow", Vector3.new(0.3, 0.15, L * 0.9), CFrame.new(sd * 5.4, 0.85, 0), COL.Glow, NEON, false, 0.1)
		end
		add("BBrace", Vector3.new(11, 0.6, 1.2), CFrame.new(0, -1.1, 0), Color3.fromRGB(40, 42, 50), METAL, false, 0)
		B.segs[#B.segs + 1] = sg
		nanoCubes(c + Vector3.new(0, 2, 0), 4, 9, 0.42, c)
		if i % 6 == 0 then sparks(c, 6, COL.Glow, 6, 0.4) end
		task.wait(0.03)
	end
	B.built = true
	task.delay(BRIDGE_LIFE, function()
		if not B.dead then NX.dissolveBridge(B) end
	end)
end

function NX.castBridge()
	if NX.busyBridge or S.nuking then return end
	NX.busyBridge = true
	local my = S
	task.spawn(function()
		local ok, err = pcall(NX.runBridge, my)
		if not ok then warn("[Hulkbuster] Cau nano loi:", err) end
		NX.busyBridge = false
		NX.stompT0 = nil
	end)
end

------------------------------------------------------------------
-- CONG DICH CHUYEN
------------------------------------------------------------------
local function newPortal(center, n, out)
	local P = {center = center, n = n, out = out, R = PORTAL_R, scale = 0, age = 0, life = PORTAL_LIFE, rim = {}, spokes = {}, opening = false, closing = false}
	local rt = n:Cross(Vector3.yAxis)
	if rt.Magnitude < 0.05 then rt = Vector3.xAxis end
	P.rt = rt.Unit
	P.disc = nxPart("PortalDisc", Vector3.new(0.3, 2, 2), Color3.fromRGB(80, 170, 255), NEON, CYL)
	P.disc.Transparency = 0.4
	P.disc2 = nxPart("PortalDisc2", Vector3.new(0.25, 2, 2), Color3.fromRGB(235, 250, 255), NEON, CYL)
	P.disc2.Transparency = 0.65
	local cols = {COL.Gold, COL.Red, COL.Metal}
	local N = 28
	for i = 1, N do
		local p = nxPart("PortalRim", Vector3.new(1, 1.5, 1.7), cols[(i % 3) + 1], (i % 3 == 1) and SMOOTH or METAL)
		P.rim[i] = {p = p, a = (i / N) * math.pi * 2, th = math.random(), gone = false}
	end
	for k = 1, 5 do
		local sp = nxPart("PortalSpoke", Vector3.new(2, 0.12, 0.7), (k % 2 == 0) and COL.White or COL.Glow, NEON)
		sp.Transparency = 0.45 + 0.08 * k
		P.spokes[k] = sp
	end
	local lt = Instance.new("PointLight")
	lt.Color = Color3.fromRGB(130, 210, 255)
	lt.Range = 34
	lt.Brightness = 0
	lt.Parent = P.disc
	P.light = lt
	pcall(mkEmitter, P.disc2, {
		life = NumberRange.new(0.5, 1.1), speed = NumberRange.new(2, 6), rate = 30, spread = Vector2.new(180, 180), light = 1,
		color = ColorSequence.new(COL.Glow, COL.White),
		size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(1, 0)}),
	})
	NX.plist[#NX.plist + 1] = P
	return P
end

local function portalDestroy(P)
	pcall(function() P.disc:Destroy() end)
	pcall(function() P.disc2:Destroy() end)
	for _, b in ipairs(P.rim) do if not b.gone then pcall(function() b.p:Destroy() end) end end
	for _, s in ipairs(P.spokes) do pcall(function() s:Destroy() end) end
end

local function portalStep(P, dt)
	P.age = P.age + dt
	if P.opening then
		P.scale = math.min(1, P.scale + dt / (P.openT or 0.65))
		if P.scale >= 1 then P.opening = false end
	end
	if not P.closing and P.age >= P.life then P.closing = true end
	if P.closing then
		P.scale = P.scale - dt / 0.7
		if P.scale <= 0 then
			portalDestroy(P)
			P.dead = true
			return
		end
	end
	local ds = 1 - (1 - math.clamp(P.scale, 0, 1)) ^ 2
	local R = P.R
	local e = math.clamp((P.age - P.life * 0.3) / (P.life * 0.7), 0, 1)
	local t = P.age
	local up = Vector3.yAxis
	local base = CFrame.lookAt(P.center, P.center + P.n)
	local dsz = math.max(0.1, 2 * R * ds * (1 - 0.3 * e))
	P.disc.Size = Vector3.new(0.3, dsz, dsz)
	P.disc.CFrame = base * CFrame.Angles(0, math.pi / 2, 0)
	P.disc2.Size = Vector3.new(0.25, math.max(0.1, dsz * 0.78), math.max(0.1, dsz * 0.78))
	P.disc2.CFrame = base * CFrame.new(0, 0, -0.1) * CFrame.Angles(0, math.pi / 2, 0)
	local flick = (e > 0.5) and (0.5 * e * math.random()) or 0
	P.disc.Transparency = 0.35 + flick
	P.disc2.Transparency = 0.62 + flick * 0.5
	P.light.Brightness = 2 * ds * (1 - 0.5 * e)
	local seg = 2 * math.pi * R * ds / #P.rim * 1.12
	for _, b in ipairs(P.rim) do
		if not b.gone then
			if e > 0.02 and e > b.th * 0.92 then
				-- an mon nano: khoi vo thanh hat
				b.gone = true
				nanoCubes(b.p.Position, 3, 0.9, 1.3)
				b.p:Destroy()
			else
				local ca, sa = math.cos(b.a), math.sin(b.a)
				local radial = P.rt * ca + up * sa
				local tang = P.rt * (-sa) + up * ca
				local pos = P.center + radial * (R * ds)
				if e > 0.35 then
					local j = e * 0.25
					pos = pos + Vector3.new(fr(-j, j), fr(-j, j), fr(-j, j))
				end
				b.p.Size = Vector3.new(math.max(0.1, seg), 1.5 * ds + 0.05, 1.7 * ds + 0.05)
				b.p.CFrame = CFrame.fromMatrix(pos, tang, radial)
			end
		end
	end
	for k, sp in ipairs(P.spokes) do
		local th = t * (1.8 + k * 0.5) * ((k % 2 == 0) and 1 or -1) + k * 1.2566
		local u = P.rt * math.cos(th) + up * math.sin(th)
		sp.Size = Vector3.new(math.max(0.1, dsz * 0.85), 0.12, 0.7 * ds + 0.05)
		sp.CFrame = CFrame.fromMatrix(P.center + P.n * (0.15 + 0.05 * k), u, P.n)
	end
	if e > 0.02 then
		P.nT = (P.nT or 0) + dt
		if P.nT > (0.22 - 0.17 * e) then
			P.nT = 0
			local a = math.random() * math.pi * 2
			local rp = P.center + (P.rt * math.cos(a) + up * math.sin(a)) * (R * ds * fr(0.2, 1))
			nanoCubes(rp, 2, 0.6, 1.2)
		end
	end
end

function NX.killPortals(anim)
	for _, P in ipairs(NX.plist) do
		if anim then
			P.closing = true
		else
			portalDestroy(P)
			P.dead = true
		end
	end
	NX.portals = {}
	if not anim then NX.plist = {} end
end

local function openPortal(P)
	P.opening = true
	ringFx(P.center, PORTAL_R * 2.2, COL.Glow, 0.7)
	sparks(P.center, 24, COL.Glow, 10, 0.6)
	playSound(SND_PING, 0.8, 1.2)
end

------------------------------------------------------------------
-- V10.13: TU CUU KHI KHONG GIAN SUP DO MA DUOI KHONG CO DAT
--   dang mac giap          -> tu vao che do bay luon
--   giap tach roi, o xa    -> 2 cong dich chuyen (0.5s), giap chui vao cong, bay toi chu, mac 0.5s, vao bay
--   giap tach roi, o gan   -> bay sieu nhanh toi, hop the lien, vao bay
--   chua mac / chua co giap-> cac bo phan tu vu tru bay vao ~1s, tu vao bay
------------------------------------------------------------------
function NX.rescueRun()
	local char = player.Character
	local proot = char and char:FindFirstChild("HumanoidRootPart")
	if not proot then return end

	-- giu nguoi choi dung yen tren khong trong luc giap toi (khong de roi), nha ra khi giap da nam quyen dieu khien
	local holdCF = proot.CFrame
	local holding = false
	local holdConn
	local function holdOn()
		if holding then return end
		holding = true
		holdConn = RunService.Heartbeat:Connect(function()
			if not proot.Parent then return end
			if S.on and not S.drone and S.ctrl then return end
			proot.CFrame = holdCF
			proot.AssemblyLinearVelocity = Vector3.zero
			proot.AssemblyAngularVelocity = Vector3.zero
		end)
	end
	local function holdOff()
		holding = false
		if holdConn then holdConn:Disconnect() holdConn = nil end
	end

	local my = S
	local ok, err = pcall(function()
		if S.on and not S.drone then
			---------------- 1) dang mac giap: bay luon ----------------
			local w0 = os.clock()
			while S == my and S.on and (S.busy or S.assembling) and os.clock() - w0 < 2.5 do task.wait(0.05) end
			if S ~= my or not S.on or S.drone then return end
			if S.ctrl ~= "fly" then
				if not S.ctrl then
					beginAirControl()
					local vy = S.hrp.AssemblyLinearVelocity.Y
					S.fvel = Vector3.new(0, math.clamp(vy, -60, 0), 0)
				end
				S.fvel = S.fvel or Vector3.zero
				S.ctrl = "fly"
				S.stomp = false
				S.flying = true
				S.hoverFeet, S.hoverBack = false, false
				buildWings()
				ringFx(S.hrp.Position - Vector3.new(0, 3, 0), 16, COL.Fire, 0.6)
				playSound(SND_ROCKET, 0.5, 0.9)
				shake(0.8, 0.4)
			end

		elseif S.on and S.drone and S.shell and S.phrp and S.phrp.Parent then
			---------------- 2/3) giap tach roi ----------------
			holdOn()
			S.busy = true
			S.strikes = {}
			dismissExtras()
			S.dhold = true
			S.denter = false
			S.dfaceOwner = false
			S.dvel = Vector3.zero
			S.dmode, S.dlast = "fly", "fly"
			buildWings()
			local owner = S.phrp
			local a = S.fpos
			local b = owner.Position
			local dist = (a - b).Magnitude

			local function face(d)
				local f = Vector3.new(d.X, 0, d.Z)
				if f.Magnitude > 0.5 then S.frot = CFrame.lookAt(Vector3.zero, f.Unit) end
			end
			local function dash(p0, p1, T)
				face(p1 - p0)
				local t0 = os.clock()
				while S == my and S.on and S.drone do
					local u = math.clamp((os.clock() - t0) / T, 0, 1)
					S.fpos = p0:Lerp(p1, 1 - (1 - u) ^ 3)
					if u >= 1 then break end
					RunService.Heartbeat:Wait()
				end
			end

			if dist < CFG.RescueNear then
				-- GAN: bay sieu nhanh toi, hop the lien
				sparks(a, 20, COL.Glow, 12, 0.5)
				playSound(SND_ROCKET, 0.5, 1.4)
				dash(a, b, math.clamp(dist / 450, 0.1, 0.25))
				if S ~= my or not S.on then return end
				NX.quickEnter(0.22)
			else
				-- XA: 2 cong dich chuyen (0.5s) o cho giap va cho minh, giap chui vao cong roi bay toi chu
				local dn = (b - a).Unit
				local R = PORTAL_R
				local PA = newPortal(a + dn * (R + 5), -dn, dn)
				local PB = newPortal(b - dn * (R + 8), dn, -dn)
				for _, P in ipairs({PA, PB}) do
					P.openT = 0.5
					P.life = 4
					openPortal(P)
				end
				face(dn)
				local t0 = os.clock()
				while S == my and S.on and os.clock() - t0 < 0.5 do task.wait() end
				if S ~= my or not S.on then return end
				-- giap lao vao cong A, hien ra o cong B
				dash(a, PA.center, 0.14)
				if S ~= my or not S.on then return end
				sparks(PA.center, 30, COL.Glow, 14, 0.6)
				S.fpos = PB.center
				sparks(PB.center, 30, COL.Glow, 14, 0.6)
				ringFx(PB.center, PORTAL_R * 2, COL.Gold, 0.5)
				playSound(SND_PING, 0.8, 1.5)
				PA.closing = true
				-- bay liền toi chu
				dash(PB.center, owner.Position, 0.15)
				PB.closing = true
				if S ~= my or not S.on then return end
				NX.quickEnter(0.3)
			end

		else
			---------------- 4) chua mac / chua co giap: bo phan tu vu tru bay vao, ~1s ----------------
			holdOn()
			nxFlash(Color3.fromRGB(235, 245, 255), 0.5, 0.5)
			playSound(SND_PING, 0.8, 0.8)
			NX.asmOpts = {k = 0.7 / 4.7, air = true, distMul = 3}
			wear()
			NX.asmOpts = nil
		end
	end)
	holdOff()
	NX.asmOpts = nil
	if not ok then
		warn("[Hulkbuster] Tu cuu loi:", err)
		if S == my and S.on then
			S.busy = false
			S.post = nil
			S.dhold = false
		end
	end
end

function NX.rescueFall()
	if NX.rescuing then return end
	NX.rescuing = true
	pcall(NX.rescueRun)
	NX.rescuing = false
end

local function portalArmTargets(P)
	local pos = {}
	pos[1] = P.center + P.rt * (P.R + 2.4) + Vector3.new(0, -2, 0) - P.n * 1.5
	pos[-1] = P.center - P.rt * (P.R + 2.4) + Vector3.new(0, -2, 0) - P.n * 1.5
	return pos
end

function NX.runPortal(my)
	if S.nuking then return end
	if not S.extras then
		summonExtras()
		local w0 = os.clock()
		while (not S.extras or S.extras.xs < 0.6) and os.clock() - w0 < 1.6 do RunService.Heartbeat:Wait() end
	end
	if not alive(my) or not S.extras then return end
	local X = S.extras
	if X.goal == 0 then X.goal = 1 end
	local root = S.hrp
	local aim = nxAim(root.Position, 420)
	local dir = nxFlat(aim - root.Position)
	if not dir then return end
	local fd = Vector3.new(aim.X - root.Position.X, 0, aim.Z - root.Position.Z).Magnitude
	if fd < 28 then aim = root.Position + dir * 28 end
	nxFace(dir)
	NX.killPortals(true)
	local up = Vector3.new(0, PORTAL_R * 0.98, 0)
	local Apos = nxGround(root.Position + dir * 17)
	local Bpos = nxGround(aim)
	-- 1) 2 tay ve cong dau canh minh
	local A = newPortal(Apos + up, dir, -dir)
	NX.portals = {A = A}
	X.cst = {rate = 9, pos = portalArmTargets(A), face = A.center}
	task.wait(0.45)
	if not alive(my) then return end
	openPortal(A)
	task.wait(0.6)
	if not alive(my) or not S.extras then return end
	-- 2) 2 tay bay that nhanh toi cho da bam
	local B = newPortal(Bpos + up, dir, dir)
	X.cst = {rate = 16, pos = portalArmTargets(B), face = B.center}
	local w1 = os.clock()
	while os.clock() - w1 < 0.55 and alive(my) and S.extras do
		for _, bs in ipairs(X.bases) do sparks(bs.Position, 2, COL.Glow, 6, 0.3) end
		task.wait(0.03)
	end
	if not alive(my) then return end
	NX.portals.B = B
	openPortal(B)
	shake(0.5, 0.3)
	task.wait(0.8)
	-- 3) tay ve lai cho cu
	if S.extras then S.extras.cst = nil end
end

function NX.castPortal()
	if NX.busyPortal or S.nuking then return end
	NX.busyPortal = true
	local my = S
	task.spawn(function()
		local ok, err = pcall(NX.runPortal, my)
		if not ok then warn("[Hulkbuster] Cong dich chuyen loi:", err) end
		NX.busyPortal = false
		if S.extras and S.extras.cst then S.extras.cst = nil end
	end)
end

local function portalTeleport()
	local A, B = NX.portals.A, NX.portals.B
	if not (A and B) or A.dead or B.dead or A.closing or B.closing then return end
	if A.scale < 0.85 or B.scale < 0.85 then return end
	if os.clock() < NX.tpCd then return end
	local root = ownerRoot()
	if not (root and root.Parent) then return end
	local p = root.Position
	local pairs2 = {{A, B}, {B, A}}
	for _, pr in ipairs(pairs2) do
		local P, Q = pr[1], pr[2]
		local rel = p - P.center
		local dn = rel:Dot(P.n)
		local inplane = (rel - P.n * dn).Magnitude
		if math.abs(dn) < 4.5 and inplane < P.R * 0.82 then
			NX.tpCd = os.clock() + 1.4
			local gh = Workspace:Raycast(p, Vector3.new(0, -40, 0), rayParams())
			local h = gh and (p.Y - gh.Position.Y) or 6
			h = math.clamp(h, 3.5, 30)
			local ex = Q.center + Q.out * 10
			local gy = nxGround(Vector3.new(ex.X, Q.center.Y, ex.Z)).Y
			ringFx(P.center, P.R * 2.4, COL.Glow, 0.5)
			sparks(P.center, 20, COL.White, 10, 0.5)
			nxPlace(Vector3.new(ex.X, gy + h, ex.Z), CFrame.lookAt(Vector3.zero, Q.out).Rotation)
			ringFx(Q.center, Q.R * 2.4, COL.Glow, 0.5)
			sparks(Q.center, 20, COL.White, 10, 0.5)
			nxFlash(Color3.fromRGB(190, 225, 255), 0.55, 0.45)
			shake(0.6, 0.25)
			playSound(SND_PING, 0.9, 1.5)
			return
		end
	end
end

------------------------------------------------------------------
-- VONG LAP CHUNG + DIEU PHOI + DON DEP
------------------------------------------------------------------
function NX.step(dt)
	local H = NX.hole
	if H then
		holeStep(H, dt)
		if H.mode == "idle" and not H.dying then
			H.sT = (H.sT or 0) + dt
			if H.sT > 0.04 then
				H.sT = 0
				local ks = math.max(1, H.r / 9.8)
				local a = math.random() * math.pi * 2
				local rr = fr(18, 46) * ks
				local p0 = H.pos + Vector3.new(math.cos(a) * rr, fr(-14, 10) * ks, math.sin(a) * rr)
				local sc = NX.HOLE.StreakCols
				local st = nxPart("Pull", Vector3.new(0.18, 0.18, 3) * ks, sc[math.random(#sc)], NEON)
				st.CFrame = CFrame.lookAt(p0, H.pos)
				tw(st, 0.7, {CFrame = CFrame.lookAt(H.pos, H.pos + (H.pos - p0)), Transparency = 1, Size = Vector3.new(0.05, 0.05, 0.4) * ks}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				Debris:AddItem(st, 0.8)
			end
			if S.on and not NX.sucking and not NX.realm and not NX.exiting then
				local root = ownerRoot()
				if root and (root.Position - H.pos).Magnitude < HOLE_PULL then NX.suck(H) end
			end
			if not NX.realm and not NX.sucking and os.clock() - H.born > HOLE_LIFE then NX.killHole(true) end
		end
	end
	if #NX.plist > 0 then
		for i = #NX.plist, 1, -1 do
			local P = NX.plist[i]
			if P.dead then
				table.remove(NX.plist, i)
			else
				portalStep(P, dt)
				if P.dead then table.remove(NX.plist, i) end
			end
		end
		if S.on and NX.portals and NX.portals.A and NX.portals.B then portalTeleport() end
	end
	for i = #NX.bridges, 1, -1 do
		if NX.bridges[i].dead then table.remove(NX.bridges, i) end
	end
	if NX.guide then pcall(NX.guideStep, dt) end
	if NX.realm then
		local root = ownerRoot()
		if root and not NX.collapsing and root.Position.Y < NX_REALM.Y + NX.RLM.Floor - 40 then
			nxPlace(NX_REALM + Vector3.new(0, 7, 0))
		end
		-- V10.11: bay/nhay len cham vao ho den tren troi -> thoat ra qua ho trang
		local HH = NX.hole
		if root and HH and HH.mode == "idle" and not HH.dying and not NX.exiting and not NX.collapsing and os.clock() - (NX.realmT0 or 0) > 2 then
			if (root.Position - HH.pos).Magnitude < HH.r + NX.RLM.TouchPad then NX.exitRealm() end
		end
		if NX.realmSpin then
			for _, p in ipairs(NX.realmSpin) do
				if p.Parent then p.CFrame = p.CFrame * CFrame.Angles(dt * 0.2, dt * 0.3, 0) end
			end
		end
		local okS, eS = true, nil
		if not NX.collapsing then okS, eS = pcall(NX.realmStream, dt) end
		if not okS and not NX.realmWarned then
			NX.realmWarned = true
			warn("[Hulkbuster] Realm stream loi:", eS)
		end
	end
end

function NX.cast(kind)
	if kind == "armor" then NX.castHole()
	elseif kind == "fly" then NX.castBridge()
	elseif kind == "attack" then NX.castPortal() end
end

-- V10.13b: don dep khi thao giap TRONG khong gian ky ao: giu khong gian + ho den thoat + chi duong + sup do; chi bo cau / cong / hieu ung gan voi giap
NX.cleanupKeepRealm = function()
	NX.upGoal = 0
	NX.upW = 0
	NX.stompT0 = nil
	NX.dropV = 0
	pcall(NX.killPortals, false)
	for _, B in ipairs(NX.bridges) do
		B.dead = true
		for _, sg in ipairs(B.segs or {}) do
			for _, p in ipairs(sg.parts or {}) do pcall(function() p:Destroy() end) end
			for _, st in ipairs(sg.strips or {}) do pcall(function() st:Destroy() end) end
		end
	end
	NX.bridges = {}
	NX.busyBridge, NX.busyPortal, NX.sucking = false, false, false
end

NX.cleanup = function(full)
	NX.collapsing = false
	pcall(NX.guideStop)
	NX.upGoal = 0
	NX.upW = 0
	NX.stompT0 = nil
	NX.dropV = 0
	if NX.realm and NX.returnPos then
		pcall(function() nxPlace(NX.returnPos + Vector3.new(0, 3, 0), NX.returnRot) end)
	end
	NX.realm = false
	NX.exiting = false
	pcall(NX.spaceEnv, false)
	pcall(NX.killHole, false)
	pcall(NX.destroyRealm)
	pcall(NX.killPortals, false)
	for _, B in ipairs(NX.bridges) do B.dead = true end
	NX.bridges = {}
	NX.busyHole, NX.busyBridge, NX.busyPortal, NX.sucking = false, false, false, false
	pcall(function() if NX_FOLDER then NX_FOLDER:Destroy() end end)
	pcall(function() if NX_SOLID then NX_SOLID:Destroy() end end)
	NX_FOLDER, NX_SOLID = nil, nil
	if full and NX.conn then
		NX.conn:Disconnect()
		NX.conn = nil
	end
end

NX.conn = RunService.Heartbeat:Connect(function(dt)
	local ok, err = pcall(NX.step, dt)
	if not ok and not NX.warned then
		NX.warned = true
		warn("[Hulkbuster NX] " .. tostring(err))
	end
end)


local function resolve(kind, n)
	-- V10.12: o khong gian ky ao thi Tool1 x4 LUON hien chi duong + dem nguoc 180s (ke ca khi giap dang tat / dang busy), khong con thoat truc tiep
	if kind == "armor" and n >= 4 and NX.realm then NX.cast("armor") return end
	-- V10.4: co busy / assembling ket qua 15s (loi giua chung) => tu go, tool khong bi liet
	local nowT = os.clock()
	if S.busy then S.busyAt = S.busyAt or nowT; if nowT - S.busyAt > 15 then S.busy = false; S.busyAt = nil end else S.busyAt = nil end
	if S.assembling then S.asmAt = S.asmAt or nowT; if nowT - S.asmAt > 15 then S.assembling = false; S.asmAt = nil end else S.asmAt = nil end
	if S.assembling then return end
	if S.busy and not (kind == "armor" and n == 2) then return end
	if n >= 4 and S.on then NX.cast(kind) return end   -- V10: bam 4 lan = 3 chieu moi
	if kind == "armor" then
		if not S.on then wear()
		elseif S.drone then
			-- dang ra khoi giap: bam 1 = giap dam, bam 2 = thao giap, bam 3 = chan (khong bat man hinh quet)
			if n == 2 then unwear(true)
			elseif n == 1 then dashPunch() end
		elseif n >= 3 then toggleScan()
		elseif n == 2 then unwear(true)
		else dashPunch() end
		return
	end
	if not S.on then return end
	if kind == "fly" then
		if n >= 3 then task.spawn(toggleExit)
		elseif S.drone then
			if n == 2 then droneWalk() else droneFly() end
		elseif n >= 2 then stopFly()
		elseif S.ctrl == "fly" then fireSalvo()
		else startFly() end
	elseif kind == "attack" then
		if S.nuking then return end
		if n >= 3 then nuke()
		elseif n == 2 then dismissExtras()
		elseif not S.extras then summonExtras()
		else barrage() end
	end
end

local clicks = {}
local function onClick(kind)
	local c = clicks[kind]
	if not c then c = {n = 0, token = 0}; clicks[kind] = c end
	-- V10.4: Tool that + o GUI cung ban 1 cham => chi tinh 1 (hai cu bam that cach nhau > 60ms)
	local nowC = os.clock()
	if c.last and nowC - c.last < 0.06 then return end
	c.last = nowC
	c.n += 1
	c.token += 1
	local tok = c.token
	task.delay(CFG.ClickWindow, function()
		if c.token ~= tok then return end
		local n = c.n
		c.n = 0
		local ok, err = pcall(resolve, kind, n)
		if not ok then
			warn("[Hulkbuster] Loi:", err)
			S.busy, S.assembling = false, false   -- V10.4: loi giua chung khong de ket co => tool khong chet
		end
	end)
end

------------------------------------------------------------------
-- TOOL
------------------------------------------------------------------
local TOOLS = {
	{name = "BusterArmor", kind = "armor", tip = "1: bien hinh/dam | 2: thao | 3: man hinh quet+ESP | 4: HO DEN sat vun (bam lai khi o khong gian ky ao = ve)"},
	{name = "BusterFly", kind = "fly", tip = "1: bay/phao | 2: tat bay | 3: ra/vao giap | 4: CAU NANO"},
	{name = "BusterAttack", kind = "attack", tip = "1: tay phu/dam | 2: thao tay | 3: bom nguyen tu | 4: CONG DICH CHUYEN"},
}

local function giveTools()
	local bp = player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack", 5)
	if not bp then return end
	for _, def in ipairs(TOOLS) do
		local old = bp:FindFirstChild(def.name) or (player.Character and player.Character:FindFirstChild(def.name))
		if old then old:Destroy() end
		local t = Instance.new("Tool")
		t.Name = def.name
		t.RequiresHandle = false
		t.CanBeDropped = false
		t.ToolTip = def.tip
		t.Activated:Connect(function() onClick(def.kind) end)
		t.Parent = bp
	end
end

giveTools()

------------------------------------------------------------------
-- GIAO DIEN TOOL: thanh ngang 3 o nhu balo | trong suot | vien keo tha to, giao dien nho
-- bam o tool = CAM tool (sang len, bam lai = cat). Dang cam: cham man hinh = dung tool
-- (cham nhanh 2-3 lan = lenh 2 / 3, y het tool that trong balo)
------------------------------------------------------------------
local ToolGui = {}

local function destroyToolGui()
	for _, c in ipairs(ToolGui.conns or {}) do pcall(function() c:Disconnect() end) end
	if ToolGui.gui then pcall(function() ToolGui.gui:Destroy() end) end
	ToolGui = {}
end

local function buildToolGui()
	local pg = player:WaitForChild("PlayerGui")
	local old = pg:FindFirstChild("HB_ToolGui")
	if old then old:Destroy() end

	local conns = {}
	ToolGui.conns = conns
	local function bind(sig, fn) local c = sig:Connect(fn); table.insert(conns, c); return c end

	local gui = Instance.new("ScreenGui")
	gui.Name = "HB_ToolGui"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 100
	gui.IgnoreGuiInset = true   -- dung toan man hinh (khong bi chan boi thanh tren)
	gui.Parent = pg
	ToolGui.gui = gui

	local FONT = Enum.Font.GothamBold
	local SLOT_W, SLOT_H, GAP = 84, 48, 4          -- o tool (ngan lai)
	local CTRL_W = 60                                -- nut - va X (rong ra) (thu nho / dong)
	local MARGIN = 15                                -- vien keo tha to bao quanh (tren/duoi/trai/phai)
	local LIFT = 4                                   -- o dang cam nhac len
	local INNER_W = CTRL_W + GAP + #TOOLS * SLOT_W + (#TOOLS - 1) * GAP
	local PANEL_W, PANEL_H = INNER_W + MARGIN * 2, SLOT_H + MARGIN * 2
	local SLOT_COL, PURPLE = Color3.fromRGB(45, 45, 60), Color3.fromRGB(130, 80, 180)
	local BLUE = Color3.fromRGB(40, 170, 255)

	local function round(o, r) local u = Instance.new("UICorner"); u.CornerRadius = UDim.new(0, r or 8); u.Parent = o end
	local function stroke(o, col, th, tr) local s = Instance.new("UIStroke"); s.Color = col or COL.Gold; s.Thickness = th or 1.5; s.Transparency = tr or 0; s.Parent = o; return s end

	-- keo tha giong TTHub: nguong 8px, gioi han trong man hinh, cham nhe = click
	local function SetupDrag(handle, target, onTap, overflow)
		overflow = overflow or 0
		local dragging, dragInput, dragStart, startPos, startVec, hasMoved = false, nil, nil, nil, nil, false
		bind(handle.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if not dragging then
					dragging, hasMoved = true, false
					dragInput = input
					dragStart = input.Position
					startVec = Vector2.new(input.Position.X, input.Position.Y)
					startPos = target.Position
					local conn
					conn = input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging, dragInput = false, nil
							if not hasMoved and onTap then onTap() end
							conn:Disconnect()
						end
					end)
				end
			end
		end)
		bind(UIS.InputChanged, function(input)
			if input == dragInput and dragging then
				if (Vector2.new(input.Position.X, input.Position.Y) - startVec).Magnitude > 8 then
					hasMoved = true
					local delta = input.Position - dragStart
					local vp, sz, an = gui.AbsoluteSize, target.AbsoluteSize, target.AnchorPoint
					-- overflow: phan vien trong suot duoc phep tran ra ngoai => phan nhin thay cham sat mep man hinh
					local minX = -an.X * sz.X - startPos.X.Scale * vp.X - overflow
					local maxX = vp.X - (1 - an.X) * sz.X - startPos.X.Scale * vp.X + overflow
					local minY = -an.Y * sz.Y - startPos.Y.Scale * vp.Y - overflow
					local maxY = vp.Y - (1 - an.Y) * sz.Y - startPos.Y.Scale * vp.Y + overflow
					target.Position = UDim2.new(startPos.X.Scale, math.clamp(startPos.X.Offset + delta.X, minX, maxX),
						startPos.Y.Scale, math.clamp(startPos.Y.Offset + delta.Y, minY, maxY))
				end
			end
		end)
	end

	-- khung chinh: trong suot, phan vien (MARGIN) la vung de cam keo
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.fromOffset(PANEL_W, PANEL_H)
	panel.Position = UDim2.new(0.5, -PANEL_W / 2, 1, -PANEL_H - 60)
	panel.BackgroundColor3 = Color3.new(0, 0, 0)
	panel.BackgroundTransparency = 0.88
	panel.BorderSizePixel = 0
	panel.ClipsDescendants = true
	panel.Active = true
	panel.Parent = gui
	round(panel, 16)
	stroke(panel, Color3.new(1, 1, 1), 1, 0.85)
	SetupDrag(panel, panel, nil, MARGIN)

	-- cot nut nho: thu nho / dong
	local function smallBtn(txt, y, col, action)
		local h = (SLOT_H - GAP) / 2
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(CTRL_W, h)
		b.Position = UDim2.fromOffset(MARGIN, MARGIN + y)
		b.BackgroundColor3 = col
		b.BackgroundTransparency = 0.35
		b.Text = (txt == "–") and "" or txt
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Font = FONT
		b.TextSize = 24
		b.AutoButtonColor = false
		b.Parent = panel
		round(b, 6)
		if txt == "–" then
			-- dau tru ve bang thanh ngang de to ro, khong phu thuoc font
			local bar = Instance.new("Frame")
			bar.Size = UDim2.fromOffset(26, 5)
			bar.Position = UDim2.new(0.5, -13, 0.5, -2)
			bar.BackgroundColor3 = Color3.new(1, 1, 1)
			bar.BorderSizePixel = 0
			bar.Parent = b
			round(bar, 3)
		end
		SetupDrag(b, panel, action, MARGIN)
		return b
	end

	-- 3 o tool nhu balo
	local held = nil
	local slots = {}

	local function refresh()
		for i, s in ipairs(slots) do
			local on = held == i
			tw(s.btn, 0.15, {
				BackgroundTransparency = on and 0.3 or 0.5,
				Position = on and s.up or s.base,
			})
			s.st.Color = on and BLUE or PURPLE
			s.st.Thickness = on and 2.5 or 1.2
			s.st.Transparency = on and 0 or 0.2
		end
	end

	local function flash(i)
		local s = slots[i]
		if not s then return end
		s.st.Color = Color3.new(1, 1, 1)
		tw(s.st, 0.25, {Color = BLUE})
	end

	for i, def in ipairs(TOOLS) do
		local x = MARGIN + CTRL_W + GAP + (i - 1) * (SLOT_W + GAP)
		local btn = Instance.new("TextButton")
		btn.Name = def.name
		btn.Size = UDim2.fromOffset(SLOT_W, SLOT_H)
		btn.Position = UDim2.fromOffset(x, MARGIN)
		btn.BackgroundColor3 = SLOT_COL
		btn.BackgroundTransparency = 0.5
		btn.AutoButtonColor = false
		btn.Text = def.name
		btn.TextColor3 = COL.White
		btn.Font = FONT
		btn.TextSize = 13
		btn.TextScaled = true
		local lim = Instance.new("UITextSizeConstraint")
		lim.MaxTextSize, lim.MinTextSize = 13, 8
		lim.Parent = btn
		local pad = Instance.new("UIPadding")
		pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 6), UDim.new(0, 6)
		pad.Parent = btn
		btn.Parent = panel
		round(btn, 7)
		local st = stroke(btn, PURPLE, 1.2, 0.2)

		local num = Instance.new("TextLabel")
		num.Size = UDim2.fromOffset(14, 14)
		num.Position = UDim2.fromOffset(4, 1)
		num.BackgroundTransparency = 1
		num.Text = tostring(i)
		num.TextColor3 = Color3.fromRGB(190, 190, 205)
		num.Font = FONT
		num.TextSize = 11
		num.Parent = btn

		slots[i] = {btn = btn, st = st, base = UDim2.fromOffset(x, MARGIN), up = UDim2.fromOffset(x, MARGIN - LIFT)}

		-- cham o = cam tool / cat tool (giong hotbar)
		SetupDrag(btn, panel, function()
			if held == i then held = nil else held = i end
			refresh()
		end, MARGIN)
	end

	-- dang cam tool: cham man hinh (khong phai GUI, khong vuot) = dung tool
	local down
	bind(UIS.InputBegan, function(input, gp)
		if gp or not held then return end
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			down = {type = t, obj = input, pos = Vector2.new(input.Position.X, input.Position.Y), time = os.clock()}
		end
	end)
	bind(UIS.InputEnded, function(input)
		if not down or input.UserInputType ~= down.type then return end
		if down.type == Enum.UserInputType.Touch and input ~= down.obj then return end
		local d = (Vector2.new(input.Position.X, input.Position.Y) - down.pos).Magnitude
		local dt = os.clock() - down.time
		down = nil
		if held and d < 24 and dt < 0.6 then   -- V10.4: noi nguong cham (truoc 14px / 0.4s) tranh mat cu bam
			flash(held)
			onClick(TOOLS[held].kind)
		end
	end)

	smallBtn("–", 0, Color3.fromRGB(70, 70, 90), function() task.spawn(function() ToolGui.minimize() end) end)
	smallBtn("X", (SLOT_H + GAP) / 2, Color3.fromRGB(150, 30, 30), destroyToolGui)

	-- nut tron khi thu nho: vien ngoai to de keo, vong trong nho
	local bubble = Instance.new("TextButton")
	bubble.Name = "Bubble"
	bubble.Size = UDim2.fromOffset(62, 62)
	bubble.Position = panel.Position
	bubble.BackgroundColor3 = Color3.new(0, 0, 0)
	bubble.BackgroundTransparency = 0.88
	bubble.AutoButtonColor = false
	bubble.Text = ""
	bubble.Visible = false
	bubble.Parent = gui
	round(bubble, 31)
	local core = Instance.new("TextLabel")
	core.Size = UDim2.fromOffset(36, 36)
	core.Position = UDim2.new(0.5, -18, 0.5, -18)
	core.BackgroundColor3 = COL.Red
	core.BackgroundTransparency = 0.3
	core.Text = "HB"
	core.TextColor3 = COL.Gold
	core.Font = FONT
	core.TextSize = 15
	core.Parent = bubble
	round(core, 18); stroke(core, COL.Gold, 1.5, 0.2)

	local function clampInto(obj, ov)
		ov = ov or 0
		local vp, sz = gui.AbsoluteSize, obj.AbsoluteSize
		local p = obj.Position
		obj.Position = UDim2.new(0, math.clamp(p.X.Offset + p.X.Scale * vp.X, -ov, math.max(-ov, vp.X - sz.X + ov)),
			0, math.clamp(p.Y.Offset + p.Y.Scale * vp.Y, -ov, math.max(-ov, vp.Y - sz.Y + ov)))
	end

	local function openPanel()
		bubble.Visible = false
		panel.Position = bubble.Position
		panel.Visible = true
		panel.Size = UDim2.fromOffset(0, 0)
		tw(panel, 0.25, {Size = UDim2.fromOffset(PANEL_W, PANEL_H)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		task.delay(0.3, function() if panel.Parent then clampInto(panel, MARGIN) end end)
	end

	function ToolGui.minimize()
		held = nil
		refresh()
		bubble.Position = panel.Position
		local t = tw(panel, 0.2, {Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		t.Completed:Wait()
		panel.Visible = false
		bubble.Visible = true
		clampInto(bubble, 13)
	end

	SetupDrag(bubble, bubble, openPanel, 13)
end

pcall(buildToolGui)

local charConn = player.CharacterAdded:Connect(function()
	pcall(unwear)
	task.wait(0.6)
	giveTools()
end)

pcall(function()
	if getgenv then
		getgenv().HulkbusterCleanup = function()
			pcall(unwear)
			pcall(NX.cleanup, true)
			pcall(envRestoreNow)
			pcall(destroyHUD)
			pcall(destroyToolGui)
			pcall(function() charConn:Disconnect() end)
			pcall(function() FX:Destroy() end)
			local bp = player:FindFirstChildOfClass("Backpack")
			for _, def in ipairs(TOOLS) do
				if bp and bp:FindFirstChild(def.name) then bp[def.name]:Destroy() end
				if player.Character and player.Character:FindFirstChild(def.name) then player.Character[def.name]:Destroy() end
			end
		end
		getgenv().BusterCleanup = getgenv().HulkbusterCleanup
	end
end)

print("[Hulkbuster V10.13] Loaded! BusterArmor | BusterFly | BusterAttack | bam 4 lan = ho den / cau nano / cong dich chuyen | GUI: nut HB / dau - de thu nho")
