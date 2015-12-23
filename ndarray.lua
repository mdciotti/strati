ndarray = {}
ndarray.__index = ndarray

function ndarray.new(cols, rows)
    local self = {}
    setmetatable(self, ndarray)
    self.cols = cols
    self.rows = rows
    self.data = {}
    return self
end

function ndarray:get(i, j)
    return self.data[j * self.cols + i]
end

function ndarray:set(i, j, value)
    self.data[j * self.cols + i] = value
end

function ndarray:each(lambda)
    for i = 0, self.cols - 1 do
        for j = 0, self.rows - 1 do
            lambda(i, j, self:get(i, j))
        end
    end
end

function ndarray:init(lambda)
    for i = 0, self.cols - 1 do
        for j = 0, self.rows - 1 do
            self:set(i, j, lambda(i, j))
        end
    end
end
