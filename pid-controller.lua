-- PID Controller
PID = {}
PID.__index = PID

function PID.new(pFactor, iFactor, dFactor)
    local self = setmetatable({}, PID)
    self.pFactor = pFactor -- kg * m/s^2
    self.iFactor = iFactor -- kg * m/s^3
    self.dFactor = dFactor -- kg * m/s
    self._integral = 0
    self._lastError = 0
    return self
end

function PID:update(setpoint, actual, dt)
    local present = setpoint - actual
    self._integral = self._integral + present * dt
    local deriv = (present - self._lastError) / dt
    self._lastError = present
    return present * self.pFactor + self._integral * self.iFactor + deriv * self.dFactor
end
