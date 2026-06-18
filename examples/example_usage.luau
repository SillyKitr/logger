-- Example usage of this.
local Logger = require("../src")
local log = Logger.new({
        name = "example",
        level = "trace",
		colors = true,
        -- Yea sink is not gonna be used here since it's works for
        -- Custom logging actions.
})

log:trace("This is a trace!")
log:debug("wow")
log:info("Who cares anyways?")
log:warn("mrrrp?")

-- // loops or whatever?
for i = 5,1,-1 do
    log:error("Bullshit spotted in davenport, iowa")
end

log:fatal("It's joever.")